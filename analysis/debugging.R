# Example workflows / scratchpad
library(appeears)

user <- "khufkens"
options(keyring_backend = "file")

df <- data.frame(
  task = "grand canyon",
  subtask = c("test1", "test2"),
  latitude = c(36.206228, 36.206228),
  longitude = c(-112.127134, -112.127134),
  start = c("2018-01-01","2018-01-01"),
  end = c("2018-01-15","2018-01-15"),
  product = c("MOD11A2.061","MCD12Q2.006"),
  layer = c("LST_Day_1km","Dormancy")
)

task <- rs_build_task(df = df)

rs_request(
  request = task,
  user = "khufkens",
  transfer = TRUE,
  path = "~/tmp/test",
  verbose = TRUE
)
