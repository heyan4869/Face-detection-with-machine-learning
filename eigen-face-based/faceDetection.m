function plotFace = faceDetection(numOfImage, numOfFace)

testImage = getImage();

faceSpot = findSpot(numOfImage, numOfFace);

imagesc(testImage{numOfImage});
for j = 1 : 5
    facePosition = faceSpot{j};
    [nrow, ncol] = size(facePosition);
    for k = 1 : nrow
        rectangle('Position', [facePosition(k, 1) facePosition(k, 2) 64 64]);
    end
end

% plotFace = testImage{numOfImage};
plotFace = [];