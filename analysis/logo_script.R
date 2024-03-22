library(hexSticker)
library(showtext)

# Loading Google fonts (http://www.google.com/fonts)
font_add_google("Roboto")

# Automatically use showtext to render text for future devices
showtext_auto()

## use the ggplot2 example
sticker(
  here::here("globe-eurafrica.png"),
  package="AρρEEARS",
  p_size=22,
  p_y = 1.3,
  s_x=1,
  s_y=.3,
  s_width=.8,
  h_fill = "#2276ac",
  h_color = "#2276ac",
  p_family = "Roboto",
  white_around_sticker = TRUE,
  filename = here::here("logo.png")
)
