load("data/tt_prodes.mat");
load("data/tt_deter.mat");
load("data/amazon_mask.mat");

area=6.25^2;
p_yearly_def=Tp1y.c*area;
p_monthly_def=Tp1.c*area;
d_yearly_def=Td1y.c*area;
d_monthly_def=Td1.c*area;
py_idx=(p_yearly_def>1) & (~isnan(p_yearly_def));
dy_idx=(d_yearly_def>1 & ~isnan(d_yearly_def));
pm_idx=(p_monthly_def>1) & (~isnan(p_monthly_def));
dm_idx=(d_monthly_def>1000 & ~isnan(d_monthly_def));
figure(1)
hold on
ax=gca;
ax.ColorOrderIndex=1;
plot(Tp1y.dates(py_idx),p_yearly_def(py_idx))
ax.ColorOrderIndex=2;
plot(Td1y.dates(dy_idx),d_yearly_def(dy_idx))
ylabel("Deforestation Area (km^2)")
xlabel("Year")
legend("PRODES","DETER")
title("Annual Measured Deforestation")
hold off

figure(2)
hold on
ax=gca;
ax.ColorOrderIndex=2;
plot(Td1.dates(dm_idx),d_monthly_def(dm_idx),'DatetimeTickFormat','MMMyy')
xt=datetime(year(min(Td1.dates)),1,1):calmonths(6):datetime(year(max(Td1.dates)),12,31);
ax.XTick=xt;
ylabel("Deforestation Area (km^2)")
xlabel("Year")
legend("DETER")
title("Monthly DETER Deforestation")
hold off
