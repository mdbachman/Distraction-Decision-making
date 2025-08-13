%% Sets up estimation of DDM parameters
% This particular one is for the no distractor trials, using Equation 1 
% from the methods.

% Author: Matthew D. Bachman. Based on scripts by Nicolette J. Sullivan.

%% get cluster settings
% Get dataset parameters
dir = '/mnt/munin//Huettel/FoodPrime.01/Analysis/Matthew';
s = SUBJNO;
grp = GRP;
cond = 'noDist';
fprintf('\n%s, subj %d, set %s %d\n',cond, s, num2str(grp))

%% get per-trial data
data=csvread(fullfile(dir,['DDM_set',num2str(grp),'_nodist.csv']));
data = data(data(:,1) == s,:);
vals = [data(:,2) - data(:,3)]; % values
realchoices = data(:,4); % choice
realrts = round(data(:,5)); % response time

%% model specific parameters
% param order: temp, ndt, b
lb = [.00001 1                                .5];
ub = [.01   round(nanmean(nanmean(realrts))) 5];
integers = 2;

% for grid
possparams = combvec(linspace(lb(1), ub(1), 10), ...
    linspace(lb(2), ub(2), 10), ...
    linspace(lb(3), ub(3), 10))';
possparams(:,integers) = round(possparams(:,integers));

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
    ['output_', num2str(s) cond num2str(grp) 'Data.mat']);
if ~exist(fullfile(dir,'results'),'dir')
    mkdir(fullfile(dir,'results'));
end


%% grid search

gridchisq_all = zeros(size(possparams,1), 1);
tic
for i = 1:size(possparams,1)
    gridchisq_all(i) = fitFcn_noDist(vals, realchoices, realrts, nsims, ...
        possparams(i,:));
end
gridtime=toc;
gridsorted_all=sortrows([gridchisq_all possparams]);
save(savefile) % save all variables

%% GA fit
options.InitialPopulationMatrix = gridsorted_all(1:nparents,2:end);
tic;
[estparams_all, chisq_all, exitflag_all, output_all, population_all, scores_all] = ...
    ga(@(params)(fitFcn_noDist(vals, realchoices, realrts, nsims, params)), ...
    nparams,[],[],[],[], lb, ub, [], integers, options);
gatime_all=toc;

save(savefile)% save all variables