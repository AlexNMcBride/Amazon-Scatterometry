load('/auto/home/mcbride/Amazon-Scatterometry/data/ascat_scat_deter.mat');
Td=load('/auto/home/mcbride/Amazon-Scatterometry/data/tt_acc_def.mat');
output='/auto/home/mcbride/Amazon-Scatterometry/data/ascat_scat_acc.mat';
% acc_dates(1)=01-Feb-2016
% Ascat dates(end)=01-Feb-2024
acc_def=Td.T.c(1:97);
acc_dates=Td.T.dates;

acc_def1=zeros(size(acc_def));
for i=1:size(acc_def,1)
    d=acc_def(i);
    acc_def1(i)=sum(d{1},"all","omitmissing");
end
T.def2=acc_def;
T.def1=acc_def1;
save(output,"T","-v7.3")