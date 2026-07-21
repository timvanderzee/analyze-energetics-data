clear all; close all; clc

conds = {'c60','c120','c240', 'e60','e120','e240', 'ISOM_EXT', 'ISOM_FLEX', 'STR-SHOR'};

% load('gravity.mat', 'As')

Ps = [1:8, 10:15];
colors = parula(max(Ps));

% Ps = 1;
ymaxs = [50    50    50    50    50    50    50    50    50    50    50    70   300   100];

cd('C:\Users\u0167448\OneDrive - KU Leuven\10. Energetics\dataset')
load('cycle_data.mat', 'tlin', 'Data_active', 'Data_passive', 'labs', 'units','ymins', 'Tcycle')

% compute mean tlin from mean Tcycle
Tcycle(Tcycle == 0) = nan;
mTcycle = mean(Tcycle,2, 'omitnan');

tlins = nan(9, 2000);
for k = 1:9
   tlins(k,:) = linspace(0,mTcycle(k), 2000);
end
        
        % correct gravity
% for P = Ps
%     Data_active(:,:,P,end) = Data_active(:,:,P,end) - (As(P,1)*cosd(Data_active(:,:,P,12)-As(P,2)) + As(P,3));
%     Data_passive(:,:,P,end) = Data_passive(:,:,P,end) - (As(P,1)*cosd(Data_passive(:,:,P,12)-As(P,2)) + As(P,3));
% end

% Data_active(:,:,:,end) = Data_active(:,:,:,end) - Data_passive(:,:,:,end);

% compute acceleration
fs = 1/mean(diff(tlin));
[b,a] = butter(2, 50/(.5*fs), 'low');

for P = Ps
    for k = 1:size(Data_active,2)
        vel_filt_active = filtfilt(b,a,Data_active(:,k,P,13));
        vel_filt_passive = filtfilt(b,a,Data_active(:,k,P,13));
        
        Data_active(:,k,P,15) = -grad5(vel_filt_active, mean(diff(tlin)));
        Data_passive(:,k,P,15) = -grad5(vel_filt_passive, mean(diff(tlin)));
    end
end

%% correct for inertia
close all

td = 0;
tds = zeros(11,9);
I = zeros(length(Ps), 9);

func = @(a, x) a*x;
fcost = @(a,x,y) sum((y - func(a,x)).^2, 'omitnan');


for P = Ps
    for k = [(1:6), 9]
        
        % signals
        acc = Data_passive(:,k,P,15);
        trq = Data_passive(:,k,P,14);
        
        [X, lags]= xcorr(acc, trq*100);
        [~, maxid] = max(X);
        tds(P,k) = lags(maxid) / fs;
        
        %     figure(101)
        %     plot(lags, X); hold on
        
        % shifted
        acc_shift = interp1(tlin-tds(P), acc, tlin);
        
        
        % find inertia
        I(P,k) = fminsearch(@(a) fcost(a, acc_shift(:), trq(:)), 1/100);
        
        %     figure(100)
        %     nexttile
        %     plot(tlin, trq); hold on
        %     plot(tlin, func(I(P,k), acc_shift));
        %
        % active
        %     acc = Data_active(:,k,P,15);
        %     trq = Data_active(:,k,P,14);
        
        %     acc_shift = interp1(tlin-tds(P), acc, tlin)';
        
        %     figure(102)
        %     nexttile
        %     plot(tlin, trq); hold on
        %
        %     plot(tlin, func(I(P,k),acc_shift(:)));
        %     plot(tlin, trq - func(I(P,k),acc_shift(:)));
        
        % correct
        Data_passive(:,k,P,15) = interp1(tlin-tds(P,k), Data_passive(:,k,P,15), tlin)';
        Data_active(:,k,P,15) = interp1(tlin-tds(P,k), Data_active(:,k,P,15), tlin)';
    end
    
    % subtract inertia from torque
    Data_passive(:,:,P,14) = Data_passive(:,:,P,14) - func(I(P,k),Data_passive(:,:,P,15));
    Data_active(:,:,P,14) = Data_active(:,:,P,14) - func(I(P,k),Data_active(:,:,P,15));
    
    % calculate power
    Data_passive(:,:,P,16) = Data_passive(:,:,P,14) .* Data_passive(:,:,P,13) * pi/180;
    Data_active(:,:,P,16) = Data_active(:,:,P,14) .* Data_active(:,:,P,13) * pi/180;
    
    
end

% resync the isometric
for k = 7:8
    for P = Ps
        
        [~, ids] = max(diff(movmean(Data_active(:,k,P,14),100)));
        
        for i = 1:size(Data_active,4) % variables
            
            Data_passive(:,k,P,i) = [Data_passive((ids):end,k,P,i); Data_passive(1:(ids-1),k,P,i)];
            Data_active(:,k,P,i) = [Data_active((ids):end,k,P,i); Data_active(1:(ids-1),k,P,i)];
        end
    end
end

%% plot!
labs{end+1} = 'Acc.';
units{end+1} = ' (Deg/s^2)';
ymins(end+1) = -1e4;
ymaxs(end+1) = 1e4;

