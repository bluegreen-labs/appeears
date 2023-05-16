#----- set options -----
options(keyring_backend="file")
library(sf)
library(terra)
library(dplyr)

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
server_check <- appeears:::rs_running(file.path(rs_server(),"product"))

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
  end = "2010-01-15",
  product = "MCD12Q2.006",
  layer = "Greenup"
)

# load the north carolina demo data
# included in the {sf} package
# and only retain Camden county
roi_sf <- sf::st_read(system.file("gpkg/nc.gpkg", package="sf"), quiet = TRUE) |>
  filter(
    NAME == "Camden"
  )

#---- test functions ----

test_that("test functions without task ids", {
  skip_on_cran()
  skip_if(!server_check)

  # list products / layers / quality
  expect_true(inherits(rs_products(), "data.frame"))
  expect_true(inherits(rs_layers("MCD12Q2.006"), "data.frame"))
  expect_true(inherits(rs_quality(), "data.frame"))
  expect_true(inherits(rs_quality(product = "MCD12Q2.006"), "data.frame"))
  expect_true(inherits(rs_quality(
    product = "MCD12Q2.006",
    layer = "Greenup"), "list"))

  # create tasks
  expect_type(rs_build_task(df), "character")

  # create tasks failed (missing field)
  df_missing <- df |> select(-product)
  expect_error(rs_build_task(df_missing))

  # create polygon tasks
  expect_type(rs_build_task(df, roi_sf), "character")

  # create polygon task
  expect_type(rs_build_task(df, roi_sf, format = "netcdf4"), "character")

  # list tasks
  expect_type(rs_list_task(user = "khufkens"), "list")
})


test_that("test login-logout", {
  skip_on_cran()
  skip_if(login_check)
  expect_type(rs_logout(rs_login("khufkens")), "logical")
})


test_that("test request environment", {
  skip_on_cran()
  skip_if(login_check)

  # build task
  task <- rs_build_task(df)

  # request task
  request <- rs_request(
    request = task,
    user = "khufkens",
    transfer = FALSE,
    verbose = FALSE
  )

  # list environment/tasks
  expect_type(request, "environment")
  expect_type(rs_list_task(request$get_task_id(), "khufkens"), "list")

  # status info from request
  expect_type(request$is_pending(), "logical")
  expect_type(request$is_running(), "logical")
  expect_type(request$is_success(), "logical")
  expect_type(request$is_failed(), "logical")

  # update status
  expect_type(request$update_status(), "environment")

  # get request/status
  expect_type(request$get_status(), "character")
  expect_type(request$get_request(), "character")

  # delete task
  expect_message(request$delete())

})
