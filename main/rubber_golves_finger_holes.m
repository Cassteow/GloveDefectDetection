function [props, finger_defect, message, fingerNum]=rubber_golves_finger_holes(img)
oriImg = img;
oriImg=imresize(oriImg, [1920 NaN]);
%Convert to grayscale
grayImg = rgb2gray(oriImg);

%Perform gaussian blurring to reduce noise
grayImg = imgaussfilt(grayImg,1);

%Create local entrophy of gloves
E = entropyfilt(grayImg);
% rescale array values of range from 0 to 1
Eim = rescale(E);

%binarize image
bwImg = imbinarize(Eim,0.5);
%Remove small object
bwImg = bwareaopen(bwImg,2000);

%fill the holes in the mask
filledMask = imfill(bwImg, 'holes');
%Get the biggest object
filledMask=bwareafilt(filledMask, 1);
%Get gloves centroid
propsFilledMask=regionprops(filledMask,'Centroid');
gloveCentroid = propsFilledMask.Centroid;

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

message = '';

finger_defect = [];

%fix size for cropped image
targetSize = [NaN 156];

%lower and upper boundary for YCbCr skin detection
skinLower = [0, 77, 133];
skinUpper = [190, 127, 173];

%Check if finger has hole
for k=1:fingerNum
    boundingBox = props(k).BoundingBox;

    %crop finger in original image and resize
    fingerRegionOri = imcrop(oriImg,boundingBox);
    fingerRegionOri = imresize(fingerRegionOri, targetSize);

    %crop finger in mask and resize
    fingerRegionMask = imcrop(fingerMask,boundingBox);
    fingerRegionMask = imresize(fingerRegionMask, targetSize);

    %crop finger tip mask and resize
    fingerTipRegion = imcrop(fingerTipMask,boundingBox);
    fingerTipRegion = imresize(fingerTipRegion, targetSize);

    %Calculate white pixel number in mask
    totalArea = sum(fingerRegionMask(:));

    %Remove small object
    fingerRegionMask = bwareaopen(fingerRegionMask,10000);

    %Get ROI in color image
    fingerRegionMask = cast(fingerRegionMask,'uint8');
    fingerRegionMask = repmat(fingerRegionMask, [1,1,3]);
    fingerRegionOri(~fingerRegionMask)=0;

    %skin detection using YCbCr 
    gwFingerRegion = grayworld(fingerRegionOri); %Use grayworld algorithm to reduce wrong color temperature effect
    imgYcbcr=rgb2ycbcr(gwFingerRegion);

    skinMask = imgYcbcr(:,:,1) >= skinLower(1) & imgYcbcr(:,:,1) <= skinUpper(1) & ...
                imgYcbcr(:,:,2) >= skinLower(2) & imgYcbcr(:,:,2) <= skinUpper(2) & ...
                imgYcbcr(:,:,3) >= skinLower(3) & imgYcbcr(:,:,3) <= skinUpper(3);

    %Check if the skin is in finger tip region
    fingerTipIntersect = fingerTipRegion & skinMask;
    if any(fingerTipIntersect(:))
        %calculate white pixel numbers in skin mask
        skinArea = sum(skinMask(:));
        %calculate skin percentage at finger region
        skinPercentage = (skinArea/totalArea) * 100;

        if(skinPercentage > 15)
            finger_defect=[finger_defect, k];
        end
    end
    

end
end