labs{end+1} = 'Power';
units{end+1} = ' (W)';
ymins(end+1) = -400;
ymaxs(end+1) = 200;

for k = 1:size(Data_active,2) % conditions
    
    figure(k)
    
%     set(gcf, 'WindowState', 'maximized', 'Name', conds{k});
    set(gcf, 'Name', conds{k});
    
    % find the phases
    if ~strcmp(conds{k}(1), 'I')
        tcon(k,:) = [find(Data_active(20:end,k,1,13) > 20, 1, 'first')+20 find(Data_active(:,k,1,13) > 20, 1, 'last')];
        tecc(k,:) = [find(Data_active(20:end,k,1,13) < -20, 1, 'first')+20 find(Data_active(:,k,1,13) < -20, 1, 'last')];
        
        if tcon(k,2) < tcon(k,1)
            tcon(k,2) = size(Data_active,1);
        end
        
        if tecc(k,2) < tecc(k,1)
            tecc(k,2) = size(Data_active,1);
        end
    end
    
    for i = 1:size(Data_active,4) % variables
               
        nexttile
    if ~strcmp(conds{k}(1), 'I')
        h = patch(tlins(k,[tcon(k,:) flip(tcon(k,:))]), 10*[-100 -100 100 100], [1 .9 .9], 'linestyle', 'none'); hold on
        patch(tlins(k,[tecc(k,:) flip(tecc(k,:))]), 10*[-100 -100 100 100], [.9 1 .9], 'linestyle', 'none'); hold on
    end
    
        for P = Ps
          
            plot(tlins(k,:), Data_active(:,k,P,i),'color', colors(P,:), 'linewidth', 1); hold on
            %             plot(tlin, Data_passive(:,k,P,i),'--','color', colors(P,:), 'linewidth', 1.5); hold on
            
        end
        
        plot(tlins(k,:), mean(Data_active(:,k,:,i), 3, 'omitnan'), 'k-', 'linewidth', 2);
        plot(tlins(k,:), mean(Data_active(:,k,:,i), 3, 'omitnan') + [std(Data_active(:,k,:,i), 1, 3, 'omitnan') ...
            -std(Data_active(:,k,:,i), 1, 3, 'omitnan')], 'k-', 'linewidth', 1);

        title(labs{i})
        ylabel([labs{i}, units{i}])
        yline(0,'k--')
        box off
        
        ylim([ymins(i) ymaxs(i)])
        
        xlim([0 Tcycle(k,P)])
        
    end
end


%% calculate activation
A = nan(9,11,4);

tstart =  min([tcon(:,1) tecc(:,1)],[],2);
tstop =  1000 * ones(size(tstart));

tstart(7:8) = 1;
tstop(7:8) = 1000;

for P = Ps
    for k = 1:9
        
        % entire cycle
        A(k,P,1) = mean(Data_active(:,k,P,1:3), 'all');
        
        % only isometric portion
        A(k,P,2) = mean(Data_active(1:tstart(k),k,P,1:3), 'all');
        
        % only contraction portion
        A(k,P,3) = mean(Data_active(tstart(k):tstop(k),k,P,1:3), 'all');
        
        % only relaxed portion
        A(k,P,4) = mean(Data_active(tstop(k):end,k,P,1:3), 'all');
    end
end

figure(10)

titles = {'Total', 'Isometric', 'Contraction', 'Relaxation'};
for i = 1:4
    subplot(4,1,i)
    bar(A(:,:,i)')
    title(titles{i})
end

%% calculate work
W = nan(9,11,3);

% Wpos = nan(9,11);
% Wneg = nan(9,11);

for P = Ps
    for k = 1:9
        
        Pnet = Data_active(:,k,P,16);
        
        isf = isfinite(Pnet);
        
        Ppos = Pnet;
        Pneg = Pnet;
        
        Ppos(Ppos<0) = 0;
        Pneg(Pneg>0) = 0;
        
        W(k,P,1) = trapz(tlins(k,isf), Pnet(isf));
        W(k,P,2) = trapz(tlins(k,isf), Ppos(isf));
        W(k,P,3) = trapz(tlins(k,isf), Pneg(isf));
        
    end
end

%% calculate time shortening and lengthening
for k = 1:9
    if tcon(k,2) > 0
        Ts(k) = tlins(k,tcon(k,2)) - tlins(k,tcon(k,1));
        Tl(k) = tlins(k,tecc(k,2)) - tlins(k,tecc(k,1));
    end
end

%%
if ishandle(100), close(100); end
figure(100)

for P = Ps
    nexttile
    bar(reordercats(categorical(conds), conds), squeeze(W(:,P,:)))
    box off
    title(num2str(P))
end

%%
if ishandle(101), close(101); end
figure(101)

bar(reordercats(categorical(conds), conds), mean(A,2,'omitnan'))

%% save
cd('C:\Users\u0167448\Documents\GitHub\analyze-energetics-data')
save('mechanics.mat', 'W', 'conds', 'Ts', 'Tl', 'mTcycle', 'A')