function [props, abnormalWidth, message]=rubber_gloves_connected_finger(img)
oriImg=img;
oriImg=imresize(oriImg, [1920 NaN]);
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
propsFilledMask=regionprops(filledMask,'Orientation','Area');


% Remove skin region
%lower and upper boundary for YCbCr skin detection
skinLower = [100, 95, 138];
skinUpper = [250, 125, 201];

%skin detection
imgYcbcr=rgb2ycbcr(oriImg);

skinMask = imgYcbcr(:,:,1) >= skinLower(1) & imgYcbcr(:,:,1) <= skinUpper(1) & ...
            imgYcbcr(:,:,2) >= skinLower(2) & imgYcbcr(:,:,2) <= skinUpper(2) & ...
            imgYcbcr(:,:,3) >= skinLower(3) & imgYcbcr(:,:,3) <= skinUpper(3);

%Remove skin region from mask
filledMask = imsubtract(filledMask,skinMask);
se = strel('disk',5);
filledMask=imopen(filledMask,se);
filledMask = imbinarize(filledMask);
%fill the holes in the mask
filledMask = imfill(filledMask, 'holes');
%Get the biggest object
filledMask=bwareafilt(filledMask, 1);
propsFilledMask=regionprops(filledMask,'Orientation','Area');

message = '';

if(isempty(propsFilledMask.Area))
    message = sprintf('No gloves detected');
    return;
end

%Get gloves orientation
imgOrientation = propsFilledMask.Orientation;
if(imgOrientation < 0)
    imgOrientation = imgOrientation * -1;
end

%Get palm mask
open = strel('disk',190);
palmImg = imopen(filledMask, open);

%Get finger mask
finger = imsubtract(filledMask,palmImg);
finger = im2bw(finger);
finger = bwareaopen(finger,20000);

%separate fingers
seOpen = strel('disk',35);
fingerMask = imopen(finger, seOpen);

%Get bounding box, area, orientation, max and min feret properties of the finger regions
props=regionprops(fingerMask,'BoundingBox', 'Area', 'Orientation', 'MaxFeretProperties','MinFeretProperties');
regionAreas=[props.Area];
fingerNum = length(regionAreas);

widths=[];

if(fingerNum > 0)
    %Find finger regions orientation and width
    for k=1:(fingerNum)
        %get finger region orientation
        orientation=props(k).Orientation;
        if(orientation < 0)
            orientation = orientation * -1;
        end

        %Compare finger region orientation to gloves orientation
        orienDiff = imgOrientation - orientation;
        if(orienDiff < 0)
            orienDiff = orienDiff * -1;
        end

        %If difference between angles of finger orientation and gloves orientation >=70, 
        %considered finger regions too short. Thus, use max feret diameter.
        if(orienDiff < 70)
            width = props(k).MinFeretDiameter;
            widths=[widths; k width];
        else
            width = props(k).MaxFeretDiameter;
            widths=[widths; k width];
        end
    end
else
    message = sprintf('No finger detected');
    return;
end

%Get the min finger regions widths
minWidth = min(widths(:,2));
abnormalWidth=[];

%Get the abnormal width fingers region
for k=1:size(widths,1)
    if(widths(k,2)/minWidth >= 1.45)
        abnormalWidth=[abnormalWidth; widths(k,1) widths(k,2)];
    end
end
end