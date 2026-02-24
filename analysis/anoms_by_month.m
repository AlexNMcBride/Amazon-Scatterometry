load("/auto/home/mcbride/Amazon-Scatterometry/data/ascat_scat_acc.mat")
steps=200;
a_edges=linspace(-4,4,steps);
idx=~isnan(T.def1);
T=T(idx,:);

p_month=9;

all_tab=table('size',[0 4], 'VariableTypes', {'single' 'double' 'double' 'double'}, ...
    'VariableNames', {'defs' 'anoms' 'stds' 'means'});
no_def_tab=table('size',[0 4], 'VariableTypes', {'single' 'double' 'double' 'double'}, ...
    'VariableNames', {'defs' 'anoms' 'stds' 'means'});
def_tab=table('size',[0 4], 'VariableTypes', {'single' 'double' 'double' 'double'}, ...
    'VariableNames', {'defs' 'anoms' 'stds' 'means'});
for i=1:size(T,1)
    t=T(i,:);
    if isnan(t.means1) || size(t.def2{1},1)==0
        continue;
    elseif month(t.dates)~=p_month
        continue;
    end
    all_pix=~isnan(t.means2{1});
    def_pix=t.def2{1}>0.01;
    no_def_pix=(t.def2{1}<0.01 & ~isnan(t.means2{1}));
    defs=t.def2{1}(def_pix);
    anoms=t.anoms2{1}(def_pix);
    stds=t.stds2{1}(def_pix);
    means=t.means2{1}(def_pix);
    d_tab=table(defs,anoms,stds,means);
    a_tab=table(t.def2{1}(all_pix),t.anoms2{1}(all_pix),t.stds2{1}(all_pix),...
        t.means2{1}(all_pix),'VariableNames', {'defs' 'anoms' 'stds' 'means'});
    n_tab=table(t.def2{1}(no_def_pix),t.anoms2{1}(no_def_pix),t.stds2{1}(no_def_pix),...
        t.means2{1}(no_def_pix),'VariableNames', {'defs' 'anoms' 'stds' 'means'});
    all_tab=[all_tab;a_tab];
    def_tab=[def_tab;d_tab];
    no_def_tab=[no_def_tab;n_tab];
end
h1=histogram(no_def_tab.anoms,a_edges);
h1.EdgeColor="none";
title("Anoms for Month: " + num2str(p_month))
