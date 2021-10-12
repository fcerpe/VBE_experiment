% (C) Copyright 2020 CPP visual motion localizer developpers

function [cfg] = setParameters()

    % VISUAL LOCALIZER

    % Initialize the parameters and general configuration variables
    cfg = struct();

    % by default the data will be stored in an output folder created where the
    % setParamters.m file is
    % change that if you want the data to be saved somewhere else
    cfg.dir.output = fullfile(fileparts(mfilename('fullpath')), 'output');

    %% Debug mode settings

    cfg.debug.do = false; % To test the script out of the scanner, skip PTB sync
    cfg.debug.smallWin = true; % To test on a part of the screen, change to 1
    cfg.debug.transpWin = false; % To test with trasparent full size screen
    cfg.debug.showMouse = false;

    cfg.skipSyncTests = 1;

    cfg.verbose = 1;

    %% Engine parameters

    cfg.testingDevice = 'mri';
    cfg.eyeTracker.do = false;
    cfg.audio.do = false;

    cfg = setMonitor(cfg);

    % Keyboards
    cfg = setKeyboards(cfg);

    % MRI settings
    cfg = setMRI(cfg);
    cfg.suffix.acquisition = '0p75mmEvTr2p18'; % Is it changeable? 
                                               % Does it mean something?
    cfg.pacedByTriggers.do = false;

    %% Experiment Design

    cfg.design.localizer = 'VWFA';
    
    % (F)rench (W)ords, (B)raille (W)ords, (L)ine (D)rawings, and (S)crambled conditions
    cfg.design.names = {'fw'; 'sfw'; 'bw'; 'sbw'; 'ld'; 'sld'};

    cfg.design.nbRepetitions = 6;
    cfg.design.nbEventsPerBlock = 20; 

    %% Timing

    cfg.timing.eventDuration = 1; % second

    % Time between blocs in secs
    cfg.timing.IBI = 6;
    % Time between events in secs
    cfg.timing.ISI = 0.01;
    % Number of seconds before the motion stimuli are presented
    cfg.timing.onsetDelay = 0;
    % Number of seconds after the end all the stimuli before ending the run
    cfg.timing.endDelay = 3.6;

    % reexpress those in terms of repetition time
    if cfg.pacedByTriggers.do

        cfg.pacedByTriggers.quietMode = true;
        cfg.pacedByTriggers.nbTriggers = 5;

        cfg.timing.eventDuration = cfg.mri.repetitionTime / 2 - 0.04; % second

        % Time between blocs in secs
        cfg.timing.IBI = 6;
        % Time between events in secs
        cfg.timing.ISI = 0.1;
        % Number of seconds before the motion stimuli are presented
        cfg.timing.onsetDelay = 0;
        % Number of seconds after the end all the stimuli before ending the run
        cfg.timing.endDelay = 2;

    end

    %% Visual Stimuliation
    
    % List of objects represented: same order in all the folders, lets us
    % speed up the 'get which image' phase
    % 10-8-2021: Let's start with only one
    
    %% Task(s)
    cfg.task.name = 'visual localizer';

    % Instruction
    cfg.task.instruction = 'TASK - Detect the repetition \n \n\n';

    % Fixation cross (in pixels)
    cfg.fixation.type = 'cross';
    cfg.fixation.color = cfg.color.white;
    cfg.fixation.width = .25;
    cfg.fixation.lineWidthPix = 3;
    cfg.fixation.xDisplacement = 0;
    cfg.fixation.yDisplacement = 0;

    % target
    cfg.target.maxNbPerBlock = 1;
    cfg.target.duration = 0.1; % In secs
    cfg.target.type = 'repetition';
    
    cfg.extraColumns = {'image', 'target', 'event', 'block', 'keyName'};    

end

function cfg = setKeyboards(cfg)
    cfg.keyboard.escapeKey = 'ESCAPE';
    cfg.keyboard.responseKey = {'r', 'g', 'y', 'b','d', 'n', 'z', 'e','t'};
    cfg.keyboard.keyboard = [];
    cfg.keyboard.responseBox = [];

    if strcmpi(cfg.testingDevice, 'mri')
        cfg.keyboard.keyboard = [];
        cfg.keyboard.responseBox = [];
    end
end

function cfg = setMRI(cfg)
    % letter sent by the trigger to sync stimulation and volume acquisition
    cfg.mri.triggerKey = 't';
    cfg.mri.triggerNb = 0;

    cfg.mri.repetitionTime = 1.8;

    cfg.bids.MRI.Instructions = 'Detect the repeated stimulus';
    cfg.bids.MRI.TaskDescription = [];

end

function cfg = setMonitor(cfg)

    % Monitor parameters for PTB
    cfg.color.white = [255 255 255];
    cfg.color.black = [0 0 0];
    cfg.color.red = [255 0 0];
    cfg.color.grey = mean([cfg.color.black; cfg.color.white]);
    cfg.color.background = cfg.color.black;
    cfg.text.color = cfg.color.white;

    % Monitor parameters
    cfg.screen.monitorWidth = 50; % in cm
    cfg.screen.monitorDistance = 40; % distance from the screen in cm

    if strcmpi(cfg.testingDevice, 'mri')
        cfg.screen.monitorWidth = 25;
        cfg.screen.monitorDistance = 95;
    end

end

