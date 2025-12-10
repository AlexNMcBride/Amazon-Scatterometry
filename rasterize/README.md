# Amazon-Scatterometry/rasterize
Shell scripts to convert GIS data from polygons to .tif rasters containing overlap area.
These scripts automate the data processing needed to compare PRODES and DETER polygon data to ERS and ASCAT scatterometer data using QGIS libraries. This is done in two steps:
    1. Overlap analysis. The deforestation polygons for a given day area laid on top of a pre-existing polygon layer matching the pixel footprints of one of the three image types. The resulting polygon file, a .gpkg file with the deforestation image date in the file name, contains the overlap area and percentage for each pixel of the base raster.
    2. Overlap rasterization. The polygon file is then rasterized to a match the pixel footprint corresponding to the specified scatterometer data product. The output is formatted as a .tif image with pixel values representing the percentage of deforestation detected in that area at that date.

Copies of the georeferenced pixel grids and biome masks for the Legal Amazon can be found in the base_rasters directory.