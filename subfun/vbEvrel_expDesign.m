% (C) Copyright 2020 CPP visual motion localizer developpers

function [cfg] = vbEvrel_expDesign(cfg, displayFigs)
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
%     [~, C1_INDEX, C2_INDEX, C3_INDEX, C4_INDEX] = assignConditions(cfg);

%     if mod(NB_REPETITIONS, MAX_TARGET_PER_BLOCK) ~= 0
%         error('number of repetitions must be a multiple of max number of targets');
%     end
    
    % Total of 8 targets (10% of 80 stimuli, 16*5). 
    % Randomly distribute 8 targets in 5 repetitions
    TOTAL_TARGETS = 6;
    
    while true 
        numTargetsForEachBlock = randi(2,1,NB_BLOCKS); % ones(1, NB_BLOCKS);
        numNullsForEachBlock = shuffle(numTargetsForEachBlock);
        
        % logical controls: not too many stimuli (6 in total each)
        notTooMany = sum(numTargetsForEachBlock) == TOTAL_TARGETS && sum(numNullsForEachBlock) == TOTAL_TARGETS;
        
        % not the same repetition has 2 blocks
        notOverlapping = true;
        for l = 1:NB_BLOCKS
            if numTargetsForEachBlock(l) == 2 && numNullsForEachBlock(l) == 2
                notOverlapping = false;
            end
        end
                
        % check 
        if notTooMany && notOverlapping
            break
        end
    end
    
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
        if max(sum(repetitionTargets)) < 3 % no more than 2
            break
        end
    end
    
    %% Create null trials matrix and targets 
    % Must be different than 1 back targets, so not in the same position
    % (+2,-2)
    % Must enlarge matrix and put 0 as image ID
    
    do = true;
    
    while do
        
        nullTargets = zeros(NB_BLOCKS, NB_EVENTS_PER_BLOCK);
        
        for iBlock = 1:NB_BLOCKS
            nbTarget = numNullsForEachBlock(iBlock);
            chosenPosition = setTargetPositionInSequence(NB_EVENTS_PER_BLOCK, nbTarget, [1 2 NB_EVENTS_PER_BLOCK-1 NB_EVENTS_PER_BLOCK]);
            
            for k = 1:length(chosenPosition)
                j = chosenPosition(k);
                % if in the repetition matrix there is not an event nearr-by (-2 position to +2 positions)
                if ~(repetitionTargets(iBlock,j-2) == 1 || repetitionTargets(iBlock,j-1) == 1 || ...
                        repetitionTargets(iBlock,j) == 1 || repetitionTargets(iBlock,j+1) == 1 || ...
                        repetitionTargets(iBlock,j+2) == 1)
                    
                    % safe position, add it
                    nullTargets(iBlock, j) = 2;
                end
            end
        end
        
        % all targets have been placed and no more than 2 in a coloumn
        if sum(nullTargets,'all') == TOTAL_TARGETS*2 && max(sum(nullTargets)) < 5
            break
        end
    end

    %% Randomize events order in each "block" and add the 0 as null
    % matrix that holds the randomizations
    shuffledEv = zeros(NB_BLOCKS, 16); 
    
    % Put into a single row, split in two, assign the corresponding stimuli
    
    for ri = 1:NB_BLOCKS % fill the matrix with permutations of the order
        shuffledEv(ri,:) = shuffle(1:16);    
    end
       
    %% Create repetitions, nulls, targets
    % Merge target matrix and shullfed matrix, duplicating the element with
    % the target
    % in which order should we present the images? 8 = 8th image of the
    % randomized order + split
    orderMatrix = zeros(NB_BLOCKS,NB_EVENTS_PER_BLOCK + MAX_TARGET_PER_BLOCK+1); 
    
    % new target matrix that considers the more elements we have
    targetMatrix = zeros(NB_BLOCKS,NB_EVENTS_PER_BLOCK + MAX_TARGET_PER_BLOCK+1); 
    
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
            elseif nullTargets(k,m) == 2 % no repetition but null trial
                orderMatrix(k,e) = 0;
                targetMatrix(k,e) = 2;
                e = e + 1;
                % then add the following one too, so the lopps don't get
                % messy
                orderMatrix(k,e) = shuffledEv(k,m);
                e = e + 1;
            else % neither
                orderMatrix(k,e) = shuffledEv(k,m);
                e = e + 1;
            end
        end
    end
       
    %% Create ISI matrix with variations
    % 
    isi = cfg.timing.ISI;
    % total length is equal to num of blocks * events per block
    sizes = size(orderMatrix);                  % get sizes
    totLength = round((sizes(1) * sizes(2))/3); % how many repetitions?
    isiArray = repmat(isi, 1, totLength);         % repeat matrix
    isiArray = shuffle(isiArray);               % randomize it
    isiArray = horzcat(isiArray,2);             % add a zero to make calcs easier
    isiMatrix = reshape(isiArray,[sizes(1), sizes(2)]);
    
    %% Create the position matrix (a.k.a. shift to the left or to the right)
    % same concept as ISI, without the last 0
    
    tilt = [-1 0 1]; % left, center, right
    tiltArray = repmat(tilt, 1, totLength);
    randPos = shuffle(tilt);
    tiltArray = horzcat(tiltArray,randPos(1)); % get a random position to complete the matrix
    tiltArray = shuffle(tiltArray);
    tiltMatrix = reshape(tiltArray, [sizes(1), sizes(2)]);
    
    %% Now we do the easy stuff
    cfg.design.blockNames = assignConditions(cfg);
    cfg.design.nbBlocks = NB_BLOCKS;
    cfg.design.repetitionTargets = repetitionTargets;
    
    % Length of block is 10, plus possible repetition due to target
    cfg.design.lengthBlock = numTargetsForEachBlock + numNullsForEachBlock + 16; 
    cfg.design.presMatrix = orderMatrix;
    cfg.design.targetMatrix = targetMatrix;
    cfg.design.isiMatrix = isiMatrix;
    cfg.design.tiltMatrix = tiltMatrix;

    %% Plot
    diplayDesign(cfg, displayFigs);

end
