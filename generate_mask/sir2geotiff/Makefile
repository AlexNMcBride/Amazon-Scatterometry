#
# make file for sir2geotiff2.c 
#
# ** be sure to edit include/sir3.h to reflect machine/compiler type

CC = gcc
CFLAGS = -I.
LDFLAGS = -lm

all : sir2geotiff2

sir2geotiff2 : sir2geotiff2.c sir_io.c sir_ez.c sir_geom.c
	$(CC) $(CFLAGS) -osir2geotiff2 sir2geotiff2.c sir_io.c sir_ez.c sir_geom.c $(LDFLAGS)

clean :
	rm -f sir2geotiff2 *.o

