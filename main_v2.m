clear all; close all; clc
addpath(genpath(cd))

fs = 1000;
dt = 1/fs;

datafolder = 'C:\Users\u0167448\OneDrive - KU Leuven\10. Energetics\dataset';

visualize = 1;
colors = lines(8);

Ps = 2;

EMGchannels = 4 * ones(1,11);

% conditions that exist
vid = 1:10;

Sdata(1).conds = {'MVC_QCEPS_L', 'c60','c120','c240', 'e60','e120','e240', 'ISOM_EXT', 'ISOM_FLEX', 'STR-SHOR'};
Sdata(2).conds = {'MVC_QUAD L', 'c60','c120','c240', 'e60','e120','e240', 'ISOM_EXT', 'ISOM_FLEX', 'STR-SHOR'};
Sdata(3).conds = {'MVC_QUADS L', 'c60','c120','c240', 'e60','e120','e240', 'ISOM_EXT', 'ISOM_FLEX', 'STR-SHOR'};
Sdata(4).conds = {'MVC QUAD L', 'c60','c120','c240', 'e60','e120','e240', 'ISOM_EXT', 'ISOM_FLEX', 'STR-SHOR'};
Sdata(5).conds = {'MVC_QUADS L', 'c60','c120','c240', 'e60','e120','e240', 'ISOM_EXT', 'ISOM_FLEX', 'STR-SHOR'};
Sdata(6).conds = {'MVC_QUAD L', 'c60','c120','c240', 'e60','e120','e240', 'ISOM_EXT', 'ISOM_FLEX', 'STR-SHOR'};
Sdata(7).conds = {'MVC_QUAD_Flex_2', 'c60','c120','c240', 'e60','e120','e240', 'ISOM_EXT', 'ISOM_FLEX', 'STR-SHOR'};
Sdata(8).conds = {'MVC_QUAD L', 'c60','c120','c240_2', 'e60','e120','e240', 'ISOM_EXT', 'ISOM_FLEX', 'STR_SHOR'};
Sdata(9).conds = {};
Sdata(10).conds = {'QUAD L', 'c60','c120','c240', 'e60','e120','e240', 'ISOM_EXT', 'ISOM_FLEX', 'STR_SHOR'};
Sdata(11).conds = {'QUAD_L', 'c60','c120','c240', 'e60','e120','e240', 'ISOM_EXT', 'ISOM_FLEX', 'STR_SHOR'};

Sdata(1).vid = (1:10);
Sdata(2).vid = (1:10);
Sdata(3).vid = (1:10);
Sdata(4).vid = [1 2, 4:10]; % cybex error during c120
Sdata(5).vid = (1:10);
Sdata(6).vid = (1:10);
Sdata(7).vid = 1:10;
Sdata(8).vid = 1:10;
Sdata(10).vid = 1:10;
Sdata(11).vid = [1, 5, 6];

% tstop
Sdata(1).tstop = [10 21:10:91];
Sdata(2).tstop = [10 26:10:96];
Sdata(3).tstop = [11 25:10:95];
Sdata(4).tstop = (11:10:91);
Sdata(5).tstop = [(11:10:81), 92];
Sdata(6).tstop = (10:10:90);
Sdata(7).tstop = (10:10:90);
Sdata(8).tstop = [10, 30, 43:10:103]; % made up, need to verify
Sdata(9).tstop = (10:10:90);
Sdata(10).tstop = (10:10:90);
Sdata(11).tstop = (10:10:90);

% signals
for i = 1:11
Sdata(i).signals_of_interest = {'Voltage.x', 'Angle.Angle', 'Angular Velocity.Angular Velocity', 'Torque.Torque'};
end

% order (relevant for energetics)
Sdata(1).order = [8 2 9 5 6 4 1 7 3];
Sdata(2).order = [9 8 2 4 6 3 7 1 5];
Sdata(3).order = [8 1 7 3 5 9 4 6 2];
Sdata(4).order = [1 4 5 2 8 7 9 3 6];
Sdata(5).order = [8 9 4 6 1 5 2 7 3];
Sdata(6).order = [8 9 2 4 7 5 1 6 3];
Sdata(7).order = [3 4 2 5 7 9 8 6 1];
Sdata(8).order = [6 3 7 8 5 1 2 4 9];
Sdata(9).order = [5 2 1 7 6 8 9 3 4];
Sdata(10).order = [7 2 8 5 6 9 4 1 3];
Sdata(11).order = [4 3 7 9 8 1 5 6 2];

