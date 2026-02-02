close all
def_file="./data/t_ascat_scat_deter.mat";
scat_file="./data/ascat_scat_deter.mat";
load(def_file)
load(scat_file)
steps=100;
d_edges=linspace(min(def_tab.defs),max(def_tab.defs),steps);
a_edges=linspace(min(def_tab.anoms),max(def_tab.anoms),steps);
s_edges=linspace(min(def_tab.stds),max(def_tab.stds),steps);
m_edges=linspace(min(def_tab.means),max(def_tab.means),steps);
a_coef=polyfit(def_tab.defs,def_tab.anoms,1);
a_fit=polyval(a_coef,d_edges);
% figure(1)
% hold on
% title("Deforestion vs. \sigma^0 Anomaly (DETER)")
% ylabel("\sigma^0 Anomaly (dB)")
% xlabel("Deforestation Area (% of Pixel)")
% scatter(def_tab.defs,def_tab.anoms,'.')
% plot(d_edges,a_fit,'LineWidth',2)
% xlim([min(def_tab.defs) max(def_tab.defs)])
% grid on
% hold off


m=a_coef(1);
b=a_coef(2);
x_int=b/m;
a_inv=polyval([1/m x_int],a_edges);
% figure(2)
% hold on
% title("DETER \sigma^0 Anomaly vs. Deforestation (DETER)")
% xlabel("\sigma^0 Anomaly (dB)")
% ylabel("Deforestation Area (% of Pixel)")
% scatter(def_tab.anoms,def_tab.defs,'.')
% plot(a_edges,b_fit,'LineWidth',2)
% ylim([min(def_tab.defs) max(def_tab.defs)])
% grid on
% hold off

