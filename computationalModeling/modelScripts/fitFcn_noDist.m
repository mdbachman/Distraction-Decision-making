function chisq = fitFcn_noDist(vals, realchoices, realrts, nsims, params)
%% Fits DDM parameters
% This fits the regular DDM (equation 1 in Methods)
% Author: Matthew D. Bachman. Based on scripts by Nicolette J. Sullivan.

% Initialize variables.
maxrt = 400;
% param order: temp, ndt, b
delta = params(1); % Drift Rate
ndt = params(2);   % Non-decision time
b = params(3);     % Boundary
noise = .1;        % Noise 
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

    % simulate process
    drift = cumsum([zeros(nsims, ndt) ... 
        repmat(drate(i), nsims, maxrt-ndt) + ...
        normrnd(0, noise, nsims, maxrt-ndt)
        ], 2);    

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