clear all; close all; clc
addpath(genpath(cd))

datafolder = 'C:\Users\u0167448\OneDrive - KU Leuven\10. Energetics\dataset';


colors = lines(8);

Ps = 1:15;

conds = {'MVC_QCEPS_L', 'c60','c120','c240', 'e60','e120','e240', 'ISOM_EXT', 'ISOM_FLEX', 'STR-SHOR'};

for i = Ps
    Sdata(i).tstop = 10:10:90;
end

% exceptions
Sdata(1).tstop = [10 21:10:91];
Sdata(2).tstop = [10 26:10:96];
Sdata(3).tstop = [11 25:10:95];
Sdata(4).tstop = (11:10:91);
Sdata(5).tstop = [(11:10:81), 92];
Sdata(8).tstop = [10, 30, 43:10:103]; % made up, need to verify

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
Sdata(12).order = [5 7 8 3 6 1 2 4 9];
Sdata(13).order = [5 8 3 9 2 7 6 1 4];
Sdata(14).order = [9 2 1 6 8 3 7 4 5];
Sdata(15).order = [7 4 9 5 1 3 2 6 8];

% pre-allocate
N = 9;
M = length(Ps);


Pmetn   = nan(M,N);
VO2_rest = nan(M,1);
RQ_rest = nan(M,1);


for P = Ps

    
    %% analyze energetics    
    foldername = [datafolder, '\P', num2str(P)];
    
    if isfolder(foldername)
    cd(foldername)
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
    
    figure(P)
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
end

%% summary graphs
if ishandle(300), close(300); end

vels = [60 120 240 -60 -120 -240 -5 5 0];

for P = Ps
order = Sdata(P).order;

Pmet(P,:) = Pmetn(P, order);
end


N = length(order);

Sm = mean(Pmet,2);

Pmetc = Pmet - Sm + mean(Sm, 'omitnan');

figure(300)   
nexttile
errorbar(1:9, mean(Pmetc, 'omitnan'), std(Pmetc, 'omitnan')); hold on

xticklabels(conds);
ylabel('Metabolic rate (W)')
box off

xlabel('Angular velocity condition (deg/s)') 


%% save
cd('C:\Users\u0167448\Documents\GitHub\analyze-energetics-data')
% save('metabolics.mat', 'Pmet', 'Sdata')