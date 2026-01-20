function head=cetb_sir_head(cetb,opt)
%
% head=cetb_sir_head(cetb,opt)
%
%      cetb: structure read using readcetb.m
%      opt:  optional array variable name, e.g., 'TB','Sigma0','TB_inc',
%             'Sigma0_inc', 'Sigma0_std','TB_std','TB_num','TB_time', etc.
%
% generate BYU .SIR header from cetb structure

% written by DGL 10 Sep 2018
% revised by DGL 20 Sep 2020 + general resolution options
% revised by DGL 19 Sep 2022 + updated to use radar, too
% revised by DGL 27 Jun 2025 + switch projection x,y dimensions, generalized

head=zeros([256,1]);  % template header array
head=setsirhead('nsx',head,cetb.ydim);
head=setsirhead('nsy',head,cetb.xdim);
head=setsirhead('nhead',head,1);
head=setsirhead('nhtype',head,31);
head=setsirhead('nia',head,0);
head=setsirhead('ndes',head,0);
head=setsirhead('ldes',head,0);
head=setsirhead('ideg_sc',head,10);
head=setsirhead('iscale_sc',head,100);
head=setsirhead('i0_sc',head,1);
head=setsirhead('ixdeg_off',head,0);
head=setsirhead('iydeg_off',head,0);
head=setsirhead('ia0_off',head,0);
head=setsirhead('ib0_off',head,0);
head=setsirhead('ioff',head,100);
head=setsirhead('iscale',head,200);
head=setsirhead('type',head,['(unspecified) ',cetb.platform]); % default value
% sigma0 defaults
head=setsirhead('ioff',head,-33);    % default value
head=setsirhead('iscale',head,1000); % default value
head=setsirhead('itype',head,1);     % default value
head=setsirhead('anodata',head,-32); % default value
head=setsirhead('vmin',head,-30);    % default value
head=setsirhead('vmax',head,0);      % default value
if length(strfind(cetb.basename,'TB')) % TB defaults
  head=setsirhead('ioff',head,100);    % default value
  head=setsirhead('iscale',head,200);  % default value
  head=setsirhead('itype',head,3);     % default value
  head=setsirhead('anodata',head,100); % default value
  head=setsirhead('vmin',head,180);    % default value
  head=setsirhead('vmax',head,295);    % default value
end

if isfield(cetb,'lat_org')
  if cetb.lat_org > 80.0
    head=setsirhead('iopt',head,8); % EASE2N
  elseif cetb.lat_org < -80.0
    head=setsirhead('iopt',head,9); % EASE2S
  else
    head=setsirhead('iopt',head,10);% EASE2T/M
  end
else
  head=setsirhead('iopt',head,10);% EASE2T/M
end
head=setsirhead('xdeg',head,cetb.xdim/2.0);
head=setsirhead('ydeg',head,cetb.ydim/2.0);

xres=sscanf(cetb.xres,'%f');
if xres > 1000.0
  xres=xres/1000.0;
end
%determine the SIR projection parameters based on resolution
%for ind=3 nease: (0=24, 1=12,   2=6,    3=3,     4=1.5)
%for ind=2 nease: (0=36, 1=18,   2=9,    3=4.5,   4=2.25, 5=1.125)
%for ind=1 nease: (0=30, 1=15,   2=7.5,  3=3.25,  4=1.625)
%for ind=0 nease: (0=25, 1=12.5, 2=6.25, 3=3.125, 4=1.56)
d=[0,0,25; 0,1,12.5; 0,2,6.25; 0,3,3.125; 0,4,1.56;...
   1,0,30; 1,1,15;   1,2,7.5;  1,3,3.25;  1,4,1.625;...
   2,0,36; 2,1,18;   2,2,9;    2,3,4.5;   2,4,2.25; 2,5,1.125;...
   3,0,24; 3,1,12;   3,2,6;    3,3,3;     3,4,1.5;];
i=find(abs(xres-d(:,3))<0.01);
if length(i)<1
  i=find(abs(xres-d(:,3))<0.1);
