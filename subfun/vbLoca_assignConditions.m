% (C) Copyright 2020 CPP visual motion localizer developpers

function [conditionNamesVector, CON1_INDEX, CON2_INDEX, CON3_INDEX, CON4_INDEX, ...
    CON5_INDEX, CON6_INDEX] = vbLoca_assignConditions(cfg)

[~, nbRepet] = getDesignInput(cfg);

% regular
% conditionNamesVector = repmat(cfg.design.names, nbRepet, 1);

% Hans scrambling variant
% First three (1-2-3) are repeated in the opposite manner (3-2-1) at the
% end. Rest is shuffled
% SHUFFLE - GET ORDER OF THE FIRST REP - SHUFFLE INDIVIDUALLY ALL THE REPS
% - PUT TOGETHER
firstRepetition = shuffle(cfg.design.names);
conditionNamesVector = firstRepetition;
for rep = 2:nbRepet-1
    condIsRepeated = true;
    while condIsRepeated 
        thisShuffledRepetition = shuffle(cfg.design.names);
        if not(strcmp(thisShuffledRepetition{1}, conditionNamesVector{end}))
            conditionNamesVector = vertcat(conditionNamesVector,thisShuffledRepetition);
            condIsRepeated = false;
        end
    end
end

if strcmp(firstRepetition{end}, conditionNamesVector{end})
    conditionNamesVector = vertcat(conditionNamesVector, ...
                                    firstRepetition{5}, firstRepetition{6}, firstRepetition{4}, ...
                                    firstRepetition{3}, firstRepetition{2}, firstRepetition{1});
else
    conditionNamesVector = vertcat(conditionNamesVector, ...
                                    firstRepetition{6}, firstRepetition{5}, firstRepetition{4}, ...
                                    firstRepetition{3}, firstRepetition{2}, firstRepetition{1});
end


% Get the index of each condition
nameCondition1 = 'fw';
nameCondition2 = 'sfw';
nameCondition3 = 'bw';
nameCondition4 = 'sbw';
nameCondition5 = 'ld';
nameCondition6 = 'sld';

CON1_INDEX = find(strcmp(conditionNamesVector, nameCondition1));
CON2_INDEX = find(strcmp(conditionNamesVector, nameCondition2));
CON3_INDEX = find(strcmp(conditionNamesVector, nameCondition3));
CON4_INDEX = find(strcmp(conditionNamesVector, nameCondition4));
CON5_INDEX = find(strcmp(conditionNamesVector, nameCondition5));
CON6_INDEX = find(strcmp(conditionNamesVector, nameCondition6));

end
