%% Visual Braille - event-related experiment - supplementaty code: stimuli list
%
% List of the stimuli used in the experiment.
% - for experts to familiarize with Braille words and reduce reading time
% - for novices to control

% get the stimuli
load('inputs/prescan_imgs.mat');

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

questions.mustBePositiveInteger = 'Please enter a positive integer: ';
questions.startCondition = 'Enter the starting condition (FR = 1, BR = 2): ';
questions.questionsToAsk = {'Enter the starting condition (FR = 1, BR = 2): ', 1};

responses = askUserCli(questions, responses);
cfg.subject.firstCond = responses{1, 1};

% Open Screen and add background
Screen('Preference', 'SkipSyncTests', 1);

try

    % creates window and launches, with all the parameters
    cfg = visbra_initPTB(cfg);
    
    waitFor(cfg, 0.5);

    if cfg.subject.firstCond == 1
        firstCharCondition = "french";
        secondCharCondition = "braille";
        firstImage = prescanner_french;
        secondImage = prescanner_braille;
    else
        firstCharCondition = "braille";
        secondCharCondition = "french";
        firstImage = prescanner_braille; 
        secondImage = prescanner_french;
    end

    %% first list for 2 minutes
    fprintf('\n Showing list of %s stimuli\n', string(firstCharCondition));

    framesLeft = floor(cfg.timing.eventDuration / cfg.screen.ifi);
    vbl = Screen('Flip', cfg.screen.win);
    onset = vbl;

    % Set up alpha-blending for smooth (anti-aliased) lines
    Screen('BlendFunction', cfg.screen.win, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    % time in frames
    framesLeft = floor(10 / cfg.screen.ifi);
    
    while framesLeft
        % FIRST LIST
        imageTexture = Screen('MakeTexture', cfg.screen.win, firstImage);
        
        Screen('DrawTexture', cfg.screen.win, imageTexture, [], [], 0);
        Screen('DrawingFinished', cfg.screen.win);
        vbl = Screen('Flip', cfg.screen.win, vbl + cfg.screen.ifi);

        framesLeft = framesLeft - 1;
    end
    
    Screen('DrawingFinished', cfg.screen.win);
    Screen('Close');

    vbl = Screen('Flip', cfg.screen.win, vbl + cfg.screen.ifi);
    duration = vbl - onset;
    disp(duration)

    % wait 5 seconds between lists
    waitFor(cfg, 5);

    %% Second list for 2 minutes
    fprintf('\n Showing list of %s stimuli\n', string(secondCharCondition));

    framesLeft = floor(cfg.timing.eventDuration / cfg.screen.ifi);
    vbl = Screen('Flip', cfg.screen.win);
    onset = vbl;
    
    % Set up alpha-blending for smooth (anti-aliased) lines
    Screen('BlendFunction', cfg.screen.win, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    % time in frames
    framesLeft = floor(10 / cfg.screen.ifi);
    
    while framesLeft
        % SECOND LIST
        imageTexture = Screen('MakeTexture', cfg.screen.win, secondImage);
        
        Screen('DrawTexture', cfg.screen.win, imageTexture, [], [], 0);
        Screen('DrawingFinished', cfg.screen.win);
        vbl = Screen('Flip', cfg.screen.win, vbl + cfg.screen.ifi);

        framesLeft = framesLeft - 1;
    end
    
    Screen('DrawingFinished', cfg.screen.win);
    Screen('Close');

    vbl = Screen('Flip', cfg.screen.win, vbl + cfg.screen.ifi);
    duration = vbl - onset;
    disp(duration)

    % Blank screen
    Screen('FillRect', cfg.screen.win, cfg.color.background);
    
    % Closing up
    Screen('CloseAll');
    
catch
    
    % Closes the onscreen window if it is open.
    Priority(0);
    if exist('origLUT', 'var')
        Screen('LoadNormalizedGammaTable', screenNumber, origLUT);
    end
    Screen('CloseAll');
    psychrethrow(psychlasterror);
    
end
