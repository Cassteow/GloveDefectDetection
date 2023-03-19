function [props, stitchNo] = cloth_glove_stitch(img)
%img = imread('sample_images\IPPR DARK CLOTH\IPPR DARK CLOTH STITCH\CLOTH STITCH 2.jpg');
glove_img = img;

% Convert image to grayscale
gray_img = rgb2gray(glove_img);
% Median filtering to remove noise
filteredImg = medfilt2(gray_img);

% Threshold the image using Otsu's method
level = graythresh(filteredImg);
bwImg = imbinarize(filteredImg, level);

% Fill any holes in the binary image
filledImg = imfill(bwImg, 'holes');

% Get the biggest object (Glove)
filledMask = bwareafilt(filledImg, 1);

% Get glove smoothed mask (without any threads)
nhood = ones(9);
open = strel(nhood);
smoothMask = imopen(filledMask, open);


% Subtract from main image and detect any possible stitches
stitch = imsubtract(filledMask,smoothMask);
stitch = im2bw(stitch);

% Remove any small areas (too small to consider as stitches)
stitch = bwareaopen(stitch,50);

[StitchBBox, numRegions] = bwlabel(stitch);
props = regionprops(StitchBBox, 'BoundingBox');
stitchNo = numRegions;

