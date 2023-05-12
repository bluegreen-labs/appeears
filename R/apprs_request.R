#' AppEEARS data request and download
#'
#' Stage a data request, and optionally download the data to disk. Alternatively
#' you can only stage requests, logging the request URLs to submit download
#' queries later on using \code{\link[apprs]{apprs_transfer}}.
#'
#' @param user user (email address or ID) provided by the ECMWF data service,
#' used to retrieve the token set by \code{\link[apprs]{apprs_set_key}}
#' @param path path were to store the downloaded data
#' @param time_out how long to wait on a download to start (default =
#' \code{3*3600} seconds).
#' @param transfer logical, download data TRUE or FALSE (default = TRUE)
#' @param request nested list with query parameters following the layout
#' as specified on the ECMWF APIs page
#' @param job_name optional name to use as an RStudio job and as output variable
#'  name. It has to be a syntactically valid name.
#' @param verbose show feedback on processing
#' @import R6
#'
#' @return the path of the downloaded (requested file) or the an R6 object
#' with download/transfer information
#' @seealso \code{\link[apprs]{apprs_set_key}}
#' \code{\link[apprs]{apprs_transfer}}
#' @export
#' @author Koen Hufkens
#' @examples
#'
#' \dontrun{
#' # specifiy a task/request as a
#' # data frame
#' df <- data.frame(
#'  task = "grand canyon",
#'  subtask = c("test1", "test2"),
#'  latitude = c(36.206228, 36.206228),
#'  longitude = c(-112.127134, -112.127134),
#'  start = c("2018-01-01","2018-01-01"),
#'  end = c("2018-01-15","2018-01-15"),
#'  product = c("MOD11A2.061","MCD12Q2.006"),
#'  layer = c("LST_Day_1km","Dormancy")
#')
#'
#' # build a proper JSON query
#' task <- apprs_build_task(df = df)
#'
#' # request the task to be executed
#' apprs_request(
#'  request = task,
#'  user = "earth_data_user",
#'  transfer = TRUE,
#'  path = "~/some_path",
#'  verbose = TRUE
#')
#'}

apprs_request <- function(
    request,
    user,
    transfer = TRUE,
    path = tempdir(),
    time_out = 3600,
    job_name,
    verbose = TRUE
) {

  if (!missing(job_name)) {
    if (make.names(job_name) != job_name) {
      stop("job_name '",
           job_name,
           "' is not a syntactically valid variable name.")
    }

    # Evaluates all arguments.
    call <- match.call()
    call$path <- path
    call_list <- lapply(call, eval)
    call[names(call_list)[-1]] <- call_list[-1]

    script <- make_script(call = call, name = job_name)
    if (!requireNamespace("rstudioapi", quietly = TRUE)) {
      stop("Jobs are only supported in RStudio.")
    }

    if (!rstudioapi::isAvailable("1.2")) {
      stop(
        "Need at least version 1.2 of RStudio to use jobs. Currently running ",
        rstudioapi::versionInfo()$version,
        "."
      )
    }

    job <- rstudioapi::jobRunScript(
      path = script,
      name = job_name,
      exportEnv = "R_GlobalEnv"
      )

    return(invisible(job))
  }

  # check the login credentials
  if (missing(request)) {
    stop("Please provide an AppEEARS task/request!")
  }

  # check for user
  if (missing(user)){
    stop("Missing user credentials, please provide a valid username!")
  }

  # Create request and submit to service
  request <- apprs_service$new(
    request = request,
    user = user,
    path = path
    )

  # Submit the request
  request$submit()

  # Only wait for request to finish if transfer == TRUE
  if (transfer) {
    request$transfer(time_out = time_out)
    if (request$is_success()) {

      # download the data to a set file location
      file_location <- request$get_file()

      # delete from queue
      request$delete()

      # return file location
      return(file_location)
    }
    message("Transfer was not successfull - please check your request later at:")
    message(request$get_url())
  }

  return(request)
}
