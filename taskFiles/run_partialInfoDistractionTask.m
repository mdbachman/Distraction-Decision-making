%% Task script to run Distraction task with partial-information distractions
% Author: Matthew D. Bachman
% will first run health and taste ratings (run 1)
% then run the distraction task (run 2)
% Requires Psychtoolbox.

Screen('Preference','SkipSyncTests',1);
cd('C:\Users\eyetracker\Documents\MATLAB\Huettel Lab\MDB\FoodChoice')
addpath(genpath('generalCode'));
addpath stimuli;

% eye tracking nonsense startup
Calib = initialize_params_et();
tetio_init();
trackerinfo           = tetio_getTrackers();
trackerID             = trackerinfo.ProductId;
tetio_connectTracker(trackerID)



%% set randomizer

RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));

%% get/check settings (subj no. and update variable)


update = true; % update the stock.mat file after selecting a food

if ~exist('subject_data','dir')
    mkdir('subject_data')
end

if ~exist('subject','var')
    subject = [];
    while isempty(subject) || ~isa(subject,'double')
        subject = input('Subject number: ');
    end
end

if ~exist('run','var')
    run = [];
    while isempty(run) || ~isa(run,'double') || run < 1 || run > 6
        run = input('Run number (1-2): ');
    end
end 

lastRun=5;
%% Makes it here, at least
dataFName = fullfile('subject_data', ['s' num2str(subject) 'Results.mat']);

while exist(dataFName,'file') && isequal(run,1)  && subject ~= 999 % (test subject)
    overwrite = input('Subject files exists. Overwrite? 1=yes, 0=no ');
    if ~overwrite
        subject = input('Subject number: ');
        dataFName = fullfile('subject_data', ['s' num2str(subject) 'Results.mat']);
    else
        % save backup just in case!
        append=num2str(clock); % append year/date/time to backup file name
        append = append(~isspace(append) & append ~= '.');
        movefile(fullfile('subject_data', ['s' num2str(subject) 'Results.mat']), ...
            fullfile('subject_data', ['old_' append '_s' num2str(subject) 'Results.mat']));
        break
    end
end

if run > 1 && exist(dataFName,'file')
    load(dataFName);
elseif run > 1 && ~exist(dataFName,'file')
    disp('run > 1 but no data file exists. exiting.')
    sca; return;
end


%% starting up: initial settings
%run = rand(1:5);
% experiment info
if run==1
    data.subject = subject;
    data.date = fix(clock);
end

