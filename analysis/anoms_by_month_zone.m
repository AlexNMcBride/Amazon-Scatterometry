load("/auto/home/mcbride/Amazon-Scatterometry/data/ascat_scat_acc.mat")
d_mask=load('/auto/home/mcbride/Amazon-Scatterometry/data/def_zones.mat').def_mask;
p_mask=load('/auto/home/mcbride/Amazon-Scatterometry/data/pro_zones.mat').pro_mask;

d_output=sprintf("/auto/home/mcbride/Amazon-Scatterometry/data/t_zone_month_def_anoms.mat");
p_output=sprintf("/auto/home/mcbride/Amazon-Scatterometry/data/t_zone_month_pro_anoms.mat");

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


def_tab=table('size',[0 6], 'VariableTypes', {'int8' 'int8' 'single' 'double' 'double' 'double'}, ...
    'VariableNames', {'zone' 'd_month' 'defs' 'anoms' 'stds' 'means'});
pro_tab=table('size',[0 6], 'VariableTypes', {'int8' 'int8' 'single' 'double' 'double' 'double'}, ...
    'VariableNames', {'zone' 'd_month' 'defs' 'anoms' 'stds' 'means'});
ref_mean = zeros(size(T,1),1);
for d_month=1:12
    for zone=2:6
        def_mask=(d_mask==zone);
        pro_mask=(p_mask==zone);
        for i=1:size(T,1)
            t=T(i,:);
            if isnan(t.means1) || size(t.def2{1},1)==0
                ref_mean(i)=NaN;
                continue;
            elseif month(t.dates)~=d_month
                continue;
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
            d_tab=table(repmat(zone,size(defs)),repmat(d_month,size(defs)),defs,anoms,stds,means,'VariableNames', {'zone' 'd_month' 'defs' 'anoms' 'stds' 'means'});
            n_tab=table(repmat(zone,size(t.def2{1}(no_def_pix))),repmat(d_month,size(t.def2{1}(no_def_pix))),t.def2{1}(no_def_pix),t.means2{1}(no_def_pix)-ref_mean(i),t.stds2{1}(no_def_pix),...
                t.means2{1}(no_def_pix),'VariableNames', {'zone' 'd_month' 'defs' 'anoms' 'stds' 'means'});
            def_tab=[def_tab;d_tab];
            pro_tab=[pro_tab;n_tab];
        end
    end
end

figure(1)
steps=100;
hist(def_tab.anoms,steps)
xlim([-5 2])

figure(2)
d_edges=linspace(0,100,steps);
a_edges=linspace(-5,2,steps);
a_coef=polyfit(def_tab.defs,def_tab.anoms,1);
a_fit=polyval(a_coef,d_edges);
nd=histcounts2(def_tab.defs,def_tab.anoms,d_edges,a_edges);
imagesc(d_edges,a_edges,nd')
title("Def vs. Anomaly for Zone #" + num2str(zone) + " Month #" + num2str(d_month))
hold on
plot(d_edges,a_fit)
cmap=parula;
cmap(1,:)=1;
colormap(cmap)
set(gca,"YDir","normal")
xlabel("Deforestation Percentage")
ylabel("\sigma^0 Anomaly (dB)")
hold off

save(d_output,"def_tab")
save(p_output,"pro_tab")
