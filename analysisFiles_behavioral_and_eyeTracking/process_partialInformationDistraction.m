%% Behavioral Processing Pipeline for Eyetracking + Distraction study
% Author: Matthew D. Bachman.
% This script processes data when participants were distracted on their
% FIRST fixation.

%% This script handles all of the data processing for this sample. 
%% It also exports the data into a format that is usable for the computational models at the end.


% Clear prior variables and set pathways
clear
cd S:\Projects\Bachman\EyetrackingDistraction\version1_firstFixation\analysis
addpath S:\Projects\Bachman\EyetrackingDistraction\version1_firstFixation\data\processed
addpath S:\Projects\Bachman\EyetrackingDistraction\version1_firstFixation\data\raw

% List of subjects. Subjects that were dropped from the final sample
% are commented out with a reason.
subnames ={
    '1',
    '2',
    '3', 
    '4', 
    '5',
    '6',
    '7',
    '8', 
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
 %   '18', %Food Allergy
    '19',
    '20',
    '21',
    '22',
    '23',
    '24',
    '25',
 %   '26', % >.25% trials removed from artifact tagging
    '27',
    '28', 
    '29', 
    '30',
 %   '31', % >.25% trials removed from artifact tagging
    '32',
 %   '33', %Food Allergy
    '34',
  %  '35',  % >.25% trials removed from artifact tagging
    '36',
    '37',
    '38',
    '39',
 %   '40', %Food Allergy
    '41',
    '42', 
    '43',
    '44', 
    '45',
    '46',
    '47',
 %   '48',  % >.25% trials removed from artifact tagging
    '49',
    '50',
    '51',
    '52',
    '53',
    '54',
    '55',   
    '56',
    '57'
    };

%% Preallocate empty matrices for analysis variables
% "Analysis_full" is reserved for the full sample. The subfields dictate
% whether they are used for Behavioral or Eyetracking analyses.
Analysis_full.subname = [];
Analysis_full.Behavior.ratings = [];Analysis_full.Behavior.ratings_full = [];Analysis_full.Behavior.ratings_no_distractor = [];Analysis_full.Behavior.ratings_distractor = [];
Analysis_full.Behavior.distractor_trials = [];
Analysis_full.Behavior.choice = [];Analysis_full.Behavior.choice_no_distractor = [];Analysis_full.Behavior.choice_distractor = [];
Analysis_full.Behavior.RT = [];Analysis_full.Behavior.RT_no_distractor = [];Analysis_full.Behavior.RT_distractor = [];
 Analysis_full.EyeTracking.firstFix = [];
Analysis_full.EyeTracking.perjrej =[];
Analysis_full.EyeTracking.followingFix_sam_all = []; Analysis_full.EyeTracking.followingFix_sam_choice = [];
Analysis_full.EyeTracking.firstFix_choiceBias = []; Analysis_full.Plotting.firstFix_choiceBias_distractor = [];Analysis_full.Plotting.firstFix_choiceBias_no_distractor = [];
Analysis_full.EyeTracking.fixation_locations = []; 
Analysis_full.EyeTracking.fixation_durations = []; 
Analysis_full.EyeTracking.propDistFix = [];
Analysis_full.EyeTracking.test_subjs = [];
Analysis_full.EyeTracking.followingFix_sam_SubjList = [];
Analysis_full.EyeTracking.distractor_trials_firstFixRating = [];
Analysis_full.EyeTracking.distractorOn = [];
Analysis_full.EyeTracking.fixation_trialtype = [];
Analysis_full.EyeTracking.fixation_subnum    = [];
Analysis_full.EyeTracking.fixation_trial     = [];
Analysis_full.EyeTracking.fixation_firstfixDelay     = [];
Analysis_full.EyeTracking.fixation_ratings     = [];
Analysis_full.EyeTracking.distractor_start = [];
Analysis_full.EyeTracking.distractor_end = [];

