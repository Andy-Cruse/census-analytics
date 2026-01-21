# US Census Geospatial Analytics Pipeline

A containerized pipeline for fetching, processing, and visualizing US Census data with geospatial analysis.

## Features
- Fetches 2020 Decennial Census population data via API
- Downloads state boundary shapefiles from US Census TIGER
- Merges demographic and geographic data
- Creates interactive Leaflet maps and static visualizations
- Runs in Docker container for reproducibility

## Quick Start

### 1. Get Census API Key (Free)
Register at: https://api.census.gov/data/key_signup.html
Add to R environment:
```r
usethis::edit_r_environ()
# Add: CENSUS_API_KEY="your_key_here"