function faceExpressionTestErr = faceExpressionTestAddErr(k)

eigenFaces = findEigenFaces(k);

% reshape the eigen faces
eigenFacesReshape = [];
nrow = 19;
ncol = 19;
for j = 1 : k
    y = eigenFaces{j};
    scaledy = imresize(y, [nrow, ncol]);
    scaledy = scaledy(:);
    eigenFacesReshape = [eigenFacesReshape scaledy];
end

% get the test face expression with eigen faces previously
[faceExpressionTestPre, numOfFace] = faceExpressTestErr(k);
faceExpressionTestErr = zeros(1, numOfFace);
[addrow, addcol] = size(faceExpressionTestErr);

% calculate the err and add to the face expression
location = '/Users/Yan/Documents/MATLAB/sp3/BoostingData/test/face/';
myPath= location;
fileNames = dir(fullfile(myPath, '*.pgm'));
for i = 1 : length(fileNames)
    filename = fileNames(i).name;
    filelocation = strcat(location, filename);
    x = double(imread(filelocation));
    x = x - mean(x(:));
    if norm(x(:)) ~= 0
        x = x / norm(x(:));
    end
    [nrow, ncol] = size(x);
    scaledFace = x(:);
    
    % calculate w*E
    sumwe = zeros(nrow * ncol, 1);
    sumwe = eigenFacesReshape * faceExpressionTestPre(:, i);
    
    % calculate each err
    faceEigenTestErr = (1 / (nrow * ncol)) * sumsqr(scaledFace - sumwe);
    
    % add to face weight expression
    faceExpressionTestErr(1, i) = faceEigenTestErr;
end