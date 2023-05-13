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
#' @param format file format of the downloaded data either geotiff or
#'  netcdf4 (the default)
#'
#' @return a valid AppEEARS JSON formatted task
#' @export
#' @examples
#'
#' \dontrun{
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
#' layer = c("Dormancy")
#' )
#'
#' # build a task
#' rs_build_task(df)
#'}

rs_build_task <- function(
    df,
    roi,
    format = "netcdf4"
) {

  # split out names of the data frame
  cols <- names(df)

  # check minimum required data
  # task, subtask, start, end, product, layer
  # lat/lon is elective if an roi is provided

  # missing roi -> point extraction
  if (missing(roi)) {
    type <- "point"
  } else {
    type <- "area"
  }

  if (!(("start" %in% cols) && ("end" %in% cols))) {
    stop("missing date range")
  }

  # set date range, with reall, a MM-DD-YYYY format
  # dear people at NASA get your sh*t together, this
  # stuff crashes satellites

  # extract the maximum date range from all listed
  # subtasks
  start <- min(as.Date(df$start))
  end <- max(as.Date(df$end))

  date <- data.frame(
    startDate = format(as.Date(start), "%m-%d-%Y"),
    endDate = format(as.Date(end), "%m-%d-%Y")
  )

  layers <- data.frame(
    product = df$product,
    layer = df$layer
  )

  if (!missing(roi)) {
    if (inherits(roi, "sf", which = FALSE)) {
      # convert simple feature to geojson
      # and then to list
      geojson_list <- roi |>
        st_union() |> # create one polygon
        st_as_sf() |> # create simple feature
        st_transform(crs = "EPSG:4326") |> # transform to geographic
        geojsonio::geojson_json() |>
        geojson_list(geometry = "Feature") |>
        unclass()

    } else if (
      inherits(roi, "SpatRaster", which = FALSE)
    ) {
      # convert simple feature to geojson
      # and then to list
      geojson_list <- roi |>
        sf::st_bbox() |>
        st_as_sfc() |>
        st_as_sf() |> # must be simple feature to work
        st_transform(crs = "EPSG:4326") |>
        geojsonio::geojson_json() |>
        geojson_list(geometry = "Feature") |>
        unclass()

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
      "geo" = geojson_list
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

    # combine coordinates
    coordinates <- data.frame(
      id = as.character(seq_len(nrow(df))),
      longitude = df$longitude,
      latitude = df$latitude,
      category = df$subtask
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