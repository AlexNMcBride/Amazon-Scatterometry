clear
load("/auto/home/mcbride/Amazon-Scatterometry/data/ascat_scat_acc.mat")
d_tab=load("/auto/home/mcbride/Amazon-Scatterometry/data/t_zone_month_def_anoms.mat").def_tab;
def_mask=load('/auto/home/mcbride/Amazon-Scatterometry/data/def_zones.mat').def_mask;
pro_mask=load('/auto/home/mcbride/Amazon-Scatterometry/data/pro_zones.mat').pro_mask;

def_min=0.1;
t=T(end,:);
% t=T(end-7,:);
zone=3;
steps=100;
a_range=[-5 2];
d_range=[0 100];
d_edges=linspace(0,100,steps);
a_edges=linspace(-5,2,steps);
d_mask=(def_mask==zone);
p_mask=(pro_mask==zone);
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
d=t.def2{1}(ys,xs);
a=t.anoms2{1}(ys,xs);
regs=reg_tab(zone-1,:);
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

% plot comparison
figure(1)
subplot(2,2,1)
imagesc(d_min)
subtitle("Deforestation Area")
colorbar
caxis(d_range)

subplot(2,2,2)
imagesc(r_pred)
subtitle("Ridge Regression Prediction")
colorbar
caxis(d_range)

subplot(2,2,3)
imagesc(m_pred)
subtitle("Mean Regression Prediction")
colorbar
caxis(d_range)

subplot(2,2,4)
m_fit=polyval(invert_fit(m_coefs),d_edges);
r_fit=polyval(invert_fit(r_coefs),d_edges);
nd=histcounts2(def_tab.defs,def_tab.anoms,d_edges,a_edges);
imagesc(d_edges,a_edges,nd')
set(gca,"YDir","normal")
subtitle("Def vs. Anomaly for Zone #" + num2str(zone))
hold on
xlim(d_range)
ylim(a_range)
plot(d_edges,m_fit,d_edges,r_fit)
yline(r_fit(1)-regs.std)
legend("Mean fit","Ridge fit", "Noise Threshold (mean-1\sigma)")
cmap=parula;
cmap(1,:)=1;
colormap(cmap)
xlabel("Deforestation Percentage")
ylabel("\sigma^0 Anomaly (dB)")
hold off

% stats
d_tot=sum(d_min,"all");
m_tot=sum(m_pred,"all");
m_corr=corr2(d_min,m_pred);
r_tot=sum(r_pred,"all");
r_corr=corr2(d_min,r_pred);

