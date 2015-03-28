function faceMatch = findMatch(num)

eigenfaceimage = findEigenFace('/Users/Yan/Documents/MATLAB/sp3/lfw1000/');

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

scaledImage = cell(5, 1);
testImageCurr = testimage{num};
[nrows, ncolumns] = size(testImageCurr);
scaledImage{1} = imresize(testImageCurr,[nrows * 0.5, ncolumns * 0.5]);
scaledImage{2} = imresize(testImageCurr,[nrows * 0.75, ncolumns * 0.75]);
scaledImage{3} = testImageCurr;
scaledImage{4} = imresize(testImageCurr,[nrows * 1.5, ncolumns * 1.5]);
scaledImage{5} = imresize(testImageCurr,[nrows * 2, ncolumns * 2]);

patchScore = cell(5, 1);

for m = 1 : 5
    A = scaledImage{m};
    E = eigenfaceimage;
    % no need to scale the eigen face
    % E = imresize(E, [64 * scaleArray(m), 64 * scaleArray(m)]);
    [N, M] = size(E);
    pixelsinpatch = N * M;
    integralA = cumsum(cumsum(A,1),2);
    patchmeansofA = [];
    
    for i = 1:size(A,1)-N+1
        for j = 1:size(A,2)-M+1
            a1 = integralA(i,j);
            a2 = integralA(i+N-1,j);
            a3 = integralA(i,j+M-1);
            a4 = integralA(i+N-1,j+M-1);
            patchmeansofA(i,j) = a4 + a1 - a2 - a3;
        end
    end
    
    tmpim = conv2(A, fliplr(flipud(E)));
    convolvedimage = tmpim(N:end, M:end);
    [rownum, colnum] = size(convolvedimage);
    scaledpatchmeansofA = imresize(patchmeansofA,[rownum,colnum]);
    
    sumE = sum(E(:));
    % patchscore = convolvedimage - sumE*patchmeansofA(1:size(convolvedimage,1),1:size(convolvedimage,2));
    patchScore{m} = convolvedimage - sumE*scaledpatchmeansofA(1:size(convolvedimage,1),1:size(convolvedimage,2));
end

faceMatch = patchScore;
