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

token <- app_login(user)
app_logout(token)

# # create the task request
# task <- '{
#           "task_type": "point",
#           "task_name": "my-task",
#           "params":{
#             "dates": [
#             {
#               "startDate": "01-01-2010",
#               "endDate": "01-31-2010"
#             }],
#             "layers": [
#             {
#               "product": "MOD11A1.061",
#               "layer": "LST_Day_1km"
#             }],
#             "coordinates": [
#             {
#               "latitude": 42,
#               "longitude": -72
#             }]
#       }
# }'
#
#
# task <- fromJSON(task)
# task <- toJSON(task, auto_unbox=TRUE)
#
# response <- httr::POST(
#   "https://appeears.earthdatacloud.nasa.gov/api/task",
#   body = task,
#   encode = "json",
#   httr::add_headers(
#     Authorization = token,
#     "Content-Type" = "application/json")
#   )
#
# task_response <- prettify(toJSON(httr::content(response), auto_unbox = TRUE))
# task_response
#
# ct <- httr::GET(
#   file.path(app_server(),"task"),
#   httr::add_headers(Authorization = token)
# )
#
# print(ct)
