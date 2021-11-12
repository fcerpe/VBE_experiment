%% Visual Braille - event-related experiment - supplementaty code: stimuli list
%
% List of the stimuli used in the experiment.
% - for experts to familiarize with Braille words and reduce reading time
% - for novices to control

% get the stimuli
load('inputs/mvpa_stimuli.mat');

t = stimuli.box;

% Open Screen and add background
Screen('Preference', 'SkipSyncTests', 1);

try
    % Routine stuff
    % PTB opens a windows on the screen with the max index
    screens = Screen('Screens');
    whichscreen = max(screens);
    [t.win, t.rect] = Screen('OpenWindow', whichscreen, t.bg_color);
    
    % FONT AND SIZE ARE REALLY IMPORTANT
    Screen('TextFont', t.win, t.font);
    Screen('TextSize', t.win, t.size);
    
    HideCursor;
    
    stimuliUnicode = [102 97 117 99 111 110 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 114 111 113 117 101 116 10 10 ...
                      99 111 99 104 111 110 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 112 111 117 108 101 116 10 10 ...
                      98 97 108 99 111 110  32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 118 97 108 108 111 110  10 10 ...
                      99 104 97 108 101 116 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 115 111 109 109 101 116 10 10 ...
        10255 10261 10277 10247 10257 10270 32 32 32 32 32 32 32 32 32 32 32 32 10263 10261 10271 10277 10257 10270 10 10 ...
        10254 10261 10253 10253 10257 10270 32 32 32 32 32 32 32 32 32 32 32 32 10279 10241 10247 10247 10261 10269 10 10 ...
        10249 10261 10249 10259 10261 10269 32 32 32 32 32 32 32 32 32 32 32 32 10251 10241 10277 10249 10261 10269 10 10 ...
        10243 10241 10247 10249 10261 10269 32 32 32 32 32 32 32 32 32 32 32 32 10249 10259 10241 10247 10257 10270];

    % Blank screen
    Screen('FillRect', t.win, t.bg_color);
    
    % DRAW LIST
    DrawFormattedText(t.win, stimuliUnicode, 'center', 'center', t.txt_color);
    Screen('Flip', t.win);
    
    % for a minute
    WaitSecs(60);
    
    % Buffer screen
    Screen('FillRect', t.win, t.bg_color);
    Screen('Flip', t.win);
    WaitSecs(2);
    
    % Closing up
    Screen('CloseAll');
    ShowCursor
    
catch
    
    % Closes the onscreen window if it is open.
    Priority(0);
    if exist('origLUT', 'var')
        Screen('LoadNormalizedGammaTable', screenNumber, origLUT);
    end
    Screen('CloseAll');
    psychrethrow(psychlasterror);
    
end
