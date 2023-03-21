function[props, stainNo]=cloth_glove_stain(img)
glove_img = img;

% Convert image from rgb to hsv
stain_hsv = rgb2hsv(glove_img);
% Extract the HSV channel values
hueImg = stain_hsv(:,:,1);
saturationImg = stain_hsv(:,:,2);
valueImg = stain_hsv(:,:,3);

% Find thresholds of HSV for Stain Detection
hueThresholdLow = 0.57;
hueThresholdHigh = 0.72;
saturationThresholdLow = 0.25;
saturationThresholdHigh = 0.5;
valueThresholdLow = 0.35;
valueThresholdHigh = 0.65;

% Threshold the hue channel to identify pixels with a hue value in the range of glove opening colors
hueMask = (hueImg >= hueThresholdLow) & (hueImg <= hueThresholdHigh);
saturationMask = (saturationImg >= saturationThresholdLow) & (saturationImg <= saturationThresholdHigh);
valueMask = (valueImg >= valueThresholdLow) & (valueImg <= valueThresholdHigh);

stainmask = uint8(hueMask & saturationMask & valueMask);
smallestAcceptableArea = 20; % Keep areas only if they're bigger than this.
stainmask = uint8(bwareaopen(stainmask,smallestAcceptableArea));

stainmask_clearborder = imclearborder(stainmask);
% create structuring element
stain_SE_90 = strel('line',3,90);
stain_SE_0 = strel('line', 3, 0);
stainmask_dilate = imdilate(stainmask_clearborder, [stain_SE_90 stain_SE_0]);

stainmask_double_erode = double(bwmorph(stainmask_dilate, 'erode', 1));
stainmask_double_dilate = double(bwmorph(stainmask_double_erode, 'dilate', 10));
stainmask_double_clearborder = imclearborder(stainmask_double_dilate, 4);

[stainBBox, numRegions] = bwlabel(stainmask_double_clearborder);
stain_final = regionprops(stainBBox, 'BoundingBox');
stainNo = numRegions;
props = stain_final;