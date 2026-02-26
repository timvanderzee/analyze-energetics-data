clear all; close all; clc
addpath(genpath(cd))

Ps = [2 3];

for pp = 1:2
    P = Ps(pp);
    conds = {'MVC', 'c50', 'c100', 'c150', 'c200', 'e50', 'e100'};
    
    for i = 1:length(conds)
        if P == 2 && i > 1
            files{i} = ['p', num2str(P), '__', conds{i}, '.c3d'];
            EMGchannel = 1;
        else
            files{i} = ['p', num2str(P), '_', conds{i}, '.c3d'];
            EMGchannel = 3;
        end
    end
    
    cd(['C:\Users\u0167448\OneDrive - KU Leuven\10. Energetics\2302\P', num2str(P), '\Nexus\t1'])
    colors = lines(length(files));
    
    % velocity conditions
    for kk = 1:length(files)
        data = ezc3dRead(files{kk});
        
        % Check available analog channels
        analogLabels = data.parameters.ANALOG.LABELS.DATA;
        
        % Read analog data
        analogData = data.data.analogs;  % [samples × channels]
        
        %%
        signals_of_interest = {['Voltage.',num2str(EMGchannel)], 'Angle.Angle', 'Angular Velocity.1', 'Torque.Torque'};
        
        for i = 1:length(signals_of_interest)
            for j = 1:length(analogLabels)
                if strcmp(analogLabels{j}, signals_of_interest(i))
                    id(i) = j;
                end
            end
        end
        
        %% figure 1: time series
        fs = 1000;
        dt = 1/fs;
        N = length(analogData);
        t = 0:dt:(N-1)*dt;
        
        % for i = 1:length(id)
        %     figure(1)
        %     subplot(4,1,i)
        %     plot(t,analogData(:,id(i)))
        % end
        
        %% figure 2: determine frequency
        Kangle = analogData(:,id(2)) * 180/pi;
        
        [b,a] = butter(1, 1/(.5*fs), 'low');
        Kangle_filt = filtfilt(b,a,Kangle);
        
        % figure(2)
        % % subplot(412)
        % plot(t, Kangle)
        % hold on
        % plot(t, Kangle_filt)
        % Kangle_filt(t<3) = nan;
        
        % find peaks
        % figure(2)
        [pks, locs] = findpeaks(-Kangle_filt);
        %
        % plot(t(locs), pks, 'o')
        
        %% plot in time-series
        % Ts = t(locs);
        % figure(1)
        %
        % for i = 1:length(id)
        %     for j = 1:length(Ts)
        %
        %         subplot(4,1,i)
        %         xline(Ts(j))
        %     end
        % end
        
        %% filter EMG
        EMG = analogData(:,id(1));
        
        [b1,a1] = butter(1, 20/(.5*fs), 'high');
        
        EMGf = filtfilt(b1,a1, EMG);
        
        [b2,a2] = butter(1, 5/(.5*fs), 'low');
        EMGb = 0.0071;
        EMGe = filtfilt(b2,a2,abs(EMGf)) - EMGb;
        
        
        %% calculate acceleration
        Vel = -analogData(:,id(3)) * 180/pi;      
        Acc = grad5(Vel(:), dt);
         
        %% correct torque
        p = [-0.0173 0.0061];
        
        Tgrav = polyval(p, analogData(:,id(2)));
        
        Tknee = (analogData(:,id(4)) - Tgrav) * 1000; % - AccI;
        
        % mechanical power
        Power = Tknee .* Vel * pi/180;
        
        %% get data
        
        if kk == 1 % MVC
            EMG_MVC(kk,pp) = max(movmean(EMGe, 500));
            
        else

            EMGn = EMGe / EMG_MVC(1,pp) * 100;
            Data = [EMGn Kangle Vel Acc Tknee Power];
            
            ks = kk-1;
            %% calc per cycle
            Ts = t(locs);
            Tcycle(ks,pp) = mean(diff(Ts));
            tlin = linspace(0,Tcycle(ks,pp), 500);

            activeData = nan(length(tlin), length(Ts)-1, size(Data,2));
            passiveData = nan(length(tlin), length(Ts)-1, size(Data,2));


            for i = 1:size(Data,2)
                for k = 1:length(Ts)-1
                    ids = t > Ts(k) & t < Ts(k+1);

                    if Ts(k) < 50
                        passiveData(:,k,i) = interp1(t(ids) - t(find(ids,1)),Data(ids,i), tlin);
                    else
                        activeData(:,k,i) = interp1(t(ids) - t(find(ids,1)),Data(ids,i), tlin);
                    end
                end
            end


            %% figure 3: plot per cycle
            % if ishandle(3), close(3); end
            labs = {'Activation', 'Angle', 'Velocity', 'Acceleration', 'Torque', 'Power'};
            units = {' (%)', ' (deg)', ' (deg/s)', ' (deg/s^2)', ' (N-m)', ' (W)'};

            ymins = [-5 0 -300 -1e4 -20 -100];
            ymaxs = [50 70 300 1e4 100 100];

            for i = 1:size(Data,2)

                figure(ks + (pp-1)*10)
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

                xlim([0 Tcycle(ks,pp)])
            end

            % compute work
            Amean = mean(activeData(:,:,1), 2, 'omitnan');
            Tmean = mean(activeData(:,:,5), 2, 'omitnan') - mean(passiveData(:,:,5), 2, 'omitnan');
            vmean = mean(activeData(:,:,3), 2, 'omitnan');
            Pmean = Tmean .* vmean * pi/180;

            plot(tlin, Pmean, 'k--')

            idf = isfinite(Pmean);

            Ppos = Pmean;
            Pneg = Pmean;

            Ppos(Ppos<0) = 0;
            Pneg(Pneg>0) = 0;

            Wpos(ks,pp) = trapz(tlin(idf), Ppos(idf));
            Wneg(ks,pp) = trapz(tlin(idf), Pneg(idf));
            Wnet(ks,pp) = trapz(tlin(idf), Pmean(idf));
            
            Act(ks,pp) = mean(Amean);

            xlabel('Time (s)')
        end
    end
