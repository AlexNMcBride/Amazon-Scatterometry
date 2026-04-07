load("/auto/home/mcbride/Amazon-Scatterometry/data/ascat_scat_acc.mat")
wet_output="/auto/home/mcbride/Amazon-Scatterometry/data/t_wet_predict.mat";
dry_output="/auto/home/mcbride/Amazon-Scatterometry/data/t_dry_predict.mat";
t=T(end,:);

wet_pred=table('size',[0 7], 'VariableTypes', {'int8' 'double' 'double' 'double' 'double' 'double' 'double'}, ...
    'VariableNames', {'zone' 'd_tot' 'm_tot' 'r_tot' 'm_corr' 'r_corr' 'min_def'});
for zone=2:7
    [dt,mt,rt,mc,rc,md]=predict_zone(zone,t);
    w_pred=table(zone,dt,mt,rt,mc,rc,md,'VariableNames', {'zone' 'd_tot' 'm_tot' 'r_tot' 'm_corr' 'r_corr' 'min_def'});
    wet_pred=[wet_pred;w_pred];
end
t=T(end-7,:);
dry_pred=table('size',[0 7], 'VariableTypes', {'int8' 'double' 'double' 'double' 'double' 'double' 'double'}, ...
    'VariableNames', {'zone' 'd_tot' 'm_tot' 'r_tot' 'm_corr' 'r_corr' 'min_def'});
for zone=2:7
    [dt,mt,rt,mc,rc,md]=predict_zone(zone,t);
    d_pred=table(zone,dt,mt,rt,mc,rc,md,'VariableNames', {'zone' 'd_tot' 'm_tot' 'r_tot' 'm_corr' 'r_corr' 'min_def'});
    dry_pred=[dry_pred;d_pred];
end

save(wet_output,"wet_pred");
save(dry_output,"dry_pred");