end
if length(i)<1,error(sprintf('*** Cannot find standard EASE2 resolution %f',xres));else i=i(1);end;


head=setsirhead('ascale',head,d(i,2)); % isc
head=setsirhead('bscale',head,d(i,1)); % ind
%[d(i,1),d(i,2),xres]
head=setsirhead('a0',head,0.0);
head=setsirhead('b0',head,0.0);
head=setsirhead('ipol',head,0.0);
if length(strfind(cetb.fpol,'V'))>0
  head=setsirhead('ipol',head,1.0);
end
if length(strfind(cetb.fpol,'.'))>0
  xres=sscanf(cetb.fpol,'%f');
else
  xres=sscanf(cetb.fpol,'%2d');
end
head=setsirhead('ifreqhm',head,round(xres(1)*10));

% decode start/stop days
head=setsirhead('ismin',head,0.0);
head=setsirhead('iemin',head,1440.0);
iyear=sscanf(cetb.tstart,'%4d');
imon=sscanf(cetb.tstart(6:end),'%2d');
iday=sscanf(cetb.tstart(9:end),'%2d');
head=setsirhead('iyear',head,iyear(1));
doy=julday(imon(1),iday(1),iyear(1))-julday(1,1,iyear(1))+1;
head=setsirhead('isday',head,doy);
imon=sscanf(cetb.tstop(6:end),'%2d');
iday=sscanf(cetb.tstop(9:end),'%2d');
doy=julday(imon(1),iday(1),iyear(1))-julday(1,1,iyear(1))+1;
head=setsirhead('ieday',head,doy);

% store strings
k=strfind(cetb.filename,'/'); % strip path from file name
if length(k)>0 
  k=k(end)+1;
else
  k=1;
end
[path,name,ext] = fileparts(cetb.filename);
title = name + ext;
head=setsirhead('title',head,title);
head=setsirhead('type',head,['CETB TB ',cetb.platform]);
head=setsirhead('sensor',head,['CETB ',cetb.instrument]);
head=setsirhead('tag',head,'(c) 2017 BYU MERS');
head=setsirhead('crproc',head,'cetb_sir_head.m');
str=char(datetime());
head=setsirhead('crtime',head,str);

% optionally add other factors
if nargin>1
  varopt=opt;
else
  varopt=cetb.basename;
