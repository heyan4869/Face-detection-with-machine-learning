function nonFaceExpressionErr = nonFaceExpressionAddErr(k)

eigenFaces = findEigenFaces(k);

eigenFacesReshape = [];
nrow = 19;
ncol = 19;
for j = 1 : k
    y = eigenFaces{j};
    scaledy = imresize(y, [nrow, ncol]);
    scaledy = scaledy(:);
    eigenFacesReshape = [eigenFacesReshape scaledy];
end

% get the non face expression with eigen faces previously
[nonFaceExpressionPre, numOfNonFace] = nonFaceExpressWithErr(k);
% nonFaceExpressionErr = [nonFaceExpressionPre; zeros(1, numOfNonFace)];
nonFaceExpressionErr = zeros(1, numOfNonFace);
[addrow, addcol] = size(nonFaceExpressionPre);

% calculate the err and add to the face expression
location = '/Users/Yan/Documents/MATLAB/sp3/BoostingData/train/non-face/';
myPath= location;
fileNames = dir(fullfile(myPath, '*.pgm'));
for i = 1 : length(fileNames)
    % if i == 3978
    %     disp(i);
    % end
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
    sumwe = eigenFacesReshape * nonFaceExpressionPre(:, i);
    
    % calculate each err
    nonFaceEigenErr = sumsqr(scaledFace - sumwe) / (nrow * ncol);
    
    % if nonFaceEigenErr == 0
    %     nonFaceEigenErr = 1;
    % end
    
    % add to face weight expression
    nonFaceExpressionErr(1, i) = nonFaceEigenErr;
end

