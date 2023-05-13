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
  task = "task",
  subtask = c("sub_task"),
  latitude = c(36.206228),
  longitude = c(-112.127134),
  start = c("2018-01-01"),
  end = c("2018-01-15"),
  product = c("MCD12Q2.006"),
  layer = c("Greenup")
)

# load the north carolina demo data
# included in the {sf} package
# and only retain Camden county
roi <- st_read(system.file("gpkg/nc.gpkg", package="sf"), quiet = TRUE) |>
  filter(
    NAME == "Camden"
  )

# Create a SpatRaster from a file
f <- system.file("ex/elev.tif", package="terra")
roi <- rast(f)

source("R/rs_build_task.R")

task <- rs_build_task(
  df = df,
  roi = roi,
  format = "geotiff"
)

print(task)

rs_request(
  request = task,
  user = "khufkens",
  transfer = TRUE,
  path = "~/tmp/test",
  verbose = TRUE
)

#source("R/rs_transfer.R")
#source("R/zzz.R")

#rs_transfer("309f2a64-7963-4cd2-b76a-09f4453cbb04","khufkens","~/tmp/test")
