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
county_population <- get_decennial(
  geography = "county",
  state = "17",
  variables = "P1_001N",  # Total population
  year = 2020,
  output = "wide",
  key = census_api_key
)

# Clean column names
county_population <- county_population %>%
  mutate(county_name = gsub(" County, Illinois", "", NAME)) %>%
  mutate(county_fips = substr(GEOID, 3, nchar(GEOID))) %>%
  # mutate(state_fips = "17") %>%
  rename(population = P1_001N) %>%
  select(county_fips, county_name, population)

# Save to CSV
write.csv(county_population, "data/raw/county_population_2020.csv", row.names = FALSE)
cat("Census data saved: data/raw/county_population_2020.csv\n")
cat("Rows:", nrow(county_population), "\n")
print(head(county_population))

# STEP 1B: Download State Shapefiles
counties_shape <- counties(state = "17", cb = TRUE, year = 2020)
  
# Keep only necessary columns
counties_shape <- counties_shape %>%
  select(COUNTYFP, NAME, geometry) %>%
  rename(county_fips = COUNTYFP, county_name = NAME)

# Save shapefile
st_write(counties_shape, "data/raw/counties_shapefile.shp", delete_layer = TRUE)
cat("Shapefile saved: data/raw/counties_shapefile.shp\n")

# STEP 1C: Merge Data
spatial_data <- counties_shape %>%
  left_join(county_population, by = c("county_fips", "county_name"))

# Calculate population density (people per sq km)
spatial_data <- spatial_data %>%
  mutate(
    area_sqkm = as.numeric(st_area(geometry)) / 1e6,
    pop_density = population / area_sqkm
  )

# Save merged spatial data
saveRDS(spatial_data, "data/processed/county_spatial_data.rds")
cat("Merged spatial data saved: data/processed/county_spatial_data.rds\n")

# Quick summary
cat("\n=== DATA SUMMARY ===\n")
cat("Total counties:", nrow(spatial_data), "\n")
cat("Total IL population:", sum(spatial_data$population, na.rm = TRUE), "\n")
cat("Most populous:", spatial_data$county_name[which.max(spatial_data$population)], "\n")
cat("Least populous:", spatial_data$county_name[which.min(spatial_data$population)], "\n")
cat("Highest density:", spatial_data$county_name[which.max(spatial_data$pop_density)], "\n")

