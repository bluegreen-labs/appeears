# Download demo data for inst/extdata
library(appeears)

user <- "khufkens"
options(keyring_backend = "file")

df <- data.frame(
  task = "time_series",
  subtask = "US-Ha1",
  latitude = 42.5378,
  longitude = -72.1715,
  start = "2010-01-01",
  end = "2010-12-31",
  product = "MCD43A4.061",
  layer = c("Nadir_Reflectance_Band3","Nadir_Reflectance_Band4")
)

task <- rs_build_task(
  df = df
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
