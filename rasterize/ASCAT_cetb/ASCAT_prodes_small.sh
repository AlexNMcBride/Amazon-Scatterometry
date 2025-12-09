shapes_directory="~/QGIS/cetb_amazon/daily_prodes/small_deforestation"
pixels_file="~/deforestation/ASCAT_cetb/pixels/ASCAT_cetb_pixels_clean.gpkg"
base_raster="~/deforestation/ASCAT_cetb/pixels/ASCAT_cetb_georeferenced.tif"
extent="-17367530.4451613724231720,-6757219.2531846631318331 : 17367164.5822104141116142,6756278.8122193478047848"
overlap_directory="~/deforestation/ASCAT_cetb/prodes_small/overlap"
raster_directory="~/deforestation/ASCAT_cetb/prodes_small/rasters"

start_year=2014
end_year=2020

~/Amazon-Scatterometry/rasterize/overlap_analysis.sh $pixels_file $shapes_directory $overlap_directory $start_year $end_year
~/Amazon-Scatterometry/rasterize/rasterize_overlap.sh $overlap_directory $raster_directory $base_raster $extent

# No PRODES small deforestation data in first year range
# start_year=2001
# end_year=2007

# ~/Amazon-Scatterometry/rasterize/overlap_analysis.sh $pixels_file $shapes_directory $overlap_directory $start_year $end_year
# ~/Amazon-Scatterometry/rasterize/rasterize_overlap.sh $overlap_directory $raster_directory $base_raster $extent