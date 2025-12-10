% ESCAT box: y = (876,1445), x = (1550,2107)
% box - min y, max y, min x, max x
box = [876, 1445, 1550, 2107];
start_year = 2002;
start_day = 1;
end_year = 2011;
end_day = 365;
biome_clip_path = "/auto/home/mcbride/programs/tools/biome_clip";
mask_file = "/auto/home/mcbride/deforestation/ESCAT_cetb/ESCAT_cetb_biome_mask.tif";
biome=readgeoraster(mask_file);
mask = (biome ~= 0);
clip_mask = mask(box(1):box(2),box(3):box(4));

% prodes all
start_year = 2002;
start_day = 1;
end_year = 2011;
end_day = 365;
output = "/auto/home/mcbride/programs/tools/biome_clip/Escat_prodes_all.mat";
data_path = "/auto/home/mcbride/deforestation/ESCAT_cetb/prodes_all/rasters";
filenames = dir(data_path);

clips = [];
num_files = length(filenames);
for i=3:num_files
    % clip image to biome extent
    file = filenames(i);
    full_path = sprintf('%s/%s',file.folder, file.name);
    def_data = readgeoraster(full_path);
    biome_def = def_data .* mask;
    clip = biome_def(box(1):box(2),box(3):box(4));
    % get image date
    datestr = split(string(file.name),'_');
    date = split(datestr(3),'-');
    month = str2num(date(2));
    day = str2num(date(3));
    year = str2num(date(1));
    time = datetime(year,month,day);
    % save to data structure
    clip_data = struct('date', time, 'img', clip);
    clips = [clips clip_data];
end
save(output, 'clips', '-v7.3');

% prodes def
start_year = 2002;
start_day = 1;
end_year = 2011;
end_day = 365;
output = "/auto/home/mcbride/programs/tools/biome_clip/Escat_prodes_def.mat";
data_path = "/auto/home/mcbride/deforestation/ESCAT_cetb/prodes_def/rasters";
filenames = dir(data_path);

clips = [];
num_files = length(filenames);
for i=3:num_files
    % clip image to biome extent
    file = filenames(i);
    full_path = sprintf('%s/%s',file.folder, file.name);
    def_data = readgeoraster(full_path);
    biome_def = def_data .* mask;
    clip = biome_def(box(1):box(2),box(3):box(4));
    % get image date
    datestr = split(string(file.name),'_');
    date = split(datestr(3),'-');
    month = str2num(date(2));
    day = str2num(date(3));
    year = str2num(date(1));
    time = datetime(year,month,day);
    % save to data structure
    clip_data = struct('date', time, 'img', clip);
    clips = [clips clip_data];
end
save(output, 'clips', '-v7.3');