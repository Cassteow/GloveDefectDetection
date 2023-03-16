function varargout = cloth_glove_defect_detection(varargin)
% CLOTH_GLOVE_DEFECT_DETECTION MATLAB code for cloth_glove_defect_detection.fig
%      CLOTH_GLOVE_DEFECT_DETECTION, by itself, creates a new CLOTH_GLOVE_DEFECT_DETECTION or raises the existing
%      singleton*.
%
%      H = CLOTH_GLOVE_DEFECT_DETECTION returns the handle to a new CLOTH_GLOVE_DEFECT_DETECTION or the handle to
%      the existing singleton*.
%
%      CLOTH_GLOVE_DEFECT_DETECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CLOTH_GLOVE_DEFECT_DETECTION.M with the given input arguments.
%
%      CLOTH_GLOVE_DEFECT_DETECTION('Property','Value',...) creates a new CLOTH_GLOVE_DEFECT_DETECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cloth_glove_defect_detection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cloth_glove_defect_detection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cloth_glove_defect_detection

% Last Modified by GUIDE v2.5 16-Mar-2023 09:25:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cloth_glove_defect_detection_OpeningFcn, ...
                   'gui_OutputFcn',  @cloth_glove_defect_detection_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before cloth_glove_defect_detection is made visible.
function cloth_glove_defect_detection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cloth_glove_defect_detection (see VARARGIN)

% Choose default command line output for cloth_glove_defect_detection
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes cloth_glove_defect_detection wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = cloth_glove_defect_detection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnLoadImage.
function btnLoadImage_Callback(hObject, eventdata, handles)
% hObject    handle to btnLoadImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla reset;
% Function to Get Image
[filename, pathname] = uigetfile({'*.jpg;*.tif;*.bmp;*.jpeg;*.png;*.gif','All Image Files';'*.*','All Files'}, 'Select an Image');
fileName = fullfile(pathname, filename);

% Read Image
Img = imread(fileName);

% Display Image
axis(handles.axes1);
imagesc(Img);



% --- Executes on button press in btnDetect.
function btnDetect_Callback(hObject, eventdata, handles)
% hObject    handle to btnDetect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
input = get(handles.axes1, 'Children');
glove_img = get(input, 'CData');


% Get the value of the pop-out menu
     if isempty(input)
            % Display an error message if the axes is empty
            errordlg('Error: You did not load image!','Error Message','modal');
     else
        clothcover = cloth_glove_detector(glove_img);
        if (clothcover >= 30)
            switch get(handles.defectSelect, 'value')
                case 1 %Detect opening

                    % color image segmentation
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
                    valueThresholdHigh = 0.6;
            

                    % Threshold the hue channel to identify pixels with a hue value in the range of glove opening colors
                    hueMask = (hueImg >= hueThresholdLow) & (hueImg <= hueThresholdHigh);
                    saturationMask = (saturationImg >= saturationThresholdLow) & (saturationImg <= saturationThresholdHigh);
                    valueMask = (valueImg >= valueThresholdLow) & (valueImg <= valueThresholdHigh);

                    openmask = uint8(hueMask & saturationMask & valueMask);
                    smallestAcceptableArea = 50; % Keep areas only if they're bigger than this.
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
                    disp(numRegions)
                    axis(handles.axes1);
                    imagesc(glove_img);
                    hold on;
                    if numRegions>0
                        for k = 1 : numRegions
                            OPthisBBox = openfinal(k).BoundingBox;
                            rectangle('Position', OPthisBBox, 'EdgeColor', 'r','LineWidth',1);
                        end
                    end
                case 2 %Detect stain
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
                    smallestAcceptableArea = 50; % Keep areas only if they're bigger than this.
                    stainmask = uint8(bwareaopen(stainmask,smallestAcceptableArea));

                    %tear_complement = imcomplement(tear_mask);
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
                    disp(numRegions);
                    axis(handles.axes1);
                    imagesc(glove_img);
                    hold on;

                    for k = 1:numRegions
                        stainthisBBox = stain_final(k).BoundingBox;
                        rectangle('Position', stainthisBBox, 'EdgeColor', 'r','LineWidth',1);
                    end

            end

        end

     end

                   
                    


% --- Executes on button press in btnReset.
function btnReset_Callback(hObject, eventdata, handles)
% hObject    handle to btnReset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in ExitButton.
function ExitButton_Callback(hObject, eventdata, handles)
% hObject    handle to ExitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(glove_defect_detection);


% --- Executes on selection change in defectSelect.
function defectSelect_Callback(hObject, eventdata, handles)
% hObject    handle to defectSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns defectSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from defectSelect


% --- Executes during object creation, after setting all properties.
function defectSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to defectSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
