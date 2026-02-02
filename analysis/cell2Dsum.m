function c_sums = cell2Dsum(c)
if isempty(c)
    c_sums = {};
else
    m=cat(3,c{:});
    c_sums={sum(m,3,"omitmissing")};
end



