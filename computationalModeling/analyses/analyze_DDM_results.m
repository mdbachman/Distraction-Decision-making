%% Drift-diffusion analyses for my Distraction & Decision Making paper
% Author: Matthew D. Bachman
% To make this script you will need the corresponding output from all of
% the DDMs, and to make sure the pathways load correctly.

% Initialize variables.
clear
subnames = [1:50];

% Allocate empty variables.
model_names = {'Data_2ndSampleDistDur2','Data_decay','Data_firstFixnoRV','Data_decay_firstFixnoRV'};
variable_names = {'estparams_all','chisq_all'};
for currModel = 1:length(model_names)
    for currVar = 1:length(variable_names)
        partialInfoDistractions.ddm.Dist.(model_names{currModel}).(variable_names{currVar}) = [];
        fullInfoDistractions.ddm.Dist.(model_names{currModel}).(variable_names{currVar}) = [];
        partialInfoDistractions.ddm.noDist.Data.(variable_names{currVar}) = [];
        fullInfoDistractions.ddm.noDist.Data.(variable_names{currVar}) = [];
        partialInfoDistractions.ddm.noDist.Data_addm.(variable_names{currVar}) = [];
        fullInfoDistractions.ddm.noDist.Data_addm.(variable_names{currVar}) = [];
        partialInfoDistractions.ddm.noDist.Data_addm_firstFixnoRV.(variable_names{currVar}) = [];
        fullInfoDistractions.ddm.noDist.Data_addm_firstFixnoRV.(variable_names{currVar}) = [];
    end
end


for thisSubj = 1:length(subnames)
    % pull noDist data
    for currVar = 1:length(variable_names)
        % regulart DDM  (see Equation 1 in Methods)
        noDistparams = load(['results\output_' num2str(thisSubj) 'noDist1Data.mat']);        
        partialInfoDistractions.ddm.noDist.Data.(variable_names{currVar}) = [partialInfoDistractions.ddm.noDist.Data.(variable_names{currVar});noDistparams.(variable_names{currVar})];
        noDistparams = load(['results\output_' num2str(thisSubj) 'noDist2Data.mat']);        
        fullInfoDistractions.ddm.noDist.Data.(variable_names{currVar}) = [fullInfoDistractions.ddm.noDist.Data.(variable_names{currVar});noDistparams.(variable_names{currVar})];

         % regular aDDM  (see Equation 2 in Methods)
        noDistparams = load(['results_addm\addm_s' num2str(thisSubj) '_noDist_set1_Data_v2.mat']);        
        partialInfoDistractions.ddm.noDist.Data_addm.(variable_names{currVar}) = [partialInfoDistractions.ddm.noDist.Data_addm.(variable_names{currVar});noDistparams.(variable_names{currVar})];
        noDistparams = load(['results_addm\addm_s' num2str(thisSubj) '_noDist_set2_Data_v2.mat']);        
        fullInfoDistractions.ddm.noDist.Data_addm.(variable_names{currVar}) = [fullInfoDistractions.ddm.noDist.Data_addm.(variable_names{currVar});noDistparams.(variable_names{currVar})];

        % modified aDDM (see Equation 3 in Methods)
        noDistparams = load(['results_addm\addm_s' num2str(thisSubj) '_noDist_set1_Data_v2_firstFixnoRV.mat']);        
        partialInfoDistractions.ddm.noDist.Data_addm_firstFixnoRV.(variable_names{currVar}) = [partialInfoDistractions.ddm.noDist.Data_addm_firstFixnoRV.(variable_names{currVar});noDistparams.(variable_names{currVar})];
        noDistparams = load(['results_addm\addm_s' num2str(thisSubj) '_noDist_set2_Data_v2_firstFixnoRV.mat']);        
        fullInfoDistractions.ddm.noDist.Data_addm_firstFixnoRV.(variable_names{currVar}) = [fullInfoDistractions.ddm.noDist.Data_addm_firstFixnoRV.(variable_names{currVar});noDistparams.(variable_names{currVar})];
    end


    % Pull Dist data
    for currModel = 1:length(model_names)
        % load model parameters for 
        params = load(['results\output_' num2str(thisSubj) 'Dist1' cell2mat(model_names(currModel)) '.mat']);
        for currVar = 1:length(variable_names)
            if isfield(params,variable_names{currVar})
                partialInfoDistractions.ddm.Dist.(model_names{currModel}).(variable_names{currVar}) = [partialInfoDistractions.ddm.Dist.(model_names{currModel}).(variable_names{currVar});params.(variable_names{currVar})];
            else
                partialInfoDistractions.ddm.Dist.(model_names{currModel}).(variable_names{currVar}) = [partialInfoDistractions.ddm.Dist.(model_names{currModel}).(variable_names{currVar});NaN];
            end
            if strmatch(cell2mat(model_names(currModel)),'Data_decay_withholdTrials','exact')
                partialInfoDistractions.ddm.Dist.(model_names{currModel}).index{thisSubj} = params.index;
            end
            end
            params = load(['results\output_' num2str(thisSubj) 'Dist2' cell2mat(model_names(currModel)) '.mat']);
            for currVar = 1:length(variable_names)
                if isfield(params,variable_names{currVar})
                    fullInfoDistractions.ddm.Dist.(model_names{currModel}).(variable_names{currVar}) = [fullInfoDistractions.ddm.Dist.(model_names{currModel}).(variable_names{currVar});params.(variable_names{currVar})];
                else
                    fullInfoDistractions.ddm.Dist.(model_names{currModel}).(variable_names{currVar}) = [fullInfoDistractions.ddm.Dist.(model_names{currModel}).(variable_names{currVar});NaN];
                end
                if strmatch(cell2mat(model_names(currModel)),'Data_decay_withholdTrials','exact')
                    fullInfoDistractions.ddm.Dist.(model_names{currModel}).index{thisSubj} = params.index;
                end
            end
        end
    end



