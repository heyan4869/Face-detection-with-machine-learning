function eigenFaces = findEigenFaces(k)

location = '/Users/Yan/Documents/MATLAB/sp3/lfw1000/';
myPath= location;
fileNames = dir(fullfile(myPath, '*.pgm'));
% disp(length(fileNames));
trainface = cell(length(fileNames), 1);
Y = [];
for i = 1 : length(fileNames)
    filename = fileNames(i).name;
    filelocation = strcat(location, filename);
    % imagesc(imread(filelocation));
    % add mean normalization and variance normalization
    x = double(imread(filelocation));
    x = x - mean(x(:));
    if norm(x(:)) ~= 0
        x = x / norm(x(:));
    end
    trainface{i} = x;
    % imagesc(trainface{k});
    [nrows, ncolumns] = size(trainface{i});
    Y = [Y trainface{i}(:)];
end

[U,S,V] = svd(Y,0);
eigenFaces = cell(k, 1);
for j = 1 : k
    eigenfacevector = U(:, j);
    eigenFaces{j} = reshape(eigenfacevector, nrows, ncolumns);
end

% yy = [];
% for count = 1 : k
%     y = eigenFaces{count};
%     scaledy = imresize(y, [19, 19]);
%     scaledy = reshape(scaledy, 19 * 19, 1);
%     yy = [yy scaledy(:)];
% end
    