% pre-allocate
N = 9;
M = length(Ps);

Act     = nan(N,M);
Tav     = nan(N,M);
Wpos    = nan(N,M);
Wneg    = nan(N,M);
Wnet    = nan(N,M);
Tcycle  = nan(N,M);
Pmetn   = nan(M,N);
VO2_rest = nan(M,1);
RQ_rest = nan(M,1);

Ameans = nan(1000, N, M);
Tmeans = nan(1000, N, M);
vmeans = nan(1000, N, M);

for P = Ps
%     P = Ps;
    
    EMGchannel = EMGchannels(P);

    conds = Sdata(P).conds;

    cd([datafolder, '\P', num2str(P), '\cybex'])
    
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
            
            %%
            signals_of_interest = Sdata(P).signals_of_interest;
            signals_of_interest{1}(9) = num2str(EMGchannel);
            
            id = nan(1,length(signals_of_interest));
            for i = 1:length(signals_of_interest)
                for j = 1:length(analogLabels)
                    if strcmp(analogLabels{j}, signals_of_interest(i))
                        id(i) = j;
                    end
                end
            end

            N = length(analogData);
            t = 0:dt:(N-1)*dt;

            EMG     = analogData(:,id(1));
            Kangle  = analogData(:,id(2)) * 180/pi;
            Vel     = analogData(:,id(3)) * -180/pi;
            Tknee   = analogData(:,id(4)) * 1000;

            % simple calculations
            Acc     = grad5(Vel(:), dt);
            Power   = Tknee .* Vel * pi/180;
            
            %% filter EMG
            [b1,a1] = butter(1, 20/(.5*fs), 'high');
            [b2,a2] = butter(1, 5/(.5*fs), 'low');
            
            EMGf = filtfilt(b1,a1, EMG);
            EMGff = filtfilt(b2,a2,abs(EMGf));
            EMGb = mean(EMGff(t < 1));
            EMGe = EMGff - EMGb;
            
            %% get data
            if trial == 1 % MVC
                if P == 3
                    EMGe(t > 50) = nan; % artefact
                end
                
                [EMG_MVC(trial,P), mid] = max(movmean(EMGe, 500));
                
                if visualize
                    figure(100)
                    nexttile
                    plot(t, EMGe, t, movmean(EMGe, 500)); hold on
                    plot(t(mid), EMG_MVC(trial,P),'o')
                    
                    nexttile
                    plot(t, Tknee)
                end
                
            else
                
                %% load ultrasound
%                 if isfolder([datafolder, dates{P}, '\ultrasound'])
%                     cd([datafolder, dates{P}, '\ultrasound'])
% 
%                     faslen = [];
%                     time = [];
% 
%                     TF = [0 240];
% 
%                     for i = 1:2    
%                         filename = ['p', num2str(P), '_', conds{trial}, '_', num2str(i), '_tracked.mat'];
% 
%                         if exist(filename, 'file')
%                             load(filename);
%                             % sync
%                             delay = 120-Fdat.Region.Time(end);
%                             tshift = Fdat.Region.Time + 1 + delay + TF(i);
% 
%                             faslen = [faslen; Fdat.Region.FL(:)];
%                             time = [time; tshift];
% 
%                         end
%                     end
%                 
%                     % interpolate
%                     FL = interp1(time,faslen, t);                
%                 else
                    FL = nan(size(t));
