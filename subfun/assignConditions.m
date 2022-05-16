% (C) Copyright 2020 CPP visual motion localizer developpers

function [conditionNamesVector, CON1_INDEX, CON2_INDEX, CON3_INDEX, CON4_INDEX, ...
          CON5_INDEX, CON6_INDEX, CON7_INDEX, CON8_INDEX] = assignConditions(cfg)

    [~, nbRepet] = getDesignInput(cfg);

    conditionNamesVector = repmat(cfg.design.names, nbRepet, 1);

    % Get the index of each condition
    nameCondition1 = 'frw';
    nameCondition2 = 'fpw';
    nameCondition3 = 'fnw';
    nameCondition4 = 'ffs';
    nameCondition5 = 'brw';
    nameCondition6 = 'bpw';
    nameCondition7 = 'bnw';
    nameCondition8 = 'bfs';
    
    CON1_INDEX = find(strcmp(conditionNamesVector, nameCondition1));
    CON2_INDEX = find(strcmp(conditionNamesVector, nameCondition2));
    CON3_INDEX = find(strcmp(conditionNamesVector, nameCondition3));
    CON4_INDEX = find(strcmp(conditionNamesVector, nameCondition4));
    CON5_INDEX = find(strcmp(conditionNamesVector, nameCondition5));
    CON6_INDEX = find(strcmp(conditionNamesVector, nameCondition6));
    CON7_INDEX = find(strcmp(conditionNamesVector, nameCondition7));
    CON8_INDEX = find(strcmp(conditionNamesVector, nameCondition8));

end
