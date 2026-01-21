library(tidycensus)
library(tigris)
library(sf)
library(dplyr)

# Read environment
if (file.exists(".env")) {
  # Local development
  readRenviron(".env")
}

# get census api key
census_api_key <- Sys.getenv("CENSUS_KEY") 

# Fetch 2020 population data by state
state_population <- get_decennial(
  geography = "state",
  variables = "P1_001N",  # Total population
  year = 2020,
  output = "wide",
  key = census_api_key
)

# Clean column names
state_population <- state_population %>%
  rename(
    state_name = NAME,
    population = P1_001N,
    state_fips = GEOID
  ) %>%
  select(state_fips, state_name, population)

# Save to CSV
write.csv(state_population, "data/raw/state_population_2020.csv", row.names = FALSE)
cat("Census data saved: data/raw/state_population_2020.csv\n")
cat("Rows:", nrow(state_population), "\n")
print(head(state_population))

# STEP 1B: Download State Shapefiles
states_shape <- states(cb = TRUE, year = 2020)  # 'cb' = cartographic boundaries (simplified)

# Keep only necessary columns
states_shape <- states_shape %>%
  select(STATEFP, NAME, geometry) %>%
  rename(state_fips = STATEFP, state_name = NAME)

# Save shapefile
st_write(states_shape, "data/raw/states_shapefile.shp", delete_layer = TRUE)
cat("Shapefile saved: data/raw/states_shapefile.shp\n")

# STEP 1C: Merge Data
spatial_data <- states_shape %>%
  left_join(state_population, by = c("state_fips", "state_name"))

# Calculate population density (people per sq km)
spatial_data <- spatial_data %>%
  mutate(
    area_sqkm = as.numeric(st_area(geometry)) / 1e6,
    pop_density = population / area_sqkm
  )

# Save merged spatial data
saveRDS(spatial_data, "data/processed/state_spatial_data.rds")
cat("Merged spatial data saved: data/processed/state_spatial_data.rds\n")

# Quick summary
cat("\n=== DATA SUMMARY ===\n")
cat("Total states:", nrow(spatial_data), "\n")
cat("Total US population:", sum(spatial_data$population, na.rm = TRUE), "\n")
cat("Most populous:", spatial_data$state_name[which.max(spatial_data$population)], "\n")
cat("Least populous:", spatial_data$state_name[which.min(spatial_data$population)], "\n")
cat("Highest density:", spatial_data$state_name[which.max(spatial_data$pop_density)], "\n")
