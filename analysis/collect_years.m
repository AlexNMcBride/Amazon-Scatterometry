clear
% ASCAT cetb
for year=2008:2024
    eval(sprintf("clips_%d = load('/auto/home/mcbride/Amazon-Scatterometry/output/ascat_cetb_4_day_scat_%d.mat')",year,year));
end
clips_year = [clips_2008,clips_2009,clips_2010,clips_2011,clips_2012,clips_2013,...
        clips_2014,clips_2015,clips_2016,clips_2017,clips_2018,clips_2019,...
        clips_2020,clips_2021,clips_2022,clips_2023,clips_2024];
save("/auto/home/mcbride/Amazon-Scatterometry/output/ascat_cetb_day_scat_4_3.125km.mat","clips_year",'-v7.3');

clear
% ERS-1
for year=1991:1996
    eval(sprintf("clips_%d = load('/auto/home/mcbride/Amazon-Scatterometry/output/ers1_18_day_scat_%d.mat')",year,year));
end
clips_year = [clips_1991,clips_1992,clips_1993,clips_1994,clips_1995,clips_1996];
save("/auto/home/mcbride/Amazon-Scatterometry/output/ers1_18_day_scat.mat","clips_year",'-v7.3');

clear
% ERS-2
for year=1996:2011
    eval(sprintf("clips_%d = load('/auto/home/mcbride/Amazon-Scatterometry/output/ers2_18_day_scat_%d.mat')",year,year));
end
clips_year = [clips_1996,clips_1997,clips_1998,clips_1999,clips_2000,...
    clips_2001,clips_2002,clips_2003,clips_2004,clips_2005,clips_2006,...
    clips_2007,clips_2008,clips_2009,clips_2010,clips_2011];
save("/auto/home/mcbride/Amazon-Scatterometry/output/ers2_18_day_scat.mat","clips_year",'-v7.3');

clear
% ERS Mersback
for year=1992:2001
    eval(sprintf("clips_%d = load('/auto/home/mcbride/Amazon-Scatterometry/output/ers_18_day_scat_%d.mat')",year,year));
end
clips_year = [clips_1992,clips_1993,clips_1994,clips_1995,clips_1996,clips_1997,clips_1998,clips_1999,clips_2000,...
    clips_2001];
save("/auto/home/mcbride/Amazon-Scatterometry/output/ers_18_day_scat.mat","clips_year",'-v7.3');
