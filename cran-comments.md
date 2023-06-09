Dear CRAN team,

This is the re-submission of the {appeears} package. This package provides a
convenient interface to the Application for Extracting and Exploring Analysis
Ready Samples (AppEEARS) API. This API which allows querying of various remote
sensing data product for point or restricted geographic areas. This package will
over time most likely supersede the {MODISTools} API package due to the 
asynchronous download ability and better scheduling ability.

The full documentation can be found at the github repository link:
https://bluegreen-labs.github.io/appeears/

Code coverage sits at 72%, with remaining uncovered code pertaining to server
errors (which are hard to test for). The underlying framework borrows heavily
from my {ecmwfr} package due to similarities of the NASA API with those used
by ECMWF in serving climate data.

## revisions (per review)

All code is tested outside CRAN as personal API codes can not be shared. For
a breakdown of coverage statistics I refer to:

https://app.codecov.io/gh/bluegreen-labs/appeears

Limited functions are documented with "dynamic" examples which are run (on CRAN).
Functions covered in this way are, rs_layers() and  rs_products() which require no authentication. rs_build_task() is now exposed as well (not wrapped in dontrun). 
All other function touch upon some form of authentication (and can't be tested due to credentials).

Furthermore, I added Elio Campitelli as contributor, as the R6 refactoring of 
{ecmwfr} was mostly his work. I've borrowed this for the package in hindsight 
this seems only fair (I've got written consent, and both DESCRIPTION and 
CITATION files were updated accordingly).

I hope with these additions the package can be reconsidered.
Kind regards,
Koen Hufkens

--- 

I have read and agree to the the CRAN policies at:
http://cran.r-project.org/web/packages/policies.html

## local, github actions and r-hub

- Ubuntu 22.04 install on R 4.3
- Ubuntu 22.04 on github actions (devel / release)
- rhub::check_on_cran() with only notes for stray latex elements
- codecove.io code coverage at ~72%

## github actions R CMD check results

0 errors | 0 warnings | 0 notes

