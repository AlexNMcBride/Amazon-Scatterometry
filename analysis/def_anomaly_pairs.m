load("./data/ascat_scat_prodes.mat")
output="./data/t_ascat_scat_prodes.mat";
thresh=1.0;
% idx=~isoutlier(T.means1,"mean", "ThresholdFactor", thresh);
idx=T.def1~=0 & ~isnan(T.def1);
T=T(idx,:);
entries=size(T.dates,1);
all_tab=table('size',[0 4], 'VariableTypes', {'single' 'double' 'double' 'double'}, ...
    'VariableNames', {'defs' 'anoms' 'stds' 'means'});
no_def_tab=table('size',[0 4], 'VariableTypes', {'single' 'double' 'double' 'double'}, ...
    'VariableNames', {'defs' 'anoms' 'stds' 'means'});
def_tab=table('size',[0 4], 'VariableTypes', {'single' 'double' 'double' 'double'}, ...
    'VariableNames', {'defs' 'anoms' 'stds' 'means'});
for i=1:entries
    t=T(i,:);
    if isnan(t.means1)
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
save(output,"all_tab","no_def_tab","def_tab","-v7.3")
% [U,S,V]=svd(table2array(all_tab),"econ");
% d=table2array(def_tab(def_tab.defs==max(def_tab.defs),:));