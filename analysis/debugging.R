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
roi <- sf::st_read(system.file("gpkg/nc.gpkg", package="sf"), quiet = TRUE) |>
  filter(
    NAME == "Camden"
  )

df$task <- "polygon"
task_roi_1 <- rs_build_task(
  df = df,
  roi = roi,
  format = "geotiff"
)

# Create a SpatRaster from a file
# f <- system.file("ex/elev.tif", package="terra")
roi <- rast(f)
df$task <- "raster"

task_roi_2 <- rs_build_task(
  df = df,
  roi = roi,
  format = "geotiff"
)

df$task <- "point"
task <- rs_build_task(
  df = df
)

rs_request(
  request = task_roi_1,
  user = "khufkens",
  transfer = TRUE,
  path = "inst/extdata/",
  verbose = TRUE
)

rs_request(
  request = task_roi_2,
  user = "khufkens",
  transfer = TRUE,
  path = "inst/extdata/",
  verbose = TRUE
)

rs_request(
  request = task,
  user = "khufkens",
  transfer = TRUE,
  path = "inst/extdata/",
  verbose = TRUE
)
