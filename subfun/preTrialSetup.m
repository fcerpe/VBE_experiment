% (C) Copyright 2020 CPP visual motion localizer developpers

function varargout = preTrialSetup(varargin)
    % varargout = postInitializatinSetup(varargin)

    % generic function to prepare some structure before each trial

    [cfg, iBlock, iEvent, iRun] = deal(varargin{:});

    % trial_type is defined by the currentImgIndex: 
    % 1-8 = french, 9-16 = braille, 17 = blank
    switch cfg.design.blockMatrix(iRun, iBlock)
        case {'frw','fpw','fnw','ffs'} 
            thisEvent.trial_type = 'french';
        case {'brw','bpw','bnw','bfs'} 
            thisEvent.trial_type = 'braille';
    end
    
    if cfg.design.targetMatrix(iBlock,iEvent,iRun)
        thisEvent.trial_type = 'target';
    end
%     thisEvent.trial_type = cfg.design.blockNames{iBlock};
    thisEvent.target = cfg.design.targetMatrix(iBlock, iEvent, iRun);

    % If this frame shows a target we change the color of the cross
    thisFixation.fixation = cfg.fixation;
    thisFixation.screen = cfg.screen;
    
    % Maybe load the image? 

    varargout = {thisEvent, thisFixation, cfg};
end
