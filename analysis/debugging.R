# Example workflows / scratchpad
library(jsonlite)
library(httr)

user <- "khufkens"
options(keyring_backend = "file")

source("R/app_get_key.R")
source("R/app_set_key.R")
source("R/zzz.R")
source("R/app_products.R")
source("R/app_layers.R")
source("R/app_list_task.R")
source("R/app_login.R")
source("R/app_build_task.R")

token <- app_login(user)

df <- data.frame(
  task = c("grand canyon", "grand canyon"),
  subtask = c("test1", "test2"),
  lat = c(36.206228, 37.289327),
  lon = c(-112.127134, -112.973760),
  start = c("2018-01-01","2018-01-01"),
  end = c("2018-12-31","2018-12-31"),
  product = c("MOD11A2.061","MOD11A2.061"),
  layer = c("LST_Day_1km","LST_Night_1km")
)

task <- app_build_task(df = df)

response <- httr::POST(
  "https://appeears.earthdatacloud.nasa.gov/api/task",
  body = task,
  encode = "json",
  httr::add_headers(
    Authorization = paste("Bearer", token),
    "Content-Type" = "application/json")
  )

task_response <- prettify(toJSON(httr::content(response), auto_unbox = TRUE))
print(task_response)

ct <- httr::GET(
  file.path(app_server(),"task"),
  httr::add_headers(Authorization = paste("Bearer", token))
)

task_response <- prettify(toJSON(httr::content(ct), auto_unbox = TRUE))
print(jsonlite::fromJSON(task_response))
