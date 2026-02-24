% Note: the polyfit coefficients are inverted so x=anomaly and y=deforestation
def_tab=load("/auto/home/mcbride/Amazon-Scatterometry/data/t_zone_month_def_anoms.mat").def_tab;
pro_tab=load("/auto/home/mcbride/Amazon-Scatterometry/data/t_zone_month_pro_anoms.mat").pro_tab;
dry_output="/auto/home/mcbride/Amazon-Scatterometry/data/t_dry_reg_coefs.mat";
wet_output="/auto/home/mcbride/Amazon-Scatterometry/data/t_wet_reg_coefs.mat";

dry_months = [7:9];
wet_months=[1:6,10:12];

wet_tab=table('size',[5 7], 'VariableTypes', {'int8' 'double' 'double' 'double' 'double' 'double' 'double'}, ...
    'VariableNames', {'zone' 'm_mean' 'b_mean' 'm_ridge' 'b_ridge' 'mean' 'std'});
steps=100;
def_min=0.1;
d_edges=linspace(0,100,steps);
a_edges=linspace(-5,2,steps);
for zone=2:6
    d_idx=(def_tab.zone==zone & ismember(def_tab.d_month,wet_months) & def_tab.defs>def_min);
    zd_tab=def_tab(d_idx,:);
    p_idx=(pro_tab.zone==zone & ismember(pro_tab.d_month,wet_months)& pro_tab.defs<def_min);
    zp_tab=pro_tab(p_idx,:);
    p_mean=mean(zp_tab.means);
    p_std=std(zp_tab.anoms);
    nd=histcounts2(zd_tab.defs,zd_tab.anoms,d_edges,a_edges);
    % get mean fit
    a_coef=polyfit(zd_tab.defs,zd_tab.anoms,1);
    m_coefs=invert_fit(a_coef);
    % get mode fit
    r_anoms=find_ridge(nd,a_edges);
    r_edges=d_edges(2:end);
    idx=~isnan(r_anoms);
    b_coef=polyfit(d_edges(idx),r_anoms(idx),1);
    r_coefs=invert_fit(b_coef);
    w_tab=table(zone, m_coefs(1),m_coefs(2),r_coefs(1),r_coefs(2),p_mean,p_std, 'VariableNames', ...
        {'zone' 'm_mean' 'b_mean' 'm_ridge' 'b_ridge' 'mean' 'std'});
    wet_tab(zone-1,:)=w_tab;
end

for zone=2:6
    d_idx=(def_tab.zone==zone & ismember(def_tab.d_month,dry_months) & def_tab.defs>def_min);
    zd_tab=def_tab(d_idx,:);
    p_idx=(pro_tab.zone==zone & ismember(pro_tab.d_month,dry_months)& pro_tab.defs<def_min);
    zp_tab=pro_tab(p_idx,:);
    p_mean=mean(zp_tab.means);
    p_std=std(zp_tab.anoms);
    nd=histcounts2(zd_tab.defs,zd_tab.anoms,d_edges,a_edges);
    % get mean fit
    a_coef=polyfit(zd_tab.defs,zd_tab.anoms,1);
    m_coefs=invert_fit(a_coef);
    % get mode fit
    r_anoms=find_ridge(nd,a_edges);
    r_edges=d_edges(2:end);
    idx=~isnan(r_anoms);
    b_coef=polyfit(d_edges(idx),r_anoms(idx),1);
    r_coefs=invert_fit(b_coef);
    d_tab=table(zone, m_coefs(1),m_coefs(2),r_coefs(1),r_coefs(2),p_mean,p_std, 'VariableNames', ...
        {'zone' 'm_mean' 'b_mean' 'm_ridge' 'b_ridge' 'mean' 'std'});
    dry_tab(zone-1,:)=d_tab;
end
