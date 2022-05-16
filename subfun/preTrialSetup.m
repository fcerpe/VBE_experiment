% (C) Copyright 2020 CPP visual motion localizer developpers

function varargout = preTrialSetup(varargin)
    % varargout = postInitializatinSetup(varargin)

    % generic function to prepare some structure before each trial

    [cfg, iBlock, iEvent, iRun] = deal(varargin{:});

    % trial_type is defined by the currentCondition: 
    % 1-8 = french, 9-16 = braille, 17 = blank
<<<<<<< HEAD
    switch cfg.design.blockMatrix(iRun,iBlock)
=======
    switch cfg.design.blockMatrix(iRun, iBlock)
>>>>>>> a1954660d693fc8cf72133b965c4786e71cfa888
        case {'frw','fpw','fnw','ffs'} 
            thisEvent.trial_type = 'french';
        case {'brw','bpw','bnw','bfs'} 
            thisEvent.trial_type = 'braille';
<<<<<<< HEAD
=======
    end
    
    if cfg.design.targetMatrix(iBlock,iEvent,iRun)
        thisEvent.trial_type = 'target';
>>>>>>> a1954660d693fc8cf72133b965c4786e71cfa888
    end
%     thisEvent.trial_type = cfg.design.blockNames{iBlock};
    thisEvent.target = cfg.design.targetMatrix(iBlock, iEvent, iRun);

    % If this frame shows a target we change the color of the cross
    thisFixation.fixation = cfg.fixation;
    thisFixation.screen = cfg.screen;
    
    % Maybe load the image? 

    varargout = {thisEvent, thisFixation, cfg};
end
