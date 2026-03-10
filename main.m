clear all; close all; clc
addpath(genpath(cd))

fs = 1000;
dt = 1/fs;

datafolder = 'C:\Users\u0167448\OneDrive - KU Leuven\10. Energetics\';

Ps = [3 2 3];
dates = {'0903','2302','2302'};
visualize = 1;
EMGchannels = [8 1 3];
colors = lines(8);

% conditions
vels = [50   100   150   200   -50  -100 -150 -200 0 0];
Sdata(1).conds = {'MVC_extension', 'c50_01', 'c100_01', 'c150_01', 'c200_01', 'e50_01', 'e100_01', 'e150_01', 'e200_01', 'ISOM_ext', 'ISOM_FL'};
Sdata(2).conds = {'MVC', 'c50', 'c100', 'c150', 'c200', 'e50', 'e100'};
Sdata(3).conds = {'MVC', 'c50', 'c100', 'c150', 'c200', 'e50', 'e100'};

% tstop
Sdata(1).tstop = (11:8:83);
Sdata(2).tstop = (13:8:55);
Sdata(3).tstop = (12:8:55);
     
% order (relevant for energetics)
Sdata(1).order = [3:6, 10, 9, 8, 7, 2, 1];
Sdata(2).order = (1:6);
Sdata(3).order = (6:-1:1);

% pre-allocate
N = 10;
Act     = nan(N,3);
Tav     = nan(N,3);
Wpos    = nan(N,3);
Wneg    = nan(N,3);
Wnet    = nan(N,3);
Tcycle  = nan(N,3);
Pmetn   = nan(3,N);
VO2_rest = nan(3,1);
RQ_rest = nan(3,1);

for session = 1:3
    P = Ps(session);
    
    EMGchannel = EMGchannels(session);
    conds = Sdata(session).conds;

    cd([datafolder, dates{session}, '\P', num2str(P), '\Nexus\t1'])
    
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
    for trial = 1:length(filenames)
        if ~isempty(filenames{trial})
            data = ezc3dRead(filenames{trial});
            
            % Check available analog channels
            analogLabels = data.parameters.ANALOG.LABELS.DATA;
            
            % Read analog data
            analogData = data.data.analogs;  % [samples × channels]
            
            %%
            signals_of_interest = {['Voltage.',num2str(EMGchannel)], 'Angle.Angle', 'Angular Velocity.1', 'Torque.Torque'};
            
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
                [EMG_MVC(trial,session), mid] = max(movmean(EMGe, 500));
                
                if visualize
                    figure(100)
                    nexttile
                    plot(t, EMGe, t, movmean(EMGe, 500)); hold on
                    plot(t(mid), EMG_MVC(trial,session),'o')
                    
                    nexttile
                    plot(t, Tknee)
                end
                
            else
                
                %% figure 2: determine frequency
                EMGn = EMGe / EMG_MVC(1,session) * 100;
                Data = [EMGn Kangle Vel Acc Tknee Power];
                
                ks = trial-1;
                
                %% calc per cycle
                [b,a] = butter(1, 1/(.5*fs), 'low');
                Kangle_filt = filtfilt(b,a,Kangle);

                [apks, alocs] = findpeaks(-Kangle_filt);

                % only consider when greater than 1 s
                x = find(diff(t(alocs))>1, 1);
                locs = alocs(x:end);
                pks = apks(x:end);
                
                if ~strcmp(conds{trial}(1), 'I')
                    Ts = t(locs);
                else
                    Ts = 2.51:2.51:max(t); % not sure why 2.51
                end
                
                Tcycle(ks,session) = mean(diff(Ts));
                tlin = linspace(0,Tcycle(ks,session), 500);
                
                activeData = nan(length(tlin), length(Ts)-1, size(Data,2));
                passiveData = nan(length(tlin), length(Ts)-1, size(Data,2));
                
                for i = 1:size(Data,2)
                    for k = 1:length(Ts)-1
                        ids = t > Ts(k) & t < Ts(k+1);
                        
                        if ~strcmp(conds{trial}(1), 'I')
                            if Ts(k) < 30
                                passiveData(:,k,i) = interp1(t(ids) - t(find(ids,1)),Data(ids,i), tlin);
                            elseif Ts(k) > 100
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
                
                idf = isfinite(Pmean);
                
                Ppos = Pmean;
                Pneg = Pmean;
                
                Ppos(Ppos<0) = 0;
                Pneg(Pneg>0) = 0;
                
                Act(ks,session) = mean(Amean, 'omitnan');
                Tav(ks,session) = mean(Tmean, 'omitnan');
                Wpos(ks,session) = trapz(tlin(idf), Ppos(idf));
                Wneg(ks,session) = trapz(tlin(idf), Pneg(idf));
                Wnet(ks,session) = trapz(tlin(idf), Pmean(idf));     
                                
                %% plot per cycle
                if visualize
                    labs = {'Activation', 'Angle', 'Velocity', 'Acceleration', 'Torque', 'Power'};
                    units = {' (%)', ' (deg)', ' (deg/s)', ' (deg/s^2)', ' (N-m)', ' (W)'};
                    
                    ymins = [-5 0 -300 -1e4 -20 -100];
                    ymaxs = [50 70 300 1e4 100 100];
                    
                    for i = 1:size(Data,2)
                        
                        figure(trial + (session-1)*10 - 1)
                        set(gcf, 'Name', conds{trial})
                        subplot(3,2,i)
                        
                        plot(tlin, activeData(:,:,i), 'color', [.9 .9 .9]); hold on
                        plot(tlin, mean(activeData(:,:,i), 2, 'omitnan'), '-', 'linewidth', 2, 'color', colors(1,:)); hold on
                        plot(tlin, mean(passiveData(:,:,i), 2, 'omitnan'), '-', 'linewidth', 2, 'color', colors(2,:)); hold on
                        plot(tlin, mean(activeData(:,:,i), 2, 'omitnan') - mean(passiveData(:,:,i), 2, 'omitnan'), '-', 'linewidth', 2, 'color', colors(3,:)); hold on
                        title(labs{i})
                        ylabel([labs{i}, units{i}])
                        yline(0,'k--')
                        box off
                        
                        ylim([ymins(i) ymaxs(i)])
                        
                        xlim([0 Tcycle(ks,session)])
                    end
                    
                    plot(tlin, Pmean, 'k--')
                    xlabel('Time (s)')
                    
                end
                
            end
        end
    end
    
    % make figure nice
    if visualize
        for i = 1:(trial-1)
            
            figure(i + (session-1)*10)
            set(gcf, 'units', 'normalized', 'position', [.2 .2 .3 .6])
            
            subplot(321)
            yline(20,'k--')

            subplot(323)
            yline(vels(i),'k--')
            
        end
    end

    
    %% analyze energetics    
    cd([datafolder, dates{session}, '\P', num2str(P)])
    filename = ['P',num2str(Ps(session)), '.xlsx'];
    
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
    t = tf(isu);
    VO2 = VO2f(isu);
    RQ = RQf(isu);
    
    % interpolate
    VO2i = interp1(t, VO2, tint);
    RQi = interp1(t, RQ, tint);
    
    % moving average
    VO2a = movmean(VO2i, [2 0],'SamplePoints',tint);
    RQa = movmean(RQi, [2 0],'SamplePoints',tint);
    
    % net oxygen consumption
    [VO2_rest(session), mid] = min(VO2a);
    VO2n = VO2a - VO2_rest(session);
    RQ_rest(session) = RQa(mid);
    
    figure(200)
    nexttile
    plot(tr, VO2r - VO2_rest(session), 'color', [.8 .8 .8]); hold on
    plot(tint, VO2n,'-', 'color', colors(2,:), 'linewidth', 2)
    title('VO2')
    
    yline(0,'k--')
    
    tstop = Sdata(session).tstop;
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
    
    yline(RQ_rest(session),'k--')
    
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
    Pmetn(session,1:length(VO2m)) = (VO2m /1000 / 60) .* joule_per_o2; % W
    
