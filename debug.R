cat("=== R Environment in Docker ===\n")
cat("R version:", R.version.string, "\n")
cat("\nLibrary paths:\n")
print(.libPaths())
cat("\nFirst 20 installed packages:\n")
ip <- installed.packages()
print(ip[1:20, c("Package", "Version")])
cat("\nLooking for tidycensus...\n")
if ("tidycensus" %in% rownames(ip)) {
  cat("✓ tidycensus found at version:", ip["tidycensus", "Version"], "\n")
} else {
  cat("✗ tidycensus NOT found\n")
  cat("Searching filesystem...\n")
  paths <- .libPaths()
  for (path in paths) {
    pkg_path <- file.path(path, "tidycensus")
    if (file.exists(pkg_path)) {
      cat("Found tidycensus directory at:", pkg_path, "\n")
    }
  }
}
