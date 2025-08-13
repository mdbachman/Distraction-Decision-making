%% Behavioral Processing Pipeline for Eyetracking + Distraction study
% Author: Matthew D. Bachman.
% This script analyses data when participants were distracted on their
% SECOND fixation.

%% This script handles all of the data processing, data analysis, and figure
%% plotting for this sample. It also exports the data into a format that is
%% usable for the computational models at the end.

% Clear prior variables and set pathways
clear
close all
cd S:\Projects\Bachman\EyetrackingDistraction\version2_secondFixation\analysis
addpath S:\Projects\Bachman\EyetrackingDistraction\version2_secondFixation\data\processed
addpath S:\Projects\Bachman\EyetrackingDistraction\version2_secondFixation\data\raw

% List of subjects. Subjects that were dropped from the final sample
% are commented out with a reason. Also lists how the % distractors
% triggered.
  subnames ={
    '92', % 0.63704
    '93', % 0.48889
    '94', % 0.85926
    '95', % 0.87407
    '96' % 0.67407
    % '97', % 0.14074 Barely any trials
    '98', % 0.4963
    '99',  %  0.39259
    '100', % 0.58519
    '101', % 0.60741
    '102', % 0.65926
    '103', % 0.56296
    '104', % 0.46667
    '105', % 0.52593
    '106', % 0.41481
    '107', % 0.88889
    '108', % 0.71111
    '109', % 0.81481
    '110', % 0.84444
    '111', % 0.68148
    '112', % 0.62963
    '113', % 0.36296 
    '114', % 0.62963
    '115', % 0.58519
    '116', % 0.53333
  %  '117', % 0.28148 Bad eyetracking
    '118', % 0.34815
    '119', % 0.88889 
    '120', % 0.63704
 %   '121', % 0.81481 Food Allergy (Fish)
 %   '122', 0.0074074 Barely any trials left
 %   '123', % 0.41481 Food Allergy
    '124', % 0.37037
    '125', % 0.74815 
    '126', % 0.67407 
    '127', % 0.68889
    '128', % 0.62222 
   % '129', % 0.31111  Bad eyetracking
    '130', % 0.65926
    '131', % 0.65185
    '132', % 0.51111
    '133', % 0.62222
    '134', % 0.41481
    '135', % 0.64444
    '136', % 0.42963
    '137', % 0.58519
  %  '138', % 0.11852 %Barely any trials left
  %  '139', Food Allergy (nuts and fish)
  %  '140', Food allergy
    '141', % 0.8
    '142', % 0.85926
    '143',  % .6
    '144', % 0.58519
    '145', % 0.84444
    '146',  % 0.57037
    '147', % 0.71852
 %   '148', % Deborah said to drop subject. Tech issues w/ tracker.
    '149',  % 0.46667
   % '150',  % No eyetracking data
    '151', % 0.59259
    '152', % 0.46667 
   % '153'  % Food allergy
    };

%% Preallocate empty matrices for analysis variables
% "Analysis_full" is reserved for the full sample. The subfields dictate
% whether they are used for Behavioral or Eyetracking analyses.
Analysis_full.binranges = [-4:4];
Analysis_full.subname = [];
Analysis_full.Behavior.ratings_full = [];
Analysis_full.Behavior.distractor_trials = [];
Analysis_full.Behavior.choice = [];
Analysis_full.Behavior.RT = [];
Analysis_full.Behavior.RT_adjusted = [];
Analysis_full.EyeTracking.firstFix = [];
Analysis_full.EyeTracking.perjrej =[];
Analysis_full.EyeTracking.followingFix_sam = [];
Analysis_full.EyeTracking.followingFix_sam_all = [];
Analysis_full.EyeTracking.fixation_locations = []; 
Analysis_full.EyeTracking.fixation_durations = []; 
Analysis_full.EyeTracking.propDistFix = [];
Analysis_full.EyeTracking.followingFix_sam_SubjList = [];
Analysis_full.EyeTracking.followingFix_returnRating = [];
Analysis_full.EyeTracking.firstFix_choiceBias = [];
Analysis_full.Behavior.dist_triggered = [];
Analysis_full.Behavior.distractor_onset = [];
Analysis_full.Behavior.distractor_end = []
Analysis_full.EyeTracking.fixation_trialtype = [];
Analysis_full.EyeTracking.fixation_subnum    = [];
Analysis_full.EyeTracking.fixation_trial     = [];
Analysis_full.EyeTracking.fixation_firstfixDelay     = [];
Analysis_full.EyeTracking.fixation_ratings     = [];
Analysis_full.EyeTracking.distractor_start = [];
Analysis_full.EyeTracking.distractor_end = [];   
Analysis_full.EyeTracking.preDistDur = [];
Analysis_full.EyeTracking.preDistFirstFixDur = [];
Analysis_full.EyeTracking.distLength = [];
Analysis_full.Plotting.firstFix_choiceBias_distractor = [];
Analysis_full.Plotting.firstFix_choiceBias_no_distractor = [];

