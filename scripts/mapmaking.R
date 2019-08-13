#### ggplot2 map making
library(tidyverse)
library(ggplot2)
library(ggmap)
library(maps)
library(mapdata)
theme_set(
  theme_void()
)

## the world
map.world <- map_data("world") 

ggplot(map.world, aes(x = long, y = lat, group = group)) +
  geom_polygon(fill="lightgray", colour = "white")


usa <- map_data("usa")
states <- map_data("state")
nz <- map_data("nz")
head(nz)

ggplot() + geom_polygon(data = nz, aes(x=long, y = lat, group = group)) + 
  coord_fixed(1.3)

ggplot() + geom_polygon(data = nz, aes(x=long, y = lat, group = group)) + 
  coord_fixed(1.3) +
  geom_point(aes(y=-45.872979, x=170.472364), col = "yellow",size=4)

ggplot(data = states) + 
  geom_polygon(aes(x = long, y = lat, fill = region, group = group), color = "white") + 
  coord_fixed(1.3) +
  guides(fill=FALSE)  # do this to leave off the color legend


# Some EU Contries
some.eu.countries <- c(
  "Portugal", "Spain", "France", "Switzerland", "Germany",
  "Austria", "Belgium", "UK", "Netherlands",
  "Denmark", "Poland", "Italy", 
  "Croatia", "Slovenia", "Hungary", "Slovakia",
  "Czech republic"
)
# Retrievethe map data
some.eu.maps <- map_data("world", region = some.eu.countries)

# Compute the centroid as the mean longitude and lattitude
# Used as label coordinate for country's names
region.lab.data <- some.eu.maps %>%
  group_by(region) %>%
  summarise(long = mean(long), lat = mean(lat))

ggplot(some.eu.maps, aes(x = long, y = lat)) +
  geom_polygon(aes( group = group, fill = region))+
  geom_text(aes(label = region), data = region.lab.data,  size = 3, hjust = 0.5)+
  scale_fill_viridis_d()+
  theme_void()+
  theme(legend.position = "none")

library("WHO")

life.exp <- get_data("WHOSIS_000001")             # Retrieve the data
life.exp <- life.exp %>%
  filter(year == 2015 & sex == "Both sexes") %>%  # Keep data for 2015 and for both sex
  select(country, value) %>%                      # Select the two columns of interest
  rename(region = country, lifeExp = value) %>%   # Rename columns
  # Replace "United States of America" by USA in the region column
  mutate(
    region = ifelse(region == "United States of America", "USA", region)
  ) 

world_map <- map_data("world")
life.exp.map <- left_join(life.exp, world_map, by = "region")

ggplot(life.exp.map, aes(long, lat, group = group))+
  geom_polygon(aes(fill = lifeExp ), color = "white")+
  scale_fill_viridis_c(option = "C")




library(sp)
# https://gadm.org/download_country_v3.html
# download NZ shapefiles

## Avoid scientific notation
options(scipen = 12)

## Load required packages
lib <- c("raster", "rgdal", "ggplot2")
sapply(lib, function(x) require(x, character.only = TRUE))

## Download and reproject data from gadm.org to UTM 60S
nz1 <- getData("GADM", country = "NZ", level = 1)
#nz1 <- spTransform(nz1, CRS("+init=epsg:2135"))
nz1 <- spTransform(nz1, CRS("+proj=utm +zone=59 +datum=WGS84"))

## Extract polygon corners and merge with shapefile data
nz1@data$id <- rownames(nz1@data)
nz1.ff <- fortify(nz1)
nz1.df <- merge(nz1@data, nz1.ff, by = "id", all.y = TRUE)

## Plot map
ggplot() + 
  geom_polygon(data = nz1.df, aes(x = long, y = lat, group = group, fill = NAME_1), color = "black") +
  theme(legend.position = "none") +
  labs(x = "x", y = "y") + 
  theme_bw()

  

