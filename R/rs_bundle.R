#' AppEEARS list of bundled files to download
#'
#' Returns a data frame of all data ready for download as one bundle
#'
#' @param user username used to sign up
#' @param task_id task id for which to return the file download bundle
#' @return returns a nested list of files to download
#'
#' @export
#' @author Koen Hufkens
#' @examples
#'
#' \dontrun{
#' # get a list of datasets
#' rs_bundle(
#' user = "your_user_name",
#' task_id = "a_task_id"
#' )
#'}

rs_bundle <- function(
    user,
    task_id
){

  # retrieve token to list tasks
  token <- rs_login(user)

  # get bundle
  response <- httr::GET(
      file.path(rs_server(),"bundle", task_id),
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

  # return content
  return(ct)
}