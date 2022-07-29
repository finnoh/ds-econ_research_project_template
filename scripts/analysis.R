print("Runs analysis")

library(tidyverse)
library(ggplot2)
plot_diamonds <-
  diamonds %>% ggplot(aes(x = carat, y = price, color = color)) +
  geom_point(alpha = 0.3) +
  theme_bw() +
  labs(
    x = "Carat",
    y = "Price",
    color = "Diamond Color",
    title = "The Diamond Market"
  )