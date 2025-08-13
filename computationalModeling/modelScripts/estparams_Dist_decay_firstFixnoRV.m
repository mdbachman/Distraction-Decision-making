%% Sets up estimation of DDM parameters
% This particular one is for decay models with NO modified first
% fixation.

% Author: Matthew D. Bachman. Based on scripts by Nicolette J. Sullivan.
%% get cluster settings
% Get dataset parameters
dir = '/mnt/munin//Huettel/FoodPrime.01/Analysis/Matthew';
s = SUBJNO;
grp = GRP;
cond = 'Dist';
fprintf('\n%s, subj %d, set %s %d\n',cond, s, num2str(grp))

%% get per-trial data
data=csvread(fullfile(dir,['DDM_set',num2str(grp),'_dist.csv']));
data = data(data(:,1) == s,:);

vals = [data(:,2) data(:,3)]; % Get the value for the left/right option
realchoices = data(:,4); % choice
realrts = round(data(:,5)); % response time

% load old, pre-fit parameters from the no distractor dataset
oldparams=load(fullfile(dir,'results',['output_' num2str(s) 'noDist' num2str(grp) 'Data']));
drate    = oldparams.estparams_all(1);
ndt      = oldparams.estparams_all(2);
boundary = oldparams.estparams_all(3);

% load the gaze data to find the fixation information
[~, gaze] = getGaze(s, cond, grp, dir);

% Get some of the distractor information. Necessary for the models.
distonset = round(data(:,6));
distoffset = round(data(:,7));
distLength = round(nanmean(distoffset - distonset));
if grp==1
    firstFixDur = 10;
    preDistLength = 0;
    distLength = 40;
else
    preDistLength = data(:,8);
    distLength = data(:,9);
    firstFixDur = data(:,10);
end

%% model specific parameters - be sure these are changed
% lower bound is "eps" because actual zero can sometimes have wonky
% effects.
lb = [eps];
ub = [1];
integers = 2;

% for grid
possparams = combvec(linspace(lb(1), ub(1), 20))';

%% search settings

nsims = 5000;
nparams = size(lb,2);

% for GA
if nparams <=5
    nparents=50;
else
    nparents=200;
end
options.Display = 'off';
options.MaxGenerations = nparents*200;
options.PopulationSize = nparents;

% saving
savefile = fullfile(dir,'results',...
    ['output_', num2str(s) cond num2str(grp) 'Data_decay_firstFixnoRV.mat']);
if ~exist(fullfile(dir,'results'),'dir')
    mkdir(fullfile(dir,'results'));
end


%% grid search
gridchisq_all = zeros(size(possparams,1), 1);
tic
for i = 1:size(possparams,1)
    gridchisq_all(i) = fitFcn_Dist_decay_firstFixnoRV(vals, realchoices, realrts, distonset, distoffset, drate, ndt, boundary, nsims, ...
        possparams(i,:),gaze,preDistLength,distLength,firstFixDur);
end
gridtime=toc;
gridsorted_all=sortrows([gridchisq_all possparams]);
save(savefile)% save all variables

%% GA fit
options.InitialPopulationMatrix = gridsorted_all(1:length(possparams),2:end);
tic;
[estparams_all, chisq_all, exitflag_all, output_all, population_all, scores_all] = ...
    ga(@(params)(fitFcn_Dist_decay_firstFixnoRV(vals, realchoices, realrts, distonset, distoffset, drate,ndt, boundary, nsims, params,gaze,preDistLength,distLength,firstFixDur)), ...
    nparams,[],[],[],[], lb, ub, [], [], options);
gatime_all=toc;
save(savefile)% save all variables
