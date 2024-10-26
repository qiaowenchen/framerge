cd 'D:\吵雯的文件夹\学习与工作\工作\Shared with me\qwcwork\framerge\revise\mvme'
clear
load timer_1m&mm.mat

% Calculate the mean of c2 and c3 for each Obs
meanData_1m = varfun(@median, data_1m, 'GroupingVariables', 'Obs');
% Extract the median values as column vectors
mean_1m = [meanData_1m.median_c2,meanData_1m.median_c3];

% Calculate the median of c2 and c3 for each Obs
medianData_1m = varfun(@median, data_1m, 'GroupingVariables', 'Obs');
% Extract the median values as column vectors
median_1m = [medianData_1m.median_c2,medianData_1m.median_c3];

% Calculate the sum of c2 and c3 for each Obs
sumData_1m = varfun(@sum, data_1m, 'GroupingVariables', 'Obs');
% Extract the sum values as column vectors
sum_1m = [sumData_1m.sum_c2,sumData_1m.sum_c3];


% Calculate the mean of c2 and c3 for each Obs
meanData_mm = varfun(@median, data_mm, 'GroupingVariables', 'Obs');
% Extract the median values as column vectors
mean_mm = [meanData_mm.median_c2,meanData_mm.median_c3];

% Calculate the median of c2 and c3 for each Obs
medianData_mm = varfun(@median, data_mm, 'GroupingVariables', 'Obs');
% Extract the median values as column vectors
median_mm = [medianData_mm.median_c2,medianData_mm.median_c3];

% Calculate the sum of c2 and c3 for each Obs
sumData_mm = varfun(@sum, data_mm, 'GroupingVariables', 'Obs');
% Extract the sum values as column vectors
sum_mm = [sumData_mm.sum_c2,sumData_mm.sum_c3];





%%%% Figure
X = 1:4;

%%% mean 1:m
axis1 = subplot(2,3,1);
h_mean_1m = bar(X,mean_1m,1,'grouped');
set(gca,'position',[0.1350 0.5508  0.2000  0.4000],'XtickLabel',[10 100 1000 2000],...
    'FontSize',18)
title('Mean of 1:m','FontSize',20)
% xlabel('Observations(thousand)')
ylabel('Time(seconds)','FontSize',18)
% Color
h_mean_1m(1).FaceColor = [0.980392157	0.498039216	0.435294118];
h_mean_1m(2).FaceColor = [1	0.745098039	0.478431373];
% % Legend
% legend('framerge 1:m', 'merge 1:m', 'Location', 'northoutside');
% letter
ylim = get(gca, 'ylim');  % Get the current y-axis limits
text(0, ylim(2)+0.1, 'a', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center','FontSize',18)


%%% median 1:m
axis2 = subplot(2,3,2);
h_median_1m = bar(X,median_1m,1,'grouped');
set(gca,'position',[0.3700    0.5508    0.2000    0.4000],'XtickLabel',[10 100 1000 2000],...
    'FontSize',18)
title('Median of 1:m','FontSize',20)
% xlabel('Observations(thousand)')
% Color
h_median_1m(1).FaceColor = [0.980392157	0.498039216	0.435294118];
h_median_1m(2).FaceColor = [1	0.745098039	0.478431373];
% letter
ylim = get(gca, 'ylim');  % Get the current y-axis limits
text(0, ylim(2)+0.1, 'b', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center','FontSize',18)


%%% sum 1:m
axis3 = subplot(2,3,3);
h_sum_1m = bar(X,sum_1m,1,'grouped');
set(gca,'position',[0.6120 0.5508    0.2000    0.4000],'XtickLabel',[10 100 1000 2000],...
    'FontSize',18)
title('Sum of 1:m','FontSize',20)
% xlabel('Observations(thousand)')
% Color
h_sum_1m(1).FaceColor = [0.980392157	0.498039216	0.435294118];
h_sum_1m(2).FaceColor = [1	0.745098039	0.478431373];
% letter
ylim = get(gca, 'ylim');  % Get the current y-axis limits
text(0, ylim(2)+10, 'c', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center','FontSize',18)
% Legend
legend1 = legend('framerge 1:m', 'merge 1:m', 'position',[0.8570    0.5080    0.0150    0.0602],'box','off');
set(legend1, 'FontSize', 18 );

%%% mean m:m
axis4 = subplot(2,3,4);
h_mean_mm = bar(X,mean_mm,1,'grouped');
set(gca,'position',[0.1350 0.0700  0.2000  0.4000],'XtickLabel',[10 100 1000 2000],...
    'FontSize',18)
title('Mean of m:m','FontSize',20)
label1 = xlabel('Observations(thousand)');
set(label1, 'position', [2.5000 -0.9 -1])
ylabel('Time(seconds)','FontSize',18)
% Color
h_mean_mm(1).FaceColor = [0.556862745	0.811764706	0.788235294];
h_mean_mm(2).FaceColor = [0.509803922	0.690196078	0.823529412];
% letter
ylim = get(gca, 'ylim');  % Get the current y-axis limits
text(0, ylim(2)+0.5, 'd', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center','FontSize',18)


%%% median m:m
axis5 = subplot(2,3,5);
h_median_mm = bar(X,median_mm,1,'grouped');
set(gca,'position',[0.3700 0.0700  0.2000  0.4000],'XtickLabel',[10 100 1000 2000],...
    'FontSize',18)
title('Median of m:m','FontSize',20)
label2 = xlabel('Observations(thousand)');
set(label2, 'position',[2.5000 -0.9 -1])
% Color
h_median_mm(1).FaceColor = [0.556862745	0.811764706	0.788235294];
h_median_mm(2).FaceColor = [0.509803922	0.690196078	0.823529412];
% letter
ylim = get(gca, 'ylim');  % Get the current y-axis limits
text(0, ylim(2)+0.5, 'e', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center','FontSize',18)


%%% sum m:m
axis6 = subplot(2,3,6);
h_sum_mm = bar(X,sum_mm,1,'grouped');
set(gca,'position',[0.6120 0.0700  0.2000  0.4000],'XtickLabel',[10 100 1000 2000],...
    'FontSize',18)
title('Sum of m:m','FontSize',20)
label3 = xlabel('Observations(thousand)');
set(label3, 'position',[2.5000  -90   -1.0000])
% Color
h_sum_mm(1).FaceColor = [0.556862745	0.811764706	0.788235294];
h_sum_mm(2).FaceColor = [0.509803922	0.690196078	0.823529412];
% % Legend
% legend('framerge 1:m', 'merge 1:m', 'Location', 'northoutside');
% letter
ylim = get(gca, 'ylim');  % Get the current y-axis limits
text(-0.2, ylim(2)+50, 'f', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center','FontSize',18)
% Legend
legend2 = legend('framerge m:m', 'joinby', 'position',[0.8600    0.4400    0.0139    0.0602],'box','off');
set(legend2, 'FontSize', 18);



% print(['nvme','.eps'],'-depsc','-r600');% save eps with 600dpi
% print(gcf, 'nvme', '-dsvg'); % save svg