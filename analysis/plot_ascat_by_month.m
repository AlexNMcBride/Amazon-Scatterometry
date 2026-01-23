load("/auto/home/mcbride/Amazon-Scatterometry/output/ascat_cetb_day_scat_4_6.25km.mat","clips_year");
start_year = 2008;
end_year = 2024;
num_years = end_year - start_year+1;
monthly_avgs = zeros(years,12);
% for i=1:years
%     days = size(clips_year(i).clips,2);
%     sig0s = zeros(days,1);
%     for j=1:12
%         for k=1:days
%             sig0s(k)
%         end
%     end
% end

% by year
figure(1)
hold on
for i=1:num_years
    days = size(clips_year(i).clips,2);
    if days==0
        continue;
    end
    cur_year = year(clips_year(i).clips(1).date);
    if cur_year==2014
        continue;
    end
    avgs = zeros(days,1);
    dates = repmat(datetime(0,0,0),days,1);
    for k=1:days
        dat = ~isnan(clips_year(i).clips(k).img);
        img = clips_year(i).clips(k).img(dat);
        dates(k) = clips_year(i).clips(k).date-calyears(i);
        avgs(k) = mean(img);
    end
    thresh = 1.0;
    idx = ~isoutlier(avgs, "mean", "ThresholdFactor", thresh);
    plot(dates(idx),avgs(idx),'DatetimeTickFormat','MMM','DisplayName',num2str(cur_year))
end
legend
hold off

% by month
figure(2)
hold on
for i=1:num_years
    days = size(clips_year(i).clips,2);
    if days==0
        continue;
    end
    cur_year = year(clips_year(i).clips(1).date);
    if cur_year==2014
        continue;
    end
    avgs = zeros(days,1);
    dates = repmat(datetime(0,0,0),days,1);
    for k=1:days
        dat = ~isnan(clips_year(i).clips(k).img);
        img = clips_year(i).clips(k).img(dat);
        dates(k) = clips_year(i).clips(k).date-calyears(i);
        avgs(k) = mean(img);
    end
    thresh = 1.0;
    idx = ~isoutlier(avgs, "mean", "ThresholdFactor", thresh);
    dates = dates(idx);
    avgs = avgs(idx);
    T = timetable(dates,avgs);
    Tm = retime(T,'monthly','mean');
    plot(Tm.dates,Tm.avgs,'DatetimeTickFormat','MMM','DisplayName',num2str(cur_year))
end
legend
hold off