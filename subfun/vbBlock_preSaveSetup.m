% (C) Copyright 2020 CPP visual motion localizer developpers

function varargout = vbBlock_preSaveSetup(varargin)
    % varargout = postInitializatinSetup(varargin)

    % generic function to prepare structures before saving

    [thisEvent, thisFixation, shift, iEvent, duration, onset, cfg, imgToSave, isi, logFile] = ...
        deal(varargin{:});

    thisEvent.event = iEvent;
    thisEvent.block = shift;
    thisEvent.keyName = 'n/a';
    thisEvent.duration = duration;
    thisEvent.onset = onset - cfg.experimentStart;
    thisEvent.fixationPosition = thisFixation.fixation.xDisplacement;
    thisEvent.image = imgToSave;
    thisEvent.isi = isi;
    
    % Save the events txt logfile
    % we save event by event so we clear this variable every loop
    thisEvent.isStim = logFile.isStim;
    thisEvent.fileID = logFile.fileID;
    thisEvent.extraColumns = logFile.extraColumns;

    varargout = {thisEvent};

end
