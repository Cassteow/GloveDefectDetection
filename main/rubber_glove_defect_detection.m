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

% Last Modified by GUIDE v2.5 21-Mar-2023 19:04:20

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

        handles.fingerHolesTxt.String = 'Processing...';
        handles.connFingerTxt.String = 'Processing...';
        handles.gloveTearTxt.String = 'Processing...';
         
        %Detect finger holes
        [fingerHolesProps, finger_defect, msgFingerHoles, fingerNum] = rubber_golves_finger_holes(glove_img);
   
        %Detect connected finger
        [conFingerProps, abnormalWidth, msgConFinger] = rubber_gloves_connected_finger(glove_img, fingerNum);
    
        %Detect glove tearing
        [tearProps, tearDefect] = rubber_gloves_tear(glove_img);

        glove_img=imresize(glove_img, [1920 NaN]);
    
        axis(handles.axes1);
        imagesc(glove_img);
        hold on;

        %Finger holes detection result
        if(~isempty(finger_defect))
            msgFingerHoles = sprintf('Finger holes detected. \nThe finger holes number: %2d',length(finger_defect));
        else
            msgFingerHoles = 'No finger holes';
        end

        handles.fingerHolesTxt.String = msgFingerHoles;
        
        %Label finger holes defect
        if(~isempty(finger_defect))
            for k = 1 : length(finger_defect)
                 BB = fingerHolesProps(finger_defect(k)).BoundingBox;
                 rectangle('Position', BB, 'EdgeColor', 'r','LineWidth',1);
            end
        end

        %Connected finger detection result
        if(~isempty(abnormalWidth))
            msgConFinger = sprintf('Connected finger detected. \nThe connected finger number: %2d',size(abnormalWidth,1));
        else
            msgConFinger = 'No Connected Finger';
        end

        handles.connFingerTxt.String = msgConFinger;
        
        %Label connected finger defect
        if(~isempty(abnormalWidth))
            for i=1:size(abnormalWidth,1)
                box = conFingerProps(abnormalWidth(i,1)).BoundingBox;
                rectangle('Position', box, 'EdgeColor', 'g','LineWidth',1);
            end
        end
     

        %Glove tearing detection result
        if(~isempty(tearDefect))
            msgConFinger = sprintf('Glove tearing detected. \nThe glove tearing number: %2d',length(tearDefect));
        else
            msgConFinger = 'No Glove tearing';
        end

        handles.gloveTearTxt.String = msgConFinger;

        %Label glove tearing defect
        if(~isempty(tearDefect))
            for i=1:length(tearDefect)
                box = tearProps(tearDefect(i)).BoundingBox;
                rectangle('Position', box, 'EdgeColor', 'b','LineWidth',1);
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


% --- Executes on button press in returnBtn.
function returnBtn_Callback(hObject, eventdata, handles)
% hObject    handle to returnBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Close current interface
close(rubber_glove_defect_detection);
% go back to main menu
IPPR_Main_GDD();
