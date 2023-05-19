service <- R6::R6Class("appeears_service",
  cloneable = FALSE,
  public = list(
    initialize = function(request,
                          user,
                          url,
                          path = tempdir(),
                          verbose = TRUE) {
      private$user <- user
      private$token <- rs_login(user)
      private$request <- request
      private$path <- path
      private$verbose <- verbose
      private$status <- "unsubmitted"
      private$next_retry <- Sys.time()

      return(self)
    },

    print = function(...) {
      request <- capture.output(str(private$request, 1))
      cat("Download request \n")
      cat("  Status:  ", private$status, "\n")
      cat("  Location:", if (private$downloaded) private$path else "NA", "\n")
      cat("  Request:", request, sep = "\n     ")

      invisible(self)
    },

    submit = function() {
     stop("not implemented")
    },

    update_status = function(fail_is_error = TRUE,
                             verbose = NULL) {
      stop("not implemented")
      },

    download = function(force_redownload = FALSE,
                        fail_is_error = TRUE,
                        verbose = NULL) {
     stop("not implemented")
    },

    transfer = function(time_out = 3600, verbose = NULL) {
      if (private$verbose) {
        message(sprintf("- timeout set to %.1f hours", time_out/3600))
      }

      # set time-out
      time_out <- Sys.time() + time_out

      # Try to download while pending.
      # Quit if timed out
      while (Sys.time() < time_out) {
        self$download()

        if (private$downloaded) {
          break
        }
      }

      if (self$is_pending()) {
        if (private$verbose) {
          # needs to change!
          message("  Your download timed out, however ...\n")
          self$exit_message()  # TODO
        }
      }
      return(self)

    },

    exit_message = function() {
      stop("not implemented")
    },

    delete = function() {
      stop("not implemented")
    },

    browse_request = function() {
      stop("not implemented")
    },

    # rename private$name to private$task_id
    get_task_id = function() {
      private$name
    },

    get_status = function() {
      private$status
    },

    get_request = function() {
      private$request
    },

    is_failed = function() {
      private$failed
    },

    is_success = function() {
      private$downloaded
    },

    is_running = function() {
      private$status != "done"
    },

    is_pending = function() {
      # Always pending, unless it has failed or successfully downloaded.
      !(self$is_failed() | private$downloaded)
    }

  ),
  private = list(
    service = NA,
    request = NA,

    user = NA,
    token = NA,

    path = NA,
    time_out = NA,

    status = NA,
    failed = FALSE,
    code = NA,
    name = NA,
    retry = NA,
    next_retry = NA,

    verbose = TRUE,
    downloaded = FALSE
  )
)

