clear
load("/auto/home/mcbride/Amazon-Scatterometry/data/ascat_scat_acc.mat")
d_mask=load('/auto/home/mcbride/Amazon-Scatterometry/data/def_zones.mat').def_mask;
p_mask=load('/auto/home/mcbride/Amazon-Scatterometry/data/pro_zones.mat').pro_mask;
zone=6;
d_output=sprintf("/auto/home/mcbride/Amazon-Scatterometry/data/zone_%d_def_anoms.mat",zone);
p_output=sprintf("/auto/home/mcbride/Amazon-Scatterometry/data/zone_%d_pro_anoms.mat",zone);

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
def_mask=(d_mask==zone);
pro_mask=(p_mask==zone);

def_tab=table('size',[0 4], 'VariableTypes', {'single' 'double' 'double' 'double'}, ...
    'VariableNames', {'defs' 'anoms' 'stds' 'means'});
pro_tab=table('size',[0 4], 'VariableTypes', {'single' 'double' 'double' 'double'}, ...
    'VariableNames', {'defs' 'anoms' 'stds' 'means'});
ref_mean = zeros(size(T,1),1);
for i=1:size(T,1)
    t=T(i,:);
    if isnan(t.means1) || size(t.def2{1},1)==0
        ref_mean(i)=NaN;
        continue;
    % elseif month(t.dates)~=p_month
    %     continue;
    end
    def_pix=def_mask;
    no_def_pix=pro_mask;
    ref_pix=pro_mask & t.def2{1}<0.01;
    ref=mean(t.means2{1}(ref_pix),"all","omitmissing");
    ref_mean(i)=ref;
    defs=t.def2{1}(def_pix);
    anoms=t.means2{1}(def_pix)-ref_mean(i);
    stds=t.stds2{1}(def_pix);
    means=t.means2{1}(def_pix);
    d_tab=table(defs,anoms,stds,means);
    n_tab=table(t.def2{1}(no_def_pix),t.means2{1}(no_def_pix)-ref_mean(i),t.stds2{1}(no_def_pix),...
        t.means2{1}(no_def_pix),'VariableNames', {'defs' 'anoms' 'stds' 'means'});
    def_tab=[def_tab;d_tab];
    pro_tab=[pro_tab;n_tab];
end
plot(ref_mean)
save(d_output,"def_tab")
save(p_output,"pro_tab")
