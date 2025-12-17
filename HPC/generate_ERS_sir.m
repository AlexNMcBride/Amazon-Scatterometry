function cmds = generate_ERS_sir(ERS_num,year,day,last_day)
% generate_ERS_sir(ERS_num,year,day,last_day)
%
% This script creates a list of the jobs to be run to create
% the CETB ERS products and the ERS input files required.
%
% Expect ~18 million measurements for 18 day image, ~6 million for 6 day.
%
% ERS-1 start date: 1991 213 (August 1, 1991) 
% ERS-1 end date: 1996 154 (June 2, 1996)
% ERS-2 start date: 1996 086 (March 26, 1996)
% ERS-2 end date: 2011 185 (July 4, 2011)
%
% written 18 Dec 2024 by DGL at BYU
% modified 23 Jun 2025 by Alex McBride

if ERS_num ~= 1 && ERS_num ~= 2
    fprintf("Invalid instrument number\n")
end
dry_run = false;
% destination directory
wdir = sprintf('/home/alexmc99/ERS_work/ERS%d/%d',ERS_num,year);
pdir = sprintf('/home/alexmc99/ERS_prod/ERS%d/%d',ERS_num,year);

% location of time-ordered ERS .dat files
if ERS_num == 1
  ers_file_name = '/home/alexmc99/ERS_work/scripts/ERS1_data_files.mat';
  location='/home/alexmc99/ERS-1';
else
  ers_file_name = '/home/alexmc99/ERS_work/scripts/ERS2_data_files.mat';
  location='/home/alexmc99/ERS-2';
end

% get list of all files in location directory
if exist(ers_file_name) == 0
  fprintf("File not found, creating...\n")
  % for each orbit file, determine measurement date
  F=dir([location,'/CYCLE_*_/ORBIT_*_*/*.nc']);
  Nf=length(F);
  for file=1:Nf    
    time_str = strsplit(F(file).name,"_");
    date_str = convertCharsToStrings(time_str(3));
    F(file).date = extractBetween(date_str,1,6);
  end
  
  % save to .mat file
  save(ers_file_name,"Nf","F");

else
  % load .mat file
  fprintf("File found\n")
  load(ers_file_name,"Nf","F");
end

% ERS-1 start date: 1991 213 (August 1, 1991) 
% ERS-1 end date: 1996 154 (June 2, 1996)
% ERS-2 start date: 1996 086 (March 26, 1996)
% ERS-2 end date: 2011 185 (July 4, 2011)
% for year=1991:1996
% for year=1996:2011
cmds = "";
file_number = 1;
for dstart=day:6:last_day
    file_number = date_start_index(F,year,dstart,file_number);
    for interval=[6,18] % imaging period
    % for interval=[6] % test for six day
    % for interval=[0] % test for one day
      eday = dstart+interval;
      [emonth eday eyear] = doy2date_wrap(eday,year);
      eday = date2doy(eyear,emonth,eday);
      fprintf("Dates: %d %d-%d\n",year,dstart,eday);
    
      file_list = ers_files(F,year,dstart,interval,file_number);
      flist_file = sprintf("%s/%d_%03d_%02d.flist",wdir,year,dstart,interval);
      flist = fopen(flist_file, 'w+');
      fprintf(flist,"%s",file_list);
      Pname=sprintf('%s/BYU-ESCAT-TEST.12.5km-ERS%d_ESCAT-%4.4d%3.3d_%4.4d%3.3d-5.3VV-B-SIR-v1.0.nc.comp',wdir,ERS_num,year,dstart,eyear,eday);
      
      % check to see if product is completed. if this one exists, assume others do too.
      % if exist(Pname,'file')==2 
      %   fprintf('skipping existing %s\n',Pname);
      %   continue
      % end
      % if get to here, file does not exist, need to create it and its siblings
    
      Reg='NST';
      %for each case (N,S,T)
      for ireg=1:3
        RegCh=Reg(ireg);
        % create make file
        cmd=sprintf('/home/dgl2/taskman/ERS/bin/ers_meta_make -r /home/dgl2/taskman/ERS/ref -M %s/E2%c_%4.4d_%3.3d_%2.2d.meta ESCAT %d %d %d /home/dgl2/taskman/ERS/def/escat_E2%cB.def %s/%4.4d_%3.3d_%2.2d.flist',wdir,RegCh,year,dstart,interval,dstart,eday,year,RegCh,wdir,year,dstart,interval);
        disp(cmd);
        if ~dry_run
            system(cmd);
        end
        % create GRD and SIR product file
        cmd=sprintf('/home/dgl2/taskman/ERS/bin/ers_cetb_sir -x /home/dgl2/taskman/ERS/bin/fixnc %s -R -s -w %s %s/E2%c_%4.4d_%3.3d_%2.2d.meta',pdir,wdir,wdir,RegCh,year,dstart,interval);
        disp(cmd);
        tstart=tic;
        if ~dry_run
            system(cmd);
        end
        telapsed=toc(tstart)/60; % time in mins
        fprintf('/nJob %4.4d %3.3d %2.2d %c took %d\n',year,dstart,interval,RegCh,telapsed);
        cmds = append(cmds,cmd + "\n");

        %disp('pausing...');pause;disp('continuing...');
    
      end
    end
end


% example commands
% ls -1 /auto/temp/long/ERS/dat/ers_1998_06.dat /auto/temp/long/ERS/dat/ers_1998_07.dat > work/1998_180_18.flist
% /auto/home/long/src/linux/newSCP/ERS/bin/ers_meta_make -M work/E2N_1998_180_006.meta ESCAT 180 185 1998 def/escat_E2NB.def work/1998_180_6.flist
% /auto/home/long/src/linux/newSCP/ERS/bin/ers_cetb_sir -x /auto/home/long/src/linux/newSCP/TRMMPR/bin/fixnc /auto/temp/long/TRMMPR/final -R -s -w work work/E2T_1998_180_006.meta

end
