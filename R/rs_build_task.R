#' Build a task request
#'
#' Builds a valid JSON formatted API request from either
#' a tidy data frame with point based sub-tasks, or when
#' a region of interest (roi) is specified coordinates
#' (latitude/longitude) will be ignored and a bounding
#' box for an sf or SpatRaster object will be used instead.
#'
#' @param df a data frame with task name (task), subtask name (subtask),
#' latitude, longitude, start (start) and end (end) date.
#' @param roi a region of interest defined by a SpatRaster or sf object,
#' the roi will override any point based data provided as latittude-longitude
#' coordinates in the data frame
#' @param format file format of the downloaded data either geotiff (the default)
#' or netcdf4
#'
#' @return a valid AppEEARS JSON formatted task
#' @export
#' @examples
#'
#' # define a task as a tidy data frame
#' # multiple subtasks can be provided
#' df <- data.frame(
#' task = "task_name",
#' subtask = c("sub_task"),
#' latitude = c(36.206228),
#' longitude = c(-112.127134),
#' start = c("2018-01-01"),
#' end = c("2018-01-15"),
#' product = c("MCD12Q2.006"),
#' layer = c("Greenup")
#' )
#'
#' # build a task
#' rs_build_task(df)

rs_build_task <- function(
    df,
    roi,
    format = "geotiff"
) {

  # required fields
  required_fields <- c(
    "task",
    "subtask",
    "latitude",
    "longitude",
    "start",
    "end",
    "product",
    "layer"
  )

  # missing roi -> point extraction
  if (missing(roi)) {
    type <- "point"

    if (!all(required_fields %in% names(df))) {

      missing_fields <- paste(
        required_fields[!(required_fields %in% names(df))],
        collapse = ", "
      )

      stop(
        sprintf("Your task list misses required fields: %s",
                missing_fields)
      )
    }

  } else {
    type <- "area"
    required_fields <- required_fields[-c(3,4)]

    if (!all(required_fields %in% names(df))) {

      missing_fields <- paste(
        required_fields[!(required_fields %in% names(df))],
        collapse = ", "
      )

      stop(
        sprintf("Your task list misses required fields: %s",
                missing_fields)
      )
    }
  }

  if (!(("start" %in% names(df)) && ("end" %in% names(df)))) {
    stop("missing date range")
  }

  # extract the maximum date range from all listed
  # subtasks
  start <- min(as.Date(df$start))
  end <- max(as.Date(df$end))

  # set date ranges
  date <- data.frame(
    startDate = format(as.Date(start), "%m-%d-%Y"),
    endDate = format(as.Date(end), "%m-%d-%Y")
  )

  # get unique product layer combinations
  # to limit unnecessary downloads
  df_layer <- unique(df[,c("product","layer")])

  # layer product combinations
  layers <- data.frame(
    product = df_layer$product,
    layer = df_layer$layer
  )

  if (!missing(roi)) {
    if (inherits(roi, "sf", which = FALSE)) {
      # convert simple feature to geojson
      # and then to list
      geojson_task <- sf::st_union(roi)
      geojson_task <- sf::st_as_sf(geojson_task)
      geojson_task <- sf::st_transform(geojson_task, crs = "EPSG:4326")
      geojson_task <- geojsonio::geojson_json(geojson_task)
      geojson_task <- geojsonio::geojson_list(geojson_task, geometry = "Feature")
      geojson_task <- unclass(geojson_task)

    } else if (
      inherits(roi, "SpatRaster", which = FALSE)
    ) {
      # convert simple feature to geojson
      # and then to list
      geojson_task <- sf::st_bbox(roi)
      geojson_task <- sf::st_as_sfc(geojson_task)
      geojson_task <- sf::st_as_sf(geojson_task)
      geojson_task <- sf::st_transform(geojson_task, crs = "EPSG:4326")
      geojson_task <- geojsonio::geojson_json(geojson_task)
      geojson_task <- geojsonio::geojson_list(geojson_task, geometry = "Feature")
      geojson_task <- unclass(geojson_task)

    } else {
      stop("You region of interest is not of type 'sf' or 'SpatRaster")
    }

    # set output format
    output <- list("projection" = "geographic")
    output$format$type <- format

    # combine all task info fields
    task_info <- list(
      "dates" = date,
      "layers" = layers,
      "output" = output,
      "geo" = geojson_task
    )

  } else {

    required_fields <- c(
      "task",
      "subtask",
      "latitude",
      "longitude",
      "start",
      "end",
      "product",
      "layer"
    )

    if (!all(required_fields %in% names(df))) {

      missing_fields <- paste(
        required_fields[!(required_fields %in% names(df))],
        collapse = ", "
      )

      stop(
        sprintf("Your task list misses required fields: %s",
                missing_fields)
      )
    }

    # only retain unique locations to limit
    # unnecessary downloads
    df_task <- unique(df[,c("task","subtask","latitude","longitude")])

    # combine coordinates
    coordinates <- data.frame(
      id = as.character(seq_len(nrow(df_task))),
      longitude = df_task$longitude,
      latitude = df_task$latitude,
      category = df_task$subtask
    )

    # list task info
    task_info <- list(
      "dates" = date,
      "layers" = layers,
      "coordinates" = coordinates
    )
  }

  # combine all bits to form a full task
  task <- list(
    "params" = task_info,
    "task_name" = unique(df$task),
    "task_type" = type
  )

  # convert to proper JSON format
  task_json <- jsonlite::toJSON(task, auto_unbox = TRUE)

  return(task_json)
}
