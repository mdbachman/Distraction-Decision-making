function [behav,gaze] = getGaze(s, cond, grp, dir)
% get gaze distributions, behavior, etc.

% CSV columns:
% 1 - subj 
% 2 - probability of first fixation to the left/default (one unique value
% per participant
% 3 - trial number (1=first trial experienced)
% 4 - valOpt1 (one unique value per trial)
% 5 - valOpt2 (one unique value per trial)
% 6 - choice (one unique value per trial)
% 7 - response time in ms (one unique value per trial)
% 8 - delay before looking at any option (one unique value per trial)
% 9 - item fixated on (1=left/def, 2=right/alt, 0=transition/noAOI fixated on)
% 10 - length of gaze to AOI (or length of transition)
% 11 - total of nonfixation time this trial (one unique value per trial)
% 12 - trial type.

data=csvread(fullfile(dir,['set' num2str(grp) '_addm.csv']));
data = data(data(:,1)==s, :);
if isempty(data)
    fprintf('no px data for %d. exiting\n',s)
    behav=[];
    gaze=[];
    return
end

% narrow it down to correct data per condition
if strmatch(cond,'noDist')
    data((find(data(:,12)==1)),:)=[];
elseif strmatch(cond,'Dist')
    data((find(data(:,12)==0)),:)=[];
end

% remove trials that weren't triggered.
if grp == 2
   data((find(data(:,12)==2)),:)=[];
end


% turn the fixations onto the distractor into non-unit fixations. better
% for simulations at least.
%data(find(data(:,9)>2),9) = 0; % this reduces only to left/right, removes distractor  and distractor+buffer.
data(find(data(:,9)>3),9) = 0; % this reduces only to left/right/distraction, removing distractor+buffer

% get per-trial data:
count=1;
for t = unique(data(:,3))'
    
    ind = find(data(:,3) == t,1,'first');
    behav.vals(count,:) = data(ind, 4:5);
    behav.realchoices(count,1) = data(ind,6); % choice
    behav.realrts(count,1) = data(ind,7) / 10; % response time

    count = count+1;
end
gaze.probFirstFixLeft = unique(data(:,2));
behav.possdiffs = unique(behav.vals,'rows');

% get emperical distribution of gaze for each value difference
gaze.vals = data(:, 4:5);
gaze.trial = data(:,3);
fixpatterns = data(:,9);
startDelays = data(:,8) / 10;
fixTime = floor(data(:,10) / 10); % convert fixTime from ms to positions on drates array

% accidently formatted the time units differently between grp 1 and 2.
if grp == 1
    startDist = data(:,13) / 10;
    durDist = data(:,14) / 10;
elseif grp == 2
    startDist = data(:,13) * 100;
    durDist = data(:,14) * 100;
end



for i = 1:size(behav.possdiffs,1)
    
    % find all data with this value difference
    ind = gaze.vals(:,1) == behav.possdiffs(i,1) & gaze.vals(:,2) == behav.possdiffs(i,2);
    if sum(ind)

        % get start and end points for distractors
        gaze.distStart{i} = unique(startDist(ind));
        gaze.distDur{i}   = unique(durDist(ind));
        % get all possible gaze patters (1 2 1, etc.)
        count=1;
        for t = unique(gaze.trial(ind))'
            tind = gaze.trial == t & ind;
            gaze.possPats{i}{count} = fixpatterns(tind);
            gaze.possPats{i}{count}(gaze.possPats{i}{count}==0) = [];
            count=count+1;
        end

        % get all start delays experienced
        if length(unique(startDelays(ind)))==1
            gaze.possStDel{i} = [unique(startDelays(ind)); unique(startDelays(ind))];
        else
            gaze.possStDel{i} = unique(startDelays(ind));
        end

        % get all fixation times for this value difference
        gaze.possTimes{i}{1} = fixTime(fixpatterns==1 & ind);
        gaze.possTimes{i}{2} = fixTime(fixpatterns==2 & ind);
        gaze.possTimes{i}{3} = fixTime(fixpatterns==3 & ind);
        
        if isempty(gaze.possTimes{i}{1})
            gaze.possTimes{i}{1} = [0 0];
        end
        if isempty(gaze.possTimes{i}{2})
            gaze.possTimes{i}{2} = [0 0];
        end
        if isempty(gaze.possTimes{i}{3})
            gaze.possTimes{i}{3} = [0 0];
        end

        % get total nonfixation time for trials with this val. diff.
        if length(unique(data(ind,11))) <= 1
            gaze.nonfixTimes{i} = [0 0]; % required by randsample
        else
            gaze.nonfixTimes{i} = unique(data(ind,11) / 10);
        end



    else
        disp('error, no gaze data for this value difference')
    end
end


end