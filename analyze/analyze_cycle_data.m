clear all; close all; clc
% profile on
conds = {'c60','c120','c240', 'e60','e120','e240', 'ISOM_EXT', 'ISOM_FLEX', 'STR-SHOR'};

load('MVC.mat', 'Tknee')

% Ps = [1:8, 10:15];
Ps = [7,8,10:15];
colors = hot(max(Ps));
mcolor = lines(1);

% Ps = 1;
ymaxs = [50    50    50    50    50    50    50    50    50    50    50    70   300   100];

cd('C:\Users\u0167448\OneDrive - KU Leuven\10. Energetics\dataset')
load('cycle_data.mat', 'tlin', 'Data_active', 'labs', 'units','ymins', 'Tcycle')

% Data is samples X conditions X participants X variables

%% exclude some data
Data_active(:,:,2:6,9) = nan; % GL quality bad
Data_active(:,:,[7 10],11) = nan; % TA quality bad
Data_active(:,:,11,8) = nan; % SM quality bad

%% correct torque wrt max
% Data_active(:,:,:,end) = Data_active(:,:,:,end) ./ reshape(max(Tknee,[],2),1,1,15) * 100;
% units{14} = ' (%)';
ymins(14) = -5;

%% compute time vector
% compute mean tlin from mean Tcycle
Tcycle(Tcycle == 0) = nan;
mTcycle = mean(Tcycle,2, 'omitnan');

tlins = nan(9, size(Data_active,1));
for k = 1:9
    tlins(k,:) = linspace(0,mTcycle(k), size(Data_active,1));
end


%% optional: simplify
temp(:,:,:,1) = mean(Data_active(:,:,:,1:3), 4, 'omitnan'); % agonist
temp(:,:,:,2) = mean(Data_active(:,:,:,4:11), 4, 'omitnan'); % antagonist
temp(:,:,:,3:5) = Data_active(:,:,:,12:14);

Data_active = temp;
labs = {'Agonist', 'Antagonist', labs{end-2:end}};
units = {' (%)', ' (%)', units{end-2:end}};
ymins = [-5 -5 ymins(end-2:end)];
ymaxs = [50 50 ymaxs(end-2:end)];

%% calculate power
Data_active(:,:,:,end+1) = Data_active(:,:,:,end) .* Data_active(:,:,:,end-1) * pi/180;

labs{end+1} = 'Power';
units{end+1} = ' (W)';
ymins(end+1) = -400;
ymaxs(end+1) = 200;

%% resync the isometric
for k = 7:8
    for P = Ps
        
        [~, ids] = max(diff(movmean(Data_active(:,k,P,end-1),100)));
        
        for i = 1:size(Data_active,4) % variables
            
%             Data_passive(:,k,P,i) = [Data_passive((ids):end,k,P,i); Data_passive(1:(ids-1),k,P,i)];
            Data_active(:,k,P,i) = [Data_active((ids):end,k,P,i); Data_active(1:(ids-1),k,P,i)];
        end
    end
end


%% compute the phases
tcon = zeros(size(Data_active,2),2);
tecc = zeros(size(Data_active,2),2);

for k = 1:size(Data_active,2) % conditions
        
    % find the phases
    if ~strcmp(conds{k}(1), 'I')
        tcon(k,:) = [find(Data_active(20:end,k,1,end-2) > 20, 1, 'first')+20 find(Data_active(:,k,1,end-2) > 20, 1, 'last')];
        tecc(k,:) = [find(Data_active(20:end,k,1,end-2) < -20, 1, 'first')+20 find(Data_active(:,k,1,end-2) < -20, 1, 'last')];
        
        if tcon(k,2) < tcon(k,1)
            tcon(k,2) = size(Data_active,1);
        end
        
        if tecc(k,2) < tecc(k,1)
            tecc(k,2) = size(Data_active,1);
        end
    end
end

