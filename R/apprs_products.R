#' AppEEARS dataset list
#'
#' Returns a data frame of available data products
#'
#' @return returns a data frame with the AppEEARS datasets
#' @seealso \code{\link[apprs]{apprs_set_key}}
#' \code{\link[apprs]{apprs_transfer}}
#' \code{\link[apprs]{apprs_request}}
#'
#' @export
#' @author Koen Hufkens
#' @examples
#'
#' \dontrun{
#' # get a list of datasets
#' apprs_products()
#'}

apprs_products <- memoise::memoise(function(){

  # grab the content on a product query
  # and convert to data frame which is returned
  ct <- httr::GET(file.path(apprs_server(),"product"))
  ct <- jsonlite::prettify(
    jsonlite::toJSON(httr::content(ct), auto_unbox = TRUE)
  )
  ct <- jsonlite::fromJSON(ct)

  # return content
  return(ct)
})
