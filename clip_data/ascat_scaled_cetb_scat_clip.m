% ESCAT box: y = (876,1445), x = (1550,2107)
% box - min y, max y, min x, max x
box = [876, 1445, 1550, 2107];
biome_clip_path = "/auto/home/mcbride/programs/tools/biome_clip";
mask_file = "/auto/home/mcbride/Amazon-Scatterometry/base_rasters/ESCAT_cetb_biome_mask.tif";
biome=readgeoraster(mask_file);
mask = (biome ~= 0);
start_year = 2008;
start_day = 1;
end_year = 2024;
end_day = 39;
length = 4;

for year=2008:2024
    output = sprintf("/auto/home/mcbride/Amazon-Scatterometry/output/ascat_cetb_%d_day_scat_%d_6.25km.mat",year,length);
    scat_filenames = [];
    clips = [];
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
    scat_filenames = get_ascat_cetb_file_names(year,start,stop,'T',length);
    scat_filenames = sort(scat_filenames);
    
    num_files = size(scat_filenames);
    for i=1:num_files(2)
        file_path = scat_filenames(i);
        [path, name, ext] = fileparts(file_path);
        nc = readcetb0(file_path);
        % head = cetb2sir_head(nc);
        img = nc.sir;
        scaled_img = imresize(img,[2160 5552]);
        sigma0 = scaled_img .* mask;
        clip = sigma0(box(1):box(2),box(3):box(4));
        clip(clip == 0) = NaN;
        % get image date
        name = split(name,'-');
        dates = name(5);
        lenstr = split(dates,'_');
        startstr = lenstr(1);
        year = str2double(extractBefore(startstr,5));
        jul_date = str2double(extractAfter(startstr,4));
        [month, day] = doy2date_wrap(jul_date,year);
        time = datetime(year,month,day);
        % save to data structure
        clip_data = struct('date', time, 'length', length, 'img', clip);
        clips = [clips clip_data];
    end
    save(output, 'clips', '-v7.3');
end