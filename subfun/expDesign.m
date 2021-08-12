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

    if mod(NB_REPETITIONS, MAX_TARGET_PER_BLOCK) ~= 0
        error('number of repetitions must be a multiple of max number of targets');
    end

    % Modified: added the 0 targets condition    
    RANGE_TARGETS = 0:MAX_TARGET_PER_BLOCK;
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
    
    %% Shuffle events (words) in each block in a similar fashion
    % Only kept the rule about no more than 2 target in the same event
    % order, to guarantee that all elements will be subject to repetition
    eventIDs = 1:20;
    whichEvent = repmat(eventIDs, NB_BLOCKS, 1);
    
    while 1
        
        % Try shuffling every row (run)
        for s = 1:size(whichEvent,1)
            shuffledEvents(s,:) = shuffle(whichEvent(s,:));
        end
        
        % Check coloumns for repetitions: max 2 for every condition (see
        % C1_INDEX etc)
        for c = 1:size(whichEvent,2)
            % Get the unique values of each condition
            nr_1 = unique(shuffledEvents(C1_INDEX',c));
            nr_2 = unique(shuffledEvents(C2_INDEX',c));
            nr_3 = unique(shuffledEvents(C3_INDEX',c));
            nr_4 = unique(shuffledEvents(C4_INDEX',c));
            nr_5 = unique(shuffledEvents(C5_INDEX',c));
            nr_6 = unique(shuffledEvents(C6_INDEX',c));
            
            % Check each condition
            for u = 1:length(nr_1)
                if sum(shuffledEvents(C1_INDEX',c) == nr_1(u)) > 2 
                    break;
                end
            end
        end
        
        
        for iBlock = 1:NB_BLOCKS
            
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

    %% Now we do the easy stuff
    cfg.design.blockNames = assignConditions(cfg);
    cfg.design.nbBlocks = NB_BLOCKS;
    cfg.design.repetitionTargets = repetitionTargets;
    % Length of block is 20, plus possible repetitions due to target
    cfg.design.lengthBlock = numTargetsForEachBlock + 20; 

    %% Plot
    diplayDesign(cfg, displayFigs);

end
