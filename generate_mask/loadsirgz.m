function [img head]=loadsirgz(fname);
%
% function [img head]=loadsirgz(fname);
%
% equivalent to loadsir, but checks to see if file is gzipped
% and gunzips if necessary prior to reading
%

if ~exist(fname,'file')
  img=[];
  head=[];
  fprintf('*** file not found %s\n',fname);
  return;
end

if length(fname)<3
  [img head]=loadsir(fname);
  return;
end

if fname(end-2:end)=='.gz'
  tnames=gunzip(fname,'/tmp/');
  [img head]=loadsir(char(tnames{1}));
  delete(char(tnames{1}));
else
  [img head]=loadsir(fname);
end

