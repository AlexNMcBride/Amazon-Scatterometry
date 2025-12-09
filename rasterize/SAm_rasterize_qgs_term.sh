# qgis_process run gdal:rasterize --distance_units=meters --area_units=m2 --ellipsoid=EPSG:7030 --INPUT='/auto/home/mcbride/QGIS/cetb_amazon/overlap/ASCAT_SAm/prodes_all_overlap/SAm_prodes_all_overlap_2022.gpkg|layername=SAm_prodes_all_overlap_2022' --FIELD=image_date_2008-05-01_pc --BURN=0 --USE_Z=false --UNITS=0 --WIDTH=1310 --HEIGHT=1850 --EXTENT='-2900000.000000000,2929500.000000000,-4200000.000000000,4032500.000000000 []' --NODATA=0 --OPTIONS= --DATA_TYPE=5 --INVERT=false --EXTRA= --OUTPUT=/auto/home/mcbride/QGIS/cetb_amazon/overlap/test/qgis_process_test.tif

for year in $(seq 2019 1 2023); do
    INPUT_LAYER="/auto/home/mcbride/QGIS/cetb_amazon/overlap/ASCAT_SAm/prodes_all_overlap/SAm_prodes_all_overlap_$year.gpkg"
    OUTPUT_DIR="/auto/home/mcbride/QGIS/cetb_amazon/overlap/ASCAT_SAm/prodes_all_overlap"
    EXTENT="-2900000.000000000,2929500.000000000,-4200000.000000000,4032500.000000000 []"
    WIDTH=1310
    HEIGHT=1850

    # Get field names ending in "pc"
    FIELDS=$(ogrinfo -ro -so -al $INPUT_LAYER | grep  pc | cut -d ':' -f 1)

    for FIELD in $FIELDS; do
        OUTPUT_FILE="$OUTPUT_DIR/SAm_${FIELD}.tif"
        qgis_process run gdal:rasterize \
        --distance_units=meters \
        --area_units=m2 \
        --ellipsoid=EPSG:7030 \
        --INPUT="$INPUT_LAYER" \
        --FIELD="$FIELD" \
        --BURN=0 \
        --USE_Z=false \
        --UNITS=0 \
        --WIDTH=$WIDTH \
        --HEIGHT=$HEIGHT \
        --EXTENT="$EXTENT" \
        --NODATA=0 \
        --OPTIONS= \
        --DATA_TYPE=5 \
        --INVERT=false \
        --EXTRA= \
        --OUTPUT="$OUTPUT_FILE"
    done
done