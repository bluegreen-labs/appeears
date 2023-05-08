#' Build a task request
#'
#' @param df a data frame with task name (task), subtask name (subtask),
#' latitude (lat), longitude (lon), start (start) and end (end) date.
#' @param roi a region of interest defined by a SpatRaster or sf object,
#' the roi will override any point based data provided as lat/lon coordinates
#' in the data frame
#'
#' @return a valid AppEEARS JSON formatted task
#' @export
#'
#' @examples
#'

app_build_task <- function(
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
        id = 1:nrow(df),
        longitude = df$lon,
        latitude = df$lat,
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

    print(task_json)
}

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

app_build_task(df = df)