end


%% figure size
for i = 1:ks
    figure(i)
    
    set(gcf, 'units', 'normalized', 'position', [.2 .2 .3 .6], 'Name', files{i})
    
    
end



%% save figures
% cd('C:\Users\u0167448\Documents\GitHub\analyze-energetics-data\figures')
%
% for i = 1:kk
%     figure(i)
%
%     exportgraphics(gcf,['Fig', num2str(i), '.png'])
%
%
% end

%% analyze energetics
tstart = [0 (8:8:50) 53; 0 (7:8:50) 52];
tstop = tstart + 5;

if ishandle(200), close(200); end
color = lines(6);
Ps = [2 3];

tint = (1:1:(60*60))/60; % (s)

for j = 1:2
    cd(['C:\Users\u0167448\OneDrive - KU Leuven\10. Energetics\2302\P', num2str(j+1)])
    filename = ['P', num2str(j+1), '.xlsx'];
    
    time = readmatrix(filename,   "OutputType",  "datetime", "Range", 'J:J');
    tr = minute(time) + second(time)/60;
    
    VO2r = readmatrix(filename, "Range", 'O:O');
    RQr = readmatrix(filename, "Range", 'Q:Q');
    
    % get finite and unique values
    isf = isfinite(tr);
    tf = tr(isf);
    VO2f = VO2r(isf);
    RQf = RQr(isf);
    
    [~, isu] = unique(tf);
    t = tf(isu);
    VO2 = VO2f(isu);
    RQ = RQf(isu);
    
    % interpolate
    VO2i = interp1(t, VO2, tint);
    RQi = interp1(t, RQ, tint);
    
    figure(200)
    subplot(2,2,j)
    plot(tr, VO2r, 'color', [.8 .8 .8]); hold on
    plot(tint, VO2i,'--', 'color', color(1,:))
    title('VO2')
    
    subplot(2,2,j+2)
    plot(tr, RQr, 'color', [.8 .8 .8]); hold on
    plot(tint, RQi,'--', 'color', color(1,:))
    title('RQ')
    
    ks = [0 2];
    for k = 1:2
        subplot(2,2,j + ks(k))
        xline(tstop(j,:),'k--')
        xline(tstart(j,:),'r--')
        box off
    end
    
    for i = 1:length(tstop)
        if i == 1
            id = 5;
        else
            id = 2;
        end
        
        tid = tint > (tstop(j,i)-id) & tint < tstop(j,i);
        
        VO2m(j,i) = mean(VO2i(tid), 'omitnan');
        RQm(j,i) = mean(RQi(tid), 'omitnan');
        
        subplot(2,2,j)
        plot([min(tint(tid)) max(tint(tid))], ones(1,2) * VO2m(j,i), 'r:', 'linewidth', 2)
        
        subplot(2,2,j+2)
        plot([min(tint(tid)) max(tint(tid))], ones(1,2) * RQm(j,i), 'r:', 'linewidth', 2)
        
    end
    
    
end

%% calc metabolic energy expenditure
% Brockway
RQdata = [0.7145; 1];
joule_per_o2_data = [19.8071 21.0956] * 1e3;

% RER -> Joule per liter O2
joule_per_o2 = polyval(polyfit(RQdata, joule_per_o2_data, 1), RQm); % kcal per L
Pmet = (VO2m/1000 / 60) .* joule_per_o2; %

%% summary
if ishandle(100), close(100); end
figure(100)

order = [1:6; 6:-1:1];

vs = [50 100 150 200 -50 -100];

% net VO2
VO2n = VO2m(:,2:end-1) - VO2m(:,1);
Pmetn = Pmet(:,2:end-1) - Pmet(:,1);


for pp = 1:2
    subplot(4,2,pp)
    
    Pmech = [Wpos(:,pp) Wneg(:,pp) Wnet(:,pp)] ./ Tcycle(:,pp);
    emech = Pmech(:,3) ./ Pmetn(pp,order(pp,:))';
    
    bar(vs, Pmech);
    box off
    %     xlabel('Angular velocity condition (deg/s)')
    ylabel('Mechanical power (W)')
    legend('Positive', 'Negative', 'Net', 'location', 'best')
    
    title(['Participant ', num2str(pp)])
    subtitle('Mechanical power')
    
    subplot(4,2,pp+2)
    bar(vs, Act(:,pp));
    box off

    ylabel('Activation (%)')
    subtitle('Activation')

    
    subplot(4,2,pp+4)
    bar(vs, Pmetn(pp,order(pp,:)))
    box off
    %     xlabel('Angular velocity condition (deg/s)')
    ylabel('Metabolic power (W)')
    subtitle('Net metabolic power')
    
    subplot(4,2,pp+6)
    bar(vs, emech * 100)
    box off
    xlabel('Angular velocity condition (deg/s)')
    ylabel('Mechanical efficiency (%)')
    subtitle('Mechanical efficiency')
end



