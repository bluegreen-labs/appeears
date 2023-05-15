#----- set options -----
options(keyring_backend="file")
library(sf)
library(terra)

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
server_check <- appeears:::rs_running(appeears:::rs_server())

# if the server is reachable, try to set login
# if not set login check to TRUE as well
if(server_check & ON_GIT){
  user <- try(
    appeears::rs_set_key(
        user = "khufkens",
        password = Sys.getenv("PASS")
        )
      )

  # set login check to TRUE so skipped if
  # the user is not created
  login_check <- inherits(user, "try-error")
}

df <- data.frame(
  task = "time_series",
  subtask = "US-Ha1",
  latitude = 42.5378,
  longitude = -72.1715,
  start = "2010-01-01",
  end = "2010-12-31",
  product = "MCD12Q2.006",
  layer = "Greenup"
)

rs_request(
  request = task_time_series,
  user = "khufkens",
  transfer = TRUE,
  path = "inst/extdata/",
  verbose = TRUE
)

#---- test functions ----

test_that("test functions without logins", {
  skip_on_cran()
  skip_if(login_check)

  # list products / layers
  expect_true(inherits(rs_products(), "data.frame"))
  expect_true(inherits(rs_layers("MCD12Q2.006"), "data.frame"))

  # create tasks
  expect_type(rs_build_task(df), "character")





})


test_that("test data transfers", {
  skip_on_cran()
  skip_if(login_check)

  expect_true(inherits(rs_products(), "data.frame"))
  expect_true(inherits(rs_layers("MCD12Q2.006"), "data.frame"))
  expect_type(rs_build_task(df), "character")

})


