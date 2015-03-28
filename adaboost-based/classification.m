function [classifiedFaceResult, classifiedNonFaceResult, resultGram] = classification(k)

% calculate the predictor parameter
thresholdOfH = predictor(k);

% get the weight expression of the test data
[faceExpressionTest, numOfFaceTest] = faceExpressTest(k);
[nonFaceExpressionTest, numOfNonfaceTest] = nonFaceExpressTest(k);

% store the right label
trueLabelTest = [ones(1, numOfFaceTest), ones(1, numOfNonfaceTest).*(-1)];
predictLabelTest = ones(1, numOfFaceTest + numOfNonfaceTest);

% merge the weight expression
weightOfEigenTest = [faceExpressionTest, nonFaceExpressionTest];

% use H to classify
tempWeight = weightOfEigenTest;
count = 0;
resultGram = [];

% for curr = 1 : numOfFaceTest + numOfNonfaceTest
%     if tempWeight(1, curr) < thresholdOfH(1, 2)
%         predictLabelTest(1, curr) = -1;
%     end
%     if predictLabelTest(1, curr) ~= trueLabelTest(1, curr)
%         count = count + 1;
%     end
% end

for curr = 1 : numOfFaceTest + numOfNonfaceTest
    temp = 0;
    [rownum, colnum] = size(thresholdOfH);
    for pointer = 1 : rownum
        if tempWeight(thresholdOfH(pointer, 3), curr) < thresholdOfH(pointer, 2)
            temp = temp + thresholdOfH(pointer, 1) * (-1) * thresholdOfH(pointer, 4);
        else
            temp = temp + thresholdOfH(pointer, 1) * thresholdOfH(pointer, 4);
        end
    end
    
    if temp < 0.4
        predictLabelTest(1, curr) = -1;
    end
    if predictLabelTest(1, curr) ~= trueLabelTest(1, curr)
        count = count + 1;
    end
    
    resultGram = [resultGram temp];
end

counter = 0;
for cur = 1 : numOfFaceTest
    if predictLabelTest(1, cur) ~= trueLabelTest(1, cur)
        counter = counter + 1;
    end
end
        
classifiedFaceResult = counter / numOfFaceTest;
classifiedNonFaceResult = (count - counter) / numOfNonfaceTest;