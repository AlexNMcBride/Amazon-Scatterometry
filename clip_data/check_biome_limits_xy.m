% provides the x and y limits needed to clip overlap and scatterometer images to solely the Amazon biome
clear
masks_path="~/Amazon-Scatterometry/base_rasters";
SAm_biome_mask="~/Amazon-Scatterometry/base_rasters/SAm_biome_mask.tif";
ASCAT_biome_mask="~/Amazon-Scatterometry/base_rasters/ASCAT_cetb_biome_mask.tif";
ESCAT_biome_mask="~/Amazon-Scatterometry/base_rasters/ESCAT_cetb_biome_mask.tif";

sam_biome=readgeoraster(SAm_biome_mask);
ascat_biome=readgeoraster(ASCAT_biome_mask);
escat_biome=readgeoraster(ESCAT_biome_mask);

% ASCAT cetb
max_x = 0;
max_y = 0;
ascat_size = size(ascat_biome);
min_x = ascat_size(2);
min_y = ascat_size(1);

for y=1:ascat_size(1)
    for x=1:ascat_size(2)
        if ascat_biome(y,x)
            if y < min_y
                min_y = y;
            elseif y > max_y
                max_y = y;
            end
            if x < min_x
                min_x = x;
            elseif x > max_x
                max_x = x;
            end
        end
    end
end

fprintf("ASCAT box: y = (%d,%d), x = (%d,%d)\n", min_y,max_y,min_x,max_x);

% ESCAT cetb
max_x = 0;
max_y = 0;
escat_size = size(escat_biome);
min_x = escat_size(2);
min_y = escat_size(1);

for y=1:escat_size(1)
    for x=1:escat_size(2)
        if escat_biome(y,x)
            if y < min_y
                min_y = y;
            elseif y > max_y
                max_y = y;
            end
            if x < min_x
                min_x = x;
            elseif x > max_x
                max_x = x;
            end
        end
    end
end
fprintf("ESCAT box: y = (%d,%d), x = (%d,%d)\n", min_y,max_y,min_x,max_x);

% SAm
max_x = 0;
max_y = 0;
sam_size = size(sam_biome);
min_x = sam_size(2);
min_y = sam_size(1);

for y=1:sam_size(1)
    for x=1:sam_size(2)
        if sam_biome(y,x)
            if y < min_y
                min_y = y;
            elseif y > max_y
                max_y = y;
            end
            if x < min_x
                min_x = x;
            elseif x > max_x
                max_x = x;
            end
        end
    end
end
fprintf("SAm box: y = (%d,%d), x = (%d,%d)\n", min_y,max_y,min_x,max_x);