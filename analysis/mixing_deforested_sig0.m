load('/auto/home/mcbride/Amazon-Scatterometry/data/ascat_scat_prodes.mat')
def2=T.def2;
dates=T.dates;
Td=timetable(dates,def2);
Ty=retime(Td,"yearly",@cell2Dmean);
years=Ty(2:end,:).dates;
def_total=Ty.def2;
max_def=zeros(size(Ty,1),1);
for i=1:size(Ty,1)
    total=cell2Dsum(Ty(1:i,:).def2);
    def_total(i)=total;
    max_def(i)=max(total{1},[],"all");
end
hold on
imagesc(total{1})
c=colorbar;
caxis([0 max_def(end)]);
cmap=parula;
cmap(1,:)=0;
colormap(cmap)
