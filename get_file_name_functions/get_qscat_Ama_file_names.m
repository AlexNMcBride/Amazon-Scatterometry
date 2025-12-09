function [file_names] = get_qscat_file_names(year,start_date,end_date,pol,egg)
%GET_QSCAT_FILE_NAMES Summary of this function goes here
%   Detailed explanation goes here
file_names = [];
first_date = start_date - mod((start_date - 1),4);
last_date = end_date - mod((end_date - 1),4);
if last_date > 361
    last_date = 361;
end
region = "Ama";
for n=first_date:4:last_date
    my_date = n;
    finish_date = my_date + 3;
    short_year_str = extractAfter(num2str(year),2);
    file_type = sprintf("qu%s%s",egg,pol);
    file_str = "/auto/internet/ftp/data/qscatv2/%d/sir/%s/%s/%03d/a/%s-a-%s%s-%03d-%03d.sir.gz";
    file_name = sprintf(file_str,year,file_type,region,my_date,file_type,region,short_year_str,my_date,finish_date);
    if isfile(file_name)
        file_names = cat(2,file_names,file_name);
    else
        display("File not found: " + file_name);
    end
end
end

