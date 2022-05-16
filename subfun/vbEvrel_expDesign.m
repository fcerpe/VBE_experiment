% (C) Copyright 2020 CPP visual motion localizer developpers

function [cfg] = vbEvrel_expDesign(cfg, displayFigs)
    % 
    % EXPERIMENT DESIGN
    % 12 runs: fr - br - fr - br - fr - br - fr - br - fr - br - fr - br
    % Within each run, there are 12 blocks 
    % each block represent one of the 4 conditions (rw - pw - nw - fs)
    % each condition is repeated 3 times, to cover all the stimuli
    %
    % TARGETS
    % either 0 or 1 in each block
    % Rules:
    % (1) Targets (repetition) cannot be relative to the first stimulus of a block
    % targets are 
    % (2) Targets are balanced across conditions: 
    % - in each run, each condition has at least 1 target
    % - in runs 1/3/5, conditions 1 (rw) and 2 (pw) have two targets
    % - in runs 2/4/6, conditions 3 (nw) and 4 (fs) have two targets
    % - targets are balanced in the position they appear. Every runs has 2
    % targets relative to stimulus 2, 2 relative to stimulus 3 and 2
    % relative to stimulus 4
    %
    % WORKFLOW:
    % we are creating the presentation matrix for the whole experiment of
    % 12 runs
    %
    % Input:
    % - cfg: parameters returned by setParameters
    % - displayFigs: a boolean to decide whether to show the basic design
    % matrix of the design
    %
    % Output:
    % - ExpParameters.designBlockNames = cell array (nr_blocks, 1) with the
    %                                    name for each block
    % - cfg.designFixationTargets = array (nr_blocks, numEventsPerBlock)
    %                               showing for each event if it should be accompanied by a target

    %% Check inputs and distribute targets

    % Set to 1 for a visualtion of the trials design order
    if nargin < 2 || isempty(displayFigs)
        displayFigs = 0;
    end

    % Set variables here for a dummy test of this function
    if nargin < 1 || isempty(cfg)
        error('give me something to work with');
    end

    [NB_BLOCKS, NB_REPETITIONS, NB_EVENTS_PER_BLOCK, MAX_TARGET_PER_BLOCK] = getDesignInput(cfg);
%     [~, C1_INDEX, C2_INDEX, C3_INDEX, C4_INDEX] = assignConditions(cfg);

%     if mod(NB_REPETITIONS, MAX_TARGET_PER_BLOCK) ~= 0
%         error('number of repetitions must be a multiple of max number of targets');
%     end
    
   
    %% Get pre-made design infos
    load('inputs/experimentDesignSupplement.mat');

    whichCond = "";
    % switch numbers for condition names in the condition order.
    % it's annoying
<<<<<<< HEAD
    for r = 1:size(conditionsOrder,1)
        for b = 1:size(conditionsOrder,2)
            whichCond(r,b) = cfg.design.names{conditionsOrder(r,b)'};
        end
    end

    whichCond = whichCond';
       
    %% Create ISI matrix with variations
    isi = [0.8 1 1.2];
    
    totIsi = numStimPerBlock-1;     % how many ISI we have per block?
    numIsiPerBlock = [sum(totIsi(1:12))     sum(totIsi(13:24))   sum(totIsi(25:36)) ...
                      sum(totIsi(37:48))    sum(totIsi(49:60))   sum(totIsi(61:72)) ...
                      sum(totIsi(73:84))    sum(totIsi(85:96))   sum(totIsi(97:108)) ...
                      sum(totIsi(109:120))  sum(totIsi(121:132)) sum(totIsi(133:144))];  
    % re-arrange for readability
    totIsi = reshape(totIsi,12,12);
    
    % matrix with all the isi (and 0 in case there is no target and no
    % extra isi)
    isiMatrix = zeros(12,4,12);

=======
    switch cfg.subject.firstCond
        case 1
            currentConditionOrder = frfirst_conditionsOrder;
        case 2
            currentConditionOrder = brfirst_conditionsOrder;
    end
    
    for r = 1:size(currentConditionOrder,1)
        for b = 1:size(currentConditionOrder,2)
            whichCond(r,b) = cfg.design.names{currentConditionOrder(r,b)'};
        end
    end

    whichCond = whichCond';
       
    %% Create ISI matrix with variations
    isi = [0.8 1 1.2];
    
    totIsi = numStimPerBlock-1;     % how many ISI we have per block?
    numIsiPerBlock = [sum(totIsi(1:12))     sum(totIsi(13:24))   sum(totIsi(25:36)) ...
                      sum(totIsi(37:48))    sum(totIsi(49:60))   sum(totIsi(61:72)) ...
                      sum(totIsi(73:84))    sum(totIsi(85:96))   sum(totIsi(97:108)) ...
                      sum(totIsi(109:120))  sum(totIsi(121:132)) sum(totIsi(133:144))];  
    % re-arrange for readability
    totIsi = reshape(totIsi,12,12);
    
    % matrix with all the isi (and 0 in case there is no target and no
    % extra isi)
    isiMatrix = zeros(12,4,12);

>>>>>>> a1954660d693fc8cf72133b965c4786e71cfa888
    for nI = 1:length(numIsiPerBlock)  
            isiArray = repmat(isi, 1, numIsiPerBlock(nI)/3);  % repeat matrix
            isiArray = shuffle(isiArray);                   % randomize it
            
            % re-arrange matrix
            for nB = 1:12
                isiMatrix(nB, 1:totIsi(nB,nI), nI) = isiArray(1:totIsi(nB,nI));
                isiArray(1:totIsi(nB,nI)) = [];
            end
    end    

    %% Now we do the easy stuff
    cfg.design.blockNames = vbEvrel_assignConditions(cfg);
    cfg.design.nbBlocks = NB_BLOCKS;
    cfg.design.nbRuns = 12;
    
    % Length of block is 10, plus possible repetition due to target
    cfg.design.blockLengths = reshape(numStimPerBlock,12,12); 
    cfg.design.blockMatrix = whichCond;
    cfg.design.presentationMatrix = stimOrderMatrix;
    cfg.design.targetMatrix = targetMatrix;
    cfg.design.isiMatrix = isiMatrix;

    clearvars ans conditionsOrder isiMatrix numStimPerBlock stimOrderMatrix StimuliPerBlock targetMatrix totIsi

end
