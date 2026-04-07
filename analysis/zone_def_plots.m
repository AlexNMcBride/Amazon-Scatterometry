zone = 7;

d_output=sprintf("/auto/home/mcbride/Amazon-Scatterometry/data/zone_%d_def_anoms.mat",zone);
p_output=sprintf("/auto/home/mcbride/Amazon-Scatterometry/data/zone_%d_pro_anoms.mat",zone);
load(d_output);
load(p_output);

def_tab=def_tab(def_tab.defs>1,:);
pro_tab=pro_tab(pro_tab.defs<.1,:);

steps=100;
d_edges=linspace(0,100,steps);
a_edges=linspace(-5,2,steps);
m_edges=linspace(min(def_tab.means),max(def_tab.means),steps);
nd=histcounts2(def_tab.defs,def_tab.anoms,d_edges,a_edges);

figure(2)
a_coef=polyfit(def_tab.defs,def_tab.anoms,1);
a_fit=polyval(a_coef,d_edges);
imagesc(d_edges,a_edges,nd')
title("Def vs. Anomaly for Zone #" + num2str(zone))
hold on
plot(d_edges,a_fit)
cmap=parula;
cmap(1,:)=1;
colormap(cmap)
set(gca,"YDir","normal")
xlabel("Deforestation Percentage")
ylabel("\sigma^0 Anomaly (dB)")
hold off

% figure(2)
% h2=histogram2(def_tab.defs,def_tab.anoms,d_edges,a_edges);
% title("Def vs. Anomaly for Zone #" + num2str(zone))
% xlabel("Deforestation Percentage")
% ylabel("\sigma^0 Anomaly (dB)")
% h2.FaceColor="flat";

figure(3)
histogram(def_tab.defs)
title("Def Percentages for Zone #" + num2str(zone))
xlabel("Deforestation Percentage")
ylabel("Number of Pixels")

figure(4)
histogram(def_tab.anoms)
title("Anomaly for Protected Zone #" + num2str(zone))
xlabel("\sigma^0 Anomaly (dB)")
ylabel("Number of Pixels")
