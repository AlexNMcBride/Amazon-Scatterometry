function [file_names, ave_files] = get_ascat_cetb_file_names(year,start_date,end_date,region,length)
% Get ASCAT cetb file names from a given year.
file_names = [];
ave_files = [];
first_date = start_date + mod((start_date + 1),2);
if mod(year,4) == 0 && mod(year,100) ~= 0 || year == 2000
    leap_year = true;
    days = 366;
else
    leap_year = false;
    days = 365;
end
if year < 2018
    file_str = "/auto/home/mers_data/ASCAT/%d-%03d-%d/BYU-ASCAT-EASE2_%s3.125km-METOP_ASCAT-%d%03d_%d%03d-5.3VV-B-%s-v1.0.nc";
else
    file_str = "/auto/home/mers_data/ASCAT2/%d-%03d-%d/BYU-ASCAT-EASE2_%s3.125km-METOP_ASCAT-%d%03d_%d%03d-5.3VV-B-%s-v1.0.nc";
end
% Has both Ama and SAm regions
for n=first_date:end_date
    finish_date = mod(n + length - 1, days);
    if finish_date < n
        file_name = sprintf(file_str,year,n,length,region,year,n,year+1,finish_date,"SIR");
        ave_file = sprintf(file_str,year,n,length,region,year,n,year+1,finish_date,"AVE");
    else
        file_name = sprintf(file_str,year,n,length,region,year,n,year,finish_date,"SIR");
        ave_file = sprintf(file_str,year,n,length,region,year,n,year,finish_date,"AVE");
    end
    if isfile(file_name)
        file_names = cat(2,file_names,file_name);
    elseif isfile(ave_file)
        display("AVE file found: " + ave_file);
        ave_files = cat(2,ave_files,ave_file);
    else
        display("No SIR or AVE file: " + file_name);
    end
end
