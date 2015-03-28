function [faceExpression, numOfFace, eigenMatrix] = faceExpress(k)

eigenFaces = findEigenFaces(k);
% imagesc(eigenFaces{1});

% read the training face images
location = '/Users/Yan/Documents/MATLAB/sp3/BoostingData/train/face/';
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
    % scaledx = reshape(x, nrow * ncol, 1);
    scaledx = x(:);
   
    
    % compute the eigen weight
    eigenWeight = cell(k, 1);
    eigenMatrix = [];
    for j = 1 : k
        y = eigenFaces{j};
        scaledy = imresize(y, [nrow, ncol]);
        scaledy = scaledy(:);
        eigenMatrix = [eigenMatrix scaledy];
        eigenWeight{j} = pinv(scaledy) * scaledx;
        
        scaledx = scaledx - eigenWeight{j} * scaledy;
        
    end
    eigenExpression = [eigenExpression eigenWeight(:)];
end
faceExpression = cell2mat(eigenExpression);