%% plot!
for k = 1:size(Data_active,2) % conditions
    figure(k)
    set(gcf, 'Name', conds{k});
    
    for i = 1:size(Data_active,4) % variables
        
        nexttile
        if ~strcmp(conds{k}(1), 'I')
            h = patch(tlins(k,[tcon(k,:) flip(tcon(k,:))]), 10*[-100 -100 100 100], [.7 .7 .7], 'linestyle', 'none'); hold on
            patch(tlins(k,[tecc(k,:) flip(tecc(k,:))]), 10*[-100 -100 100 100], [.3 .3 .3], 'linestyle', 'none'); hold on
        end
        
%         for P = Ps
%             plot(tlins(k,:), Data_active(:,k,P,i),'color', colors(P,:), 'linewidth', 1); hold on
%         end
        
               
        patch([tlins(k,:) flip(tlins(k,:))]', [mean(Data_active(:,k,Ps,i), 3, 'omitnan') + std(Data_active(:,k,Ps,i), 1, 3, 'omitnan'); ...
            flip(mean(Data_active(:,k,Ps,i), 3, 'omitnan')-std(Data_active(:,k,Ps,i), 1, 3, 'omitnan'))], mcolor + [.7 .5 .25], 'linestyle', 'none'); hold on
        
        plot(tlins(k,:), mean(Data_active(:,k,Ps,i), 3, 'omitnan'), '-','color', mcolor, 'linewidth', 2); hold on
        
        title(labs{i})
        ylabel([labs{i}, units{i}])
        yline(0,'k--')
        box off
        
        ylim([ymins(i) ymaxs(i)])
        
        xlim([0 mTcycle(k)])
        
    end
end

% profile viewer
return

%% activation time integral
act = Data_active(:,:,:,1);

tstart =  min([tcon(:,1) tecc(:,1)],[],2);
tstop =  1000 * ones(size(tstart));

tstart(7:8) = 1;
tstop(7:8) = 1;

Iact = nan(max(Ps),9);
for k = 1:9

    if k < 7 || k == 9

        % remove contraction part
        act(tstart(k):tstop(k),k,:) = 0;
    end
    
    for P = Ps
        Iact(P,k) = trapz(tlins(k,:), act(:,k,P));
        
        figure(100)
        subplot(3,3,k)
        plot(tlins(k,:), act(:,k,P)); hold on
    end
end
        
% for P = Ps
        
%% calculate activation
% A = nan(9,11,5);
% 
% 
% for P = Ps
%     for k = 1:9
%         
%         % entire cycle
%         A(k,P,1) = mean(Data_active(:,k,P,1:3), 'all');
%         
%         % only isometric portion
%         A(k,P,2) = mean(Data_active(1:tstart(k),k,P,1:3), 'all');
%         
%         % only contraction portion
%         A(k,P,3) = mean(Data_active(tstart(k):tstop(k),k,P,1:3), 'all');
%         
%         % only relaxed portion
%         A(k,P,4) = mean(Data_active(tstop(k):end,k,P,1:3), 'all');
%         
%         % non contraction
%         A(k,P,5) = mean([Data_active(1:tstart(k),k,P,1:3); Data_active(tstop(k):end,k,P,1:3)], 'all');
%     end
% end
% 
% figure(10)
% 
% titles = {'Total', 'Isometric', 'Contraction', 'Relaxation', 'Non contraction'};
% for i = 1:5
%     subplot(5,1,i)
%     bar(A(:,:,i)')
%     title(titles{i})
% end

%% calculate work
W = nan(9,max(Ps),3);

% Wpos = nan(9,11);
% Wneg = nan(9,11);

for P = Ps
    for k = 1:9
        
        Pnet = Data_active(:,k,P,end);
        
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

% bar(reordercats(categorical(conds), conds), mean(A,2,'omitnan'))

%% save
cd('C:\Users\u0167448\Documents\GitHub\analyze-energetics-data\data')
save('mechanics.mat', 'W', 'conds', 'Ts', 'Tl', 'mTcycle', 'Iact')