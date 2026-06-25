%% Analysis script for Distraction study
% Author: Matthew D. Bachman
% This script handles the analysis and plotting for the paper.

% Load the processed data from both conditions
Set1 = load('S:\Projects\Bachman\EyetrackingDistraction\version1_firstFixation\analysis\PartialInfoDistractor.mat');
Set2 = load('S:\Projects\Bachman\EyetrackingDistraction\version2_secondFixation\analysis\FullInfoDistractor.mat');

%% Format the data
% Behavioral Stats
    Behavioral_Stats_dataset_study1 = dataset(Set1.Analysis_full.Behavior.choice,...
        Set1.Analysis_full.Behavior.ratings,...
        Set1.Analysis_full.Behavior.distractor_trials,...
        Set1.Analysis_full.subname,...
        Set1.Analysis_full.Behavior.RT_min400);
    Behavioral_Stats_dataset_study1.Properties.VarNames = {'choices','SVdiff','TrialType','SubjList','RT_adjusted'};

    Behavioral_Stats_dataset_study2 = dataset(Set2.Analysis_full.Behavior.choice,...
        Set2.Analysis_full.Behavior.ratings,...
        Set2.Analysis_full.Behavior.distractor_trials,...
        Set2.Analysis_full.subname,...
        Set2.Analysis_full.Behavior.RT_adjusted);
    Behavioral_Stats_dataset_study2.Properties.VarNames = {'choices','SVdiff','TrialType','SubjList','RT_adjusted'};

    % Eye-tracking analyses
    EyeTracking_Stats_dataset_study1 = dataset(Set1.Analysis_full.EyeTracking.followingFix_sam_SubjList, ...
        Set1.Analysis_full.EyeTracking.followingFix_sam_all, ...
        Set1.Analysis_full.EyeTracking.distractor_trials_firstFixRating);
    EyeTracking_Stats_dataset_study1.Properties.VarNames = {'SubjList','followingFix_sam','disruptedRating'};


    EyeTracking_Stats_dataset_study2 = dataset(Set2.Analysis_full.EyeTracking.followingFix_sam_SubjList, ...
        Set2.Analysis_full.EyeTracking.followingFix_sam_all, ...
        Set2.Analysis_full.EyeTracking.followingFix_returnRating);
    EyeTracking_Stats_dataset_study2.Properties.VarNames = {'SubjList','followingFix_sam','disruptedRating'};

    % Relationship between first fix to choice
    firstFix_dataset_study1 = dataset(Set1.Analysis_full.EyeTracking.firstFix_choiceBias, ...
        Set1.Analysis_full.Behavior.distractor_trials,...
        Set1.Analysis_full.subname);
    firstFix_dataset_study1.Properties.VarNames = {'firstFix_choiceBias','trialType','SubjList'};

    firstFix_dataset_study2 = dataset(Set2.Analysis_full.EyeTracking.firstFix_choiceBias, ...
        Set2.Analysis_full.Behavior.distractor_trials,...
        Set2.Analysis_full.subname);
    firstFix_dataset_study2.Properties.VarNames = {'firstFix_choiceBias','trialType','SubjList'};

    % Relationship between post-distraction fixation to choice.
    postDistFix_dataset_study1 = dataset(Set1.Analysis_full.EyeTracking.followingFix_sam_SubjList, ...
        Set1.Analysis_full.EyeTracking.followingFix_sam_all, ...
        Set1.Analysis_full.EyeTracking.distractor_trials_firstFixRating, ...
        Set1.Analysis_full.Behavior.followFix_toChoice_all);
    postDistFix_dataset_study1.Properties.VarNames = {'SubjList','followingFix_sam','disruptedRating','selectedSecondFix'};
    postDistFix_dataset_study1.followingFix_sam(postDistFix_dataset_study1.followingFix_sam==0)=-1;

    postDistFix_dataset_study2 = dataset(Set2.Analysis_full.EyeTracking.followingFix_sam_SubjList, ...
        Set2.Analysis_full.EyeTracking.followingFix_sam_all, ...
        Set2.Analysis_full.EyeTracking.followingFix_returnRating, ...
        Set2.Analysis_full.Behavior.followFix_toChoice_all);
    postDistFix_dataset_study2.Properties.VarNames = {'SubjList','followingFix_sam','disruptedRating','selectedSecondFix'};
    postDistFix_dataset_study2.followingFix_sam(postDistFix_dataset_study2.followingFix_sam==0)=-1;



%% How do distraction influence behavioral measures (i.e., Figure 2).

% Choice Time - Study 1 (Fig 2A; Table 1, left)
    glme=fitglme(Behavioral_Stats_dataset_study1, 'RT_adjusted ~ SVdiff^2* TrialType - SVdiff - SVdiff:TrialType + (SVdiff^2* TrialType - SVdiff - SVdiff:TrialType |SubjList)','Distribution','Normal','Link','identity')
