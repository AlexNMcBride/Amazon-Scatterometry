function [file_names] = get_ers_file_names(start_date,end_date)
%GET_ERS_FILE_NAMES Summary of this function goes here
%   Detailed explanation goes here
file_names = [];
pol = "h";
if year > 1996 || (year == 1996 && start_date > 155)
    file_type = "ers1";
else
    file_type = "ers2";
end
first_date = start_date - mod((start_date - 1),6);
last_date = end_date - mod((end_date - 1),6);
if last_date > 362
    last_date = 362;
end
% Has only SAm region, not Ama
region = "SAm";
for n=first_date:6:last_date
    my_date = n;
    finish_date = my_date + 17;
    short_year_str = extractAfter(num2str(year),2);
    file_str = "/auto/internet/ftp/data/ers/%d/sir/%s/%s/%03d/a/%s-a-%s%s-%03d-%03d.sir.gz";
    file_name = sprintf(file_str,year,file_type,region,my_date,file_type,region,short_year_str,my_date,finish_date);
    if isfile(file_name)
        file_names = cat(2,file_names,file_name);
    else
        display("File not found: " + file_name);
    end
end
end