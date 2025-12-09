function [file_names] = get_escat_cetb_file_names(year,start_date,end_date,ers_num,region,length)
%GET_ASCAT_CETB_FILE_NAMES Summary of this function goes here
%   Detailed explanation goes here
file_names = [];
if year ~= 1996 && start_date ~= 86
    first_date = start_date + mod((start_date + 1),2);
else
    first_date = start_date;
end
if mod(year,4) == 0 && mod(year,100) ~= 0 || year == 2000
    leap_year = true;
    days = 366;
else
    leap_year = false;
    days = 365;
end
file_str = "/auto/home/mcbride/ERS_sir/ERS%d_prod/%d/BYU-ESCAT-EASE2_%s6.25km-ERS_ESCAT-%d%03d_%d%03d-5.3VV-B-SIR-v1.0.nc";
% Has both Ama and SAm regions
for n=first_date:6:end_date
    finish_date = mod(n + length, days);
    if (finish_date < n)
        file_name = sprintf(file_str,ers_num,year,region,year,n,year+1,finish_date);
    else
        file_name = sprintf(file_str,ers_num,year,region,year,n,year,finish_date);
    end
    if isfile(file_name)
        file_names = cat(2,file_names,file_name);
    else
        display("File not found: " + file_name);
    end
end