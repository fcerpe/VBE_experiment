% (C) Copyright 2018 Mohamed Rezk
% (C) Copyright 2020 CPP visual motion localizer developpers
%
% Modifications by Filippo Cerpelloni

function [onset, duration, image] = doDotMo(cfg, thisEvent, thisFixation, dots, iEvent)
    % Presents the stimulation images of french/braille/drawings and scrambling controls
    %
    % Input:
    %  - cfg: PTB/machine configurations returned by setParameters and initPTB
    %
    % The dots are drawn on a square with a width equals to the width of the
    % screen
    % We then draw an aperture on top to hide the certain dots.

    %% Get parameters
    % Set for how many frames this event will last
    framesLeft = floor(cfg.timing.eventDuration / cfg.screen.ifi);

    %% Start the dots presentation
    vbl = Screen('Flip', cfg.screen.win);
    onset = vbl;

    while framesLeft
        %% Center the coordinates (?)

        % We assumed that zero is at the top left, but we want it to be
        % in the center, so shift the dots up and left, which just means
        % adding half of the screen width in pixel to both the x and y direction.
        % thisEvent.dot.positions = (dots.positions - cfg.dot.matrixWidth / 2)';

        %% draw evetything and flip screen

        DrawFormattedText(cfg.screen.win, 'IMAGE TO COME', 'center','center');
                
        Screen('DrawingFinished', cfg.screen.win);
        vbl = Screen('Flip', cfg.screen.win, vbl + cfg.screen.ifi);

        %% Update counters
        
        % Check for end of loop
        framesLeft = framesLeft - 1;
    end

    %% Erase last dots

    drawFixation(thisFixation);

    Screen('DrawingFinished', cfg.screen.win);

    vbl = Screen('Flip', cfg.screen.win, vbl + cfg.screen.ifi);

    duration = vbl - onset;

end