%     Name                           Estimate      SE           tStat      DF       pValue         Lower         Upper    
%    {'(Intercept)'       }            1.313      0.03834     34.245    19594    1.1406e-249         1.2378       1.3881
%    {'TrialType'         }         0.062478     0.021232     2.9426    19594      0.0032584       0.020861      0.10409
%    {'SVdiff^2'          }        -0.024729    0.0014142    -17.486    19594     6.0474e-68      -0.027501    -0.021957
%    {'SVdiff^2:TrialType'}        0.0021516    0.0012692     1.6953    19594        0.09004    -0.00033609    0.0046392

% Choice Time - Study 2 (Fig 2B; Table 1, right)
    glme=fitglme(Behavioral_Stats_dataset_study2, 'RT_adjusted ~ SVdiff^2* TrialType - SVdiff - SVdiff:TrialType + (SVdiff^2* TrialType - SVdiff - SVdiff:TrialType |SubjList)','Distribution','Normal','Link','identity')
    % Name                          Estimate     SE           tStat      DF       pValue         Lower        Upper    
    % {'(Intercept)'       }           1.3981      0.03946     35.431    17612    1.1065e-265       1.3208       1.4754
    % {'TrialType'         }          0.21582     0.023933     9.0177    17612     2.1148e-19      0.16891      0.26273
    % {'SVdiff^2'          }        -0.027069    0.0017587    -15.391    17612     4.1713e-53    -0.030516    -0.023621
    % {'SVdiff^2:TrialType'}         0.010789    0.0017645     6.1145    17612     9.8925e-10    0.0073303     0.014247


% Choice consistency - Study 1 (Figure 2C; Table 2, left)
    glme=fitglme(Behavioral_Stats_dataset_study1, 'choices ~ SVdiff * TrialType+ (SVdiff*TrialType|SubjList)','Distribution','binomial','Link','logit')
%    Name                        Estimate     SE          tStat      DF       pValue         Lower        Upper   
%    {'(Intercept)'     }         0.043196    0.031514     1.3707    19594        0.17049    -0.018574     0.10497
%    {'SVdiff'          }           1.3472    0.063121     21.343    19594    6.1891e-100       1.2235      1.4709
%    {'TrialType'       }        -0.063417    0.053636    -1.1823    19594        0.23708     -0.16855    0.041715
%    {'SVdiff:TrialType'}         0.043341    0.034482     1.2569    19594         0.2088    -0.024247     0.11093
 

% Choice consistency - Study 2 (Figure 2D; Table 2, right)
    glme=fitglme(Behavioral_Stats_dataset_study2, 'choices ~ SVdiff * TrialType+ (SVdiff*TrialType|SubjList)','Distribution','binomial','Link','logit')
%    Name                        Estimate     SE          tStat       DF       pValue        Lower        Upper   
%    {'(Intercept)'     }          0.03225    0.033483     0.96317    17612       0.33547     -0.03338    0.097881
%    {'SVdiff'          }           1.2523    0.062924      19.902    17612    3.5777e-87        1.129      1.3756
%    {'TrialType'       }        -0.041185    0.057365    -0.71794    17612        0.4728     -0.15363    0.071257
%    {'SVdiff:TrialType'}         0.071076    0.041703      1.7043    17612      0.088337    -0.010666     0.15282


    figure
    subplot(2,2,1)
    hold on
    errorbar(-4:4,nanmean(Set1.Analysis_full.Plotting.rt_noDist),nanstd(Set1.Analysis_full.Plotting.rt_noDist)/sqrt(50),'color','blue','marker','.','color','b')
    errorbar(-4:4,nanmean(Set1.Analysis_full.Plotting.rt_dist),nanstd(Set1.Analysis_full.Plotting.rt_dist)/sqrt(50),'color','red','marker','.','color','r')
    xlim([-4.05 4.05]); ylim([.6 2])
    xlabel('Value Difference')
    ylabel('Choice Time')
    hold off
    subplot(2,2,2)
    hold on
    errorbar(-4:4,nanmean(Set2.Analysis_full.Plotting.rt_noDist),nanstd(Set2.Analysis_full.Plotting.rt_noDist)/sqrt(50),'color','blue','marker','.','color','b')
    errorbar(-4:4,nanmean(Set2.Analysis_full.Plotting.rt_dist),nanstd(Set2.Analysis_full.Plotting.rt_dist)/sqrt(50),'color','magenta','marker','.','color','m')
    xlim([-4.05 4.05]); ylim([.6 2])
    xlabel('Value Difference')
    ylabel('Choice Time')
    hold off
    subplot(2,2,3)
    hold on
    errorbar(-4:4,nanmean(Set1.Analysis_full.Plotting.choice_noDist),nanstd(Set1.Analysis_full.Plotting.choice_noDist)/sqrt(50),'color','blue','marker','.','color','b')
    errorbar(-4:4,nanmean(Set1.Analysis_full.Plotting.choice_dist),nanstd(Set1.Analysis_full.Plotting.choice_dist)/sqrt(50),'color','red','marker','.','color','r')
    xlim([-4.05 4.05]); ylim([0 1])
    xticks(-4:1:4);
    yticks(0:.1:1);      
    xlabel('Value Difference')
    ylabel('Proportion choice==1')
    hold off
    subplot(2,2,4)
    hold on
    errorbar(-4:4,nanmean(Set2.Analysis_full.Plotting.choice_noDist),nanstd(Set2.Analysis_full.Plotting.choice_noDist)/sqrt(50),'color','blue','marker','.','color','b')
    errorbar(-4:4,nanmean(Set2.Analysis_full.Plotting.choice_dist),nanstd(Set2.Analysis_full.Plotting.choice_dist)/sqrt(50),'color','magenta','marker','.','color','m')
    xlim([-4.05 4.05]); ylim([0 1])
    xticks(-4:1:4);
    yticks(0:.1:1);      
    xlabel('Value Difference')
    ylabel('Proportion choice==1')
    hold off
    print('-depsc2','-painters','-loose','Figure2.eps')



