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

% invert linear fit
m=a_coef(1);
b=a_coef(2);
x_int=b/m;
a_inv=polyval([1/m x_int],a_edges);

% apply to timetable
dates=T.dates;
anoms2=T.anoms2;
