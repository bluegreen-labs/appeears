#' Checks AppEEARS login
#'
#' Returns a valid token for a session if
#' successful otherwise fails with an error (stop())
#'
#' @param user AppEEARS username
#'
#' @return
#' @export

apprs_login <- function(
    user
) {

  # retrieve password from key-chain
  password <- apprs_get_key(user = user)
  secret <- jsonlite::base64_enc(paste(user, password, sep = ":"))

  ct <- httr::POST(
    file.path(apprs_server(),"login"),
    httr::add_headers(
      "Authorization" = paste("Basic", gsub("\n", "", secret)),
      "Content-Type" = "application/x-www-form-urlencoded;charset=UTF-8"),
    body = "grant_type=client_credentials"
    )

  if(httr::status_code(ct) < 400) {
    token <- jsonlite::prettify(
      jsonlite::toJSON(
        httr::content(ct),
        auto_unbox = TRUE)
    )

    # grab only the token
    token <- jsonlite::fromJSON(token)$token

    return(token)
  } else {
    stop("Failed to login")
  }
}

#' Invalidates an AppEEARS bearer token
#'
#' Given a token it will log out / delete this
#' token, invalidating it.
#'
#' @param token a Bearer token as returned by apprs_login()
#'
#' @return
#' @export

apprs_logout <- function(
    token
) {

  ct <- httr::POST(
    file.path(apprs_server(),"logout"),
    httr::add_headers(
      Authorization = paste("Bearer", token),
      "Content-Type" = "application/x-www-form-urlencoded;charset=UTF-8"),
    body = "grant_type=client_credentials"
  )

  if(httr::status_code(ct) < 400) {
    message("logged out of session ...")
  } else {
    stop("Failed to login")
  }
}

