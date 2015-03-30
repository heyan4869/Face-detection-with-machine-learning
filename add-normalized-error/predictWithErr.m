function thresholdOfH = predictWithErr(k)

% calculate the weight expression of face and non-face with err
[faceExpression, numOfFace] = faceExpressWithErr(k);
[nonFaceExpression, numOfNonFace] = nonFaceExpressWithErr(k);

% get the expression with error considered
faceExpressionErr = faceExpressionAddErr(k);
nonFaceExpressionErr = nonFaceExpressionAddErr(k);

% add together
% faceExpression = [faceExpression; faceExpressionErr];
% nonFaceExpression = [nonFaceExpression; nonFaceExpressionErr];

trueLabel = [ones(1, numOfFace), ones(1, numOfNonFace).*(-1)];
updateResult = ones(1, numOfFace + numOfNonFace);
updateWeight = ones(1, numOfFace + numOfNonFace)./(numOfFace + numOfNonFace);
weightOfEigen = [faceExpression, nonFaceExpression];
numOfRound = 10;
% num of row 
thresholdOfH = zeros(numOfRound, 4);

for round = 1 : numOfRound
    roundResult = [];
    roundSign = [];
    setOfMinErr = zeros(1, numOfRound);
    setOfMinThreshold = zeros(1, numOfRound);
    positionOfCut = zeros(1, k);
    % add the level of err
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
            tempLabel = ones(1, numOfFace + numOfNonFace);
            % count = 0;
            tempErr = 0;
            % check if predict right
            for curr = 1 : (numOfFace + numOfNonFace)
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

        setOfMinThreshold(1, level) = minLevelWeight + gap * minOfErr;
        positionOfCut(1, level) = minOfErr;
    end
    numOfMin = min(setOfMinErr);
    indexOfMin = find(setOfMinErr == numOfMin);
    minThresholdOverall = setOfMinThreshold(1, indexOfMin);
    resultOfThreshold = minThresholdOverall;
    % update the predict label
    updateResult = roundResult(indexOfMin * positionOfCut(indexOfMin), :);
    
    % update the weight based on label result
    alphaOfErr = 0.5 * log((1 - numOfMin) / numOfMin);
    for temp = 1 : numOfFace + numOfNonFace
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

% consider error as a new feature
errExpression = [faceExpressionErr, nonFaceExpressionErr];
maxOfErr = max(errExpression);
minOfErr = min(errExpression);
minErrBackup = minOfErr;
errGap = (maxOfErr - minOfErr) / 100;
errSum = zeros(1, 100);
errResult = [];
errSign = [];
for errCut = 1 : 100
    currThreshold = minOfErr + errCut * errGap;
    currLabel = ones(1, numOfFace + numOfNonFace);
    currErr = 0;
    
    for pointer = 1 : (numOfFace + numOfNonFace)
        if errExpression(1, pointer) > currThreshold
            currLabel(1, pointer) = -1;
        end
        if currLabel(1, pointer) ~= trueLabel(1, pointer)
            currErr = currErr + 1;
        end
    end
    
%     if currErr > (numOfFace + numOfNonFace) / 2
%         errSign = [errSign -1];
%         currErr = (numOfFace + numOfNonFace) - currErr;
%         currLabel = -currLabel;
%     else
%         errSign = [errSign 1];
%     end
    errSign = [errSign -1];
    errResult = [errResult; currLabel];
    errSum(1, errCut) = currErr / (numOfFace + numOfNonFace);
end

minErr = min(errSum);
alphaErr = 0.5 * log((1 - minErr) / minErr);
indexOfMinErr = find(errSum == min(errSum));
[~, indcol] = size(indexOfMinErr);
if indcol > 1
    indexOfMinErr = indexOfMinErr(1, 1);
end
errThreshold = minOfErr + errGap * indexOfMinErr;
    
addSign = errSign(1, indexOfMinErr);

% add the result to thresholdOfH
thresholdOfH(round + 1, 1) = alphaErr;
thresholdOfH(round + 1, 2) = errThreshold;
thresholdOfH(round + 1, 3) = 11;
thresholdOfH(round + 1, 4) = addSign;

beep;
