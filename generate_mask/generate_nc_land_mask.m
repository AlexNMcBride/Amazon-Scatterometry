function land_mask=generate_nc_land_mask(file_path, output_file_name, title)
% file_path = "BYU-ASCAT-EASE2_T3.125km-METOP_ASCAT-2014002_2014005-5.3VV-B-SIR-v1.0.nc";
% output_file_name = "ASCAT_cetb_T_landmask.sir";
% title = "ASCAT CETB T MASK image";
% Load nc file
nc = readcetb0(file_path);
head = cetb2sir_head(nc);
data = nc.sir;
xdim = nc.xdim;
ydim = nc.ydim;

land_mask = zeros(xdim,ydim);


% % Load sir data and pixel dimensions

% if contains(file_path,".gz")
%     [data,head] = loadsirgz(char(file_path));
%     [xdim,ydim] = size(data);
% else
%     [data,head] = loadsir(char(file_path));
%     [xdim,ydim] = size(data);
% end

% Get longitude and latitude of pixels
% 
% alat = zeros(xdim,ydim);
% alon = zeros(xdim,ydim);
% for y=1:ydim
%     for x=1:xdim
%         [lon,lat] = pix2latlon(y,x,head);
%         alat(x,y) = lat;
%         alon(x,y) = lon;
%     end
% end

% Check pixels for land
for y=1:ydim
    for x=1:xdim
        % ylat = alat(x,y);
        % xlon = alon(x,y);
        % land_mask(x,y) = is_land(ylat,xlon);
        [lon,lat] = pix2latlon(y,x,head);
        land_mask(x,y) = is_land(lat,lon);
    end
end

% Generate title to designate land mask of region
% Title of sir image provided assumed to contain " of [region]"
land_mask_title_stub = "ASCAT CETB T MASK image";
title = sirheadvalue('title',head);
region_string_position = strfind(title, " of");
title_stub = title(region_string_position:strlength(title));
land_mask_title = land_mask_title_stub + title_stub;

head = setsirhead('title', head, land_mask_title);
head = setsirhead('type', head, 'LAND MASK');
head = setsirhead('tag', head, '(C) 2025 BYU MERS Laboratory');
head = setsirhead('crproc', head, 'generate_nc_land_mask.m v1.0');
head = setsirhead('crtime', head, string(datetime));
head = setsirhead('idatatype', head, 1);
% set vmin = 0, vmax = 1
head(50) = 0;
head(51) = 1;

writesir(output_file_name, land_mask, head);