% Begin processing
for current_subname = 1:length(subnames);
    % Load data
    load(['S:\Projects\Bachman\EyetrackingDistraction\version2_secondFixation\data\raw\s',subnames{current_subname},'Results.mat']);
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
    data.analysis.behavior.trialNum = [1:405]';
   
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
        if ismember(fix,data.distractor_trials) && data.binary.timeStamp.distractorOn(fix) > 0 %% changes distractor trials to only ones that worked
            data.analysis.behavior.distractor_trials(fix) = 1;
        elseif ismember(fix,data.distractor_trials) && isnan(data.binary.timeStamp.distractorOn(fix))
            data.analysis.behavior.distractor_trials(fix) = 2;
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
    data.analysis.behavior.distractor.onset = data.binary.distractor.onset;
    data.analysis.behavior.distractor.length = data.binary.distractor.length;
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
    data.analysis.behavior.distractor.onset = data.analysis.behavior.distractor.onset(~cellfun('isempty',data.binary.choice));
    data.analysis.behavior.distractor.length = data.analysis.behavior.distractor.length(~cellfun('isempty',data.binary.choice));
    data.analysis.behavior.trialNum = data.analysis.behavior.trialNum(~cellfun('isempty',data.binary.choice));

    
    % Removes trials with responses under 200ms    
    fast_trials = find(data.analysis.behavior.RT<.02);
    if ~isempty(fast_trials)
        data.analysis.behavior.ratings(fast_trials,:) = [];        
        data.analysis.behavior.choice(fast_trials,:) = [];        
        data.analysis.behavior.RT(fast_trials,:) = [];        
        data.analysis.behavior.distractor_trials(fast_trials,:) = [];      
        data.eyetracking.gaze.raw.left(fast_trials) = [];        
        data.eyetracking.gaze.raw.right(fast_trials) = [];    
        data.eyetracking.timestamp(fast_trials) = [];    
        data.analysis.timeStamp.stimOn(fast_trials) = []; 
        data.analysis.timeStamp.distractorOn(fast_trials) = []; 
        data.analysis.behavior.distractor.onset(fast_trials) = []; 
        data.analysis.behavior.distractor.length(fast_trials) = []; 
        data.analysis.behavior.trialNum(fast_trials) = []; 
    end

    % Remove errant trials with too slow responses
    slow_trials = find(data.analysis.behavior.RT>4.8);
    if ~isempty(slow_trials)
        data.analysis.behavior.ratings(slow_trials,:) = [];        
        data.analysis.behavior.choice(slow_trials,:) = [];        
        data.analysis.behavior.RT(slow_trials,:) = [];        
        data.analysis.behavior.distractor_trials(slow_trials,:) = [];     
        data.eyetracking.gaze.raw.left(slow_trials) = [];        
        data.eyetracking.gaze.raw.right(slow_trials) = [];    
        data.eyetracking.timestamp(slow_trials) = [];    
        data.analysis.timeStamp.stimOn(slow_trials) = []; 
        data.analysis.timeStamp.distractorOn(slow_trials) = []; 
        data.analysis.behavior.distractor.onset(slow_trials) = []; 
        data.analysis.behavior.distractor.length(slow_trials) = []; 
        data.analysis.behavior.trialNum(slow_trials) = []; 
    end     
    
    
    % Final transformation for choice data.
    data.analysis.behavior.choice = cell2mat(data.analysis.behavior.choice);
    data.analysis.behavior.choice = str2num(data.analysis.behavior.choice(:,1));
    
   
  %% Collate behavioral data
  Analysis_full.subname = [Analysis_full.subname;repmat(current_subname,length(data.analysis.behavior.RT),1)];
  Analysis_full.Behavior.ratings_full = [Analysis_full.Behavior.ratings_full;data.analysis.behavior.ratings];
  Analysis_full.Behavior.choice = [Analysis_full.Behavior.choice;data.analysis.behavior.choice];
  Analysis_full.Behavior.distractor_trials = [Analysis_full.Behavior.distractor_trials;data.analysis.behavior.distractor_trials];
  Analysis_full.Behavior.RT = [Analysis_full.Behavior.RT;data.analysis.behavior.RT];
  Analysis_full.Behavior.distractor_onset = [Analysis_full.Behavior.distractor_onset;(data.analysis.timeStamp.distractorOn(data.analysis.behavior.distractor_trials==1) - data.analysis.timeStamp.stimOn(data.analysis.behavior.distractor_trials==1))];
  Analysis_full.Behavior.distractor_end = [Analysis_full.Behavior.distractor_end;(data.analysis.timeStamp.distractorOn(data.analysis.behavior.distractor_trials==1) - data.analysis.timeStamp.stimOn(data.analysis.behavior.distractor_trials==1)) + data.analysis.behavior.distractor.length(data.analysis.behavior.distractor_trials==1)];

  % Checks that distractor trials were triggered (or not).
  data.analysis.behavor.dist_triggered = [];
  for jj = 1:135
      if isnan(data.binary.timeStamp.distractorOn(data.distractor_trials(jj)))
           data.analysis.behavor.dist_triggered = [data.analysis.behavor.dist_triggered,0]; 
      else
           data.analysis.behavor.dist_triggered = [data.analysis.behavor.dist_triggered,1]; 
      end
  end
  Analysis_full.Behavior.dist_triggered = [Analysis_full.Behavior.dist_triggered;data.analysis.behavor.dist_triggered];

  %% EyeTracking Analyses
  data.eyetracking.gaze.firstFix = zeros(length(data.analysis.behavior.RT),1);
  data.eyetracking.gaze.firstFixDur = NaN(length(data.analysis.behavior.RT),1);
  data.eyetracking.gaze.firstFixDelay = zeros(length(data.analysis.behavior.RT),1);
  data.eyetracking.gaze.followingFix_loc = [];
  data.eyetracking.gaze.followingFix_sam = [];
  data.eyetracking.gaze.firstFix_choiceBias = NaN(length(data.analysis.behavior.RT),1);
  data.eyetracking.distFixDelay = [];
  data.eyetracking.gaze.followingFix_ratings = [];
  data.eyetracking.distractor_ratings_second = [];
 
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

      % Calculates First Fixation info.
      first_movement = find(data.eyetracking.gaze.loc{trial}(:) > 1,1,'first' );
      if ~isempty(first_movement)
        data.eyetracking.gaze.firstFix(trial) = data.eyetracking.gaze.loc{trial}(first_movement); 
        data.eyetracking.gaze.firstFixDelay(trial) = (double(data.eyetracking.timestamp{trial}(first_movement) - data.eyetracking.timestamp{trial}(1)))/1000000;
      else 
        data.eyetracking.gaze.firstFix(trial) = NaN; 
        data.eyetracking.gaze.firstFixDelay(trial) = NaN;
      end
      data.eyetracking.firstFixDelay_nodistractor = nanmean((data.eyetracking.gaze.firstFixDelay(data.analysis.behavior.distractor_trials==0)));
      
     
      data.eyetracking.perjrej = 1 - ((length(data.eyetracking.gaze.firstFix)-sum(isnan(data.eyetracking.gaze.firstFix)))/length(data.eyetracking.gaze.firstFix));    
      
     % Interpolate some location values (to account for blinks).
    changePoints = diff(data.eyetracking.gaze.loc{trial})~=0;
    changePoints = find(changePoints);
    changePoints = [changePoints;length(data.eyetracking.gaze.loc{trial})];
    fixDurs = []; fixDurs_items = [];
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
       
        % Begins cycling through the distractor trials.
      if data.analysis.behavior.distractor_trials(trial) == 1 && ~isnan(data.eyetracking.gaze.firstFix(trial))  && ~isnan(data.analysis.timeStamp.distractorOn(trial)) 
          % What was the rating of the disrupted item?
          if data.eyetracking.gaze.firstFix(trial) == 2
            data.eyetracking.distractor_ratings_second = [data.eyetracking.distractor_ratings_second;data.analysis.behavior.ratings(trial,2)];
          elseif data.eyetracking.gaze.firstFix(trial) == 3
            data.eyetracking.distractor_ratings_second = [data.eyetracking.distractor_ratings_second;data.analysis.behavior.ratings(trial,1)];
          end                   
         Analysis_full.EyeTracking.followingFix_sam_SubjList = [Analysis_full.EyeTracking.followingFix_sam_SubjList;current_subname];

           % Mark the start and end of each distractor
          distractor_start = data.analysis.timeStamp.distractorOn(trial) - data.analysis.timeStamp.stimOn(trial); 
          distractor_end = distractor_start + data.analysis.behavior.distractor.length(trial);
          
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

          % Recodes the fixations in the middle of the screen during the
          % distraction as being on the distractor
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
                data.eyetracking.gaze.followingFix_ratings = [data.eyetracking.gaze.followingFix_ratings;NaN];
               end
           end
           
           % Second fix distractor specific. Thius is REVERSED coded from the previous version because it supposes that the second fix HAS to be diff
           % erent than the first one.
           % If they look at Item 1 -> Item 2 -> Distraction - > Item 1
           % Then this variable = 0.
           % If they look at Item 1 -> Item 2 -> Distraction - > Item 2
           % Then this variable is 1.           
           if ~isnan(data.eyetracking.gaze.firstFix(trial)) && ~isnan(data.eyetracking.gaze.followingFix_loc(end)) && (data.eyetracking.gaze.firstFix(trial) == data.eyetracking.gaze.followingFix_loc(end))
                data.eyetracking.gaze.followingFix_sam = [data.eyetracking.gaze.followingFix_sam;0];
                data.eyetracking.gaze.followingFix_ratings = [data.eyetracking.gaze.followingFix_ratings;data.analysis.behavior.ratings(trial,3)];
           elseif ~isnan(data.eyetracking.gaze.firstFix(trial)) && ~isnan(data.eyetracking.gaze.followingFix_loc(end)) && (data.eyetracking.gaze.firstFix(trial) ~= data.eyetracking.gaze.followingFix_loc(end))
                data.eyetracking.gaze.followingFix_sam = [data.eyetracking.gaze.followingFix_sam;1];
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
  
    % This information is primarily for the aDDMs.
    Analysis_full.EyeTracking.fixation_locations       = [Analysis_full.EyeTracking.fixation_locations;data.eyetracking.gaze.fixation_locations{trial}];
    Analysis_full.EyeTracking.fixation_durations       = [Analysis_full.EyeTracking.fixation_durations;data.eyetracking.gaze.fixation_durations{trial}];
    Analysis_full.EyeTracking.fixation_trialtype = [Analysis_full.EyeTracking.fixation_trialtype;repmat(data.analysis.behavior.distractor_trials(trial),length(data.eyetracking.gaze.fixation_durations{trial}),1)];
    Analysis_full.EyeTracking.fixation_subnum    = [Analysis_full.EyeTracking.fixation_subnum;repmat(current_subname,length(data.eyetracking.gaze.fixation_durations{trial}),1)];
    Analysis_full.EyeTracking.fixation_trial     = [Analysis_full.EyeTracking.fixation_trial;repmat(trial,length(data.eyetracking.gaze.fixation_durations{trial}),1)];
    Analysis_full.EyeTracking.fixation_firstfixDelay     = [Analysis_full.EyeTracking.fixation_firstfixDelay;repmat(data.eyetracking.gaze.firstFixDelay(trial),length(data.eyetracking.gaze.fixation_durations{trial}),1)];
    Analysis_full.EyeTracking.fixation_ratings     = [Analysis_full.EyeTracking.fixation_ratings;repmat(data.analysis.behavior.ratings(trial,1:2),length(data.eyetracking.gaze.fixation_durations{trial}),1)];
    % Distractor start and end - necesary for the aDDM.
    if data.analysis.behavior.distractor_trials(trial) == 0
        Analysis_full.EyeTracking.distractor_start = [Analysis_full.EyeTracking.distractor_start;repmat(0,length(data.eyetracking.gaze.fixation_durations{trial}),1)];
        Analysis_full.EyeTracking.distractor_end = [Analysis_full.EyeTracking.distractor_end;repmat(0,length(data.eyetracking.gaze.fixation_durations{trial}),1)];
    else
        Analysis_full.EyeTracking.distractor_start = [Analysis_full.EyeTracking.distractor_start;repmat(data.analysis.behavior.distractor.onset(trial),length(data.eyetracking.gaze.fixation_durations{trial}),1)];
        Analysis_full.EyeTracking.distractor_end = [Analysis_full.EyeTracking.distractor_end;repmat(data.analysis.behavior.distractor.length(trial),length(data.eyetracking.gaze.fixation_durations{trial}),1)];
    end
       
      % Calculate if people chose the first thing they looked at.
      if ~isnan(data.eyetracking.gaze.firstFix(trial)) & (data.eyetracking.gaze.firstFix(trial) == 2 && data.analysis.behavior.choice(trial) == 1 )| (data.eyetracking.gaze.firstFix(trial) == 3 && data.analysis.behavior.choice(trial)  == 0 );
        data.eyetracking.gaze.firstFix_choiceBias(trial) = 1;
      elseif ~isnan(data.eyetracking.gaze.firstFix(trial)) & (data.eyetracking.gaze.firstFix(trial) == 2 && data.analysis.behavior.choice(trial)  == 0 ) | (data.eyetracking.gaze.firstFix(trial) == 3 && data.analysis.behavior.choice(trial)  == 1 );
          data.eyetracking.gaze.firstFix_choiceBias(trial) = 0;
      end

   % Adjust RT for trials with a distractor
    if data.analysis.timeStamp.distractorOn(trial) > 0
        Analysis_full.Behavior.RT_adjusted = [Analysis_full.Behavior.RT_adjusted;data.analysis.behavior.RT(trial) - data.analysis.behavior.distractor.length(trial)];
      else
        Analysis_full.Behavior.RT_adjusted = [Analysis_full.Behavior.RT_adjusted;data.analysis.behavior.RT(trial)];
    end
  end % end of trial-level eyetracking processing
  % Add all of this participant's eyetracking data to the overall matrix.
    Analysis_full.EyeTracking.firstFix = [Analysis_full.EyeTracking.firstFix;data.eyetracking.gaze.firstFix];
    Analysis_full.EyeTracking.perjrej = [Analysis_full.EyeTracking.perjrej;data.eyetracking.perjrej];
    Analysis_full.EyeTracking.followingFix_returnRating = [Analysis_full.EyeTracking.followingFix_returnRating;data.eyetracking.distractor_ratings_second];
    Analysis_full.EyeTracking.followingFix_sam = [Analysis_full.EyeTracking.followingFix_sam;nanmean(data.eyetracking.gaze.followingFix_sam)];
    Analysis_full.EyeTracking.followingFix_sam_all = [Analysis_full.EyeTracking.followingFix_sam_all;data.eyetracking.gaze.followingFix_sam];
    Analysis_full.EyeTracking.firstFix_choiceBias = [Analysis_full.EyeTracking.firstFix_choiceBias;data.eyetracking.gaze.firstFix_choiceBias];
    Analysis_full.EyeTracking.propDistFix = [Analysis_full.EyeTracking.propDistFix;length(find(data.eyetracking.distFixDelay>0))/length(data.eyetracking.distFixDelay)];
    Analysis_full.EyeTracking.preDistFirstFixDur = [Analysis_full.EyeTracking.preDistFirstFixDur;data.eyetracking.gaze.firstFixDur];
    Analysis_full.EyeTracking.preDistDur = [Analysis_full.EyeTracking.preDistDur;(data.eyetracking.gaze.firstFixDur + 1000*data.analysis.behavior.distractor.onset)];
    Analysis_full.EyeTracking.distLength = [Analysis_full.EyeTracking.distLength;data.analysis.behavior.distractor.length];
    Analysis_full.Plotting.firstFix_choiceBias_distractor = [Analysis_full.Plotting.firstFix_choiceBias_distractor;nanmean(data.eyetracking.gaze.firstFix_choiceBias(find(data.analysis.behavior.distractor_trials == 1)))];
    Analysis_full.Plotting.firstFix_choiceBias_no_distractor = [Analysis_full.Plotting.firstFix_choiceBias_no_distractor;nanmean(data.eyetracking.gaze.firstFix_choiceBias(find(data.analysis.behavior.distractor_trials == 0)))];
