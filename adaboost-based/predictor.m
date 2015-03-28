function thresholdOfH = predictor(k)

% calculate the weight expression of face and non-face
[faceExpression, numOfFace] = faceExpress(k);
[nonFaceExpression, numOfNonface] = nonFaceExpress(k);

trueLabel = [ones(1, numOfFace), ones(1, numOfNonface).*(-1)];
updateResult = ones(1, numOfFace + numOfNonface);
updateWeight = ones(1, numOfFace + numOfNonface)./(numOfFace + numOfNonface);
weightOfEigen = [faceExpression, nonFaceExpression];
numOfRound = 20;
thresholdOfH = zeros(numOfRound, 4);

for round = 1 : numOfRound
    roundResult = [];
    roundSign = [];
    setOfMinErr = zeros(1, 10);
    setOfMinThreshold = zeros(1, 10);
    positionOfCut = zeros(1, k);
    for level = 1 : k
        levelWeight = weightOfEigen(level, :);
        maxLevelWeight = max(levelWeight);
        minLevelWeight = min(levelWeight);
        gap = (maxLevelWeight - minLevelWeight) / 50;
        err = zeros(1, 50);
        
        % numOfCut = 0;
        % find the error weight of each cut in the current level
        for cut = 1 : 50
            tempOfThreshold = minLevelWeight + gap * cut;
            tempLabel = ones(1, numOfFace + numOfNonface);
            % count = 0;
            tempErr = 0;
            % check if predict right
            for curr = 1 : (numOfFace + numOfNonface)
                if levelWeight(1, curr) < tempOfThreshold
                    tempLabel(1, curr) = -1;
                end
                if tempLabel(1, curr) ~= trueLabel(1, curr)
                    % count = count + 1;
                    tempErr = tempErr + updateWeight(1, curr);
                    % updateResult(1, curr) = -1;
                end
            end
            if tempErr > 0.5
                tempLabel = -tempLabel;
                roundSign = [roundSign -1];
                tempErr = 1 - tempErr;
            else
                roundSign = [roundSign 1];
            end
            % store the predict label for every loop
            roundResult = [roundResult; tempLabel];
            
            err(1, cut) = tempErr;
        end
        [setOfMinErr(1, level),minOfErr] = min(err);
        % minOfErr = find(err == min(err));
%         [~, numcol] = size(minOfErr);
%         if numcol > 1
%             setOfMinThreshold(1, level) = minLevelWeight + gap * minOfErr(1, 1);
%             numOfCut = minOfErr(1, 1);
%         else
%             setOfMinThreshold(1, level) = minLevelWeight + gap * minOfErr;
%             numOfCut = minOfErr;
%         end
        setOfMinThreshold(1, level) = minLevelWeight + gap * minOfErr;
        positionOfCut(1, level) = minOfErr;
    end
    numOfMin = min(setOfMinErr);
    indexOfMin = find(setOfMinErr == numOfMin);
    resultOfThreshold = setOfMinThreshold(1, indexOfMin);
    % resultOfThreshold = minThresholdOverall;
    % update the predict label
    updateResult = roundResult(indexOfMin * positionOfCut(indexOfMin), :);
    
    % update the weight based on label result
    alphaOfErr = 0.5 * log((1 - numOfMin) / numOfMin);
    for temp = 1 : numOfFace + numOfNonface
        if updateResult(1, temp) ~= trueLabel(1, temp)
            updateWeight(1, temp) = updateWeight(1, temp) * exp(alphaOfErr);
        else
            updateWeight(1, temp) = updateWeight(1, temp) * exp(-1 * alphaOfErr);
        end
    end
    updateWeight = updateWeight / sum(updateWeight);
    
    % update the model of H
    thresholdOfH(round, 1) = alphaOfErr;
    thresholdOfH(round, 2) = resultOfThreshold;
    thresholdOfH(round, 3) = indexOfMin;
    thresholdOfH(round, 4) = roundSign(1, indexOfMin * positionOfCut(indexOfMin));
    
end