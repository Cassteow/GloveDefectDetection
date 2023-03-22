function[props, dirtNo]=nitrile_glove_dirt_fingertip(img)
glove_img = img;

% Convert image from rgb to hsv
dirt_hsv = rgb2hsv(glove_img);
% Extract the HSV channel values
hueImg = dirt_hsv(:,:,1);
saturationImg = dirt_hsv(:,:,2);
valueImg = dirt_hsv(:,:,3);

% Find thresholds of HSV for Dirt Detection
hueThresholdLow = 0.49;
hueThresholdHigh = 0.75;
saturationThresholdLow = 0.72;
saturationThresholdHigh = 0.95;
valueThresholdLow = 0.51;
valueThresholdHigh = 0.95;

% Threshold the hue channel to identify pixels with a hue value in the range of glove dirt colors
hueMask = (hueImg >= hueThresholdLow) & (hueImg <= hueThresholdHigh);
saturationMask = (saturationImg >= saturationThresholdLow) & (saturationImg <= saturationThresholdHigh);
valueMask = (valueImg >= valueThresholdLow) & (valueImg <= valueThresholdHigh);

dirtmask = uint8(hueMask & saturationMask & valueMask);
smallestAcceptableArea = 5; % Keep areas only if they're bigger than this.
dirtmask = uint8(bwareaopen(dirtmask,smallestAcceptableArea));

dirtmask_clearborder = imclearborder(dirtmask);
% create structuring element
dirt_SE_90 = strel('line',3,90);
dirt_SE_0 = strel('line', 3, 0);
dirtmask_dilate = imdilate(dirtmask_clearborder, [dirt_SE_90 dirt_SE_0]);

dirtmask_double_erode = double(bwmorph(dirtmask_dilate, 'erode', 1));
dirtmask_double_dilate = double(bwmorph(dirtmask_double_erode, 'dilate', 10));
dirtmask_double_clearborder = imclearborder(dirtmask_double_dilate, 4);

[stainBBox, numRegions] = bwlabel(dirtmask_double_clearborder);
stain_final = regionprops(stainBBox, 'BoundingBox');
dirtNo = numRegions;
props = stain_final;