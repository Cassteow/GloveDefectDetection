function varargout = glove_defect_detection(varargin)
% GLOVE_DEFECT_DETECTION MATLAB code for glove_defect_detection.fig
%      GLOVE_DEFECT_DETECTION, by itself, creates a new GLOVE_DEFECT_DETECTION or raises the existing
%      singleton*.
%
%      H = GLOVE_DEFECT_DETECTION returns the handle to a new GLOVE_DEFECT_DETECTION or the handle to
%      the existing singleton*.
%
%      GLOVE_DEFECT_DETECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GLOVE_DEFECT_DETECTION.M with the given input arguments.
%
%      GLOVE_DEFECT_DETECTION('Property','Value',...) creates a new GLOVE_DEFECT_DETECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before glove_defect_detection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to glove_defect_detection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help glove_defect_detection

% Last Modified by GUIDE v2.5 14-Mar-2023 00:22:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @glove_defect_detection_OpeningFcn, ...
                   'gui_OutputFcn',  @glove_defect_detection_OutputFcn, ...
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


% --- Executes just before glove_defect_detection is made visible.
function glove_defect_detection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to glove_defect_detection (see VARARGIN)

% Choose default command line output for glove_defect_detection
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes glove_defect_detection wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = glove_defect_detection_OutputFcn(hObject, eventdata, handles) 
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
                    % Find thresholds of HSV 
                    hueThresholdLow = 0;
                    hueThresholdHigh = 0.14; %graythresh(hueImg);
                    saturationThresholdLow = 0.42; %graythresh(saturationImg);
                    saturationThresholdHigh = 1.0;
                    valueThresholdLow = 0.33; %graythresh(valueImg);
                    valueThresholdHigh = 1.0;
            

                    % Threshold the hue channel to identify pixels with a hue value in the range of skin colors
                    hueMask = (hueImg >= hueThresholdLow) & (hueImg <= hueThresholdHigh);
                    saturationMask = (saturationImg >= saturationThresholdLow) & (saturationImg <= saturationThresholdHigh);
                    valueMask = (valueImg >= valueThresholdLow) & (valueImg <= valueThresholdHigh);
                    skinmask = uint8(hueMask & saturationMask & valueMask);

                    OSShnobord = imclearborder(skinmask,4);
                    %figure(2), subplot(2,2,2),imshow(OSShnobord),title('no border');
         
                    OSEh = double(bwmorph(OSShnobord,'erode',3));
                    OSDh = double(bwmorph(OSEh,'dilate',5));
                    OSBWnobord = imclearborder(OSDh,4);

                    %figure(2),subplot(2,2,3), imshow(OSBWnobord),title('OSBWnobord dilate erode Image');
                    %figure(2),subplot(2,2,4), imshow(cloth_img),title('Ori Image');
    
                    [OSBBox, numRegions] = bwlabel(OSBWnobord);
                    BWfinal = regionprops(OSBBox, 'BoundingBox');
                    disp(numRegions)
                    axis(handles.axes1);
                    imagesc(glove_img);
                    hold on;
                    for k = 1 : numRegions
                        OSthisBBox = BWfinal(k).BoundingBox;
                        rectangle('Position', OSthisBBox, 'EdgeColor', 'r','LineWidth',1);
                        
                    end
                case 2 %Detect tearing
                    tear_hsv = rgb2hsv(glove_img);
                    % Extract the HSV channel values
                    tear_hue = tear_hsv(:,:,1);
                    tear_saturate = tear_hsv(:,:,2)*2.5;
                    tear_value = tear_hsv(:,:,3);
                    
                    tear_mask = ((tear_saturate>1)+(tear_saturate<0.58))>0;
                    tear_complement = imcomplement(tear_mask);
                    tear_clearborder = imclearborder(tear_complement);
                    % create structuring element
                    tear_SE_90 = strel('line',3,90); 
                    tear_SE_0 = strel('line', 3, 0);
                    tear_dilate = imdilate(tear_clearborder, [tear_SE_90 tear_SE_0]);

                    tear_double_erode = double(bwmorph(tear_dilate, 'erode', 1));
                    tear_double_dilate = double(bwmorph(tear_dilate, 'dilate', 10));
                    tear_double_clearborder = imclearborder(tear_double_dilate, 4);

                    [BoundingBox, numRegions] = bwlabel(tear_double_clearborder);
                    tear_final = regionprops(BoundingBox, 'BondingBox');

                    axis(handles.axes1);
                    imagesc(glove_img);
                    hold on;

                    for k = 1:numRegions
                        thisBondingBox
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
