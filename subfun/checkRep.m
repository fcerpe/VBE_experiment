function outBool = checkRep(target, shuffled)
% CHECK REPETITIONS 
% Given the target matrix and the shuffle matrix from expDesign, check 
% whether the target events are repeated, and how frequently. We want to
% avoid possible cue effects

for i = 1:size(shuffled,1)
    impo = shu(tar(:,i) > 0,i);
    
    % che criterio? Non più di due per condizione non vale molto
    if length(impo) <= 

end



outBool = false;
end

