#' Checks AppEEARS login
#'
#' Returns a valid token for a session if
#' successful otherwise fails with an error (stop())
#'
#' @param user AppEEARS username
#'
#' @return returns an AppEEARS session (bearer) token
#' @export

rs_login <- function(
    user
) {

  # retrieve password from key-chain
  password <- rs_get_key(user = user)
  secret <- jsonlite::base64_enc(paste(user, password, sep = ":"))

  ct <- httr::POST(
    file.path(rs_server(),"login"),
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
#' @param token a Bearer token as returned by rs_login()
#'
#' @return returns if the session has closed TRUE/FALSE
#' @export

rs_logout <- function(
    token
) {

  ct <- httr::POST(
    file.path(rs_server(),"logout"),
    httr::add_headers(
      Authorization = paste("Bearer", token),
      "Content-Type" = "application/x-www-form-urlencoded;charset=UTF-8"),
    body = "grant_type=client_credentials"
  )

  if(httr::status_code(ct) < 400) {
    message("logged out of session ...")
  } else {
    warning("Failed to login")
    return(FALSE)
  }

  # return NULL if successful
  return(TRUE)
}

