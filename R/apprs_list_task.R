#' AppEEARS list of tasks and status
#'
#' Returns a data frame of all submitted tasks either
#' in full of when providing the di
#'
#' @param user username used to sign up
#' @return returns a data frame with the AppEEARS tasks
#'
#' @export
#' @author Koen Hufkens
#' @examples
#'
#' \dontrun{
#' # get a list of datasets
#' apprs_list_task()
#'}

apprs_list_task <- function(
    user,
    task_id
){

  # retrieve password from key-chain
  password <- apprs_get_key(user = user)

  # grab the content on a product query
  # and convert to data frame which is returned
  if(missing(task_id)){
    print("check")
    ct <- httr::GET(
      file.path(apprs_server(),"task"),
      httr::authenticate(user, password, type = "basic"),
      )
  } else {
    ct <- httr::GET(
      file.path(apprs_server(),"task", task_id),
      httr::authenticate(user, password, type = "basic"),
      )
  }

  ct <- jsonlite::prettify(
    jsonlite::toJSON(content(ct), auto_unbox = TRUE)
  )
  ct <- jsonlite::fromJSON(ct)

  # convert to data frame
  df <- as.data.frame(
    do.call("rbind",ct)
  )

  # return content
  return(df)
}
