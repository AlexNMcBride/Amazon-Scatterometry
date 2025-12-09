#!/bin/bash

shapes_directory="/auto/home/mcbride/QGIS/test_rasterize/shapes"
pixels_file="/auto/home/mcbride/QGIS/test_rasterize/pixels/SAm_pixels_clean.gpkg"
base_raster="/auto/home/mcbride/QGIS/test_rasterize/pixels/ASCAT_SAm_land_mask_aligned.tif"
extent="-2900000.0000000000000000,-4200000.0000000000000000 : 2929500.0000000000000000,4032500.0000000000000000"
overlap_directory="/auto/home/mcbride/QGIS/test_rasterize/overlap"
raster_directory="/auto/home/mcbride/QGIS/test_rasterize/rasters"
start_year=1991
end_year=2024

~/Amazon-Scatterometry/rasterize/overlap_analysis.sh $pixels_file $shapes_directory $overlap_directory $start_year $end_year
~/Amazon-Scatterometry/rasterize/rasterize_overlap.sh $overlap_directory $raster_directory $base_raster $extent
