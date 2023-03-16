function varargout = rubber_glove_defect_detection(varargin)
% RUBBER_GLOVE_DEFECT_DETECTION MATLAB code for rubber_glove_defect_detection.fig
%      RUBBER_GLOVE_DEFECT_DETECTION, by itself, creates a new RUBBER_GLOVE_DEFECT_DETECTION or raises the existing
%      singleton*.
%
%      H = RUBBER_GLOVE_DEFECT_DETECTION returns the handle to a new RUBBER_GLOVE_DEFECT_DETECTION or the handle to
%      the existing singleton*.
%
%      RUBBER_GLOVE_DEFECT_DETECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RUBBER_GLOVE_DEFECT_DETECTION.M with the given input arguments.
%
%      RUBBER_GLOVE_DEFECT_DETECTION('Property','Value',...) creates a new RUBBER_GLOVE_DEFECT_DETECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before rubber_glove_defect_detection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to rubber_glove_defect_detection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help rubber_glove_defect_detection

% Last Modified by GUIDE v2.5 16-Mar-2023 00:59:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rubber_glove_defect_detection_OpeningFcn, ...
                   'gui_OutputFcn',  @rubber_glove_defect_detection_OutputFcn, ...
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


% --- Executes just before rubber_glove_defect_detection is made visible.
function rubber_glove_defect_detection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to rubber_glove_defect_detection (see VARARGIN)

% Choose default command line output for rubber_glove_defect_detection
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes rubber_glove_defect_detection wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = rubber_glove_defect_detection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in LoadImgBtn.
function LoadImgBtn_Callback(hObject, eventdata, handles)
% hObject    handle to LoadImgBtn (see GCBO)
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


% --- Executes on button press in detectBtn.
function detectBtn_Callback(hObject, eventdata, handles)
% hObject    handle to detectBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
input = get(handles.axes1, 'Children');
glove_img = get(input, 'CData');


% Get the value of the pop-out menu
 if isempty(input)
        % Display an error message if the axes is empty
        errordlg('Error: You did not load image!','Error Message','modal');
 else
    switch get(handles.defectSelect, 'value')
        case 1 %Detect finger number
%             [props,finger_defect]=rubber_glove_defect_detection(glove_img);
%             figure;imshow(glove_img);
%             for k = 1 : length(finger_defect)
%                  BB = props(finger_defect(k)).BoundingBox;
%                  rectangle('Position', BB, 'EdgeColor', 'r','LineWidth',1);
%                  break
%             end
                oriImg = glove_img;
                I=rgb2gray(oriImg);
                
                %Perform gaussian blurring to reduce noise
                I=imgaussfilt(I,2);
                E = entropyfilt(I);
                Eim = rescale(E);
                % imshow(Eim);
                BW1 = imbinarize(Eim,0.5);
                % figure;imshow(BW1);
                BWao = bwareaopen(BW1,2000);
                % figure;imshow(BWao);
                
                filledImg = imfill(BWao, 'holes');
                bw=bwareafilt(filledImg, 1);
                % figure;imshow(filledImg);
                
                open = strel('disk',150);
                palm_img = imopen(filledImg, open);
                % figure;imshow(palm_img);
                
                finger = imsubtract(filledImg,palm_img);
                finger = im2bw(finger);
                finger = bwareaopen(finger,20000);
                % figure;imshow(finger);
                seOpen = strel('disk',15);
                fingerMask = imopen(finger, seOpen);
                % figure;imshow(fingerMask);
                
                props=regionprops(fingerMask,'BoundingBox', 'Area');
                Iarea=[props.Area];
                % fprintf('Number Of Fingers: %2d\n',length(Iarea));
                fingerNum = length(Iarea);
                
                if(fingerNum < 5)
                    % fprintf('Not enough fingers. There are only %2d fingers',length(Iarea));
                else
                    targetSize = [NaN 156];
                    
                    skinLower = [0, 77, 133];
                    skinUpper = [142, 127, 173];
                
                    finger_defect = [];
                
                    for k=1:length(Iarea)
                        thisBB = props(k).BoundingBox;
                    
                        defect_region = imcrop(oriImg,thisBB);
                        defect_region = imresize(defect_region, targetSize);
                    
                        defect_mask = imcrop(fingerMask,thisBB);
                        defect_mask = imresize(defect_mask, targetSize);
                    
                        totalArea = sum(defect_mask(:));
                    
                        defect_mask = bwareaopen(defect_mask,10000);
                        defect_mask = cast(defect_mask,'uint8');
                        defect_mask = repmat(defect_mask, [1,1,3]);
                        defect_region(~defect_mask)=0;
                    
                        %skin detection
                        imgYcbcr=rgb2ycbcr(defect_region);
                
                        skinMask = imgYcbcr(:,:,1) >= skinLower(1) & imgYcbcr(:,:,1) <= skinUpper(1) & ...
                                    imgYcbcr(:,:,2) >= skinLower(2) & imgYcbcr(:,:,2) <= skinUpper(2) & ...
                                    imgYcbcr(:,:,3) >= skinLower(3) & imgYcbcr(:,:,3) <= skinUpper(3);
                
                        
                
                        skinArea = sum(skinMask(:));
                        skinPercentage = (skinArea/totalArea) * 100;
                
                        if(skinPercentage > 10)
                            finger_defect=cat(2,finger_defect,k);
                        end
                
                    end
                end
                
                axis(handles.axes1);
                imagesc(glove_img);
                hold on;
                if(~isempty(finger_defect))
                    for k = 1 : length(finger_defect)
                         BB = props(finger_defect(k)).BoundingBox;
                         rectangle('Position', BB, 'EdgeColor', 'r','LineWidth',1);
                    end
                end
    end
 end


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


% --- Executes on button press in exitBtn.
function exitBtn_Callback(hObject, eventdata, handles)
% hObject    handle to exitBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(rubber_glove_defect_detection);