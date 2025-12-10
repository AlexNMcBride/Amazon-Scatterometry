/**************************************************************************

 Stand alone program to generate a geotiff file from a standard BYU .sir file
 using a self-contained simple geotiff writing routine.

 Geotiff code only supports standard SIR Lambert and Polar Stereographic 
 projections. Conventional tiff will be made for other SIR projections.
 Only supports 8 bit output images.

 written by D.G. Long  12 Feb 2011 at BYU
 revised by D.G. Long  16 Feb 2011 at BYU + added color table, optional args
 revised by D.G. Long  03 Oct 2012 at BYU + fixed polar stereographic case

 compilation requires sir_ez.h sir3.h, sir_io.c, sir_geom.c, and sir_ez.c 

 **************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "sir_ez.h"  /* easy sir routine interface */


float fround(float r)  /* ensure compatibility across compilers */
{	
  int i = (int) r;
  float ret_val = (float) i;
  if (ret_val - r > 0.5) ret_val -= 1.0;
  if (r - ret_val > 0.5) ret_val += 1.0;
  return ret_val;
}


int write_geotiff(char *filename, unsigned char *byte, int nx, int ny,
		  int proj, double pixscale, double uy, double lx,
		  double proj_org, double proj_lat, double proj_lon,
		  int colormap_flag, int *red, int *green, int *blue, 
		  int Geotiff);

int read_colortable(char *name, unsigned char *rtab, unsigned char *gtab, unsigned char *btab, int flag)
{
  FILE *imf;
  int i,r,g,b;
  
  /* printf("Reading input %d color table file '%s'\n",flag,name);*/
  imf = fopen(name,"rb"); 
  if (imf == NULL) {
    fprintf(stderr,"*** ERROR: cannot open color table file: %s\n",name);
    fflush(stderr);
    return(-1);
  } else {
    if (flag == 0) { /* binary color table file (one byte/entry 256 red, then green, etc. */
      if (fread(rtab, sizeof(char), 256, imf) == 0) 
	fprintf(stderr," *** Error reading color table file (r)\n");
      if (fread(gtab, sizeof(char), 256, imf) == 0) 
	fprintf(stderr," *** Error reading color table file (g)\n");
      if (fread(btab, sizeof(char), 256, imf) == 0) 
	fprintf(stderr," *** Error reading color table file (b)\n");
    } else { /* ascii color table file 256 lines with one r,g,b value per line */
      for (i=0; i< 256; i++)
	if (fscanf(imf,"%d %d %d",&r,&g,&b) == EOF) {
	  fprintf(stderr," *** Error reading color table file line %d\n",i);
	  fclose(imf);
	  return(-1);
	} else {	  
	  *(rtab+i) = r;
	  *(gtab+i) = g;
	  *(btab+i) = b;
	}
    }
    fclose(imf);
  }
  return(0);
}


/* main program definition */

