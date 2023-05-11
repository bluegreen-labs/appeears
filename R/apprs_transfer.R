#' AppEEARS data transfer function
#'
#' Returns the contents of the requested url as a NetCDF file downloaded
#' to disk or the current status of the requested transfer.
#'
#' @param user user (email address) used to sign up for the ECMWF data service,
#' used to retrieve the token set by \code{\link[apprs]{apprs_set_key}}.
#' @param task R6 \code{\link[apprs]{apprs_request}}) query output or task id
#' @param path path were to store the downloaded data
#' @param verbose show feedback on data transfers
#' @return data on disk as specified by a
#' \code{\link[apprs]{apprs_request}}
#' @seealso \code{\link[apprs]{apprs_set_key}}
#' \code{\link[apprs]{apprs_request}}
#' @export
#' @author Koen Hufkens
#' @examples
#'
#' \dontrun{
#' # set key
#' apprs_set_key(user = "test", password = "123")
#'
#' # request data and grab url and try a transfer
#' r <- apprs_request(request, "test", transfer = FALSE)
#'
#' # check transfer, will download if available
#' apprs_transfer(r$get_task_id(), user = "test")
#'}

apprs_transfer <- function(
    task,
    user,
    path = tempdir(),
    verbose = TRUE
    ) {

  if (inherits(task, "apprs_service")) {
    task$transfer()
    return(task)
  }

  # check the login credentials
  if (missing(user) || missing(task)) {
    stop("Please provide AppEEARS login or task to download!")
  }

  # get token
  token <- apprs_login(user)

  # get bundle
  response <- httr::GET(
    file.path(apprs_server(),"bundle", task),
    httr::add_headers(
      Authorization = paste("Bearer", token)
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

  # verbose feedback on download
  if (verbose) {
    message(sprintf("Processing bundle: %s", task))
  }

  # try downloading whole bundle, log downloaded
  # state
  downloaded <- lapply(ct$files, function(file){

    # set temp file name
    temp_file <- file.path(tempdir(), file$file_name)

    # set final file name
    final_file <- file.path(path, file$file_name)

    # write the file to disk using the destination directory and file name
    response <- GET(
      file.path(apprs_server(), "bundle/", task, file$file_id),
      write_disk(temp_file, overwrite = TRUE),
      httr::add_headers(
        Authorization = paste("Bearer", token)
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

        if (verbose) {
          message(sprintf("- moved temporary files to -> %s", final_file))
        }
      } else {
        if (verbose) {
          message(sprintf("- downloaded file to -> %s", temp_file))
        }
      }

      return(TRUE)
    }
  })

  # trap (http) errors on download, return a general error statement
  if (all(unlist(downloaded))) {
    if (fail_is_error) {
      stop("Some downloads failed - consider redownloading")
    } else {
      warning("Some downloads failed - consider redownloading")
      return(self)
    }
  }

  # return state variable
  return(invisible(ct))
}
