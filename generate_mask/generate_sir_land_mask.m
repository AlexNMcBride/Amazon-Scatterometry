function land_mask=generate_sir_land_mask(file_path, output_file_name)

% Load sir data and pixel dimensions
if contains(file_path,".gz")
    [data,head] = loadsirgz(char(file_path));
    [ydim,xdim] = size(data);
else
    [data,head] = loadsir(char(file_path));
    [ydim,xdim] = size(data);
end

% Get longitude and latitude of pixels
land_mask = zeros(ydim,xdim);
alat = zeros(ydim,xdim);
alon = zeros(ydim,xdim);
for x=1:xdim
    for y=1:ydim
        [lon,lat] = pix2latlon1(x,y,head);
        alat(y,x) = lat;
        alon(y,x) = lon;
    end
end

% Check pixels for land
for x=1:xdim
    for y=1:ydim
        ylat = alat(y,x);
        xlon = alon(y,x);
        land_mask(y,x) = is_land(ylat,xlon);
        % if ~is_land(ylat,xlon)
        %     land_mask(y,x) = 0;
        % else
        %     land_mask(y,x) = 1;
        % end
    end
end

% Generate title to designate land mask of region
% Title of sir image provided assumed to contain " of [region]"
land_mask_title_stub = "OSCAT SAm MASK image";
title = sirheadvalue('title',head);
region_string_position = strfind(title, " of");
title_stub = title(region_string_position:strlength(title));
land_mask_title = land_mask_title_stub + title_stub;

head = setsirhead('title', head, land_mask_title);
head = setsirhead('type', head, 'LAND MASK');
head = setsirhead('tag', head, '(C) 2024 BYU MERS Laboratory');
head = setsirhead('crproc', head, 'generate_sir_land_mask.m v1.0');
head = setsirhead('crtime', head, string(datetime));
head = setsirhead('idatatype', head, 1);
% set vmin = 0, vmax = 1
head(50) = 0;
head(51) = 1;

writesir(output_file_name, land_mask, head);
