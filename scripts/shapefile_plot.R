require("rgdal") # requires sp, will use proj.4 if installed
require("maptools")
require("ggplot2")
require("plyr")

utils::unzip("data/kx-district-health-board-2015-SHP.zip", exdir = "data/")
shp <- readOGR(dsn = "data/district-health-board-2015.shp", stringsAsFactors = F)

summary(shp@data)

map <- ggplot() + geom_polygon(data = shp, aes(x = long, y = lat, group = group), colour = "black", fill = NA)
map + theme_void() + coord_fixed(1.3)

hdat <- read_csv(file="data/nz-health-survey-2016-17-regional-update-dhb-prevalences.zip")

# Regions data is lazy loaded by the nzcensr and simplify
library(rgdal)
library(spdplyr)
library(geojsonio)
library(rmapshaper)
library(tidyverse)

shp <- readOGR(dsn = "data/district-health-board-2015.shp", stringsAsFactors = F)
wgs84 = '+proj=longlat +datum=WGS84'
shp2 <- spTransform(shp, CRS(wgs84))
shp3 <- fortify(shp2)

shp4 <- shp3 %>%
  filter(DHB2015_Co != 99)


shp@data <- shp@data %>%
  filter(DHB2015_Co != 99) %>% 
  left_join(hdat, by = c("DHB2015_Na" = "region")) %>% 
  filter(.,short.description == "ADHD" & type == "CRUDE")

adhd_plot <- 
  # Create ggplot object
  ggplot(shp) +
  # Add the data
  geom_sf(aes(fill = shp@data$Prevalence_Mean)) +
  # Add the title
  ggtitle("ADHD Prevalence", 
          subtitle = "per 1000 People") +
  labs(fill = "Prevalence")

adhd_plot

adhd_plot + facet_grid(. ~ Ethnicity)

