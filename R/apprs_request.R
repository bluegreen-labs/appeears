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
#' @import uuid
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
#' # set key
#' apprs_set_key(user = "test@mail.com", key = "123")
#'
#' request <- list(stream = "oper",
#'    levtype = "sfc",
#'    param = "167.128",
#'    dataset = "interim",
#'    step = "0",
#'    grid = "0.75/0.75",
#'    time = "00",
#'    date = "2014-07-01/to/2014-07-02",
#'    type = "an",
#'    class = "ei",
#'    area = "50/10/51/11",
#'    format = "netcdf",
#'    target = "tmp.nc")
#'
#' # demo query
#' apprs_request(request = request, user = "test@mail.com")
#'
#' # Run as an RStudio Job. When finished, will create a
#' # variable named "test" in your environment with the path to
#' # the downloaded file.
#' apprs_request(request = request, user = "test@mail.com", job_name = "test")
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

  if (!is.list(request) | is.character(request)) {
    stop(
      "`request` must be a named list. \n",
      "If you are passing the user as first argument, notice that argument ",
      "order was changed in version 1.1.1."
    )
  }

  # check the login credentials
  if (missing(request)) {
    stop("Please provide ECMWF or CDS login credentials and data request!")
  }

  # check for user
  if (missing(user)){
    stop("Missing user credentials, please provide a valid user/ID!")
  }

  # split out data
  service <- "appeears"
  url <- app_server()

  # Create request and submit to service
  request <- service$new(
    request = request,
    user = user,
    url = url,
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
