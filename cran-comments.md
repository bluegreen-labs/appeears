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

## revisions

All code is tested outside CRAN as personal API codes can not be shared. For
a breakdown of coverage statistics I refer to:

https://app.codecov.io/gh/bluegreen-labs/appeears

Limited functions are documented with "dynamic" examples which are run.
The code required to trap potential errors if the service is down
exceeds that of actual function coverage. Therefore I personally would object 
to this course of action, as it might confuse users to why this is included and if
this is necessary within their own code. However, I will retain these changes
as per review request. Functions covered in this way are, rs_layers() and 
rs_products() which require no authentication. rs_build_task() is now exposed
as well (not wrapped in dontrun).

I hope with these additions the package can be considered.
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

