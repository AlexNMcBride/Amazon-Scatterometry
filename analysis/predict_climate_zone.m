load("/auto/home/mcbride/Amazon-Scatterometry/data/t_dry_reg_coefs.mat");
load("/auto/home/mcbride/Amazon-Scatterometry/data/t_wet_reg_coefs.mat");
climate=load("/auto/home/mcbride/Amazon-Scatterometry/data/climate_zones.mat").clip;
load("/auto/home/mcbride/Amazon-Scatterometry/data/ascat_scat_acc.mat");
def_mask=load("/auto/home/mcbride/Amazon-Scatterometry/data/def_zones.mat").def_mask;
pro_mask=load("/auto/home/mcbride/Amazon-Scatterometry/data/pro_zones.mat").pro_mask;
mask=load('/auto/home/mcbride/Amazon-Scatterometry/data/master_mask.mat').mask;
w_output="/auto/home/mcbride/Amazon-Scatterometry/data/t_wet_ama_predict.mat";
d_output="/auto/home/mcbride/Amazon-Scatterometry/data/t_dry_ama_predict.mat";

t=T(end,:);
wet_def=t.def2{1};
wet_mean=t.means2{1};
dry_months=[7:9];
wet_months=[1:6,10:12];
wet=ismember(month(t.dates), wet_months);
if wet
    reg_tab=load("/auto/home/mcbride/Amazon-Scatterometry/data/t_wet_reg_coefs.mat").wet_tab;
else
    reg_tab=load("/auto/home/mcbride/Amazon-Scatterometry/data/t_dry_reg_coefs.mat").dry_tab;
end

wet_ama=table('size',[0 7], 'VariableTypes', {'int8' 'int8' 'double' 'double' 'double' 'double' 'double'}, ...
    'VariableNames', {'pred_zone' 'climate_zone' 'd_tot' 'm_tot' 'r_tot' 'm_corr' 'r_corr'});

for zone=2:7
    if (zone == 4 || zone == 6)
        climate_zone = 1;
    elseif (zone == 3 || zone == 5)
        climate_zone = 2;
    elseif (zone == 2 || zone == 7)
        climate_zone = 3;
    end
    regs=reg_tab(zone-1,:);
    c=climate;
    c(climate~=climate_zone)=0;
    climate_mask = logical(c.*mask);
    d = wet_def .* climate_mask;
    d_tot = sum(d,"all","omitmissing");
    regs = reg_tab(zone-1,:);
    a = t.means2{1} - regs.mean;
    a(~climate_mask) = NaN;
    m_coefs=[regs.m_mean regs.b_mean];
    mi_coefs=invert_fit(m_coefs);
    r_coefs=[regs.m_ridge regs.b_ridge];
    ri_coefs=invert_fit(r_coefs);
    m_pred=polyval(m_coefs,a);
    r_pred=polyval(r_coefs,a);
    min_def=polyval(r_coefs,ri_coefs(2)-regs.std);
    d_min=d;
    d_min(d_min<min_def)=0; 
    % threshold deforestation values
    d_min=d;
    d_min(d_min<min_def)=0;
    m_pred(m_pred<min_def | isnan(m_pred))=0;
    r_pred(r_pred<min_def | isnan(r_pred))=0;
    m_pred(m_pred>100)=100;
    r_pred(r_pred>100)=100;
    m_tot=sum(m_pred,"all","omitmissing");
    r_tot=sum(r_pred,"all","omitmissing");
    m_corr=corr2(d_min,m_pred);
    r_corr=corr2(d_min,r_pred);
    w_tab = table(zone, climate_zone, d_tot, m_tot, r_tot, m_corr, r_corr, ...
    'VariableNames', {'pred_zone' 'climate_zone' 'd_tot' 'm_tot' 'r_tot' 'm_corr' 'r_corr'});
    wet_ama = [wet_ama;w_tab];
end

t=T(end-7,:);
dry_def=t.def2{1};
dry_mean=t.means2{1};
dry_ama=table('size',[0 7], 'VariableTypes', {'int8' 'int8' 'double' 'double' 'double' 'double' 'double'}, ...
    'VariableNames', {'pred_zone' 'climate_zone' 'd_tot' 'm_tot' 'r_tot' 'm_corr' 'r_corr'});

for zone=2:7
    if (zone == 4 || zone == 6)
        climate_zone = 1;
    elseif (zone == 3 || zone == 5)
        climate_zone = 2;
    elseif (zone == 2 || zone == 7)
        climate_zone = 3;
    end
    regs=reg_tab(zone-1,:);
    c=climate;
    c(climate~=climate_zone)=0;
    climate_mask = logical(c.*mask);
    d = dry_def .* climate_mask;
    d_tot = sum(d,"all","omitmissing");
    regs = reg_tab(zone-1,:);
    a = t.means2{1} - regs.mean;
    a(~climate_mask) = NaN;
    m_coefs=[regs.m_mean regs.b_mean];
    mi_coefs=invert_fit(m_coefs);
    r_coefs=[regs.m_ridge regs.b_ridge];
    ri_coefs=invert_fit(r_coefs);
    m_pred=polyval(m_coefs,a);
    r_pred=polyval(r_coefs,a);
    min_def=polyval(r_coefs,ri_coefs(2)-regs.std);
    % threshold deforestation values
    d_min=d;
    d_min(d_min<min_def)=0;
    m_pred(m_pred<min_def | isnan(m_pred))=0;
    r_pred(r_pred<min_def | isnan(r_pred))=0;
    m_pred(m_pred>100)=100;
    r_pred(r_pred>100)=100;
    m_tot=sum(m_pred,"all","omitmissing");
    r_tot=sum(r_pred,"all","omitmissing");
    m_corr=corr2(d_min,m_pred);
    r_corr=corr2(d_min,r_pred);
    d_tab = table(zone, climate_zone, d_tot, m_tot, r_tot, m_corr, r_corr, ...
    'VariableNames', {'pred_zone' 'climate_zone' 'd_tot' 'm_tot' 'r_tot' 'm_corr' 'r_corr'});
    dry_ama = [dry_ama;d_tab];
end
wet_ama
dry_ama