%                 end
                

                %% combine data
                EMGn = EMGe / EMG_MVC(1,P) * 100;
                Data = [EMGn Kangle Vel Acc Tknee Power FL(:)];
                
                ks = trial-1;
                
                %% calc per cycle
                [b,a] = butter(1, 0.5/(.5*fs), 'low');
                Kangle_filt = filtfilt(b,a,Kangle);

                [apks, alocs] = findpeaks(-Kangle_filt);

                % only consider when greater than 1 s
                x1 = find(diff(t(alocs))>1, 1, 'first');
                x2 = find(diff(t(alocs))>1, 1, 'last');
                locs = alocs(x1:x2);
                pks = apks(x1:x2);
                
                if ~strcmp(conds{trial}(1), 'I')
                    Ts = t(locs);
                else
                    
                    Ts = (1/.374):(1/.374):max(t); 
                end
                
                Ts = Ts(Ts<350);
                
                Tcycle(ks,P) = median(diff(Ts));
                tlin = linspace(0,Tcycle(ks,P), 1000);
                
                activeData = nan(length(tlin), length(Ts)-1, size(Data,2));
                passiveData = nan(length(tlin), length(Ts)-1, size(Data,2));
                
                for i = 1:size(Data,2)
                    for k = 1:length(Ts)-1
                        ids = t > Ts(k) & t < Ts(k+1);
                        
                        if ~strcmp(conds{trial}(1), 'I') || P > 3
                            if Ts(k) < 50
                                passiveData(:,k,i) = interp1(t(ids) - t(find(ids,1)),Data(ids,i), tlin);
                            elseif Ts(k) > 250 && Ts(k) < 350
                                activeData(:,k,i) = interp1(t(ids) - t(find(ids,1)),Data(ids,i), tlin);
                            end
                        else
                            activeData(:,k,i) = interp1(t(ids) - t(find(ids,1)),Data(ids,i), tlin);
                            passiveData(:,k,i) = ones(size(tlin)) * mean(Data(t<1,i));
                        end
                    end
                end
                
               
                
                %% compute average terms
                Amean = mean(activeData(:,:,1), 2, 'omitnan') - mean(passiveData(:,:,1), 2, 'omitnan');
                Tmean = mean(activeData(:,:,5), 2, 'omitnan') - mean(passiveData(:,:,5), 2, 'omitnan');
                vmean = mean(activeData(:,:,3), 2, 'omitnan');
                Pmean = Tmean .* vmean * pi/180;
                Lmean = mean(activeData(:,:,7), 2, 'omitnan');
                
                idf = isfinite(Pmean);
                
                Ppos = Pmean;
                Pneg = Pmean;
                
                Ppos(Ppos<0) = 0;
                Pneg(Pneg>0) = 0;
                
                Act(ks,P) = mean(Amean, 'omitnan');
                Tav(ks,P) = mean(Tmean, 'omitnan');
                Wpos(ks,P) = trapz(tlin(idf), Ppos(idf));
                Wneg(ks,P) = trapz(tlin(idf), Pneg(idf));
                Wnet(ks,P) = trapz(tlin(idf), Pmean(idf));   
                
                % store
                Ameans(:,ks, P) = Amean;
                vmeans(:,ks, P) = vmean;
                Tmeans(:,ks, P) = Tmean;
                 
                %% plot per cycle
                if visualize
                    labs = {'Activation', 'Angle', 'Velocity', 'Acceleration', 'Torque', 'Power', 'Length'};
                    units = {' (%)', ' (deg)', ' (deg/s)', ' (deg/s^2)', ' (N-m)', ' (W)', 'mm'};
                    
                    ymins = [-5 0 -300 -1e4 -20 -100 50];
                    ymaxs = [50 70 300 1e4 100 100 160];
                    
                    for i = 1:size(Data,2)
                        
                        figure(trial + (P-1)*10 - 1)
                        set(gcf, 'Name', conds{trial})
                        nexttile
                        
                        plot(tlin, activeData(:,:,i), 'color', [.8 .8 1]); hold on
                        plot(tlin, passiveData(:,:,i), 'color', [1 .8 .8]); hold on
                        plot(tlin, mean(activeData(:,:,i), 2, 'omitnan'), '-', 'linewidth', 2, 'color', colors(1,:)); hold on
                        plot(tlin, mean(passiveData(:,:,i), 2, 'omitnan'), '-', 'linewidth', 2, 'color', colors(2,:)); hold on
                        
                        plot(tlin, mean(activeData(:,:,i), 2, 'omitnan') - mean(passiveData(:,:,i), 2, 'omitnan'), '-', 'linewidth', 2, 'color', colors(3,:)); hold on
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
    end
    
    % make figure nice
    if visualize
        for i = 1:(trial-1)
            
            figure(i + (P-1)*10)
            set(gcf, 'units', 'normalized', 'position', [.2 .2 .3 .6])
