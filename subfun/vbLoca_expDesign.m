% (C) Copyright 2020 CPP visual motion localizer developpers

function [cfg] = expDesign(cfg, displayFigs)
    % TO MODIFY: no more static / motion. Just static and show some images
    % 
    % Creates the sequence of blocks and the events in them
    % (Gives better results than randomised).
    %
    % Style guide: constants are in SNAKE_UPPER_CASE
    %
    % TARGETS
    % Pseudorandomization rules:
    % (1) If there are more than 1 target per block we make sure that they are at least 2
    % events apart.
    % (2) Targets cannot be on the first or last event of a block.
    % (3) Targets can not be present more than NB_REPETITIONS - 1 times in the same event
    % position across blocks.
    %
    % Input:
    % - cfg: parameters returned by setParameters
    % - displayFigs: a boolean to decide whether to show the basic design
    % matrix of the design
    %
    % Output:
    % - ExpParameters.designBlockNames = cell array (nr_blocks, 1) with the
    %                                    name for each block
    % - cfg.designDirections = array (nr_blocks, numEventsPerBlock)
    %                          with the direction to present in a given block
    % - 0 90 180 270 indicate the angle
    % - -1 indicates static
    % - cfg.designSpeeds = array (nr_blocks, numEventsPerBlock) * speedEvent;
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
    [~, C1_INDEX, C2_INDEX, C3_INDEX, C4_INDEX, C5_INDEX, C6_INDEX] = assignConditions(cfg);

%     if mod(NB_REPETITIONS, MAX_TARGET_PER_BLOCK) ~= 0
%         error('number of repetitions must be a multiple of max number of targets');
%     end

    % Modified: added the 0 targets condition   
    RANGE_TARGETS = 0:MAX_TARGET_PER_BLOCK;
    
    % Usual way of doing it
    targetPerCondition = repmat(RANGE_TARGETS, 1, NB_REPETITIONS / (MAX_TARGET_PER_BLOCK+1));
    
    numTargetsForEachBlock = zeros(1, NB_BLOCKS);
    numTargetsForEachBlock(C1_INDEX) = shuffle(targetPerCondition);
    numTargetsForEachBlock(C2_INDEX) = shuffle(targetPerCondition);
    numTargetsForEachBlock(C3_INDEX) = shuffle(targetPerCondition);
    numTargetsForEachBlock(C4_INDEX) = shuffle(targetPerCondition);
    numTargetsForEachBlock(C5_INDEX) = shuffle(targetPerCondition);
    numTargetsForEachBlock(C6_INDEX) = shuffle(targetPerCondition);
    
    
    %% Give the blocks the condition names and pick which events are targets
    % Task is 1-back: need to repeat random images either once or twice, based on
    % # of targets 
    % repetitionTargets: 
        
    while 1
        repetitionTargets = zeros(NB_BLOCKS, NB_EVENTS_PER_BLOCK);
       
        for iBlock = 1:NB_BLOCKS
            % Set target
            % - if there are 2 targets per block we make sure that they are at least
            % 2 events apart
            % - targets cannot be on the first or last event of a block
            % - no more than 2 target in the same event order

            nbTarget = numTargetsForEachBlock(iBlock);
            chosenPosition = setTargetPositionInSequence(NB_EVENTS_PER_BLOCK, ...
                                                         nbTarget, ...
                                                         [1 NB_EVENTS_PER_BLOCK]);
            repetitionTargets(iBlock, chosenPosition) = 1;
        end

        % Check rule 3
        if max(sum(repetitionTargets)) < NB_REPETITIONS - 1
            break
        end
    end
    
    %% Randomize, split, put in an ordered fashion
    % randomize stimuli categories and repetitions, 
    % then split into two groups,
    % then create a nice matrix from which we can pick our stimuli
    % matrix that holds the randomizations
    randMatrix = zeros(NB_BLOCKS/2, 20); 
    
    for ri = 1:size(randMatrix,1) % fill the matrix with permutations of the order
        randMatrix(ri,:) = shuffle(1:20);    
    end
    
    % matrix where the actual image indexes are stored. That's where we get
    % which stimulus will be presented
    shuffledEv = zeros(NB_BLOCKS,10);
    
    orep = 1;
    for row = 1:NB_REPETITIONS 

        iniInd = 6*(row-1)+1;
        if mod(row,2) ~= 0 % if odd number, 1 3 5 
            shuffledEv(iniInd:iniInd+5,:) = randMatrix(orep:orep+5, 1:10);
        else
            shuffledEv(iniInd:iniInd+5,:) = randMatrix(orep:orep+5, 11:20);
            orep = orep+6; % increase counter after 2 reps
        end
    end
    
    %% Create repetitions
    % Merge target matrix and shullfed matrix, duplicating the element with
    % the target
    % in which order should we present the images? 8 = 8th image of the
    % randomized order + split
    orderMatrix = zeros(NB_BLOCKS,NB_EVENTS_PER_BLOCK + MAX_TARGET_PER_BLOCK); 
    
    % new target matrix that considers the more elements we have
    targetMatrix = zeros(NB_BLOCKS,NB_EVENTS_PER_BLOCK + MAX_TARGET_PER_BLOCK); 
    
    for k = 1:size(repetitionTargets,1)
        e = 1; % index to go through the new matrix. Will skip ahead when encountering a target
        
        for m = 1:size(repetitionTargets,2)
            % If there is a target, put the image twice in the presentation
            % matrix, otherwise just once
            if repetitionTargets(k,m) == 1
                orderMatrix(k,e) = shuffledEv(k,m);
                e = e + 1;
                % do it again (and add the target where it should be)
                orderMatrix(k,e) = shuffledEv(k,m);
                targetMatrix(k,e) = 1;
                e = e + 1;
            else % == 0
                orderMatrix(k,e) = shuffledEv(k,m);
                e = e + 1;
            end
        end
    end
    
    %% Now we do the easy stuff
    cfg.design.blockNames = assignConditions(cfg);
    cfg.design.nbBlocks = NB_BLOCKS;
    cfg.design.repetitionTargets = repetitionTargets;
    
    % Length of block is 10, plus possible repetition due to target
    cfg.design.lengthBlock = numTargetsForEachBlock + 10; 
    cfg.design.presMatrix = orderMatrix;
    cfg.design.targetMatrix = targetMatrix;

    %% Plot
    diplayDesign(cfg, displayFigs);

end
