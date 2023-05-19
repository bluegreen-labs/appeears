# Download demo data for inst/extdata
library(appeears)

user <- "khufkens"
options(keyring_backend = "file")

#---- download point data ----

source("R/rs_build_task.R")

df <- data.frame(
  task = "time_series",
  subtask = c("US-Ha1","US-Ha1","US-Test","US-Test"),
  latitude = c(42.5378,42.5378, 41,41),
  longitude = c(-72.1715,-72.1715, -80,-80),
  start = "2010-01-01",
  end = "2010-01-15",
  product = "MCD12Q2.006",
  layer = c(
    "Greenup",
    "Dormancy",
    "Greenup",
    "Dormancy"
    )
)

task_new <- df |> rs_build_task()

rs_list_task(user = "khufkens")

request_new <- rs_request(
  request = task_new,
  user = "khufkens",
  transfer = TRUE,
  path = "~/tmp/test/",
  verbose = TRUE,
  time_out = 2
)
