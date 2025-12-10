% box - min y, max y, min x, max x
box = [130, 823, 103, 1009];
start_year = 2007;
start_day = 1;
end_year = 2022;
end_day = 319;
biome_clip_path = "/auto/home/mcbride/programs/tools/biome_clip";
output = "/auto/home/mcbride/programs/tools/biome_clip/sam_scat.mat";
mask_file = "~/Amazon-Scatterometry/base_rasters/SAm_biome_mask.tif";
biome=readgeoraster(mask_file);
mask = (biome ~= 0);

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
    scat_filenames = [scat_filenames get_ascat_file_names(year,start,stop)];
end

clips = [];
num_files = size(scat_filenames);
for i=1:num_files(2)
    % clip image to biome extent
    sir_file = scat_filenames(i);
    [path, name, ext] = fileparts(sir_file);
    basename = split(name,'.');
    filename = sprintf("%s/temp/SAm/%s", biome_clip_path, name);
    if ~exist(filename, 'file')
        cmd = sprintf("cp %s %s/temp/SAm/%s%s", sir_file, biome_clip_path, name, ext);
        system(cmd)
        cmd = sprintf("gunzip %s/temp/SAm/%s%s %s", biome_clip_path, name, ext, filename);
        system(cmd)
    end
    [img head] = loadsir(filename);
    sigma0 = img .* mask;
    clip = sigma0(box(1):box(2),box(3):box(4));
    % get image date
    date = split(basename(1),'-');
    start = str2num(date(4));
    length = str2num(date(5)) - start;
    year = str2num(extractAfter(date(3),3));
    if year < 90
        year = year + 2000;
    else
        year = year + 1900;
    end
    [month day] = doy2date(start,year);
    time = datetime(year,month,day);
    % save to data structure
    clip_data = struct('date', time, 'length', length, 'img', clip);
    clips = [clips clip_data];
end
save(output, 'clips', '-v7.3');