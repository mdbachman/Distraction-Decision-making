%% Sets up estimation of aDDM parameters
% This particular one is for Equation 3 in Methods.

% Author: Matthew D. Bachman. Based on scripts by Nicolette J. Sullivan.
a=1;
try 
    type = 'TYPE';
    if strcmp(type,'recov')
        isrecov=true;
    else
        isrecov=false;
    end
  
    %% get cluster settings
    dir = 'DIR';
    s = SUBJNO;
    if ~isrecov
        name = 'MOD';
        cond = 'noDist';
        grp = GRP;
    end
    RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)))

    % saving
    if isrecov
        fprintf('recovery agent %d\n',s)
        savefile = fullfile(dir,'results_addm',...
            ['recov_addm_', num2str(s) 'Data_firstFixnoRV.mat']);
    else
        fprintf('s %d, %s exp %d\n',s, cond, grp)
        savefile = fullfile(dir,'results_addm',...
            ['addm_s', num2str(s) '_' cond '_set' num2str(grp) '_Data_v2_firstFixnoRV.mat']);
    end
    if ~exist(fullfile(dir,'results_addm'),'dir')
        mkdir(fullfile(dir,'results_addm'));
    end

    if exist(savefile,'file')
        load(savefile)
        dir=pwd;
    end
    
    %% get behavioral data
    % % for recovery
    if isrecov
        recov=load(fullfile(dir,'recovery_addm.mat'));

        recov.rts = recov.rts/10;
        keep = recov.rts(:,s) > 30 & recov.rts(:,s) < 1500;

        % ALREADY MAPPED
        vals = recov.vals(:,:,s); % values

        realchoices = recov.choices(:,s); % choice
        realrts = recov.rts(:,s); % response time
    else
        % for subject data
        [behav, gaze] = getGaze(s, cond, grp, dir);
        if isempty(behav)
            fprintf('no px data for %d. exiting\n',s)
            return
        end
        vals = behav.vals;
        realchoices = behav.realchoices;
        realrts = behav.realrts;
        keep = true(length(realchoices),1);      
    end        

    %% get gaze data
    if isrecov
        % for recovery: get addm data
        tmp = recov.gazeMatrix(recov.gazeMatrix(:,1)==s,:);
        data = tmp(tmp(:,1)==s,:);
        startDelays = data(:,5)/10;
        fixItem = data(:,6);
        fixTime = data(:,7);
        gaze.vals = data(:,3:4);
        gaze.trial = data(:,2);
        % convert fixTime from ms to positions on drates array
        fixTime = floor(fixTime/10);
        gaze.probFirstFixLeft = unique(data(:,end)); % is last col of *_behav.csv in px data

        % for recovery - get addm data
        transitiondata = recov.nongazeMatrix(recov.nongazeMatrix(:,1)==s,:);
        count=1;
        for t = unique(transitiondata(:,3))'
            ind = find(t == transitiondata(:,3));
            nongaze.vals(count,:) = transitiondata(ind(1),4:5);
            nongaze.nonfix(count) = transitiondata(ind(1),8)/10; % total nonfix time per trial
            count=count+1;
        end

        % get emperical distribution of gaze for each value difference
        possdiffs = unique(vals,'rows');
        for i = 1:size(possdiffs,1)
            count=1;
            ind = gaze.vals(:,1) == possdiffs(i,1) & gaze.vals(:,2) == possdiffs(i,2);
            for t = unique(gaze.trial(ind))'
                tind = gaze.trial == t & ind;
                gaze.possPats{i}{count} = fixItem(tind);
                count=count+1;
            end
            gaze.possStDel{i} = unique(startDelays(ind));
            gaze.possTimes{i}{1} = fixTime(fixItem==1);
            gaze.possTimes{i}{2} = fixTime(fixItem==2);
            
            nongazeind = nongaze.vals(:,1) == possdiffs(i,1) & nongaze.vals(:,2) == possdiffs(i,2);
            gaze.nonfixTimes{i} = nongaze.nonfix(nongazeind);
        end
        clear recov; % so we don't have to save it        
    end


    %% get matched cval trials
    if ~isrecov && ~exist('trials_ddm','var')
        goaldiff=0;
        goaldiff_rt=1;
        pd_ddm = 1;
        pd_test = 0;
        rt_ddm = 100;
        rt_test = 0;
        iter=1;
        while abs(pd_ddm - pd_test) > goaldiff || ...
                abs(rt_ddm - rt_test) > goaldiff_rt

            trialsorted = sortrows([rand(sum(keep), 1) (1:sum(keep))']);
            trials_ddm = trialsorted(1:ceil(sum(keep)/2), 2);
            trials_test = trialsorted((ceil(sum(keep)/2)+1):end, 2);

            pd_ddm = sum(realchoices(trials_ddm)==1)/length(trials_ddm);
            pd_test = sum(realchoices(trials_test)==1)/length(trials_test);

            rt_ddm = nanmean(realrts(trials_ddm));
            rt_test = nanmean(realrts(trials_test));

            iter=iter+1;
            if iter>100
                goaldiff = goaldiff+.001;
                goaldiff_rt = goaldiff_rt+1;
                iter=1;
            end
        end
    end

    %% search settings
    nsims = 5000;
    % param order: temp, ndt, b, theta
    if isrecov
        lb = [.0005 1   1  .2];
        ub = [.02   125 3   1];
    else
        lb = [.00005 1   .5 .01];
        ub = [.1    130 2   1];
    end

    integers = [];
    nparams = size(lb,2);
    % for grid
    possparams = combvec(linspace(lb(1), ub(1), 5), ...
        linspace(lb(2), ub(2), 5), ...
        linspace(lb(3), ub(3), 5), ...
        linspace(lb(4), ub(4), 5))';
    possparams(:,integers) = round(possparams(:,integers));

    % for GA
    if nparams <=5
        nparents=50;
    else
        nparents=200;
    end
    options.Display = 'off';
    options.MaxGenerations = nparents*200;
    options.PopulationSize = nparents;

    %% grid search
    if ~exist('gridsorted_all','var')
        gridchisq_all = zeros(size(possparams,1), 1);
        for i = 1:size(possparams,1)
            gridchisq_all(i) = fitFcn_addm_noDist_firstFixnoRV(vals, realchoices, realrts, nsims, ...
                gaze, possparams(i,:));
        end
        gridsorted_all=sortrows([gridchisq_all possparams]);
        save(savefile)% save all variables
    end
    %% GA fit
        options.InitialPopulationMatrix = gridsorted_all(1:nparents,2:end);
        tic;
        [estparams_all, chisq_all, exitflag_all, output_all, population_all, scores_all] = ...
            ga(@(params)(fitFcn_addm_noDist_firstFixnoRV(vals, realchoices, realrts, nsims, gaze, params)), ...
            nparams,[],[],[],[], lb, ub, [], integers, options);
        gatime_all=toc;
        save(savefile)% save all variables
catch ME
    fprintf('subj %d error\n', s)
    if exist('ME','var')
        ME    
        savefile = fullfile(dir,'results',...
            ['error', num2str(s) 'Data_v2_firstFixnoRV.mat']);
        save(savefile)
        ME.stack
    end
end

a=1;
