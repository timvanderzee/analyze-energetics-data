clear all; close all; clc
addpath(genpath(cd))

datafolder = 'C:\Users\u0167448\OneDrive - KU Leuven\10. Energetics\dataset';

visualize = 0;
colors = lines(8);

Ps = 1:15;

labs = {'VL_L', 'VM_L', 'RF_L', 'VL_R', 'VM_R', 'RF_R', 'BF', 'SM', 'GL', 'GM', 'TA'};

for i = 1:11 % max number of EMG channels
    units{i} = ' (%)';
    ymins(i) = -5;
    ymaxs(i) = 50;
end

labs = [labs, {'Angle', 'Velocity','Torque'}];
units = [units, {' (deg)', ' (deg/s)', ' (N-m)'}];

ymins = [ymins, 0 -300 -50];
ymaxs = [ymaxs, 70 300 100];


% pre-allocate
% N = 9;
% M = length(Ps);

% Data_active      = nan(2000, N, M, 14);
% Data_passive     = nan(2000, N, M, 14);

% load MVC
load('MVC.mat', 'MVCs');

%% Load existing data
cd('C:\Users\u0167448\OneDrive - KU Leuven\10. Energetics\dataset')
load('cycle_data.mat', 'tlin', 'Data_active', 'Data_passive', 'labs', 'units','ymins', 'Tcycle')

%% Process

th = 20; % velocity threshold
smps = [1 1 1 -1 -1 -1 0 0 1];

for P = Ps
    
    disp(P)
    
    subject_folder = [datafolder, '\P', num2str(P), '\cybex'];
    
    if isfolder(subject_folder)
        cd(subject_folder)
        
        load(['P', num2str(P), '_data.mat'], 'data', 'conds')
        
        for trial = 1:9
            %             Data = [EMGn Kangle Vel Tknee];
            
            Data = [data(trial).EMG data(trial).Angle data(trial).Velocity data(trial).Torque];
            
            ks = trial;
            
            %% get locs
            if ~strcmp(conds{trial}(1), 'I')
                Vel = data(trial).Velocity * smps(trial);

                id = 1;
                i = 0;
                ids = [];

                while id < length(Vel)
    %             for i = 1:10

                    id1 = find(Vel(id:end) > th, 1) + id - 1; % start of movement
                    id = find(Vel(id1:end) < th, 1) + id1; % end of movement

                    i = i+1;

                    if ~isempty(id)
                        ids(i) = id;
                    else
                        break
                    end

                end
            end
            
            fs = 1./mean(diff(data(trial).Time));
            
%             locs = ids;
            locs = ids + round(fs * .5/.374);
            
            %% calc per cycle
%             [b,a] = butter(1, 0.5/(.5*fs), 'low');
%             Kangle = data(trial).Angle;
            t = data(trial).Time;
