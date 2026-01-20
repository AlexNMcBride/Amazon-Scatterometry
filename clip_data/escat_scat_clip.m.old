% ESCAT box: y = (876,1445), x = (1550,2107)
% box - min y, max y, min x, max x
box = [876, 1445, 1550, 2107];
biome_clip_path = "/auto/home/mcbride/programs/tools/biome_clip";
mask_file = "~/Amazon-Scatterometry/base_rasters/ESCAT_cetb_biome_mask.tif";
biome=readgeoraster(mask_file);
mask = (biome ~= 0);

% ERS-1 6 day
start_year = 1991;
start_day = 213;
end_year = 1996;
end_day = 154;
ers_num = 1;
length = 6;
output = sprintf("/auto/home/mcbride/programs/tools/biome_clip/ers%d_%d_day_scat.mat",ers_num,length);

scat_filenames = [];
for year = start_year:end_year
    if year == start_year
        start = start_day;
    else
        start = 1;
    end
    if year == end_year
        stop = end_day;
    else
        stop = 365;
    end
    scat_filenames = [scat_filenames get_escat_cetb_file_names(year,start,stop,ers_num,'T',length)];
end
scat_filenames = sort(scat_filenames);

clips = [];
num_files = size(scat_filenames);
for i=1:num_files(2)
    file_path = scat_filenames(i);
    [path, name, ext] = fileparts(file_path);
    nc = readcetb0(file_path);
    % head = cetb2sir_head(nc);
    img = nc.sir;
    sigma0 = img .* mask;
    clip = sigma0(box(1):box(2),box(3):box(4));
    % get image date
    name = split(name,'-');
    dates = name(5);
    lenstr = split(dates,'_');
    startstr = lenstr(1);
    year = str2num(extractBefore(startstr,5));
    jul_date = str2num(extractAfter(startstr,4));
    [month, day] = doy2date(jul_date,year);
    time = datetime(year,month,day);
    % save to data structure
    clip_data = struct('date', time, 'length', length, 'img', clip);
    clips = [clips clip_data];
end
save(output, 'clips', '-v7.3');

% ERS-1 18 day
start_year = 1991;
start_day = 213;
end_year = 1996;
end_day = 154;
ers_num = 1;
length = 18;
output = sprintf("/auto/home/mcbride/programs/tools/biome_clip/ers%d_%d_day_scat.mat",ers_num,length);

scat_filenames = [];
for year = start_year:end_year
    if year == start_year
        start = start_day;
    else
        start = 1;
    end
    if year == end_year
        stop = end_day;
    else
        stop = 365;
    end
    scat_filenames = [scat_filenames get_escat_cetb_file_names(year,start,stop,ers_num,'T',length)];
end
scat_filenames = sort(scat_filenames);
clips = [];
num_files = size(scat_filenames);
for i=1:num_files(2)
    file_path = scat_filenames(i);
    [path, name, ext] = fileparts(file_path);
    nc = readcetb0(file_path);
    % head = cetb2sir_head(nc);
    img = nc.sir;
    sigma0 = img .* mask;
    clip = sigma0(box(1):box(2),box(3):box(4));
    % get image date
    name = split(name,'-');
    dates = name(5);
    lenstr = split(dates,'_');
    startstr = lenstr(1);
    year = str2num(extractBefore(startstr,5));
    jul_date = str2num(extractAfter(startstr,4));
    [month, day] = doy2date(jul_date,year);
    time = datetime(year,month,day);
    % save to data structure
    clip_data = struct('date', time, 'length', length, 'img', clip);
    clips = [clips clip_data];
end
save(output, 'clips', '-v7.3');

% ERS-2 6 day
start_year = 1996;
start_day = 86;
end_year = 2011;
end_day = 185;
ers_num = 2;
length = 6;
output = sprintf("/auto/home/mcbride/programs/tools/biome_clip/ers%d_%d_day_scat.mat",ers_num,length);

scat_filenames = [];
for year = start_year:end_year
    if year == start_year
        start = start_day;
    else
        start = 1;
    end
    if year == end_year
        stop = end_day;
    else
        stop = 365;
    end
    scat_filenames = [scat_filenames get_escat_cetb_file_names(year,start,stop,ers_num,'T',length)];
end
scat_filenames = sort(scat_filenames);
clips = [];
num_files = size(scat_filenames);
for i=1:num_files(2)
    file_path = scat_filenames(i);
    [path, name, ext] = fileparts(file_path);
    nc = readcetb0(file_path);
    % head = cetb2sir_head(nc);
    img = nc.sir;
    sigma0 = img .* mask;
    clip = sigma0(box(1):box(2),box(3):box(4));
    % get image date
    name = split(name,'-');
    dates = name(5);
    lenstr = split(dates,'_');
    startstr = lenstr(1);
    year = str2num(extractBefore(startstr,5));
    jul_date = str2num(extractAfter(startstr,4));
    [month, day] = doy2date(jul_date,year);
    time = datetime(year,month,day);
    % save to data structure
    clip_data = struct('date', time, 'length', length, 'img', clip);
    clips = [clips clip_data];
end
save(output, 'clips', '-v7.3');

% ERS-2 18 day
start_year = 1996;
start_day = 86;
end_year = 2011;
end_day = 185;
ers_num = 2;
length = 18;
output = sprintf("/auto/home/mcbride/programs/tools/biome_clip/ers%d_%d_day_scat.mat",ers_num,length);

scat_filenames = [];
for year = start_year:end_year
    if year == start_year
        start = start_day;
    else
        start = 1;
    end
    if year == end_year
        stop = end_day;
    else
        stop = 365;
    end
    scat_filenames = [scat_filenames get_escat_cetb_file_names(year,start,stop,ers_num,'T',length)];
end
scat_filenames = sort(scat_filenames);
clips = [];
num_files = size(scat_filenames);
for i=1:num_files(2)
    file_path = scat_filenames(i);
    [path, name, ext] = fileparts(file_path);
    nc = readcetb0(file_path);
    % head = cetb2sir_head(nc);
    img = nc.sir;
    sigma0 = img .* mask;
    clip = sigma0(box(1):box(2),box(3):box(4));
    % get image date
    name = split(name,'-');
    dates = name(5);
    lenstr = split(dates,'_');
    startstr = lenstr(1);
    year = str2num(extractBefore(startstr,5));
    jul_date = str2num(extractAfter(startstr,4));
    [month, day] = doy2date(jul_date,year);
    time = datetime(year,month,day);
    % save to data structure
    clip_data = struct('date', time, 'length', length, 'img', clip);
    clips = [clips clip_data];
end
save(output, 'clips', '-v7.3');