function[props, holeNo]= nitrile_glove_hole(img)
glove_img = img;

% Convert RGB image to HSV
hole_hsv =rgb2hsv(glove_img);

% Extract out the H, S, and V images individually
hueImg= hole_hsv(:,:,1);
saturationImg = hole_hsv(:,:,2);
valueImg = hole_hsv(:,:,3);

% Find thresholds of HSV for Hole Detection
hueThresholdLow = 0.03;
hueThresholdHigh = 0.25; %graythresh(hueImg);
saturationThresholdLow = 0.12; %graythresh(saturationImg);
saturationThresholdHigh = 0.35;
valueThresholdLow = 0.77; %graythresh(valueImg);
valueThresholdHigh = 0.9;


% Threshold the hue channel to identify pixels with a hue value in the range of glove hole colors
hueMask = (hueImg >= hueThresholdLow) & (hueImg <= hueThresholdHigh);
saturationMask = (saturationImg >= saturationThresholdLow) & (saturationImg <= saturationThresholdHigh);
valueMask = (valueImg >= valueThresholdLow) & (valueImg <= valueThresholdHigh);

% Combine HSV masks as hole mask
holemask = uint8(hueMask & saturationMask & valueMask);
% Keep areas only if they're bigger than this.
smallestAcceptableArea = 10; 
holemask = uint8(bwareaopen(holemask,smallestAcceptableArea));


holemask_clearborder = imclearborder(holemask,4);
%figure(2), subplot(2,2,2),imshow(OSShnobord),title('no border');

holemask_erode = double(bwmorph(holemask_clearborder,'erode',3));
holemask_dilate = double(bwmorph(holemask_erode,'dilate',5));
holemask_clearborder = imclearborder(holemask_dilate,4);

%figure(2),subplot(2,2,3), imshow(OSBWnobord),title('OSBWnobord dilate erode Image');
%figure(2),subplot(2,2,4), imshow(cloth_img),title('Ori Image');

[OpenBBox, numRegions] = bwlabel(holemask_clearborder);
openfinal = regionprops(OpenBBox, 'BoundingBox');
props = openfinal;
holeNo = numRegions;

