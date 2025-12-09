function [month,day] = monthFinder(d,y)

if(mod(y,4) == 0)
    add = 1;
else
    add = 0;
end

if(d <= 31)
    month = 1;
    day = d;
elseif(d <= 59 + add)
    month = 2;
    day = d - 31;
elseif(d <= 90 + add)
    month = 3;
    day = d - (59 + add);
elseif(d <= 120 + add)
    month = 4;
    day = d - (90 + add);
elseif(d <= 151 + add)
    month = 5;
    day = d - (120 + add);
elseif(d <= 181 + add)
    month = 6;
    day = d - (151 + add);
elseif(d <= 212 + add)
    month = 7;
    day = d - (181 + add);
elseif(d <= 243 + add)
    month = 8;
    day = d - (212 + add);
elseif(d <= 273 + add)
    month = 9;
    day = d - (243 + add);
elseif(d <= 304 + add)
    month = 10;
    day = d - (273 + add);
elseif(d <= 334 + add)
    month = 11;
    day = d - (304 + add);
elseif(d <= 365 + add)
    month = 12;
    day = d - (334 + add);
else
    month = 0;
    day = 0;
end

end



