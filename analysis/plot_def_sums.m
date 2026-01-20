% instrument (def_types): 
%   sam (sam_prodes_def, prodes_small, deter)
%   escat (prodes_all, prodes_def)
%   ascat
% fix: sam_prodes_all, ascat_prodes_def
% file contains clips with deforestation images and dates

instrument = "sam";
def_type = "deter";
filename = sprintf("/auto/home/mcbride/Amazon-Scatterometry/output/%s_%s.mat", instrument, def_type);
load(filename)
if instrument == "ascat"
    pixel_area = 3.125^2;
else
    pixel_area = 6.250^2;
end
days_clips = size(clips);
days = days_clips(2);
sum_def = [];
dates = [];
for n=1:days
    def_pixels = clips(n).img;
    area = sum(sum(def_pixels(:,:))) * pixel_area;
    sum_def = [sum_def area];
    dates = [dates clips(n).date];
end
plot(dates,sum_def)
titl = sprintf("Deforestation Area (km^2)");
title(titl)

resolution = size(clips(1).img);

def_sum = zeros(resolution(1), resolution(2));
for n=1:days
    def_sum = def_sum + clips(n).img;
end

% compute spatial autocorrelation? Use Moran's I?
k = 7;
k_mid = (k+1)/2;
w = zeros(k,k);
for n=1:k
    for m=1:k
        w(n,m) = exp(-1*sqrt((k_mid-n)^2+(k_mid-m)^2));
    end
end
% normalize weight matrix
w = w/sum(sum(w));
M = moransI(def_sum,w,'true');
% global Moran's I
M_global = mean(M,"all");