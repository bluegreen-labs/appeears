# Example workflows / scratchpad
library(appeears)
library(sf)
library(dplyr)
library(geojsonio)
library(geojson)
library(terra)

user <- "khufkens"
options(keyring_backend = "file")

df <- data.frame(
  task = "grand canyon",
  subtask = c("test2"),
  latitude = c(36.206228),
  longitude = c(-112.127134),
  start = c("2018-01-01"),
  end = c("2018-01-15"),
  product = c("MCD12Q2.006"),
  layer = c("Dormancy")
)

# load the north carolina demo data
# included in the {sf} package
# and only retain Camden county
roi <- st_read(system.file("gpkg/nc.gpkg", package="sf"), quiet = TRUE) |>
  filter(
    NAME == "Camden"
  )

source("R/rs_build_task.R")

task <- rs_build_task(
  df = df,
  roi = roi
)

print(task)

rs_request(
  request = task,
  user = "khufkens",
  transfer = TRUE,
  path = "~/tmp/test",
  verbose = TRUE
)

source("R/rs_transfer.R")
source("R/zzz.R")

rs_transfer("ae81f094-7328-40b7-b6df-636dcc1d58ef","khufkens","~/tmp/test")
