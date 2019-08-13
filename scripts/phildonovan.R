# https://www.spatialanalytics.co.nz/post/2018/11/01/plotting-new-zealand-with-r/
# https://www.r-spatial.org/r/2018/10/25/ggplot2-sf.html


library(sf)
library(ggspatial)
library(tidyverse)
library(ggthemes)
devtools::install_github("phildonovan/nzcensr")
library(nzcensr)
library(ggrepel)

# Regions data is lazy loaded by the nzcensr and simplify
regions_simple_1000 <- st_simplify(regions, dTolerance = 1000)

# Set the theme
theme_set(theme_tufte())

ggplot() +
  
  # Add the data
  geom_sf(data = regions_simple_1000) + 
  
  # Add the title
  ggtitle("The Regions of New Zealand", 
          subtitle = "From the 2013 NZ Census") +
  
  # Add north arrow and scale bar
  annotation_north_arrow(location = "br", which_north = "true", 
                         pad_x = unit(0.05, "in"), pad_y = unit(0.2, "in"),
                         style = north_arrow_fancy_orienteering) + 
  annotation_scale(location = "br", width_hint = 0.5) +
  
  # Tinker with the theme a bit. 
  theme(panel.grid.major = element_line(color = gray(.5),
                                        linetype = "dashed", size = 0.5),
        panel.background = element_rect(fill = "white"))

# Simplify TA data
tas_simple_1000 <- st_simplify(tas, dTolerance = 1000)

ggplot(regions_simple_1000) +
  
  # Add the data
  geom_sf() + 
  geom_sf(data = tas_simple_1000, fill = NA, linetype = "dotted") + 
  
  # Add the title
  ggtitle("The Regions and Territorial Authorities of New Zealand", 
          subtitle = "From the 2013 NZ Census") +
  
  # Add north arrow and scale bar
  annotation_north_arrow(location = "br", which_north = "true", 
                         pad_x = unit(0.05, "in"), pad_y = unit(0.2, "in"),
                         style = north_arrow_fancy_orienteering) + 
  annotation_scale(location = "br", width_hint = 0.5) +
  
  # Tinker with the theme a bit. 
  theme(panel.grid.major = element_line(color = gray(.5),
                                        linetype = "dashed", size = 0.5),
        panel.background = element_rect(fill = "white"))


# Unfortunately ggrepel cannot take sf objects so we convert 
# the tas to centroids and then add the x, y to the ta data
tas_centroids <- st_centroid(tas) %>% 
  bind_cols(st_coordinates(.) %>% data.frame)

# Let's also strip away district from label names as they 
# just clutter the presentation a little.
tas_centroids <- 
  mutate(tas_centroids, 
         TA2013_NAM = str_replace(TA2013_NAM, " District", ""))

ggplot(regions_simple_1000) +
  
  # Add the data
  geom_sf() + 
  geom_sf(data = tas_simple_1000, fill = NA, linetype = "dotted") + 
  geom_text_repel(data = tas_centroids, 
                  aes(x = X, y = Y, label = TA2013_NAM),
                  alpha = 0.75,
                  fontface = "italic", family = "serif",
                  nudge_x = c(1, -1.5, 2, 2, -1), 
                  nudge_y = c(0.25, -0.25, 0.5, 0.5, -0.5)) + 
  
  # Add the title
  ggtitle("The Regions and Territorial Authorities of New Zealand", 
          subtitle = "From the 2013 NZ Census") +
  
  # Add north arrow and scale bar
  annotation_north_arrow(location = "br", which_north = "true", 
                         pad_x = unit(0.05, "in"), pad_y = unit(0.2, "in"),
                         style = north_arrow_fancy_orienteering) + 
  annotation_scale(location = "br", width_hint = 0.5) +
  
  # Tinker with the theme a bit. 
  theme_tufte() +
  theme(panel.grid.major = element_line(color = gray(.5),
                                        linetype = "dashed", size = 0.5),
        panel.background = element_rect(fill = "white"),
        axis.title = element_blank())


# We'll use the cowplot library to easily inset ggplot graphs / maps.
library(cowplot)

# Split the data between Chatham Islands and the rest of NZ.
chathams <- filter(regions_simple_1000, REGC2013 == 99)
chatham_tas <- filter(tas_simple_1000, str_detect(TA2013_NAM, "Chatham"))
chatham_tas_point <- filter(tas_centroids, str_detect(TA2013_NAM, "Chatham"))

nz_regions <- filter(regions_simple_1000, REGC2013 != 99)

nz_tas <- filter(tas_simple_1000, 
                 !str_detect(TA2013_NAM, "Chatham|Area Outside"))

nz_tas_point <- filter(tas_centroids, 
                       !str_detect(TA2013_NAM, "Chatham|Area Outside"))

