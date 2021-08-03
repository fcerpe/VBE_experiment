% (C) Copyright 2020 CPP visual motion localizer developpers

function [conditionNamesVector, CON1_INDEX, CON2_INDEX, CON3_INDEX, CON4_INDEX, CON5_INDEX, CON6_INDEX] = assignConditions(cfg)

    [~, nbRepet] = getDesignInput(cfg);

    conditionNamesVector = repmat(cfg.design.names, nbRepet, 1);

    % Get the index of each condition
    nameCondition1 = 'FW';
    nameCondition2 = 'FWS';
    nameCondition3 = 'BW';
    nameCondition4 = 'BWS';
    nameCondition5 = 'LD';
    nameCondition6 = 'LDS';
    
    CON1_INDEX = find(strcmp(conditionNamesVector, nameCondition1));
    CON2_INDEX = find(strcmp(conditionNamesVector, nameCondition2));
    CON3_INDEX = find(strcmp(conditionNamesVector, nameCondition3));
    CON4_INDEX = find(strcmp(conditionNamesVector, nameCondition4));
    CON5_INDEX = find(strcmp(conditionNamesVector, nameCondition5));
    CON6_INDEX = find(strcmp(conditionNamesVector, nameCondition6));

end