int main(int argc, char **argv) {

  /* declare variables */  
  char in_name[512], out_name[512];  
  char *ss, line[512], proj4text[512], filename[512];
  
  sir_head head;
  float *stval, smin, smax, scale, tmp; 
  int ierr;
  int base,i,j,k,nsx,nsy,ix,iy;
  unsigned char *data;
  double pixscale, uy, lx, proj_org, proj_lat, proj_lon; 

  double latitude_of_projection_origin;
  double latitude_of_true_scale;   
  double longitude_of_projection_origin;
  double semimajor_radius;
  double f;
  double semiminor_radius;
  double xgrid_valid_range[2];
  double ygrid_valid_range[2];

  unsigned char rtab[256], gtab[256], btab[256];
  int red[256], green[256], blue[256];  

  /* program flags */
  int gproj=0;
  int ColorMap_flag=0;
  int ColTab_format=1;
  int Show_nodata=0;
  int GeoTiff_flag=1;
  int verbose=1;
  int help=0;

  /* check for optional initial arguments */
  base=0;
  i=1;
  while ( i < argc && argv[i] != NULL && *argv[i] != '\0' && *(argv[i]) == '-') {   /* optional argument */
    base=i;
    if (*(argv[i]+1) == 'b')   /* binary color table */
       ColTab_format = 1;
    if (*(argv[i]+1) == 'v')   /* verbose on */
      verbose = 1;
    if (*(argv[i]+1) == 'q')   /* verbose off */
      verbose = 0;
    if (*(argv[i]+1) == 't')   /* tiff only */
      GeoTiff_flag = 0;
    if (*(argv[i]+1) == 'n')   /* show nodata */
      Show_nodata = 1;
    if (*(argv[i]+1) == 'h')   /* help */
      help = 1;
    if (*(argv[i]+1) == '-' && *(argv[i]+2) == 'h')   /* help */
      help = 1;
    i++;    
  }
  base++;

  if (argc <= base || help) {
    printf("Usage: %s <-b -q -t -n -h> input_filename <output_name <<min max>> <coltabfile>>>\n",argv[0]);
    printf("Converts a BYU .sir file to geotiff or tiff file\n");
    printf(" input_filename : input BYU .sir file\n");
    printf(" output_name : name of output geotiff file [def=filename.tif]\n");
    printf(" min,max : min,max [def=from sir header]\n");
    printf(" coltabfile : ascii color table file [def=grayscale]\n");
    printf("Optional ash arguments\n");
    printf("  -b : binary color table file [def=ascii]\n");
    printf("  -q : quiet [def=verbose]\n");
    printf("  -t : output only standard TIFF file not a geotiff file [def=geotiff]\n");
    printf("  -n : only no-data pixels at lowest output value [def=no-data flag ignored]\n");
    exit(1);
  }

  strcpy(in_name,argv[base]);    /* input file name */
  if (argc>base+1)
    strcpy(out_name,argv[base+1]); /* specified output file name on command line*/
  else
    sprintf(out_name,"%s.tif",in_name); /* def output file name */
 
  /* strip path from input name to create temporary file name */
  strcpy(filename,in_name);
  while ((ss=strstr(filename,"/"))) {  /* strip off path info from input*/
    strcpy(line,++ss);
    strcpy(filename,line);
  }
  
  /* read sir input file */
  sir_init_head(&head);
  if (verbose)
    printf("Reading SIR file %s\n",in_name);
  ierr = get_sir(in_name, &head, &stval);
  if (ierr < 0) {
    fprintf(stdout,"*** Error reading SIR header from file '%s'\n",in_name);
    exit(-1);
  }
  sir_update_head(&head, stval);  /* fix old-style header information */

  /* print sir file header */
  if (verbose)
    print_sir_head(stdout, &head);

  /* default scaling range from sir file header */
  smin=head.v_min;
  smax=head.v_max;

  /* override initial options if appropriate command line arguments are present */
  if (argc > base+2) sscanf(argv[base+2],"%f",&smin); 
  if (argc > base+3) sscanf(argv[base+3],"%f",&smax); 

  if (argc > base+4) { /* read user input color table file */
    if (verbose)
      printf("Reading color table file %s\n",argv[base+4]);
    read_colortable(argv[base+4],rtab,gtab,btab,ColTab_format);
    ColorMap_flag=1;
  } else          /* initialize a gray scale colortable */
    for (j=0;j<256;j++)
      rtab[j]=gtab[j]=btab[j]=(unsigned char) j;

  /* get projection transformation information from BYU SIR file */
  switch (head.iopt) {
  case 5:  /* Polar stereographic */
    if (verbose)
      printf("Polar Stereographic Projection\n");    

    /* precise projection parameters used in generating SIR images */
    semimajor_radius = 6378273.0;
    f = 2.0/0.006693883;
    semiminor_radius = semimajor_radius * sqrt(1.0 - 0.006693883);
    latitude_of_projection_origin = fround(head.ydeg);
    latitude_of_true_scale = fround(head.ydeg);
    longitude_of_projection_origin = fround(head.xdeg);
    latitude_of_projection_origin = 90.0;
     if (fround(head.ydeg) < 0.0)
	latitude_of_projection_origin = -90.0;

    /* for precision, use exact values rather than the quantized 
       values from SIR file header for specific cases, this is really
       not required */
    if (head.iregion == 100) { /* Antarctic */
      latitude_of_projection_origin = -90.0;
      latitude_of_true_scale = -70.0;
      longitude_of_projection_origin = 0.0;
    } else if (head.iregion == 110) { /* Arctic */
      latitude_of_projection_origin = 90.0;
      latitude_of_true_scale = 70.0;
      longitude_of_projection_origin = -45.0;
    } else if (head.iregion == 112) { /* NHe */
      latitude_of_projection_origin = 90.0;
      latitude_of_true_scale = 70.0;
      longitude_of_projection_origin = -45.0;
    } else
      if (verbose)
	printf("* unknown SIR polar stereographic projection region %d\n",head.iregion);
    
    /* image pixel coordinates at LL of SIR pixel*/
    xgrid_valid_range[0] = fround(head.a0*1000.0);
    xgrid_valid_range[1] = fround(head.a0*1000.0)+head.nsx*fround(head.ascale*1000.0);
    ygrid_valid_range[1] = fround(head.b0*1000.0);
    ygrid_valid_range[0] = fround(head.b0*1000.0)+head.nsy*fround(head.bscale*1000.0);
    
    /* for reference, image pixel coordinates at SIR pixel centers */
    /*
     xgrid_valid_range[0] = (head.a0+0.5*head.ascale)*1000.0;
     xgrid_valid_range[1] = fround((head.a0+(head.nsx+0.5)*head.ascale)*1000.0);
     ygrid_valid_range[1] = (head.b0+0.5*head.bscale)*1000.0;
     ygrid_valid_range[0] = fround((head.b0+(head.nsy+0.5)*head.bscale)*1000.0);
    */

    /* for reference image pixel coordinates at UL of SIR pixel*/
    /*
     xgrid_valid_range[0] = head.a0*1000.0;
     xgrid_valid_range[1] = fround((head.a0+head.nsx/head.ascale)*1000.0);
     ygrid_valid_range[1] = fround((head.b0-1.0/head.bscale)*1000.0);
     ygrid_valid_range[0] = fround((head.b0+(float)(head.nsy-1)/head.bscale)*1000.0);
    */

    gproj=2;
    pixscale=(double) fround(head.ascale*1000.0); /* the same for both x and y */
    proj_org=latitude_of_projection_origin;    
    proj_lat=latitude_of_true_scale;
    proj_lon=longitude_of_projection_origin;
    uy=xgrid_valid_range[0];
    lx=ygrid_valid_range[0];
    
    /* generate gdal transformation information string
       note: wgs84 used as initial datum, but some parameters are overridden
       to match values acutally used in creating SIR files */
    sprintf(proj4text,"\"+datum=wgs84 +proj=stere +lat_0=%lf +lat_ts=%lf +lon_0=%lf +k=1 +units=m +no_defs +x_0=0 +y_0=0 +a=%0.3lf +b=%0.3lf\" -a_ullr %0.3lf %0.3lf %0.3lf %0.3lf",latitude_of_projection_origin,latitude_of_true_scale,longitude_of_projection_origin,semimajor_radius,semiminor_radius,xgrid_valid_range[0],ygrid_valid_range[0],xgrid_valid_range[1],ygrid_valid_range[1]);

    break;

  case -1:  /* no projection */
    if (verbose)
      printf("Image only SIR file, no projection information\n");
    if (GeoTiff_flag) {
      printf("*** Conversion of the Lat/Lon SIR projection is not supported by this code\n");
      printf("*** Only a conventional tiff image will be made\n");
      GeoTiff_flag=0;
    }
    gproj=0;
    pixscale=1.0;
    proj_org=0.0;
    proj_lat=0.0;
    proj_lon=0.0;
    uy=0.0;
    lx=0.0;
    break;

  case 0:   /* Lat/lon grid "projection" */
    if (verbose) {
      printf("Lat/Lon grid image\n");    
      if (GeoTiff_flag) {
	printf("*** Conversion of the Lat/Lon SIR projection is not supported by this code\n");
	printf("*** Only a conventional tiff image will be made\n");
	GeoTiff_flag=0;
      }     
    }    
    gproj=0;
    pixscale=1.0;
    proj_org=0.0;
    proj_lat=0.0;
    proj_lon=0.0;
    uy=0.0;
    lx=0.0;
    break;
    
  case 1:   /* Lambert equal area fixed radius projection */
    /* precise projection parameters used in generating SIR images */
    semimajor_radius = 6378000.0;     
    f=0.0;   
    semiminor_radius = semimajor_radius;
    /* fall through next case intended */
  case 2:   /* Lambert equal area local radius projection */
    printf("Lambert Equal Area Projection\n");    
    if (head.iopt == 2) {
      /* precise projection parameters used in generating SIR images */
      semimajor_radius = 6378135.0;     
      f=298.260;   
      semiminor_radius = semimajor_radius * (1.0 - 1.0/f);
    }

    latitude_of_projection_origin = head.ydeg;
    latitude_of_true_scale = head.ydeg;
    longitude_of_projection_origin = head.xdeg;

    /* image pixel coordinates at LL of SIR pixel*/
    xgrid_valid_range[0] = fround(1000.0*head.a0);
    xgrid_valid_range[1] = fround(1000.0*head.a0)+head.nsx*fround(1000.0/head.ascale);
    ygrid_valid_range[1] = fround(1000.0*head.b0);
    ygrid_valid_range[0] = fround(1000.0*head.b0)+head.nsy*fround(1000.0/head.bscale);

    /* set write_geotiff parameters */
    gproj=1;    /* Lambert */
    pixscale=(double) fround(1000.0/head.ascale); /* the same for both x and y */
    proj_org=latitude_of_true_scale;
    proj_lat=latitude_of_projection_origin;      
    proj_lon=longitude_of_projection_origin;
    uy=xgrid_valid_range[0];
    lx=ygrid_valid_range[0];
 
    /* generate gdal transformation information string
       note: wgs84 used as initial datum, but some parameters are overridden
       to match values acutally used in creating SIR files */
    sprintf(proj4text,"\"+datum=wgs84 +proj=laea +lat_0=%lf +lon_0=%lf +k=1 +x_0=0 +y_0=0 +a=%0.3lf +rf=%0.3lf +units=m +no_defs\" -a_ullr %11.3lf %11.3lf %11.3lf %11.3lf",latitude_of_projection_origin,longitude_of_projection_origin,semimajor_radius,f,xgrid_valid_range[0],ygrid_valid_range[0],xgrid_valid_range[1],ygrid_valid_range[1]);
     
    break;

  case 11: /* EASE grid north */
  case 12: /* EASE grid south */
  case 13: /* EASE grid cylindrical */
  default:
    if (verbose)
      printf("EASE projection\n");
    if (GeoTiff_flag) {
      printf("*** Conversion of the EASE projection is not supported by this code\n");
      printf("*** Only a conventional tiff image will be made\n");
      GeoTiff_flag=0;
    }
    gproj=0;
    pixscale=1.0;
    proj_org=0.0;
    proj_lat=0.0;
    proj_lon=0.0;
    uy=0.0;
    lx=0.0;
    break;
  }

  /* image size, note  that SIR images have pixel origin at lower left corner */
  nsx=head.nsx;
  nsy=head.nsy;

  /* create a byte array by scaling the floating point SIR 
     data array to 8 bits, clipping the upper and lower values
     note that this code discards the no_data information */

  /* declare byte array */
  data = (unsigned char *) malloc(sizeof(char) * nsx * nsy);
  if (data == NULL) {
     printf("*** ERROR: temporary image memory allocation failure...\n");
     exit(-1);
  }
  
  if (smin>smax) { /* swath max min if backwards */
    tmp=smax;    
    smax=smin;
    smin=tmp;
  }
  if (smax-smin==0.0) smax=smin+1.0; /* error correction */

  scale=smax-smin;
  if (verbose)
    printf("Image scaling: min=%f max=%f range=%f\n",smin,smax,scale);  
  if (verbose)
    if (Show_nodata) {	
      if (ColorMap_flag)	  
	printf(" Nodata flag shown as lowest color table index\n");
      else
	printf(" Nodata flag shown as black\n");
    }

  scale=255.0/scale;

  /* scale pixels while flipping image array vertically */
  for (iy = 0; iy < nsy; iy++)     
    for (ix = 0; ix < nsx; ix++) {
      j=ix+iy*nsx;  /* conventional row-order */
      i=ix+(nsy-iy-1)*nsx;  /* flipped row-order */
      tmp=(stval[j]-smin)*scale;
      if (Show_nodata) { /* use bottom of color table to indicate no data */
	tmp +=1;
	if (tmp > 255.0) tmp = 255;
	if (tmp < 1.0) tmp = 1;
	if (stval[j]<head.anodata+0.0001) tmp=0;  /* no data value */
      } else {	
	if (tmp > 255.0) tmp = 255;
	if (tmp < 0.0) tmp = 0;
      }
      k = (int) (tmp);
      data[i]=(char) k;
    }

 /* scale 8 bit color table to 16 bits for tiff file */
  for (j=0;j<256;j++) {
    red[j]  =(int) rtab[j] * 256;
    green[j]=(int) gtab[j] * 256;
    blue[j] =(int) btab[j] * 256;
  }

  /* printf("Output color table: %d\n",ColorMap);     
     for (n=0; n<ColorMap; n++)
       printf(" %3d %5d %5d %5d\n",n,red[n],green[n],blue[n]); */

  if (verbose)
    printf("Writing output geotiff to %s\n", out_name);

  /* generate geotiff file */
  ierr=write_geotiff(out_name, data, nsx, nsy, gproj, pixscale,
		     uy, lx, proj_org, proj_lat, proj_lon,
		     ColorMap_flag, red, green, blue, GeoTiff_flag);
  
  if (ierr < 0) {
    printf("*** ERROR writing file %s ***\n",out_name);
    exit(-1);
  }
  if (verbose)
    printf("Wrote geotiff file to %s\n", out_name);
    
  return 0;
}


