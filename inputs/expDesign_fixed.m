%% VISUAL BRAILLE MAIN EXPERIMENT - DESIGN PARAMETERS
% made once and then stored for all the experiments

%% Create runs and the presentation order of the conditions
    % We make only six runs for french, then repeat them and shuffle the order to get
    % the braille ones

    % presentation order for a single run
    runArr = [1 2 3 4]; 
    runMat = zeros(6,12);

    % make sure that in every block position, each condition appears at
    % least once and not more than 2 times
    notPosition = true;
    while notPosition 

        for m = 1:size(runMat,1)
        % shuffle the array and check that conditions are not repeated
            notShuffle = true;
            while notShuffle
                thisShuf1 = shuffle(runArr); thisShuf2 = shuffle(runArr); thisShuf3 = shuffle(runArr);
        
                % if there is no direct repetition
                if thisShuf1(end) ~= thisShuf2(1) && thisShuf2(end) ~= thisShuf3(1)
                    % accept the shuffle
                    notShuffle = false;
                end
            end
    
        % assign the array to the run
        thisShuf = horzcat(thisShuf1,thisShuf2,thisShuf3);
        runMat(m,:) = thisShuf;
    
        end
    
        % check blocks distribution
        blockDistribution = [0 0 0 0 0 0 0 0 0 0 0 0];
        for c = 1:size(runMat,2)
            if length(unique(runMat(:,c))) == 4
                blockDistribution(c) = 1;
            end
        end

        % all respect the parameters? 
        if all(blockDistribution)
            notPosition = false;
        end
    end
  
    % duplicate the matrix for the braille runs
    runShuffle = shuffle([1 2 3 4 5 6]);
    runFull = zeros(12,12);
    runFull([1 3 5 7 9 11],:) = runMat;
    s = 1;
    for r = 2:2:size(runFull,1)
        runFull(r,:) = runMat(runShuffle(s),:) + 4;
        s = s + 1;
    end

    %% balance stimuli order across runs for each condition
    
    % 6 runs per condition * 12 stimuli per condition * 8 conditions
    runCondStim = zeros(6,12,8);

    % for each condition
    for cond = 1:8

        stimOrder = repmat([1 2 3 4 5 6 7 8 9 10 11 12],6,1);

        notDistribution = true;
        while notDistribution
            % shuffle rows
            for l = 1:size(stimOrder,1)
                % shuffle this row
                stimOrder(l,:) = shuffle(stimOrder(l,:));
            end

            % check the first coloumns of every block for the
            % distribution of stimuli, all should be represented (12
            % stimuli, 18 positions)
            check = stimOrder(:,[1 5 9]);
            if length(unique(check)) == 12
                notDistribution = false;
            end

        end
        
        % store the condition order in the matrix
        runCondStim(:,:,cond) = stimOrder;
    end

    %% re-arrange stimuli preentations and build block * stimuli * runs matrix

    % 12 runs of 12 blocks of 4 stimuli each (without target, coming later)
    blockStimRun = zeros(12,4,12);

    % take each condition from runCondStim
    % take evry row
    % split it in 3
    % put the pieces accordingly

    for cd = 1:size(runCondStim,3)
        for rn = 1:size(runCondStim,1)
            % take the stimuli order
            this = runCondStim(rn,:,cd);
            
            % are we talking about french or braille?
            if cd <= 4
                % french is in odd runs
                runOrder = [1 3 5 7 9 11];
            else
                % braille is in even runs
                runOrder = [2 4 6 8 10 12];
            end
            blockOrder = find(runFull(runOrder(rn),:) == cd);

            % re-arrange it into the new matrix
            blockStimRun(blockOrder(1),:,runOrder(rn)) = this(1:4);
            blockStimRun(blockOrder(2),:,runOrder(rn)) = this(5:8);
            blockStimRun(blockOrder(3),:,runOrder(rn)) = this(9:12);
        end
    end

    %% Pick which events are targets
    % Task is 1-back: need to repeat an image, if indicated by the target
      
    % think holistic
    % shuffle the different runs, one after the other
    % compare the targets' positions against the condition they fall in
    % do this for each language separately. French and Braille are
    % different stimuli
    notEqualTargets = true;

    while notEqualTargets
        targetPositions = zeros(1,144);
        condPositions = reshape(runFull,1,144);

        for rn = 1:12:144
            targetPositions(rn:rn+11) = shuffle(numTargetsForEachBlock);
        end

        whichPositions = condPositions(targetPositions == 1);

        distribution = [sum(whichPositions == 1), sum(whichPositions == 2), ...
            sum(whichPositions == 3), sum(whichPositions == 4), ...
            sum(whichPositions == 5), sum(whichPositions == 6), ...
            sum(whichPositions == 7), sum(whichPositions == 8)];

        % if all are 9, end
        if length(unique(distribution)) == 1
            notEqualTargets = false;
        end
    end

    iRun = 1;
    index = 1;
    while iRun <= 12
        % that target distribution is fine, all conditions have the same
        % number of targets
        %
        % Now we choose the positions of those targets
        % 72 targets / 3 positions = 24 target per position
        thisRunTargets = zeros(12,4);
        thisRunPositions = targetPositions(index:index+11);

        % for each block, go choose the position as usual
        
        for iBlock = 1:12

            nbTarget = thisRunPositions(iBlock);

            chosenPosition = setTargetPositionInSequence(size(thisRunTargets,2), nbTarget, 1);

            thisRunTargets(iBlock, chosenPosition) = 1;
        end

        [sum(thisRunTargets(:,2)) sum(thisRunTargets(:,3)) sum(thisRunTargets(:,4))]

        % Check rule 3
        if max(sum(thisRunTargets)) < 3 % no more than 2 in the same column
            % move to the next block
            targetMatrix(:,:,iRun) = thisRunTargets;
            iRun = iRun + 1;
            index = index + 12;
        end
    end
       
    %% Create repetitions
    % Merge target matrix and stimuli matrix, duplicating the element with
    % the target
    
    orderMatrix = zeros(12,5,12); 
    
    for iRun = 1:size(targetMatrix,3)
        for iBlock = 1:size(targetMatrix,1)
            e = 1; % index to go through the new matrix. Will skip ahead when encountering a target

            for iStim = 1:size(targetMatrix,2)
                % If there is a target, put the image twice in the presentation
                % matrix, otherwise just once
                if targetMatrix(iBlock,iStim,iRun) == 1
                    orderMatrix(iBlock,iStim,iRun) = blockStimRun(iBlock,iStim,iRun);
                    e = e + 1;
                    % do it again (and add the target where it should be)
                    orderMatrix(iBlock,e,iRun) = blockStimRun(iBlock,iStim,iRun);
                    e = e + 1;
                else % neither
                    orderMatrix(iBlock,e,iRun) = blockStimRun(iBlock,iStim,iRun);
                    e = e + 1;
                end
            end
        end
    end
    
    % shift towards the right the target matrix. Move the target from
    % "which to repeat" to "which has been repeated"
    targetMatrix(:,2:5,:) = targetMatrix; 

    numStimPerBlock = targetPositions' + 4;
    
    %% Clear and save

    save('expDesignInfo.mat');