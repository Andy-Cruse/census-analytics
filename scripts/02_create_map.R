library(leaflet)
library(sf)
library(dplyr)
library(viridis)
library(htmlwidgets)
library(ggplot2)

# Load processed data
spatial_data <- readRDS("data/processed/state_spatial_data.rds")

# Convert to Web Mercator for Leaflet
spatial_data_wm <- st_transform(spatial_data, crs = 4326) |>
  filter(!state_fips %in% c("60", "78", "66", "69", "72"))  # remove territories except DC

# Create color palette based on population density
pal <- colorNumeric(
  palette = "viridis",
  domain = spatial_data_wm$pop_density
)

# Create interactive map
map <- leaflet(spatial_data_wm) %>%
  addTiles() %>%  # Base map
  addPolygons(
    fillColor = ~pal(pop_density),
    weight = 1,
    opacity = 1,
    color = "white",
    dashArray = "3",
    fillOpacity = 0.7,
    highlightOptions = highlightOptions(
      weight = 3,
      color = "#666",
      fillOpacity = 0.9,
      bringToFront = TRUE
    ),
    label = ~paste(
      state_name, 
      "<br>Population: ", format(population, big.mark = ","),
      "<br>Density: ", round(pop_density, 1), " people/km²"
    ) %>% lapply(htmltools::HTML),
    labelOptions = labelOptions(
      style = list("font-weight" = "normal", padding = "3px 8px"),
      textsize = "12px",
      direction = "auto"
    )
  ) %>%
  addLegend(
    pal = pal,
    values = ~pop_density,
    opacity = 0.7,
    title = "Population Density<br>(people/km²)",
    position = "bottomright"
  )

# Save as HTML
saveWidget(map, file = "output/us_population_density_map.html")
cat("Interactive map saved: output/us_population_density_map.html\n")

# Create a static plot
static_plot <- ggplot(spatial_data) +
  geom_sf(aes(fill = pop_density), color = "white", size = 0.2) +
  scale_fill_viridis_c(
    name = "Population Density\n(people/km²)",
    option = "plasma",
    trans = "log10"
  ) +
  labs(
    title = "US Population Density by State (2020 Census)",
    subtitle = "Darker colors indicate higher population density",
    caption = "Source: US Census Bureau 2020 Decennial Census"
  ) +
  theme_void() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5)
  )

ggsave("output/us_population_density_static.png", static_plot, 
       width = 10, height = 6, dpi = 300)
cat("Static map saved: output/us_population_density_static.png\n")

# Open the HTML map in browser
browseURL("output/us_population_density_map.html")
