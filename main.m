clear all; close all; clc
addpath(genpath('C:\Users\u0167448\Documents\GitHub\analyze-energetics-data\analyze'))
addpath(genpath('C:\Users\u0167448\Documents\GitHub\analyze-energetics-data\process'))

Ps = 15;

%% gravity
get_gravity(Ps);

%% mvc
close all
get_MVC(Ps)

%% convert
convert_c3d_to_mat(Ps)

%% cycle data
close all
get_cycle_data(Ps)

%% get energetics
close all
Ps = [7:8, 10:21];
% Ps = 21;
get_energetics(Ps)

%% analyze - dataset 1
close all
Ps = [1:8, 10:15];
analyze_cycle_data(Ps, 1)

%% analyze - dataset 2
close all
Ps = 16:21;
analyze_cycle_data(Ps, 2)
 
 %% plot - dataset 1
if ishandle(1), close(1); end
if ishandle(2), close(2); end

% Ps = [7:8, 10:15];
Ps = [1:6];
[eff1a_uc, eff1a] = analyze_energetics(Ps);

Ps = [7:8, 10:15];
[eff1b_uc, eff1b] = analyze_energetics(Ps);

Ps = [1:8, 10:15];
[eff1_uc, eff1] = analyze_energetics(Ps);

%% plot - dataset 2
Ps = 16:21;
close all
figure(3)
eff2 = analyze_energetics_dataset2(Ps);

%% statistics

if ishandle(4), close(4); end
figure(4)



for kk = 1:2
    
    figure(4)
    subplot(1,2,kk)
    
    for mm = 1
    
    if kk == 1
        if mm == 1
            eff = eff1;
        elseif mm == 2
            eff = eff1a;
        else
            eff = eff1b;
        end
        id = [6:-1:4, 1:3];
        v = [-240 -120 -60 0 60 120 240];
        
        y = eff(id,:,:);
        Y = [y(1:3,:,:); zeros(1, size(y,2), 3); y(4:6,:,:)];
        
    else
        eff = eff2;
        
        % reorder so that velocity is increasing
        id = [8:-1:5, 1:4];
        v = [-240 -120 -60 -30 0 30 60 120 240];

        y = eff(id,:,:);
        Y = [y(1:4,:,:); zeros(1, size(y,2), 3); y(5:8,:,:)];
    end


    color = lines(3);


    for i = 1
        errorbar(v, mean(Y(:,:,i),2, 'omitnan'), std(Y(:,:,i),1,2, 'omitnan'), '--o', 'color', color(mm,:), ...
            'markerfacecolor', color(mm,:)); hold on
    end
    
    grid on
    box off
    xlabel('Velocity (deg/s)')
    ylabel('Efficiency (%)')

    for j = 1 %:size(y,3)
        for i = 1:(size(Y,1)-1)
            [h(i,j), p(i,j)] = ttest(Y(i,:,j), Y(i+1,:,j));


        if h(i,j)
            plot([v(i) v(i+1)], [mean(Y(i,:,j),2) mean(Y(i+1,:,j),2)], 'k-')
        end
        end
    end

    icon = v > 0;
    iecc = v < 0;
    Ycon = mean(Y(icon,:,1),2,'omitnan');
    Yecc = mean(Y(iecc,:,1),2,'omitnan');
    
    figure(200)
%     subplot(1,2,kk);
    plot(v(icon), Yecc./Ycon); hold on
end
end


