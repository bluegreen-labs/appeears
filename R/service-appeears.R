appeears_service <- R6::R6Class("appeears_service",
  inherit = service,
  public = list(
    submit = function() {

      if (private$status != "unsubmitted") {
        return(self)
      }

      if (private$verbose) message("\nSubmitting request")

      #  get the response for the query provided
      response <- httr::POST(
        file.path(rs_server(),"task"),
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
        file.path(rs_server(),"task", private$name),
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
      } else if (private$status == "done") {
        private$code <- 302
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
      if (private$downloaded == TRUE) {
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
      if (private$verbose) message("\nDownloading files")

      # get bundle (can't take more than 30 seconds)
      response <- httr::GET(
        file.path(rs_server(),"bundle", private$name),
        httr::add_headers(
          Authorization = paste("Bearer", private$token)
        ),
        httr::timeout(30)
      )

      # trap general http error
      if (httr::http_error(response)) {
        stop(
      "      Your requested download is unavailable as the session expired\n
      (download > 48h old), or your connection timed out!",
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
        temp_file <- file.path(tempdir(), basename(file$file_name))

        # sort downloads in directories by task name
        # mostly because of potential repeated naming
        # of area based downloads
        final_path <- file.path(
          private$path,
          # private$name # use this to use the full task id (messy)
          jsonlite::fromJSON(private$request)$task_name
        )

        # create final path if it does not exist
        if (!dir.exists(final_path)) {
          dir.create(final_path)
        }

        # final file name
        final_file <- file.path(final_path, basename(file$file_name))

        # write the file to disk using the destination directory and file name
        response <- httr::GET(
          file.path(rs_server(), "bundle/", private$name, file$file_id),
          httr::write_disk(temp_file, overwrite = TRUE),
          httr::add_headers(
            Authorization = paste("Bearer", private$token)
          )
        )

        # log if the file was successfully downloaded
        if (httr::http_error(response)) {
          message(sprintf("- download of %s failed", temp_file))
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
          } else {
            message(sprintf("- files are temporary stored in -> %s", temp_file))
          }

          return(TRUE)
        }
      })

      # trap (http) errors on download, return a general error statement
      if (!all(unlist(downloaded))) {
        if (fail_is_error) {
          stop("Some downloads failed - consider redownloading")
        } else {
          warning("Some downloads failed - consider redownloading")
          return(self)
        }
      }

      # set the all green
      private$downloaded <- all(unlist(downloaded))
      return(self)
    },

    exit_message = function() {
      appeears:::exit_message(
        url = private$name,
        path = private$path
      )
    },

    delete = function() {

      #  get the response for the query provided
      response <- httr::DELETE(
        file.path(rs_server(), "task", private$name),
        httr::add_headers(
          Authorization = paste("Bearer", private$token)
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
        message("- Deleted data from queue for task id:")
        message("  ", private$name, "\n")
      }

      private$status <- "deleted"
      private$code <- 204
      return(self)
    }
  ),
  private = list(
    service = "appears",
    http_verb = "POST",
    get_location = function(content) {
      content$location
    }
  )
)
