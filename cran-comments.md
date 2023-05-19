Dear CRAN team,

This is the first release of the {appeears} package. This package provides a
convenient interface to the Application for Extracting and Exploring Analysis
Ready Samples (AppEEARS) API. This API which allows querying of various remote
sensing data product for point or restricted geographic areas. This package will
over time most likely supercede the {MODISTools} API package due to the 
asynchronous download ability and better scheduling ability.

The full documentation can be found at the github repository link:
https://bluegreen-labs.github.io/appeears/

Code coverage sits at 72%, with remaining uncovered code pertaining to server
errors (which are hard to test for). The underlying framework borrows heavily
from my {ecmwfr} package due to similarities of the NASA API with those used
by ECMWF in serving climate data.

I hope this is a valuable addition to the CRAN ecosystem.
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
