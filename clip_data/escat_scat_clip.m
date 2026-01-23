% ESCAT box: y = (876,1445), x = (1550,2107)
% box - min y, max y, min x, max x
box = [876, 1445, 1550, 2107];
biome_clip_path = "/auto/home/mcbride/programs/tools/biome_clip";
mask_file = "/auto/home/mcbride/Amazon-Scatterometry/base_rasters/ESCAT_cetb_biome_mask.tif";
biome=readgeoraster(mask_file);
mask = (biome ~= 0);

ers_num = 2;
length = 18;
% ERS-1
if ers_num == 1
    start_year = 1991;
    start_day = 213;
    end_year = 1996;
    end_day = 154;
elseif ers_num == 2
    start_year = 1996;
    start_day = 86;
    end_year = 2011;
    end_day = 185;
else
    % MERSback range
    start_year = 1992;
    start_day = 1;
    end_year = 2001;
    end_day = 19;
end

length = 18;
for year=start_year:end_year
    if ers_num == 1 || ers_num == 2
        output = sprintf("/auto/home/mcbride/Amazon-Scatterometry/output/ers%d_%d_day_scat_%d.mat",ers_num,length,year);
    else
        output = sprintf("/auto/home/mcbride/Amazon-Scatterometry/output/ers_%d_day_scat_%d.mat",length,year);
    end
    
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
    if ers_num == 1 || ers_num == 2
        scat_filenames = get_ers2_cetb_file_names(year,start,stop,ers_num,'T',length);
    else
        scat_filenames = get_ers_cetb_file_names(year,start,stop,'T',length);
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
        clip(clip == 0) = NaN;
        % get image date
        if ers_num == 1 || ers_num == 2
            name = split(name,'-');
            dates = name(5);
            lenstr = split(dates,'_');
            startstr = lenstr(1);
            year = str2num(extractBefore(startstr,5));
            julday = str2num(extractAfter(startstr,4));
            [month day] = doy2date_wrap(julday,year);
            time = datetime(year,month,day);
        else
            name = split(name,'_');
            dates = name(8);
            lenstr = split(dates,'-');
            startstr = lenstr(1);
            year = str2num(extractBefore(startstr,5));
            month = str2num(extractBetween(startstr,5,6));
            day = str2num(extractBetween(startstr,7,8));
            time = datetime(year,month,day);
        end
        
        % save to data structure
        clip_data = struct('date', time, 'length', length, 'img', clip);
        clips = [clips clip_data];
    end
    save(output, 'clips', '-v7.3');
end