% open window
Screen('Preference', 'VisualDebugLevel', 1);% change psych toolbox screen check to black
[exp_screen, ~] = Screen('OpenWindow', 1);
[data.width, data.height] = Screen('WindowSize',exp_screen);
data.screenRefreshRate = Screen('GetFlipInterval', exp_screen);
Screen('BlendFunction', exp_screen, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

Screen('TextFont',exp_screen,'Arial');

% style settings
wrapat = 70;
vSpacing = 1.2;
bg_color = [50 50 50];
txt_color = WhiteIndex(exp_screen);
no_choice_color = [250 0 0];
chosen_color= [0 220 0];
txt_size.fixCross = 36;
txt_size.blockTxt = 26;
txt_size.rateFoodName = 33;
txt_size.rateGuide = 22;
txt_size.binaryFoodName = 30;
txt_size.statusLabels = 32;

% response key set up
KbName('UnifyKeyNames');
hunger_keys = [{'Not at all'} {'A little'} {'Moderately'} {'Extremely'}];
hunger_key_codes = KbName({'1!' '2@' '3#' '4$'});
exitKeys = KbName({'e', 'E'});
rightKey = KbName('rightarrow');
leftKey = KbName('leftarrow');
spaceKey = KbName('space');
startFirstKeys = KbName({'b', 'B'});


%% ratings: set up task
if isequal(run,1)



    % retrieve image names from directory
    tmp = dir('stimuli/FoodImages/*.bmp');
    data.rate.image_names = {tmp(1:length(tmp)).name}';
    tmp = dir('stimuli/FoodImages/*.jpg');
    data.rate.image_names = [data.rate.image_names; {tmp(1:length(tmp)).name}'];

    data.rate.nTrials = length(data.rate.image_names); 

    % experiment settings
    data.rate.blockname = {'HEALTH' 'TASTE' 'WANTING'};
    data.rate.blockdistript = {'HEALTHY you think each food is', ...
        'TASTY each food item is to you', ...
        'much you WANT TO EAT this food after the task'};
    data.rate.nratings = length(data.rate.blockname);


    % randomize order of foods and order of ratings
    data.rate.ind = randperm(length(data.rate.image_names))'; % food presentation order
    data.rate.ratingsorder = [randperm(2) 3]; % wanting LAST, other two random


    % timing
    data.rate.feedbackSecs = .2; % feedback duration
    % ITI
    tmp = repmat([.2 .3 .4 .5], 1, ceil(data.rate.nTrials/4))';
    tmp = tmp(1:data.rate.nTrials);
    data.rate.reset_screen = sortrows([rand(data.rate.nTrials,1), tmp]);
    data.rate.reset_screen = data.rate.reset_screen(:,2);

    % location of text keyboard guide:
    data.rate.guideLocs = linspace(.15,.96,6) * data.width;

    % response key guides
    data.rate.resp_keys = {'c' 'v' 'b' 'n' 'm'};
    data.rate.resp_key_codes = KbName(data.rate.resp_keys);
    data.rate.keyguide = 'c             v             b             n             m'; % set key labels
    data.rate.keyguideTwo = 'cvbnm'; % set key labels
    data.rate.guide{1} = {'very unhealthy', 'unhealthy', 'neutral', 'healthy', 'very healthy'};
    data.rate.guide{2} = {'very bad taste', 'bad taste', 'neutral', 'good taste', 'very good taste'};
    data.rate.guide{3} = {'strongly don''t want', 'don''t want', 'neutral', 'want', 'strongly want'};
    data.rate.guideTwo{1} = {'very\nunhealthy', 'unhealthy', 'neutral', 'healthy', 'very\nhealthy'};
    data.rate.guideTwo{2} = {'very\nbad taste', 'bad taste', 'neutral', 'good taste', 'very\ngood taste'};
    data.rate.guideTwo{3} = {'strongly\ndon''t want', 'don''t want', 'neutral', 'want', 'strongly\nwant'};
    data.rate.choicevalence_guide = repmat(-2:2,3,1);


    % randomly set the left-right scale direction on a participant-by-participant basis
    data.rate.scaleFlip = randi(2)-1; % 1=flip it, 0=don't
    % flip scale if necessary
    if data.rate.scaleFlip
        for i=1:data.rate.nratings
            data.rate.guide{i} = fliplr(data.rate.guide{i});
            data.rate.guideTwo{i} = fliplr(data.rate.guideTwo{i});
        end
        data.rate.choicevalence_guide = fliplr(data.rate.choicevalence_guide);
    end

    % preallocate
    data.rate.choice = cell(data.rate.nTrials, data.rate.nratings); % letter pressed
    data.rate.choicetxt = cell(data.rate.nTrials, data.rate.nratings); % text of response
    data.rate.choicevalence = NaN(data.rate.nTrials, data.rate.nratings); % number of response
    data.rate.RT = NaN(data.rate.nTrials, data.rate.nratings); % RT
    data.rate.health = NaN(data.rate.nTrials, 1);
    data.rate.taste = NaN(data.rate.nTrials, 1);
    data.rate.wanting = NaN(data.rate.nTrials, 1);
    data.rate.timeStamp.stimOn = NaN(data.rate.nTrials, data.rate.nratings); % time stamp
    data.rate.timeStamp.RT = NaN(data.rate.nTrials, data.rate.nratings); % time stamp
    data.rate.timeStamp.feedbackOn = NaN(data.rate.nTrials, data.rate.nratings); % time stamp
    data.rate.timeStamp.fixOn = NaN(data.rate.nTrials, data.rate.nratings); % time stamp



    %% ask about hunger:

    Screen('TextSize', exp_screen, txt_size.blockTxt);
    Screen(exp_screen, 'FillRect', bg_color);
    DrawFormattedText(exp_screen,['Before you begin, how hungry are you right now?\n'...
        ' (Use the keyboard numbers to respond)\n\n\n\n'...
        '1            2           3           4    \n\n'...
        'Not at all     A little    Moderately  Extremely'],...
        'center','center',txt_color,wrapat,[],[],vSpacing);
    Screen(exp_screen,'Flip');
    while 1
        [keyIsDown, ~, keyCode] = KbCheck;
        if keyIsDown && any(keyCode(hunger_key_codes)) && length(KbName(keyCode)) == 2
            data.hungerlevel = KbName(keyCode);
            data.hungerlevel = str2double(data.hungerlevel(1));
            data.hunger_text = hunger_keys(data.hungerlevel);
            break
        elseif keyIsDown && any(keyCode(exitKeys)) && length(KbName(keyCode)) == 1
            Screen('CloseAll');
            return
        end
    end

    %% ratings: instructions

    clear inst
    inst{1} = ['In this part of the study, you will participate in two tasks.\n\n\n'...
        'TASK ONE\n\n'...
        'In the first task, you will use the keyboard to rate a variety '...
        'of foods on two attributes, one at a time.\n\n'...
        'Press the right arrow to continue.'...
        ];
    inst{length(inst)+1} = ['You''ll rate foods on their healthiness and how tasty they are to you.\n\n'...
        'You have the option to rate an item as "neutral;" however, '...
        'it is helpful if you do your best to avoid rating items as "neutral."\n\n'...
        'Press the right arrow to continue, and the left arrow to go back.'
        ];
    inst{length(inst)+1} = ['Rate each food based on how it looks on the screen.\n\n'...
        'For example, when rating a picture of a plain piece of bread, tell us how healthy '...
        'you think it is alone, not how healthy it would have been if it were covered in '...
        'butter.\n\n'...
        'Press the right arrow to continue, and the left arrow to go back.'
        ];
    inst{length(inst)+1} = ['Please get the experimenter''s '...
        'attention now if you have any questions at all.\n\n'...
        'Otherwise, press the "b" key to begin.\n\n'...
        'You will not be able to return to the instructions after pressing '...
        'the "b" key on the keyboard.'...
        ];

    tic;
    i=1;
    Screen('TextSize', exp_screen, txt_size.blockTxt);
    while i <= length(inst)

        Screen(exp_screen, 'FillRect', bg_color);
        DrawFormattedText(exp_screen,inst{i},'center','center',txt_color,wrapat,...
            [],[],vSpacing);
        Screen(exp_screen, 'Flip');
        WaitSecs(.2); KbEventFlush;

        while 1
            [keyIsDown, ~, keyCode] = KbCheck;
            if keyIsDown && any(keyCode(exitKeys))
                sca; return
            elseif keyIsDown && keyCode(leftKey) && i > 1
                i = i - 1;
                break
            elseif keyIsDown && i<length(inst) && keyCode(rightKey)
                i = i + 1;
                break
            elseif keyIsDown && i==length(inst) && any(keyCode(startFirstKeys))
                data.bKeyPressed(run) = GetSecs;
                i = i + 1;
                break
            end
        end
    end
    data.rate.instructions_viewed = toc;



    %% ratings: task

    tic;
    count=1;
    for nB = data.rate.ratingsorder(1:3) % collect health and taste in the pre-determined order

        % show ratings instructions & key guide
        Screen('TextSize', exp_screen, txt_size.blockTxt);
        Screen(exp_screen, 'FillRect', bg_color);
        DrawFormattedText(exp_screen,sprintf(['Please rate the following foods ' ...
            'based on how %s, using the keys and the scale below.'],...
            data.rate.blockdistript{nB}), 'center',data.height*.2,txt_color,wrapat,[],[],vSpacing);
        for n = 1:length(data.rate.keyguideTwo)
            DrawFormattedText(exp_screen,data.rate.keyguideTwo(n),...
                data.rate.guideLocs(n),data.height*.5,txt_color,wrapat,[],[],vSpacing);
            DrawFormattedText(exp_screen,data.rate.guideTwo{nB}{n},...
                data.rate.guideLocs(n),data.height*.58,txt_color,wrapat,[],[],vSpacing);
        end
        DrawFormattedText(exp_screen,'Press the spacebar to begin!',...
            'center', data.height*.8, txt_color, wrapat, [], [], vSpacing);
        Screen(exp_screen, 'Flip');
        WaitSecs(.2); KbEventFlush;
        % wait for spacebar to begin
        while 1
            [keyIsDown, ~, keyCode] = KbCheck;
            if keyIsDown && keyCode(spaceKey)
                break
            elseif any(keyCode(exitKeys))
                sca; return
            end
        end

        % countdown to start
        for i = 1:3
            Screen(exp_screen, 'FillRect', bg_color);
            DrawFormattedText(exp_screen,['Task will start in ' num2str(4-i) ' seconds.\n\n\n'],...
                'center', 'center', [255 0 0],wrapat,[],[],vSpacing);
            Screen(exp_screen,'Flip');        
            WaitSecs(1);
        end


        for trial = data.rate.ind' % run trials in the pre-determined randomized order

            % display stimuli
            % get the food image
            imgfile = imread(['stimuli/FoodImages/' data.rate.image_names{trial}]);
            img = Screen(exp_screen, 'MakeTexture', imgfile);
            % show the image
            Screen(exp_screen, 'FillRect', bg_color);
            Screen('DrawTexture', exp_screen, img, [], ...
                [data.width*.5-200 data.height*.5-200 ...
                data.width*.5+200 data.height*.5+200]);
            % show ratings scale
            Screen('TextSize', exp_screen, txt_size.rateGuide);
            for n = 1:length(data.rate.keyguideTwo)
                DrawFormattedText(exp_screen,data.rate.keyguideTwo(n),...
                    data.rate.guideLocs(n),data.height*.8,txt_color,wrapat,[],[],vSpacing);
                DrawFormattedText(exp_screen,data.rate.guideTwo{nB}{n},...
                    data.rate.guideLocs(n),data.height*.88,txt_color,wrapat,[],[],vSpacing);
            end
            Screen('Flip', exp_screen);
            data.rate.timeStamp.stimOn(trial, nB) = GetSecs;

            % listen for response
            while 1
                [keyIsDown, ~, keyCode] = KbCheck;
                if keyIsDown && any(keyCode(data.rate.resp_key_codes)) && length(KbName(keyCode)) == 1

                    data.rate.timeStamp.RT(trial,nB) = GetSecs; 
                    data.rate.RT(trial,nB) = data.rate.timeStamp.RT(trial,nB) ...
                        - data.rate.timeStamp.stimOn(trial,nB);

                    data.rate.choice{trial,nB} = KbName(keyCode); % letter code

                    data.rate.choicetxt{trial,nB} = data.rate.guide{nB}{data.rate.choice{trial,nB} ...
                        ==cell2mat(data.rate.resp_keys)}; % string

                    data.rate.choicevalence(trial,nB) = ... % -2 to 2
                        data.rate.choicevalence_guide(nB,data.rate.choice{trial,nB} == ...
                        cell2mat(data.rate.resp_keys));

                    data.rate.(lower(data.rate.blockname{nB}))(trial) = data.rate.choicevalence(trial,nB);

                    break
                elseif keyIsDown && any(keyCode(exitKeys)) && length(KbName(keyCode)) == 1
                    sca; return;
                end
            end
            save(dataFName,'data');

            % --- show their response
            % show the image:
            Screen(exp_screen, 'FillRect', bg_color);
            Screen('DrawTexture', exp_screen, img, [], ...
                [data.width*.5-200 data.height*.5-200 ...
                data.width*.5+200 data.height*.5+200]);
            % show ratings scale
            Screen('TextSize', exp_screen, txt_size.rateGuide);
            for n = 1:length(data.rate.keyguideTwo)
                if strcmp(data.rate.choicetxt{trial,nB}, data.rate.guide{nB}{n})
                    DrawFormattedText(exp_screen,data.rate.keyguideTwo(n),...
                        data.rate.guideLocs(n),data.height*.8,chosen_color,wrapat,[],[],vSpacing);
                    DrawFormattedText(exp_screen,data.rate.guideTwo{nB}{n},...
                        data.rate.guideLocs(n),data.height*.88,chosen_color,wrapat,[],[],vSpacing);
                else
                    DrawFormattedText(exp_screen,data.rate.keyguideTwo(n),...
                        data.rate.guideLocs(n),data.height*.8,txt_color,wrapat,[],[],vSpacing);
                    DrawFormattedText(exp_screen,data.rate.guideTwo{nB}{n},...
                        data.rate.guideLocs(n),data.height*.88,txt_color,wrapat,[],[],vSpacing);
                end
            end
            Screen('Flip', exp_screen);
            data.rate.timeStamp.feedbackOn(trial, nB) = GetSecs;
            Screen('Close', img);
            WaitSecs(data.rate.feedbackSecs);
            %imwrite(Screen('GetImage', exp_screen), sprintf('%d_%d.png',nB,trial))

            % fixation
            Screen('TextSize', exp_screen, txt_size.fixCross);
            DrawFormattedText(exp_screen,'+','center','center',txt_color,wrapat,[],[],vSpacing);
            Screen(exp_screen,'Flip');
            data.rate.timeStamp.fixOn(trial, nB) = GetSecs;
            WaitSecs(data.rate.reset_screen(trial));
        end    


        % --- end-of-block screen
        if count == 1
            Screen('TextSize', exp_screen, txt_size.blockTxt);
            DrawFormattedText(exp_screen,['End of this group of ratings.\n'...
                'Press the spacebar to continue.'],...
                'center', 'center', txt_color, wrapat, [], [], vSpacing);
            Screen(exp_screen,'Flip');
            
            WaitSecs(.2); KbEventFlush;
            while 1
                [keyIsDown, ~, keyCode] = KbCheck;
                if keyIsDown && keyCode(spaceKey)
                    break
                elseif any(keyCode(exitKeys))
                    sca; return
                end
            end
        end

        count=count+1;    
    end
    data.rate.taskDur(1) = toc;

    

    
    save(dataFName,'data');


   
    %% simple binary choice: create food pairs
    
    
    
    % create food 
    data.binary.nTrials = 405;
    datasample(1:10,5,'Replace',false)

    % all possible food pairs
    foodsIndex = (1:length(data.rate.image_names))';
    [x, y] = meshgrid(foodsIndex, foodsIndex);
    all = [x(:) y(:)];
    all(all(:,1)==all(:,2),:) = []; % remove trials pairing same food.
    
    
    %% Starting from this point - I think this above is correct.
    % get ratings of each food pair
    tastePairs = [data.rate.taste(all(:,1)) data.rate.taste(all(:,2))];;
    tasteDifferences = [data.rate.taste(all(:,1))-data.rate.taste(all(:,2))];
    
    wantingPairs = [data.rate.wanting(all(:,1)) data.rate.wanting(all(:,2))];
    wantingDifferences = [data.rate.wanting(all(:,1))-data.rate.wanting(all(:,2))];
    

    % pick up the correct number of trials for each trial type
    trials = [];
    difference_values = -4:4;
    trials_per_bin = data.binary.nTrials / (length(difference_values));
    Random_Seed = RandStream('mlfg6331_64'); 
    for current_difference_value = 1:length(difference_values);
        indices = find(wantingDifferences==difference_values(current_difference_value));
        if length(indices) >= trials_per_bin %If there are more trails available than needed.
            chosen_indices = randsample(Random_Seed,indices,(data.binary.nTrials / 9));
            trials = [trials;all(chosen_indices,:)];
        elseif (length(indices) < trials_per_bin) && (length(indices) >= trials_per_bin/2) % If there are fewer than the total number of trials needed, but more than half. 
            extra_trials_needed = trials_per_bin - length(indices); 
            trials = [trials;all(indices,:)];
            extra_trials = randsample(Random_Seed,indices,extra_trials_needed);
            trials = [trials;all(extra_trials,:)];
        elseif (length(indices) < trials_per_bin) && (length(indices) < trials_per_bin/2) % If there are so few trials available that there isn't even half available. Will basically add copies of the available trials until 
            original_indices = indices;                                                   % over half is achieved, and then grab a few remaining ones like in the previous statement.   
            while length(indices) < (trials_per_bin/2)
                indices = [indices;original_indices];
                trials = [trials;all(indices,:)];
            end
            extra_trials_needed = trials_per_bin - length(indices); 
            extra_trials = randsample(Random_Seed,indices,extra_trials_needed);
            trials = [trials;all(extra_trials,:)];
        end
    end
    trials = trials(randperm(size(trials,1)),:); 
    
    if trials < 405 
        disp('Warning! Not enough trials available');
    end;

    data.binary.trials = trials;
    % get image names for each trial
    data.binary.imgNamesUseInOrder = [{data.rate.image_names{data.binary.trials(:,1)}}', {data.rate.image_names{data.binary.trials(:,2)}}'];


    
    save(dataFName,'data');
    
    %% simple binary choice: set up task

    data.binary.feedbackSecs = .2;
    
    % ITI
    tmp = repmat([1.3 1.4 1.5 1.6 1.7], 1, ceil(data.binary.nTrials/5))';
    tmp = tmp(1:data.binary.nTrials);
    data.binary.reset_screen = sortrows([rand(data.binary.nTrials,1), tmp]);
    data.binary.reset_screen = data.binary.reset_screen(:,2);
    
    % size and location of food and boxes
    food_height = 144;
    food_width = 144;
    data.binary.leftFoodLoc = [data.width*.25-food_width data.height*.5-food_height ...
            data.width*.25+food_width data.height*.5+food_height];
    data.binary.rightFoodLoc = [data.width*.75-food_width data.height*.5-food_height ...
            data.width*.75+food_width data.height*.5+food_height];
    data.binary.distractorLoc = [data.width*.5-food_width data.height*.5-food_height ...
            data.width*.5+food_width data.height*.5+food_height];
    % choice boxes
    box_height = food_height + 5;
    box_width = food_width + 5;
    data.binary.left_box = [data.width*.25-box_width data.height*.5-box_height ...
        data.width*.25+box_width data.height*.5+box_height];
    data.binary.right_box = [data.width*.75-box_width data.height*.5-box_height ...
        data.width*.75+box_width data.height*.5+box_height];
    
    data.binary.resp_key_codes = KbName({'1!' '0)'});
    
    % preallocate...
    data.binary.RT = NaN(data.binary.nTrials,1); % RT (secs to make choice after images shown)
    data.binary.choice_text = cell(1,data.binary.nTrials); % image name
    data.binary.choice = cell(data.binary.nTrials,1); % 1!(left) or 0)(right)
    data.binary.chooseLeft = false(data.binary.nTrials,1);
    data.binary.leftOrRightWord = NaN(data.binary.nTrials,1);
    data.binary.timeStamp.stimOn = NaN(data.binary.nTrials,1);
    data.binary.timeStamp.RT = NaN(data.binary.nTrials,1);
    data.binary.timeStamp.feedbackOn = NaN(data.binary.nTrials,1);
    data.binary.timeStamp.fixOn = NaN(data.binary.nTrials,1);
    data.binary.timeStamp.beforeWhile = NaN(data.binary.nTrials,1); % time stamp
    data.binary.timeStamp.afterWhile = NaN(data.binary.nTrials,1); % time stamp
    data.binary.timeStamp.distractorOn = NaN(data.binary.nTrials,1); % time stamp
    data.binary.timeStamp.remainingOn = NaN(data.binary.nTrials,1); % time stamp
    data.binary.timeStamp.FirstFixationCompleted = NaN(data.binary.nTrials,1); % time stamp
    data.binary.distractor.type = NaN(data.binary.nTrials,1);
    data.binary.distractor.rotation = NaN(data.binary.nTrials,1);
    

    save(dataFName,'data');
    sca
    
elseif isequal(run,2)
    
    clear calibrationName;
    calibrationName = (['calibrationResults_',num2str(subject),'.mat']);

    if ~exist(calibrationName,'file')
        disp('Warning! Eyetracker has not been calibrated yet!')
        pause(5);
        sca;
        return;
    else
        disp('Calibration found. Proceeding.')
    end
    
    
    ifi = Screen('GetFlipInterval', exp_screen);
    %distractor_images = {'2038.jpg','2190.jpg','2393.jpg','2397.jpg','2411.jpg','2440.jpg','2480.jpg','2570.jpg','2580.jpg','2620.jpg','2840.jpg','2890.jpg','5130.jpg','5390.jpg','5731.jpg','5740.jpg','7010.jpg','7020.jpg','7025.jpg','7026.jpg','7031.jpg','7040.jpg','7041.jpg','7050.jpg','7053.jpg','7059.jpg','7060.jpg','7090.jpg','7100.jpg','7110.jpg','7140.jpg','7150.jpg','7175.jpg','7179.jpg','7205.jpg','7217.jpg','7224.jpg','7234.jpg','7235.jpg','7490.jpg','7491.jpg','7700.jpg','7705.jpg','7950.jpg','9360.jpg'};

    distractor_images = {'5130.jpg','5390.jpg','5731.jpg','5740.jpg','7010.jpg','7020.jpg','7025.jpg','7026.jpg','7030.jpg','7031.jpg','7040.jpg','7041.jpg','7050.jpg','7053.jpg','7059.jpg','7060.jpg','7090.jpg','7100.jpg','7110.jpg','7140.jpg','7150.jpg','7161.jpg','7175.jpg','7179.jpg','7205.jpg','7217.jpg','7224.jpg','7234.jpg','7235.jpg','7490.jpg','7491.jpg','7700.jpg','7705.jpg','7950.jpg','9360.jpg'};
    data.distractor_trials = sort(datasample(1:data.binary.nTrials,round(data.binary.nTrials/3),'Replace',false));
    data.distractor_trials(1);
    Trial_Length = 4;
    data.binary.Start_ET_Time = GetSecs;
    data.FrameRate = tetio_getFrameRate;
    %data.binary.distractor_required_duration = round(100/data.FrameRate); 
    data.binary.distractor_required_duration = 12; 
    data.binary.eyetracking.results = {'TrialNum','FixPoint','FixCoord','TextLoc','Frame','ETInfo'};
    leftEyeAll = [];
    rightEyeAll = [];
    timeStampAll = [];
    trialNum = [];

    
    %% Some specific stuff for the transparent boxes
    transparency = .2:.05:.8;
    %% End of transparent stuff

    %% simple binary choice instructions
    
    clear inst
    inst{1} = ['TASK TWO\n\n'...
        'On each trial of this task, you will make choices between '...
        'two different foods.\n\n'...
        'Press the right arrow to continue.'...
        ];

    inst{length(inst)+1} = ['In this experiment you will make decisions between pairs of snack foods. '...
        'You should choose which food you would prefer to eat. '...
        'Press the one (1) key to select the food on the left, and zero (0) '...
        'key to select the food on the right. The white box surrounding your food will '...
        'become thicker when you select it. \n\n\n'...
        'Press the right arrow to continue, and the left arrow to go back.'...
        ];

     inst{length(inst)+1} = ['At the end of the experiment, you will actually '...
        'receive your food choice from one randomly-selected trial across the '...
        'entire experiment.\n\n'...
        'You can leave either when you''ve eaten the '...
        'food, or when one half hour has expired.\n\n\n'...
        'Press the right arrow to continue, and the left arrow to go back.'...
        ];
    inst{length(inst)+1} = ['You will have four seconds to make each choice. '...
        'If you do not respond quickly enough then you will see the word "Slow!" appear on the screen.\n\n\n'...
        'Press the right arrow to continue, and the left arrow to go back.'...
        ];
    inst{length(inst)+1} = ['Feel free to look at each food option to help you make your choice. '...
        'However, please look back at the white fixation cross in the middle of the screen once you have finished making your choice. \n\n\n'...
        'Press the right arrow to continue, and the left arrow to go back.'...
        ];
    inst{length(inst)+1} = ['To make these decisions more like everyday food choices, we will occasionally show you a different, irrelevant picture during some trials.\n\n '...
        'It will not affect your food choices or outcome. You cannot make a food choice while this image is on the screen. '...
        'Do not feel any pressure to memorize the pictures, as we will not be testing you on them later on.\n\n\n'...
        'Press the right arrow to continue, and the left arrow to go back.'...
        ];

    inst{length(inst)+1} = ['Please get the experimenter''s '...
        'attention now if you have any questions at all.\n\n'...
        'Otherwise, press the "b" key to begin.\n\n\n'...
        'You will not be able to return to the instructions after pressing '...
        'the "b" key on the keyboard.'...
        ];

    Screen('TextSize', exp_screen, txt_size.blockTxt);
    tic; % start timer
    i=1;
    while i <= length(inst)

        Screen(exp_screen, 'FillRect', bg_color);
        DrawFormattedText(exp_screen,inst{i},'center','center',txt_color,wrapat,...
            [],[],vSpacing);
        Screen(exp_screen, 'Flip');
        WaitSecs(.2); KbEventFlush;

        while 1
            [keyIsDown, ~, keyCode] = KbCheck;
            if keyIsDown && any(keyCode(exitKeys))
                sca; return
            elseif keyIsDown && keyCode(leftKey) && i > 1
                i = i - 1;
                break
            elseif keyIsDown && i<length(inst) && keyCode(rightKey)
                i = i + 1;
                break
            elseif keyIsDown && i==length(inst) && any(keyCode(startFirstKeys))
                data.bKeyPressed(run) = GetSecs;
                i = i + 1;
                break
            end
        end
    end
    data.binary.instruct_seconds_viewed = toc; % end timer

    
    %%  binary choice task
    %%% MDB
    % countdown to start
    for i = 1:3
        Screen(exp_screen, 'FillRect', bg_color);
        DrawFormattedText(exp_screen,['Task will start in ' num2str(4-i) ' seconds.\n\n\n'],...
            'center', 'center', [255 0 0],wrapat,[],[],vSpacing);
        Screen(exp_screen,'Flip');        
        WaitSecs(1);
    end
    
    disp('Beginning the task.');
    data.binary.task_start = GetSecs;
    for trial = 1:data.binary.nTrials 
        imgfile_left = imread(['stimuli/FoodImages/' data.binary.imgNamesUseInOrder{trial, 1}]);
        imgfile_right = imread(['stimuli/FoodImages/' data.binary.imgNamesUseInOrder{trial, 2}]);
        choiceImg{1} = Screen(exp_screen, 'MakeTexture',imgfile_left);
        choiceImg{2} = Screen(exp_screen, 'MakeTexture',imgfile_right);
        box_left_thickness = 2;
        box_right_thickness = 2;
        choice_made = false;
        while_frame = 0;
        if mod(trial,5) == 0
            disp((['Trial ', num2str(trial),' of ',num2str(data.binary.nTrials), ' complete.']))
        end
        
        tetio_startTracking; % start eye tracker recording %Check to make sure that this is working.
        % Distractor trials 
        if ismember(trial,data.distractor_trials) 
            % Sets up information about distracotr
            current_distractor_image = imread(['C:\Users\eyetracker\Documents\MATLAB\Huettel Lab\MDB\FoodChoice\stimuli\IAPS_Images/' distractor_images{(randi(35))}]);
            if randi(2) == 1 
                data.distractor.rotation(trial) = 1;
            else
                current_distractor_image = flipdim(current_distractor_image,2);
                data.distractor.rotation(trial) = 2;
            end
            distractor = Screen(exp_screen, 'MakeTexture',current_distractor_image);
            distractor_length_distribution = .4;
            current_distractor_length = distractor_length_distribution(randi(length(distractor_length_distribution)));
            DistractorTimeFrames = round(current_distractor_length / ifi);
            
            % Before distractor onset
            if choice_made == false;            
                % draw images and text
                Screen('TextSize', exp_screen, txt_size.fixCross);
                Screen(exp_screen, 'FillRect', bg_color);
                % draw images
                Screen('DrawTexture', exp_screen, choiceImg{1}, [], data.binary.leftFoodLoc);
                Screen('DrawTexture', exp_screen, choiceImg{2}, [], data.binary.rightFoodLoc);
                % draw boxes around foods
                Screen('FrameRect', exp_screen, txt_color, data.binary.left_box, box_left_thickness);
                Screen('FrameRect', exp_screen, txt_color, data.binary.right_box, box_right_thickness);
                DrawFormattedText(exp_screen,'+','center','center',txt_color,wrapat,[],[],vSpacing);
                % flip images and text
                vbl = Screen(exp_screen,'Flip');
                data.binary.timeStamp.stimOn(trial) = GetSecs;   
                
                % eyetracking parameters 
                eyes = [0 0 0]; % this always need to be initiated or else error
                eyes2 = {'TimeStamp','EyeX','EyeY','RawGazeData'};
                data.binary.timeStamp.beforeWhile(trial) = GetSecs;
                j = 0;
                while 1
                    pause(1/data.FrameRate); % measurement every *almost* 16 millisec - probably closer to 20 millisec, dependeing on computing power
                    [lefteye_distInit, righteye_distInit, timestamp_distInit, trigSignal_distInit] = tetio_readGazeData;
                    
                    % this makes sure that at least one eye is being picked up
                    % NECESSARY or else will get error with ParseGazeData
                    if isempty(lefteye_distInit)
                        continue;
                    end
                
                    numGazeData = size(lefteye_distInit, 2);
                    leftEyeAll = vertcat(leftEyeAll, lefteye_distInit(:, 1:numGazeData));
                    rightEyeAll = vertcat(rightEyeAll, righteye_distInit(:, 1:numGazeData));
                    timeStampAll = vertcat(timeStampAll, timestamp_distInit(:,1));
                    trialNum = vertcat(trialNum, repmat(trial,size(timestamp_distInit(:,1),1),1));

                    GazeData = ParseGazeData(lefteye_distInit(end,:),righteye_distInit(end,:)); % Parse last gaze data.

                    % making sure both eyes are giving valid data
                    validLeftEyePos = GazeData.left_validity <= 2;
                    validRightEyePos = GazeData.right_validity <= 2;

                    if validLeftEyePos && validRightEyePos
                        l_x = GazeData.left_gaze_point_2d.x*Calib.mondims1.width;
                        l_y = GazeData.left_gaze_point_2d.y*Calib.mondims1.height;
                        r_x = GazeData.right_gaze_point_2d.x*Calib.mondims1.width;
                        r_y = GazeData.right_gaze_point_2d.y*Calib.mondims1.height;
                    
                        eyeX = mean([l_x,r_x]);
                        eyeY = mean([l_y,r_y]);

                        eyes = [eyes;[GetSecs,mean([l_x,r_x]),mean([l_y,r_y])]];
                        eyes2 = [eyes2;...
                            [num2cell([GetSecs,mean([l_x,r_x]),mean([l_y,r_y])]),{GazeData}]];
                    end
                    
                    eyes_temp = eyes(((eyes(:,2) > data.binary.leftFoodLoc(1) & eyes(:,2) < data.binary.leftFoodLoc(3)) & (eyes(:,3) > data.binary.leftFoodLoc(2) & eyes(:,3) < data.binary.leftFoodLoc(4))) | ((eyes(:,2) > data.binary.rightFoodLoc(1) & eyes(:,2) < data.binary.rightFoodLoc(3)) & (eyes(:,3) > data.binary.rightFoodLoc(2) & eyes(:,3) < data.binary.rightFoodLoc(4))));
             % Checks to see if enough fixations in AOI or if
                % experimenter proceeded manually with key press (set as
                % SPACEBAR here)
                    [keyIsDown, ~, keyCode] = KbCheck;
                    if keyIsDown && any(keyCode(data.binary.resp_key_codes)) && choice_made == false
                        data.binary.timeStamp.RT(trial) = GetSecs;
                        data.binary.RT(trial) = data.binary.timeStamp.RT(trial) - ...
                        data.binary.timeStamp.stimOn(trial);
                        data.binary.choice{trial} = KbName(keyCode); % 1! or 0)   
                        if strcmp(data.binary.choice{trial},'1!')
                            box_left_thickness = 8;
                            choice_made = true;
                            break
                        elseif strcmp(data.binary.choice{trial},'0)')
                            box_right_thickness = 8;
                            choice_made = true;
                            break
                        end
                    elseif size(eyes_temp,1) >= data.binary.distractor_required_duration %| keyIsDown && any(keyCode(data.binary.resp_key_codes)) && choice_made == false 
                        break;
                    elseif keyIsDown && any(keyCode(exiteKeys))
                        sca; return
                    end
                    data.binary.timeStamp.FirstFixationCompleted(trial) = GetSecs;   
                end
               data.binary.timeStamp.afterWhile(trial) = GetSecs;
            etinfo.tracked = eyes2;
            etinfo.trackedinaoi = eyes_temp;
