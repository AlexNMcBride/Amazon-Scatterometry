function [month day iyyy] = doy2date(doy,year)
%
% [month day] = doy2date(doy,year)
%
% given day of year and year, returns month and year
%
% uses julday and caldat
%
jday=julday(1,1,year)+doy-1;
[month, day, iyyy]=caldat(jday);
return
