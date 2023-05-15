# appeears 

[![R-CMD-check](https://github.com/bluegreen-labs/appeears/workflows/R-CMD-check/badge.svg)](https://github.com/bluegreen-labs/appeears/actions)
[![codecov](https://codecov.io/gh/bluegreen-labs/ecmwfr/branch/master/graph/badge.svg)](https://codecov.io/gh/bluegreen-labs/ecmwfr)

Programmatic interface to the [NASA AppEEARS API](https://appeears.earthdatacloud.nasa.gov/) services where, and I quote, "The Application for Extracting and Exploring Analysis Ready Samples (AρρEEARS) offers a simple and efficient way to access and transform geospatial data from a variety of federal data archives. AρρEEARS enables users to subset geospatial datasets using spatial, temporal, and band/layer parameters."

## How to cite this package in your article

You can cite this package like this "we obtained data through the NASA AppEEARS
API using the {appeears} R package (Hufkens 2023)". Here is the full
bibliographic reference to include in your reference list (don't forget
to update the 'last accessed' date):

> Hufkens, K. (2023). appeears: Programmatic interface to the NASA AppEEARS API. Zenodo. <http://doi.org/10.5281/zenodo.xxx>.

## Installation

### development release

To install the development releases of the package run the following
commands:

``` r
if(!require(remotes)){install.packages("remotes")}
remotes::install_github("bluegreen-labs/appeears")
library("appeears")
```

Vignettes are not rendered by default, if you want to include additional
documentation please use:

``` r
if(!require(remotes)){install.packages("remotes")}
remotes::install_github("bluegreen-labs/appeears", build_vignettes = TRUE)
library("appeears")
```

## Use

### Setup

Before starting save the provided NASA Earth Data password to your local keychain. The
package does not allow you to use your password inline in scripts to limit
security issues when sharing scripts on github or otherwise.

``` r
# set a key to the keychain
rs_set_key(
  user = "earth_data_user",
  password = "XXXXXXXXXXXXXXXXXXXXXX"
  )

# you can retrieve the password using
rs_get_key(user = "earth_data_user")

# the output should be the key you provided
# "XXXXXXXXXXXXXXXXXXXXXX"
```

Downloads are managed using a Bearer/session token. This token is valid for 48 hours,
after which it will expire and you will need to request a new one. Although downloads
are managed using the user (keychain) details only, you can request the current token
using `rs_login()`, while `rs_logout()` will explicitly invalidate the current
session token.

```r
# request the current token
token <- rs_login(user = "earth_data_user")

# invalidate the current session
rs_logout(token)
```

### Point based data requests

All point based queries are made by first creating a
tidy data frame with the desired products and layers
to query.

In this data frame `task` specifies the overall name
of the task to run (this prefix will be used to name
the final downloaded files). The `subtask` denotes the
various locations and or products you want to query. As
such, you can query multiple locations in the same larger
task, avoiding multiple queries to the API.

The `latitude` and `longitude` fields specify geographic
coordinates of query locations, while `start` and `end`
columns define the range of the data queried. Note that
the date range will cover the maximum date range across
all `subtasks`. If date ranges vary widely it is advised
to create separate tasks.

Finally the `product` and `layer` columns denote the 
remote sensing product and particular layer to download.
A full list of products can be queried using `rs_products()`,
while the layers of a particular product can be listed
using `rs_layers()`. Note that the product needs to be
specified using the full product name, including the version
of the product (as stored in the `ProductAndVersion` field).

For point and area based queries all data are saved in a
subdirectory of the main `path` as defined by the task name.
An abbreviated workflow can be found below, while a full
worked example is provided in the vignettes.

```r
# Load the library
library(appeears)

# list all products
rs_products()

# list layers of the MOD11A2.061 product
rs_layers("MOD11A2.061")

# specifiy a task/request as a
# data frame
df <- data.frame(
  task = "task",
  subtask = c("sub_task_1", "sub_task_2"),
  latitude = c(36.206228, 36.206228),
  longitude = c(-112.127134, -112.127134),
  start = c("2018-01-01","2018-01-01"),
  end = c("2018-01-15","2018-01-15"),
  product = c("MOD11A2.061","MCD12Q2.006"),
  layer = c("LST_Day_1km","Greenup")
)

# build a proper JSON query
task <- rs_build_task(df = df)

# request the task to be executed
rs_request(
  request = task,
  user = "earth_data_user",
  transfer = TRUE,
  path = "~/some_path",
  verbose = TRUE
)
````

### Area based data requests

You can select a region-of-interest (ROI) instead of point based data,
using both `sf` polygons or the extent (bounding box) of an existing
`terra` `SpatRaster` object. Both methods follow the same workflow.

#### {sf} polygon ROI

When using an `sf` object, provide it to the `roi` argument of the
`rs_build_task()` function. The `sf` object must be of class `sf` not `sfc`
when required convert `sfc` data using `st_as_sf()`.

Note however that at the time only as simple polygon is supported. Multiple 
polygons in the same `sf` object might result in failure to query the data.

Furthermore, no other means will be provided to specify a region-of-interest.
As such, you will always have to query a region-of-interest using an `sf`
object. This ensures consistency across queries and allows for rapid visualization
of a region of interest (in contrast to a simple list of e.g. top-left,
bottom-right coordinates).

```r
# load the required libraries
library(sf)
library(dplyr)

# load the north carolina demo data
# included in the {sf} package
# and only retain Camden county
roi <- st_read(system.file("gpkg/nc.gpkg", package="sf"), quiet = TRUE) |>
  filter(
    NAME == "Camden"
  )

# build the area based request/task
task <- rs_build_task(
  df = df,
  roi = roi,
  format = "geotiff"
)

# request the task to be executed
rs_request(
  request = task,
  user = "earth_data_user",
  transfer = TRUE,
  path = "~/some_path",
  verbose = TRUE
)
```

#### {terra} SpatRaster ROI

The `terra` based region-of-interest workflow is similar to that of `sf`
polygon based queries. One only has to provide a `SpatRaster` as an `roi`
argument in `rs_build_task()` to query a region of the same extent as the
`SpatRaster`. The use case for this functionality is obvious, creating a quick
way to sample new data for an existing data set (using the same coverage).

Note that unlike the `sf` method a bounding box is used and masked data is
ignored (the full extent is downloaded and masking will have to be repeated
afterwards).

```r
# load the required libraries
library(terra)

# create a SpatRaster ROI from the terra demo file
f <- system.file("ex/elev.tif", package="terra")
roi <- terra::rast(f)

# build the area based request/task
task <- rs_build_task(
  df = df,
  roi = roi,
  format = "geotiff"
)

# request the task to be executed
rs_request(
  request = task,
  user = "earth_data_user",
  transfer = TRUE,
  path = "~/some_path",
  verbose = TRUE
)
```

## File based keychains

On linux you can opt to use a file based keyring, instead of a GUI based
keyring manager. This is helpful for headless setups such as servers.
For this option to work linux users must set an environmental option.

``` r
options(keyring_backend="file")
```

You will be asked to provide a password to encrypt the keyring with.
Upon the start of each session you will be asked to provide this
password, unlocking all `appeears` credentials for this session. Should
you ever forget the password just delete the file at:
`~/.config/r-keyring/ecmwfr.keyring` and re-enter all your credentials.


# Acknowledgements

The `appeears` package is a product of BlueGreen Labs, and has been in part supported by the LEMONTREE project funded through the Schmidt Futures fund, under the umbrella of the Virtual Earth System Research Institute (VESRI).
