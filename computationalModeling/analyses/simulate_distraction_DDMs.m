%% Drift-diffusion simulations analyses for my Distraction & Decision Making paper
% Author: Matthew D. Bachman
% To make this script you are reccomend to have the corresponding output from one of
% the no distractor DDMs. You will also need to change your
% pathways/directories accordingly.


% This script randomly simulates behavioral measures under varying levels
% of the decay parameter or accumulation parameter. 
% The non-decision and boundary parameters are randomly selected from the
% full boundaries.
% The non-decision times are randomly selected from those derived from the
% no-distractor trials in the Partial-Information set. This is because the
% upper boundary for non-decision time was so high (i.e, set to the max RT)
% that randomly sampling this space did not accurately reflect
% participant's real estimates, and thus made the simulations odd. 

% Initialize variables.
clear
subnames = [1:50];

variable_names = {'estparams_all'};
    for currVar = 1:length(variable_names)
        grp1.ddm.noDist.Data.(variable_names{currVar}) = [];
    end

for currSubj = 1:length(subnames)
    thisSubj = subnames(currSubj);
    % pull noDist data
    for currVar = 1:length(variable_names)
        noDistparams = load(['results\output_' num2str(thisSubj) 'noDist1Data.mat']);        
        grp1.ddm.noDist.Data.(variable_names{currVar}) = [grp1.ddm.noDist.Data.(variable_names{currVar});noDistparams.(variable_names{currVar})];
    end
end

%% Okay, now we're actually running simulations
nsims = 135;
lb = [.00001 .5];
ub = [.01  5];
grp1_simChoices = [];
grp1_simRTs = [];
grp1_vals = [];
grp1_mu = [];

grp1_decay_simChoices = [];
grp1_decay_simRTs = [];
grp1_decay_vals = [];
grp1_decay_mu = [];
for dummySubj = 1:50
    random_drate = (ub(1) - lb(1)).*rand() + lb(1);
    random_ndt = grp1.ddm.noDist.Data.estparams_all(randi(50),2);
    random_boundary = (ub(2) - lb(2)).*rand() + lb(2);
    random_boundary = grp1.ddm.noDist.Data.estparams_all(randi(50),3);

    [thisChoice,thisRT,thisValDiff,thisMu] = fitFcn_Dist_simulate(random_drate,random_ndt,random_boundary);
    grp1_simChoices = [grp1_simChoices;thisChoice];
    grp1_simRTs = [grp1_simRTs;thisRT];
    grp1_vals = [grp1_vals;thisValDiff];
    grp1_mu = [grp1_mu;thisMu];

    [thisChoice,thisRT,thisValDiff,thisMu] = fitFcn_Dist_decay_simulate(random_drate,random_ndt,random_boundary);
    grp1_decay_simChoices = [grp1_simChoices;thisChoice];
    grp1_decay_simRTs = [grp1_decay_simRTs;thisRT];
    grp1_decay_vals = [grp1_decay_vals;thisValDiff];
    grp1_decay_mu = [grp1_decay_mu;thisMu];
end


%% Crunch for plotting
plotMean_grp1_simChoices = [];
plotSEM_grp1_simChoices = [];
plotMean_grp1_simRTs = [];
plotSEM_grp1_simRTs = [];

plotMean_grp1_decay_simChoices = [];
plotSEM_grp1_decay_simChoices = [];
plotMean_grp1_decay_simRTs = [];
plotSEM_grp1_decay_simRTs = [];

