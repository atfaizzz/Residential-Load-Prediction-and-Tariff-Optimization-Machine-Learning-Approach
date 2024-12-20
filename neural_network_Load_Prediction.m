clear all
close all
clc
data=load('full_dataset.mat');
loads_non_normal = data.full_dataset(:,:,1);
temperature_non_normal = data.full_dataset(:,:,2);
energy_cost_non_normal = data.full_dataset(:,:,3);
t = 0:0.25:23.75;
t_old = 0:0.5:24;
load('savedcost.mat')
load('savedtemp.mat')
saved_temp_temp = interp1(t_old,saved_temp_temp,t,'linear');
saved_temp = saved_temp_temp;
loads_non_normal = 0.7*movmean(loads_non_normal,6);
load_max = max(max(loads_non_normal(:,1:96)));
load_min = min(min(loads_non_normal(:,1:96)));
temp_max = max(max(temperature_non_normal(:,1:96)));
temp_min = min(min(temperature_non_normal(:,1:96)));
cost_max = max(max(energy_cost_non_normal(:,1:96)));
cost_min = min(min(energy_cost_non_normal(:,1:96)));
loads = loads_non_normal(:,1:96) - load_min;
loads = loads ./ load_max ;
temperature = temperature_non_normal(:,1:96) - temp_min;
temperature = temperature ./ temp_max ;
energy_cost = energy_cost_non_normal(:,1:96) - cost_min;
energy_cost = energy_cost ./ cost_max ;
all_data = [temperature energy_cost loads];
cv = cvpartition(size(all_data,1),'HoldOut',0.20);
data_train = all_data(cv.training,:)';
data_test = all_data(cv.test,:)';
X = data_train';
[idx,C] = kmeans(X,10,'Display','iter');
for i = 1:size(data_train,2)
     inputs(1:288,i) = [data_train(1:192,i)', C(idx(i),193:288)];
end
targets = data_train(193:end,:);
net = feedforwardnet(10);
[net,tr] = train(net,inputs,targets);
closest = zeros(1,10);
for y = 1:size(data_test,2)
    for i = 1:192
        [~,closestIndex] = min(abs(C(:,i)-data_test(i,y)));
        closest(closestIndex) = closest(closestIndex) + 1;
    end
    [~,cluster(y)] = max(closest);
    closest = zeros(1,10);
end
for i=1:size(data_test,2)
    output = net([data_test(1:192,i)', C(cluster(i),193:288)]');
    output = movmean(output,6);
    plot_predicted_data = output' .* load_max;
    plot_predicted_data = plot_predicted_data + load_min;
    plot_real_data = data_test(193:end,i) .* load_max;
    plot_real_data = plot_real_data + load_min;
    figure
    plot(t,plot_predicted_data,'r','LineWidth', 1.5)
    hold on;
    plot(t,plot_real_data,'b','LineWidth', 1.5);
    legend('Predicted Load','Actual Load');
    ylabel('Loads (W)')
    xlabel({'Time (hours)';'(b)'})
    set(gca,'fontname','times','FontSize', 15)
axis([0 24 0 1600])
set(gca, 'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02], ...
    'XMinorTick', 'off', 'YMinorTick', 'on', 'YGrid', 'off', ...
    'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3], 'YTick', 0:200:1600,'LineWidth', 1)
xticks(0:4:24)
xticklabels({'00:00','04:00','08:00','12:00','16:00','20:00','24:00'})
end
figure
hold all
mintemp = movmean(min(temperature_non_normal),5);
maxtemp = movmean(max(temperature_non_normal),5);
patch([t fliplr(t)], [mintemp fliplr(maxtemp)], 'black', 'FaceColor', 'red', 'FaceAlpha', 0.2, 'EdgeColor','black', 'EdgeAlpha', 0);
plot(t,mean(temperature_non_normal),'r','LineWidth', 1.5);
saved_temp = saved_temp - 0.6;
plot(t,saved_temp,'b','LineWidth', 1.5);
legend('Temperature range','Temperature mean','Case study temperature','Location','northwest')
axis([0 24 17 35])
set(gca, 'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02], ...
    'XMinorTick', 'off', 'YMinorTick', 'on', 'YGrid', 'off', ...
    'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3], 'YTick', 18:2:36,'LineWidth', 1)
xticks(0:4:24)
xticklabels({'00:00','04:00','08:00','12:00','16:00','20:00','24:00'})
xlabel({'Time (hours)';'(a)'})
ylabel('Temperature (°C)')
set(gca,'fontname','times','FontSize', 15)
figure
hold all
energy_cost_non_normal  =energy_cost_non_normal*1.005;
mincost = movmean(min(energy_cost_non_normal),5);
maxcost = movmean(max(energy_cost_non_normal),5);
patch([t fliplr(t)], [mincost fliplr(maxcost)], 'black', 'FaceColor', 'yellow', 'FaceAlpha', 0.3, 'EdgeColor','yellow', 'EdgeAlpha', 0.1);
plot(t,mean(energy_cost_non_normal),'r','LineWidth', 1.5);
saved_cost = saved_cost*0.6;
saved_cost = saved_cost+0.045;
saved_cost = movmean(saved_cost,5);
set(gca,'fontname','times','FontSize', 15)
plot(t,saved_cost,'b','LineWidth', 1.5);
legend('Energy price range','Energy price mean','Case study energy price','Location','northwest')
%data fetch
axis([0 24 0.1 0.22])
set(gca, 'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02], ...
    'XMinorTick', 'off', 'YMinorTick', 'on', 'YGrid', 'off', ...
    'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3], 'YTick', 0.1:0.02:0.22,'LineWidth', 1)
xticks(0:4:24)
xticklabels({'00:00','04:00','08:00','12:00','16:00','20:00','24:00'})
xlabel({'Time (hours)';'(b)'})
ylabel('Energy Price (€ / kWh)')
set(gca,'fontname','times','FontSize', 15)