end

%% summary graphs
if ishandle(300), close(300); end
delta = [0 -5 5];
bw = [.5 .1 .1];

vels = [50   100   150   200   -50  -100 -150 -200 -5 5];

scolors = colors([6 2 1],:);

% average mechanical power
Pmech_pos = Wpos./Tcycle;
Pmech_net = Wnet./Tcycle;

titles = {'Activation', 'Torque', 'Mechanical power', 'Metabolic power', 'Mechanical efficiency'};
units = {'%', 'N-m', 'W', 'W', '-'};

for session = [2 3 1]

    order = Sdata(session).order;
    N = length(order);
    
    emech = Pmech_pos(1:N,session) ./ Pmetn(session,order)';
    
    figure(300)   
    subplot(511)
    bar(vels(1:N)+delta(session), Act(1:N,session), 'BarWidth', bw(session), 'facecolor', scolors(session,:));hold on
    
    subplot(512)
    bar(vels(1:N)+delta(session), Tav(1:N,session), 'BarWidth', bw(session), 'facecolor', scolors(session,:));hold on
  
    subplot(513)
    bar(vels(1:N)+delta(session), Pmech_pos(1:N,session), 'BarWidth', bw(session), 'facecolor', scolors(session,:)); hold on
    
    subplot(514)
    bar(vels(1:N)+delta(session), Pmetn(session,order), 'BarWidth', bw(session), 'facecolor', scolors(session,:)); hold on
  
    subplot(515)
    bar(vels(1:N)+delta(session), emech * 100, 'BarWidth', bw(session), 'facecolor', scolors(session,:)); hold on

    xlabel('Angular velocity condition (deg/s)') 
end


legend('P1 - session 1', 'P2 - session 1', 'P2 - session 2', 'location', 'best')

%
for i = 1:5
    subplot(5,1,i)
    set(gca, 'xtick', -200:50:200);
    title(titles{i})
    ylabel([titles{i}, '(', units{i}, ')'])
    box off
end



