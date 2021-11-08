%% Visual Braille study - VWFA event related experiment 
%
% Orinigally from cpp_lab\visual_motion_localizer
% (C) Copyright 2018 Mohamed Rezk
% (C) Copyright 2020 CPP visual motion localizer developpers
%
% Rearranged and modified by Filippo Cerpelloni
% Last update 21/10/2021

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
cfg = vbLoca_setParameters;
cfg = visbra_userInputs(cfg);
cfg = createFilename(cfg);

% load the stimuli from inputs
% Need to create them actually
load('inputs/localizer_stimuli.mat');

%%  Experiment
% Safety loop: close the screen if code crashes
try
    
    %% Init the experiment
    % creates window and launches, with all the parameters
    cfg = visbra_initPTB(cfg);
    
    % creates design of experiment: re-made suited on me 
    cfg = vbLoca_expDesign(cfg);
        
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

    for iBlock = 1:cfg.design.nbBlocks

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

            % Get the image file 
            currentImgIndex = cfg.design.presMatrix(iBlock,iEvent);
            
            folder = char(cfg.design.blockNames{iBlock});
            file = char(stimuli.variableNames(currentImgIndex));
            
            eval(['thisImage = images.' folder '.' file ';']);
                      
            % DO THE (RIGHT) THING
            % show the current image / stimulus and collect onset and duraton of the event
            [onset, duration] = vbLoca_showStim(cfg, thisEvent, thisFixation, thisImage, iEvent);

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
