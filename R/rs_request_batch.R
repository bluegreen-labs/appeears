#' @param user user (email address or ID) provided by the AppEEARS data service,
#' used to retrieve the token set by \code{\link[appeears]{rs_set_key}}
#' @param path path were to store the downloaded data
#' @param request_list a list of requests that will be processed in parallel.
#' @param workers maximum number of simultaneous request that will be submitted
#' to the service. Most services are limited to ~20 concurrent requests
#' (default = 2).
#' @param time_out individual time out for each request
#' @param total_timeout overall timeout limit for all the requests in seconds.
#'  (note that the overall timeout on a session is 48h)
#' @param verbose show feedback on processing
#' @importFrom R6 R6Class
#'
#' @rdname rs_request
#' @export
rs_request_batch <- function(
    request_list,
    workers = 2,
    user,
    path = tempdir(),
    time_out = 7200,
    total_timeout = length(request_list)*time_out/workers,
    verbose = TRUE
) {

  json_in_list <- vapply(request_list, function(req) {
    any(grepl("task_name", names(jsonlite::fromJSON(req))))
    },
    logical(1)
  )

  if (any(!json_in_list)) {
    stop("request_list must be a list of JSON requests")
  }

  # can't check for filenames as too diverse in output
  # filenames <- vapply(request_list, function(x) x$target, character(1))
  #
  # if (any(duplicated(filenames))) {
  #   stop("Duplicated targets found in `request_list`.")
  # }

  N <- length(request_list)
  slots <- as.list(rep(FALSE, workers))
  queue <- request_list
  done  <- list()

  force(total_timeout)  # Need to evaluate the expression before changing time_out
  time_out <- repeat_if_one(time_out, N)
  if (missing(user)) user <- NULL

  user <- repeat_if_one(user, N)
  path <- repeat_if_one(path, N)

  timeout_time <- Sys.time() + total_timeout

  while (length(done) < length(request_list) & Sys.time() < timeout_time) {
    for (w in seq_along(slots)) {

      # If a slot is free and there's a queue,
      # assign to it the next pending request,
      # remove that request from the queue
      if (isFALSE(slots[[w]]) & length(queue) > 0) {
        slots[[w]] <- rs_request(
          queue[[1]],
          user = user[1],
          time_out = time_out[1],
          path = path[1],
          transfer = FALSE,
          verbose = verbose
        )
        queue <- queue[-1]
        user <- user[-1]
        time_out <- time_out[-1]
        path <- path[-1]
      }

      # Try to download
      if (!isFALSE(slots[[w]])) {
        slots[[w]]$download()
      }

      # If the slot is not still pending,
      # add the request to the "done" list
      # and free-up the slot
      if (!isFALSE(slots[[w]]) && !slots[[w]]$is_pending()) {

        # remove the download slot from the queue
        slots[[w]]$delete()

        # add finished request to done list
        done <- append(done, slots[[w]])
        slots[[w]] <- FALSE
      }
    }
  }
}

repeat_if_one <- function(x, N) {
  if (is.null(x)) {
    return(x)
  }
  if (length(x) == 1) {
    x <- rep(x, N)
  }

  if (length(x) != N) {
    stop(deparse(substitute(x)), " must be a vector of length ", N, " or 1.")
  }
  x
}
