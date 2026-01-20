function [alon,alat]=iease2grid(iopt,thelon,thelat,ascale,bscale)
%
% function [alon,alat]=iease2grid(iopt,thelon,thelat,ascale,bscale)
%
%	computes the inverse "ease2" grid transform
%
%	given image (pixel) coordinates (thelon,thelat) the correpsonding
%       lat,lon (alon,alat) are computed 
%	using the "ease2 grid" (version 2.0) transformation given in IDL
%	source code supplied by MJ Brodzik
%
%	RADIUS EARTH=6378.137 KM (WGS 84)
%	MAP ECCENTRICITY=0.081819190843 (WGS84)
%
%	inputs:
%	  iopt: projection type 8=EASE2 N, 9-EASE2 S, 10=EASE2 T/M
%	  thelon: X coordinate in pixels (can be outside of image)
%	  thelat: Y coordinate in pixels (can be outside of image)
%	  alon, alat: lon, lat (deg) to convert (can be outside of image)
%          ascale and bscale should be integer valued)
%	  ascale: grid scale factor (0..5)  pixel size is (bscale/2^ascale)
%	  bscale: base grid scale index (ind=int(bscale))
%
%         for definitions of isc and ind see ease2_map_info
%
%	outputs:
%	  alon, alat: lon, lat location in deg  (can be outside of image)
%

% written by D. Long  7 Mar 2014
% revised by D. Long 25 Jan 2015 + vectorized

RTD=57.29577951308232;
ind = round(bscale);
isc = round(ascale);

% get base EASE2 map projection parameters
[map_equatorial_radius_m, map_eccentricity, ...
  e2, map_reference_latitude, map_reference_longitude, ...
  map_second_reference_latitude, sin_phi1, cos_phi1, kz, ...
  map_scale, bcols, brows, r0, s0, epsilon] = ease2_map_info(iopt, isc, ind);

e4 = e2 * e2;
e6 = e4 * e2;

% qp is the function q evaluated at phi = 90.0 deg
qp = ( 1.0 - e2 ) * ( ( 1.0 / ( 1.0 - e2 ) ) ...
    - ( 1.0 / ( 2.0 * map_eccentricity ) ) ...
    * log( ( 1.0 - map_eccentricity ) ...
    / ( 1.0 + map_eccentricity ) ) );

x = (thelon - r0 - 0.5) * map_scale;
y = (thelat - 0.5 - s0) * map_scale;
  
switch (iopt)
  case 8   % EASE2 grid north 
    rho2 = ( x .* x ) + ( y .* y );
    arg=1.0 - ( rho2 / ( map_equatorial_radius_m * map_equatorial_radius_m * qp ) );
    %if arg >  1.0, arg=1.0; end;      
    %if arg < -1.0, arg=-1.0; end;
    arg(arg>1.0)=1.0;
    arg(arg<-1.0)=-1.0;
    beta = asin( arg );
    lam = atan2( x, -y );

  case 9   % EASE2 grid south
    rho2 = ( x .* x ) + ( y .* y );
    arg = 1.0 - ( rho2  / ( map_equatorial_radius_m * map_equatorial_radius_m * qp ) );
    %if arg >  1.0, arg=1.0; end;      
    %if arg < -1.0, arg=-1.0; end;
    arg(arg>1.0)=1.0;
    arg(arg<-1.0)=-1.0;
    beta = -asin( arg );
    lam = atan2( x, y );

  case 10  % EASE2 cylindrical
    arg = 2.0 * y * kz / ( map_equatorial_radius_m * qp ) ;
    %if arg >  1.0, arg=1.0; end;      
    %if (arg < -1.0) arg=-1.0; end;
    arg(arg>1.0)=1.0;
    arg(arg<-1.0)=-1.0;
    beta = asin( arg );
    lam = x / ( map_equatorial_radius_m * kz );

  otherwise
    error('*** invalid EASE2 projection specificaion in iease2grid');      
end

phi = beta ...
    + ( ( ( e2 / 3.0 ) + ( ( 31.0 / 180.0 ) * e4 ) ...
    + ( ( 517.0 / 5040.0 ) * e6 ) ) * sin( 2.0 * beta ) ) ...
    + ( ( ( ( 23.0 / 360.0 ) * e4) ...
    + ( ( 251.0 / 3780.0 ) * e6 ) ) * sin( 4.0 * beta ) ) ...
    + ( ( ( 761.0 / 45360.0 ) * e6 ) * sin( 6.0 * beta ) );
   
alat = RTD * phi;
alon = map_reference_longitude + ( RTD*lam );
%while (alon> 180), alon=alon-360.0; end;
%while (alon<-180), alon=alon+360.0; end;
alon(alon>180)=alon(alon>180)-360.0;
alon(alon>180)=alon(alon>180)-360.0;
alon(alon<-180)=alon(alon<-180)+360.0;
alon(alon<-180)=alon(alon<-180)+360.0;


