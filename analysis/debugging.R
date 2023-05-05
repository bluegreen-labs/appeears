# Example workflows / scratchpad

options(keyring_backend = "file")

source("R/app_get_key.R")
source("R/app_set_key.R")
source("R/zzz.R")
source("R/app_products.R")
source("R/app_layers.R")

l <- app_layers(
  product = "MCD43A4.006"
)

print(l)

p <- app_products()

print(p)