%             
%             subplot(321)
%             yline(20,'k--')
% 
%             subplot(323)
%             yline(vels(i),'k--')
            
        end
    end

    
    %% analyze energetics    
    cd([datafolder, '\P', num2str(P)])
    filename = ['P',num2str(P), '.xlsx'];
    
    time = readmatrix(filename,   "OutputType",  "datetime", "Range", 'J:J');
    VO2r = readmatrix(filename, "Range", 'O:O');
    RQr = readmatrix(filename, "Range", 'Q:Q');
    
    tr = hour(time)*60 + minute(time) + second(time)/60;
    tint = 0:(1/60):max(tr);
    
    % get finite values
    isf = isfinite(tr);
    tf = tr(isf);
    VO2f = VO2r(isf);
    RQf = RQr(isf);
    
    % get unique values
    [~, isu] = unique(tf);
    tu = tf(isu);
    VO2 = VO2f(isu);
    RQ = RQf(isu);
    
    % interpolate
    VO2i = interp1(tu, VO2, tint);
    RQi = interp1(tu, RQ, tint);
    
    % moving average
    VO2a = movmean(VO2i, [2 0],'SamplePoints',tint);
    RQa = movmean(RQi, [2 0],'SamplePoints',tint);
    
    % net oxygen consumption
    [VO2_rest(P), mid] = min(VO2a);
    [VO2_rest(P)] = mean(VO2i(tint<5), 'omitnan');
    
    VO2n = VO2a - VO2_rest(P);
    RQ_rest(P) = RQa(mid);
    
    figure(200)
    nexttile
    plot(tr, VO2r - VO2_rest(P), 'color', [.8 .8 .8]); hold on
    plot(tint, VO2n,'-', 'color', colors(2,:), 'linewidth', 2)
    title('VO2')
    
    yline(0,'k--')
    
    tstop = Sdata(P).tstop;
    VO2m = nan(1, length(tstop));
    for i = 1:length(tstop)
        xline(tstop(i), 'k--')
        VO2m(i) = interp1(tint, VO2n, tstop(i));
        plot(tstop(i), VO2m(i), 'ko')
    end
    
    nexttile
    plot(tr, RQr, 'color', [.8 .8 .8]); hold on
    plot(tint, RQa,'-', 'color', colors(2,:), 'linewidth', 2)
    title('RQ')
    
    yline(RQ_rest(P),'k--')
    
    RQm = nan(1, length(tstop));
    for i = 1:length(tstop)
        xline(tstop(i), 'k--')
        RQm(i) = interp1(tint, RQa, tstop(i));
        plot(tstop(i), RQm(i), 'ko')
    end
    
    % calc metabolic energy expenditure according to Brockway
    RQdata = [0.7145; 1];
    joule_per_o2_data = [19.8071 21.0956] * 1e3;
    joule_per_o2 = polyval(polyfit(RQdata, joule_per_o2_data, 1), RQm); % Joule per L
    
    % calculate net metabolic rate
    Pmetn(P,1:length(VO2m)) = (VO2m /1000 / 60) .* joule_per_o2; % W
    
end

%% summary graphs
if ishandle(300), close(300); end
delta = [0 -5 5 0 0 0];
bw = [.5 .1 .1 .5 1 1];


vels = [60 120 240 -60 -120 -240 -5 5 0];

scolors = colors([6 2 1 3 5 1],:);

% average mechanical power
Pmech_pos = Wpos./Tcycle;
Pmech_net = Wnet./Tcycle;
Pmech_neg = Wneg./Tcycle;

titles = {'Activation', 'Torque', 'Mechanical power', 'Metabolic power', 'Mechanical efficiency'};
units = {'%', 'N-m', 'W', 'W', '-'};

% for P = 2

    order = Sdata(P).order;
    N = length(order);
    
    emech = Pmech_net(:,P) ./ Pmetn(P,order)';
    
    figure(300)   
    subplot(511)
    bar(Act(:,P));hold on
  
    subplot(512)
    bar(Tav(:,P));hold on
  
    subplot(513)
    bar([Pmech_net(:,P) Pmech_pos(vid(2:end)-1,P) Pmech_neg(vid(2:end)-1,P)]); hold on
    
    subplot(514)
    bar(Pmetn(P,order)); hold on
  
    subplot(515)
    bar(emech * 100); hold on

    xlabel('Angular velocity condition (deg/s)') 
% end


% legend('P1 - P 1', 'P2 - P 1', 'P2 - P 2', 'location', 'best')

%
for i = 1:5
    subplot(5,1,i)
%     set(gca, 'xtick', -200:50:200);
    title(titles{i})
    xticklabels(Sdata(1).conds(2:end));
    ylabel([titles{i}, '(', units{i}, ')'])
    box off
end



