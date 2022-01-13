% (C) Copyright 2020 CPP visual motion localizer developpers

function varargout = preTrialSetup(varargin)
    % varargout = postInitializatinSetup(varargin)

    % generic function to prepare some structure before each trial

    [cfg, iBlock, iEvent] = deal(varargin{:});

    % trial_type is defined by the currentImgIndex: 
    % 1-8 = french, 9-16 = braille, 17 = blank
    switch cfg.design.presMatrix(iBlock,iEvent)
        case {1,2,3,4,5,6,7,8} 
            thisEvent.trial_type = 'french';
        case {9,10,11,12,13,14,15,16} 
            thisEvent.trial_type = 'braille';
        case 0
            thisEvent.trial_type = 'blank';
    end
%     thisEvent.trial_type = cfg.design.blockNames{iBlock};
    thisEvent.target = cfg.design.targetMatrix(iBlock, iEvent);

    % If this frame shows a target we change the color of the cross
    thisFixation.fixation = cfg.fixation;
    thisFixation.screen = cfg.screen;
    
    % Maybe load the image? 

    varargout = {thisEvent, thisFixation, cfg};
end
