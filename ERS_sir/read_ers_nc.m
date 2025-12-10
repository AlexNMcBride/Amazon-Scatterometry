function ers = read_ers_nc(filename)
    %function ers=read_ers_nc(filename)
    %
    % ers=read_ers_nc(filename)
    %
    % inputs: filename
    %
    % outputs: structure ers which contains the key contents of the ERS netcdf file
    %
    % matlab routine to read the contents of an ERS .NC file into a matlab
    % structure
    
    % written by DGL at BYU 05 May 2025
    % filename='ASPS20_H_910801051457.nc';
    
    ers=[];
    display = true;
    % check file existence
    if exist(filename,'file')==2  % if file exists, process
    
      % open netcdf read
      ncid=netcdf.open(filename,'NC_NOWRITE');
      if ncid==0
        disp('**** could not open file for reading');
        return;
      end
      ers.filename=filename;
      
      % get file array dimensions
      [dimname1,ers.numrows]=netcdf.inqDim(ncid,0);
      [dimname1,ers.numcells]=netcdf.inqDim(ncid,1);
      [dimname2,ers.numbeams]=netcdf.inqDim(ncid,2);
      
      % close netcdf interface, here after use high level routines
      netcdf.close(ncid);
        
      % get global attributes
      NC_GLOBAL='/';
      ers.title=ncreadatt(filename,NC_GLOBAL,'Title');
      ers.start_date_time=ncreadatt(filename,NC_GLOBAL,'start_date_time');
      ers.stop_date_time=ncreadatt(filename,NC_GLOBAL,'stop_date_time');
      
      % data scientific datasets
      ers.time=ncread(filename,'time');  % row time (sec since 1950-01-01 0:0:0 UTC)
      ers.head=ncread(filename,'head');  % heading w/respec to North
      ers.lon=ncread(filename,'lon')*0.001; % WVC longitude
      ers.lat=ncread(filename,'lat')*0.001; % WVC latitude
      ers.sigma0=ncread(filename,'sigma0'); % sigma0 triplet (fore,mid,aft)
      ers.kp=ncread(filename,'kp');      % Kp (fore,mid,aft)
      ers.inc=ncread(filename,'inc_angle_trip'); % incidence angle (fore,mid,aft)
      ers.azi=ncread(filename,'azi_angle_trip'); % azimuth angle (fore,mid,aft)
      ers.number_of_samples=ncread(filename,'number_of_samples'); %
      ers.node_confidence_data1_sigma0=ncread(filename,'node_confidence_data1_sigma0'); % 
      ers.node_confidence_data2_sigma0=ncread(filename,'node_confidence_data2_sigma0'); % 
      if display
          disp(ers)
          myfigure(1)
          title("Latlong Location of Measurements")
          plot(ers.lon(:,:,1),ers.lat(:,:,1),'.')
        %  axis([-180 360 -90 90])
          myfigure(2)
          title("Middle Antenna \sigma^0")
          imagesc(ers.sigma0(:,:,2),[-30,0]);colorbar;
          myfigure(3)
          title("Middle Antenna Incidence Angle")
          imagesc(ers.inc(:,:,2),[0,50]);colorbar;
          myfigure(4)
          title("Middle Antenna Azimuth Angle")
          imagesc(ers.azi(:,:,2),[0,360]);colorbar;
      end
    else 
        fprintf("File not found\n")
    end
end