end
%% Remove unmarked distractors

    % Saving the original choice and RT data. This is just working around
    % an organizational issue for how the aDDM was collated.
    orig_choice = Analysis_full.Behavior.choice;
    orig_RT = Analysis_full.Behavior.RT;  

    % Removing the untriggered distractors
    % Note: This doesn't imapct the aDDM data because it was only ever
    % conducted on no-distractor trials.
    bad_trials = find(Analysis_full.Behavior.distractor_trials==2);
    Analysis_full.Behavior.distractor_trials(bad_trials,:) = [];   
    Analysis_full.Behavior.choice(bad_trials,:) = [];   
    Analysis_full.Behavior.ratings_full(bad_trials,:) = [];
    Analysis_full.Behavior.RT(bad_trials,:) = [];        
    Analysis_full.Behavior.RT_adjusted(bad_trials,:) = [];  
    Analysis_full.subname(bad_trials,:) = [];      
    Analysis_full.EyeTracking.firstFix(bad_trials,:) = [];        
    Analysis_full.EyeTracking.firstFix_choiceBias(bad_trials,:) = []; 
    Analysis_full.EyeTracking.preDistDur(bad_trials,:) = []; 
    Analysis_full.EyeTracking.preDistFirstFixDur(bad_trials,:) = []; 
    Analysis_full.EyeTracking.distLength(bad_trials,:) = []; 
    Analysis_full.Behavior.ratings = Analysis_full.Behavior.ratings_full(:,3);

     % Getting some subject-level means, for later plotting
    Analysis_full.Plotting.choice_noDist = nan(50,9); Analysis_full.Plotting.choice_dist = nan(50,9);
    Analysis_full.Plotting.rt_noDist = nan(50,9); Analysis_full.Plotting.rt_dist = nan(50,9);
    Analysis_full.Plotting.postDistFix = zeros(50,5);
    for currSubj = 1:50
        binranges = -4:4;
        for currVal = 1:9
                    Analysis_full.Plotting.choice_noDist(currSubj,currVal) = nanmean(Analysis_full.Behavior.choice(Analysis_full.Behavior.ratings==binranges(currVal)&Analysis_full.Behavior.distractor_trials==0&Analysis_full.subname==currSubj));
                    Analysis_full.Plotting.choice_dist(currSubj,currVal) = nanmean(Analysis_full.Behavior.choice(Analysis_full.Behavior.ratings==binranges(currVal)&Analysis_full.Behavior.distractor_trials==1&Analysis_full.subname==currSubj));
                    Analysis_full.Plotting.rt_noDist(currSubj,currVal) = nanmean(Analysis_full.Behavior.RT_adjusted(Analysis_full.Behavior.ratings==binranges(currVal)&Analysis_full.Behavior.distractor_trials==0&Analysis_full.subname==currSubj));
                    Analysis_full.Plotting.rt_dist(currSubj,currVal) = nanmean(Analysis_full.Behavior.RT_adjusted(Analysis_full.Behavior.ratings==binranges(currVal)&Analysis_full.Behavior.distractor_trials==1&Analysis_full.subname==currSubj));
        end
        binranges = -2:2;
        for currVal = 1:5
            Analysis_full.Plotting.postDistFix(currSubj,currVal) = nanmean(Analysis_full.EyeTracking.followingFix_sam_all(Analysis_full.EyeTracking.followingFix_returnRating==binranges(currVal)&Analysis_full.EyeTracking.followingFix_sam_SubjList==currSubj));
        end
    end