% Convert chi-square fits to BICs using the following equation
% BIC = Chi-square * number of parameters fit * log(number of subjects)
BIC_ddm_partialInfoDistractions = partialInfoDistractions.ddm.noDist.Data.chisq_all * 3 * log(length(partialInfoDistractions.ddm.noDist.Data.chisq_all ));
BIC_ddm_fullInfoDistractions = fullInfoDistractions.ddm.noDist.Data.chisq_all * 3 * log(length(fullInfoDistractions.ddm.noDist.Data.chisq_all ));
BIC_addm_reg_partialInfoDistractions = partialInfoDistractions.ddm.noDist.Data_addm.chisq_all * 4 * log(length(partialInfoDistractions.ddm.noDist.Data_addm.chisq_all));
BIC_addm_reg_fullInfoDistractions = fullInfoDistractions.ddm.noDist.Data_addm.chisq_all * 4 * log(length(fullInfoDistractions.ddm.noDist.Data_addm.chisq_all));
BIC_addm_nRV_partialInfoDistractions = partialInfoDistractions.ddm.noDist.Data_addm_firstFixnoRV.chisq_all * 4 * log(length(partialInfoDistractions.ddm.noDist.Data_addm_firstFixnoRV.chisq_all));
BIC_addm_nRV_fullInfoDistractions = fullInfoDistractions.ddm.noDist.Data_addm_firstFixnoRV.chisq_all * 4 * log(length(fullInfoDistractions.ddm.noDist.Data_addm_firstFixnoRV.chisq_all));

% Comparing no distraction conditions.
[a,b,c,d] = ttest(BIC_ddm_partialInfoDistractions,BIC_addm_reg_partialInfoDistractions) % p = 6.4385e-06, t = -5.0535
[a,b,c,d] = ttest(BIC_ddm_fullInfoDistractions,BIC_addm_reg_fullInfoDistractions) % p = 8.2575e-07, t = -5.6432
[a,b,c,d] = ttest(BIC_ddm_partialInfoDistractions,BIC_addm_nRV_partialInfoDistractions) % p =  3.9292e-15, t = -11.2132
[a,b,c,d] = ttest(BIC_ddm_fullInfoDistractions,BIC_addm_nRV_fullInfoDistractions) % p = 3.9684e-15, t = -11.2100


