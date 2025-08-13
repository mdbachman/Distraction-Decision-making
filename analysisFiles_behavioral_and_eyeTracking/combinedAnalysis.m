%% Analysis script for Distraction study
% Author: Matthew D. Bachman
% This script handles the analysis and plotting for the paper.

% Load the processed data from both conditions
Set1 = load('S:\Projects\Bachman\EyetrackingDistraction\version1_firstFixation\analysis\PartialInfoDistractor.mat');
Set2 = load('S:\Projects\Bachman\EyetrackingDistraction\version2_secondFixation\analysis\FullInfoDistractor.mat');

%% Format the data
% Behavioral Stats
    Behavioral_Stats_dataset = dataset([Set1.Analysis_full.Behavior.choice;Set2.Analysis_full.Behavior.choice],...
                  [Set1.Analysis_full.Behavior.ratings;Set2.Analysis_full.Behavior.ratings],...
        [Set1.Analysis_full.Behavior.distractor_trials;Set2.Analysis_full.Behavior.distractor_trials],...
        [Set1.Analysis_full.subname;Set2.Analysis_full.subname+50],...
        [Set1.Analysis_full.Behavior.RT_min400;Set2.Analysis_full.Behavior.RT_adjusted],...
        [repmat(-1,length(Set1.Analysis_full.subname),1);repmat(1,length(Set2.Analysis_full.subname),1)]);
    Behavioral_Stats_dataset.Properties.VarNames = {'choices','SVdiff','TrialType','SubjList','RT_adjusted','Dataset'};

    % Eye-tracking analyses
    EyeTracking_Stats_dataset = dataset([Set1.Analysis_full.EyeTracking.followingFix_sam_SubjList;Set2.Analysis_full.EyeTracking.followingFix_sam_SubjList+50], ...
        [Set1.Analysis_full.EyeTracking.followingFix_sam_all;Set2.Analysis_full.EyeTracking.followingFix_sam_all], ...
        [Set1.Analysis_full.EyeTracking.distractor_trials_firstFixRating;Set2.Analysis_full.EyeTracking.followingFix_returnRating], ...
        [repmat(-1,length(Set1.Analysis_full.EyeTracking.followingFix_sam_SubjList),1);repmat(1,length(Set2.Analysis_full.EyeTracking.followingFix_sam_SubjList),1)]);
    EyeTracking_Stats_dataset.Properties.VarNames = {'SubjList','followingFix_sam','disruptedRating','Dataset'};

    % Relationship between first fix to choice
    firstFix_dataset = dataset([Set1.Analysis_full.EyeTracking.firstFix_choiceBias;Set2.Analysis_full.EyeTracking.firstFix_choiceBias], ...
        [Set1.Analysis_full.Behavior.distractor_trials;Set2.Analysis_full.Behavior.distractor_trials],...
        [Set1.Analysis_full.subname;Set2.Analysis_full.subname+50],...
        [repmat(-1,length(Set1.Analysis_full.subname),1);repmat(1,length(Set2.Analysis_full.subname),1)]);
    firstFix_dataset.Properties.VarNames = {'firstFix_choiceBias','trialType','SubjList','Dataset'};

    % Relationship between post-distraction fixation to choice.
    postDistFix_dataset = dataset([Set1.Analysis_full.EyeTracking.followingFix_sam_SubjList;Set2.Analysis_full.EyeTracking.followingFix_sam_SubjList+50], ...
        [Set1.Analysis_full.EyeTracking.followingFix_sam_all;Set2.Analysis_full.EyeTracking.followingFix_sam_all], ...
        [Set1.Analysis_full.EyeTracking.distractor_trials_firstFixRating;Set2.Analysis_full.EyeTracking.followingFix_returnRating], ...
        [Set1.Analysis_full.Behavior.followFix_toChoice_all;Set2.Analysis_full.Behavior.followFix_toChoice_all], ...
        [repmat(-1,length(Set1.Analysis_full.EyeTracking.followingFix_sam_SubjList),1);repmat(1,length(Set2.Analysis_full.EyeTracking.followingFix_sam_SubjList),1)]);
    postDistFix_dataset.Properties.VarNames = {'SubjList','followingFix_sam','disruptedRating','selectedSecondFix','Dataset'};
    postDistFix_dataset.followingFix_sam(postDistFix_dataset.followingFix_sam==0)=-1;

