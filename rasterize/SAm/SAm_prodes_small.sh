shapes_directory="~/QGIS/cetb_amazon/daily_prodes/small_deforestation"
pixels_file="~/deforestation/SAm/pixels/SAm_pixels_clean.gpkg"
base_raster="~/deforestation/SAm/pixels/ASCAT_SAm_land_mask_aligned.tif"
extent="-2900000.0000000000000000,-4200000.0000000000000000 : 2929500.0000000000000000,4032500.0000000000000000"
overlap_directory="~/deforestation/SAm/prodes_small/overlap"
raster_directory="~/deforestation/SAm/prodes_small/rasters"
start_year=2007
end_year=2022

~/Amazon-Scatterometry/rasterize/overlap_analysis.sh $pixels_file $shapes_directory $overlap_directory $start_year $end_year
~/Amazon-Scatterometry/rasterize/rasterize_overlap.sh $overlap_directory $raster_directory $base_raster $extent