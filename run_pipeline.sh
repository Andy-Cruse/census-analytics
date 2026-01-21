#!/usr/bin/env bash

echo "=== US Census Pipeline ==="
echo "Starting at: $(date)"
echo ""

# Show current directory
echo "Working in: $(pwd)"
echo ""

# Step 1: Install packages
echo "--- Step 1: Installing R packages ---"
if command -v Rscript >/dev/null 2>&1; then
    Rscript requirements.R
else
    echo "ERROR: Rscript not found"
    exit 1
fi
echo ""

# Step 2: Fetch data
echo "--- Step 2: Fetching data ---"
if [ -f "scripts/01_fetch_data.R" ]; then
    Rscript scripts/01_fetch_data.R
else
    echo "ERROR: scripts/01_fetch_data.R not found"
    exit 1
fi
echo ""

# Step 3: Create visualizations
echo "--- Step 3: Creating visualizations ---"
if [ -f "scripts/02_create_map.R" ]; then
    Rscript scripts/02_create_map.R
else
    echo "ERROR: scripts/02_create_map.R not found"
    exit 1
fi
echo ""

echo "=== Pipeline Complete ==="
echo "Finished at: $(date)"
echo ""
echo "Output files:"
find output -type f 2>/dev/null | head -10
