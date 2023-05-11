# Example workflows / scratchpad
library(jsonlite)
library(httr)

user <- "khufkens"
options(keyring_backend = "file")

files <- list.files("R","*.R",full.names = TRUE)
lapply(files, function(file){source(file, echo = FALSE)})

token <- apprs_login(user)

df <- data.frame(
  task = "grand canyon",
  subtask = c("test1", "test2"),
  lat = c(36.206228,36.206228),
  lon = c(-112.127134,-112.127134),
  start = c("2018-01-01","2018-01-01"),
  end = c("2018-03-30","2018-03-30"),
  product = c("MOD11A2.061","MCD12Q2.006"),
  layer = c("LST_Day_1km","Dormancy")
)

task <- apprs_build_task(df = df)

apprs_request(
  request = task,
  user = "khufkens",
  transfer = TRUE,
  path = "~/tmp/test",
  verbose = TRUE
)
