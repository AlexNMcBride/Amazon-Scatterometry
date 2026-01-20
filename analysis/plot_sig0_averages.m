instrument = "sam";
ers_num = 2;
length = 6;

if instrument == "ers" || instrument == "ERS-1" || instrument == "ERS-2"
    filename = sprintf("/auto/home/mcbride/deforestation/clips/ers%d_%d_day_scat.mat",ers_num,length);
    instrument = sprintf("ERS-%d",ers_num);
    min = -42;
elseif instrument == "ascat" || instrument == "ASCAT"
    filename = sprintf("/auto/home/mcbride/deforestation/clips/%s_%d_scat.mat", instrument, length);
    instrument = "ASCAT";
else
    filename = sprintf("/auto/home/mcbride/deforestation/clips/%s_scat.mat", instrument);
    min = -33;
    instrument = "SAm";
end
load(filename);

days_clips = size(clips);
days = days_clips(2);
s_avgs = [];

dates = [];

% Get average sigma_0 value
for n=1:days
    sig0 = clips(n).img;
    cut = sig0 .* (sig0 > min);
    avg = mean(nonzeros(cut));
    s_avgs = [s_avgs avg];
    dates = [dates clips(n).date];
end
% remove NaNs
dates = dates(~isnan(s_avgs));
s_avgs = s_avgs(~isnan(s_avgs));
% could filter by daily change
% n = size(s_avgs);
% range_size = n(2) - 1;
% dif = zeros(1,range_size);
% for i=1:filt_size
%     dif(i) = s_avgs(i+1) - s_avgs(i);
% end
% Filter by standard deviation
k = .5;
idx = ~isoutlier(s_avgs, "mean", "ThresholdFactor", k);
filt_avgs = s_avgs(idx);
filt_dates = dates(idx);
% Plot averages
figure(1)
hold on
plot(filt_dates,filt_avgs)
if instrument == "ers" || instrument == "ERS-1" || instrument == "ERS-2"
    avg_titl = sprintf("Mean of ERS %d %d Day Images", ers_num, length);
elseif instrument == "ascat"
    avg_titl = sprintf("Mean of ASCAT CETB %d Day Images", length);
else
    avg_titl = sprintf("Mean of SAM 4 Day Images");
end
title(avg_titl)
hold off

% notes: SAm image for 2021 day 337 has bright swath artefacts that may be cause of spike
% SAm image for 2013 day 77 has a dark blurry swath artefact
% ERS-2 image for 2001 day 85 is very blurry, low spike on avg plot
% ERS-2 image for 2008 day 235 has very few valid data points

% find day-to-day change to find anomalies
filt_size = size(filt_avgs);
range_size = filt_size(2) - 1;
dif = zeros(1,range_size);
for i=1:range_size
    dif(i) = filt_avgs(i) - filt_avgs(i+1);
end
figure(2)
plot(filt_dates(1:range_size),dif)
ylabel("\sigma_0 dB")
dif_titl = sprintf("Day to Day Change in %s Average Backscatter", instrument);
title(dif_titl)