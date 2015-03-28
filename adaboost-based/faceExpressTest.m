function [faceExpression, numOfFace] = faceExpressTest(k)

eigenFaces = findEigenFaces(k);
% imagesc(eigenFaces{1});

% read the training face images
location = '/Users/Yan/Documents/MATLAB/sp3/BoostingData/test/face/';
myPath= location;
fileNames = dir(fullfile(myPath, '*.pgm'));
trainface = cell(length(fileNames), 1);
eigenExpression = [];
numOfFace = length(fileNames);
for i = 1 : length(fileNames)
    filename = fileNames(i).name;
    filelocation = strcat(location, filename);
    x = double(imread(filelocation));
    x = x - mean(x(:));
    if norm(x(:)) ~= 0
        x = x / norm(x(:));
    end
    trainface{i} = x;
    [nrow, ncol] = size(x);
    scaledx = x(:);
    
    % compute the eigen weight
    eigenWeight = cell(k, 1);
    for j = 1 : k
        y = eigenFaces{j};
        % [nrows, ncols] = size(y);
        scaledy = imresize(y, [nrow, ncol]);
        % imagesc(scaledy);
        scaledy = scaledy(:);
        
        eigenWeight{j} = pinv(scaledy) * scaledx;
        
        scaledx = scaledx - eigenWeight{j} * scaledy;
    end
    eigenExpression = [eigenExpression eigenWeight(:)];
end
faceExpression = cell2mat(eigenExpression);