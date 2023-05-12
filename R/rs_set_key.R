#' Set NASA Earth Data password
#'
#' Saves the token to your local keychain under
#' a service called "appeears".
#'
#' In systems without keychain management set the option
#' keyring_backend to `file` (i.e. options(keyring_backend = "file"))
#' in order to write the keychain entry to an encrypted file.
#' This mostly pertains to headless Linux systems. The keychain files
#' can be found in ~/.config/r-keyring.
#'
#' @param user user used to sign up for the AppEEARS data service (this is
#'  not the email address, but the true user name!)
#' @param password used to sign up for AppEEARS
#'
#' @return It invisibly returns the user.
#' @seealso \code{\link[appeears]{rs_get_key}}
#' @export
#' @author Koen Hufkens
#' @examples
#'
#' \dontrun{
#' # set key
#' rs_set_key(user = "test", password = "123")
#'
#' # get key
#' rs_get_key(user = "test")
#'
#' # leave user and key empty to open a browser window to the service's website
#' # and type the key interactively
#' rs_get_key()
#'
#'}
#' @importFrom utils browseURL
rs_set_key <- function(user, password) {

  # set static service
  service <- "appeears"

  if (keyring::default_backend()$name != "env") {
    if (keyring::default_backend()$name == "file") {
      if ("ecmwfr" %in% keyring::keyring_list()$keyring) {
        if(keyring::keyring_is_locked(keyring = "appeears")){
          message("Your keyring is locked please
              unlock with your keyring password!")
          keyring::keyring_unlock(keyring = "appeears")
        }
      }
    } else {
      if (keyring::keyring_is_locked()) {
        message("Your keyring is locked please
              unlock with your keyring password!")
        keyring::keyring_unlock()
      }
    }
  }

  if (missing(user) | missing(password)) {
    if (!interactive()) {
      stop("wf_set_key needs to be run interactivelly if `user` or `password` are
           not provided.")
    }
    browseURL("https://appeears.earthdatacloud.nasa.gov/")
    message("Register to get a password")
    user <- readline("User ID / email: ")
    password <- getPass::getPass(msg = "Password: ")
    if (is.null(password))
      stop("No password supplied.")
  }

  # check login
  login_ok <- rs_check_login(
    user = user,
    password = password
  )

  if (!login_ok) {
    stop("Could not validate login information.")
  } else {

    # if appeears keyring is not created do so
    if(keyring::default_backend()$name == "file"){
      if(!("appeears" %in% keyring::keyring_list()$keyring)){
        keyring::keyring_create("appeears")
      }

      # set keyring
      keyring::key_set_with_value(
        service = service,
        username = user,
        password = password,
        keyring = "appeears"
      )

      message(
        "User ",
        user,
        " added successfully to keychain file"
      )

    } else {
      keyring::key_set_with_value(
        service = service,
        username = user,
        password = password,
        keyring = "appeears"
      )

      message(
        "User ",
        user,
        " added successfully to keychain file"
      )
    }

    return(invisible(user))
  }
}
