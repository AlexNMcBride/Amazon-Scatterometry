function c_stds = cell2Dstd(c)
if isempty(c)
    c_stds = {};
else
    m=cat(3,c{:});
    c_stds={std(m,0,3,"omitmissing")};
end