%% How do distraction influence behavioral measures (i.e., Figure 2).

% Choice Time (Fig 2A and B)
    glme=fitglme(Behavioral_Stats_dataset, 'RT_adjusted ~ Dataset*SVdiff^2* TrialType - SVdiff - SVdiff:TrialType -  SVdiff:Dataset - SVdiff:TrialType:Dataset + (Dataset*SVdiff^2* TrialType - SVdiff - SVdiff:TrialType -  SVdiff:Dataset - SVdiff:TrialType:Dataset|SubjList)','Distribution','Normal','Link','identity')
%     Name                                  Estimate      SE           tStat      DF       pValue         Lower         Upper    
%     {'(Intercept)'               }            1.3555      0.02751     49.275    37206              0        1.3016       1.4095
%     {'TrialType'                 }           0.13915     0.016019     8.6868    37206     3.8755e-18       0.10775      0.17055
%     {'Dataset'                   }          0.042582      0.02751     1.5479    37206        0.12166     -0.011338     0.096501
%     {'TrialType:Dataset'         }          0.076706     0.016019     4.7886    37206     1.6863e-06      0.045309       0.1081
%     {'SVdiff^2'                  }         -0.025895    0.0011299    -22.918    37206    1.9305e-115     -0.028109     -0.02368
%     {'SVdiff^2:TrialType'        }         0.0064589    0.0010999     5.8722    37206     4.3377e-09      0.004303    0.0086147
%     {'SVdiff^2:Dataset'          }        -0.0011666    0.0011299    -1.0325    37206        0.30185    -0.0033812     0.001048
%     {'SVdiff^2:TrialType:Dataset'}         0.0043156    0.0010999     3.9236    37206     8.7397e-05     0.0021597    0.0064715 


% Choice consistency.
    glme=fitglme(Behavioral_Stats_dataset, 'choices ~ Dataset*SVdiff * TrialType+ (Dataset*SVdiff*TrialType|SubjList)','Distribution','binomial','Link','logit')
%     Name                                Estimate      SE          tStat       DF       pValue         Lower         Upper   
%     {'(Intercept)'             }          0.037723    0.022991      1.6408    37206        0.10085    -0.0073392    0.082785
%     {'SVdiff'                  }            1.2998    0.044564      29.166    37206    6.3675e-185        1.2124      1.3871
%     {'TrialType'               }         -0.052301    0.039267     -1.3319    37206        0.18289      -0.12927    0.024664
%     {'Dataset'                 }        -0.0054729    0.022991    -0.23805    37206        0.81184     -0.050535    0.039589
%     {'SVdiff:TrialType'        }          0.057209    0.027056      2.1144    37206       0.034485     0.0041775     0.11024
%     {'SVdiff:Dataset'          }         -0.047457    0.044564     -1.0649    37206        0.28692       -0.1348    0.039889
%     {'TrialType:Dataset'       }          0.011116    0.039267     0.28309    37206        0.77711     -0.065849    0.088081
%     {'SVdiff:TrialType:Dataset'}          0.013867    0.027056     0.51253    37206        0.60828     -0.039164    0.066898

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

    glme=fitglme(EyeTracking_Stats_dataset, 'followingFix_sam ~ Dataset*disruptedRating + (Dataset*disruptedRating|SubjList)','Distribution','binomial','Link','logit')
