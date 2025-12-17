function jd = julday(mm,id,iyyy)
%
% function jd = julday(mm,id,iyyy)
%     returns the Julian day number that begins on noon of the calendar
%     date specifed by month mm, day id and year iyy.
%
% opposite of caldat

% written DGL  5 Dec 1995
% revised DGL 21 Nov 2020 + vectorized, double to ensure values all same type

IGREG=15+31*(10+12*1582); % 15 Oct 1582
jy=double(iyyy);
%if (jy <0) 
%  jy=jy+1;
%end
jy(jy<0)=jy(jy<0)+1;
%if (mm > 2) 
%  jm=mm+1;
%else
%  jy=jy-1;
%  jm=mm+13;
%end
jm=double(mm+1);
jy(mm<3)=jy(mm<3)-1;
jm(mm<3)=double(mm(mm<3))+13;

jd=floor(365.25*jy)+floor(30.6001*jm)+double(id)+1720995;
%if (id+31*(mm+12*iyyy) >= IGREG) 
%  ja=floor(0.01*jy);
%  jd=jd+2-ja+floor(0.25*ja);
%end
ja=floor(0.01*jy);
ind=find(double(id)+31*(double(mm)+12*double(iyyy)) >= IGREG);
if length(ind)>0
  jd(ind)=jd(ind)+2-ja(ind)+floor(0.25*ja(ind));
end
return
end
