#' AppEEARS dataset list
#'
#' Returns a data frame of available products
#'
#' @return returns a data frame with the AppEEARS datasets
#' @seealso \code{\link[appeears]{app_set_key}}
#' \code{\link[appeears]{app_transfer}}
#' \code{\link[appeears]{app_request}}
#'
#' @export
#' @author Koen Hufkens
#' @examples
#'
#' \dontrun{
#' # get a list of datasets
#' app_products()
#'}

app_products <- function(){

  # grab the content on a product query
  # and convert to data frame which is returned
  ct <- httr::GET(file.path(app_server(),"product"))
  ct <- jsonlite::prettify(
    jsonlite::toJSON(content(ct), auto_unbox = TRUE)
  )
  ct <- jsonlite::fromJSON(ct)

  # return content
  return(ct)
}
