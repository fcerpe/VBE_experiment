%% Visual Braille study - VWFA event related (for MVPA)
%
% Orinigally from cpp_lab\visual_motion_localizer
% (C) Copyright 2018 Mohamed Rezk
% (C) Copyright 2020 CPP visual motion localizer developpers
%
% Rearranged and modified by Filippo Cerpelloni
% Last update 11/11/2021

getOnlyPress = 1;

% Clear all the previous stuff
clc;
if ~ismac
    close all;  clear Screen;
end

% make sure we got access to all the required functions and inputs
visbra_initEnv();

% set and load all the parameters to run the experiment
cfg = vbEvrel_setParameters;
cfg = visbra_userInputs(cfg);
cfg = createFilename(cfg);

% load the stimuli from inputs
load('inputs/mvpa_stimuli.mat');

%%  Experiment
% Safety loop: close the screen if code crashes
try
    
    %% Init the experiment
    
    % creates window and launches, with all the parameters
    cfg = visbra_initPTB(cfg);
    
    % creates design of experiment: re-made suited on me 
    cfg = vbEvrel_expDesign(cfg);
        
    % Prepare for the output logfiles with all
    logFile.extraColumns = cfg.extraColumns;
    logFile = saveEventsFile('init', cfg, logFile);
    logFile = saveEventsFile('open', cfg, logFile);

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
    
    fprintf('\n Running Run %.0f - %s\n', string(cfg.subject.runNb)); 
    
    % By blocks we actually mean chunks / repetitions of stimuli.
    % there's no IBI in fact, but it keeps things in order
    for iBlock = 1:cfg.design.nbBlocks

        previousEvent.target = 0;
        
        % For each event in the "block" 
        for iEvent = 1:cfg.design.lengthBlock(iBlock)
            
            % Check for experiment abortion from operator
            checkAbort(cfg, cfg.keyboard.keyboard);

            [thisEvent, thisFixation, cfg] = preTrialSetup(cfg, iBlock, iEvent);

            % we wait for a trigger every 2 events
            if cfg.pacedByTriggers.do && mod(iEvent, 2) == 1
                waitForTrigger(cfg, cfg.keyboard.responseBox, cfg.pacedByTriggers.quietMode, ...
                               cfg.pacedByTriggers.nbTriggers);
            end

            % Get the path of the specific .png image 
            % string(cfg.design.names(iBlock))
            currentImgIndex = cfg.design.presMatrix(iBlock,iEvent);
            
            % Go pick the corresponding image 
            % w0 is a images made of only zeros, so no word dispalyed
            % IMPORTANT: with the indented targets, choose the folder beforehand
            eval(['thisImage = images.words.w' char(string(currentImgIndex)) ';']);
                      
            % WORD EVENT
            % show the word and collect onset and duraton of the event
            [onset, duration] = vbEvrel_showStim(cfg, thisEvent, thisFixation, thisImage, iEvent);
            
            % Save image ID 
            if currentImgIndex == 0
                currentImgIndex = 17;
            end
            imgToSave = char(stimuli.eventNames(currentImgIndex));
            
            % Save word event
            thisEvent = preSaveSetup(thisEvent, thisFixation, iBlock, iEvent, ...
                                     duration, onset, cfg, imgToSave, logFile);

            saveEventsFile('save', cfg, thisEvent);

            % collect the responses and appends to the event structure for saving in the tsv file
            responseEvents = getResponse('check', cfg.keyboard.responseBox, cfg, getOnlyPress);

            triggerString = ['trigger_' cfg.design.blockNames{iBlock}];
            saveResponsesAndTriggers(responseEvents, cfg, logFile, triggerString);
          
            previousEvent = thisEvent;

            % wait accordingly to the randomized variable delay
            % plus, draw fixation (inside the waitFor function)
            waitFor(cfg, cfg.design.isiMatrix(iBlock,iEvent));
            
        end

        % "prepare" cross for the baseline block
        % if MT / MST this allows us to set the cross at the position of the next block
        if iBlock < cfg.design.nbBlocks
            nextBlock = iBlock + 1;
        else
            nextBlock = cfg.design.nbBlocks;
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

    cleanUp();

catch

    cleanUp();
    psychrethrow(psychlasterror);

end
