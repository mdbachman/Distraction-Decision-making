function chisq = fitFcn_addm_Dist(vals, realchoices, realrts, nsims, gaze, params)
%% Fits the attention drift-diffusion model
% Based on Equation 2 in Methods.
% Author: Matthew D. Bachman. Based on scripts by Nicolette J. Sullivan.

maxrt = 440;
delta = params(1);
ndt = params(2);
b = params(3);
theta = params(4);
noise = .1;
possdiffs = unique(vals,'rows');
drate = delta * [possdiffs(:,1), possdiffs(:,2)];

p = zeros(length(possdiffs), 7, 2);
pi = p;
pratio = zeros(7, 2);
acrossbins = zeros(1, length(possdiffs));
simchoices = zeros(1,nsims);
simrts = simchoices;
for i = 1:size(possdiffs,1)
    
    theseNonFix(:,1) = randsample(gaze.nonfixTimes{i}, nsims, 1);
    thisStartDelay = randsample(gaze.possStDel{i},1,1);
    
    % clear key variables
    simchoices(:)=0;
    simrts(:)=0;
    p(:)=0;
    pi(:)=0;
    pratio(:)=0;

    % randomly draw a fixation pattern and fixation time from empirical distribution
    whichpat = randi(size(gaze.possPats{i},2),1,nsims);
    whichtime{1} = randi(size(gaze.possTimes{i}{1},1), 1, nsims);
    whichtime{2} = randi(size(gaze.possTimes{i}{2},1), 1, nsims);
    % build drift based on those patterns/times
    drift = zeros(nsims, maxrt);
    for j = 1:nsims
        thispat = gaze.possPats{i}{whichpat(j)};
        
        thisdrate = zeros(1, floor(thisStartDelay)); 
        for idx = 1:length(thispat)
            if idx == 1
                fItem = randsample([1 2], 1, true, ...
                    [gaze.probFirstFixLeft 1-gaze.probFirstFixLeft]);
            else
                fItem = thispat(idx);
            end
            nfItem = 3-thispat(idx);
            fTime = gaze.possTimes{i}{fItem}(whichtime{fItem}(j));
            
            fixdrate =  drate(i,fItem) - theta * drate(i, nfItem); 
            
            thisdrate = [thisdrate, repmat(fixdrate, 1, fTime)];
        end
        drift(j, 1:length(thisdrate)) = thisdrate;
    end
    drift = drift(:,1:maxrt); % rest are uninterrupted last fixations
    drift = cumsum(drift + normrnd(0,noise, nsims, size(drift,2)),2);

    [crossupper, crossupperrt] = max(drift >= b,[],2);
    [crosslower, crosslowerrt] = max(drift <= -b,[],2);        
    simchoices((crossupper & ~crosslower) | ...
        (crossupper & crosslower & crossupperrt < crosslowerrt)) = 1;
    simchoices((crosslower & ~crossupper) | ...
        (crossupper & crosslower & crosslowerrt < crossupperrt)) = -1;
    thisndt = ndt;
    
    simrts(simchoices==1) = crossupperrt(simchoices==1) + thisndt + theseNonFix(simchoices==1);
    simrts(simchoices==-1) = crosslowerrt(simchoices==-1) + thisndt + theseNonFix(simchoices==-1);

    % bin real data
    valind = vals(:, 1) == possdiffs(i, 1) & vals(:, 2) == possdiffs(i, 2);
    N = sum(valind); % n observations per "compatibility condition"
    Ntop=sum(realchoices==1 & valind);
    Nbot=sum(realchoices==-1 & valind);

    if Ntop>0
        if Ntop>10
            topquants = [.1 .3 .5 .7 .9];
        elseif Ntop <=5
            topquants = .5;
        elseif Ntop <=10
            topquants = [.3 .5 .9];
        end
        
        % bin observed RTs for top choices
        RTbins_top = [0 quantile(realrts(realchoices==1 & valind), ...
            topquants) Inf];
        [~, ~, realrtbin_top] = histcounts(realrts, RTbins_top);
        
        % for simulated data, get probability
        if any(simchoices == 1)
            % bin simulated RTs using real top choice bins
            [~, ~, simrtbin] = histcounts(simrts, RTbins_top);
            % get p(this choice & RT bin)
            for j = 1:length(RTbins_top)-1
                pi(i, j, 1) = sum(simrtbin == j & simchoices == 1) / ...
                    sum(simchoices == 1);% predicted proportion
            end
        end
        pi(i,pi(i,:,1)==0,1)=eps;% avoiding infinity
        
        % for observed data, get probability
        for j = 1:length(RTbins_top)-1
            % get p(this choice & RT bin)
            p(i,j, 1) = sum(realrtbin_top == j & valind & realchoices == 1) ./ ...
                sum(realchoices == 1 & valind);
            pratio(j,1) = (p(i,j,1) - pi(i,j,1))^2 / pi(i,j,1);
        end
        
    end
    
    if Nbot>0
        
        if Nbot>10
            botquants = [.1 .3 .5 .7 .9];
        elseif Nbot <=5
            botquants = .5;
        elseif Nbot <=10
            botquants = [.3 .5 .9];
        end
        
        RTbins_bot = [0 quantile(realrts(realchoices== -1 & valind), ...
            botquants) Inf];
        [~, ~, realrtbin_bot] = histcounts(realrts, RTbins_bot);
        
        if any(simchoices==-1)
            [~, ~, simrtbin] = histcounts(simrts, RTbins_bot);
            for j = 1:length(RTbins_bot)-1
                pi(i, j, 2) = sum(simrtbin == j & simchoices == -1) / ...
                    sum(simchoices==-1);% predicted proportion
            end
        end
        pi(i,pi(i,:,2)==0,2)=eps; % avoiding infinity
         
        for j = 1:length(RTbins_bot)-1
            p(i,j, 2) = sum(realrtbin_bot == j & valind & realchoices == -1) ./ ...
                sum(realchoices== -1 & valind);
            pratio(j,2) = (p(i,j,2) - pi(i,j,2))^2 / pi(i,j,2);
        end
    end
    
    acrossbins(i) = N * nansum(pratio(:)); % sum across all bins and both choice types (top and bottom)

end

chisq = nansum(acrossbins(~isinf(acrossbins)));
if isinf(chisq)% avoiding infinity
   chisq = realmax;
end


end