%     Name                               Estimate    SE          tStat      DF      pValue         Lower      Upper  
%     {'(Intercept)'            }        -1.5264     0.060135    -25.383    6293    2.0782e-135    -1.6443    -1.4085
%     {'disruptedRating'        }        0.56683     0.041288     13.729    6293     2.7742e-42    0.48589    0.64776
%     {'Dataset'                }        0.53072     0.060135     8.8254    6293     1.3939e-18    0.41283     0.6486
%     {'disruptedRating:Dataset'}        0.18515     0.041288     4.4843    6293     7.4438e-06    0.10421    0.26609

% Demonstrating that this effect holds, even when in the
% Partial-Information Distraction condition
    glme=fitglme(EyeTracking_Stats_dataset(EyeTracking_Stats_dataset.Dataset==-1,:), 'followingFix_sam ~ disruptedRating + (disruptedRating|SubjList)','Distribution','binomial','Link','logit')
%     Name                       Estimate    SE          tStat      DF      pValue         Lower      Upper  
%     {'(Intercept)'    }        -2.0571     0.083265    -24.706    4732    7.4333e-127    -2.2204    -1.8939
%     {'disruptedRating'}        0.38167     0.048504     7.8689    4732     4.4031e-15    0.28658    0.47677

figure
hold on
errorbar(-2:2,nanmean(Set1.Analysis_full.Plotting.postDistFix),nanstd(Set1.Analysis_full.Plotting.postDistFix)/sqrt(50),'color','red','marker','.','markersize',20,'linewidth',2,'color','r')
errorbar(-2:2,nanmean(Set2.Analysis_full.Plotting.postDistFix),nanstd(Set2.Analysis_full.Plotting.postDistFix)/sqrt(50),'color','magenta','marker','.','markersize',20,'linewidth',2,'color','m')
xlim([-2.05 2.05])
hold off
ylim([0 1])
print('-depsc2','-painters','-loose','Figure3.eps')





%% What happens to the relationship between first fixation to choices (Figure 4a)
    glme=fitglme(firstFix_dataset, 'firstFix_choiceBias ~ Dataset*trialType+(Dataset*trialType|SubjList)','Distribution','binomial','Link','logit')
%     Name                         Estimate     SE          tStat      DF       pValue       Lower       Upper     
%     {'(Intercept)'      }         0.077259     0.01354     5.7059    36205    1.166e-08     0.05072        0.1038
%     {'trialType'        }        -0.052692    0.027016    -1.9504    36205     0.051139    -0.10565    0.00026073
%     {'Dataset'          }        0.0027593     0.01354    0.20379    36205      0.83852    -0.02378      0.029298
%     {'trialType:Dataset'}        -0.049484    0.027016    -1.8316    36205     0.067013    -0.10244     0.0034686



%% What is the relationship between post-distraction fixations and choices (Figure 4b)
    glme=fitglme(postDistFix_dataset, 'selectedSecondFix ~ Dataset*followingFix_sam*disruptedRating + (Dataset*followingFix_sam*disruptedRating|SubjList)','Distribution','binomial','Link','logit')
%     Name                                                Estimate      SE          tStat        DF      pValue        Lower        Upper    
%     {'(Intercept)'                             }           0.7866    0.064932      12.114    6289    2.0874e-33      0.65931      0.91389
%     {'followingFix_sam'                        }          0.41211    0.074673      5.5189    6289    3.5472e-08      0.26573       0.5585
%     {'disruptedRating'                         }         0.023982    0.044652     0.53708    6289       0.59123    -0.063551      0.11151
%     {'Dataset'                                 }          0.43095    0.064932       6.637    6289    3.4688e-11      0.30366      0.55824
%     {'followingFix_sam:disruptedRating'        }          0.95838    0.049503       19.36    6289    3.7072e-81      0.86134       1.0554
%     {'followingFix_sam:Dataset'                }        -0.031782    0.074673    -0.42562    6289        0.6704     -0.17817       0.1146
%     {'disruptedRating:Dataset'                 }         0.001826    0.044652    0.040894    6289       0.96738    -0.085706     0.089358
%     {'followingFix_sam:disruptedRating:Dataset'}         -0.16171    0.049503     -3.2668    6289     0.0010936     -0.25876    -0.064672



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

    
