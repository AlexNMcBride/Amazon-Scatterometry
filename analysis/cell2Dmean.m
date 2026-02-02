function c_avgs = cell2Dmean(c)
if isempty(c)
    c_avgs = {};
else
    m=cat(3,c{:});
    c_avgs={mean(m,3,"omitmissing")};
end