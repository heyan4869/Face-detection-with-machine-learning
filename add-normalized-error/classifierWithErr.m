function [classifiedFaceResult, classifiedNonFaceResult, resultGramErr] = classifierWithErr(k)

% calculate the predictor parameter
thresholdOfH = predictWithErr(k);

% get the weight expression of the test data
[faceExpressionTestErr, numOfFaceTest] = faceExpressTestErr(k);
[nonFaceExpressionTestErr, numOfNonfaceTest] = nonFaceExpressTestErr(k);

% get the err
faceExpressionTestOfErr = faceExpressionTestAddErr(k);
nonFaceExpressionTestOfErr = nonFaceExpressionTestAddErr(k);
expressionOfErr = [faceExpressionTestOfErr, nonFaceExpressionTestOfErr];

% store the right label
trueLabelTest = [ones(1, numOfFaceTest), ones(1, numOfNonfaceTest).*(-1)];
predictLabelTest = ones(1, numOfFaceTest + numOfNonfaceTest);

% merge the weight expression
weightOfEigenTestErr = [faceExpressionTestErr, nonFaceExpressionTestErr];

% use H to classify
tempWeight = weightOfEigenTestErr;
count = 0;
resultGramErr = [];

for curr = 1 : numOfFaceTest + numOfNonfaceTest
    temp = 0;
    [rownum, ~] = size(thresholdOfH);
    for pointer = 1 : (rownum - 1)
        if tempWeight(thresholdOfH(pointer, 3), curr) < thresholdOfH(pointer, 2)
            temp = temp + thresholdOfH(pointer, 1) * (-1) * thresholdOfH(pointer, 4);
        else
            temp = temp + thresholdOfH(pointer, 1) * thresholdOfH(pointer, 4);
        end
    end
    
    if expressionOfErr(1, curr) < thresholdOfH(rownum, 2)
        temp = temp + thresholdOfH(rownum, 1) * (-1) * thresholdOfH(rownum, 4);
    else
        temp = temp + thresholdOfH(rownum, 1) * thresholdOfH(rownum, 4);
    end
    
    
    if temp < 1.2
        predictLabelTest(1, curr) = -1;
    end
    
    resultGramErr = [resultGramErr temp];
end

% testErr = [];
% for pointer = 1 : numOfFaceTest
%     if expressionOfErr(1, pointer) < thresholdOfH(rownum, 2)
%         predictLabelTest(1, pointer) = 1;
%         testErr = [testErr 1];
%     else
%         testErr = [testErr -1];
%     end
% end
    
% count the num of wrong label overall
for flag = 1 : numOfFaceTest + numOfNonfaceTest
    if predictLabelTest(1, flag) ~= trueLabelTest(1, flag)
        count = count + 1;
    end
end

% count the num of wrong label for face
counter = 0;
for cur = 1 : numOfFaceTest
    if predictLabelTest(1, cur) ~= trueLabelTest(1, cur)
        counter = counter + 1;
    end
end
        
classifiedFaceResult = counter / numOfFaceTest;
classifiedNonFaceResult = (count - counter) / numOfNonfaceTest;
