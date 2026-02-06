def_file="./data/t_ascat_scat_acc.mat";
load(def_file)
steps=100;
d_edges=linspace(min(def_tab.defs),max(def_tab.defs),steps);
a_edges=linspace(min(def_tab.anoms),max(def_tab.anoms),steps);
s_edges=linspace(min(def_tab.stds),max(def_tab.stds),steps);
m_edges=linspace(min(def_tab.means),max(def_tab.means),steps);
n=histcounts2(def_tab.defs,def_tab.anoms,d_edges,a_edges);
m=histcounts(no_def_tab.anoms,steps);
p=histcounts(def_tab.anoms,steps);
an=histcounts(all_tab.anoms,steps);
nn=an/max(an);
mn=m/max(m);
pn=p/max(p);
hold on
b1=bar(nn,a_edges);
b2=bar(pn,a_edges);
b1.FaceAlpha=.3;
b2.FaceAlpha=.3;
xlabel("\sigma^0 Anomaly (dB)")
title("Normalized Pixel Count for \sigma^0 Anomalies")
legend("All Pixels","Deforested Pixels")
hold off
% figure(1)
% hold on
% cmap=parula;
% cmap(1,:)=1;
% colormap(cmap)
% imagesc(d_edges,a_edges,n')
% set(gca,"YDir","normal")
% hold off
% histogram2(def_tab.defs,def_tab.anoms)
% xlabel("Deforestation Percentage")
% ylabel("%sigma^0 Anomaly (db)")
% set(gca,'ZScale','log')

figure(1)
a_coef=polyfit(def_tab.defs,def_tab.anoms,1);
a_fit=polyval(a_coef,d_edges);
hold on
scatter(def_tab.defs,def_tab.anoms,'.')
plot(d_edges,a_fit)
title("Def vs. Anomaly")
hold off

figure(2)
s_coef=polyfit(def_tab.stds,def_tab.defs,1);
s_fit=polyval(s_coef,d_edges);
hold on
scatter(def_tab.defs,def_tab.stds,'.')
plot(d_edges,s_fit)
title("Def vs. Std")
hold off

figure(3)
m_coef=polyfit(def_tab.defs,def_tab.means,1);
m_fit=polyval(m_coef,d_edges);
hold on
scatter(def_tab.defs,def_tab.means,'.')
plot(d_edges,m_fit)
title("Def vs. Mean")
hold off

figure(4)
histogram(def_tab.anoms,a_edges)
xline(mean(def_tab.anoms),'r','LineWidth',2)
title("\sigma^0 Anomaly Values of Deforested Pixels")
xlabel("\sigma^0 Anomaly (dB)")
ylabel("Number of Pixels")

figure(5)
hold on
histogram(all_tab.anoms,a_edges)
xline(mean(all_tab.anoms),'r','LineWidth',2)
title("\sigma^0 Anomaly Values of All Pixels")
xlabel("\sigma^0 Anomaly (dB)")
ylabel("Number of Pixels")
hold off

figure(6)
hold on
histogram(def_tab.means,m_edges)
xline(mean(def_tab.means))
hold off

figure(6)
histogram(all_tab.means,m_edges)
xline(mean(all_tab.means))
title("All Means")

figure(7)
hold on
histogram(all_tab.defs,d_edges)
xlim([0 max(def_tab.defs)])
set(gca,"Yscale","log")
xlabel("Deforestation Area (% of Pixel)")
ylabel("Number of pixels")
title("Pixel Deforestation Values (DETER)")
hold off

figure(8)
pix=max(Tn.c);
coverage=100*(pix-Tn.c)/pix;
hold on
ax=gca;
xt=datetime(year(min(Tn.dates)),1,1):calmonths(6):datetime(year(max(Tn.dates)),12,31);
ax.XTick=xt;
plot(Tn.dates,coverage,'DatetimeTickFormat','yyyy','LineWidth',1.5)
ylim([0 105])
ylabel("Amazon Coverage (% of Total Pixels)")
title("ERS-2 Amazon Coverage")