#' AppEEARS data transfer function
#'
#' Returns the contents of the requested url as a NetCDF file downloaded
#' to disk or the current status of the requested transfer.
#'
#' @param user user (email address) used to sign up for the AppEEARS data service,
#' used to retrieve the token set by \code{\link[appeears]{rs_set_key}}.
#' @param task_id R6 \code{\link[appeears]{rs_request}}) query output or task id
#' @param path path were to store the downloaded data
#' @param verbose show feedback on data transfers
#' @return data on disk as specified by a
#' \code{\link[appeears]{rs_request}}
#' @seealso \code{\link[appeears]{rs_set_key}}
#' \code{\link[appeears]{rs_request}}
#' @export
#' @author Koen Hufkens
#' @examples
#'
#' \dontrun{
#' # set key
#' rs_set_key(user = "test", password = "123")
#'
#' # request data and grab url and try a transfer
#' r <- rs_request(request, "test", transfer = FALSE)
#'
#' # check transfer, will download if available
#' rs_transfer(r$get_task_id(), user = "test")
#'}

rs_transfer <- function(
    task_id,
    user,
    path = tempdir(),
    verbose = TRUE
    ) {

  if (inherits(task_id, "appeears_service")) {
    task_id$transfer()
    return(task_id)
  }

  # check the login credentials
  if (missing(user) | missing(task_id)) {
    stop("Please provide AppEEARS login or task to download!")
  }

  # get token
  token <- rs_login(user)

  # get bundle
  ct <- rs_bundle(task_id, user)

  # verbose feedback on download
  if (verbose) {
    message(sprintf("Processing bundle: %s", task_id))
  }

  # try downloading whole bundle, log downloaded
  # state
  downloaded <- lapply(ct$files, function(file) {

    # set temp file name
    temp_file <- file.path(tempdir(), basename(file$file_name))

    # set final file name
    final_file <- file.path(path, basename(file$file_name))

    # write the file to disk using the destination directory and file name
    response <- httr::GET(
      file.path(rs_server(), "bundle/", task_id, file$file_id),
      httr::write_disk(temp_file, overwrite = TRUE),
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

      if (temp_file != final_file) {
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
  if (!all(unlist(downloaded))) {
      warning("Some downloads failed - consider redownloading")
  }

  # return state variable
  return(invisible(ct))
}
