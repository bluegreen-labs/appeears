# set options
options(keyring_backend="file")

# spoof keyring
if(!("appeears" %in% keyring::keyring_list()$keyring)){
  keyring::keyring_create("appeears", password = "test")
}

login_check <- FALSE

# check if on github
ON_GIT <- ifelse(
  length(Sys.getenv("GITHUB_TOKEN")) <= 1,
  TRUE,
  FALSE
)

# is the server reachable
server_check <- apprs:::apprs_running(apprs:::apprs_server())

# if the server is reachable, try to set login
# if not set login check to TRUE as well
if(server_check & ON_GIT){
  user <- try(
    apprs::apprs_set_key(
        user = "khufkens",
        password = Sys.getenv("PASS")
        )
      )

  # set login check to TRUE so skipped if
  # the user is not created
  login_check <- inherits(user, "try-error")
}
