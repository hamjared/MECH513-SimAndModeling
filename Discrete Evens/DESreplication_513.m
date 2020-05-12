clear
close all
format compact

n_replications = 20; % how many replications do you want to do 
for replication = 1:n_replications
    
    random_seed = replication; % replace this with a constant to get repeatable results
    sim('QueuingStrategies_513.slx') % run the simulation
    % divide the output into batches
    l_time = length(output);
    batch_output(1,1:3) = mean(output(floor(l_time*.5):floor(l_time*.6),:));
    batch_output(2,1:3) = mean(output(floor(l_time*.6):floor(l_time*.7),:));
    batch_output(3,1:3) = mean(output(floor(l_time*.7):floor(l_time*.8),:));
    batch_output(4,1:3) = mean(output(floor(l_time*.8):floor(l_time*.9),:));
    batch_output(5,1:3) = mean(output(floor(l_time*.9):floor(l_time*1),:));
    
    repl_batch{replication}(:,:) = batch_output;
end

% compose vector that allows for comparison of each queue type  
% across batches
for comparison = 1:3
batch_1 = [];
batch_2 = [];
batch_3 = [];
batch_4 = [];
batch_5 = [];

for replication = 1:10
    batch_1 = [batch_1 repl_batch{replication}(1,comparison)];
    batch_2 = [batch_2 repl_batch{replication}(2,comparison)];
    batch_3 = [batch_3 repl_batch{replication}(3,comparison)];
    batch_4 = [batch_4 repl_batch{replication}(4,comparison)];
    batch_5 = [batch_5 repl_batch{replication}(5,comparison)];  
end
% average the replications to get a single value for each batch, and each
% comparison
Queue_batchavg(:,comparison) = mean([batch_1 ;batch_2; batch_3; batch_4; batch_5],2);
end

% do the MATLAB anova, significant differences are demonstrable when F > 1
Y = [Queue_batchavg(:,1); Queue_batchavg(:,2); Queue_batchavg(:,3)]
Cat = [ones(size(Queue_batchavg(:,1))); 2*ones(size(Queue_batchavg(:,1))) ; 3*ones(size(Queue_batchavg(:,1)))]
Batch_num = [[1:5] [1:5] [1:5]]'
[p,t,stats] = anovan(Y,{Cat Batch_num},'varnames',strvcat('QueueType', 'Batches'))
multcompare(stats)



     
     