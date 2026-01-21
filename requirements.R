# requirements.R - WSL version
options(repos = c(CRAN = "https://cloud.r-project.org"))

cat("Installing R packages to user directory...\n")

# Create user library if it doesn't exist
user_lib <- path.expand("~/R/library")
if (!dir.exists(user_lib)) {
  dir.create(user_lib, recursive = TRUE)
}

# Add user library to path
.libPaths(c(user_lib, .libPaths()))

cat("Library path:", .libPaths(), "\n\n")

# Install packages
packages <- c("dplyr", "ggplot2", "tidycensus", "tigris", "leaflet", "htmlwidgets")

for (pkg in packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat(paste("Installing", pkg, "...\n"))
    install.packages(pkg, lib = user_lib, dependencies = TRUE)
    cat(paste("✓", pkg, "installed\n"))
  } else {
    cat(paste("✓", pkg, "already installed\n"))
  }
}

# Test
cat("\n=== TEST ===\n")
if (require("dplyr", quietly = TRUE)) {
  cat("✓ dplyr loaded successfully\n")
} else {
  cat("✗ dplyr failed to load\n")
}

cat("\nDone! Run: Rscript scripts/01_fetch_data.R\n")