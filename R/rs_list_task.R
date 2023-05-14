#' AppEEARS list of tasks and status
#'
#' Returns a data frame of all submitted tasks either
#' in full of when providing the di
#'
#' @param user username used to sign up
#' @param task_id task for which to list the status (if missing
#'  all tasks are listed)
#' @return returns a data frame with the AppEEARS tasks
#'
#' @export
#' @author Koen Hufkens
#' @examples
#'
#' \dontrun{
#' # get a list of datasets
#' rs_list_task()
#'}

rs_list_task <- function(
  task_id,
  user
){

  # retrieve token to list tasks
  token <- rs_login(user)

  # grab the content on a product query
  # and convert to data frame which is returned
  if(missing(task_id)){
    ct <- httr::GET(
      file.path(rs_server(),"task"),
      httr::add_headers(
        Authorization = paste("Bearer", token),
        "Content-Type" = "application/json")
      )
  } else {
    ct <- httr::GET(
      file.path(rs_server(),"task", task_id),
      httr::add_headers(
        Authorization = paste("Bearer", token),
        "Content-Type" = "application/json")
      )
  }

  # split out the content from the returned
  # API data, and clean up the JSON formatting
  ct <- jsonlite::prettify(
    jsonlite::toJSON(httr::content(ct), auto_unbox = TRUE)
  )

  # convert the json data to a data frame
  df <- jsonlite::fromJSON(ct)

  # return content
  return(df)
}
