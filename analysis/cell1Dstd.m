function c_std = cell1Dstd(c)
if isempty(c)
    c_std = NaN;
else
    m=cat(3,c{:});
    c_std=std(m,0,"all","omitmissing");
end