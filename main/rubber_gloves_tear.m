function [tearMaskProps, tearDefect]=rubber_gloves_tear(img)
oriImg=img;
%resize image
oriImg=imresize(oriImg, [1920 NaN]);

%Convert to grayscale
grayImg = rgb2gray(oriImg);

%Perform gaussian blurring to reduce noise
grayImg = imgaussfilt(grayImg,2);

%Use otsu thresholding
level = graythresh(grayImg);
%binarize image
bwImg = imbinarize(grayImg,level);
%Remove small object
bwImg = bwareaopen(bwImg,1000);

%connect lines
bwImg = imclose(bwImg, strel('disk',3));
%fill the holes in the mask
filledMask = imfill(bwImg, 'holes');
%Get the biggest object
filledMask=bwareafilt(filledMask, 1);
propsFilledMask=regionprops(filledMask,'Centroid', 'Area');

%Get the centroid and area of the glove
gloveCentroid = propsFilledMask.Centroid;
gloveArea = propsFilledMask.Area;

%Use grayworld algorithm to reduce wrong color temperature effect
gwImg = grayworld(oriImg);

%crop out the gloves region from original image
invMask = ~filledMask;
glove = gwImg;
glove(repmat(invMask, [1, 1, 3])) = 0;

%Get palm mask
open = strel('disk',150);
palmImg = imopen(filledMask, open);

%Get finger mask
finger = imsubtract(filledMask,palmImg);
finger = im2bw(finger);
finger = bwareaopen(finger,20000);

%separate fingers
seOpen = strel('disk',35);
fingerMask = imopen(finger, seOpen);

%Get bounding box and area of the regions
props=regionprops(fingerMask,'BoundingBox', 'Area', 'MaxFeretProperties');
regionAreas=[props.Area];
fingerNum = length(regionAreas);

maxUpperFrtPnt = [];

%Find the max feret coordinates furthest from the glove centroid as finger
%tips
for k=1:numel(props)
    firstDist = norm(props(k).MaxFeretCoordinates(1, :)-gloveCentroid);
    secondDist = norm(props(k).MaxFeretCoordinates(2, :)-gloveCentroid);

    if(firstDist > secondDist)
        upFrtPnt = props(k).MaxFeretCoordinates(1, :);
    else
        upFrtPnt = props(k).MaxFeretCoordinates(2, :);
    end

    maxUpperFrtPnt = [maxUpperFrtPnt; upFrtPnt];
end

%create finger tip mask
fingerTipMask = zeros(size(filledMask));

for i = 1:size(maxUpperFrtPnt,1)
    x=round(maxUpperFrtPnt(i,1));
    y=round(maxUpperFrtPnt(i,2));
    fingerTipMask(y,x) = 1;
end
%Dilate the finger tip point
fingerTipMask = imdilate(fingerTipMask,strel('disk',40));


%lower and upper boundary for YCbCr skin detection
skinLower = [90, 90, 140];
skinUpper = [200, 130, 170];

%skin detection using YCbCr
imgYcbcr=rgb2ycbcr(glove);

skinMask = imgYcbcr(:,:,1) >= skinLower(1) & imgYcbcr(:,:,1) <= skinUpper(1) & ...
            imgYcbcr(:,:,2) >= skinLower(2) & imgYcbcr(:,:,2) <= skinUpper(2) & ...
            imgYcbcr(:,:,3) >= skinLower(3) & imgYcbcr(:,:,3) <= skinUpper(3);



%perform open oeration to clean thin lines
skinMask = imopen(skinMask, strel('disk', 5));

%Remove the border region
skinMask = imclearborder(skinMask);

%Remove region less than 0.5% of gloves
skinMask = bwareaopen(skinMask,round(gloveArea * 0.005));

tearDefect = [];

tearMaskProps = regionprops(skinMask, 'BoundingBox');

if(~isempty(tearMaskProps))
    %fix size for cropped image
    targetSize = [NaN 156];

    for k=1:numel(tearMaskProps)
        tearBox = tearMaskProps(k).BoundingBox;
    
        %crop tear region in original image and resize
        tearRegion = imcrop(skinMask,tearBox);
        tearRegion = imresize(tearRegion, targetSize);

        %crop finger tip region in original image and resize
        fingerTipRegion = imcrop(fingerTipMask,tearBox);
        fingerTipRegion = imresize(fingerTipRegion, targetSize);

        %To ensure the defect is tearing and not finger holes
        fingerTipIntersect = fingerTipRegion & tearRegion;
        if ~any(fingerTipIntersect(:))
            tearDefect = [tearDefect, k];
        end
    end
end

end
