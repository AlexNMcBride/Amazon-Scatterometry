function file_number = date_start_index(F,year,date,start_index)
    if start_index == length(F)
        start_index = 1;
    end
    date_string = get_ers_date_string(year,date);
    for i=start_index:1:length(F)
        if F(i).date == date_string
            break;
        end
    end
    if i == 1
        file_number = i;
    else
        file_number = i-1;
    end
end