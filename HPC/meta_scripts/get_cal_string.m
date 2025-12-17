function ers_cal_string = get_cal_string(month, day, year)
    ers_cal_string = sprintf("%.2d%.2d%.2d",mod(year,100),month,day);
end