# Make plots
# First plot is jsut the plot of the mainland excluding the Chathams.
nz_plot <- 
  
  # Create ggplot object
  ggplot(nz_regions) +
  
  # Add the data
  geom_sf() + 
  geom_sf(data = nz_tas, fill = NA, linetype = "dotted") + 
  geom_text_repel(data = nz_tas_point, 
                  aes(x = X, y = Y, label = TA2013_NAM),
                  alpha = 0.75,
                  fontface = "italic", family = "serif",
                  nudge_x = c(1, -1.5, 2, 2, -1), 
                  nudge_y = c(0.25, -0.25, 0.5, 0.5, -0.5)) + 
  
  # Add the title
  ggtitle("The Regions and Territorial Authorities of New Zealand", 
          subtitle = "From the 2013 NZ Census") +
  
  # Add north arrow and scale bar
  annotation_north_arrow(location = "bl", which_north = "true", 
                         pad_x = unit(0.05, "in"), pad_y = unit(0.2, "in"),
                         style = north_arrow_fancy_orienteering) + 
  annotation_scale(location = "bl", width_hint = 0.5) +
  
  # Tinker with the theme a bit. 
  theme_tufte() +
  theme(panel.grid.major = element_line(color = gray(.5),
                                        linetype = "dashed", size = 0.5),
        panel.background = element_rect(fill = "white"),
        axis.title = element_blank())

# Chathams
chatham_plot <-
  
  # Create ggplot object
  ggplot(chathams) +
  
  # Add the data
  geom_sf() + 
  geom_sf(data = chatham_tas, fill = NA, linetype = "dotted") + 
  geom_text_repel(data = chatham_tas_point, 
                  aes(x = X, y = Y, label = TA2013_NAM),
                  alpha = 0.75,
                  fontface = "italic", family = "serif") + 
  
  # Tinker with the theme a bit. 
  theme_bw() +
  theme(panel.grid.major = element_line(color = "white"),
        panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "white"),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_blank(),
        axis.line = element_blank())

ggdraw(nz_plot) +
  draw_plot(chatham_plot, width = 0.16, height = 0.16, x = 0.65, y = 0.05)

nz_plot <- 
  
  # Create ggplot object
  ggplot(nz_regions) +
  
  # Add the data
  geom_sf(aes(fill = REGC2013_N)) +
  geom_sf(data = nz_tas, fill = NA, linetype = "dotted") + 
  geom_text_repel(data = nz_tas_point, 
                  aes(x = X, y = Y, label = TA2013_NAM),
                  alpha = 0.75,
                  fontface = "italic", family = "serif",
                  nudge_x = c(1, -1.5, 2, 2, -1), 
                  nudge_y = c(0.25, -0.25, 0.5, 0.5, -0.5)) + 
  
  # Add the title
  ggtitle("The Regions and Territorial Authorities of New Zealand", 
          subtitle = "From the 2013 NZ Census") +
  labs(fill = "Region") + 
  
  # Add north arrow and scale bar
  annotation_north_arrow(location = "bl", which_north = "true", 
                         pad_x = unit(0.05, "in"), pad_y = unit(0.2, "in"),
                         style = north_arrow_fancy_orienteering) + 
  annotation_scale(location = "bl", width_hint = 0.5) +
  
  # Tinker with the theme a bit. 
  theme_tufte() +
  theme(panel.grid.major = element_line(color = gray(.5),
                                        linetype = "dashed", size = 0.5),
        panel.background = element_rect(fill = "white"),
        axis.title = element_blank())

nz_plot

###
nz_regions$REGC2013_N2 <- str_replace(name," Region", "")

nz_regions2 <- nz_regions %>% left_join(hdat, by = c("REGC2013_N2" = "region")) %>% 
  filter(.,short.description == "ADHD" & type == "CRUDE")

adhd_plot <- 
  
  # Create ggplot object
  ggplot(nz_regions2) +
  
  # Add the data
  geom_sf(aes(fill = Prevalence_Mean)) +
  geom_sf(data = nz_tas, fill = NA, linetype = "dotted") + 
  
  # Add the title
  ggtitle("ADHD Prevalence", 
          subtitle = "per 1000 People") +
  labs(fill = "Prevalence") + 
  
  # Add north arrow and scale bar
  annotation_north_arrow(location = "bl", which_north = "true", 
                         pad_x = unit(0.05, "in"), pad_y = unit(0.2, "in"),
                         style = north_arrow_fancy_orienteering) + 
  annotation_scale(location = "bl", width_hint = 0.5) +
  
  # Tinker with the theme a bit. 
  theme_tufte() +
  theme(panel.grid.major = element_line(color = gray(.5),
                                        linetype = "dashed", size = 0.5),
        panel.background = element_rect(fill = "white"),
        axis.title = element_blank())

adhd_plot