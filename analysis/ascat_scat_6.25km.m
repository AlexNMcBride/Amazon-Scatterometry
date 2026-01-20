start_year = 2008;
end_year = 2024;
years = end_year - start_year;
clips_size = [570, 558];

% no ascat data for 2011-099 to 2014-002
for year=2008:2024
    eval(sprintf("clips_%d = load('/auto/home/mcbride/Amazon-Scatterometry/output/ascat_cetb_%d_day_scat_4_6.25km.mat')",year,year));
end
clips_year = [clips_2008,clips_2009,clips_2010,clips_2011,clips_2012,clips_2013,...
        clips_2014,clips_2015,clips_2016,clips_2017,clips_2018,clips_2019,...
        clips_2020,clips_2021,clips_2022,clips_2023,clips_2024];
save("/auto/home/mcbride/Amazon-Scatterometry/output/ascat_cetb_day_scat_4_6.25km.mat","clips_year",'-v7.3');