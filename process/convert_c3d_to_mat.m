clear all; close all; clc
addpath(genpath(cd))

fs = 1000;
dt = 1/fs;

datafolder = 'C:\Users\u0167448\OneDrive - KU Leuven\10. Energetics\dataset';

Ps = 1;

for i = 1:11 % max number of EMG channels
    SOIs{i} = 'Voltage.x';
end

% signals
conds = {'c60','c120','c240', 'e60','e120','e240', 'ISOM_EXT', 'ISOM_FLEX', 'STR-SHOR'};

% load MVC and graivty
load('MVC.mat', 'MVCs');
load('gravity.mat', 'As');

% downsample factor
dsf = 4;

%% Process
for P = Ps
    data = [];
    
    signals_of_interest = [SOIs, {'Angle.Angle', 'Angular Velocity.Angular Velocity', 'Torque.Torque'}];    
    
    disp(P)
    
    if P == 1
        EMGchannels = [4 10 8 6 12 7 5 9 11 13 14]; % switch GM and GL
    elseif P == 11 % blue box
        EMGchannels = [4 10 16 12 11 7 15 9 13 1 14];
    elseif P > 11
        EMGchannels = [4 10 16 12 11 7 3 9 1 1 14];
    else % white box
        EMGchannels = [4 10 8 6 12 7 5 9 13 11 14];
    end
       
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
        for trial = 1:9
            if ~isempty(filenames{trial})
                                
                c3ddata = ezc3dRead(filenames{trial});
                
                % Check available analog channels
                analogLabels = c3ddata.parameters.ANALOG.LABELS.DATA;
                
                % Read analog data
                analogData = c3ddata.data.analogs;  % [samples × channels]
                                
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
                
                EMG    = analogData(:,id(1:length(EMGchannels)));
                Aknee  = analogData(:,id(length(EMGchannels)+1)) * 180/pi;
                Vknee  = analogData(:,id(length(EMGchannels)+2)) * -180/pi;
                Tknee  = analogData(:,id(length(EMGchannels)+3)) * 1000;
                
                %% filter mechanics data
                % mechanics data
                MData = [Aknee Vknee Tknee];
                
                [b,a] = butter(1, 50/(.5*fs), 'low');
                
                FData = nan(size(MData));
                for ii = 1:size(MData,2)
                    FData(:,ii) = filtfilt(b,a, MData(:,ii));
                end
                
                %% filter EMG
                % remove GM
                EMG(:,10) = 0;
                
                % filter
                [b1,a1] = butter(1, [20 400]/(.5*fs), 'bandpass');
%                 [b2,a2] = butter(1, 5/(.5*fs), 'low');
                
                EMGff = nan(size(EMG));
                for ii = 1:length(EMGchannels)
                    EMGf = filtfilt(b1,a1, EMG(:,ii));
                    EMGff(:,ii) = abs(EMGf);
%                     EMGff = filtfilt(b2,a2,abs(EMGf));

                end
                

                % normalize with respect to MVC
                fEMG = EMGff ./ MVCs(P,1:length(EMGchannels)) * 100;
                fEMG2 = EMG ./ MVCs(P,1:length(EMGchannels)) * 100;
                
%                 % no MVCs
%                 if P == 2
%                     fEMG(:,4) = 0; % no VL MVC
%                 elseif P == 5 || P == 6
%                     fEMG(:,9) = 0;   
%                 elseif P == 10
%                     fEMG(:,7) = 0;
%                 end
                                 
                % noise detection
                dEMGs = [zeros(1,size(fEMG,2)); diff(fEMG2)];
                sid = abs(dEMGs) > 300;
                
                for i = 1:size(EMG,2)
                    ids = find(sid(:,i));
                    ir(i) = sum(sid(:,i));
                    
                    if ir(i) > 10
                    
                        for j = 1:length(ids)
                            i1 = max(1, ids(j)-200);
                            i2 = min(length(EMG), ids(j)+200);

                            fEMG(i1:i2,i) = nan;
                        end
                    end
                end
                
                EMGn = nan(size(EMG));
                for ii = 1:length(EMGchannels)
                      
                    EMGb = mean(fEMG(t < 50));
                    EMGn(:,ii) = fEMG(:,ii) - EMGb;
                end
   
                % normalize wit respect to MVC
%                 EMGn = EMGe ./ MVCs(P,1:length(EMGchannels)) * 100;
                
                %% subtract gravity
                FData(:,3) = FData(:,3) - (As(P,1)*cosd(FData(:,1)-As(P,2)) + As(P,3));
                           
                %% downsample everything                
                data(trial).Time        = t(1:dsf:end);
                data(trial).EMG         = EMGn(1:dsf:end,:);
                data(trial).Angle       = FData(1:dsf:end,1);
                data(trial).Velocity    = FData(1:dsf:end,2);
                data(trial).Torque      = FData(1:dsf:end,3);

            end
        end
    end
    
    save(['P', num2str(P), '_data.mat'], 'data', 'conds');
    
end