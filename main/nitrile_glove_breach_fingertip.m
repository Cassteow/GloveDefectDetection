function[props, breachNo]= nitrile_glove_breach_fingertip(img)
glove_img = img;

% Convert RGB image to HSV
breach_hsv =rgb2hsv(glove_img);

% Extract out the H, S, and V images individually
hueImg= breach_hsv(:,:,1);
saturationImg = breach_hsv(:,:,2);
valueImg = breach_hsv(:,:,3);

% Find thresholds of HSV for Breach Detection
hueThresholdLow = 0.02;
hueThresholdHigh = 0.14; %graythresh(hueImg);
saturationThresholdLow = 0.18; %graythresh(saturationImg);
saturationThresholdHigh = 0.55;
valueThresholdLow = 0.75; %graythresh(valueImg);
valueThresholdHigh = 1;


% Threshold the hue channel to identify pixels with a hue value in the range of glove hole colors
hueMask = (hueImg >= hueThresholdLow) & (hueImg <= hueThresholdHigh);
saturationMask = (saturationImg >= saturationThresholdLow) & (saturationImg <= saturationThresholdHigh);
valueMask = (valueImg >= valueThresholdLow) & (valueImg <= valueThresholdHigh);

% Combine HSV masks as open mask
breachmask = uint8(hueMask & saturationMask & valueMask);
% Keep areas only if they're bigger than this.
smallestAcceptableArea = 200; 
breachmask = uint8(bwareaopen(breachmask,smallestAcceptableArea));


breachmask_clearborder = imclearborder(breachmask,4);
%figure(2), subplot(2,2,2),imshow(OSShnobord),title('no border');

breachmask_erode = double(bwmorph(breachmask_clearborder,'erode',3));
breachmask_dilate = double(bwmorph(breachmask_erode,'dilate',5));
breachmask_clearborder = imclearborder(breachmask_dilate,4);

%figure(2),subplot(2,2,3), imshow(OSBWnobord),title('OSBWnobord dilate erode Image');
%figure(2),subplot(2,2,4), imshow(cloth_img),title('Ori Image');

[OpenBBox, numRegions] = bwlabel(breachmask_clearborder);
openfinal = regionprops(OpenBBox, 'BoundingBox');
props = openfinal;
breachNo = numRegions;

