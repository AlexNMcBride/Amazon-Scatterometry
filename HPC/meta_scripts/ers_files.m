function file_names = ers_files(F,start_year,start_date,interval,file_number)
    Nf = length(F);
    valid_dates = "";
    for i=start_date:start_date+interval
        file_date = get_ers_date_string(start_year,i) + " ";
        valid_dates = append(valid_dates,file_date);
    end
    dates_list = strsplit(valid_dates);
    if length(dates_list) ~= 1
        dates_list = dates_list(1:length(dates_list)-1);
    end

    % find date string after final date
    end_date = start_date+interval+1;
    end_date_string = get_ers_date_string(start_year,end_date);
    call = 0;
    
    % always include file at index provided
    file_paths = "";
    file_path = sprintf("%s/%s\n",F(file_number).folder,F(file_number).name);
    file_paths = file_paths.append(file_paths,file_path);
    for file=file_number+1:1:Nf
        % fprintf("Index: %d\n",file)
        if ismember(F(file).date,dates_list)
            call = call + 1;
            % fprintf("file found")
            file_path = sprintf("%s/%s\n",F(file).folder,F(file).name);
            file_paths = append(file_paths,file_path);
            continue;
        end
        if strcmp(F(file).date, end_date_string)
            fprintf("End date found, index: %d\n",file)
            break;
        end
    end
    file_names = file_paths;
    % file_names = strsplit(file_paths);
    % if length(file_names) > 1
    %     file_names = file_names(1:end-1);
    % end
end