% Is where participants look after the distraction related to choice
Analysis_full.Plotting.followFix_toChoice_mean = [];
distractionChoices = Analysis_full.Behavior.choice(Analysis_full.Behavior.distractor_trials==1);
distractionRT = Analysis_full.Behavior.choice(Analysis_full.Behavior.distractor_trials==1);
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
            if theseFirstFixes(i) == 2 && theseVars(i)==0 && theseChoices(i)==1 %Looked left, then right, then looked left and choose left.
                followFix_toChoice_thisSubj = [followFix_toChoice_thisSubj;1];
            elseif theseFirstFixes(i) == 3 && theseVars(i)==0 && theseChoices(i)==0 %Looked right, then left, then right and choose right.
                followFix_toChoice_thisSubj = [followFix_toChoice_thisSubj;1];
            elseif theseFirstFixes(i) == 2 && theseVars(i)==1 && theseChoices(i)==0 %Looked left, then right, then right and choose right.
                followFix_toChoice_thisSubj = [followFix_toChoice_thisSubj;1];
            elseif theseFirstFixes(i) == 3 && theseVars(i)==1 && theseChoices(i)==1 % Looked right, then left, then left and choose left.
                followFix_toChoice_thisSubj = [followFix_toChoice_thisSubj;1];
            else
                followFix_toChoice_thisSubj = [followFix_toChoice_thisSubj;0];
            end
        end
    end
    Analysis_full.Behavior.followFix_toChoice_all = [Analysis_full.Behavior.followFix_toChoice_all;followFix_toChoice_thisSubj];
    Analysis_full.Plotting.followFix_toChoice_mean=[Analysis_full.Plotting.followFix_toChoice_mean;nanmean(followFix_toChoice_thisSubj)];
