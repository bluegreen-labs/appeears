#' AppEEARS dataset layers
#'
#' Returns a data frame of available layers
#' for an AppEEARS product
#'
#' @param product product for which to list the layers
#' @return returns a data frame with the AppEEARS datasets
#' @seealso \code{\link[appeears]{rs_products}}
#'
#' @export
#' @author Koen Hufkens
#' @examples
#'
#' \dontrun{
#' # get a list of datasets
#' rs_layers()
#'}

rs_layers <- function(
    product
    ){

  # grab the content on a product query
  # and convert to data frame which is returned
  ct <- httr::GET(file.path(rs_server(),"product", product))
  ct <- jsonlite::prettify(
    jsonlite::toJSON(httr::content(ct), auto_unbox = TRUE)
  )
  ct <- jsonlite::fromJSON(ct)

  # convert to data frame
  df <- as.data.frame(
    do.call("rbind",ct)
  )

  df$Band <- rownames(df)
  rownames(df) <- NULL

  # return content
  return(df)
}