%            data.binary.eyetracking.results = [data.binary.eyetracking.results;[{trial},{etinfo}]];
            end
            
            
            % Distractor Onset         
            if choice_made == false;
                if randi(1) == 1 % Will currently only do the static image set. Switch this number to 2 to turn the flickering back on. 
                    data.binary.distractor.type(trial) = 1;
                    for frame = 1:DistractorTimeFrames - 1
                        % Distractor type 1; It just appears               
                        % Draw the same images as before
                        % Now add in the distractor image
                        Screen('DrawTexture', exp_screen, distractor, [], data.binary.distractorLoc);
                        vbl = Screen(exp_screen,'Flip', vbl + (1-.5) * ifi);
                        if frame == 1 
                            data.binary.timeStamp.distractorOn(trial) = GetSecs;
                        end
                    end
                end
            end
            % Now the remaining frames in the current trial
            
            RemainingTimeFrames = round(((4-(data.binary.timeStamp.FirstFixationCompleted(trial) - data.binary.timeStamp.stimOn(trial)))/ ifi));
            
            if choice_made == false;
                for frame = 1:RemainingTimeFrames - 1 
                    Screen('TextSize', exp_screen, txt_size.fixCross);  
                    Screen('DrawTexture', exp_screen, choiceImg{1}, [], data.binary.leftFoodLoc);  
                    Screen('DrawTexture', exp_screen, choiceImg{2}, [], data.binary.rightFoodLoc);           
                    Screen('FrameRect', exp_screen, txt_color, data.binary.left_box, box_left_thickness);
                    Screen('FrameRect', exp_screen, txt_color, data.binary.right_box, box_right_thickness);
                    DrawFormattedText(exp_screen,'+','center','center',txt_color,wrapat,[],[],vSpacing);
                    vbl = Screen(exp_screen,'Flip', vbl + (1-.5) * ifi);
                    if frame == 1 
                        data.binary.timeStamp.remainingOn(trial) = GetSecs;
                    end
                    [keyIsDown, ~, keyCode] = KbCheck;
                    if keyIsDown && any(keyCode(data.binary.resp_key_codes)) && choice_made == false
                        data.binary.timeStamp.RT(trial) = GetSecs;
                        data.binary.RT(trial) = data.binary.timeStamp.RT(trial) - ...
                        data.binary.timeStamp.stimOn(trial);
                        data.binary.choice{trial} = KbName(keyCode); % 1! or 0)   
                        if strcmp(data.binary.choice{trial},'1!')
                            box_left_thickness = 8;
                            choice_made = true;
                            break
                        elseif strcmp(data.binary.choice{trial},'0)')
                            box_right_thickness = 8;
                            choice_made = true;
                            break
                        end
                    elseif keyIsDown && any(keyCode(exitKeys))
                        sca; return
                    end
                end
            end
        % No distraction condition.
        else 
            data.binary.distractor.type(trial) = 0;
                for frame = 1: round(Trial_Length/ifi) - 1
                    % Draw the screen
                    Screen('TextSize', exp_screen, txt_size.fixCross);
                    Screen(exp_screen, 'FillRect', bg_color);
                    % get images
                    Screen('DrawTexture', exp_screen, choiceImg{1}, [], data.binary.leftFoodLoc);
                    Screen('DrawTexture', exp_screen, choiceImg{2}, [], data.binary.rightFoodLoc);
        

                    % draw boxes around foods
                    Screen('FrameRect', exp_screen, txt_color, data.binary.left_box, box_left_thickness);
                    Screen('FrameRect', exp_screen, txt_color, data.binary.right_box, box_right_thickness);
                    
                    DrawFormattedText(exp_screen,'+','center','center',txt_color,wrapat,[],[],vSpacing);

                    % flip images and text
                    Screen(exp_screen,'Flip');
                    if frame == 1
                        data.binary.timeStamp.stimOn(trial) = GetSecs;
                        data.binary.timeStamp.distractorOn(trial) = 0;
                        data.binary.timeStamp.remainingOn(trial) = 0;
                    end
                    [keyIsDown, ~, keyCode] = KbCheck;
                    if keyIsDown && any(keyCode(data.binary.resp_key_codes)) && choice_made == false
                        data.binary.timeStamp.RT(trial) = GetSecs;
                        data.binary.RT(trial) = data.binary.timeStamp.RT(trial) - ...
                        data.binary.timeStamp.stimOn(trial);
                        data.binary.choice{trial} = KbName(keyCode); % 1! or 0)   
                        if strcmp(data.binary.choice{trial},'1!')
                            box_left_thickness = 8;
                            choice_made = true;
                            break
                        elseif strcmp(data.binary.choice{trial},'0)')
                            box_right_thickness = 8;
                            choice_made = true;
                            break
                        end
                    elseif keyIsDown && any(keyCode(exitKeys))
                        sca; return
                    end 
                end
        end
    tic;
    [lefteye, righteye, timestamp, eyesize] = tetio_readGazeData;
    gazeData{trial}.left              = lefteye;
    gazeData{trial}.right             = righteye;
    gazeData{trial}.timestamp         = timestamp;
    gazeData{trial}.sz                = eyesize;
    toc
    tetio_stopTracking; % stop eye tracker %Also check this
    save(dataFName, 'data','gazeData'); % This might be a problem - won't save gazedata then. 
        

     if choice_made == true;
        % Draw the screen
        Screen('TextSize', exp_screen, txt_size.fixCross);
        Screen(exp_screen, 'FillRect', bg_color);
        % get images
        Screen('DrawTexture', exp_screen, choiceImg{1}, [], data.binary.leftFoodLoc);
        Screen('DrawTexture', exp_screen, choiceImg{2}, [], data.binary.rightFoodLoc);
        % draw boxes around foods03
        Screen('FrameRect', exp_screen, txt_color, data.binary.left_box, box_left_thickness);
        Screen('FrameRect', exp_screen, txt_color, data.binary.right_box, box_right_thickness);
        DrawFormattedText(exp_screen,'+','center','center',txt_color,wrapat,[],[],vSpacing);
        % flip images and text
        Screen(exp_screen,'Flip');
        data.binary.timeStamp.feedbackOn(trial) = GetSecs;
        WaitSecs(.4);
     else
        % Participant didn't respond quickly enough. 
        % Draw the screen
        Screen('TextSize', exp_screen, txt_size.fixCross);
        Screen(exp_screen, 'FillRect', bg_color);
        % get images
        Screen('DrawTexture', exp_screen, choiceImg{1}, [], data.binary.leftFoodLoc);
        Screen('DrawTexture', exp_screen, choiceImg{2}, [], data.binary.rightFoodLoc);
        % draw boxes around foods
        Screen('FrameRect', exp_screen, no_choice_color, data.binary.left_box, 8);
        Screen('FrameRect', exp_screen, no_choice_color, data.binary.right_box, 8);
        DrawFormattedText(exp_screen,'Slow!','center','center',no_choice_color,wrapat,[],[],vSpacing);
        % flip images and text
        Screen(exp_screen,'Flip');
        data.binary.timeStamp.feedbackOn(trial) = GetSecs;
        WaitSecs(.4);
     end





        % ----- fixation
    Screen('TextSize', exp_screen, txt_size.fixCross);
    Screen(exp_screen, 'FillRect', bg_color);
    DrawFormattedText(exp_screen,'+','center','center',txt_color,wrapat,[],[],vSpacing);
    Screen(exp_screen,'Flip');
    data.binary.timeStamp.fixOn(trial) = GetSecs;
    WaitSecs(data.binary.reset_screen(trial));

    
    % Half-way break
    if trial == round(data.binary.nTrials/2);
        Screen('TextSize', exp_screen, txt_size.fixCross);
        Screen(exp_screen, 'FillRect', bg_color);
        DrawFormattedText(exp_screen,'You are at the halfway point. \n\n\n This is a 20 second break. The task will continue afterwards.','center','center',txt_color,wrapat,[],[],vSpacing);     
        Screen(exp_screen,'Flip');
        WaitSecs(20);
        Screen('TextSize', exp_screen, txt_size.fixCross);
        Screen(exp_screen, 'FillRect', bg_color);
        DrawFormattedText(exp_screen,'+','center','center',txt_color,wrapat,[],[],vSpacing);
        Screen(exp_screen,'Flip');
        WaitSecs(1.5);
    end
