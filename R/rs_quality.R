#' List or translate AppEEARS quality metrics
#'
#' Returns a data frame of all quality layers,
#' or the translation of a quality layer value
#' into plain language.
#'
#' @param product AppEEARS product name
#' @param layer name of a product quality control layer
#' @param value quality control value to translate
#'
#' @return returns a data frame of all AppEEARS quality layers,
#' or those associated with a product. When a value is provided
#' this quality flag will be translated from bitwise representation
#' to plain language.
#'
#' @export
#' @author Koen Hufkens
#' @examples
#'
#' \dontrun{
#' # get a list of quality layers for all data products
#' rs_quality()
#'}

rs_quality <- memoise::memoise(function(
  product,
  layer,
  value
){

  # grab quality info for all products
  if (
      missing(product) &
      missing(layer) &
      missing(value)
      ){

    ct <- httr::GET(
      file.path(rs_server(),"quality"))
  }

  # grab quality info for a single product
  if (!missing(product)) {

    ct <- httr::GET(
      file.path(rs_server(),"quality", product))
  }

  # grab quality info for a product layer combination
  if (!missing(product) & !missing(layer)) {

    ct <- httr::GET(
      file.path(rs_server(),"quality", product, layer))
  }

  # grab quality info for a product layer combination
  if (!missing(product) & !missing(layer) & !missing(value) ) {

    ct <- httr::GET(
      file.path(rs_server(),"quality", product, layer))
  }

  # split out the content from the returned
  # API data, and clean up the JSON formatting
  ct <- jsonlite::prettify(
    jsonlite::toJSON(httr::content(ct), auto_unbox = TRUE)
  )

  # convert the json data to a data frame
  df <- jsonlite::fromJSON(ct)

  # return content
  return(df)
})