%             Kangle_filt = filtfilt(b,a,Kangle);
%             
%             if strcmp(conds{trial}(1), 'c')
%                 [~, alocs] = findpeaks(-Kangle_filt);
%             else
%                 [~, alocs] = findpeaks(Kangle_filt);
%             end
%             
%             % only consider when greater than 1 s
%             x1 = find(diff(t(alocs))>1, 1, 'first');
%             x2 = find(diff(t(alocs))>1, 1, 'last');
%             locs = alocs(x1:x2);
%             pks = apks(x1:x2);
            
            if ~strcmp(conds{trial}(1), 'I')
                Ts = t(locs(2:end-1));
            else
                
                Ts = (1/.374):(1/.374):max(t);
            end
            
            Ts = Ts(Ts<350);
            
            Tcycle(ks,P) = median(diff(Ts));
            tlin = linspace(0,Tcycle(ks,P), 2000);
            
            activeData = nan(length(tlin), length(Ts)-1, size(Data,2));
            passiveData = nan(length(tlin), length(Ts)-1, size(Data,2));
            
            if P == 4 && trial == 2
                tmax = 280;
            else
                tmax = 350;
            end
            
            for i = 1:size(Data,2)
                for k = 1:length(Ts)-1
                    ids = t > Ts(k) & t < Ts(k+1);
                    
                    % normalized time
                    tau  = (t(ids) - t(find(ids,1))) / (t(find(ids,1, 'last')) - t(find(ids,1, 'first')));
                    
                    if Ts(k) < 45
                        passiveData(:,k,i) = interp1(tau, Data(ids,i), linspace(0,1,length(tlin)));
                        
                    elseif Ts(k) > 200 && Ts(k) < tmax
                        activeData(:,k,i) = interp1(tau, Data(ids,i), linspace(0,1,length(tlin)));
                        
                    end
                    
                end
            end
            
            %% compute average terms
            for i = 1:size(activeData, 3)
                Data_active(:,ks, P, i)  = mean(activeData(:,:,i), 2, 'omitnan');
                Data_passive(:,ks, P, i)  = mean(passiveData(:,:,i), 2, 'omitnan');
            end
            
            
            %% plot per cycle
            if visualize
                
                
                for i = 1:size(Data,2)
                    
                    figure(trial + (P-1)*10)
                    set(gcf, 'Name', conds{trial})
                    nexttile
                    
                    plot(tlin, activeData(:,:,i), 'color', [.8 .8 1]); hold on
                    plot(tlin, passiveData(:,:,i), 'color', [1 .8 .8]); hold on
                    
                    plot(tlin, mean(activeData(:,:,i), 2, 'omitnan'), '-', 'linewidth', 2, 'color', colors(1,:)); hold on
                    plot(tlin, mean(passiveData(:,:,i), 2, 'omitnan'), '-', 'linewidth', 2, 'color', colors(2,:)); hold on
                    
                    title(labs{i})
                    ylabel([labs{i}, units{i}])
                    yline(0,'k--')
                    box off
                    
                    ylim([ymins(i) ymaxs(i)])
                    
                    xlim([0 Tcycle(ks,P)])
                end
                
                %                     plot(tlin, Pmean, 'k--')
                xlabel('Time (s)')
                
            end
            
            
            % make figure nice
            if visualize
                for i = 1:(trial-1)
                    
                    figure(i + (P-1)*10)
                    set(gcf, 'units', 'normalized', 'position', [.2 .2 .3 .6])
                    
                    
                end
            end
        end
        
    else
        disp('Could not find folder')
    end
end

return
%% plot summary
close all
colors = parula(11);

for k = 1:size(Data_active,2)
    figure(k)
    
    set(gcf, 'WindowState', 'maximized', 'Name', conds{k});
    
    for i = 1:size(Data_active,4)
        
        
        nexttile
        
        if ~strcmp(conds{k}(1), 'I')
            tcon = [find(Data_active(:,k,1,13) > 20, 1, 'first') find(Data_active(:,k,1,13) > 20, 1, 'last')];
            tecc = [find(Data_active(:,k,1,13) < -20, 1, 'first') find(Data_active(:,k,1,13) < -20, 1, 'last')];
            
            h = patch(tlin([tcon flip(tcon)]), 10*[-100 -100 100 100], [.9 .9 .9], 'linestyle', 'none'); hold on
            patch(tlin([tecc flip(tecc)]), 10*[-100 -100 100 100], [.9 .9 .9], 'linestyle', 'none'); hold on
        end
        
        for P = Ps
            
            
            plot(tlin, Data_active(:,k,P,i),'color', colors(P,:), 'linewidth', 1.5); hold on
            
            plot(tlin, Data_passive(:,k,P,i),'--','color', colors(P,:), 'linewidth', 1.5); hold on
            
        end
        
        title(labs{i})
        ylabel([labs{i}, units{i}])
        yline(0,'k--')
        box off
        
        ylim([ymins(i) ymaxs(i)])
        
        xlim([0 Tcycle(ks,P)])
        
    end
end

%% Save
cd('C:\Users\u0167448\OneDrive - KU Leuven\10. Energetics\dataset')
save('cycle_data.mat', 'tlin', 'Data_active', 'Data_passive', 'labs', 'units','ymins', 'Tcycle')
