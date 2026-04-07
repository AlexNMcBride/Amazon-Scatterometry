function [d_tot m_tot r_tot m_corr r_corr min_def] = predict_zone(zone,t)

load("/auto/home/mcbride/Amazon-Scatterometry/data/ascat_scat_acc.mat")
d_tab=load("/auto/home/mcbride/Amazon-Scatterometry/data/t_zone_month_def_anoms.mat").def_tab;
def_mask=load('/auto/home/mcbride/Amazon-Scatterometry/data/def_zones.mat').def_mask;
pro_mask=load('/auto/home/mcbride/Amazon-Scatterometry/data/pro_zones.mat').pro_mask;
mask=load('/auto/home/mcbride/Amazon-Scatterometry/data/master_mask.mat').mask;

def_min=0.1;
d_mask=logical(def_mask==zone.*mask);
dry_months=[7:9];
wet_months=[1:6,10:12];

wet=ismember(month(t.dates), wet_months);
if wet
    d_idx=(d_tab.zone==zone & ismember(d_tab.d_month,wet_months) & d_tab.defs>def_min);
    def_tab=d_tab(d_idx,:);
    reg_tab=load("/auto/home/mcbride/Amazon-Scatterometry/data/t_wet_reg_coefs.mat").wet_tab;
else
    d_idx=(d_tab.zone==zone & ismember(d_tab.d_month,dry_months) & d_tab.defs>def_min);
    def_tab=d_tab(d_idx,:);
    reg_tab=load("/auto/home/mcbride/Amazon-Scatterometry/data/t_dry_reg_coefs.mat").dry_tab;
end

[ys,xs]=get_def_box(zone);
regs=reg_tab(zone-1,:);
d=t.def2{1}(ys,xs);
a=t.means2{1}(ys,xs)-regs.mean;
m_coefs=[regs.m_mean regs.b_mean];
mi_coefs=invert_fit(m_coefs);
r_coefs=[regs.m_ridge regs.b_ridge];
ri_coefs=invert_fit(r_coefs);
m_pred=polyval(m_coefs,a);
r_pred=polyval(r_coefs,a);
min_def=polyval(r_coefs,ri_coefs(2)-regs.std);
% threshold prediction values
d_min=d;
d_min(d_min<min_def)=0;
m_pred(m_pred<min_def | isnan(m_pred))=0;
r_pred(r_pred<min_def | isnan(r_pred))=0;
m_pred(m_pred>100)=100;
r_pred(r_pred>100)=100;
% stats
d_tot=sum(d_min,"all");
m_tot=sum(m_pred,"all");
m_corr=corr2(d_min,m_pred);
r_tot=sum(r_pred,"all");
r_corr=corr2(d_min,r_pred);