% Begin processing participants
for current_subname = 1:length(subnames);
    % Load data
    load(['S:\Projects\Bachman\EyetrackingDistraction\version1_firstFixation\data\raw\s',subnames{current_subname},'Results.mat']);
    disp(['Loaded current subject: ', subnames{current_subname}]);
    
    % Extract rating information
    data.analysis.behavior.ratings_in_order = [data.rate.ind,data.rate.wanting];
    data.analysis.behavior.ratings = zeros(405,3);
    for side = 1:2
        for current_trial = 1:data.binary.nTrials
            current_food = data.binary.trials(current_trial,side); 
            data.analysis.behavior.ratings(current_trial,side) = data.analysis.behavior.ratings_in_order(current_food,2);
        end
    end

    % Calculate the difference between the left and right option.
    data.analysis.behavior.ratings(:,3) = data.analysis.behavior.ratings(:,1) - data.analysis.behavior.ratings(:,2);
   
    % Extract RT
    data.analysis.behavior.RT= data.binary.RT;   
    
    % Extract choice data and convert to usable data.
    data.analysis.behavior.choice = data.binary.choice;

    % Some of the keyboard inputs for choices came out weird - this ensures
    % consistent formatting
    for choice_check = 1:length(data.analysis.behavior.choice)
       if sum((strcmp(data.analysis.behavior.choice{choice_check},'1!')|strcmp(data.analysis.behavior.choice{choice_check},'0)'))+10)~=10,
       clear checking_bad_trial
        for checking_bad_trial = 1:length(data.analysis.behavior.choice{choice_check})
            if checking_bad_trial > length(data.analysis.behavior.choice{choice_check})
            elseif ismember(data.analysis.behavior.choice{choice_check}(checking_bad_trial),{'1!'})
               data.analysis.behavior.choice{choice_check} = '1!';
            elseif ismember(data.analysis.behavior.choice{choice_check}(checking_bad_trial),{'0)'})
               data.analysis.behavior.choice{choice_check} = '0)';
            else
            end
        end
        else
      end
    end
    
    % Convert distractor trials into a more usable format. 
    data.analysis.behavior.distractor_trials = zeros(length(data.binary.RT),1);
    for fix = 1:length(data.analysis.behavior.distractor_trials)
        if ismember(fix,data.distractor_trials)
            data.analysis.behavior.distractor_trials(fix) = 1;
        end
    end   
    
    % Grab key eyetracking variables
    data.eyetracking.screen_height = data.height;
    data.eyetracking.screen_width = data.width;
    data.eyetracking.left_food_location = data.binary.leftFoodLoc;
    data.eyetracking.right_food_location = data.binary.rightFoodLoc;
    data.eyetracking.distractor_location = data.binary.distractorLoc;
    data.analysis.timeStamp.stimOn = data.binary.timeStamp.stimOn;
    data.analysis.timeStamp.distractorOn = data.binary.timeStamp.distractorOn; 
    for i = 1:size(gazeData.left,2)
        if ismember(i,data.distractor_trials)
            data.eyetracking.gaze.raw.left{i} = [gazeData.left_distInit{i};gazeData.left{i}];
            data.eyetracking.gaze.raw.right{i} = [gazeData.right_distInit{i};gazeData.right{i}];
            data.eyetracking.timestamp{i} = [gazeData.timestamp_distInit{i};gazeData.timestamp{i}];
        else
            data.eyetracking.gaze.raw.left{i} = gazeData.left{i};
            data.eyetracking.gaze.raw.right{i} = gazeData.right{i};
            data.eyetracking.timestamp{i} = gazeData.timestamp{i};
        end
    end            
   
    
    % Marks empty trials for removal in the ratings dataset. A little convoluted, but works
    empty_trials = [];
    for i = 1:(data.binary.nTrials)
        if isequal(data.binary.choice(i),{[]}) || isempty(data.binary.choice(i))
            empty_trials = [empty_trials;i];
        else
        end
    end
    
    % Removes trials with no responses
    data.analysis.behavior.ratings(empty_trials,:) = [];        
    data.analysis.behavior.choice = data.analysis.behavior.choice(~cellfun('isempty',data.binary.choice));
    data.analysis.behavior.RT = data.analysis.behavior.RT(~cellfun('isempty',data.binary.choice));
    data.analysis.behavior.distractor_trials = data.analysis.behavior.distractor_trials(~cellfun('isempty',data.binary.choice));
    data.eyetracking.gaze.raw.left = data.eyetracking.gaze.raw.left(~cellfun('isempty',data.binary.choice));
    data.eyetracking.gaze.raw.right = data.eyetracking.gaze.raw.right(~cellfun('isempty',data.binary.choice));
    data.eyetracking.timestamp = data.eyetracking.timestamp(~cellfun('isempty',data.binary.choice));
    data.analysis.timeStamp.stimOn = data.analysis.timeStamp.stimOn(~cellfun('isempty',data.binary.choice));
    data.analysis.timeStamp.distractorOn = data.analysis.timeStamp.distractorOn(~cellfun('isempty',data.binary.choice));
    
    % Removes trials with responses under 200ms    
    fast_trials = find(data.analysis.behavior.RT<.02);
    if ~isempty(fast_trials)
        data.analysis.behavior.ratings(fast_trials,:) = [];        
        data.analysis.behavior.choice(fast_trials,:) = [];        
        data.analysis.behavior.distractor_trials(fast_trials,:) = [];      
        data.eyetracking.gaze.raw.left(fast_trials) = [];        
        data.eyetracking.gaze.raw.right(fast_trials) = [];    
        data.eyetracking.timestamp(fast_trials) = [];    
        data.analysis.timeStamp.stimOn(fast_trials) = []; 
        data.analysis.timeStamp.distractorOn(fast_trials) = []; 
        data.analysis.behavior.RT(fast_trials,:) = [];        
    end

    % Remove errant trials with too slow responses
    slow_trials = find(data.analysis.behavior.RT>4.4);
    if ~isempty(slow_trials)
        data.analysis.behavior.ratings(slow_trials,:) = [];        
        data.analysis.behavior.choice(slow_trials,:) = [];        
        data.analysis.behavior.distractor_trials(slow_trials,:) = [];      
        data.eyetracking.gaze.raw.left(slow_trials) = [];        
        data.eyetracking.gaze.raw.right(slow_trials) = [];    
        data.eyetracking.timestamp(slow_trials) = [];    
        data.analysis.timeStamp.stimOn(slow_trials) = []; 
        data.analysis.timeStamp.distractorOn(slow_trials) = []; 
        data.analysis.behavior.RT(slow_trials,:) = [];        
    end    

  % remove distractor trials that weren't triggered 
   data.eyetracking.distractorOn = data.analysis.timeStamp.distractorOn- data.analysis.timeStamp.stimOn;
    if sum(isnan(data.eyetracking.distractorOn))>0
        data.analysis.behavior.ratings(isnan(data.eyetracking.distractorOn),:) = [];        
        data.analysis.behavior.choice(isnan(data.eyetracking.distractorOn),:) = [];        
        data.analysis.behavior.RT(isnan(data.eyetracking.distractorOn),:) = [];        
        data.analysis.behavior.distractor_trials(isnan(data.eyetracking.distractorOn),:) = [];      
        data.eyetracking.gaze.raw.left(isnan(data.eyetracking.distractorOn)) = [];        
        data.eyetracking.gaze.raw.right(isnan(data.eyetracking.distractorOn)) = [];    
        data.eyetracking.timestamp(isnan(data.eyetracking.distractorOn)) = [];    
        data.analysis.timeStamp.stimOn(isnan(data.eyetracking.distractorOn)) = []; 
        data.analysis.timeStamp.distractorOn(isnan(data.eyetracking.distractorOn)) = []; 
    end 
   
    % Final transformation for choice data.
    data.analysis.behavior.choice = cell2mat(data.analysis.behavior.choice);
    data.analysis.behavior.choice = str2num(data.analysis.behavior.choice(:,1));
    
    % Delineate the trials by distractors/no distractors, just for
    % organization.
    data.analysis.behavior.choice_distractor = data.analysis.behavior.choice(data.analysis.behavior.distractor_trials==1);
    data.analysis.behavior.RT_distractor = data.analysis.behavior.RT(data.analysis.behavior.distractor_trials==1);
    data.analysis.behavior.ratings_distractor = data.analysis.behavior.ratings((data.analysis.behavior.distractor_trials==1),:);
    
    data.analysis.behavior.choice_no_distractor = data.analysis.behavior.choice(data.analysis.behavior.distractor_trials==0);
    data.analysis.behavior.RT_no_distractor = data.analysis.behavior.RT(data.analysis.behavior.distractor_trials==0);
    data.analysis.behavior.ratings_no_distractor = data.analysis.behavior.ratings((data.analysis.behavior.distractor_trials==0),:);                 
   
   
  %% Collate behavioral data
  Analysis_full.subname = [Analysis_full.subname;repmat(current_subname,length(data.analysis.behavior.RT),1)];
  Analysis_full.Behavior.ratings_full = [Analysis_full.Behavior.ratings_full;data.analysis.behavior.ratings];
  Analysis_full.Behavior.ratings = [Analysis_full.Behavior.ratings;data.analysis.behavior.ratings(:,3)];
  Analysis_full.Behavior.ratings_no_distractor = [Analysis_full.Behavior.ratings_no_distractor;data.analysis.behavior.ratings_no_distractor(:,3)];
  Analysis_full.Behavior.ratings_distractor = [Analysis_full.Behavior.ratings_distractor;data.analysis.behavior.ratings_distractor(:,3)];
  Analysis_full.Behavior.choice = [Analysis_full.Behavior.choice;data.analysis.behavior.choice];
  Analysis_full.Behavior.choice_no_distractor = [Analysis_full.Behavior.choice_no_distractor;data.analysis.behavior.choice_no_distractor];
  Analysis_full.Behavior.choice_distractor = [Analysis_full.Behavior.choice_distractor;data.analysis.behavior.choice_distractor];
  Analysis_full.Behavior.distractor_trials = [Analysis_full.Behavior.distractor_trials;data.analysis.behavior.distractor_trials];
  Analysis_full.Behavior.RT = [Analysis_full.Behavior.RT;data.analysis.behavior.RT];
  Analysis_full.Behavior.RT_no_distractor = [Analysis_full.Behavior.RT_no_distractor;data.analysis.behavior.RT_no_distractor];
  Analysis_full.Behavior.RT_distractor = [Analysis_full.Behavior.RT_distractor;data.analysis.behavior.RT_distractor];

  
  %% EyeTracking Analyses
  % Allocate empty variable matrices.
  data.eyetracking.gaze.firstFix = zeros(length(data.analysis.behavior.RT),1);
  data.eyetracking.gaze.firstFixDelay = zeros(length(data.analysis.behavior.RT),1);
  data.eyetracking.gaze.followingFix_loc = [];
  data.eyetracking.gaze.followingFix_sam = [];
  data.eyetracking.gaze.followingFix_sam_choice = [];
  data.eyetracking.gaze.firstFix_choiceBias = NaN(length(data.analysis.behavior.RT),1);
  data.eyetracking.distFixDelay = [];
  data.eyetracking.gaze.followingFix_ratings = [];
  data.eyetracking.distractor_ratings = [];


  % Process eye-tracking data for each trial.
  for trial = 1:length(data.analysis.behavior.RT)
      % Creates average between left and right eye
      data.eyetracking.gaze.x{trial} = mean([((data.eyetracking.gaze.raw.left{trial}(:,7))),((data.eyetracking.gaze.raw.right{trial}(:,7)))],2);
      data.eyetracking.gaze.y{trial} = mean([((data.eyetracking.gaze.raw.left{trial}(:,8))),((data.eyetracking.gaze.raw.right{trial}(:,8)))],2);
      
      % Converts missing data to NaN
      data.eyetracking.gaze.x{trial}(data.eyetracking.gaze.x{trial} == -1) = NaN;
      data.eyetracking.gaze.y{trial}(data.eyetracking.gaze.y{trial} == -1) = NaN;
      
      % Converts to relative position (original data format) to pixels.
      data.eyetracking.gaze.x{trial} = data.eyetracking.gaze.x{trial} * data.eyetracking.screen_width;
      data.eyetracking.gaze.y{trial} = data.eyetracking.gaze.y{trial} * data.eyetracking.screen_height; 
      
      % calculates gaze location
      data.eyetracking.gaze.loc{trial} = zeros(length(data.eyetracking.gaze.x{trial}),1);
      for gaze_loc = 1:length(data.eyetracking.gaze.x{trial});
          if data.eyetracking.gaze.x{trial}(gaze_loc) > data.eyetracking.left_food_location(1) && data.eyetracking.gaze.x{trial}(gaze_loc) < data.eyetracking.left_food_location(3) && data.eyetracking.gaze.y{trial}(gaze_loc) > data.eyetracking.left_food_location(2) && data.eyetracking.gaze.y{trial}(gaze_loc) < data.eyetracking.left_food_location(4)
              data.eyetracking.gaze.loc{trial}(gaze_loc) = 2;
          elseif data.eyetracking.gaze.x{trial}(gaze_loc) > data.eyetracking.right_food_location(1) && data.eyetracking.gaze.x{trial}(gaze_loc) < data.eyetracking.right_food_location(3) && data.eyetracking.gaze.y{trial}(gaze_loc) > data.eyetracking.right_food_location(2) && data.eyetracking.gaze.y{trial}(gaze_loc) < data.eyetracking.right_food_location(4)
              data.eyetracking.gaze.loc{trial}(gaze_loc) = 3;
          elseif data.eyetracking.gaze.x{trial}(gaze_loc) > data.eyetracking.distractor_location(1) && data.eyetracking.gaze.x{trial}(gaze_loc) < data.eyetracking.distractor_location(3) && data.eyetracking.gaze.y{trial}(gaze_loc) > data.eyetracking.distractor_location(2) && data.eyetracking.gaze.y{trial}(gaze_loc) < data.eyetracking.distractor_location(4)
              data.eyetracking.gaze.loc{trial}(gaze_loc) = 1;
          end      
      end

      % Find the first fixation
      first_movement = find(data.eyetracking.gaze.loc{trial}(:) > 1,1,'first' );
      if ~isempty(first_movement)
        data.eyetracking.gaze.firstFix(trial) = data.eyetracking.gaze.loc{trial}(first_movement); 
        data.eyetracking.gaze.firstFixDelay(trial) = (double(data.eyetracking.timestamp{trial}(first_movement) - data.eyetracking.timestamp{trial}(1)))/1000000;
      else 
        data.eyetracking.gaze.firstFix(trial) = NaN; 
        data.eyetracking.gaze.firstFixDelay(trial) = NaN;
      end
     
      % Calculates the number of trials that had to be dropped. 
      data.eyetracking.gaze.droptrials = isnan(data.eyetracking.gaze.firstFix);
      data.eyetracking.perjrej = 1 - ((length(data.eyetracking.gaze.firstFix)-sum(isnan(data.eyetracking.gaze.firstFix)))/length(data.eyetracking.gaze.firstFix));    
      
     % Interpolate some location values (to account for blinks).
    changePoints = diff(data.eyetracking.gaze.loc{trial})~=0;
    changePoints = find(changePoints);
    changePoints = [changePoints;length(data.eyetracking.gaze.loc{trial})];
    fixDurs = []; 
    for i = 1:length(changePoints)
        if i == 1
           fixDurs = [(data.eyetracking.timestamp{trial}(changePoints(1)) - data.eyetracking.timestamp{trial}(1))/1000];
        elseif i == length(changePoints)
            fixDurs = [fixDurs;(data.eyetracking.timestamp{trial}(end) - data.eyetracking.timestamp{trial}(changePoints(end-1)))/1000];
        else
            fixDurs = [fixDurs;(data.eyetracking.timestamp{trial}(changePoints(i)) - data.eyetracking.timestamp{trial}(changePoints(i-1)))/1000];
        end
    end    
    for blink = 1:length(changePoints)-2
        if data.eyetracking.gaze.loc{trial}(changePoints(blink)) > 0 & data.eyetracking.gaze.loc{trial}(changePoints(blink)) == data.eyetracking.gaze.loc{trial}(changePoints(blink+2)) && fixDurs(blink+1) < 500 && all(isnan(data.eyetracking.gaze.x{trial}(changePoints(blink)+1:changePoints(blink+1))))
            for i = changePoints(blink):changePoints(blink+2)
                data.eyetracking.gaze.loc{trial}(i) = data.eyetracking.gaze.loc{trial}(changePoints(blink));
            end;
        end
    end
             
        % Start calculating distractor info
      if data.analysis.behavior.distractor_trials(trial) == 1 && ~isnan(data.eyetracking.gaze.firstFix(trial))  && ~isnan(data.analysis.timeStamp.distractorOn(trial)) 
          % What was the rating of the first fixated item?
          if data.eyetracking.gaze.firstFix(trial) == 2
            data.eyetracking.distractor_ratings = [data.eyetracking.distractor_ratings;data.analysis.behavior.ratings(trial,1)];
          elseif data.eyetracking.gaze.firstFix(trial) == 3
            data.eyetracking.distractor_ratings = [data.eyetracking.distractor_ratings;data.analysis.behavior.ratings(trial,2)]
          end
         Analysis_full.EyeTracking.followingFix_sam_SubjList = [Analysis_full.EyeTracking.followingFix_sam_SubjList;current_subname];             
          distractor_start = data.analysis.timeStamp.distractorOn(trial) - data.analysis.timeStamp.stimOn(trial); 
          distractor_end = distractor_start + .4;
          
          % Mark the start and end of each distractor.
          distractor_start_gazedata = 1;
          for find_new_start = 1:length(data.eyetracking.timestamp{trial})
          current_difference = (double(data.eyetracking.timestamp{trial}(find_new_start) - data.eyetracking.timestamp{trial}(1)))/1000000;
            if current_difference > distractor_start
                distractor_start_gazedata = find_new_start;
                break
            end
          end          
          distractor_end_gazedata = 1;
          for find_new_start = 1:length(data.eyetracking.timestamp{trial})
          current_difference = (double(data.eyetracking.timestamp{trial}(find_new_start) - data.eyetracking.timestamp{trial}(1)))/1000000;
            if current_difference > distractor_end
                distractor_end_gazedata = find_new_start;
                break
            end
          end          
         

          % Recode fixations in the middle during the distraction as being
          % on the distractor.
          for recode_gaze_loc = distractor_start_gazedata:distractor_end_gazedata
              if data.eyetracking.gaze.loc{trial}(recode_gaze_loc)==1
                data.eyetracking.gaze.loc{trial}(recode_gaze_loc) = 4;
              end
          end;           
          clear i;
         if  ~isnan(find(data.eyetracking.gaze.loc{trial}(:)>=  4,1,'first'))
              first_dist_look = find(data.eyetracking.gaze.loc{trial}(:)>=  4,1,'first');
              dist_look_timestamp = double(data.eyetracking.timestamp{trial}(first_dist_look) - data.eyetracking.timestamp{trial}(1))/1000000;
              dist_start_timestamp = data.analysis.timeStamp.distractorOn(trial) - data.analysis.timeStamp.stimOn(trial);
              data.eyetracking.distFixDelay = [data.eyetracking.distFixDelay;dist_look_timestamp-dist_start_timestamp];              
          else
              data.eyetracking.distFixDelay = [data.eyetracking.distFixDelay;NaN];
         end 

          % Calcaulating where people look AFTER the distractor.
          i = length(data.eyetracking.timestamp{trial});
           if ~isempty(find(data.eyetracking.gaze.loc{trial}(:)>=  4,1,'last' ))
               find_following_fix_start_point = find(data.eyetracking.gaze.loc{trial}(:)>=  4,1,'last');
               for i = find_following_fix_start_point:length(data.eyetracking.timestamp{trial})
                   if data.eyetracking.gaze.loc{trial}(i)< 4 && data.eyetracking.gaze.loc{trial}(i) > 1
                    data.eyetracking.gaze.followingFix_loc = [data.eyetracking.gaze.followingFix_loc;data.eyetracking.gaze.loc{trial}(i)];
                    break
                   end
               end
           end
           
           % This just populates a few variables with NaNS in the event
           % that the trial is bad.           
           if isequal(i,length(data.eyetracking.timestamp{trial}))
               if any(isempty(find(data.eyetracking.gaze.loc{trial}(:)>=  4,1,'last' ))) || (data.eyetracking.gaze.loc{trial}(i) <= 1 || data.eyetracking.gaze.loc{trial}(i) >3)
                data.eyetracking.gaze.followingFix_loc = [data.eyetracking.gaze.followingFix_loc;NaN];
                data.eyetracking.gaze.followingFix_sam = [data.eyetracking.gaze.followingFix_sam;NaN];
                data.eyetracking.gaze.followingFix_sam_choice = [data.eyetracking.gaze.followingFix_sam_choice;NaN];
                data.eyetracking.gaze.followingFix_ratings = [data.eyetracking.gaze.followingFix_ratings;NaN];
                Analysis_full.EyeTracking.test_subjs = [Analysis_full.EyeTracking.test_subjs;current_subname];
               end
           end
           
         % Where do you look after the distractor?    
           % For this condition, sam = 0 if you return to the disrupted item 1 -> 1, or
           % 1 if you move to the next item. 1->0.
           if ~isnan(data.eyetracking.gaze.firstFix(trial)) && ~isnan(data.eyetracking.gaze.followingFix_loc(end)) && (data.eyetracking.gaze.firstFix(trial) ~= data.eyetracking.gaze.followingFix_loc(end))
                data.eyetracking.gaze.followingFix_sam = [data.eyetracking.gaze.followingFix_sam;0];
                data.eyetracking.gaze.followingFix_sam_choice = [data.eyetracking.gaze.followingFix_sam_choice;data.analysis.behavior.choice(trial)];
                data.eyetracking.gaze.followingFix_ratings = [data.eyetracking.gaze.followingFix_ratings;data.analysis.behavior.ratings(trial,3)];
           elseif ~isnan(data.eyetracking.gaze.firstFix(trial)) && ~isnan(data.eyetracking.gaze.followingFix_loc(end)) && (data.eyetracking.gaze.firstFix(trial) == data.eyetracking.gaze.followingFix_loc(end))
                data.eyetracking.gaze.followingFix_sam = [data.eyetracking.gaze.followingFix_sam;1];
                data.eyetracking.gaze.followingFix_sam_choice = [data.eyetracking.gaze.followingFix_sam_choice;data.analysis.behavior.choice(trial)];
                data.eyetracking.gaze.followingFix_ratings = [data.eyetracking.gaze.followingFix_ratings;data.analysis.behavior.ratings(trial,3)];
           end   
      end;

    % Calculate fixation information
    changePoints = diff(data.eyetracking.gaze.loc{trial})~=0;
    changePoints = find(changePoints);
    changePoints = [changePoints;length(data.eyetracking.gaze.loc{trial})];
    fixDurs = [];
    for i = 1:length(changePoints)
        if i == 1
           fixDurs = [(data.eyetracking.timestamp{trial}(changePoints(1)) - data.eyetracking.timestamp{trial}(1))/1000];
        elseif i == length(changePoints)
            fixDurs = [fixDurs;(data.eyetracking.timestamp{trial}(end) - data.eyetracking.timestamp{trial}(changePoints(end-1)))/1000];
        else
            fixDurs = [fixDurs;(data.eyetracking.timestamp{trial}(changePoints(i)) - data.eyetracking.timestamp{trial}(changePoints(i-1)))/1000];
        end
    end
    data.eyetracking.gaze.fixation_locations{trial} = data.eyetracking.gaze.loc{trial}(changePoints);
    data.eyetracking.gaze.fixation_durations{trial} = fixDurs;  
       
    % This information is primarily used for the aDDM
    Analysis_full.EyeTracking.fixation_locations       = [Analysis_full.EyeTracking.fixation_locations;data.eyetracking.gaze.fixation_locations{trial}];
    Analysis_full.EyeTracking.fixation_durations       = [Analysis_full.EyeTracking.fixation_durations;data.eyetracking.gaze.fixation_durations{trial}];
    Analysis_full.EyeTracking.fixation_trialtype = [Analysis_full.EyeTracking.fixation_trialtype;repmat(data.analysis.behavior.distractor_trials(trial),length(data.eyetracking.gaze.fixation_durations{trial}),1)];
    Analysis_full.EyeTracking.fixation_subnum    = [Analysis_full.EyeTracking.fixation_subnum;repmat(current_subname,length(data.eyetracking.gaze.fixation_durations{trial}),1)];
    Analysis_full.EyeTracking.fixation_trial     = [Analysis_full.EyeTracking.fixation_trial;repmat(trial,length(data.eyetracking.gaze.fixation_durations{trial}),1)];
    Analysis_full.EyeTracking.fixation_firstfixDelay     = [Analysis_full.EyeTracking.fixation_firstfixDelay;repmat(data.eyetracking.gaze.firstFixDelay(trial),length(data.eyetracking.gaze.fixation_durations{trial}),1)];
    Analysis_full.EyeTracking.fixation_ratings     = [Analysis_full.EyeTracking.fixation_ratings;repmat(data.analysis.behavior.ratings(trial,1:2),length(data.eyetracking.gaze.fixation_durations{trial}),1)];

    % Distractor start and end - necessary for the aDDM
    if data.analysis.behavior.distractor_trials(trial) == 0
        Analysis_full.EyeTracking.distractor_start = [Analysis_full.EyeTracking.distractor_start;repmat(0,length(data.eyetracking.gaze.fixation_durations{trial}),1)];
        Analysis_full.EyeTracking.distractor_end = [Analysis_full.EyeTracking.distractor_end;repmat(0,length(data.eyetracking.gaze.fixation_durations{trial}),1)];
    elseif  data.analysis.behavior.distractor_trials(trial) == 1
        Analysis_full.EyeTracking.distractor_start = [Analysis_full.EyeTracking.distractor_start;repmat(100,length(data.eyetracking.gaze.fixation_durations{trial}),1)];
        Analysis_full.EyeTracking.distractor_end = [Analysis_full.EyeTracking.distractor_end;repmat(400,length(data.eyetracking.gaze.fixation_durations{trial}),1)];
    end
     
      % Do people choose the first item they fixated on.
      if ~isnan(data.eyetracking.gaze.firstFix(trial)) & (data.eyetracking.gaze.firstFix(trial) == 2 && data.analysis.behavior.choice(trial) == 1 )| (data.eyetracking.gaze.firstFix(trial) == 3 && data.analysis.behavior.choice(trial)  == 0 );
          data.eyetracking.gaze.firstFix_choiceBias(trial) = 1;
      elseif ~isnan(data.eyetracking.gaze.firstFix(trial)) & (data.eyetracking.gaze.firstFix(trial) == 2 && data.analysis.behavior.choice(trial)  == 0 ) | (data.eyetracking.gaze.firstFix(trial) == 3 && data.analysis.behavior.choice(trial)  == 1 );
          data.eyetracking.gaze.firstFix_choiceBias(trial) = 0;
      end  
  end; % End of trial-level eyetracking p processing
  % Add all of this participant's eyetracking data to the overall matrix.
    Analysis_full.EyeTracking.firstFix = [Analysis_full.EyeTracking.firstFix;data.eyetracking.gaze.firstFix];
    Analysis_full.EyeTracking.firstFix_choiceBias = [Analysis_full.EyeTracking.firstFix_choiceBias;data.eyetracking.gaze.firstFix_choiceBias];
    Analysis_full.Plotting.firstFix_choiceBias_distractor = [Analysis_full.Plotting.firstFix_choiceBias_distractor;nanmean(data.eyetracking.gaze.firstFix_choiceBias(find(data.analysis.behavior.distractor_trials == 1)))];
    Analysis_full.Plotting.firstFix_choiceBias_no_distractor = [Analysis_full.Plotting.firstFix_choiceBias_no_distractor;nanmean(data.eyetracking.gaze.firstFix_choiceBias(find(data.analysis.behavior.distractor_trials == 0)))];
    Analysis_full.EyeTracking.perjrej = [Analysis_full.EyeTracking.perjrej;data.eyetracking.perjrej];
    Analysis_full.EyeTracking.followingFix_sam_all = [Analysis_full.EyeTracking.followingFix_sam_all;data.eyetracking.gaze.followingFix_sam];
    Analysis_full.EyeTracking.distractor_trials_firstFixRating = [Analysis_full.EyeTracking.distractor_trials_firstFixRating;data.eyetracking.distractor_ratings];
    Analysis_full.EyeTracking.followingFix_sam_choice = [Analysis_full.EyeTracking.followingFix_sam_choice;data.eyetracking.gaze.followingFix_sam_choice];
    Analysis_full.EyeTracking.propDistFix = [Analysis_full.EyeTracking.propDistFix;length(find(data.eyetracking.distFixDelay>0))/length(data.eyetracking.distFixDelay)];
    Analysis_full.EyeTracking.distractorOn = [Analysis_full.EyeTracking.distractorOn;data.analysis.timeStamp.distractorOn];
    close all
