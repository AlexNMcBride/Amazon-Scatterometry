function [r_anoms idxs] = find_ridge(nd)

map=zeros(size(nd));
for i=1:size(map,1)
    vert=nd(i,:);
    if max(vert)==0
        continue;
    end
    % max_idx=(vert==max(vert));
    map(:,i)=(vert==max(vert));
end

r_anoms=zeros(1,size(map,1));
idxs=zeros(1,size(map,1));
for i=1:size(map,1)
    idx=find(map(:,i));
    if size(idx,1)==0
        idxs(i)=0;
        r_anoms(i)=NaN;
        continue;
    elseif size(idx,1)>1
        idx=idx(ceil((end-1)/2));
    end
    idxs(i)=idx;
    r_anoms(i)=a_edges(idx);
end
