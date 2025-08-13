function chisq = fitFcn_Dist_decay(vals, realchoices, realrts, distonset, distoffset, drate, ndt, boundary, nsims, params,preDistLength,DistLength)
%% Fits DDM parameters
% This particular one is for decay models with NO modified first
% fixation.

% Author: Matthew D. Bachman. Based on scripts by Nicolette J. Sullivan.

% Initialize variables
maxrt = 440;
delta = drate; % Drift rate, as estimated from no distractor trials
ndt = ndt;   % Non-decision time, as estimated from no distractor trials
b = boundary;     % Boundary, as estimated from no-distractor trials
noise = .1;        % Noise 
decayParam = params(1); % The exact parameter currently being estimated.
possdiffs = unique(vals,'rows');
drate = delta * possdiffs; 

p = zeros(length(possdiffs), 7, 2);
pi = p;
pratio = zeros(7, 2);
acrossbins = zeros(1, length(possdiffs));
simchoices = zeros(1,nsims);
simrts = simchoices;

% Begin simulations for each value-difference.
for i = 1:length(possdiffs)

    % clear key variables
    simchoices(:)=0;
    simrts(:)=0;
    p(:)=0;
    pi(:)=0;
    pratio(:)=0;

    % begin to simulate.
    drift = zeros(nsims,maxrt);

    for thisSim = 1:nsims
        % Select out random preDist period
        if length(preDistLength) == 1 
            this_preDistLength = preDistLength;
        else
            this_preDistLength = randsample(preDistLength,1);
        end

        % Select out random DistLength
        if length(DistLength) == 1 
            this_distLength = DistLength;
        else
            this_distLength = randsample(DistLength,1);
        end

        % pre-distractor
        for kk = ndt+1:ndt+this_preDistLength
            drift(thisSim,kk) = drift(thisSim,kk-1) + drate(i) + normrnd(0, noise);
        end
        % decay period
        % takes the LAST value before the distractor hit and shrinks it by decamParam.
        for jj = kk+1:kk+this_distLength
            drift(thisSim,jj) = decayParam* drift(thisSim,kk) + normrnd(0, noise);
        end

        %% now continues with the rest of the process.
         drift(thisSim,jj+1:end) = drift(thisSim,jj) + cumsum([ (repmat(drate(i), 1, maxrt-jj)  + normrnd(0, noise,1, maxrt - jj))], 2);
    end

    % Extract the corresponding RTs and choices.
    [crossupper, crossupperrt] = max(drift >= b,[],2);
    [crosslower, crosslowerrt] = max(drift <= -b,[],2);        
    simchoices((crossupper & ~crosslower) | ...
        (crossupper & crosslower & crossupperrt < crosslowerrt)) = 1;
    simchoices((crosslower & ~crossupper) | ...
        (crossupper & crosslower & crosslowerrt < crossupperrt)) = -1;
    simrts(simchoices==1) = crossupperrt(simchoices==1);
    simrts(simchoices==-1) = crosslowerrt(simchoices==-1);
    
    % bin real data
	valind = vals == possdiffs(i);
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