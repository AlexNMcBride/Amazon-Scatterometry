shapes_directory="/auto/home/mcbride/QGIS/cetb_amazon/daily_deter"
pixels_file="/auto/home/mcbride/deforestation/ESCAT_cetb/pixels/ESCAT_cetb_pixels_clean.gpkg"
base_raster="/auto/home/mcbride/deforestation/ESCAT_cetb/pixels/ESCAT_cetb_georeferenced.tif"
extent="-17367530.4451613724231720,-6757219.2531846631318331 : 17367164.5822104141116142,6756278.8122193478047848"
overlap_directory="/auto/home/mcbride/deforestation/ASCAT_scaled/deter/overlap"
raster_directory="/auto/home/mcbride/deforestation/ASCAT_scaled/deter/rasters"

start_year=2008
end_year=2024

for year in $(seq $start_year $end_year); do
	/auto/home/mcbride/Amazon-Scatterometry/rasterize/rasterize_overlap_by_year.sh $overlap_directory $raster_directory $base_raster $extent  $year > "./deter_logs/deter_rasters_$year.log" &
done
