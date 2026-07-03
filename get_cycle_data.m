clear all; close all; clc
addpath(genpath(cd))

fs = 1000;
dt = 1/fs;

datafolder = 'C:\Users\u0167448\OneDrive - KU Leuven\10. Energetics\dataset';

visualize = 0;
colors = lines(8);

Ps = 1:11;

labs = {'VL_L', 'VM_L', 'RF_L', 'VL_R', 'VM_R', 'RF_R', 'BF', 'SM', 'GL', 'GM', 'TA'};

for i = 1:11
    units{i} = ' (%)';
    ymins(i) = -5;
    ymaxs(i) = 50;
    SOIs{i} = 'Voltage.x';
end

labs = [labs, {'Angle', 'Velocity','Torque'}];
units = [units, {' (deg)', ' (deg/s)', ' (N-m)'}];

ymins = [ymins, 0 -300 -50];
ymaxs = [ymaxs, 70 300 100];

% signals
for i = 1:11
    Sdata(i).vid = 1:9;
    Sdata(i).conds = {'c60','c120','c240', 'e60','e120','e240', 'ISOM_EXT', 'ISOM_FLEX', 'STR-SHOR'};
    Sdata(i).signals_of_interest = [SOIs, {'Angle.Angle', 'Angular Velocity.Angular Velocity', 'Torque.Torque'}];
end

% pre-allocate
N = 9;
M = length(Ps);

Data_active      = nan(2000, N, M, 14);
Data_passive     = nan(2000, N, M, 14);

% load MVC
load('MVC.mat', 'MVCs');

for P = Ps
    
    disp(P)
    
    if P == 11 % blue box
        EMGchannels = [4 10 16 12 11 7 15 9 13 1 14];
    else % white box
        EMGchannels = [4 10 8 6 12 7 5 9 13 11 14];
    end
    
    conds = Sdata(P).conds;
    
    subject_folder = [datafolder, '\P', num2str(P), '\cybex'];
    
    if isfolder(subject_folder)
    cd(subject_folder)
    
    filenames = [];
    for i = 1:length(conds)
        files = dir(['*', conds{i}, '.c3d']);
        
        if ~isempty(files)
            filenames{i} = fullfile(files.folder, files.name);
        else
            filenames{i} = [];
        end
    end
    
    % velocity conditions
    for trial = Sdata(P).vid
        if ~isempty(filenames{trial})
            data = ezc3dRead(filenames{trial});
            
            % Check available analog channels
            analogLabels = data.parameters.ANALOG.LABELS.DATA;
            
            % Read analog data
            analogData = data.data.analogs;  % [samples × channels]
                       
            signals_of_interest = Sdata(P).signals_of_interest;
            
            for ii = 1:length(EMGchannels)
                
                num = num2str(EMGchannels(ii));
                
                signals_of_interest{ii}(9) = num(1);
                
                if length(num) > 1
                    signals_of_interest{ii}(10) = num(2);
                    
                end
                
                id = nan(1,length(signals_of_interest));
                for i = 1:length(signals_of_interest)
                    for j = 1:length(analogLabels)
                        if strcmp(analogLabels{j}, signals_of_interest(i))
                            id(i) = j;
                        end
                    end
                end
            end
            
            N = length(analogData);
            t = 0:dt:(N-1)*dt;
            
            EMG     = analogData(:,id(1:length(EMGchannels)));
            Kangle  = analogData(:,id(length(EMGchannels)+1)) * 180/pi;
            Vel     = analogData(:,id(length(EMGchannels)+2)) * -180/pi;
            Tknee   = analogData(:,id(length(EMGchannels)+3)) * 1000;
            
            %% filter EMG
            [b1,a1] = butter(1, 20/(.5*fs), 'high');
            [b2,a2] = butter(1, 5/(.5*fs), 'low');
            
            EMGe = nan(size(EMG));
            for ii = 1:length(EMGchannels)
                EMGf = filtfilt(b1,a1, EMG(:,ii));
                EMGff = filtfilt(b2,a2,abs(EMGf));
                
                EMGb = mean(EMGff(t < 50));
                EMGe(:,ii) = EMGff - EMGb;
            end
            
            %% combine data
            EMGn = EMGe ./ MVCs(P,1:length(EMGchannels)) * 100;
            Data = [EMGn Kangle Vel Tknee];
            
            ks = trial;
            
            %% calc per cycle
            [b,a] = butter(1, 0.5/(.5*fs), 'low');
            Kangle_filt = filtfilt(b,a,Kangle);
            
            if strcmp(conds{trial}(1), 'c')
                [apks, alocs] = findpeaks(-Kangle_filt);
            else
                [apks, alocs] = findpeaks(Kangle_filt);
            end
            
            % only consider when greater than 1 s
            x1 = find(diff(t(alocs))>1, 1, 'first');
            x2 = find(diff(t(alocs))>1, 1, 'last');
            locs = alocs(x1:x2);
            pks = apks(x1:x2);
            
            if ~strcmp(conds{trial}(1), 'I')
                Ts = t(locs(2:end));
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
            for i = 1:(length(EMGchannels) + 3)
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
            
            
            
        end
    end
    
    % make figure nice
    if visualize
        for i = 1:(trial-1)
            
            figure(i + (P-1)*10)
            set(gcf, 'units', 'normalized', 'position', [.2 .2 .3 .6])
            
            
        end
    end
    
    else
        disp('Could not find folder')
    end
end

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
save('cycle_data.mat', 'tlin', 'Data_active', 'Data_passive', 'labs', 'units','ymins', 'Tcycle')
