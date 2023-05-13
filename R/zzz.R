# Returns server URL
#
# Returns the url of the data servers for downloading
# public AppEEARS.
#
# @author Koen Kufkens
rs_server <- function() {
  # set base urls
  appeears_url <- "https://appeears.earthdatacloud.nasa.gov/api"
  return(appeears_url)
}

# Simple progress spinner
#
# Shows a spinner while waiting for a request to be processed.
#
# @param seconds integer, seconds to sleep
#
# @details Shows a spinner while waiting for a request to be processed.
# If \code{id} (character) is set, the request id will be shown in addition.
#
# @author Koen Kufkens
spinner <- function(seconds) {
  # set start time, counter
  start_time <- Sys.time()
  spinner_count <- 1

  while (Sys.time() <= start_time + seconds) {
    # slow down while loop
    Sys.sleep(0.2)

    # update spinner message
    message(paste0(c("-", "\\", "|", "/")[spinner_count],
                   " polling server for a data transfer\r"),
            appendLF = FALSE)

    # update spinner count
    spinner_count <- ifelse(spinner_count < 4, spinner_count + 1, 1)
  }
}

# Show message if user exits the function (interrupts execution)
# or as soon as an error will be thrown.
exit_message <- function(url, path, file) {
  job_list <-  "check the task status (rs_list_task()) or other functions,"

  intro <- paste(
    "Even after exiting your request is still beeing processed!",
    job_list,
    "  to manage (download, retry, delete) your requests",
    "  or to get ID's from other requests.\n\n",
    sep = "\n"
  )

  options <- paste(
    "- Retry downloading as soon as as completed:\n",
    "  rs_transfer(url = '",
    url,
    "\n",
    "<user>,\n ",
    "',\n path = '",
    path,
    "',\n filename = '",
    file,
    "')\n\n",
    "- Delete the job upon completion using:\n",
    "  rs_delete(<user>,\n url ='",
    url,
    "')\n\n",
    sep = ""
  )

  # combine all messages
  exit_msg <- paste(intro, options, sep = "")
  message(sprintf(
    "- Your request has been submitted as a %s request.\n\n  %s",
    exit_msg
  ))
}

# Startup message when attaching the package.
.onAttach <-
  function(
    libname = find.package("appeears"),
    pkgname = "appeears"
    ) {

    # startup messages
    vers <- as.character(utils::packageVersion("appeears"))
    txt <- paste(
      "\n     This is 'apprs' version ",
      vers,
      ". Please respect the terms of use:\n",
      "     - https://appeears.earthdatacloud.nasa.gov/\n"
    )
    if (interactive())
      packageStartupMessage(txt)

    # force http/2 for all products
    httr::set_config(httr::config(http_version = 2))
  }

# check if server is reachable
# returns Boolean TRUE if so
rs_running <- function(url) {
  ct <- try(httr::GET(url))

  # trap time-out, httr should exit clean but doesn't
  # it seems
  if (inherits(ct, "try-error")) {
    return(FALSE)
  }

  # trap 400 errors
  if (ct$status_code >= 404) {
    return(FALSE)
  } else {
    return(TRUE)
  }
}

# checks credentials
rs_check_login <- function(
    user,
    password,
    token = FALSE
    ) {

  # retrieve password from key-chain
  if(missing(password)) {
    password <- rs_get_key(user = user)
  }

  ct <- httr::POST(
    file.path(rs_server(),"login"),
    httr::authenticate(user, password, type = "basic"),
    body = "grant_type=client_credentials",
    httr::config(verbose = FALSE)
  )

  if(token) {
    token <- jsonlite::prettify(
      jsonlite::toJSON(
        httr::content(ct),
        auto_unbox = TRUE)
      )

    # grab only the token
    token <- jsonlite::fromJSON(token)$token

    return(token)
  } else {
    return(httr::status_code(ct) < 400)
  }
}

# Downloads only the header information
retrieve_header <- function(url, headers) {
  h <- curl::new_handle()
  curl::handle_setheaders(h, .list = headers)
  con <- curl::curl(url, handle = h)

  open(con, "rf")
  head <- curl::handle_data(h)
  close(con)

  head$headers <- curl::parse_headers_list(head$headers)
  return(head)
}

# Encapsulates errors are warnings logic.
warn_or_error <- function(..., error = FALSE) {
  if (error) {
    stop(...)
  } else {
    warning(...)
  }
}

# Creates a script to then run as a job
make_script <- function(call, name) {
  script <- tempfile()

  call$job_name <- NULL

  lines <-
    writeLines(paste0(
      "library(apprs)\n",
      name,
      " <- ",
      paste0(deparse(call), collapse = "")
    ), script)
  return(script)
}