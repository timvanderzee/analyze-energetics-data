function[] = make_masterthesis_figures(eff1, eff2)

% 1 = first protocol, 2 = second protocol
p = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2];

% 1 = vrouw, 2 = man
g = [1 2 1 2 1 2 2 2 2 1 2 1 1 2 1 2 1 1 2 2 1 1];
    
% 1 = duur, 2 = normal, 3 = kracht
s = [3 2 3 3 2 3 1 3 3 1 2 1 2 2 1 2 3 2 3 1 1 3];
color = lines(5);

speeds = {'60 deg/s', '120 deg/s', '240 deg/s'};
types = {'protocol 1', 'protocol 2'};
sports = {'duur', 'normal', 'kracht'};
genders = {'vrouw', 'man'};

%% effect of gender
if ishandle(10), close(10); end
figure(10)
clear N
for v = 1:3
    eff = [eff1(v,:,1) eff2(v,:,1)];
    for pi = 1:2
        nexttile

        for gi = 1:2

            bar(gi, mean(eff(p==pi & g == gi),'omitnan'), 'facecolor', color(gi,:)); hold on
            N(gi,pi) = sum(isfinite(eff(p==pi & g == gi)));
            errorbar(gi, mean(eff(p==pi & g == gi),'omitnan'), std(eff(p==pi & g == gi),'omitnan'), 'color', color(gi,:)); hold on
        end

        box off
        xticks([1 2])
        xticklabels(genders)
        title(speeds{v})
        subtitle(types{pi})
        ylabel('\epsilon (%)')
        ylim([0 25])
    end
end

%% effect of sport
speeds = {'30 deg/s', '60 deg/s', '120 deg/s', '240 deg/s'};

if ishandle(11), close(11); end
figure(11)

vis = [1 1 2 3; 1 2 3 4];

clear N
for v = 1:4
    eff = [eff1(vis(1,v),:,1) eff2(vis(2,v),:,1)];
%     eff(1:6) = nan;

    for pi = 1:2
        nexttile

        for si = 1:3

            bar(si, mean(eff(p==pi & s == si),'omitnan'), 'facecolor', color(si,:)); hold on
            N(si,pi) = sum(isfinite(eff(p==pi & s == si)));
            errorbar(si, mean(eff(p==pi & s == si),'omitnan'), std(eff(p==pi & s == si),'omitnan'), 'color', color(si,:)); hold on
            
            text(si, 2, ['N = ', num2str(N(si,pi))], 'HorizontalAlignment', 'Center', 'Fontsize', 6, 'Fontweight', 'bold', 'color', [1 1 1])
        end

        box off
        xticks([1 2 3])
        xticklabels(sports)
        title(speeds{v})
        subtitle(types{pi})
        ylabel('\epsilon (%)')
        ylim([0 25])

    end
end

%

