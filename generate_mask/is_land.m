function landflag = is_land(alat,alon);
%
% function landflag = is_land(alat,alon);
%
%   returns 1 if alat,alon (in deg) is over land, and 0 otherwise
%     (vectorized)
%

% revised 11/25/2020 at BYU by DGL to use persistent arrays for land map
% revised  1/ 6/2022 at BYU by DGL vectorized

% test locations 
%lat1=[27.6,28;28.5,28];
%lon1=[77.3,277.3;279.3,276];
%is_land(lat1,lon1); %== [1,1;1,0]

persistent land bits NSX NSY;
if isempty(land) % read land map (needed only once)
  [land,bits,NSX,NSY] = loadlandmap;
end

landflag=zeros(size(alat));
ind=find(abs(alat)<=90);

i=round(mod(alon(ind)+180.0+360.0,360.0)*100.0+0.5);
i(i<0)=0;
i(i>36000)=36000;
j=round((alat(ind)+90.0)*100.0+0.5);
j(j>17999)=17999;
j(j<0)=0;
  
k=floor(i/32);
l=mod(i,32);
n=j*NSX+k+1;

ib=bitand(land(n)',bits(l+1));
ind2=find(ib==0);
w=ind(ind2);
landflag(w)=1;