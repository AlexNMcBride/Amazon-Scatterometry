function cetb=readcetb0(filename,opt)
%
% cetb=readcetb(filename <,option>)
%
%  inputs: filename
%          ioption : (numeric) array read option (may be "or"-ed together)
%               0 = all (same as 4095)
%	        1 = (sir) TB/Sigma0/sig (A)* 
%	        2 = (num) Number of measurements*
%	        4 = (inc) Incidence angle*
%	        8 = (std) standard deviation*
%	       16 = (time) time*
%	       32 = (slope) TB/Sigma0 slope (B)
%	       64 = (ave) AVE TB/Sigma0 (A)
%	      128 = (aveslope) AVE TB/Sigma0 slope (B)
%	      256 = (A1) Azimuth modulation amplitude (A1)
%	      512 = (P1) Azimuth modulation phase (P1)
%	     1024 = (A2) Azimuth modulation amplitude (A2)
%	     2048 = (P1) Azimuth modulation phase (P2)
%          ioption : (character) name of nc variable array
%
% * all CETB files should ahve these variables.  The other are optional.
%
% matlab routine to read contents of a CETB .NC file into a matlab
% structure with options to control which variablearrays read.
%

% written by DGL at BYU 11 Mar 2017
% Revised by DGL at BYU  1 Jan 2022
% Revised by DGL at BYU 27 Jun 2022 + variable name options

vopt=[];
ioption=0;
if nargin>1
  if isnumeric(opt)
    ioption=opt;
  else
    ioption=4096;
    vname=opt;
  end
end

isTB=0;
cetb=[];
if exist(filename,'file')==2  % if file exists, process

  ncid=netcdf.open(filename,'NC_NOWRITE');
  if ncid==0
    disp('**** could not open file for reading');
    return;
  end
  
  % determine basename: see if TB, Sigma0, or sig arrays defined
  try
    varid = netcdf.inqVarID(ncid,'TB');
    basename='TB';
    isTB=1;
  catch
    try
      varid = netcdf.inqVarID(ncid,'Sigma0');
      basename='Sigma0';
      isTB=2;
    catch % if not, check for sig array
      try
        varid = netcdf.inqVarID(ncid,'sig');
	basename='sig';
	isTB=3;
      catch
	message('*** standard CETB file basename (TB, Sigma0, sig) not found');
	netcdf.close(ncid);
	return;
      end
    end
  end
 
  % note intended transpose 
  [dimname,cetb.xdim]=netcdf.inqDim(ncid,1);
  [dimname,cetb.ydim]=netcdf.inqDim(ncid,2);

  % get requested variable arrays
  if ioption==4096 % use input variable name
    try
      varid = netcdf.inqVarID(ncid,vname);
      netcdf.close(ncid);
      cetb.(vname)=ncread(filename,vname)';
    catch
      %message(sprintf('*** requested varible %s not found',vname));
      netcdf.close(ncid);
      return;
    end
  else
    netcdf.close(ncid);  
  end

  % numeric cases
  if ioption==0 | mod(ioption,2)==1
    cetb.sir=ncread(filename,basename)'; %*sf+off;
  end
  if ioption==0 | mod(ioption/2,2)==1
    cetb.num=ncread(filename,[basename,'_num_samples'])';
  end  
  if ioption==0 | mod(ioption/4,2)==1
    try 
      cetb.inc=ncread(filename,'angle_of_incidence')'; %*sf+off;
    catch
      cetb.inc=ncread(filename,'Incidence_angle')'; %*sf+off;
    end
  end
  if ioption==0 | mod(ioption/8,2)==1
    cetb.std=ncread(filename,[basename,'_std_dev'])'; %*sf+off;
  end  
  if ioption==0 | mod(ioption/16,2)==1
    cetb.time=ncread(filename,[basename,'_time'])';
  end
  if ioption==0 | mod(ioption/32,2)==1
    try
      cetb.slope=ncread(filename,[basename,'_slope'])';
    catch
      disp(['*** could not read slope ',basename,'_slope']);
    end
  end
  if ioption==0 | mod(ioption/64,2)==1
    try   
      cetb.ave=ncread(filename,[basename,'_ave'])';
    catch
    end
  end
  if ioption==0 | mod(ioption/128,2)==1
    try
      cetb.slope_ave=ncread(filename,[basename,'_slope_ave'])';
    catch
    end
  end
  if ioption==0 | mod(ioption/256,2)==1
    try   
      cetb.A1=ncread(filename,'Az_mod1_amp')';
    catch
    end
  end
  if ioption==0 | mod(ioption/512,2)==1
    try   
      cetb.P1=ncread(filename,'Az_mod1_ang')';
    catch
    end
  end
  if ioption==0 | mod(ioption/1024,2)==1
    try   
      cetb.A2=ncread(filename,'Az_mod2_amp')';
    catch
    end
  end
  if ioption==0 | mod(ioption/2048,2)==1
    try   
      cetb.P2=ncread(filename,'Az_mod2_ang')';
    catch
    end
  end

  cetb.filename=filename;
  cetb.basename=basename;
  cetb.isTB=isTB;
  
  % get key global attributes using file reads
  cetb.start_time=ncread(filename,'time');  % single day value
  NC_GLOBAL='/';
  cetb.instrument=ncreadatt(filename,NC_GLOBAL,'instrument');
  cetb.platform=ncreadatt(filename,NC_GLOBAL,'platform');
  cetb.tstart=ncreadatt(filename,NC_GLOBAL,'time_coverage_start');
  cetb.tstop=ncreadatt(filename,NC_GLOBAL,'time_coverage_end');
  cetb.xres=ncreadatt(filename,NC_GLOBAL,'geospatial_x_resolution');
  cetb.yres=ncreadatt(filename,NC_GLOBAL,'geospatial_y_resolution');
  cetb.time_reference=ncreadatt(filename,'time','units');   
  cetb.fpol=ncreadatt(filename,basename,'frequency_and_polarization');  
  
  try
    cetb.tdiv=ncreadatt(filename,basename,'temporal_division');
    if cetb.tdiv(1)=='A' | cetb.tdiv(1)=='D'  % ET2
      cetb.lat_org=0.0;
      cetb.tlocal_start=0.0;
      cetb.tlocal_end=1440.0;
    else % E2N or E2S
      cetb.lat_org=ncreadatt(filename,'crs','latitude_of_projection_origin');
      cetb.tlocal_start=ncreadatt(filename,basename,'temporal_division_local_start_time');
      cetb.tlocal_end=ncreadatt(filename,basename,'temporal_division_local_end_time');
    end
  catch
  end

else % file not found
  message(['*** file not found',filename]);
end