end
  save('FullInfoDistractor.mat', 'Analysis_full','-v7.3');

      
    %% Format DDM
    % No distractor trials
    DDM_nodist = nan(length(find(Analysis_full.Behavior.distractor_trials==0)),5);
    DDM_nodist(:,4) = Analysis_full.Behavior.choice(Analysis_full.Behavior.distractor_trials==0);
    DDM_nodist(DDM_nodist==0) = -1;    
    DDM_nodist(:,1) = Analysis_full.subname(find(Analysis_full.Behavior.distractor_trials==0));
    DDM_nodist(:,2) = Analysis_full.Behavior.ratings_full(find(Analysis_full.Behavior.distractor_trials==0),1)+3;
    DDM_nodist(:,3) = Analysis_full.Behavior.ratings_full(find(Analysis_full.Behavior.distractor_trials==0),2)+3;    
    DDM_nodist(:,5) = round(Analysis_full.Behavior.RT(Analysis_full.Behavior.distractor_trials==0) * 100);
    csvwrite('DDM_set2_nodist.csv',DDM_nodist);

    % Distractor trials
    DDM_dist = nan(length(find(Analysis_full.Behavior.distractor_trials==1)),10);
    DDM_dist(:,4) = Analysis_full.Behavior.choice(Analysis_full.Behavior.distractor_trials==1);
    DDM_dist(DDM_dist==0) = -1;    
    DDM_dist(:,1) = Analysis_full.subname(find(Analysis_full.Behavior.distractor_trials==1));
    DDM_dist(:,2) = Analysis_full.Behavior.ratings_full(find(Analysis_full.Behavior.distractor_trials==1),1)+3;
    DDM_dist(:,3) = Analysis_full.Behavior.ratings_full(find(Analysis_full.Behavior.distractor_trials==1),2)+3;    
    DDM_dist(:,5) = round(Analysis_full.Behavior.RT(Analysis_full.Behavior.distractor_trials==1) * 100);
    DDM_dist(:,6) = round(Analysis_full.Behavior.distractor_onset * 100);
    DDM_dist(:,7) = round(Analysis_full.Behavior.distractor_end * 100);
    DDM_dist(:,8) = round(Analysis_full.EyeTracking.preDistDur(Analysis_full.Behavior.distractor_trials==1)/10); % FirstFixation+DistractorOnsetRequimrent
    DDM_dist(:,9) = round(Analysis_full.EyeTracking.distLength(Analysis_full.Behavior.distractor_trials==1) * 100); % Distractor length
    DDM_dist(:,10) = round(Analysis_full.EyeTracking.preDistFirstFixDur(Analysis_full.Behavior.distractor_trials==1)/10); % FirstFixation+DistractorOnsetRequimrent
    csvwrite('DDM_set2_dist.csv',DDM_dist);

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
        aDDM(indices,6) = orig_choice(count);
        aDDM(indices,7) = orig_RT(count) * 1000;
        aDDM(indices,11) = nansum(Analysis_full.EyeTracking.fixation_durations(noGaze_indices));
        count = count + 1;
    end
end
aDDM(find(aDDM(:,6)==0),6)=-1;
aDDM(find(isnan(aDDM(:,8))),:) = [];
csvwrite('set2_addm.csv',aDDM)


