function [file_names] = get_tandem_file_names(start_date,end_date,pol,egg)
%GET_TANDEM_FILE_NAMES Summary of this function goes here
%   Detailed explanation goes here
file_names = [];
year = 2003;
first_date = start_date - mod((start_date - 1),2);
last_date = end_date - mod((end_date - 1),2);
% Has both Ama and SAm regions
region = "SAm";
for n=first_date:2:last_date
    my_date = n;
    finish_date = my_date + 1;
    short_year_str = extractAfter(num2str(year),2);
    file_type = sprintf("tu%s%s",egg,pol);
    file_str = "/auto/internet/ftp/data/tandem/%d/sir/%s/%s/%03d/a/%s-a-%s%s-%03d-%03d.sir.gz";
    file_name = sprintf(file_str,year,file_type,region,my_date,file_type,region,short_year_str,my_date,finish_date);
    if isfile(file_name)
        file_names = cat(2,file_names,file_name);
    else
        display("File not found: " + file_name);
    end
end
end