%% Where do people look after being distracted? (i.e., Figure 3).

%Table 3, left
    glme=fitglme(EyeTracking_Stats_dataset_study1, 'followingFix_sam ~ disruptedRating + (disruptedRating|SubjList)','Distribution','binomial','Link','logit')

    % Name                       Estimate    SE          tStat      DF      pValue         Lower      Upper  
    % {'(Intercept)'    }        -2.0571     0.083265    -24.706    4732    7.4333e-127    -2.2204    -1.8939
    % {'disruptedRating'}        0.38167     0.048504     7.8689    4732     4.4031e-15    0.28658    0.47677

    %Table 3, right

    glme=fitglme(EyeTracking_Stats_dataset_study2, 'followingFix_sam ~ disruptedRating + (disruptedRating|SubjList)','Distribution','binomial','Link','logit')
    % {'(Intercept)'    }        -0.9957     0.086786    -11.473    1561    2.5988e-29    -1.1659    -0.82547
    % {'disruptedRating'}        0.75198     0.066829     11.252    1561    2.6857e-28    0.62089     0.88306

figure
hold on
errorbar(-2:2,nanmean(Set1.Analysis_full.Plotting.postDistFix),nanstd(Set1.Analysis_full.Plotting.postDistFix)/sqrt(50),'color','red','marker','.','markersize',20,'linewidth',2,'color','r')
errorbar(-2:2,nanmean(Set2.Analysis_full.Plotting.postDistFix),nanstd(Set2.Analysis_full.Plotting.postDistFix)/sqrt(50),'color','magenta','marker','.','markersize',20,'linewidth',2,'color','m')
xlim([-2.05 2.05])
hold off
ylim([0 1])
print('-depsc2','-painters','-loose','Figure3.eps')





%% What happens to the relationship between first fixation to choices (Figure 4a)

% Table 4, left
    glme=fitglme(firstFix_dataset_study1, 'firstFix_choiceBias ~ trialType+(trialType|SubjList)','Distribution','binomial','Link','logit')
 %   Name                   Estimate      SE          tStat        DF       pValue        Lower       Upper   
%    {'(Intercept)'}            0.0745    0.019952        3.734    19074    0.00018899    0.035393     0.11361
%    {'trialType'  }        -0.0032079    0.036703    -0.087401    19074       0.93035    -0.07515    0.068734

% Table 4, right
    glme=fitglme(firstFix_dataset_study2, 'firstFix_choiceBias ~ trialType+(trialType|SubjList)','Distribution','binomial','Link','logit')%
%    Name                   Estimate    SE          tStat      DF       pValue        Lower       Upper    
 %   {'(Intercept)'}        0.080018     0.01831     4.3701    17131    1.2491e-05    0.044128      0.11591
  %  {'trialType'  }        -0.10218    0.039654    -2.5767    17131     0.0099825     -0.1799    -0.024451



%% What is the relationship between post-distraction fixations and choices (Figure 4b)

% Table 5, left
    glme=fitglme(postDistFix_dataset_study1, 'selectedSecondFix ~ followingFix_sam*disruptedRating + (followingFix_sam*disruptedRating|SubjList)','Distribution','binomial','Link','logit')
 %   {'(Intercept)'                     }         0.32766    0.072084     4.5456    4730    5.6151e-06      0.18635    0.46898
 %   {'followingFix_sam'                }         0.42496     0.09491     4.4775    4730      7.73e-06      0.23889    0.61103
 %   {'disruptedRating'                 }        0.019747    0.051891    0.38056    4730       0.70355    -0.081983    0.12148
 %   {'followingFix_sam:disruptedRating'}          1.1236    0.058297     19.274    4730    9.3977e-80       1.0093     1.2379

