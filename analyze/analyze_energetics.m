function[eff, eff_cor] = analyze_energetics(Ps)

Tmax = 1/.374; % placeholder

Tmax = 2;

% Ps = [1:15];
% Ps = [7:8, 10:15];
% Ps = 16:18;

cd('C:\Users\u0167448\Documents\GitHub\analyze-energetics-data\data')
load('mechanics_v1.mat', 'W', 'conds', 'Ts', 'Tl', 'mTcycle', 'Iact', 'A')
load('metabolics.mat', 'Pmet', 'Sdata')

Pmet = Pmet(Ps,:);
conds = {'c60','c120','c240', 'e60','e120','e240', 'ISOM_EXT', 'ISOM_FLEX', 'STR-SHOR'};

%% correct Pmet for time isometric
Piso = Pmet(:,7:8);
N = size(Piso,1);

% time the muscle was isometric
% Tiso = Tmax/2 - [Ts(1:3) Tl(4:6) Tmax/2 Tmax/2 Ts(end)+Tl(end)];

% fraction isometric compared to isometric condition
% fiso = repmat(Tiso / (Tmax/2), N,1);
fiso = [Iact(Ps,1:3)./Iact(Ps,8) Iact(Ps,4:7)./Iact(Ps,7) Iact(Ps,8)./Iact(Ps,8) Iact(Ps,9)./Iact(Ps,7)] * 1;


% portion of metabolic rate due to contraction
Pcor = Pmet - [Piso(:,2) .* fiso(:,1:3)  Piso(:,1) .* fiso(:,4:7) Piso(:,2) .* fiso(:,8) Piso(:,1) .* fiso(:,9)];

% correct for individual offset
Pcor2 = Pmet + mean(Pmet(:), 'omitnan') - mean(Pmet,2);
Act = A(1:length(conds),Ps,1);

%% compute efficiency
Pav = W(:,Ps,:) ./ mTcycle;

Pmcor(:,:,1) = W(1:length(Tl),Ps,1) ./ (Tl+Ts)'; % net
Pmcor(:,:,2) = W(1:length(Tl),Ps,2) ./ Ts'; % positive
Pmcor(:,:,3) = W(1:length(Tl),Ps,3) ./ Tl'; % negative

Pcor(Pcor<5) = nan;

eff         = Pav./Pmet' * 100;
% eff_cor     = squeeze(mean(Pav,2))./ mean(Pcor)';
eff_cor     = Pav./ Pcor' * 100;


%% figure 1 - uncorrected
figure(1)
% close all
acolors = lines(20);
colors = lines(5);
names = {'Net','Positive', 'Negative'};

x = [1:3 -1:-1:-3 5:7];

for i = 2:3
%     figure(2)
%     set(gcf, 'Name', names{i})
    
    [~, id] = sort(x);
    
    subplot(221)
    bar(x,  mean(Act,2, 'omitnan'),'facecolor', colors(1,:)); hold on    
    errorbar(x, mean(Act,2, 'omitnan'), std(Act,1,2, 'omitnan'), '.', 'color', colors(1,:)); hold on
    title('Activation')
     
    for j = 1:size(Pmet,1)
        plot(x(id), squeeze(Act(id,j)), '.:', 'color', acolors(j+1,:))
    
    end  
     
    subplot(222)
    bar(x, mean(Pmet, 'omitnan'), 'facecolor', colors(1,:)); hold on
    % xticklabels(conds)
    errorbar(x, mean(Pmet, 'omitnan'), std(Pmet, 'omitnan'), '.', 'color', colors(1,:)); hold on
    % errorbar(1:length(Tl), mean(Pcor2, 'omitnan'), std(Pcor2, 'omitnan'), 'o'); hold on
    title('Metabolic rate')
    
    for j = 1:size(Pmet,1)
        plot(x(id), Pmet(j,id), '.:', 'color', acolors(j+1,:))
    end
    
    subplot(223)
    bar(x,  mean(Pav(:,:,i),2, 'omitnan'), 'facecolor', colors(1,:)); hold on

    errorbar(x, mean(Pav(:,:,i),2, 'omitnan'), std(Pav(:,:,i),1,2, 'omitnan'), '.', 'color', colors(1,:)); hold on
    title('Mechanical work rate')

       for j = 1:size(Pcor,1)
        plot(x(id), squeeze(Pav(id,j,i)), '.:', 'color', acolors(j+1,:))
       end
     
    subplot(224)
    bar(x,  mean(eff(:,:,i),2, 'omitnan'), 'facecolor', colors(1,:)); hold on
    errorbar(x, mean(eff(:,:,i),2, 'omitnan'), std(eff(:,:,i),1,2, 'omitnan'), '.', 'color', colors(1,:)); hold on
