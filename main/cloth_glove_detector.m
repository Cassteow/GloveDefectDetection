function clothcover = cloth_glove_detector(cloth_img)
%cloth_img = imread("sample_images\IPPR DARK CLOTH\IPPR DARK CLOTH OPENING\IPPR CLOTH OPENING (4).jpg");
E = entropyfilt(cloth_img); % create local entropy image of cloth glove

E_rescale = rescale(E); % rescale array values of range from 0 to 1

binary = im2bw(E_rescale,0.52); % create binarized image
%figure, subplot(3,2,1),imshow(binary),title('Thresholded Binarized Texture Image');

BWao = bwareaopen(binary,2500); % area open removes all components lesser than X pixels
%subplot(3,2,2),imshow(BWao),title('Area-Opened Texture Image');
nhood = ones(9); % create structuring element
closeBWao = imclose(BWao,nhood); % perform morphological closing (dilation, then erosion)
%subplot(3,2,3),imshow(closeBWao),title('Closed Texture Image');

mask = imfill(closeBWao,'holes'); % fill in empty spaces 
%subplot(3,2,4),imshow(mask),title('Mask Image'); 

numcloth = nnz(~mask); % nnz returns no. of non-zero elements
    clothcover = numcloth / numel(mask) * 100; % find out percentage of cloth glove coverage
    disp(['Percentage of cloth in glove image: ' num2str(clothcover) '%'])
   %{ 
    %         Condition
   
     if (clothcover>= 50)
         disp('This is a cloth glove')
         
     end

         % color image segmentation
         % Convert RGB image to HSV
         cloth_hsv = rgb2hsv(cloth_img);
         % Extract out the H, S, and V images individually
         hueImg= cloth_hsv(:,:,1);
         saturationImg = cloth_hsv(:,:,2); 
         valueImg = cloth_hsv(:,:,3);
         % Find thresholds of HSV 
         hueThresholdLow = 0;
         hueThresholdHigh = graythresh(hueImg);
         saturationThresholdLow = graythresh(saturationImg);
         saturationThresholdHigh = 1.0;
         valueThresholdLow = graythresh(valueImg);
         valueThresholdHigh = 1.0;
         %[OpenHue,OpenSaturation,OpenIntensity] = rgb2hsv(hueImg,saturationImg,value); % HSI Model
            

         % Threshold the hue channel to identify pixels with a hue value in the range of skin colors
         hueMask = (hueImg >= hueThresholdLow) & (hueImg <= hueThresholdHigh);
         saturationMask = (saturationImg >= saturationThresholdLow) & (saturationImg <= saturationThresholdHigh);
         valueMask = (valueImg >= valueThresholdLow) & (valueImg <= valueThresholdHigh);
         skinmask = uint8(hueMask & saturationMask & valueMask);

         OSShnobord = imclearborder(skinmask,4);
         figure(2), subplot(2,3,2),imshow(OSShnobord),title('no border');
         
         OSEh = double(bwmorph(OSShnobord,'erode',3));
         OSDh = double(bwmorph(OSEh,'dilate',5));
         OSBWnobord = imclearborder(OSDh,4);

         subplot(2,3,3), imshow(OSBWnobord),title('OSBWnobord dilate erode Image');
         subplot(2,3,4), imshow(cloth_img),title('Ori Image');

         [OSBBox, numRegions] = bwlabel(OSBWnobord);
         BWfinal = regionprops(OSBBox, 'BoundingBox');
         subplot(2,3,5), imshow(cloth_img),title('bounding Image');

         for k = 1 : numRegions
             OSthisBBox = BWfinal(k).BoundingBox;
             rectangle('Position', OSthisBBox, 'EdgeColor', 'r','LineWidth',1);
             break
         end
    
     else
         disp('This is not a cloth glove')
     end
    %}
    