/*****************************************************************/
/*
 * write_geotiff routine
 *
 * a simple custom, self-contained geotiff writer to support writing
 * *selected* SIR files (Lambert and stereographic only)
 *
 * Note: *very* limited geotiff writing capability
 *
 * written by D.G. Long 12 Feb 2011 at BYU 
 *
 */
/*****************************************************************/


/* write 16 bit integer LSB first */
void fputshort(int w, FILE *fid)
{
  fputc(w & 0xff, fid);
  fputc((w>>8) &0xff,fid);
}

/* write 32 bit integer little endian order */
void fputlong(int w, FILE *fid)
{
  fputc(w & 0xff, fid);
  fputc((w>>8) &0xff,fid);
  fputc((w>>16) &0xff,fid);
  fputc((w>>24) &0xff,fid);
}


/* write double little endian order */
void fputdouble(double w, FILE *fid)
{
  const short isle_var=1;         /* for endian test */
#define ISLE *(char*)&isle_var    /* for endian test */
  unsigned char *x = (unsigned char *) &w;
  int i;

  if (ISLE)
    for (i=0; i<8; i++)
      fputc(x[i], fid);
  else
    for (i=8; i>0; --i)
      fputc(x[i-1], fid);
}

/* main code definition */
int write_geotiff(char *filename, unsigned char *byte, int nx, int ny,
		  int proj, double pixscale, double uy, double lx,
		  double proj_org, double proj_lat, double proj_lon,
		  int ColorMap_flag, int *red, int *green, int *blue, int Geotiff)
