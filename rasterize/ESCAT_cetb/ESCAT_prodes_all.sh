shapes_directory="~/QGIS/cetb_amazon/daily_prodes/all_causes"
pixels_file="~/deforestation/ESCAT_cetb/pixels/ESCAT_cetb_pixels_clean.gpkg"
base_raster="~/deforestation/ESCAT_cetb/pixels/ESCAT_cetb_georeferenced.tif"
extent="-17367530.4451613724231720,-6757219.2531846631318331 : 17367164.5822104141116142,6756278.8122193478047848"
overlap_directory="~/deforestation/ESCAT_cetb/prodes_all/overlap"
raster_directory="~/deforestation/ESCAT_cetb/prodes_all/rasters"
start_year=1991
end_year=2011

~/Amazon-Scatterometry/rasterize/overlap_analysis.sh $pixels_file $shapes_directory $overlap_directory $start_year $end_year
~/Amazon-Scatterometry/rasterize/rasterize_overlap.sh $overlap_directory $raster_directory $base_raster $extent