#' Delete AppEEARS task from queue
#'
#' Removes a task from the queue and or buffer
#'
#' @param user username used to sign up
#' @param task_id AppEEARS task id
#' @param purge if TRUE, remove all previously finished tasks from
#'  the task list (default = FALSE)
#' @return returns the content of the API call
#'
#' @export
#' @author Koen Hufkens
#' @examples
#'
#' \dontrun{
#' # delete a single task
#' apprs_delete(
#'   user = "your_user_name",
#'   task_id = "a_task_id"
#' )
#'
#' # delete all finished or crashed
#' # jobs (if not deleted previously)
#' apprs_delete(
#'   user = "your_user_name",
#'   purge = TRUE
#' )
#'}

apprs_delete <- function(
    user,
    task_id,
    purge = FALSE
){

  # check if task_id is present
  if (isFALSE(purge) && missing(task_id)) {
    stop("Missing task id to delete!")
  }

  # retrieve token to list tasks
  token <- apprs_login(user)

  # if purge is set to TRUE, list
  # all task_ids which are done or are crashed
  # keep running processes untouched
  if (purge) {
    task_list <- apprs_list_task(user = user)
    task_id <- task_list[task_list$status == "done" || task_list$crashed,]$task_id
  }

  lapply(task_id, function(id){
    response <- httr::DELETE(
      file.path(apprs_server(),"task", id),
      httr::add_headers(
        Authorization = paste("Bearer", token)
      )
    )

    # trap general http error
    if (httr::http_error(response)) {
      stop(
"Your task %s failed to delete.\n
 It was either previously delete or a wrong task id was provided.",
           call. = FALSE
      )
    }
  })

  # return empty
  return(invisible())
}

