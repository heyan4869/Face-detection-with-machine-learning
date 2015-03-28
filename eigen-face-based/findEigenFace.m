function eigenfaceimage = findEigenFace(location)

myPath= location;
% location = '/Users/Yan/Documents/MATLAB/workspace/lfw1000/'
fileNames = dir(fullfile(myPath, '*.pgm'));
% disp(length(fileNames));
trainimage = cell(length(fileNames), 1);
Y = [];
for k = 1:length(fileNames)
    filename = fileNames(k).name;
    filelocation = strcat(location, filename);
    % imagesc(imread(filelocation));
    % add mean normalization and variance normalization
    x = double(imread(filelocation));
    x = x - mean(x(:));
    x = x / norm(x(:));
    trainimage{k} = x;
    % imagesc(trainimage{k});
    [nrows, ncolumns] = size(trainimage{k});
    Y = [Y trainimage{k}(:)];
end

[U,S,V] = svd(Y,0);
eigenfacevector = U(:, 1);
eigenfaceimage = reshape(eigenfacevector, nrows, ncolumns);
imagesc(eigenfaceimage)