clear all; close all; clc

Tmax = 1/.374; % placeholder

Tmax = 2;

Ps = [1:15];
Ps = [7:8, 10:15];

load('mechanics.mat', 'W', 'conds', 'Ts', 'Tl', 'mTcycle', 'Iact')
load('metabolics.mat', 'Pmet', 'Sdata')

Pmet = Pmet(Ps,:);

%% correct Pmet for time isometric
Piso = Pmet(:,7:8);
N = size(Piso,1);

% time the muscle was isometric
% Tiso = Tmax/2 - [Ts(1:3) Tl(4:6) Tmax/2 Tmax/2 Ts(end)+Tl(end)];

% fraction isometric compared to isometric condition
% fiso = repmat(Tiso / (Tmax/2), N,1);
fiso = [Iact(Ps,1:3)./Iact(Ps,7) Iact(Ps,4:9)./Iact(Ps,8)];

% portion of metabolic rate due to contraction
Pcor = Pmet - [Piso(:,2) .* fiso(:,1:3)  Piso(:,1) .* fiso(:,4:end)];

% correct for individual offset
Pcor2 = Pmet + mean(Pmet(:), 'omitnan') - mean(Pmet,2);

%% compute efficiency
Pav = W(:,Ps,:) ./ mTcycle;

Pmcor(:,:,1) = W(:,Ps,1) ./ (Tl+Ts)'; % net
Pmcor(:,:,2) = W(:,Ps,2) ./ Ts'; % positive
Pmcor(:,:,3) = W(:,Ps,3) ./ Tl'; % negative

eff         = Pav./Pmet'; 
eff_cor     = Pav./Pcor'; 

    
%%
close all

colors = lines(5);

figure(1)

subplot(231)
errorbar(1:9, mean(Pcor2, 'omitnan'), std(Pcor2, 'omitnan'), 'o'); hold on
title('Metabolic rate')

subplot(234);
errorbar(1:9, mean(Pcor, 'omitnan'), std(Pcor, 'omitnan'), 'o')

for i = 1:3
    subplot(232)
    errorbar(1:9, mean(Pav(:,:,i),2, 'omitnan'), std(Pav(:,:,i),1,2, 'omitnan'), 'o'); hold on
    title('Mechanical work rate')
    
    subplot(235)
    errorbar(1:9, mean(Pmcor(:,:,i),2, 'omitnan'), std(Pmcor(:,:,i),1,2, 'omitnan'), 'o'); hold on

    subplot(233)
    errorbar(1:9, mean(eff(:,:,i),2, 'omitnan'), std(eff(:,:,i),1,2, 'omitnan'), 'o', 'color', colors(i,:)); hold on
    ylim([-1 1])
    title('Efficiency')
    
    subplot(236);
    errorbar(1:9, mean(eff_cor(:,:,i),2, 'omitnan'), std(eff_cor(:,:,i),1,2, 'omitnan'), 'o', 'color', colors(i,:)); hold on
    ylim([-1 1])

end

for i = 1:6
    subplot(2,3,i)
    box off
end

return

%%
if ishandle(10), close(10); end
figure(10)

titles = {'Overall', 'Isometric', 'Contraction', 'Rest'};

for i = 1:4
    subplot(4,1,i)
    bar(1:9, mean(A(:,:,i),2, 'omitnan')'); hold on
    errorbar(1:9, mean(A(:,:,i),2, 'omitnan'), std(A(:,:,i),1,2, 'omitnan'), 'o'); hold on
    xticklabels(conds)
title(titles{i})
box off
end


%% 
figure(11)

bar(1:9, mean(Pmet'./A(:,Ps,1),2,'omitnan')); hold on
errorbar(1:9, mean(Pmet'./A(:,Ps,1),2,'omitnan'),std(Pmet'./A(:,Ps,1),1,2,'omitnan')) 
    
    xticklabels(conds)
title(titles{i})
box off