end


    % Mods to test RT differences from the duration of the distractor.
    Marked_Distractor_Trials = find(Analysis_full.Behavior.distractor_trials==1);
    Analysis_full.Behavior.RT_min400 = Analysis_full.Behavior.RT;
    Analysis_full.Behavior.RT_min400(Marked_Distractor_Trials) = Analysis_full.Behavior.RT_min400(Marked_Distractor_Trials) -.400;
    Analysis_full.EyeTracking.firstFix_test = (abs(Analysis_full.EyeTracking.firstFix - 3));

    % Getting some subject-level means, for later plotting
    Analysis_full.Plotting.choice_noDist = nan(50,9); Analysis_full.Plotting.choice_dist = nan(50,9);
    Analysis_full.Plotting.rt_noDist = nan(50,9); Analysis_full.Plotting.rt_dist = nan(50,9);
    Analysis_full.Plotting.postDistFix = zeros(50,5);
    for currSubj = 1:50
        binranges = -4:4;
        for currVal = 1:9
                    Analysis_full.Plotting.choice_noDist(currSubj,currVal) = nanmean(Analysis_full.Behavior.choice(Analysis_full.Behavior.ratings==binranges(currVal)&Analysis_full.Behavior.distractor_trials==0&Analysis_full.subname==currSubj));
                    Analysis_full.Plotting.choice_dist(currSubj,currVal) = nanmean(Analysis_full.Behavior.choice(Analysis_full.Behavior.ratings==binranges(currVal)&Analysis_full.Behavior.distractor_trials==1&Analysis_full.subname==currSubj));
                    Analysis_full.Plotting.rt_noDist(currSubj,currVal) = nanmean(Analysis_full.Behavior.RT_min400(Analysis_full.Behavior.ratings==binranges(currVal)&Analysis_full.Behavior.distractor_trials==0&Analysis_full.subname==currSubj));
                    Analysis_full.Plotting.rt_dist(currSubj,currVal) = nanmean(Analysis_full.Behavior.RT_min400(Analysis_full.Behavior.ratings==binranges(currVal)&Analysis_full.Behavior.distractor_trials==1&Analysis_full.subname==currSubj));
        end
        binranges = -2:2;
        for currVal = 1:5
            Analysis_full.Plotting.postDistFix(currSubj,currVal) = nanmean(Analysis_full.EyeTracking.followingFix_sam_all(Analysis_full.EyeTracking.distractor_trials_firstFixRating==binranges(currVal)&Analysis_full.EyeTracking.followingFix_sam_SubjList==currSubj));
        end
    end

    % Is where participants look after the distraction related to choice?
    Analysis_full.Plotting.followFix_toChoice_mean = [];
    distractionChoices = Analysis_full.Behavior.choice(Analysis_full.Behavior.distractor_trials==1);
    distractionFirstFix = Analysis_full.EyeTracking.firstFix(Analysis_full.Behavior.distractor_trials==1);
    Analysis_full.Behavior.followFix_toChoice_all = [];
    for currSubj = 1:50
        theseVars = Analysis_full.EyeTracking.followingFix_sam_all(Analysis_full.EyeTracking.followingFix_sam_SubjList==currSubj);
        theseChoices = distractionChoices(Analysis_full.EyeTracking.followingFix_sam_SubjList==currSubj);
        theseFirstFixes = distractionFirstFix(Analysis_full.EyeTracking.followingFix_sam_SubjList==currSubj);
        followFix_toChoice_thisSubj = [];
        for i = 1:length(theseVars)
            if isnan(theseVars(i)) || isnan(theseChoices(i) || isnan(theseFirstFixes(i)))
                followFix_toChoice_thisSubj = [followFix_toChoice_thisSubj;NaN];
            else
                if theseFirstFixes(i) == 2 && theseVars(i)==0 && theseChoices(i)==0 % left, then right and chose right
                    followFix_toChoice_thisSubj = [followFix_toChoice_thisSubj;1];
                elseif theseFirstFixes(i) == 3 && theseVars(i)==0 && theseChoices(i)==1 % right, then left and chose left.
                    followFix_toChoice_thisSubj = [followFix_toChoice_thisSubj;1];
                elseif theseFirstFixes(i) == 2 && theseVars(i)==1 && theseChoices(i)==1
                    followFix_toChoice_thisSubj = [followFix_toChoice_thisSubj;1];
                elseif theseFirstFixes(i) == 3 && theseVars(i)==1 && theseChoices(i)==0
                    followFix_toChoice_thisSubj = [followFix_toChoice_thisSubj;1];
                else
                    followFix_toChoice_thisSubj = [followFix_toChoice_thisSubj;0];
                end
            end    
        end
        Analysis_full.Plotting.followFix_toChoice_mean=[Analysis_full.Plotting.followFix_toChoice_mean;nanmean(followFix_toChoice_thisSubj)];
        Analysis_full.Behavior.followFix_toChoice_all = [Analysis_full.Behavior.followFix_toChoice_all;followFix_toChoice_thisSubj];
    end


    %% Save Data
    save('PartialInfoDistractor.mat', 'Analysis_full','-v7.3');



    %% Format DDM
    % No distractor trials
    DDM_nodist = nan(length(find(Analysis_full.Behavior.distractor_trials==0)),5);
    DDM_nodist(:,4) = Analysis_full.Behavior.choice_no_distractor;
    DDM_nodist(DDM_nodist==0) = -1;    
    DDM_nodist(:,1) = Analysis_full.subname(find(Analysis_full.Behavior.distractor_trials==0));
    DDM_nodist(:,2) = Analysis_full.Behavior.ratings_full(find(Analysis_full.Behavior.distractor_trials==0),1)+3;
    DDM_nodist(:,3) = Analysis_full.Behavior.ratings_full(find(Analysis_full.Behavior.distractor_trials==0),2)+3;    
    DDM_nodist(:,5) = round(Analysis_full.Behavior.RT_no_distractor * 100);
    csvwrite('DDM_set1_nodist.csv',DDM_nodist);

    % Distractor trials
    Analysis_full.subname = Analysis_full.subname(find(Analysis_full.Behavior.distractor_trials==1));
    Analysis_full.subname(isnan(Analysis_full.EyeTracking.distractorOn)) = [];
    distractor_ratings = Analysis_full.Behavior.ratings_full(find(Analysis_full.Behavior.distractor_trials==1),:);
    distractor_ratings(isnan(Analysis_full.EyeTracking.distractorOn),:) = [];
    Analysis_full.Behavior.RT_distractor(isnan(Analysis_full.EyeTracking.distractorOn)) = [];
    Analysis_full.Behavior.choice_distractor(isnan(Analysis_full.EyeTracking.distractorOn)) = [];
    Analysis_full.EyeTracking.distractorOn(Analysis_full.EyeTracking.distractorOn==0)=[];
    Analysis_full.EyeTracking.distractorOn(isnan(Analysis_full.EyeTracking.distractorOn))=[];
    DDM_dist = nan(length(Analysis_full.subname),7);
    DDM_dist(:,1) = Analysis_full.subname;
    DDM_dist(:,2) = distractor_ratings(:,1)+3;
    DDM_dist(:,3) = distractor_ratings(:,2)+3; 
    DDM_dist(:,4) = Analysis_full.Behavior.choice_distractor;
    DDM_dist(DDM_dist==0) = -1; 
    DDM_dist(:,5) = round(Analysis_full.Behavior.RT_distractor * 100);
    DDM_dist(:,6) = round(Analysis_full.EyeTracking.distractorOn * 100);
    DDM_dist(:,7) = DDM_dist(:,6) + 40;
    csvwrite('DDM_set1_dist.csv',DDM_dist);


    %% Format aDDM
