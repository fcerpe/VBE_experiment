% (C) Copyright 2020 CPP visual motion localizer developpers

function [cfg] = vbBlock_expDesign(cfg, displayFigs)
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
    % (2) Targets are balanced across conditions
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
    switch cfg.subject.firstCond
        case 1
            currentConditionOrder = condOrder_frFirst;
        case 2
            currentConditionOrder = condOrder_brFirst;
    end
    
    for r = 1:size(currentConditionOrder,1)
        for b = 1:size(currentConditionOrder,2)
            whichCond(r,b) = cfg.design.names{currentConditionOrder(r,b)'};
        end
    end

    %% Everything is pre-made, we just have to give it nice names
    cfg.design.blockNames = vbBlock_assignConditions(cfg);
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
