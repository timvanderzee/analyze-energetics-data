close all; 
clear all

%% analyze energetics    
cd('C:\Users\u0167448\OneDrive - KU Leuven\10. Energetics\2004')
filename = 'P4.xlsx';

time = readmatrix(filename,   "OutputType",  "datetime", "Range", 'J:J');
VO2r = readmatrix(filename, "Range", 'O:O');
RQr = readmatrix(filename, "Range", 'Q:Q');

%%
Sdata(1).tstop = (12:8:70);
Sdata(1).tstop = [12 20 28 38:8:78];

session = 1;
colors = parula(5);
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
VO2_rest(session) = mean(VO2i(tint<5),  'omitnan');

VO2n = VO2a - VO2_rest(session);
RQ_rest(session) = RQa(mid);

figure(200)
nexttile
plot(tr, VO2r - VO2_rest(session), 'color', [.8 .8 .8]); hold on
plot(tint, VO2i - VO2_rest(session), 'color', [.5 .5 .5]); hold on
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