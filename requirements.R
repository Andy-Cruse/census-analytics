# Required R Packages
packages <- c(
  # Data manipulation
  "tidyverse",
  "dplyr",
  # Census API
  "tidycensus",
  "censusapi",       
  # Geospatial
  "sf",              
  "tigris",          
  "leaflet",         
  # Data storage
  "RSQLite",         
  "DBI",
  # Utilities
  "httr",
  "jsonlite",
  "viridis"
)

# Install missing packages
install_if_missing <- function(pkg) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
  }
}
lapply(packages, install_if_missing)
# Verify installations
cat("Required packages installed successfully!\n")