The c language program sir2geotiff2.c can convert SIR files into 
geotiff images.  For convenience, all the code required to compile
sir2geotiff2.c is contained in this directory.  A simple make file
is also provided.

Note that you may need to manually modify sir3.h if the byte order
in your machine is not little-endian (e.g., linux, windows).
