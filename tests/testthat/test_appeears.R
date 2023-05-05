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
server_check <- appeears:::ecmwf_running(appeears:::app_server(service = "cds"))

# if the server is reachable, try to set login
# if not set login check to TRUE as well
if(server_check & ON_GIT){
  user <- try(
    appeears::app_set_key(
        user = "2088",
        key = Sys.getenv("CDS"),
        service = "cds")
      )

  # set login check to TRUE so skipped if
  # the user is not created
  login_check <- inherits(user, "try-error")
}

#----- formal checks ----

test_that("set key", {
  skip_on_cran()
  skip_if(login_check)
    expect_message(app_set_key(user = "2088",
                              Sys.getenv("CDS"),
                              service = "cds"))
})

