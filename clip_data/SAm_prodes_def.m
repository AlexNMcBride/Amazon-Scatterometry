% box - min y, max y, min x, max x
box = [130, 823, 103, 1009];
start_year = 2007;
start_day = 1;
end_year = 2022;
end_day = 319;
biome_clip_path = "/auto/home/mcbride/programs/tools/biome_clip";
output = "/auto/home/mcbride/programs/tools/biome_clip/sam_prodes_def.mat";
mask_file = "~/Amazon-Scatterometry/base_rasters/SAm_biome_mask.tif";
data_path = "/auto/home/mcbride/deforestation/SAm/prodes_def/rasters";
biome=readgeoraster(mask_file);
mask = (biome ~= 0);

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