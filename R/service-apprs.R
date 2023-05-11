apprs_service <- R6::R6Class("apprs_service",
  inherit = service,
  public = list(
    submit = function() {
      if (private$status != "unsubmitted") {
        return(self)
      }

      # get (current) token
      #token <- apprs_login(user)

      #  get the response for the query provided
      response <- httr::POST(
        file.path(apprs_server(),"task"),
        body = private$request,
        encode = "json",
        httr::add_headers(
          Authorization = paste("Bearer", private$token),
          "Content-Type" = "application/json")
      )

      # trap general http error
      if (httr::http_error(response)) {
        stop(httr::content(response),
          call. = FALSE
        )
      }

      # grab content, to look at the status
      ct <- httr::content(response)
      ct$code <- 202

      # some verbose feedback
      if (private$verbose) {
        message("- staging data transfer at url endpoint or task id:")
        message("  ", ct$task_id, "\n")
      }

      private$status <- "submitted"
      private$code <- ct$code
      private$name <- ct$task_id
      private$retry <- 5
      private$next_retry <- Sys.time() + private$retry
      private$url <- file.path(apprs_server(), "task","task_id", ct$task_id)
      return(self)
    },
    update_status = function(fail_is_error = TRUE,
                             verbose = NULL) {
      if (private$status == "unsubmitted") {
        self$submit()
        return(self)
      }

      if (private$status == "deleted") {
        warn_or_error(
          "Request was previously deleted from queue",
          call. = FALSE,
          error = fail_is_error
        )
        return(self)
      }

      if (private$status == "failed") {
        warn_or_error("Request has failed", call. = FALSE, error = fail_is_error)
        return(self)
      }

      # get (current) token
      #token <- apprs_login(user)

      # retries
      retry_in <- as.numeric(private$next_retry) - as.numeric(Sys.time())

      if (retry_in > 0) {
        if (private$verbose) {
          # let a spinner spin for "retry" seconds
          spinner(retry_in)
        } else {
          # sleep
          Sys.sleep(retry_in)
        }
      }

      # GET data on the task process (based on task ID)
      response <- httr::GET(
        file.path(apprs_server(),"task", private$name),
        httr::add_headers(
          Authorization = paste("Bearer", private$token),
          "Content-Type" = "application/json")
      )

      # split out response and status
      # if done, hand over data for download
      ct <- httr::content(response)
      private$status <- ct$status

      if (private$status != "done" || is.null(private$status)) {
        private$code <- 202
        private$file_url <- NA # just to be on the safe side
      } else if (private$status == "done") {
        private$code <- 302
        private$file_url <- private$get_location(ct)
      } else if (private$status == "failed") {
        private$code <- 404
        permanent <- if (ct$crashed) "permanent "
        error_msg <- paste0(
          "Data request crashed for ", ct$task_id, " after ",
          ct$attempts, " attempts!"
        )
        warn_or_error(error_msg, error = fail_is_error)
      }
      private$next_retry <- Sys.time()
      return(self)
    },

    download = function(
      force_redownload = FALSE,
      fail_is_error = TRUE,
      verbose = NULL
      ) {
      # Check if download is actually needed
      if (private$downloaded == TRUE & file.exists(private$file) & !force_redownload) {
        if (private$verbose) message("File already downloaded")
        return(self)
      }

      # Check status
      self$update_status()

      if (private$status != "done") {
        # if (private$verbose) message("\nRequest not completed")
        return(self)
      }

      # If it's completed, begin download
      if (private$verbose) message("\nDownloading file")
      # token <- apprs_login(user)

      # list the full bundle of files associated with this
      # task_id

      # get bundle
      response <- httr::GET(
        file.path(apprs_server(),"bundle", private$name),
        httr::add_headers(
          Authorization = paste("Bearer", private$token)
        )
      )

      # trap general http error
      if (httr::http_error(response)) {
        stop("Your requested download is unavailable as the session expired (download > 48h old).",
             call. = FALSE
        )
      }

      # split out the content from the returned
      # API data, and clean up the JSON formatting
      ct <- httr::content(response)

      # try downloading whole bundle, log downloaded
      # state
      downloaded <- lapply(ct$files, function(file){

        # set temp file name
        temp_file <- file.path(tempdir(), file$file_name)

        # set final file name
        final_file <- file.path(private$path, file$file_name)

        # write the file to disk using the destination directory and file name
        response <- GET(
          file.path(apprs_server(), "bundle/", private$name, file$file_id),
          write_disk(temp_file, overwrite = TRUE),
          progress(),
          httr::add_headers(
            Authorization = paste("Bearer", private$token)
          )
        )

        # log if the file was successfully downloaded
        if (httr::http_error(response)) {
          return(FALSE)
        } else {

          # This juggling of files is due to some error when writing to
          # network drives in particular. Data is therefore first locally
          # buffered and then transferred to any other drive (networked / local)

          if(temp_file != final_file) {
            file.copy(
              temp_file,
              final_file,
              overwrite = TRUE
              )
            file.remove(temp_file)

            if (private$verbose) {
              message(sprintf("- moved temporary files to -> %s", final_file))
            }
          }

          return(TRUE)
        }
      })

      # trap (http) errors on download, return a general error statement
      if (all(downloaded)) {
        if (fail_is_error) {
          stop("Some downloads failed - consider redownloading")
        } else {
          warning("Some downloads failed - consider redownloading")
          return(self)
        }
      }

      # set the all green
      private$downloaded <- all(downloaded)

      return(self)
    },

    delete = function() {

      #  get the response for the query provided
      response <- httr::DELETE(
        private$url,
        httr::authenticate(private$user, key),
        httr::add_headers(
          "Accept" = "application/json",
          "Content-Type" = "application/json"
        )
      )

      # trap general http error
      if (httr::http_error(response)) {
        stop(httr::content(response),
             call. = FALSE
        )
      }

      # some verbose feedback
      if (private$verbose) {
        message("- Delete data from queue for url endpoint or request id:")
        message("  ", private$url, "\n")
      }

      private$status <- "deleted"
      private$code <- 204
      return(self)
    }
  ),
  private = list(
    service = "appears",
    http_verb = "POST",
    request_url = function() {
      sprintf(
        "%s/resources/%s",
        private$url,
        private$request$dataset_short_name
      )
    },
    get_location = function(content) {
      content$location
    }
  )
)
