Dear CRAN team,

This is an update of the {appeears} package (version 1.1). This package provides a convenient interface to the Application for Extracting and Exploring Analysis Ready Samples (AppEEARS) API.

The update includes one single feature, the addition of a batch downloading
option. This was initially not included (as you can requests larger/complex batches from the API). However, to organize timely downloads from the API the batch scheduler still seems useful. Code coverage remains at ~73%. Additional corrections to the documentation were also made.

Kind regards,
Koen Hufkens

--- 

I have read and agree to the the CRAN policies at:
http://cran.r-project.org/web/packages/policies.html

## local, github actions and r-hub

- Ubuntu 22.04 install on R 4.3.1
- Ubuntu 22.04 on github actions (devel / release)
- rhub::check_on_cran() with only notes for stray latex elements
- codecove.io code coverage at ~73%

## github actions R CMD check results

0 errors | 0 warnings | 0 notes
