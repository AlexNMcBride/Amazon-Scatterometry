load('/auto/home/mcbride/Amazon-Scatterometry/data/tt_prodes.mat')
load('/auto/home/mcbride/Amazon-Scatterometry/data/tt_deter.mat')
def_2000=load('/auto/home/mcbride/Amazon-Scatterometry/data/2000_acc_def.mat');
def_2007=load('/auto/home/mcbride/Amazon-Scatterometry/data/2007_acc_def.mat');
output='/auto/home/mcbride/Amazon-Scatterometry/data/tt_acc_def.mat';
% include accumulated deforestation
Tp2y.c(1)= {Tp2y.c{1} + def_2000.clip};
Tp2y.c(5)= {def_2007.clip};
start_year=year(Tp2y.dates(1));
accum_prodes=Tp2y.c;
accum_dates=Tp2y.dates+calyears(1);
for i=1:size(Tp2y,1)
    def=cell2Dsum(Tp2y.c(1:i));
    accum_prodes(i)=def;
end

dates_deter = Td2.dates;
accum_deter=Td2.c;
cur_year=year(Td2.dates(1));
year_idx=1;
for j=1:size(Td2,1)
    if year(Td2.dates(j))~=cur_year
        year_idx=j;
        cur_year=year(Td2.dates(j));
    end
    p_def=accum_prodes(cur_year-start_year);
    det=cell2Dsum(Td2.c(year_idx:j));
    if size(det{1},1)~=0
        accum_def={p_def{1} + det{1}};
        accum_deter(j)=accum_def;
    end
end
c=accum_deter;
dates=dates_deter;
T=timetable(dates,c);
save(output,'T')