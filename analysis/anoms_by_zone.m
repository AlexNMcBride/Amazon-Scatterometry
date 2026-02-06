
load("./data/ascat_scat_acc.mat")
d_mask=load('/auto/home/mcbride/Amazon-Scatterometry/data/def_zones.mat').def_mask;
p_mask=load('/auto/home/mcbride/Amazon-Scatterometry/data/pro_zones.mat').pro_mask;
m_edges=linspace(min(-10),max(-5),steps);
def_total=T(end,:).def2{1};
steps=200;
a_edges=linspace(-4,4,steps);
d_edges=linspace(0,100,steps);

idx=~isnan(T.def1);

% Zone 2 - Alta Floresta, Mato Grosso
% Zone 2 - Terra Indigena Menkragnoti
% Zone 3 - Rio Branco, Acre
% Zone 3 - Floresta Nacional Mapia-Inauini, Terra Indigena Camicua
% Zone 4 - Manaus, Amazonas
% Zone 4 - Reserva Biologica do Rio Trombetas/Uatuma
% Zone 5 - Altamira, Para
% Zone 5 - Estacao Ecologica da Terra do Meio, Terra Indigena Arawete
% Igarape Ipixuna
zone = 5; 
def_mask=(d_mask==zone);
pro_mask=(p_mask==zone);
def_tab=table('size',[0 4], 'VariableTypes', {'single' 'double' 'double' 'double'}, ...
    'VariableNames', {'defs' 'anoms' 'stds' 'means'});
pro_tab=table('size',[0 4], 'VariableTypes', {'single' 'double' 'double' 'double'}, ...
    'VariableNames', {'defs' 'anoms' 'stds' 'means'});

for i=1:size(T,1)
    t=T(i,:);
    if isnan(t.means1) || size(t.def2{1},1)==0
        continue;
    % elseif month(t.dates)~=p_month
    %     continue;
    end

    def_pix=(t.def2{1}>5 & def_mask);
    no_def_pix=(t.def2{1}<0.01 & pro_mask);
    defs=t.def2{1}(def_pix);
    anoms=t.anoms2{1}(def_pix);
    stds=t.stds2{1}(def_pix);
    means=t.means2{1}(def_pix);
    d_tab=table(defs,anoms,stds,means);
    n_tab=table(t.def2{1}(no_def_pix),t.anoms2{1}(no_def_pix),t.stds2{1}(no_def_pix),...
        t.means2{1}(no_def_pix),'VariableNames', {'defs' 'anoms' 'stds' 'means'});
    def_tab=[def_tab;d_tab];
    pro_tab=[pro_tab;n_tab];
end

figure(1)
% hold on
h1=histogram(pro_tab.anoms,a_edges);
title("Means for Protected Zone #" + num2str(zone))
% hold off

figure(2)
% hold on
h2=histogram(def_tab.anoms,a_edges);
title("Means for Deforestation Zone #" + num2str(zone))
% hold off

figure(3)
% hold on
h3=histogram(def_tab.defs,d_edges);
title("Defs for Deforestation Zone #" + num2str(zone))
% hold off