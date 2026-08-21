function[] = analyze_energetics_dataset2(Ps)


conds = {'c30', 'c60','c120','c240', 'e30', 'e60','e120','e240'};

cd('C:\Users\u0167448\Documents\GitHub\analyze-energetics-data\data')
load('mechanics_v2.mat', 'W', 'conds', 'Ts', 'Tl', 'mTcycle', 'Iact', 'A')
load('metabolics.mat', 'Pmet', 'Sdata')

load('MVC.mat', 'Tknee')
Tmax = max(Tknee,2);
Tmax = ones(size(Tmax));

% Ps = 16:18;
Pmeti = Pmet(Ps,1:length(conds))./Tmax(Ps)';

Pav = (W(1:length(conds),Ps,:) ./ mTcycle(1:length(conds)))./Tmax(Ps);

Act = A(1:length(conds),Ps,1);
% Act = (A(1:length(conds),Ps,1) ./ mTcycle(1:length(conds)))./Tmax(Ps);

eff         = Pav./Pmeti' * 100;


%%
% close all

colors = [.5 .5 .5; lines(1); lines(1)];
acolors = lines(9);

names = {'Net','Positive', 'Negative'};
ylabs = {'Activation', 'Metabolic rate (W)', 'Work rate (W)', 'Efficiency (%)'};

x = [1:4 -1:-1:-4];

for i = 2:3
    
    [~, id] = sort(x);
    
%     figure(1)
%     set(gcf, 'Name', names{i})
    
    subplot(221)
    bar(x,  mean(Act,2, 'omitnan'),'facecolor', colors(i,:)); hold on    
    errorbar(x, mean(Act,2, 'omitnan'), std(Act,1,2, 'omitnan'), '.', 'color', colors(i,:)); hold on
    title('Activation')


     for j = 1:size(Pmeti,1)
        plot(x(id), squeeze(Act(id,j)), '.:', 'color', acolors(j+1,:))
     end
    
    subplot(222)
    bar(x, mean(Pmeti, 'omitnan'),'facecolor', colors(i,:)); hold on
    errorbar(x, mean(Pmeti, 'omitnan'), std(Pmeti, 'omitnan'), '.', 'color', colors(i,:)); hold on
    title('Metabolic rate')
   
    for j = 1:size(Pmeti,1)
        plot(x(id), Pmeti(j,id), '.:', 'color', acolors(j+1,:))
    end
    
    subplot(223)
    bar(x,  mean(Pav(:,:,i),2, 'omitnan'),'facecolor', colors(i,:)); hold on    
    errorbar(x, mean(Pav(:,:,i),2, 'omitnan'), std(Pav(:,:,i),1,2, 'omitnan'), '.', 'color', colors(i,:)); hold on
    title('Mechanical work rate')


     for j = 1:size(Pmeti,1)
        plot(x(id), squeeze(Pav(id,j,i)), '.:', 'color', acolors(j+1,:))
     end
    
    subplot(224)
    bar(x,  mean(eff(:,:,i),2, 'omitnan'),'facecolor', colors(i,:)); hold on
    errorbar(x, mean(eff(:,:,i),2, 'omitnan'), std(eff(:,:,i),1,2, 'omitnan'), '.', 'color', colors(i,:)); hold on
%     ylim([-100 30])
    title('Efficiency')

     for j = 1:size(Pmeti,1)
        plot(x(id), squeeze(eff(id,j,i)), '.:', 'color', acolors(j+1,:))
     end
    
    for j = 1:4
        subplot(2,2,j)
        box off
        xticklabels(conds(id))
        ylabel(ylabs{j})
    end
    
end
return

%%
if ishandle(10), close(10); end
figure(10)

titles = {'Overall', 'Isometric', 'Contraction', 'Rest'};

for i = 1:4
    subplot(4,1,i)
    bar(1:length(Tl), mean(A(:,:,i),2, 'omitnan')'); hold on
    errorbar(1:length(Tl), mean(A(:,:,i),2, 'omitnan'), std(A(:,:,i),1,2, 'omitnan'), 'o'); hold on
    xticklabels(conds)
    title(titles{i})
    box off
end


%%
figure(11)

bar(1:length(Tl), mean(Pmeti'./A(:,Ps,1),2,'omitnan')); hold on
errorbar(1:length(Tl), mean(Pmeti'./A(:,Ps,1),2,'omitnan'),std(Pmeti'./A(:,Ps,1),1,2,'omitnan'))

xticklabels(conds)
title(titles{i})
box off