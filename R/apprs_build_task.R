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
#' the roi will override any point based data provided as latittude/longitude
#' coordinates in the data frame
#'
#' @return a valid AppEEARS JSON formatted task
#' @export

apprs_build_task <- function(
    df,
    roi
    ) {

    # split out names of the data frame
    cols <- names(df)

    # check minimum required data
    # task, subtask, start, end, product, layer
    # lat/lon is elective if an roi is provided

    # missing roi -> point extraction
    if (missing(roi)) {
        taskType <- "point"
    } else {
        taskType <- "area"
    }

    if(!("start" %in% cols & "end" %in% cols)){
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
        startDate = format(as.Date(start),"%m-%d-%Y"),
        endDate = format(as.Date(end),"%m-%d-%Y")
    )

    layers <- data.frame(
        product = df$product,
        layer = df$layer
    )

    # combine coordinates
    coordinates <- data.frame(
        id = as.character(1:nrow(df)),
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

    task <- list(
        "params" = task_info,
        "task_name" = unique(df$task),
        "task_type" = taskType
        )

    task_json <- jsonlite::toJSON(task,auto_unbox = TRUE)

    return(task_json)
}
