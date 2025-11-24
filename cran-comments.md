Dear CRAN team,

This is an update of the {appeears} package (version 1.2). This package provides a convenient interface to the Application for Extracting and Exploring Analysis Ready Samples (AppEEARS) API. The update includes trapping service/server errors more cleanly. When the service/server goes down (5xx http errors) the current error message is confusing to users (failing on internal logic). This fix provides more verbose feedback, and exits further processing cleanly. Given the nature of the errors no retry loop is initiated, not to stress the service. No other changers were made, retaining code coverage.

Kind regards,
Koen Hufkens

--- 

I have read and agree to the the CRAN policies at:
http://cran.r-project.org/web/packages/policies.html

## local, github actions and r-hub

- Ubuntu 22.04 install on R 4.5.2
- Ubuntu 22.04 on github actions (devel / release)
- rhub::check_on_cran() with only notes for stray latex elements
- codecove.io code coverage at ~73%

## github actions R CMD check results

0 errors | 0 warnings | 0 notes
