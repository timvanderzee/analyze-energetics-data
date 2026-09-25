function[eff, vels] = analyze_energetics(Ps, v, Pi, cor, i)

if nargin < 5
    i = 1;
end

if nargin < 4
    cor = 0;
end

cd('C:\Users\u0167448\Documents\GitHub\analyze-energetics-data\data')
load(['mechanics_v', num2str(v), '.mat'], 'W', 'conds', 'Ts', 'Tl', 'mTcycle', 'Iact', 'A', 'Wm', 'vm')
load('metabolics.mat', 'Pmet')

vels = vm(Ps,:)';

Pmet = Pmet(Ps,1:length(conds));
% conds = {'c60','c120','c240', 'e60','e120','e240', 'ISOM_EXT', 'ISOM_FLEX', 'STR-SHOR'};

Act = A(1:length(conds),Ps,1);

%% compute efficiency
% W = Wm;
Pav = W(1:length(conds),Ps,:) ./ mTcycle(1:length(conds));
eff         = Pav./Pmet' * 100;

% optionally, we can correct for isometric contraction time
if v == 1 && cor
    Tmax = 1/.374; % placeholder
    
    Tmax = 2;
    
    Piso = Pmet(:,7:8);
    N = size(Piso,1);
    
    % time the muscle was isometric
    % Tiso = Tmax/2 - [Ts(1:3) Tl(4:6) Tmax/2 Tmax/2 Ts(end)+Tl(end)];
    
    % fraction isometric compared to isometric condition
    % fiso = repmat(Tiso / (Tmax/2), N,1);
    fiso = [Iact(Ps,1:3)./Iact(Ps,8) Iact(Ps,4:7)./Iact(Ps,7) Iact(Ps,8)./Iact(Ps,8) Iact(Ps,9)./Iact(Ps,7)] * .5;
    
    % portion of metabolic rate due to contraction
    Pmet = Pmet - [Piso(:,2) .* fiso(:,1:3)  Piso(:,1) .* fiso(:,4:7) Piso(:,2) .* fiso(:,8) Piso(:,1) .* fiso(:,9)];
    
    Pmcor(:,:,1) = W(1:length(Tl),Ps,1) ./ (Tl+Ts)'; % net
    Pmcor(:,:,2) = W(1:length(Tl),Ps,2) ./ Ts'; % positive
    Pmcor(:,:,3) = W(1:length(Tl),Ps,3) ./ Tl'; % negative
    
%     Pmet(Pmet<5) = nan;
    eff     = Pav./ Pmet' * 100;
end

%% plot
% close all
acolors = parula(length(Ps));
colors = lines(5);
names = {'Net','Positive', 'Negative'};
ylabs = {'Activation', 'Metabolic rate (W)', 'Work rate (W)', 'Efficiency (%)'};

if v == 1
    x = [1:3 -1:-1:-3 5:7];
else
    x = [1:4 -1:-1:-4];
end


[~, id] = sort(x);

Y(:,:,1) = Act;
Y(:,:,2) = Pmet';
Y(:,:,3) = Pav(:,:,i);
Y(:,:,4) = eff(:,:,i);

titles = {'Activation', 'Metabolic rate', 'Mechanical work rate', 'Efficiency'};

for k = 1:size(Y,3)
    subplot(2,2,k)
    bar(x, mean(Y(:,:,k), 2, 'omitnan'),'facecolor', colors(1,:)); hold on
    errorbar(x, mean(Y(:,:,k),2, 'omitnan'), std(Act,1,2, 'omitnan'), '.', 'color', colors(1,:)); hold on

    box off
    xticklabels(conds(id))
    ylabel(ylabs{k})
    title(titles{k})
    
    for j = 1:size(Pmet,1)
        if Ps(j) == Pi
            lw = 2;
        else
            lw = .5;
        end
    
        plot(x(id), squeeze(Y(id,j,k)), '.:', 'color', acolors(j,:), 'DisplayName',num2str(Ps(j)), 'linewidth', lw)

    end
    
end


legend('location', 'best')


end