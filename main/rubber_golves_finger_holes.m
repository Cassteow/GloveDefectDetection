function [props, finger_defect, message]=rubber_golves_finger_holes(img)
oriImg = img;

%Convert to grayscale
img = rgb2gray(oriImg);

%Perform gaussian blurring to reduce noise
img = imgaussfilt(img,2);

%Create local entrophy of gloves
E = entropyfilt(img);
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

%Get palm mask
open = strel('disk',150);
palmImg = imopen(filledMask, open);

%Get finger mask
finger = imsubtract(filledMask,palmImg);
finger = im2bw(finger);
finger = bwareaopen(finger,20000);

%separate fingers
seOpen = strel('disk',15);
fingerMask = imopen(finger, seOpen);

%Get bounding box and area of the regions
props=regionprops(fingerMask,'BoundingBox', 'Area');
regionAreas=[props.Area];
fingerNum = length(regionAreas);

message = '';

finger_defect = [];

%check if the finger number not enough
if(fingerNum < 5)
    message = sprintf('Not enough fingers. There are only %2d fingers',fingerNum);
else
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
    
        %Calculate white pixel number in mask
        totalArea = sum(fingerRegionMask(:));
    
        %Remove small object
        fingerRegionMask = bwareaopen(fingerRegionMask,10000);

        %Get ROI in color image
        fingerRegionMask = cast(fingerRegionMask,'uint8');
        fingerRegionMask = repmat(fingerRegionMask, [1,1,3]);
        fingerRegionOri(~fingerRegionMask)=0;
    
        %skin detection
        imgYcbcr=rgb2ycbcr(fingerRegionOri);

        skinMask = imgYcbcr(:,:,1) >= skinLower(1) & imgYcbcr(:,:,1) <= skinUpper(1) & ...
                    imgYcbcr(:,:,2) >= skinLower(2) & imgYcbcr(:,:,2) <= skinUpper(2) & ...
                    imgYcbcr(:,:,3) >= skinLower(3) & imgYcbcr(:,:,3) <= skinUpper(3);

        %calculate white pixel numbers in skin mask
        skinArea = sum(skinMask(:));
        %calculate skin percentage at finger region
        skinPercentage = (skinArea/totalArea) * 100;

        if(skinPercentage > 10)
            finger_defect=cat(2,finger_defect,k);
        end

    end
end

end