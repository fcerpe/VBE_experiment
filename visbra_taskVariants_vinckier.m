%% Visual Braille study - VWFA event related (for MVPA)
%
% Orinigally from cpp_lab\visual_motion_localizer
% (C) Copyright 2018 Mohamed Rezk
% (C) Copyright 2020 CPP visual motion localizer developpers
%
% Rearranged and modified by Filippo Cerpelloni
% Last update 02/05/2022

warning('off');

getOnlyPress = 1;

% Clear all the previous stuff
clc;
if ~ismac
    close all;  clear Screen;
end

% make sure we got access to all the required functions and inputs
visbra_initEnv();

% set and load all the parameters to run the experiment
cfg = vbBlock_setParameters;
cfg = vbBlock_userInputs(cfg);
cfg.subject.firstCond = 2;

% if running mac on battery, 1.7s correspond to 3.5s of ptb presentation
cfg.timing.eventDuration = 1.7; 

cfg = createFilename(cfg);

% load the stimuli from inputs
load('inputs/taskTrial_stimuli.mat');

%%  Experiment
% Safety loop: close the screen if code crashes
try
    
    %% Init the experiment
    
    % creates window and launches, with all the parameters
    cfg = visbra_initPTB(cfg);
    
    % creates design of experiment: re-made suited on me
    cfg = vbBlock_expDesign(cfg);

    cfg.design.onedimPlaces(:,:,[1 3 5 7 9 11]) = onedimShifts(:,:,[2 4 6 8 10 12]);
    cfg.design.onedimPlaces(:,:,[2 4 6 8 10 12]) = onedimShifts(:,:,[1 3 5 7 9 11]);
    cfg.design.twodimPlaces(:,:,[1 3 5 7 9 11]) = twodimShifts(:,:,[2 4 6 8 10 12]);
    cfg.design.twodimPlaces(:,:,[2 4 6 8 10 12]) = twodimShifts(:,:,[1 3 5 7 9 11]);

    cfg.extraColumns{6} = 'tilt';
    cfg.extraColumns{7} = 'keyName';    
    
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
    
    talkToMe(cfg, sprintf('\nData will be saved in this file:\n\t%s\n', cfg.fileName.events));
    
    fprintf('\n Running Run %.0f %s\n', string(cfg.subject.runNb));
        
    % we run all the experiment in a single script, there will be a 'space'
    % to press to start the following run
    runsToPerform = [1 3 5];
    taskOrder = npermutek_noRep([1 2 3],3);
    thisTaskOrder = taskOrder(mod(cfg.subject.subjectNb,6)+1,:);
    tasks = ["nodim","onedim","twodim"];

    for rtp = 1:length(runsToPerform)

        iRun = runsToPerform(rtp);
        
        matFile = tasks(thisTaskOrder(rtp));
    
        switch matFile
            case "nodim"
                tiltMat = nodimShifts;
            case "onedim"
                tiltMat = onedimShifts;
            case "twodim"
                tiltMat = twodimShifts;
        end

        % By blocks we actually mean chunks / repetitions of stimuli.
        % there's no IBI in fact, but it keeps things in order
        for iBlock = 1:cfg.design.nbBlocks/2
            
            previousEvent.target = 0;
            
            % Get which condition are we calling, a.k.a from which
            % struct to pick the images
            currentCondition = cfg.design.blockMatrix(iRun, iBlock);
            
            % Let me know what's happening
            fprintf('\n Running Block %.0f - %s\n', iBlock, string(currentCondition));
            
            % For each event in the block. Refer to blockLengths, each
            % COLUMN represents a run, each cell represents a block within
            % that run
            for iEvent = 1:cfg.design.blockLengths(iRun, iBlock)
                
                % Check for experiment abortion from operator
                checkAbort(cfg, cfg.keyboard.keyboard);
                
                [thisEvent, thisFixation, cfg] = vbBlock_preTrialSetup(cfg, iBlock, iEvent, iRun);
                
                % Get the path of the specific .png image
                currentImgIndex = cfg.design.presentationMatrix(iBlock,iEvent,iRun);
                thisTilt = char(tiltMat(iBlock,iEvent,iRun));
                
                % Go pick the corresponding image
                % w0 is a images made of only zeros, so no word dispalyed
                % IMPORTANT: with the indented targets, choose the folder beforehand
                eval(['thisImage = ' char(matFile) '.' char(thisTilt) '.' char(currentCondition) '.w' char(string(currentImgIndex)) ';']);
                
                % Vinckier variant: if event is target, sting of hashtags
                if thisEvent.target == 1
                    eval(['thisImage = ' char(matFile) '.' char(thisTilt) '.bta.w0;']);
                end

                % WORD EVENT
                % show the word and collect onset and duraton of the event
                [onset, duration] = vbBlock_showStim(cfg, thisEvent, thisFixation, thisImage, iEvent);
                
                % Save image ID
                switch currentCondition
                    case {'frw','brw'}
                        imgToSave = char(stimuli.french.rw(currentImgIndex));
                    case {'fpw','bpw'}
                        imgToSave = char(stimuli.french.pw(currentImgIndex));
                    case {'fnw','bnw','ffs','bfs'}
                        imgToSave = char(stimuli.french.nw(currentImgIndex));
                end

                if thisEvent.target == 1
                    imgToSave = char('targetImg');
                end
    
                isi = cfg.design.isiMatrix(iBlock,iEvent,iRun);
               
                % Save word event
                thisEvent = vbBlock_preSaveSetup(thisEvent, thisFixation, iBlock, iEvent, ...
                    duration, onset, cfg, imgToSave, thisTilt, isi, logFile);
                
                saveEventsFile('save', cfg, thisEvent);
                
                % collect the responses and appends to the event structure for saving in the tsv file
                responseEvents = getResponse('check', cfg.keyboard.responseBox, cfg, getOnlyPress);
                
                triggerString = ['trigger_' cfg.design.blockNames{iBlock}];
                saveResponsesAndTriggers(responseEvents, cfg, logFile, triggerString);
                
                previousEvent = thisEvent;
    
                % ISI
                %
                % wait accordingly to the randomized variable delay
                % plus, draw fixation (inside the waitFor function)
                waitFor(cfg, cfg.design.isiMatrix(iBlock,iEvent,iRun));
                
            end
            
            % "prepare" cross for the baseline block
            % if MT / MST this allows us to set the cross at the position of the next block
            if iBlock < cfg.design.nbBlocks
                nextBlock = iBlock + 1;
            else
                nextBlock = cfg.design.nbBlocks;
            end
            
            waitFor(cfg, cfg.timing.IBI);
            
            % trigger monitoring
            triggerEvents = getResponse('check', cfg.keyboard.responseBox, cfg, ...
                getOnlyPress);
            
            triggerString = 'trigger_baseline';
            saveResponsesAndTriggers(triggerEvents, cfg, logFile, triggerString);
            
        end
    
    
    % End of the run for the BOLD to go down
    waitFor(cfg, cfg.timing.endDelay);

    % Block is over, wait for key press (SPACE) to continue
    DrawFormattedText(cfg.screen.win, 'Appuyez sur "espace" pour continuer', 'center', 'center');
    Screen('Flip', cfg.screen.win);
    
    waitForKb('space', [])

    end
    
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