end
switch varopt
  case {'sig', 'Sigma0', 'Sigma0_AzMod'}  % backscatter 
    head=setsirhead('type',head,['Sigma0 ',cetb.platform]);
    head=setsirhead('ioff',head,-33);
    head=setsirhead('iscale',head,1000);
    head=setsirhead('itype',head,1);
    head=setsirhead('anodata',head,-33);
    head=setsirhead('vmin',head,-30);
    head=setsirhead('vmax',head,0);
	
  case 'TB'  % brightness temperture
    head=setsirhead('type',head,['TB ',cetb.platform]);
    head=setsirhead('ioff',head,100);
    head=setsirhead('iscale',head,200);
    head=setsirhead('itype',head,3);
    head=setsirhead('anodata',head,100);
    head=setsirhead('vmin',head,180);
    head=setsirhead('vmax',head,295);
	
  case {'Sigma0_num', 'Sigma0_num_samples'}
    head=setsirhead('type',head,['Sigma0_num ',cetb.platform]);
    head=setsirhead('ioff',head,-1);
    head=setsirhead('iscale',head,8);
    head=setsirhead('itype',head,3);
    head=setsirhead('anodata',head,-1);
    head=setsirhead('vmin',head,-1);
    head=setsirhead('vmax',head,50);
  
  case 'TB_num'
    head=setsirhead('type',head,['TB_num ',cetb.platform]);
    head=setsirhead('ioff',head,-1);
    head=setsirhead('iscale',head,8);
    head=setsirhead('itype',head,3);
    head=setsirhead('anodata',head,-1);
    head=setsirhead('vmin',head,-1);
    head=setsirhead('vmax',head,50);
  
  case 'Sigma0_inc'
    head=setsirhead('type',head,['Sigma0_inc ',cetb.platform]);
    head=setsirhead('ioff',head,0);
    head=setsirhead('iscale',head,100);
    head=setsirhead('itype',head,9);
    head=setsirhead('anodata',head,-1);
    head=setsirhead('vmin',head,40);
    head=setsirhead('vmax',head,60);
  
  case 'TB_inc'
    head=setsirhead('type',head,['TB_inc ',cetb.platform]);
    head=setsirhead('ioff',head,0);
    head=setsirhead('iscale',head,100);
    head=setsirhead('itype',head,9);
    head=setsirhead('anodata',head,-1);
    head=setsirhead('vmin',head,40);
    head=setsirhead('vmax',head,60);
  
  case 'Sigma0_std'
    head=setsirhead('type',head,['Sigma0_std ',cetb.platform]);
    head=setsirhead('ioff',head,-1);
    head=setsirhead('iscale',head,100);
    head=setsirhead('itype',head,23);
    head=setsirhead('anodata',head,-1);
    head=setsirhead('vmin',head,0);
    head=setsirhead('vmax',head,15);
  
  case 'TB_std'
    head=setsirhead('type',head,['TB_std ',cetb.platform]);
    head=setsirhead('ioff',head,-1);
    head=setsirhead('iscale',head,100);
    head=setsirhead('itype',head,23);
    head=setsirhead('anodata',head,-1);
    head=setsirhead('vmin',head,0);
    head=setsirhead('vmax',head,15);
  
  case 'Sigma0_time'
    head=setsirhead('type',head,['Sigma0 time ',cetb.platform]);
    head=setsirhead('ioff',head,-1);
    head=setsirhead('iscale',head,1);
    head=setsirhead('itype',head,11);
    head=setsirhead('anodata',head,-1);
    head=setsirhead('vmin',head,0);
    head=setsirhead('vmax',head,1440*4);
  
  case 'TB_time'
    head=setsirhead('type',head,['TB_time ',cetb.platform]);
    head=setsirhead('ioff',head,-1);
    head=setsirhead('iscale',head,1);
    head=setsirhead('itype',head,11);
    head=setsirhead('anodata',head,-1);
    head=setsirhead('vmin',head,0);
    head=setsirhead('vmax',head,2880);

  case {'Az_mod1_amp', 'Az_mod2_amp'}
    head=setsirhead('type',head,[varopt,' ', cetb.platform]);
    head=setsirhead('ioff',head,-1);
    head=setsirhead('iscale',head,100);
    head=setsirhead('itype',head,34); % 34,37
    head=setsirhead('anodata',head,-1);
    head=setsirhead('vmin',head,0);
    head=setsirhead('vmax',head,10);
    
  case {'Az_mod1_ang', 'Az_mod2_ang'}
    head=setsirhead('type',head,[varopt,' ', cetb.platform]);
    head=setsirhead('ioff',head,0);
    head=setsirhead('iscale',head,50);
    head=setsirhead('itype',head,35); % 35,38
    head=setsirhead('anodata',head,0);
    head=setsirhead('vmin',head,0);
    head=setsirhead('vmax',head,360);
    
  case {'Incidence', 'Incidence_angle'}
    head=setsirhead('type',head,['Incidence Angle ',cetb.platform]);
    head=setsirhead('ioff',head,0);
    head=setsirhead('iscale',head,100);
    head=setsirhead('itype',head,9);
    head=setsirhead('anodata',head,0);
    head=setsirhead('vmin',head,10);
    head=setsirhead('vmax',head,60);
    
  case {'Sigma_slope', 'Sigma_slope_ave'}
    head=setsirhead('type',head,[varopt,' ',cetb.platform]);
    head=setsirhead('ioff',head,0);
    head=setsirhead('iscale',head,1000);
    head=setsirhead('itype',head,2);
    head=setsirhead('anodata',head,-3);
    head=setsirhead('vmin',head,-0.25);
    head=setsirhead('vmax',head,0);
    
  otherwise
    disp('*** unrecognized cetb_sir_head variable in cetb2sir_head');
 end
end