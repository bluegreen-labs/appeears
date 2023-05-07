# checks credentials
app_login <- function(
    user
) {

  # retrieve password from key-chain
  password <- app_get_key(user = user)

  # ct <- httr::POST(
  #   file.path(app_server(),"login"),
  #   httr::authenticate(user, password, type = "basic"),
  #   body = "grant_type=client_credentials",
  #   httr::config(verbose = FALSE)
  # )

  secret <- base64_enc(paste(user, password, sep = ":"))

  ct <- httr::POST(
    file.path(app_server(),"login"),
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

# checks credentials
app_logout <- function(
    token
) {

  ct <- httr::POST(
    file.path(app_server(),"logout"),
    httr::add_headers(
      Authorization = token,
      "Content-Type" = "application/x-www-form-urlencoded;charset=UTF-8"),
    body = "grant_type=client_credentials"
  )

  if(httr::status_code(ct) < 400) {
    message("logged out of session ...")
  } else {
    stop("Failed to login")
  }
}

