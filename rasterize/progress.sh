deter_files=$(ls /auto/home/mcbride/QGIS/cetb_amazon/daily_deter/ | wc -l)
d_overlap_files=$(ls /auto/home/mcbride/deforestation/ASCAT_scaled/deter/overlap/ | wc -l)
d_raster_files=$(ls /auto/home/mcbride/deforestation/ASCAT_scaled/deter/rasters/ | wc -l)
prodes_files=$(ls /auto/home/mcbride/QGIS/cetb_amazon/daily_prodes/all_causes/ | wc -l)
p_overlap_files=$(ls /auto/home/mcbride/deforestation/ASCAT_scaled/prodes_all/overlap/ | wc -l)
p_raster_files=$(ls /auto/home/mcbride/deforestation/ASCAT_scaled/prodes_all/rasters/ | wc -l)

ad_overlap_files=$(ls /auto/home/mcbride/deforestation/ASCAT_cetb/deter/overlap/ | wc -l)
ad_raster_files=$(ls /auto/home/mcbride/deforestation/ASCAT_cetb/deter/rasters/ | wc -l)
ap_overlap_files=$(ls /auto/home/mcbride/deforestation/ASCAT_cetb/prodes_all/overlap/ | wc -l)
ap_raster_files=$(ls /auto/home/mcbride/deforestation/ASCAT_cetb/prodes_all/rasters/ | wc -l)

echo "ASCAT scaled DETER progress:"
echo "Overlap: $d_overlap_files/$deter_files"
echo "Rasters: $d_raster_files/$deter_files"
echo "ASCAT scaled PRODES progress:"
echo "Overlap: $p_overlap_files/$prodes_files"
echo "Rasters: $p_raster_files/$prodes_files"
echo "ASCAT cetb DETER progress:"
echo "Overlap: $ad_overlap_files/$deter_files"
echo "Rasters: $ad_raster_files/$deter_files"
echo "ASCAT cetb PRODES progress:"
echo "Overlap: $ap_overlap_files/$prodes_files"
echo "Rasters: $ap_raster_files/$prodes_files"