% columns:
% 1 - subj  
% 2 - probability of first fixation to the left/default (one unique value per participant
% 3 - trial number (1=first trial experienced)
% 4 - valOpt1 (one unique value per trial)
% 5 - valOpt2 (one unique value per trial)
% 6 - choice (one unique value per trial)
% 7 - response time in ms (one unique value per trial)
% 8 - delay before looking at any option (one unique value per trial)
% 9 - item fixated on (1=left/def, 2=right/alt, 0=transition/noAOI fixated on)
% 10 - length of gaze to AOI (or length of transition)
% 11 - total of nonfixation time this trial (one unique value per trial)
% 12 - trial type
% 13 distractor start
% 14 distractor end

aDDM = nan(length(Analysis_full.EyeTracking.fixation_locations),14);
aDDM(:,1) = Analysis_full.EyeTracking.fixation_subnum;
aDDM(:,3) = Analysis_full.EyeTracking.fixation_trial;
aDDM(:,4:5) = Analysis_full.EyeTracking.fixation_ratings;
aDDM(:,8) = Analysis_full.EyeTracking.fixation_firstfixDelay * 1000;
aDDM(:,9) = Analysis_full.EyeTracking.fixation_locations-1;
aDDM(find(aDDM(:,9)==-1),9)=0;
aDDM(:,10) = Analysis_full.EyeTracking.fixation_durations;
aDDM(:,12) = Analysis_full.EyeTracking.fixation_trialtype;
aDDM(:,13) =Analysis_full.EyeTracking.distractor_start;
aDDM(:,14) =Analysis_full.EyeTracking.distractor_end;

count = 1;
for curr_subnum = 1:50
    for curr_trialnum = 1:max(aDDM(aDDM(:,1)==curr_subnum,3))
        indices = find(aDDM(:,1)==curr_subnum & aDDM(:,3) == curr_trialnum);
        noGaze_indices = find(aDDM(:,1)==curr_subnum & aDDM(:,3) == curr_trialnum & aDDM(:,9) == 0);
        aDDM(indices,2) = 1 - nanmean(Analysis_full.EyeTracking.firstFix(Analysis_full.subname==curr_subnum)-2);
        aDDM(indices,6) = Analysis_full.Behavior.choice(count);
        aDDM(indices,7) = Analysis_full.Behavior.RT(count) * 1000;
        aDDM(indices,11) = nansum(Analysis_full.EyeTracking.fixation_durations(noGaze_indices));
        count = count + 1;
    end
end
aDDM(find(aDDM(:,6)==0),6)=-1;
aDDM(find(isnan(aDDM(:,8))),:) = [];
csvwrite('set1_addm.csv',aDDM)
