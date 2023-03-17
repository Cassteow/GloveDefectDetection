function[props, openingNo]=cloth_glove_opening(img)
glove_img = img;

% Convert RGB image to HSV
cloth_hsv =rgb2hsv(glove_img);

% Extract out the H, S, and V images individually
hueImg= cloth_hsv(:,:,1);
saturationImg = cloth_hsv(:,:,2);
valueImg = cloth_hsv(:,:,3);

% Find thresholds of HSV for Opening Detection
hueThresholdLow = 0;
hueThresholdHigh = 0.14; %graythresh(hueImg);
saturationThresholdLow = 0.75; %graythresh(saturationImg);
saturationThresholdHigh = 1.0;
valueThresholdLow = 0.45; %graythresh(valueImg);
valueThresholdHigh = 0.75;


% Threshold the hue channel to identify pixels with a hue value in the range of glove opening colors
hueMask = (hueImg >= hueThresholdLow) & (hueImg <= hueThresholdHigh);
saturationMask = (saturationImg >= saturationThresholdLow) & (saturationImg <= saturationThresholdHigh);
valueMask = (valueImg >= valueThresholdLow) & (valueImg <= valueThresholdHigh);

% Combine HSV masks as open mask
openmask = uint8(hueMask & saturationMask & valueMask);
% Keep areas only if they're bigger than this.
smallestAcceptableArea = 50; 
openmask = uint8(bwareaopen(openmask,smallestAcceptableArea));


openmask_clearborder = imclearborder(openmask,4);
%figure(2), subplot(2,2,2),imshow(OSShnobord),title('no border');

openmask_erode = double(bwmorph(openmask_clearborder,'erode',3));
openmask_dilate = double(bwmorph(openmask_erode,'dilate',5));
openmask_clearborder = imclearborder(openmask_dilate,4);

%figure(2),subplot(2,2,3), imshow(OSBWnobord),title('OSBWnobord dilate erode Image');
%figure(2),subplot(2,2,4), imshow(cloth_img),title('Ori Image');

[OpenBBox, numRegions] = bwlabel(openmask_clearborder);
openfinal = regionprops(OpenBBox, 'BoundingBox');
props = openfinal;
openingNo = numRegions;

