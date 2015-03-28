function testImage = getImage()

% read in the test images
testlocation = '/Users/Yan/Documents/MATLAB/sp3/MLSP_Images/';
fileNames = dir(fullfile(testlocation, '*.jpg'));
% disp(length(fileNames));
testimage = cell(length(fileNames), 1);
for n = 1:length(fileNames)
    filename = fileNames(n).name;
    filelocation = strcat(testlocation, filename);
    % imagesc(imread(filelocation));
    % greyscaleimage = squeeze(mean(imread(filelocation),3));
    % imagesc(greyscaleimage);
    xtest = double(squeeze(mean(imread(filelocation),3)));
    xtest = xtest - mean(xtest(:));
    xtest = xtest / norm(xtest(:));
    testimage{n} = xtest;
    % [numrows, numcolumns] = size(image{n});
end
testImage = testimage;