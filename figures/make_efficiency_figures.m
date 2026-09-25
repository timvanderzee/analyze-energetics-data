function[rat] = make_efficiency_figures(vm, eff, type, j)

if nargin < 4
    j = 1;
end
    
%% order efficiency
% reorder so that velocity is increasing
if type == 1

    id = [6:-1:4, 1:3];
    v = [-240 -120 -60 0 60 120 240];

    y = eff(id,:,:);
    Y = [y(1:3,:,:); zeros(1, size(y,2), 3); y(4:6,:,:)];

else
    id = [8:-1:5, 1:4];
    v = [-240 -120 -60 -30 0 30 60 120 240];

    y = eff(id,:,:);
    Y = [y(1:4,:,:); zeros(1, size(y,2), 3); y(5:8,:,:)];
end


%% statistics
% j = 1;
% i = 1;
kk = type;

color = lines(3);

subplot(131)
errorbar(v, mean(Y(:,:,j),2, 'omitnan'), std(Y(:,:,j),1,2, 'omitnan'), '--o', 'color', color(type,:), ...
    'markerfacecolor', color(type,:)); hold on
plot(v, Y(:,:,j), '.', 'color', color(type,:))

xlabel('Velocity (deg/s)')
ylabel('Efficiency (%)')

h = nan(9,2);
p = nan(9,2);

for i = 1:(size(Y,1)-1)
    [h(i,kk), p(i,kk)] = ttest(Y(i,:,j), Y(i+1,:,j));


    if h(i,kk)
        plot([v(i) v(i+1)], [mean(Y(i,:,j),2) mean(Y(i+1,:,j),2)], 'k-')
    end
end


icon = v > 0;
iecc = v < 0;


Ycon = Y(icon,:,1);
Yecc = flip(Y(iecc,:,1));
rat = [ones(1,size(Yecc,2)); -Yecc./Ycon];

v = [0 v(icon)];

subplot(132)
errorbar(v, mean(rat,2,'omitnan'), std(rat,1,2,'omitnan'), '--o', 'color', color(type,:), ...
        'markerfacecolor', color(type,:)); hold on

plot(v, rat, '.', 'color', color(type,:))
ylabel('Efficiency ratio')
xlabel('Velocity (deg/s)')
ylim([0 5])

for i = 1:(size(rat,1)-1)
    [h2(i,kk), p2(i,kk)] = ttest(rat(i,:),rat(i+1,:));


    if h2(i,kk)
        plot([v(i) v(i+1)], [mean(rat(i,:),2) mean(rat(i+1,:),2)], 'k-')
    end
end

%% efficiency versus velocity
color = lines(2);

subplot(133)
errorbar(-mean(vm,2, 'omitnan'), mean(eff(:,:,1),2, 'omitnan'),std(eff(:,:,1),1,2, 'omitnan'), std(eff(:,:,1),1,2, 'omitnan'), ...
    std(vm,1,2, 'omitnan'), std(vm,1,2, 'omitnan'), ...
    'o', 'color', color(type,:), 'markerfacecolor', color(type,:)); hold on
plot(-vm, eff(:,:,1), '.', 'color', color(type,:))

xlabel('Velocity (mm/s)')


%% make nice
for i = 1:3
    subplot(1,3,i)
    box off
    grid on
end

end
% end