/* arguments:
  filename = output file name
  byte = 8 bit array to write to tif image
  nx,ny = size of image array
  proj = image projection
      proj==0 for tiff only 
      proj==1 for Lambert projection in geotiff
      proj==2 for polar stereographic projection in geotiff
  uy,lx = coordinates of upper left corner of projection (ignored if proj==0)
  proj_org = projection origin parameter (not used)
  proj_lat, proj_lon = projection parameters (meaning is projection dependent)
  ColorMap_flag = 0, grayscale, =1, use input red,green,blue values (256 values required).
    Black is represented by [0 0 0], and white is [65535 65535 65535]
  Geotiff =1, create geotiff, =0, create conventional tiff (w/o geotiff headers)
 */
{
  int ImageWidth = nx;
  int ImageLength = ny;

  int bit_depth=8;   /* unsigned 1 byte int, only value supported by this code */  
  int ColorMap=0;    /* set to 0 when not using colormap, set to 256 when using table */  
  int Orientation=1; /* imate orientation 1: Row from Top, Col from Left */

  double ModelPixelScaleTag[3]={0.0, 0.0, 0.0};
  double ModelTiepointTag[6]={0.0, 0.0, 0.0, 0.0, 0.0, 0.0};
  int GeoKeyDirectoryTag[19*4];
  char GeoAsciiParamsTag[256]="", str[100]="";  
  int GeoAsciiOffset = 0;
  double GeoDoubleParamsTag[7]={0.0, 0.0 ,0.0 ,0.0 ,0.0, 0.0, 0.0};  
  int GeoDoubleOffset = 0;
  int NumberOfKeys = 0;
  int PhotometricInterpretation = 1;	/* BlackIsZero */
  int Lambert=0; /* set to zero for Lambert, 1 for polar stereographic */
  int num_entry = 15; 
  int ifd_end = 0;
  int totalcnts = 8;
  int SampleFormat = 1; 

  int n, numpix, v; 
  FILE *fid;

  /* generate TIFF header arrays 
     Note: code is specialized for just Lambert and polar stereographic
     of the type used in BYU .SIR files */

  ModelPixelScaleTag[0]=pixscale;
  ModelPixelScaleTag[1]=pixscale;
  ModelTiepointTag[3]=uy;
  ModelTiepointTag[4]=lx;

  if (proj>0)
    Geotiff=1; /* create a geotiff, default is image-only (no projection) */

  if (proj==1)
    Lambert=1;  /* Lambert */
  else
    Lambert=0;  /* polar stereographic */

  if (ColorMap_flag==1) { 
    ColorMap=256; /* only support 8 bit depth */    
    PhotometricInterpretation = 3;
    num_entry++;
  }

  if (Geotiff) {
    num_entry++;    

    /* start list of Geo keys */
    NumberOfKeys++;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+0] = 1;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+1] = 1;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+2] = 0;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+3] = NumberOfKeys;

    /* Set GTModelTypeGeoKey to 1, 1024 */
    NumberOfKeys++;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+0] = 1024;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+1] = 0;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+2] = 1;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+3] = 1;

    /* Set GTRasterTypeGeoKey to 1, 1025 */
    NumberOfKeys++;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+0] = 1025;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+1] = 0;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+2] = 1; /* RasterPixelIsArea */
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+3] = 1;

    /* Set GTCitationGeoKey to 'unnamed', 1026 */
    NumberOfKeys++;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+0] = 1026;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+1] = 34737;
    strcpy(str,"unnamed|");  
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+2] = strlen(str);
    strncpy(&GeoAsciiParamsTag[GeoAsciiOffset],str,strlen(str));
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+3] = GeoAsciiOffset;
    GeoAsciiOffset += strlen(str);

    /* Set GeographicTypeGeoKey to WGS84, 2048 */
    NumberOfKeys++;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+0] = 2048;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+1] = 0;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+2] = 1;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+3] = 4326; /* GCS_WGS_84 */

    /* Set GeogCitationGeoKey to WGS 84, 2049 */
    NumberOfKeys++;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+0] = 2049;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+1] = 34737;
    strcpy(str,"WGS 84|");  
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+2] = strlen(str);
    strncpy(&GeoAsciiParamsTag[GeoAsciiOffset],str,strlen(str));
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+3] = GeoAsciiOffset;
    GeoAsciiOffset += strlen(str);
  
    /* Set GeogAngularUnitsGeoKey to deg, 2054 */
    NumberOfKeys++;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+0] = 2054;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+1] = 0;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+2] = 1;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+3] = 9102; /* deg */

    if (Lambert) {
      /* Set GeogSemiMajorAxisGeoKey to value used by SIR, 2057 */
      NumberOfKeys++;
      GeoKeyDirectoryTag[(NumberOfKeys-1)*4+0] = 2057;
      GeoKeyDirectoryTag[(NumberOfKeys-1)*4+1] = 34736;
      GeoKeyDirectoryTag[(NumberOfKeys-1)*4+2] = 1;
      GeoDoubleParamsTag[GeoDoubleOffset]=6378135.0; /* SIR-standard for Lambert */
      GeoKeyDirectoryTag[(NumberOfKeys-1)*4+3] = GeoDoubleOffset;
      GeoDoubleOffset++;
    
      /* Set GeogInvFlatteningGeoKey to value used bySIR, 2059 */
      NumberOfKeys++;
      GeoKeyDirectoryTag[(NumberOfKeys-1)*4+0] = 2059;
      GeoKeyDirectoryTag[(NumberOfKeys-1)*4+1] = 34736;
      GeoKeyDirectoryTag[(NumberOfKeys-1)*4+2] = 1;
      GeoDoubleParamsTag[GeoDoubleOffset]=298.260; /* SIR-standard for Lambert */
      GeoKeyDirectoryTag[(NumberOfKeys-1)*4+3] = GeoDoubleOffset;
      GeoDoubleOffset++;
    
      /* Set GeogPrimeMeridianLongGeoKey to 0, 2061 */
      NumberOfKeys++;
      GeoKeyDirectoryTag[(NumberOfKeys-1)*4+0] = 2061;
      GeoKeyDirectoryTag[(NumberOfKeys-1)*4+1] = 34736;
      GeoKeyDirectoryTag[(NumberOfKeys-1)*4+2] = 1;
      GeoDoubleParamsTag[GeoDoubleOffset]=0.0;
      GeoKeyDirectoryTag[(NumberOfKeys-1)*4+3] = GeoDoubleOffset;
      GeoDoubleOffset++;
    }

    /* Set ProjectedCSTypeGeoKey to user, 3072 */
    NumberOfKeys++;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+0] = 3072;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+1] = 0;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+2] = 1;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+3] = 32767; /* user defined */

    /* Set ProjectionGeoKey to user, 3074 */
    NumberOfKeys++;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+0] = 3074;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+1] = 0;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+2] = 1;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+3] = 32767; /* user defined */

    /* Set ProjCoordTransGeoKey to appropriate value, 3075 */
    NumberOfKeys++;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+0] = 3075;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+1] = 0;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+2] = 1;
    if (Lambert)
      GeoKeyDirectoryTag[(NumberOfKeys-1)*4+3] = 10; /* Lambert Equal Area */
    else
      GeoKeyDirectoryTag[(NumberOfKeys-1)*4+3] = 15; /* Polar Stereographic */

    /* Set ProjLinearUnitsGeoKey to m, 3076 */
    NumberOfKeys++;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+0] = 3076;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+1] = 0;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+2] = 1;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+3] = 9001;

    if (!Lambert) { /* polar stereographic only */
      /* Set ProjNatOriginLatGeoKey to appropriate value, 3081 */
      NumberOfKeys++;
      GeoKeyDirectoryTag[(NumberOfKeys-1)*4+0] = 3081;
      GeoKeyDirectoryTag[(NumberOfKeys-1)*4+1] = 34736;
      GeoKeyDirectoryTag[(NumberOfKeys-1)*4+2] = 1;
      GeoDoubleParamsTag[GeoDoubleOffset]=proj_lat;
      GeoKeyDirectoryTag[(NumberOfKeys-1)*4+3] = GeoDoubleOffset;
      GeoDoubleOffset++;
    }
  
    /* Set ProjFalseEastingGeoKey to 0, 3082 */
    NumberOfKeys++;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+0] = 3082;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+1] = 34736;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+2] = 1;
    GeoDoubleParamsTag[GeoDoubleOffset]=0.0;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+3] = GeoDoubleOffset;
    GeoDoubleOffset++;

    /* Set ProjFalseNorthingGeoKey to 0, 3083 */
    NumberOfKeys++;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+0] = 3083;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+1] = 34736;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+2] = 1;
    GeoDoubleParamsTag[GeoDoubleOffset]=0.0;
    GeoKeyDirectoryTag[(NumberOfKeys-1)*4+3] = GeoDoubleOffset;
    GeoDoubleOffset++;

    if (Lambert) { /* Lambert projection */
      /* Set ProjCenterLongGeoKey to appropriate value, 3088 */
      NumberOfKeys++;
      GeoKeyDirectoryTag[(NumberOfKeys-1)*4+0] = 3088;
      GeoKeyDirectoryTag[(NumberOfKeys-1)*4+1] = 34736;
      GeoKeyDirectoryTag[(NumberOfKeys-1)*4+2] = 1;
      GeoDoubleParamsTag[GeoDoubleOffset]=proj_lon;
      GeoKeyDirectoryTag[(NumberOfKeys-1)*4+3] = GeoDoubleOffset;
      GeoDoubleOffset++;
    
      /*  Set ProjCenterLatGeoKey to appropriate value, 3089 */
      NumberOfKeys++;
      GeoKeyDirectoryTag[(NumberOfKeys-1)*4+0] = 3089;
      GeoKeyDirectoryTag[(NumberOfKeys-1)*4+1] = 34736;
      GeoKeyDirectoryTag[(NumberOfKeys-1)*4+2] = 1;
      GeoDoubleParamsTag[GeoDoubleOffset]=proj_lat;
      GeoKeyDirectoryTag[(NumberOfKeys-1)*4+3] = GeoDoubleOffset;
      GeoDoubleOffset++;
    
    } else { /* polar stereographic projection */
      
      /* Set ProjScaleAtNatOriginGeoKey to 1, 3092 */
      NumberOfKeys++;
      GeoKeyDirectoryTag[(NumberOfKeys-1)*4+0] = 3092;
      GeoKeyDirectoryTag[(NumberOfKeys-1)*4+1] = 34736;
      GeoKeyDirectoryTag[(NumberOfKeys-1)*4+2] = 1;
      GeoDoubleParamsTag[GeoDoubleOffset]=1.0;
      GeoKeyDirectoryTag[(NumberOfKeys-1)*4+3] = GeoDoubleOffset;
      GeoDoubleOffset++;
    
      /* Set ProjStraightVertPoleLongGeoKey to appropriate value, 3095 */
      NumberOfKeys++;
      GeoKeyDirectoryTag[(NumberOfKeys-1)*4+0] = 3095;
      GeoKeyDirectoryTag[(NumberOfKeys-1)*4+1] = 34736;
      GeoKeyDirectoryTag[(NumberOfKeys-1)*4+2] = 1;
      GeoDoubleParamsTag[GeoDoubleOffset]=proj_lon;
      GeoKeyDirectoryTag[(NumberOfKeys-1)*4+3] = GeoDoubleOffset;
      GeoDoubleOffset++;
    }
  
    /* since always using ModelPixelScaleTag and ModelTiepointTag */
    num_entry++; num_entry++;
    if (GeoAsciiOffset > 0)
      num_entry++;
    if (GeoDoubleOffset > 0)
      num_entry++;
  }

   ifd_end = 8 + ((bit_depth/8)*ImageLength*ImageWidth) + 2 + num_entry*12 + 4;

  /* Now ready to write the TIFF file*/

   /* open and start writing file */
   fid = fopen(filename, "wb");   
   if (fid == NULL) {
     printf("*** Cannot create file '%s'\n", filename);
     return(-1);
   }

   /* write header */
   fwrite("II",1,2,fid); /* little-endian flag */
   fputshort(42,fid);    /* TIFF signature */
   totalcnts += (bit_depth/8)*ImageLength*ImageWidth;   
   fputlong(totalcnts,fid); /* IFD offset */

   /* Write image data (input array already in correct pixel order) */
   numpix=ImageWidth*ImageLength;   
   switch (bit_depth) {       
   case 8: /* only case supported */
     for (n=0; n<numpix; n++) {
       v=byte[n];
       fputc(v & 0xff,fid);
     }
     break;
     /*
       case 16:
       for (n=0; n<numpix; n++) {
       v=byte[n];
       fputshort(v,fid);
       }
       break;       
       case 32:
       for (n=0;n<numpix; n++) {
	 v=byte[n];
	 fputlong(v,fid);
       }
       break;
       */
   default:
     printf("*** this bit_depth %d not supported\n",bit_depth);
     return(-1);
     break;
   }

   /* TIFF header entries */
   fputshort(num_entry,fid);

   /* Entry 1, size */
   fputshort(256, fid);
   fputshort(3, fid);
   fputlong(1, fid);
   fputshort(ImageWidth, fid);
   fputshort(0,fid);   

   /* Entry 2, size */
   fputshort(257, fid);
   fputshort(3, fid);
   fputlong(1, fid);
   fputshort(ImageLength, fid);
   fputshort(0,fid);   

   /* Entry 3, bits per sample */
   fputshort(258, fid);
   fputshort(3, fid);
   fputlong(1, fid);
   fputshort(bit_depth, fid); /* bits per sample */
   fputshort(0,fid);   

   /* Entry 4, compression  */
   fputshort(259, fid);
   fputshort(3, fid);
   fputlong(1, fid);
   fputshort(1, fid); /* (uncompressed) */
   fputshort(0,fid);   

   /* Entry 5, PhotometricInterpretation */
   fputshort(262, fid);
   fputshort(3, fid);
   fputlong(1, fid);
   fputshort(PhotometricInterpretation, fid); /* 3=palette, 1=black is zero */
   fputshort(0,fid);   

   /* Entry 6 StripOffsets*/
   fputshort(273, fid);
   fputshort(4, fid);
   fputlong(ImageLength, fid);
   fputlong(ifd_end, fid);
   ifd_end = ifd_end + ImageLength*4;

   /* Entry 7 Orientation */
   fputshort(274, fid);
   fputshort(3, fid);
   fputlong(1, fid);
   fputshort(Orientation, fid);
   fputshort(0,fid);

   /* Entry 8 samples per pixels (1)*/
   fputshort(277, fid);
   fputshort(3, fid);
   fputlong(1, fid);
   fputshort(1, fid);
   fputshort(0,fid);

   /* Entry 9 rows per strip (1)*/
   fputshort(278, fid);
   fputshort(3, fid);
   fputlong(1, fid);
   fputshort(1, fid);
   fputshort(0,fid);

   /* Entry 10 */
   fputshort(279, fid);
   fputshort(4, fid);
   fputlong(ImageLength, fid);
   fputlong(ifd_end, fid);
   ifd_end = ifd_end + ImageLength*4;

   /* Entry 11 XResolution */
   fputshort(282, fid);
   fputshort(5, fid);
   fputlong(1, fid);
   fputlong(ifd_end, fid);
   ifd_end = ifd_end + 2*4;

   /* Entry 12 YResolution */
   fputshort(283, fid);
   fputshort(5, fid);
   fputlong(1, fid);
   fputlong(ifd_end, fid);
   ifd_end = ifd_end + 2*4;

   /* Entry 13 PlanarConfiguration */
   fputshort(284, fid);
   fputshort(3, fid);
   fputlong(1, fid);
   fputshort(1, fid);
   fputshort(0,fid);   

   /* Entry 14 ResolutionUnit */
   fputshort(296, fid);
   fputshort(3, fid);
   fputlong(1, fid);
   fputshort(2, fid);
   fputshort(0,fid);   

   if (ColorMap > 0) {
     fputshort(320, fid);
     fputshort(3, fid);
     fputlong(ColorMap*3, fid);
     fputlong(ifd_end, fid);
     ifd_end = ifd_end + ColorMap*2*3;
   }

   switch (bit_depth) {
   case 8: /* only case supported */
     SampleFormat = 1;
     break;     
   case 16:
     SampleFormat = 2;
     if (ColorMap) SampleFormat=1;     
     break;     
   case 32:
     SampleFormat = 3;
     break;
   }

   /* Entry 15 sampleformat */
   fputshort(339, fid);
   fputshort(3, fid);
   fputlong(1, fid);
   fputshort(SampleFormat, fid);
   fputshort(0,fid);

   if (Geotiff) {   /* geotiff stuff */
       
     /* ModelPixelScaleTag */
     fputshort(33550, fid);
     fputshort(12, fid);
     fputlong(3, fid);
     fputlong(ifd_end, fid);
     ifd_end += 3*8;

     /* ModelTiepointTag */
     fputshort(33922, fid);
     fputshort(12, fid);
     fputlong(6, fid);
     fputlong(ifd_end, fid);
     ifd_end += 6*8;

     /* GeoKeyDirectoryTag */
     fputshort(34735, fid);
     fputshort(3, fid);
     fputlong(4*NumberOfKeys, fid);
     fputlong(ifd_end, fid);
     ifd_end += 2*4*NumberOfKeys;

     if (GeoDoubleOffset > 0) {
       fputshort(34736, fid);  /* GeoDoubleParamsTag */
       fputshort(12, fid);
       fputlong(GeoDoubleOffset, fid);
       fputlong(ifd_end, fid);
       ifd_end += 8*GeoDoubleOffset;     
     }

     if (GeoAsciiOffset > 0) {
       GeoAsciiParamsTag[GeoAsciiOffset++]='\0'; /* NULL string ending */
       fputshort(34737, fid);  /* GeoAsciiParamsTag */
       fputshort(2, fid);
       fputlong(GeoAsciiOffset, fid);
       fputlong(ifd_end, fid);
       ifd_end += GeoAsciiOffset;     
     }
   }
   
   fputlong(0,fid);    /* terminate IFD list */
   fputshort(bit_depth,fid); /* 258 */
   fputshort(0,fid);   /* apparently extra, but needed here */

   for (n=1; n<ImageLength; n++)
     fputlong(n*ImageWidth*(bit_depth/8)+8, fid); /* StripOffsets 273 */
   for (n=0; n<ImageLength; n++)
     fputlong(ImageWidth*(bit_depth/8), fid);     /* StripByteCounts 279 */
   fputlong(96, fid); /* write XResolution (96 dpi) 282 */
   fputlong(1, fid);   
   fputlong(96, fid); /* write YResolution (96 dpi) 283 */
   fputlong(1, fid);   

   if (ColorMap > 0) {      /* color table values 320 */
     for (n=0; n<ColorMap; n++)
       fputshort(red[n],fid);
     for (n=0; n<ColorMap; n++)
       fputshort(green[n],fid);
     for (n=0; n<ColorMap; n++)
       fputshort(blue[n],fid);
   }
   
   if (SampleFormat > 2)
     fputshort(SampleFormat,fid); /* 339 */

   if (Geotiff) {   /* add geotiff arrays */
     for (n=0; n<3; n++)
       fputdouble(ModelPixelScaleTag[n],fid);   /* 33550 */
     for (n=0; n<6; n++)
       fputdouble(ModelTiepointTag[n],fid);     /* 33922 */

     GeoKeyDirectoryTag[3] = NumberOfKeys-1;
     for (n=0; n<NumberOfKeys*4; n++)
       fputshort(GeoKeyDirectoryTag[n],fid);    /* 34735 */   
     for (n=0; n<GeoDoubleOffset; n++)
       fputdouble(GeoDoubleParamsTag[n], fid);  /* 34736 */
     for (n=0; n<GeoAsciiOffset; n++)
       fputc(GeoAsciiParamsTag[n], fid);        /* 34737 */
   }   

   /* close file */
   fclose(fid);
   return(0);
}


