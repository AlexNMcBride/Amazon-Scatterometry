function [file_names] = get_ascat_file_names(year,start_date,end_date)
%GET_ASCAT_FILE_NAMES Summary of this function goes here
%   Detailed explanation goes here
file_names = [];
pol = "v";
first_date = start_date + mod((start_date + 1),2);
last_date = end_date - mod((end_date - 1),2);
if last_date > 361
    last_date = 361;
end
% Has both Ama and SAm regions
region = "SAm";
for n=first_date:2:last_date
    % i = n - first_date + 1;
    my_date = n;
    finish_date = my_date + 4;
    short_year_str = extractAfter(num2str(year),2);
    file_type = "msfa";
    file_str = "/auto/internet/ftp/data/ascat/%d/sir/%s/%s/%03d/a/%s-a-%s%s-%03d-%03d.sir.gz";
    file_name = sprintf(file_str,year,file_type,region,my_date,file_type,region,short_year_str,my_date,finish_date);
    if isfile(file_name)
        file_names = cat(2,file_names,file_name);
    else
        display("File not found: " + file_name);
    end
end
