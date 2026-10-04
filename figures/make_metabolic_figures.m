function[rat] = make_metabolic_figures(V, Y, type, Ps, Pi)

% take shortening as positive
vm = -V;

for ii = 1:2
    
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
    
    
    %% plot 1
    % j = 1;
    % i = 1;
    kk = type;
    
    color = lines(10);
    
    % subplot(131)
    T(ii,1) = nexttile;

    
    for i = 1:size(y,2)
        if Ps(i) == Pi
            lw = 2;
        else
            lw = 0.5;
        end
        
        plot(v, y(:,i), '.-', 'color', color(i,:), 'linewidth', lw); hold on
    end
    
    
    
    h = nan(9,2);
    p = nan(9,2);
    
    for i = 1:(size(y,1)-1)
        [h(i,kk), p(i,kk)] = ttest(y(i,:), y(i+1,:));
        
        
        if h(i,kk)
            plot([v(i) v(i+1)], [mean(y(i,:),2) mean(y(i+1,:),2)], 'k-', 'linewidth', 2)
        end
    end

    errorbar(v, mean(y,2, 'omitnan'), std(y,1,2, 'omitnan'), '--o', 'color', color(type,:), ...
    'markerfacecolor', color(type,:), 'linewidth', 1); hold on
    
    %% plot 2: difference
    icon = v > 0;
    iecc = v < 0;
    
    Ycon = y(icon,:,1);
    Yecc = flip(y(iecc,:,1));
    diff = [zeros(1,size(Yecc,2)); Ycon - Yecc];
    
    vnew = [0 v(icon)];
    
    T(ii,2) = nexttile;

    
    for i = 1:size(y,2)
        if Ps(i) == Pi
            lw = 2;
        else
            lw = 0.5;
        end
        
        plot(vnew, diff(:,i), '.-', 'color', color(i,:), 'linewidth', lw); hold on
    end
    
    for i = 1:(size(diff,1)-1)
        [h2(i,kk), p2(i,kk)] = ttest(diff(i,:),diff(i+1,:));
        
        
        if h2(i,kk)
            plot([vnew(i) vnew(i+1)], [mean(diff(i,:),2) mean(diff(i+1,:),2)], 'k-', 'linewidth', 2)
        end
    end
    
        errorbar(vnew, mean(diff,2,'omitnan'), std(diff,1,2,'omitnan'), '--o', 'color', color(type,:), ...
        'markerfacecolor', color(type,:), 'linewidth', 1); hold on
    
%     ylim([0 2])
    
    %% plot 3: ratio
    icon = v > 0;
    iecc = v < 0;
    
    Ycon = y(icon,:,1);
    Yecc = flip(y(iecc,:,1));
    rat = [ones(1,size(Yecc,2)); Ycon./Yecc];
    
    vnew = [0 v(icon)];
    
    T(ii,3) = nexttile;

    
    for i = 1:size(y,2)
        if Ps(i) == Pi
            lw = 2;
        else
            lw = 0.5;
        end
        
        plot(vnew, rat(:,i), '.-', 'color', color(i,:), 'linewidth', lw); hold on
    end
    
    for i = 1:(size(rat,1)-1)
        [h2(i,kk), p2(i,kk)] = ttest(rat(i,:),rat(i+1,:));
        
        
        if h2(i,kk)
            plot([vnew(i) vnew(i+1)], [mean(rat(i,:),2) mean(rat(i+1,:),2)], 'k-', 'linewidth', 2)
        end
    end
    
    errorbar(vnew, mean(rat,2,'omitnan'), std(rat,1,2,'omitnan'), '--o', 'color', color(type,:), ...
    'markerfacecolor', color(type,:), 'linewidth', 1); hold on
    ylim([0 2])
    
    %% plot 4
    T(ii,4) = nexttile;
    
    isf = find(isfinite(vm(1,:)),1);
    [~, sid] = sort(vm(:,isf));
    

    
    for i = 1:size(y,2)
        if Ps(i) == Pi
            lw = 2;
        else
            lw = 0.5;
        end
        plot(-vm(sid,i), y(:,i), '.-', 'color', color(i,:), 'linewidth', lw); hold on
    end
    
        errorbar(mean(vm(sid,:),2, 'omitnan'), mean(y(:,:),2, 'omitnan'),std(y(:,:),1,2, 'omitnan'), std(y(:,:),1,2, 'omitnan'), ...
        std(vm(sid,:),1,2, 'omitnan'), std(vm(sid,:),1,2, 'omitnan'), ...
        '--o', 'color', color(type,:), 'markerfacecolor', color(type,:), 'linewidth', 1); hold on
    
end

%% make nice
titles = {'Activation', 'Metabolic rate'};
subtitles = {'Versus joint velocity',  'Difference', 'Ratio', 'Versus muscle velocity'};
xlabs = {'Velocity (deg/s)', 'Velocity (deg/s)', 'Velocity (deg/s)', 'Velocity (mm/s)'};
ylabs = {'Activation (-)', 'Difference', 'Ratio', 'Activation (-)'; 'Metabolic rate (W/kg)', 'Difference', 'Ratio', 'Metabolic rate (W/kg)'};

% make nice
for ii = 1:2
    for i = 1:4
        set(T(ii,i), 'box', 'off')
        T(ii,i).Title.String = titles{ii};
        T(ii,i).YLabel.String = ylabs{ii,i};
        T(ii,i).Subtitle.String = subtitles{i};
        T(ii,i).XLabel.String = xlabs{ii};
    end
end

end
% end