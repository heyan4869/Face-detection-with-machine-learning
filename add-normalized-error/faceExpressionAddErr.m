function faceExpressionErr = faceExpressionAddErr(k)

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

% get the face expression with eigen faces previously
[faceExpressionPre, numOfFace] = faceExpressWithErr(k);
% faceExpressionErr = [faceExpressionPre; zeros(1, numOfFace)];
faceExpressionErr = zeros(1, numOfFace);
% [addrow, addcol] = size(faceExpressionErr);
% [nonFaceExpressionPre, numOfNonface] = nonFaceExpressWithErr(k);

% calculate the err and add to the face expression
location = '/Users/Yan/Documents/MATLAB/sp3/BoostingData/train/face/';
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
    sumwe = eigenFacesReshape * faceExpressionPre(:, i);
    
    % calculate each err
    faceEigenTestErr = sumsqr(scaledFace - sumwe) / (nrow * ncol);
    
    % add to face weight expression, calculate the log of the error to 
    % make the less error value become larger
    faceExpressionErr(1, i) = faceEigenTestErr;
end