end
% Save eyetracking data
%[lefteye, righteye, timestamp, eyesize] = tetio_readGazeData;
%gazeData{trial}.left              = lefteye;
%gazeData{trial}.right             = righteye;
%gazeData{trial}.timestamp         = timestamp;
%gazeData{trial}.sz                = eyesize;
%data.binary.task_end = GetSecs;
%tetio_stopTracking; % stop eye tracker
save(dataFName, 'data','gazeData');

    
% Figure out the chosen food
data.binary.chosen_trial = randi(data.binary.nTrials);
if iscellstr(data.binary.choice(data.binary.chosen_trial))
    if strmatch(data.binary.choice(data.binary.chosen_trial),'1!')
        data.binary.chosen_food = data.binary.imgNamesUseInOrder{data.binary.chosen_trial, 1};
        imgfile_chosen = imread(['stimuli/FoodImages/' data.binary.imgNamesUseInOrder{data.binary.chosen_trial, 1}]);
    elseif strmatch(data.binary.choice(data.binary.chosen_trial),'0)')
        data.binary.chosen_food = data.binary.imgNamesUseInOrder{data.binary.chosen_trial, 2};
        imgfile_chosen = imread(['stimuli/FoodImages/' data.binary.imgNamesUseInOrder{data.binary.chosen_trial, 2}]);
    else
        random_number = randi(2);
        data.binary.chosen_food = data.binary.imgNamesUseInOrder{data.binary.chosen_trial, random_number};
        imgfile_chosen = imread(['stimuli/FoodImages/' data.binary.imgNamesUseInOrder{data.binary.chosen_trial, random_number}]);
    end
else
    data.binary.chosen_food = data.binary.imgNamesUseInOrder{data.binary.chosen_trial, (randi(2))};
end
disp(data.binary.chosen_food)
DrawFormattedText(exp_screen,['You are done with the experiment!\n\n You won:'],'center',340,...
txt_color,wrapat,[],[],vSpacing);
chosenImg = Screen(exp_screen, 'MakeTexture',imgfile_chosen);
Screen('DrawTexture', exp_screen, chosenImg, [], data.binary.distractorLoc);
DrawFormattedText(exp_screen,['Please wait for the experimenter.'],'center',860,...
txt_color,wrapat,[],[],vSpacing);
Screen(exp_screen,'Flip');
save(dataFName, 'data','gazeData');

WaitSecs(5)
sca

% Disconnect from Tobii
if exist('Calib','var')
    tetio_disconnectTracker;
    tetio_cleanUp;
end

end




