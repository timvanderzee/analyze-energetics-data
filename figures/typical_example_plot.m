function[] = typical_example_plot(Ps)


cd('C:\Users\u0167448\OneDrive - KU Leuven\10. Energetics\dataset')
load('cycle_data.mat', 'tlin', 'Data_active', 'labs', 'units','ymins', 'Tcycle')

ids = [1 13:15];
colors = lines(2);
ls = {'-', '-.'};

ks = [1:4; 5:8];

labs{1} = 'Activation';

for jj = 1:2
    
    for k = 1:size(ks,2)
        
        figure(k)
        
        for i = 1:length(ids)
            
            subplot(4,1,i)
            
            j = ids(i);
            
            plot(tlin, Data_active(:,ks(jj,k), Ps, j), '-', 'linewidth', 2, 'color', colors(jj,:), 'linestyle', ls{jj}); hold on
            
            title(labs{j})
            ylabel([labs{j}, units{j}])
%             yline(0,'k--')
            box off

            xlim([0 Tcycle(ks(jj,k),Ps)])
        end
    end
    
end

