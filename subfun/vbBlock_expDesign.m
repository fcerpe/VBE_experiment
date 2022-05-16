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
% Based on the first alphabet, make matrices for BLOCKS, PRESENTATION, ISI
% If starting condition is Braille, switch orders. otherwise is ok
if cfg.subject.firstCond == 2
    % order of blocks
    currConditionOrder([1 3 5 7 9 11],:) = conditionOrder([2 4 6 8 10 12],:);
    currConditionOrder([2 4 6 8 10 12],:) = conditionOrder([1 3 5 7 9 11],:);
    
    % presentation of blocks within a run
    currOrderMatrix(:,:,[1 3 5 7 9 11]) = stimOrderMatrix(:,:,[2 4 6 8 10 12]);
    currOrderMatrix(:,:,[2 4 6 8 10 12]) = stimOrderMatrix(:,:,[1 3 5 7 9 11]);
    
    % isi
    currIsiMatrix(:,:,[1 3 5 7 9 11]) = isiMatrix(:,:,[2 4 6 8 10 12]);
    currIsiMatrix(:,:,[2 4 6 8 10 12]) = isiMatrix(:,:,[1 3 5 7 9 11]);
    
    currTotIsi([1 3 5 7 9 11],:) = totIsi([2 4 6 8 10 12],:);
    currTotIsi([2 4 6 8 10 12],:) = totIsi([1 3 5 7 9 11],:);
    
    % targets
    currTargetMatrix(:,:,[1 3 5 7 9 11]) = targetMatrix(:,:,[2 4 6 8 10 12]);
    currTargetMatrix(:,:,[2 4 6 8 10 12]) = targetMatrix(:,:,[1 3 5 7 9 11]);
    
    % number of stimuli per block
    currNumStimPerBlock([1:12 25:36 49:60 73:84 97:108 121:132]) = numStimPerBlock([13:24 37:48 61:72 85:96 109:120 133:144]);
    currNumStimPerBlock([13:24 37:48 61:72 85:96 109:120 133:144]) = numStimPerBlock([1:12 25:36 49:60 73:84 97:108 121:132]);
    
    % which stimuli per block
    currStimuliPerBlock(:,:,[1 3 5 7 9 11]) = StimuliPerBlock(:,:,[2 4 6 8 10 12]);
    currStimuliPerBlock(:,:,[2 4 6 8 10 12]) = StimuliPerBlock(:,:,[1 3 5 7 9 11]);
else
    currConditionOrder = conditionOrder;    currOrderMatrix = stimOrderMatrix;  currIsiMatrix = isiMatrix;
    currTotIsi = totIsi;                    currTargetMatrix = targetMatrix;    currNumStimPerBlock = numStimPerBlock;
    currStimuliPerBlock = StimuliPerBlock;
    
end

% switch numbers for condition names in the condition order.
% it's annoying
for r = 1:size(currConditionOrder,1)
    for b = 1:size(currConditionOrder,2)
        whichCond(r,b) = cfg.design.names{currConditionOrder(r,b)'};
    end
end

%% Everything is pre-made, we just have to give it nice names
cfg.design.blockNames = vbBlock_assignConditions(cfg);
cfg.design.nbBlocks = NB_BLOCKS;
cfg.design.nbRuns = 12;

% Length of block is 10, plus possible repetition due to target
cfg.design.blockLengths = reshape(numStimPerBlock,12,12)';
cfg.design.blockMatrix = whichCond;
cfg.design.presentationMatrix = stimOrderMatrix;
cfg.design.targetMatrix = targetMatrix;
cfg.design.isiMatrix = isiMatrix;

clearvars ans conditionsOrder isiMatrix numStimPerBlock stimOrderMatrix StimuliPerBlock targetMatrix totIsi

end
