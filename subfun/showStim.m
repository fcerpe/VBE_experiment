% (C) Copyright 2018 Mohamed Rezk
% (C) Copyright 2020 CPP visual motion localizer developpers
%
% Modifications by Filippo Cerpelloni

function [onset, duration, image] = showStim(cfg, thisEvent, thisFixation, image, iEvent)
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
    imgLocation = image;
    thisImage = imread(imgLocation);

    % Get the size of the image
    [imgX, imgY, imgZ] = size(thisImage);

    while framesLeft
        %% draw evetything and flip screen

        % DrawFormattedText(cfg.screen.win, 'IMAGE TO COME', 'center','center');
        % Make the image into a texture
        imageTexture = Screen('MakeTexture', cfg.screen.win, thisImage);

        % Draw the image to the screen, unless otherwise specified PTB will draw
        % the texture full size in the center of the screen. We first draw the
        % image in its correct orientation.
        Screen('DrawTexture', cfg.screen.win, imageTexture, [], [], 0);
                
        Screen('DrawingFinished', cfg.screen.win);
        vbl = Screen('Flip', cfg.screen.win, vbl + cfg.screen.ifi);

        %% Update counters
        % Check for end of loop
        framesLeft = framesLeft - 1;
    end

    %% Erase last dots

    Screen('DrawingFinished', cfg.screen.win);

    vbl = Screen('Flip', cfg.screen.win, vbl + cfg.screen.ifi);

    duration = vbl - onset;

end
