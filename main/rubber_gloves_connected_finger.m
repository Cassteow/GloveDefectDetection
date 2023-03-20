function [props, abnormalWidth, message]=rubber_gloves_connected_finger(img, fingerNum)

%If finger number is equal or more than 5, there is no connected finger
if(fingerNum >= 5)
    props=[];
    abnormalWidth=[];
    message='';
    return;
end

oriImg=img;

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
bwImg = bwareaopen(bwImg,2000);
%connect lines
bwImg = imclose(bwImg, strel('disk',3));
%fill the holes in the mask
filledMask = imfill(bwImg, 'holes');
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
open = strel('disk',200);
palmImg = imopen(filledMask, open);

%Get finger mask
finger = imsubtract(filledMask,palmImg);
finger = im2bw(finger);
finger = bwareaopen(finger,20000);

%separate fingers
seOpen = strel('disk',15);
fingerMask = imopen(finger, seOpen);

% Remove skin region
%lower and upper boundary for YCbCr skin detection
skinLower = [90, 90, 140];
skinUpper = [200, 130, 170];

%skin detection using YCbCr
gwImg = grayworld(oriImg); %Use grayworld algorithm to reduce wrong color temperature effect
 
invMask = ~fingerMask;
fingerColorImg = gwImg;
fingerColorImg(repmat(invMask, [1, 1, 3])) = 0;

imgYcbcr=rgb2ycbcr(fingerColorImg);

skinMask = imgYcbcr(:,:,1) >= skinLower(1) & imgYcbcr(:,:,1) <= skinUpper(1) & ...
            imgYcbcr(:,:,2) >= skinLower(2) & imgYcbcr(:,:,2) <= skinUpper(2) & ...
            imgYcbcr(:,:,3) >= skinLower(3) & imgYcbcr(:,:,3) <= skinUpper(3);

%Remove skin region from mask
fingerMask = imsubtract(fingerMask,skinMask);
se = strel('disk',5);
fingerMask=imopen(fingerMask,se);
fingerMask = imbinarize(fingerMask);
%fill the holes in the mask
fingerMask = imfill(fingerMask, 'holes');
%remove small object
fingerMask = bwareaopen(fingerMask, 10000);

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
    if(widths(k,2)/minWidth >= 1.5)
        abnormalWidth=[abnormalWidth; widths(k,1) widths(k,2)];
    end
end

end