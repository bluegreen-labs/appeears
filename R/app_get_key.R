#' Store username and password
#'
#' Returns you token set by \code{\link[appeears]{app_set_key}}
#'
#' @param user user (email address) used to sign up
#' @return the password set using \code{\link[appeears]{app_set_key}} saved
#' in the keychain
#' @seealso \code{\link[ecmwfr]{app_set_key}}
#' @export
#' @author Koen Kufkens
#' @examples
#'
#' \dontrun{
#' # set key
#' app_set_key(user = "test@mail.com", password = "123")
#'
#' # get key
#' app_get_key(user = "test@mail.com")
#'}

app_get_key <- function(user) {

  # set static service
  service = "appeears"

  # unlock the keyring when required, mostly so
  # only the "env" option does not require this
  if (keyring::default_backend()$name != "env") {
    if (keyring::default_backend()$name == "file") {
      if ("ecmwfr" %in% keyring::keyring_list()$keyring) {
        if(keyring::keyring_is_locked(keyring = "appeears")){
          message("Your keyring is locked please
              unlock with your keyring password!")
          keyring::keyring_unlock(keyring = "appeears")
        }
      } else {
        stop("Can't find your credentials in the ecmwfr keyring file")
      }
    } else {
      if (keyring::keyring_is_locked()) {
        message("Your keyring is locked please
              unlock with your keyring password!")
        keyring::keyring_unlock()
      }
    }
  }

  # can't use ifelse as the keyring argument will
  # throw warnings which gives issues for unit tests
  if(keyring::default_backend()$name == "file"){
    keyring::key_get(
      service = make_key_service(service),
      username = user,
      keyring = "appeears")
  } else {
    keyring::key_get(
      service = make_key_service(service),
      username = user)
  }

}
