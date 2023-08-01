#' Retrieve NASA Earth Data password
#'
#' Returns you token set by \code{\link[appeears]{rs_set_key}}
#'
#' @param user username used to sign up
#' @return the password set using \code{\link[appeears]{rs_set_key}} saved
#' in the keychain
#' @seealso \code{\link[appeears]{rs_set_key}}
#' @export
#' @author Koen Hufkens
#' @examples
#'
#' \dontrun{
#' # set key
#' rs_set_key(user = "test@mail.com", password = "123")
#'
#' # get key
#' rs_get_key(user = "test@mail.com")
#'}

rs_get_key <- function(user) {

  # trap missing user
  if (missing(user)) {
    stop("No user provided, can't retrieve user password from keyring.")
  }

  # set static service
  service = "appeears"

  # unlock the keyring when required, mostly so
  # only the "env" option does not require this
  if (keyring::default_backend()$name != "env") {
    if (keyring::default_backend()$name == "file") {
      if ("appeears" %in% keyring::keyring_list()$keyring) {
        if(keyring::keyring_is_locked(keyring = "appeears")){
          message("
  Your keyring is locked please
  unlock with your keyring password!
  ")
          keyring::keyring_unlock(keyring = "appeears")
        }
      } else {
        stop("Can't find your credentials in the appeears keyring file")
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
      service = service,
      username = user,
      keyring = "appeears"
      )
  } else {
    keyring::key_get(
      service = service,
      username = user,
      keyring = "appeears"
      )
  }

}
