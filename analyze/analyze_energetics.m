function[X, vels] = analyze_energetics(Ps, v, Pi, cor, i, type)

if nargin < 6
    type = 'joint-based';
end

if nargin < 5 || isempty(i)
    i = 1;
end

if nargin < 4 || isempty(cor)
    cor = 0;
end

cd('C:\Users\u0167448\Documents\GitHub\analyze-energetics-data\data')
load(['mechanics_v', num2str(v), '.mat'], 'W', 'conds', 'Ts', 'Tl', 'mTcycle', 'Iact', 'A', 'Wm', 'vm')
load('metabolics.mat', 'Pmet', 'Pmet_alt')

vels = vm(Ps,:)';

Pmet = Pmet(Ps,1:length(conds));
Pmet = Pmet_alt(Ps,1:length(conds));
% conds = {'c60','c120','c240', 'e60','e120','e240', 'ISOM_EXT', 'ISOM_FLEX', 'STR-SHOR'};

Act = A(1:length(conds),Ps,1);

%% compute efficiency
if strcmp(type, 'muscle-based')
    W = Wm;
end

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
    
    Pmet(Pmet<5) = nan;
    eff     = Pav./ Pmet' * 100;
end

%% plot
% close all
acolors = parula(length(Ps));
colors = lines(5);
names = {'Net','Positive', 'Negative'};
ylabs = {'Activation (%)', 'Net metabolic rate (W)', 'Net joint power (W)', 'Efficiency (%)'};

if v == 1
    x = [1:3 -1:-1:-3 5:7];
else
    x = [1:4 -1:-1:-4];
end


% [~, id] = sort(x);

X(:,:,1) = Act;
X(:,:,2) = Pmet';
X(:,:,3) = Pav(:,:,i);
X(:,:,4) = eff(:,:,i);

titles = {'Quadriceps activation', 'Metabolic energy cost', 'Mechanical work', 'Mechanical efficiency'};

avels = [30 60 120 240];

sgns = [1 -1];
aps = [0 .95];

for jj = 1:2

    if jj == 1
        Y = X(1:4,:,:);
    else
        Y = X(5:8,:,:);
    end
    
    for k = 1:size(Y,3)

        subplot(1,4,k)
        
        if k > 2 && jj == 2
            imax = 2;
        else
            imax = 1;
        end
        
        for ii = 1:imax     
            bar((1:4) -.2 + (jj-1)*.4, sgns(ii)*mean(Y(:,:,k), 2, 'omitnan'),'facecolor', brighten(colors(jj,:),aps(ii)), 'BarWidth', .35, 'EdgeColor', 'none'); hold on
            errorbar((1:4) -.2 + (jj-1)*.4, sgns(ii)*mean(Y(:,:,k),2, 'omitnan'), std(Y(:,:,k),1,2, 'omitnan'), '.', 'color', brighten(colors(jj,:),aps(ii))); hold on
        end

            
        box off
        xticks(1:4)
        xticklabels(avels)
        ylabel(ylabs{k})
        title(titles{k})
        xlabel('Joint velocity (deg/s)')
        
        xlim([.5 4.5])
%         ylims(
    end
end

for k = 1:4
    for kk = 1:4
           subplot(1,4,k)
        for j = 1:size(Pmet,1)
            if Ps(j) == Pi
                lw = 2;
            else
                lw = .5;
            end

            if k > 2
                sig = -1;
            else
                sig = 1;
            end
                
            plot(kk + [-.2 .2], [X(kk,j,k) sig*X(kk+4,j,k)], '.--','color', .7*[1 1 1], 'linewidth', lw)

        end
    end
end


% legend('location', 'best')


end