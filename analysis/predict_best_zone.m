load("/auto/home/mcbride/Amazon-Scatterometry/data/t_dry_reg_coefs.mat");
load("/auto/home/mcbride/Amazon-Scatterometry/data/t_wet_reg_coefs.mat");
climate=load("/auto/home/mcbride/Amazon-Scatterometry/data/climate_zones.mat").clip;
load("/auto/home/mcbride/Amazon-Scatterometry/data/ascat_scat_acc.mat");
mask=load('/auto/home/mcbride/Amazon-Scatterometry/data/master_mask.mat').mask;

t=T(end,:);
wet_def=t.def2{1};
dry_months=[7:9];
wet_months=[1:6,10:12];
wet=ismember(month(t.dates), wet_months);
if wet
    reg_tab=load("/auto/home/mcbride/Amazon-Scatterometry/data/t_wet_reg_coefs.mat").wet_tab;
else
    reg_tab=load("/auto/home/mcbride/Amazon-Scatterometry/data/t_dry_reg_coefs.mat").dry_tab;
end
wet_accum=zeros(size(wet_def));
% Zone 2 - Climate zone 3, corr 0.80911
% Zone 3 - Climate zone 2, corr 0.5264
% Zone 4 - Climate zone 1, corr 0.22015
% Zone 5 - Climate zone 2, corr 0.52728
% Zone 6 - Climate zone 1, corr 0.18762
% Zone 7 - Climate zone 3, corr 0.80761
for zone=[2,4,5]
    if (zone == 4 || zone == 6)
        climate_zone = 1;
    elseif (zone == 3 || zone == 5)
        climate_zone = 2;
    elseif (zone == 2 || zone == 7)
        climate_zone = 3;
    end
    regs=reg_tab(zone-1,:);
    c=climate;
    c(climate~=zone)=0;
    climate_mask = logical(c.*mask);
    d = wet_def .* climate_mask;
    d_tot = sum(d,"all","omitmissing");
    regs = reg_tab(zone-1,:);
    a = t.means2{1} - regs.mean;
    a(~climate_mask) = NaN;
    r_coefs=[regs.m_ridge regs.b_ridge];
    ri_coefs=invert_fit(r_coefs);
    r_pred=polyval(r_coefs,a);
    min_def=polyval(r_coefs,ri_coefs(2)-regs.std);
    r_pred(r_pred<min_def | isnan(r_pred))=0;
    r_pred(r_pred>100)=100;
    wet_accum=wet_accum+r_pred;
end

t=T(end-7,:);
dry_def=t.def2{1};
dry_accum=zeros(size(dry_def));

for zone=[2,4,5]
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
    climate_mask = (c.*mask);
    d = dry_def .* climate_mask;
    d_tot = sum(d,"all","omitmissing");
    regs = reg_tab(zone-1,:);
    a = t.means2{1} - regs.mean;
    a(~climate_mask) = NaN;
    r_coefs=[regs.m_ridge regs.b_ridge];
    ri_coefs=invert_fit(r_coefs);
    r_pred=polyval(r_coefs,a);
    min_def=polyval(r_coefs,ri_coefs(2)-regs.std);
    r_pred(r_pred<min_def | isnan(r_pred))=0;
    r_pred(r_pred>100)=100;
    dry_accum=dry_accum+r_pred;
end