%     ylim([-1 1])
    title('Efficiency')

        for j = 1:size(Pcor,1)
        plot(x(id), squeeze(eff(id,j,i)), '.:', 'color', acolors(j+1,:))
        end
     
    for j = 1:4
        subplot(2,2,j)
        box off
        xticklabels(conds(id))
    end
    
end

%% figure 2 - corrected
figure(2) 

for i = 2:3
%     figure(2)
%     set(gcf, 'Name', names{i})
    
    [~, id] = sort(x);
    
    subplot(221)
    bar(x,  mean(Act,2, 'omitnan'),'facecolor', colors(1,:)); hold on    
    errorbar(x, mean(Act,2, 'omitnan'), std(Act,1,2, 'omitnan'), '.', 'color', colors(1,:)); hold on
    title('Activation')
  
     for j = 1:size(Pmet,1)
        plot(x(id), squeeze(Act(id,j)), '.:', 'color', acolors(j+1,:))
     end  
    
    subplot(222);
    bar(x, mean(Pcor, 'omitnan'), 'facecolor', colors(1,:)); hold on
    % xticklabels(conds)
    errorbar(x, mean(Pcor, 'omitnan'), std(Pcor, 'omitnan'), '.', 'color', colors(1,:))
    title('Metabolic rate')
    
    for j = 1:size(Pcor,1)
        plot(x(id), Pcor(j,id), '.:', 'color', acolors(j+1,:))
    
    end
    
    subplot(223)
    bar(x,  mean(Pav(:,:,i),2, 'omitnan'), 'facecolor', colors(1,:)); hold on

    errorbar(x, mean(Pav(:,:,i),2, 'omitnan'), std(Pav(:,:,i),1,2, 'omitnan'), '.', 'color', colors(1,:)); hold on
    title('Mechanical work rate')
     
    for j = 1:size(Pcor,1)
        plot(x(id), squeeze(Pav(id,j,i)), '.:', 'color', acolors(j+1,:))
     end
     
    subplot(224);
    bar(x,  mean(eff_cor(:,:,i),2, 'omitnan'), 'facecolor', colors(1,:)); hold on
    %     plot(1:length(Tl), mean(eff_cor(:,i),2, 'omitnan'), 'o', 'color', colors(i,:)); hold on
    errorbar(x, mean(eff_cor(:,:,i),2, 'omitnan'), std(eff_cor(:,:,i),1,2, 'omitnan'), '.', 'color', colors(1,:)); hold on
%     ylim([-1 1])
    title('Efficiency')
        
    for j = 1:size(Pcor,1)
        plot(x(id), squeeze(eff_cor(id,j,i)), '.:', 'color', acolors(j+1,:))
    
    end
        
    
    for j = 1:4
        subplot(2,2,j)
        box off
        xticklabels(conds(id))
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

bar(1:length(Tl), mean(Pmet'./A(:,Ps,1),2,'omitnan')); hold on
errorbar(1:length(Tl), mean(Pmet'./A(:,Ps,1),2,'omitnan'),std(Pmet'./A(:,Ps,1),1,2,'omitnan'))

xticklabels(conds)
title(titles{i})
box off