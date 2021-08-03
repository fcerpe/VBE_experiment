% (C) Copyright 2020 CPP visual motion localizer developpers

function varargout = preTrialSetup(varargin)
    % varargout = postInitializatinSetup(varargin)

    % generic function to prepare some structure before each trial

    [cfg, iBlock, iEvent] = deal(varargin{:});

    % Not much to do since there's no motion involved
    thisEvent.trial_type = cfg.design.blockNames{iBlock};
    thisEvent.target = cfg.design.repetitionTargets(iBlock, iEvent);

    % If this frame shows a target we change the color of the cross
    thisFixation.fixation = cfg.fixation;
    thisFixation.screen = cfg.screen;
    
    % Maybe load the image? 

    varargout = {thisEvent, thisFixation, cfg};
end
