function [dboxy,dboxx] = get_def_box(zone)

if zone==2
    % Zone 2 - Alta Floresta, Mato Grosso
    dboxy=435:490;
    dboxx=315:370;
elseif zone==3
    % Zone 3 - Rio Brance, Acre
    dboxy=382:415;
    dboxx=175:197;
elseif zone==4
    % Zone 4 - Roraima
    dboxy=180:215;
    dboxx=285:315;
elseif zone==5
    % Zone 5 - Altamira, Para
    dboxy=260:285;
    dboxx=405:430;
elseif zone==6
    % Zone 6 - Ipixuna, Amazonas
    dboxy=335:380;
    dboxx=95:155;
else
    dboxy=1:570;
    dboxx=1:558;
end
