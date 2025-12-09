#!/bin/bash

pixels_file=$1
pixels_layer=$(basename $pixels_file .gpkg)
shapes_directory=$2
overlap_directory=$3
start_year=$4
end_year=$5

echo "Pixels: $pixels_file"
echo "Pixels layer: $pixels_layer"
echo "Shapes: $shapes_directory"
echo "Overlap: $overlap_directory"

mkdir -p $overlap_directory

for shape in $(find $shapes_directory -name "*.gpkg" -o -name "*.shp" -type f); do
    base=$(basename $shape)
    shape_basename=$(echo $base | cut -d '.' -f 1)
    year=$(echo $shape_basename | grep -oE '[0-9]{4}')
    if (( $year >= $start_year && $year <= $end_year)); then
        overlap_file="$overlap_directory/${shape_basename}_overlap.gpkg"
        echo "Overlap file: $overlap_file"
        qgis_process run native:calculatevectoroverlaps --distance_units=meters --area_units=m2 --ellipsoid=EPSG:7030 --INPUT="$pixels_file" --LAYERS=$shape --OUTPUT=$overlap_file
    fi
done