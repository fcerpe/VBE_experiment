% (C) Copyright 2020 CPP visual motion localizer developpers

function varargout = vbBlock_preSaveSetup(varargin)
    % varargout = postInitializatinSetup(varargin)

    % generic function to prepare structures before saving

    [thisEvent, thisFixation, iBlock, iEvent, duration, onset, cfg, imgToSave, isi, wrdCat, logFile] = ...
        deal(varargin{:});

    % if it's a real word presented, modify the trial_type saved
    % from frw/brw add _liv, _nli, _mix whether it's a block made of
    % living, non living, mixed stimuli respectively
    if all(thisEvent.trial_type([2 3]) == 'rw')
        thisEvent.trial_type = strcat(thisEvent.trial_type, wrdCat);
    end

    thisEvent.event = iEvent;
    thisEvent.block = iBlock;
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
