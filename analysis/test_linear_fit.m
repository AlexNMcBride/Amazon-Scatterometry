close all
def_file="./data/t_ascat_scat_deter.mat";
scat_file="./data/ascat_scat_deter.mat";
load(def_file)
load(scat_file)
steps=30;
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
inv_coef=[1/m x_int];

% apply to timetable
a=T(30,:).anoms2{1};
d=T(30,:).def2{1};
d_inv=a*inv_coef(1)+inv_coef(2);
a_inv=d*a_coef(1)+a_coef(2);
figure(1)
histogram(d,d_edges)