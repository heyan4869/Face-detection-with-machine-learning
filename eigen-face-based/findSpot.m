function faceSpot = findSpot(numOfImage, numOfFace)

faceMatch = findMatch(numOfImage);

% testImage = getImage();

faceSpot = cell(5, 1);
scaleSize = [0.5, 0.75, 1, 1.5, 2];

for i = 1 : 5
    hLocalMax = vision.LocalMaximaFinder;
    hLocalMax.MaximumNumLocalMaxima = numOfFace;
    hLocalMax.NeighborhoodSize = [64*scaleSize(i)+1 64*scaleSize(i)+1];
    hLocalMax.Threshold = mean(faceMatch{i}(:)) + std(faceMatch{i}(:));
    faceSpot{i} = step(hLocalMax, faceMatch{i}) / scaleSize(i);
end