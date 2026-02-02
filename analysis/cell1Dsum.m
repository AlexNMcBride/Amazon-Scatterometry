function c_sum = cell1Dsum(c)
if isempty(c)
    c_sum = NaN;
else
    m=cat(3,c{:});
    c_sum=sum(m,"all","omitmissing");
end