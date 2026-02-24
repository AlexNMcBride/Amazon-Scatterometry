load("/auto/home/mcbride/Amazon-Scatterometry/data/ascat_scat_acc.mat")
wet_output="/auto/home/mcbride/Amazon-Scatterometry/data/t_wet_predict.mat";
dry_output="/auto/home/mcbride/Amazon-Scatterometry/data/t_dry_predict.mat";
t=T(end,:);

wet_pred=table('size',[5 7], 'VariableTypes', {'int8' 'double' 'double' 'double' 'double' 'double' 'double'}, ...
    'VariableNames', {'zone' 'd_tot' 'm_tot' 'r_tot' 'm_corr' 'r_corr' 'min_def'});
for zone=2:6
    [dt,mt,rt,mc,rc,md]=predict_zone(zone,t);
    wet_pred(zone-1,:)=table(zone,dt,mt,rt,mc,rc,md,'VariableNames', {'zone' 'd_tot' 'm_tot' 'r_tot' 'm_corr' 'r_corr' 'min_def'});
end
t=T(end-7,:);
dry_pred=table('size',[5 7], 'VariableTypes', {'int8' 'double' 'double' 'double' 'double' 'double' 'double'}, ...
    'VariableNames', {'zone' 'd_tot' 'm_tot' 'r_tot' 'm_corr' 'r_corr' 'min_def'});
for zone=2:6
    [dt,mt,rt,mc,rc,md]=predict_zone(zone,t);
    dry_pred(zone-1,:)=table(zone,dt,mt,rt,mc,rc,md,'VariableNames', {'zone' 'd_tot' 'm_tot' 'r_tot' 'm_corr' 'r_corr' 'min_def'});
end

save(wet_output,"wet_pred");
save(dry_output,"dry_pred");
