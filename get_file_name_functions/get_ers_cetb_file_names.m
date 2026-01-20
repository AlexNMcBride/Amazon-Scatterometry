function [file_names] = get_ers_cetb_file_names(year,start_date,end_date,region,length)
% get_ers_cetb_files
% Years - 1996-2011
% Regions - 'N', 'S', 'T'
% Lengths - 6, 18
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
file_str = "/auto/MERSback/ERS/NSIDC-0808_ERS-ESCAT_SIR_EASE2_%s6.25KM_B_5.3VV_%03d%02d%02d-%03d%02d%02d_V1.0.nc";
% Has both Ama and SAm regions
for n=first_date:6:end_date
    finish_date = mod(n + length - 1, days);
    [start_month start_day start_year] = doy2date_wrap(n,year);
    if (finish_date < n)
        [finish_month finish_day finish_year] = doy2date_wrap(finish_date,year+1);
        file_name = sprintf(file_str,region,year,start_month,start_day,year+1,finish_month,finish_day);
    else
        [finish_month finish_day finish_year] = doy2date_wrap(finish_date,year+1);
        file_name = sprintf(file_str,region,year,start_month,start_day,year,finish_month,finish_day);
    end
    if isfile(file_name)
        file_names = cat(2,file_names,file_name);
    else
        display("File not found: " + file_name);
    end
end