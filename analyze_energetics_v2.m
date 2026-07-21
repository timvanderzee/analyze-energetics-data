clear all; close all; clc

Tmax = 1/.374; % placeholder

Tmax = 2;

Ps = [1:15];

load('mechanics.mat', 'W', 'conds', 'Ts', 'Tl', 'mTcycle', 'A')
load('metabolics.mat', 'Pmet', 'Sdata')

%% correct Pmet for time isometric
Piso = Pmet(:,7:8);
N = size(Piso,1);

% time the muscle was isometric
Tiso = Tmax/2 - [Ts(1:3) Tl(4:6) Tmax/2 Tmax/2 Ts(end)+Tl(end)];

% fraction isometric compared to isometric condition
fiso = repmat(Tiso / (Tmax/2), N,1);

% portion of metabolic rate due to contraction
Pcor = Pmet - [Piso(:,2) .* fiso(:,1:3)  Piso(:,1) .* fiso(:,4:end)];

%% compute efficiency
Pav = W(:,Ps,:) ./ mTcycle;

Pmcor(:,:,1) = W(:,Ps,1) ./ (Tl+Ts)'; % net
Pmcor(:,:,2) = W(:,Ps,2) ./ Ts'; % positive
Pmcor(:,:,3) = W(:,Ps,3) ./ Tl'; % negative

eff         = Pav./Pmet(Ps,:)'; 
eff_cor     = Pav./Pcor(Ps,:)'; 
    
%%
close all

colors = lines(5);

figure(1)

subplot(231)
errorbar(1:9, mean(Pmet, 'omitnan'), std(Pmet, 'omitnan'), 'o'); hold on
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

%%
figure
    errorbar(1:9, mean(A(:,:,1),2, 'omitnan'), std(A(:,:,1),1,2, 'omitnan'), 'o'); hold on
    
return
%% effect of speed
if ishandle(2), close(2); end
figure(2)
vels = [60 120 240];

plot(vels, squeeze(W(2,1:3,:))); hold on
errorbar(vels, mean(W(2,1:3,:),3, 'omitnan'), std(W(2,1:3,:),1,3, 'omitnan'), 'o'); hold on
box off
    