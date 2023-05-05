#' Set AppEEARS password
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
#' @param user user (email address) used to sign up for the AppEEARS data service
#' @param password used to sign up for AppEEARS
#'
#' @return It invisibly returns the user.
#' @seealso \code{\link[ecmwfr]{app_get_key}}
#' @export
#' @author Koen Hufkens
#' @examples
#'
#' \dontrun{
#' # set key
#' app_set_key(user = "test@mail.com", password = "123")
#'
#' # get key
#' app_get_key(user = "test@mail.com")
#'
#' # leave user and key empty to open a browser window to the service's website
#' # and type the key interactively
#' app_get_key()
#'
#'}
#' @importFrom utils browseURL
app_set_key <- function(user, password) {

  # set static service
  service = "appeears"

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

  if (missing(user) | missing(key)) {
    if (!interactive()) {
      stop("wf_set_key needs to be run interactivelly if `user` or `password` are
           not provided.")
    }
    browseURL(wf_key_page(service))
    message("Login or register to get a key")
    user <- readline("User ID / email: ")
    key <- getPass::getPass(msg = "Password: ")
    if (is.null(key))
      stop("No password supplied.")
  }

  # check login
  login_ok <- wf_check_login(user = user,
                             key = key,
                             service = service)

  if (!login_ok) {
    stop("Could not validate login information.")
  } else {

    # if ecmwfr keyring is not created do so
    if(keyring::default_backend()$name == "file"){
      if(!("ecmwfr" %in% keyring::keyring_list()$keyring)){
        keyring::keyring_create("ecmwfr")
      }

      # set keyring
      keyring::key_set_with_value(
        service = make_key_service(service),
        username = user,
        password = key,
        keyring = "ecmwfr"
      )

      message("User ", user, " for ", service,
              " service added successfully in keychain file")

    } else {
      keyring::key_set_with_value(
        service = make_key_service(service),
        username = user,
        password = key
      )

      message("User ", user, " for ", service,
              " service added successfully in keychain")
    }

    return(invisible(user))
  }

}
