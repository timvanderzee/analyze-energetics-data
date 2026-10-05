function[rat, h, p] = make_metabolic_figures(V, Y, type, Ps, Pi)

% take shortening as positive
vm = -V;
    
h = nan(9,size(Y,3),3);
p = nan(9,size(Y,3),3);

for ii = 1:size(Y,3)
    
    % reorder so that velocity is increasing
    if type == 1
        
        id = [6:-1:4, 1:3];
        v = [-240 -120 -60 60 120 240];
        
        y = Y(id,:,ii);
        %     Y = [y(1:6,:); zeros(1, size(y,2)); y(4:6,:)];
        
    else
        id = [8:-1:5, 1:4];
        v = [-240 -120 -60 -30 30 60 120 240];
        
        y = Y(id,:,ii);
        %     Y = [y(1:4,:); zeros(1, size(y,2)); y(5:8,:)];
    end
    
    
%     %% plot 1
    % j = 1;
    % i = 1;
    kk = 4;
%     
    color = lines(10);
%     
%     
    %% plot 1: difference
% 
%     figure(1)
%     icon = v > 0;
%     iecc = v < 0;
%     
%     Ycon = y(icon,:,1);
%     Yecc = flip(y(iecc,:,1));
%     diff = abs(Yecc) - abs(Ycon);
%     
%     vnew = [0 v(icon)];
%     
%     T(ii,1) = subplot(2,4,ii);
% 
%      bar(1:4, mean(diff,2,'omitnan'), 'facecolor', color(kk,:)); hold on
%      errorbar(1:4, mean(diff,2,'omitnan'), std(diff,1,2,'omitnan'), '.', 'color', color(kk,:), ...
%     'markerfacecolor', color(kk,:), 'linewidth', 1); hold on
% 
%     for i = 1:size(y,2)
%         if Ps(i) == Pi
%             lw = 2;
%         else
%             lw = 0.5;
%         end
%         
%         plot(1:4, diff(:,i), '.-', 'color', [.8 .8 .8], 'linewidth', lw)
%     end
%     
%     
%     for i = 1:size(Ycon,1)
%         [h(i,ii,2), p(i,ii,2)] = ttest(diff(i,:));
%         
%         
% %         if h(i,ii,2)
% %             plot(1:5(i+1), mean(diff(i+1,:),2), 'ko', 'linewidth', 2)
% %         end
%     end
%     
% 
%     
% %     ylim([0 2])
    
    %% plot 2: ratio
%     figure(2)
    icon = v > 0;
    iecc = v < 0;
    
    Ycon = y(icon,:,1);
    Yecc = flip(y(iecc,:,1));
    rat = abs(Yecc)./abs(Ycon);
    
    vnew = [0 v(icon)];
    
    T(ii,2) = subplot(1,4,ii);

    


   bar(1:4, mean(rat,2,'omitnan'), 'facecolor', color(kk,:)); hold on
        errorbar(1:4, mean(rat,2,'omitnan'), std(rat,1,2,'omitnan'), '.', 'color', color(kk,:), ...
    'markerfacecolor', color(kk,:), 'linewidth', 1); hold on
    ylim([0 6])
  
    for i = 1:size(y,2)
    if Ps(i) == Pi
        lw = 2;
    else
        lw = 0.5;
    end

    plot(1:4, rat(:,i), '.-', 'color', [.8 .8 .8], 'linewidth', lw); hold on
  end

    for i = 1:size(rat,1)
        [h(i,ii,3), p(i,ii,3)] = ttest(rat(i,:)-1);
        
%         
%         if h(i,ii,3)
%             plot(vnew(i+1), mean(rat(i+1,:),2), 'ko', 'linewidth', 2)
%         end
    end
    

    
end

%% make nice
% titles = {'Activation', 'Metabolic rate', 'Mechanical work', 'Efficiency'};
titles = {'Quadriceps activation', 'Metabolic energy cost', 'Absolute net work', 'Absolute efficiency'};
% subtitles = {'Versus joint velocity',  'Difference', 'Ratio', 'Versus muscle velocity'};
% xlabs = {'Velocity (deg/s)', 'Velocity (deg/s)', 'Velocity (deg/s)', 'Velocity (mm/s)'};
subtitles = {'Eccentric - concentric', 'Eccentric / concentric'};
ylabs = {'\Delta Activation (%)', '\Delta Metabolic rate (W)', '\Delta |Net joint power| (W)', '\Delta |Efficiency| (%)'; 
    'Activation ratio', 'Metabolic rate ratio', '|Net joint power| ratio', '|Efficiency| ratio'; };
vels = [30 60 120 240];
% type = {'difference', 'ratio'};

% make nice
for ii = 1:size(Y,3)
    for i = 2
        set(T(ii,i), 'box', 'off')
        if i == 2
            T(ii,i).Title.String = titles{ii};
        end
        
        T(ii,i).YLabel.String = ylabs{i,ii};
        T(ii,i).Subtitle.String = subtitles{i};
        T(ii,i).XLabel.String = 'Velocity (deg/s)';
        T(ii,i).XTick = 1:4;
        T(ii,i).XTickLabel = vels;
        T(ii,i).XLim = [.5 4.5];
        
    end
end

end
% end