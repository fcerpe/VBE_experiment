%% Visual Braille study - VWFA event related (for MVPA)
%
% Orinigally from cpp_lab\visual_motion_localizer
% (C) Copyright 2018 Mohamed Rezk
% (C) Copyright 2020 CPP visual motion localizer developpers
%
% Rearranged and modified by Filippo Cerpelloni
% Last update 11/08/2021

getOnlyPress = 1;

% Clear all the previous stuff
clc;
if ~ismac
    close all;
    clear Screen;
end

% make sure we got access to all the required functions and inputs
visbra_initEnv();

% set and load all the parameters to run the experiment
cfg = visbra_setParameters;
cfg = visbra_userInputs(cfg);
cfg = createFilename(cfg);

% load the stimuli from inputs
load('localizer_sota0907.mat');

%%  Experiment
% Safety loop: close the screen if code crashes
try
    
    %% Init the experiment
    
    % creates window and launches, with all the parameters
    cfg = visbra_initPTB(cfg);
    
    % creates design of experiment: re-made suited on me 
    cfg = visbra_expDesign(cfg);
        
    % Prepare for the output logfiles with all
    logFile.extraColumns = cfg.extraColumns;
    logFile = saveEventsFile('init', cfg, logFile);
    logFile = saveEventsFile('open', cfg, logFile);

    % Show experiment instruction
    standByScreen(cfg);

    % prepare the KbQueue to collect responses
    getResponse('init', cfg.keyboard.responseBox, cfg);

    % Wait for Trigger from Scanner
    waitForTrigger(cfg);

    %% Experiment Start

    % Fixation cross and get starting time
    cfg = getExperimentStart(cfg);
    
    getResponse('start', cfg.keyboard.responseBox);
    waitFor(cfg, cfg.timing.onsetDelay);

    %% Actual presentation of stimuli

    for iBlock = 1:1

        fprintf('\n Running Block %.0f - %s\n', iBlock, string(cfg.design.blockNames{iBlock})); 
        previousEvent.target = 0;
        
        % For each event in the block
        
        for iEvent = 1:cfg.design.lengthBlock(iBlock)
            
            % Check for experiment abortion from operator
            checkAbort(cfg, cfg.keyboard.keyboard);

            [thisEvent, thisFixation, cfg] = preTrialSetup(cfg, iBlock, iEvent);

            % we wait for a trigger every 2 events
            if cfg.pacedByTriggers.do && mod(iEvent, 2) == 1
                waitForTrigger(cfg, cfg.keyboard.responseBox, cfg.pacedByTriggers.quietMode, ...
                               cfg.pacedByTriggers.nbTriggers);
            end

            % we want to initialize the image when targets type is fixation cross
            % or if this the first event of a target pair
            % Get the path of the specific .png image 
            % string(cfg.design.names(iBlock))
            currentImgIndex = cfg.design.presMatrix(iBlock,iEvent);
            
            % Temp, until LD and scrambling 
            if iBlock == 2 || iBlock == 8 || iBlock == 14 || iBlock == 20 || ...
               iBlock == 26 || iBlock == 32 || iBlock == 38 || iBlock == 44 || iBlock == 50 || ...
               iBlock == 56 || iBlock == 62 || iBlock == 68
                folder = string(cfg.design.blockNames{1});
            elseif iBlock == 5 || iBlock == 11 || iBlock == 17 || iBlock == 23 || ...
                   iBlock == 29 || iBlock == 35 || iBlock == 41 || iBlock == 47 || iBlock == 53 || ...
                   iBlock == 59 || iBlock == 65 || iBlock == 71
                folder = string(cfg.design.blockNames{3});
            elseif iBlock == 6 || iBlock == 12 || iBlock == 18 || iBlock == 24 || ...
                   iBlock == 30 || iBlock == 36 || iBlock == 42 || iBlock == 48 || iBlock == 54 || ...
                   iBlock == 60 || iBlock == 66 || iBlock == 72
                folder = string(cfg.design.blockNames{4}); 
            else
                folder = string(cfg.design.blockNames{iBlock});
            end
            eval(['thisImage = images.' char(folder) '.scr_' char(stimuli.variableNames(currentImgIndex)) ';']);
                      
            % DO THE THING
            % show the current image / stimulus and collect onset and duraton of the event
            [onset, duration] = visbra_showStim(cfg, thisEvent, thisFixation, thisImage, iEvent);

            % Different from full path, we only care about the file itself
            imgToSave = char(stimuli.variableNames(currentImgIndex));
            
            thisEvent = preSaveSetup(thisEvent, thisFixation, iBlock, iEvent, ...
                                     duration, onset, cfg, imgToSave, logFile);

            saveEventsFile('save', cfg, thisEvent);

            % collect the responses and appends to the event structure for
            % saving in the tsv file
            responseEvents = getResponse('check', cfg.keyboard.responseBox, cfg, ...
                                         getOnlyPress);

            triggerString = ['trigger_' cfg.design.blockNames{iBlock}];
            saveResponsesAndTriggers(responseEvents, cfg, logFile, triggerString);

            previousEvent = thisEvent;

            waitFor(cfg, cfg.timing.ISI);
            
            % 1-back: IF the target is one, the event must be repeated

        end

        % "prepare" cross for the baseline block
        % if MT / MST this allows us to set the cross at the position of the next block
        if iBlock < cfg.design.nbBlocks
            nextBlock = iBlock + 1;
        else
            nextBlock = cfg.design.nbBlocks;
        end
        
        waitFor(cfg, cfg.timing.IBI);

        % IBI trigger paced
        if cfg.pacedByTriggers.do
            waitForTrigger(cfg, ...
                           cfg.keyboard.responseBox, ...
                           cfg.pacedByTriggers.quietMode, ...
                           cfg.timing.triggerIBI);
        end

        if isfield(cfg.design, 'localizer') && strcmpi(cfg.design.localizer, 'MT_MST') && iBlock == cfg.design.nbBlocks / 2

            waitFor(cfg, cfg.timing.changeFixationPosition);

        end

        % trigger monitoring
        triggerEvents = getResponse('check', cfg.keyboard.responseBox, cfg, ...
                                    getOnlyPress);

        triggerString = 'trigger_baseline';
        saveResponsesAndTriggers(triggerEvents, cfg, logFile, triggerString);

    end

    % End of the run for the BOLD to go down
    waitFor(cfg, cfg.timing.endDelay);

    cfg = getExperimentEnd(cfg);

    % Close the logfiles
    saveEventsFile('close', cfg, logFile);

    getResponse('stop', cfg.keyboard.responseBox);
    getResponse('release', cfg.keyboard.responseBox);

    createJson(cfg, cfg);

    farewellScreen(cfg);

    cleanUp();

catch

    cleanUp();
    psychrethrow(psychlasterror);

end