% Table 5, right

    glme=fitglme(postDistFix_dataset_study2, 'selectedSecondFix ~ followingFix_sam*disruptedRating + (followingFix_sam*disruptedRating|SubjList)','Distribution','binomial','Link','logit')
    % Name                                        Estimate    SE          tStat      DF      pValue        Lower       Upper  
    % {'(Intercept)'                     }          1.2754     0.12067     10.569    1559    2.8865e-25      1.0387     1.5121
    % {'followingFix_sam'                }         0.41463     0.11724     3.5367    1559    0.00041708     0.18467    0.64459
    % {'disruptedRating'                 }        0.010557    0.081578    0.12941    1559       0.89705    -0.14946    0.17057
    % {'followingFix_sam:disruptedRating'}         0.79343    0.082979     9.5617    1559     4.328e-21     0.63066    0.95619

pi_firstchoicebias = [nanmean(Set1.Analysis_full.Plotting.firstFix_choiceBias_no_distractor);nanmean(Set1.Analysis_full.Plotting.firstFix_choiceBias_distractor)];
pi_firstchoicebias_SEM = [nanstd(Set1.Analysis_full.Plotting.firstFix_choiceBias_no_distractor)/(sqrt(50));nanstd(Set1.Analysis_full.Plotting.firstFix_choiceBias_distractor)/(sqrt(50))];
fi_firstchoicebias = [nanmean(Set2.Analysis_full.Plotting.firstFix_choiceBias_no_distractor);nanmean(Set2.Analysis_full.Plotting.firstFix_choiceBias_distractor)];
fi_firstchoicebias_SEM = [nanstd(Set2.Analysis_full.Plotting.firstFix_choiceBias_no_distractor)/(sqrt(50));nanstd(Set2.Analysis_full.Plotting.firstFix_choiceBias_distractor)/(sqrt(50))];

figure
subplot(1,4,1)
hold on
title('Choice bias towards first fixated item')
bar(1:2,pi_firstchoicebias,'r')
errorbar(1:2,pi_firstchoicebias,pi_firstchoicebias_SEM,'.','color','black','linewidth',1)
set(gca,'XLim',[0.5 2.5],'YLim',[.4 .6])
plot(xlim,[.5 .5], 'k')
hold off
ylabel('Proportion of choices to first fix item')
subplot(1,4,2)
hold on
title('Choice bias towards first fixated item')
bar(1:2,fi_firstchoicebias,'r')
errorbar(1:2,fi_firstchoicebias,fi_firstchoicebias_SEM,'.','color','black','linewidth',1)
set(gca,'XLim',[0.5 2.5],'YLim',[.4 .6])
plot(xlim,[.5 .5], 'k')
hold off
subplot(1,4,3)
hold on
title('Choice bias towards follow-fix item')
bar(nanmean(Set1.Analysis_full.Plotting.followFix_toChoice_mean),'r')
errorbar(nanmean(Set1.Analysis_full.Plotting.followFix_toChoice_mean),nanstd(Set1.Analysis_full.Plotting.followFix_toChoice_mean)/(sqrt(50)),'.','color','black','linewidth',1)
set(gca,'XLim',[0.5 1.5],'YLim',[0 1])
plot(xlim,[.5 .5], 'k')
ylabel('Proportion of choices to first fix item')
hold off
subplot(1,4,4)
hold on
title('Choice bias towards follow-fix item')
bar(nanmean(Set2.Analysis_full.Plotting.followFix_toChoice_mean),'r')
errorbar(nanmean(Set2.Analysis_full.Plotting.followFix_toChoice_mean),nanstd(Set2.Analysis_full.Plotting.followFix_toChoice_mean)/(sqrt(50)),'.','color','black','linewidth',1)
set(gca,'XLim',[0.5 1.5],'YLim',[0 1])
plot(xlim,[.5 .5], 'k')
hold off
ylabel('Proportion of choices to first fix item')
print('-depsc2','-painters','-loose','Figure4.eps')

addpath('S:\Projects\Bachman\EyetrackingDistraction\version2_secondFixation\analysis')

figure
subplot(1,2,1)
violinplot(Set1.Analysis_full.EyeTracking.propDistFix)
title('Partial-Information Distractions')
ylabel('Proportion of attending to distraction')
ylim([0 1])
subplot(1,2,2)
violinplot(Set2.Analysis_full.EyeTracking.propDistFix)
title('Full-Information Distractions')
ylabel('Proportion of attending to distraction')
ylim([0 1])
print('-depsc2','-painters','-loose','Distractability.eps')
    
