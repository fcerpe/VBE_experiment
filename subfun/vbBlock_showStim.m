% (C) Copyright 2018 Mohamed Rezk
% (C) Copyright 2020 CPP visual motion localizer developpers
%
% Modifications by Filippo Cerpelloni

function [onset, duration] = vbBlock_showStim(cfg, thisEvent, thisFixation, thisImage, iEvent)
    % Presents the stimulation images of french/braille/drawings and scrambling controls
    %
    % Input:
    %  - cfg: PTB/machine configurations returned by setParameters and initPTB
    
    %% Get parameters
    % Set for how many frames this event will last
    framesLeft = floor(cfg.timing.eventDuration / cfg.screen.ifi);

    %% Start the dots presentation
    vbl = Screen('Flip', cfg.screen.win);
    onset = vbl;
    
    % Set up alpha-blending for smooth (anti-aliased) lines
    Screen('BlendFunction', cfg.screen.win, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    % Here we load in an image from file. This one is a image of rabbits that
    % is included with PTB
    
    while framesLeft
        % WORDS
        imageTexture = Screen('MakeTexture', cfg.screen.win, thisImage);
        
        % Draw the image to the screen, no infos = full size and centered
        Screen('DrawTexture', cfg.screen.win, imageTexture, [], [], 0);
                
        % FIXATION
        thisFixation.fixation.color = cfg.color.red;
        drawFixation(thisFixation);

        Screen('DrawingFinished', cfg.screen.win);

        vbl = Screen('Flip', cfg.screen.win, vbl + cfg.screen.ifi);

        %% Update counters
        % Check for end of loop
        framesLeft = framesLeft - 1;
    end

    %% Clear word and keep fixation

    drawFixation(thisFixation);
    
    Screen('DrawingFinished', cfg.screen.win);
    
    Screen('Close');

    vbl = Screen('Flip', cfg.screen.win, vbl + cfg.screen.ifi);

    duration = vbl - onset;

end
