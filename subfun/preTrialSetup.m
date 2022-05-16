% (C) Copyright 2020 CPP visual motion localizer developpers

function varargout = preTrialSetup(varargin)
    % varargout = postInitializatinSetup(varargin)

    % generic function to prepare some structure before each trial

    [cfg, iBlock, iEvent] = deal(varargin{:});

    % trial_type is block name unless it's target:     
    if cfg.design.targetMatrix(iBlock, iEvent)
        thisEvent.trial_type = 'target';
    else
        thisEvent.trial_type = cfg.design.blockNames{iBlock};
    end
    
    thisEvent.target = cfg.design.targetMatrix(iBlock, iEvent);

    % If this frame shows a target we change the color of the cross
    thisFixation.fixation = cfg.fixation;
    thisFixation.screen = cfg.screen;
    
    varargout = {thisEvent, thisFixation, cfg};
end
