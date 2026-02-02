function c_avg = cell1Dmean(c)
if isempty(c)
    c_avg = NaN;
else
    m=cat(3,c{:});
    c_avg=mean(m,'all',"omitmissing");
end