% Now, identify the best-fitting Distraction model.
BIC_partialInfoDistractions_acc = partialInfoDistractions.ddm.Dist.Data_2ndSampleDistDur2.chisq_all * 3 * log(50);
BIC_partialInfoDistractions_dec = partialInfoDistractions.ddm.Dist.Data_decay.chisq_all * 3 * log(50);
BIC_partialInfoDistractions_accFF = partialInfoDistractions.ddm.Dist.Data_firstFixnoRV.chisq_all * 3 * log(50);
BIC_partialInfoDistractions_decFF = partialInfoDistractions.ddm.Dist.Data_decay_firstFixnoRV.chisq_all * 3 * log(50);

BIC_fullInfoDistractions_acc = fullInfoDistractions.ddm.Dist.Data_2ndSampleDistDur2.chisq_all * 3 * log(50);
BIC_fullInfoDistractions_dec = fullInfoDistractions.ddm.Dist.Data_decay.chisq_all * 3 * log(50);
BIC_fullInfoDistractions_accFF = fullInfoDistractions.ddm.Dist.Data_firstFixnoRV.chisq_all * 3 * log(50);
BIC_fullInfoDistractions_decFF = fullInfoDistractions.ddm.Dist.Data_decay_firstFixnoRV.chisq_all * 3 * log(50);

% Decay best fits the partial-information condition
[a,b,c,d]= ttest(BIC_partialInfoDistractions_dec,BIC_partialInfoDistractions_acc) % p = .004, t = -3.0230
[a,b,c,d]= ttest(BIC_partialInfoDistractions_dec,BIC_partialInfoDistractions_accFF)  % p = 2.3154e-08, t = -6.6497
[a,b,c,d]= ttest(BIC_partialInfoDistractions_dec,BIC_partialInfoDistractions_decFF)  % p = 0.0743, t = -1.8239

% Decay best fits the full-information condition.
[a,b,c,d]= ttest(BIC_fullInfoDistractions_dec,BIC_fullInfoDistractions_acc) % p = .0146, t = -2.532
[a,b,c,d]= ttest(BIC_fullInfoDistractions_dec,BIC_fullInfoDistractions_accFF)  % p = 0.3181, t = -1.0086
[a,b,c,d]= ttest(BIC_fullInfoDistractions_dec,BIC_fullInfoDistractions_decFF)  % p = 0.3181, t = -1.0086

[a,b,c,d] = ttest2(partialInfoDistractions.ddm.Dist.Data_decay.estparams_all,fullInfoDistractions.ddm.Dist.Data_decay.estparams_all)
% t(98) = 4.4378, p = 2.3831e-05


[a,b,c] = kstest2(partialInfoDistractions.ddm.Dist.Data_decay.estparams_all,fullInfoDistractions.ddm.Dist.Data_decay.estparams_all)
%p =  4.2318e-04, D = 0.4000

%% Make the figure.
figure
subplot(1,2,1)
hold on
histogram(partialInfoDistractions.ddm.Dist.Data_decay.estparams_all,10,'FaceColor',[239/255 65/255 55/255])
title('Set 1 - estimated decay parameter, outliers removed')
ylim([0 22])
xlabel('Percent of decay')
ylabel('frequency')
hold off
subplot(1,2,2)
hold on
histogram(fullInfoDistractions.ddm.Dist.Data_decay.estparams_all,10,'FaceColor',[236/255 0 140/255])
ylim([0 22])
title('Set 2 - estimated decay parameter, outliers removed')
xlabel('Percent of decay')
ylabel('frequency')
hold off
print('-depsc2','-painters','-loose','Figure6.eps')


