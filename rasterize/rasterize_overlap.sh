#!/bin/bash

overlap_directory=$1
raster_directory=$2
base_raster=$3

# xmin=$(gdalinfo $base_raster | grep "Lower Left" | cut -d '(' -f 2 | cut -d ',' -f 1)
# xmax=$(gdalinfo $base_raster | grep "Upper Right" | cut -d '(' -f 2 | cut -d ',' -f 1)
# ymin=$(gdalinfo $base_raster | grep "Lower Right" | cut -d ',' -f 2 | cut -d ')' -f 1)
# ymax=$(gdalinfo $base_raster | grep "Upper Left" | cut -d ' ' -f 5 | cut -d ')' -f 1)
extent=$4

width=$(gdalinfo "$base_raster" | grep 'Size is' | awk '{print $3}' | cut -d ',' -f 1)
height=$(gdalinfo "$base_raster" | grep 'Size is' | awk '{print $4}')

mkdir -p $raster_directory

for overlap in $overlap_directory/*.gpkg; do
        layername=$(basename $overlap .gpkg)
        output_file="$raster_directory/${layername}.tif"
        field="${layername%_overlap}"_pc
        input="$overlap|layername=$layername"
        qgis_process run gdal:rasterize \
        --distance_units=meters \
        --area_units=m2 \
        --ellipsoid=EPSG:7030 \
        --INPUT=$input \
        --FIELD=$field \
        --BURN=0 \
        --USE_Z=false \
        --UNITS=0 \
        --WIDTH=$width \
        --HEIGHT=$height \
        --NODATA=0 \
        --OPTIONS= \
        --DATA_TYPE=5 \
        --INVERT=false \
        --EXTRA= \
        --OUTPUT="$output_file"
done

# qgis_process run gdal:rasterize --distance_units=meters --area_units=m2 --ellipsoid=PARAMETER:6378135:6356750.52001609373837709 --INPUT='/auto/home/mcbride/QGIS/test_rasterize/overlap/2007_accumulated_deforestation_overlap.gpkg|layername=2007_accumulated_deforestation_overlap' --FIELD=2007_accumulated_deforestation_pc --BURN=0 --USE_Z=false --UNITS=0 --WIDTH=1310 --HEIGHT=1850 --EXTENT='-2900000.000000000,2929500.000000000,-4200000.000000000,4032500.000000000 []' --NODATA=0 --OPTIONS= --DATA_TYPE=5 --INVERT=false --EXTRA= --OUTPUT="$output_file"