uniqueMus = unique(grp1_mu);
for currMu = 1:length(uniqueMus)
    % grp 1,choice
    empty_matrix = [];
    for currDiff = -4:4
        empty_matrix = [empty_matrix;nanmean(grp1_simChoices((grp1_mu==uniqueMus(currMu)&grp1_vals==currDiff)))];
    end
    plotMean_grp1_simChoices = [plotMean_grp1_simChoices;empty_matrix'];
    empty_matrix = [];
    for currDiff = -4:4
        empty_matrix = [empty_matrix;nanstd(grp1_simChoices((grp1_mu==uniqueMus(currMu)&grp1_vals==currDiff)))/sqrt(50)];
    end
    plotSEM_grp1_simChoices = [plotSEM_grp1_simChoices;empty_matrix'];

    % grp 1,rt
    empty_matrix = [];
    for currDiff = -4:4
        empty_matrix = [empty_matrix;nanmean(grp1_simRTs((grp1_mu==uniqueMus(currMu)&grp1_vals==currDiff)))];
    end
    plotMean_grp1_simRTs = [plotMean_grp1_simRTs;empty_matrix'];
    empty_matrix = [];
    for currDiff = -4:4
        empty_matrix = [empty_matrix;nanstd(grp1_simRTs((grp1_mu==uniqueMus(currMu)&grp1_vals==currDiff)))/sqrt(50)];
    end
    plotSEM_grp1_simRTs = [plotSEM_grp1_simRTs;empty_matrix'];

    % grp 1,choice DECAY
    empty_matrix = [];
    for currDiff = -4:4
        empty_matrix = [empty_matrix;nanmean(grp1_decay_simChoices((grp1_decay_mu==uniqueMus(currMu)&grp1_decay_vals==currDiff)))];
    end
    plotMean_grp1_decay_simChoices = [plotMean_grp1_decay_simChoices;empty_matrix'];
    empty_matrix = [];
    for currDiff = -4:4
        empty_matrix = [empty_matrix;nanstd(grp1_decay_simChoices((grp1_decay_mu==uniqueMus(currMu)&grp1_decay_vals==currDiff)))/sqrt(50)];
    end
    plotSEM_grp1_decay_simChoices = [plotSEM_grp1_decay_simChoices;empty_matrix'];

    % grp 1,rt DECAY
    empty_matrix = [];
    for currDiff = -4:4
        empty_matrix = [empty_matrix;nanmean(grp1_decay_simRTs((grp1_decay_mu==uniqueMus(currMu)&grp1_decay_vals==currDiff)))];
    end
    plotMean_grp1_decay_simRTs = [plotMean_grp1_decay_simRTs;empty_matrix'];
    empty_matrix = [];
    for currDiff = -4:4
        empty_matrix = [empty_matrix;nanstd(grp1_decay_simRTs((grp1_decay_mu==uniqueMus(currMu)&grp1_decay_vals==currDiff)))/sqrt(50)];
    end
    plotSEM_grp1_decay_simRTs = [plotSEM_grp1_decay_simRTs;empty_matrix'];

end


%% plot simulated choices
binranges = -4:4;
figure
subplot(2,2,1)
hold on
title('Accumulate - Choices')
errorbar(binranges,plotMean_grp1_simChoices(1,:),plotSEM_grp1_simChoices(1,:),'Marker','.','MarkerSize',12,'MarkerFaceColor','black','LineWidth',.75)
errorbar(binranges,plotMean_grp1_simChoices(2,:),plotSEM_grp1_simChoices(2,:),'Marker','.','MarkerSize',12,'MarkerFaceColor','black','LineWidth',.75)
errorbar(binranges,plotMean_grp1_simChoices(3,:),plotSEM_grp1_simChoices(3,:),'Marker','.','MarkerSize',12,'MarkerFaceColor','black','LineWidth',.75)
errorbar(binranges,plotMean_grp1_simChoices(4,:),plotSEM_grp1_simChoices(4,:),'Marker','.','MarkerSize',12,'MarkerFaceColor','black','LineWidth',.75)
errorbar(binranges,plotMean_grp1_simChoices(5,:),plotSEM_grp1_simChoices(5,:),'Marker','.','MarkerSize',12,'MarkerFaceColor','black','LineWidth',.75)
legend('Mu = 0','Mu = .25','Mu = .50','Mu = .75','Mu = 1.00')
xlim([-4.5 4.5])
ylim([0 1])
hold off
subplot(2,2,2)
hold on
title('Accumulate - RTs')
errorbar(binranges,plotMean_grp1_simRTs(1,:),plotSEM_grp1_simRTs(1,:),'Marker','.','MarkerSize',12,'MarkerFaceColor','black','LineWidth',.75)
errorbar(binranges,plotMean_grp1_simRTs(2,:),plotSEM_grp1_simRTs(2,:),'Marker','.','MarkerSize',12,'MarkerFaceColor','black','LineWidth',.75)
errorbar(binranges,plotMean_grp1_simRTs(3,:),plotSEM_grp1_simRTs(3,:),'Marker','.','MarkerSize',12,'MarkerFaceColor','black','LineWidth',.75)
errorbar(binranges,plotMean_grp1_simRTs(4,:),plotSEM_grp1_simRTs(4,:),'Marker','.','MarkerSize',12,'MarkerFaceColor','black','LineWidth',.75)
errorbar(binranges,plotMean_grp1_simRTs(5,:),plotSEM_grp1_simRTs(5,:),'Marker','.','MarkerSize',12,'MarkerFaceColor','black','LineWidth',.75)
legend('No Distractor','Mu = 0','Mu = .25','Mu = .50','Mu = .75','Mu = 1.00')
xlim([-4.5 4.5])
%ylim([0 1])
hold off

subplot(2,2,3)
hold on
title('Decay - Choices')
errorbar(binranges,plotMean_grp1_decay_simChoices(1,:),plotSEM_grp1_decay_simChoices(1,:),'Marker','.','MarkerSize',12,'MarkerFaceColor','black','LineWidth',.75)
errorbar(binranges,plotMean_grp1_decay_simChoices(2,:),plotSEM_grp1_decay_simChoices(2,:),'Marker','.','MarkerSize',12,'MarkerFaceColor','black','LineWidth',.75)
errorbar(binranges,plotMean_grp1_decay_simChoices(3,:),plotSEM_grp1_decay_simChoices(3,:),'Marker','.','MarkerSize',12,'MarkerFaceColor','black','LineWidth',.75)
errorbar(binranges,plotMean_grp1_decay_simChoices(4,:),plotSEM_grp1_decay_simChoices(4,:),'Marker','.','MarkerSize',12,'MarkerFaceColor','black','LineWidth',.75)
errorbar(binranges,plotMean_grp1_decay_simChoices(5,:),plotSEM_grp1_decay_simChoices(5,:),'Marker','.','MarkerSize',12,'MarkerFaceColor','black','LineWidth',.75)
legend('Mu = 0','Mu = .25','Mu = .50','Mu = .75','Mu = 1.00')
xlim([-4.5 4.5])
ylim([0 1])
hold off
subplot(2,2,4)
hold on
title('Decay - RTs')
errorbar(binranges,plotMean_grp1_decay_simRTs(1,:),plotSEM_grp1_decay_simRTs(1,:),'Marker','.','MarkerSize',12,'MarkerFaceColor','black','LineWidth',.75)
errorbar(binranges,plotMean_grp1_decay_simRTs(2,:),plotSEM_grp1_decay_simRTs(2,:),'Marker','.','MarkerSize',12,'MarkerFaceColor','black','LineWidth',.75)
errorbar(binranges,plotMean_grp1_decay_simRTs(3,:),plotSEM_grp1_decay_simRTs(3,:),'Marker','.','MarkerSize',12,'MarkerFaceColor','black','LineWidth',.75)
errorbar(binranges,plotMean_grp1_decay_simRTs(4,:),plotSEM_grp1_decay_simRTs(4,:),'Marker','.','MarkerSize',12,'MarkerFaceColor','black','LineWidth',.75)
errorbar(binranges,plotMean_grp1_decay_simRTs(5,:),plotSEM_grp1_decay_simRTs(5,:),'Marker','.','MarkerSize',12,'MarkerFaceColor','black','LineWidth',.75)
legend('No Distractor','Mu = 0','Mu = .25','Mu = .50','Mu = .75','Mu = 1.00')
xlim([-4.5 4.5])
%ylim([0 1])
hold off
print('-depsc2','-painters','-loose','Simulations.eps')

