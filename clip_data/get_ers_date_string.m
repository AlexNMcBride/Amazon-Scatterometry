function ers_date_string = get_ers_date_string(year,date)
    [month day cal_year] = doy2date_wrap(date,year);
    ers_date_string = get_cal_string(month, day, cal_year);
end
