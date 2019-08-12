library(sp)
# https://gadm.org/download_country_v3.html
# download NZ shapefiles

nz1 <- readRDS("data/gadm36_NZL_1_sp.rds")
nz2 <- readRDS("data/gadm36_NZL_2_sp.rds")

nz1$NAME_2 <- as.factor(nz1$NAME_1)
nz1$fake.data <- runif(length(nz1$NAME_1)) 

spplot(nz1,
       "NAME_2", 
       xlim=c(163,180), 
       scales=list(draw=T), 
       ylim=c(-50,-32), 
       col.regions=rgb(nz1$fake.data, 1-nz1$fake.data, 0), 
       colorkey=F)

## Avoid scientific notation
options(scipen = 12)

## Load required packages
lib <- c("raster", "rgdal", "ggplot2")
sapply(lib, function(x) require(x, character.only = TRUE))

## Download and reproject data from gadm.org to UTM 60S
nz1 <- getData("GADM", country = "NZ", level = 1)
nz1 <- spTransform(nz1, CRS("+init=epsg:2135"))
nz1 <- spTransform(nz1, CRS("+proj=utm +zone=60 +datum=WGS84"))

## Extract polygon corners and merge with shapefile data
nz1@data$id <- rownames(nz1@data)
nz1.ff <- fortify(nz1)
nz1.df <- merge(nz1@data, nz1.ff, by = "id", all.y = TRUE)

## Plot map
ggplot() + 
  geom_polygon(data = nz1.df, aes(x = long, y = lat, group = group, 
                                  fill = NAME_1), color = "black", show_legend = FALSE) +
  labs(x = "x", y = "y") + 
  
  theme_bw()

library(rgdal)
library(spdplyr)
library(geojsonio)
library(rmapshaper)
nz_region <- readOGR(dsn = "/Users/kannishida/Downloads/2016_Digital_Boundaries", layer = "REGC2016_GV_Clipped")
wgs84 = '+proj=longlat +datum=WGS84'
nz_region <- spTransform(nz_region, CRS(wgs84))
nz_region1 <- nz_region %>% filter(REGC2016 != "99")

