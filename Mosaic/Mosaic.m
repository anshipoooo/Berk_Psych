clear all;
close all;
clc

%% Dimensions
currFolder=pwd;
fileTypes={'.jpg' '.png' '.JPG' '.PNG'};

% when running the program, be sure to change the picture's name below
desiredImage=imread([currFolder,'\IMG_7265.jpg']);
desiredDimensions=[130 130];
numSquares=10;
maxFinalImage=4000;
cd 'Pictures';
currFolder=pwd;




% preview desired image to make sure it looks good
sqSizes = 1/numSquares;
desiredImage = imresize(desiredImage,desiredDimensions,'nearest');%
figure;imshow(imresize(desiredImage,10,'nearest'));
title(['Desired Image:' num2str(size(desiredImage,1)) 'x' num2str(size(desiredImage,2)) 'pixels']);

 

% now pull all the image file names out of the directory
selPhotos = [];
for t = 1:length(fileTypes)
    selPhotos = [selPhotos;dir([currFolder '/*' fileTypes{t}]);];
end

% break them up into pieces, store them in allPhotos
allPhotos = [];
allCols1 = [];
allCols2 = [];
for p = 1:length(selPhotos)
    tmpPhoto=imread([currFolder '/' selPhotos(p).name]);
    [~,smDim]=min([size(tmpPhoto,1) size(tmpPhoto,2)]);
    ar=size(tmpPhoto,3-smDim)./size(tmpPhoto,smDim);
    multFact=[1 1];
    multFace(3-smDim)=ar;
    rows=floor(multFact(1)*(1./sqSizes));
    cols=floor(multFact(2)*(1./sqSizes));
    sqSize=floor(size(tmpPhoto,smDim)*sqSizes);
    tmpPhoto=tmpPhoto(1:(sqSize*rows),1:(sqSize*cols),:);
    tmpPhoto=mat2cell(tmpPhoto,repmat(sqSize,1,rows),repmat(sqSize,1,cols),3);
    allPhotos=[allPhotos reshape(tmpPhoto,1,rows*cols)];

    allCols1=[allCols1 cell2mat(reshape(cellfun(@(x) mode(double(reshape(x,sqSize^2,3)))', tmpPhoto,'unif',0),1,rows.*cols))];
    allCols2 = [allCols2 cell2mat(reshape(cellfun(@(x) reshape(mean(mean(x,1),2),[1 3])',tmpPhoto,'unif',0),1,rows*cols))];
    disp(['Photo ' num2str(p) ' out of ' num2str(length(selPhotos)) ' broken into ' num2str(rows) ' rows x ' num2str(cols) ' columns']);
end
disp(['Full set has ' num2str(numel(allPhotos)) ' image fragments to work with']);

if (numel(desiredImage)/3)>numel(allPhotos)
    disp(['Warning: only ' num2str(numel(allPhotos)) ' picture fragments have been extracted. You need ' num2str(numel(desiredImage)/3) ' for this image']);
    disp('Some photos will be repeated.');
end


% loop through every pixel of desired Im, find the extracted patches with the closest average color
allCols1 = allCols2;
finalIm = cell(size(desiredImage,1),size(desiredImage,2));
searchOrder = randperm(numel(desiredImage)/3);
for s = 1:(numel(desiredImage)/3)
    [i,j] = ind2sub([size(desiredImage,1) size(desiredImage,2)],searchOrder(s));
    tmpDiffs = abs(double(repmat(reshape(desiredImage(i,j,:), ...
    [3 1]),1,size(allCols1,2)))-allCols1);
    [~,selPhoto] = min(sum(tmpDiffs));
    finalIm{i,j} = allPhotos{selPhoto};
    allCols1(:,selPhoto) = NaN;
    selPhotoMat(i,j) = selPhoto;
    if s == numel(allPhotos)
        allCols1 = allCols2;
    end
end
% biggestDim =  max(max(cellfun(@max,(cellfun(@size,finalIm,'unif',0)))));
finalSqSize = round(maxFinalImage./max(size(desiredImage)));
finalIm = cellfun(@(x) imresize(x,[finalSqSize finalSqSize]),finalIm,'unif',0);
finalIm= cell2mat(finalIm);
figure;imshow(finalIm)
cd ..
saveIm = input('Save image (y/n)? ','s');
if strcmp(saveIm,'y')
    fname = input('Enter filename (no extension): ','s');
    disp('Saving image. This may take a moment...');
    imwrite(finalIm,[fname '.png']);
    disp('Done!');
end

% allCols = allCols2(:,selPhotoMat);
% allCols = reshape(allCols',[size(desiredIm,1) size(desiredIm,2) 3]);
% figure;imshow(uint8(imresize(allCols,50,'nearest')))
