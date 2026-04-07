out="/auto/home/mcbride/Amazon-Scatterometry/data/monthly/z%d_monthly_coefs.mat";
coefs=zeros(5,12,2);
for i=2:7
    m_coefs=zeros(12,2);
    for j=1:12
        m_coefs(j,:)=anoms_by_month_zone(i,j);
    end
    coefs(i-1,:,:)=m_coefs;
    output=sprintf(out,i);
    % save(output,"m_coefs");
end

