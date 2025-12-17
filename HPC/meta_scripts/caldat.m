function [mm id iyyy] = caldat(julian)
%
% [mm id iyyy] = caldat(julian)
%
% given julian day [in this case, really the day of the year], 
% returns output month, day, year
%
% opposite of julday

% note: true julian day 1 starts at Noon on 1 Jan
% day of year 1 starts on at midnight on 1 Jan
% Julian calander starts on 15 Oct 1582

% written DGL  5 Dec 1995
% revised DGL 21 Nov 2020 + fix integer computation of ja, vectorize

IGREG=2299161; % 15 Oct 1582
%if (julian(1) >= IGREG)
%  jalpha=floor((floor(julian)-1867216.25)/36524.25);
%  ja=floor(julian)+1+jalpha-floor(0.25*jalpha);
%else % rare, for date less than 15 Oct 1582
%  ja=floor(julian);
%end
ja=double(floor(julian));
jalpha=floor((ja-1867216.25)/36524.25);
ja(julian>=IGREG)=floor(julian(julian>=IGREG))+1+jalpha(julian>=IGREG)-floor(0.25*jalpha(julian>=IGREG));

jb=ja+1524;
%jc=6680+floor(((jb-2439870)-122.1)/365.25);
jc=floor((jb-122.1)/365.25);
jd=365*jc+floor(0.25*jc);
je=floor((jb-jd)/30.6001);
id=jb-jd-floor(30.6001*je); % +floor(julian+0.5-floor(julian)); %(last term gives julian day break at noon)
mm=je-1;
%if (mm > 12)
%  mm=mm-12;
%end
mm(mm>12)=mm(mm>12)-12;
iyyy=jc-4715;
%if (mm > 2) 
%  iyyy=iyyy-1;
%end
iyyy(mm>2)=iyyy(mm>2)-1;
%if (iyyy <= 0) 
%  iyyy=iyyy-1;
%end
iyyy(iyyy<=0)=iyyy(iyyy<=0)-1;
return
end
