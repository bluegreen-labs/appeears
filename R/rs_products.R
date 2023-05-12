#' AppEEARS dataset list
#'
#' Returns a data frame of available data products
#'
#' @return returns a data frame with the AppEEARS datasets
#' @seealso \code{\link[appeears]{rs_set_key}}
#' \code{\link[appeears]{rs_transfer}}
#' \code{\link[appeears]{rs_request}}
#'
#' @importFrom memoise memoise
#' @export
#' @author Koen Hufkens
#' @examples
#'
#' \dontrun{
#' # get a list of datasets
#' rs_products()
#'}

rs_products <- memoise::memoise(function(){

  # grab the content on a product query
  # and convert to data frame which is returned
  ct <- httr::GET(file.path(rs_server(),"product"))
  ct <- jsonlite::prettify(
    jsonlite::toJSON(httr::content(ct), auto_unbox = TRUE)
  )
  ct <- jsonlite::fromJSON(ct)

  # return content
  return(ct)
})
