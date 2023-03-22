function varargout = nitrile_glove_defect_detection(varargin)
% NITRILE_GLOVE_DEFECT_DETECTION MATLAB code for nitrile_glove_defect_detection.fig
%      NITRILE_GLOVE_DEFECT_DETECTION, by itself, creates a new NITRILE_GLOVE_DEFECT_DETECTION or raises the existing
%      singleton*.
%
%      H = NITRILE_GLOVE_DEFECT_DETECTION returns the handle to a new NITRILE_GLOVE_DEFECT_DETECTION or the handle to
%      the existing singleton*.
%
%      NITRILE_GLOVE_DEFECT_DETECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NITRILE_GLOVE_DEFECT_DETECTION.M with the given input arguments.
%
%      NITRILE_GLOVE_DEFECT_DETECTION('Property','Value',...) creates a new NITRILE_GLOVE_DEFECT_DETECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nitrile_glove_defect_detection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nitrile_glove_defect_detection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help nitrile_glove_defect_detection

% Last Modified by GUIDE v2.5 21-Mar-2023 22:56:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nitrile_glove_defect_detection_OpeningFcn, ...
                   'gui_OutputFcn',  @nitrile_glove_defect_detection_OutputFcn, ...
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


% --- Executes just before nitrile_glove_defect_detection is made visible.
function nitrile_glove_defect_detection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nitrile_glove_defect_detection (see VARARGIN)

% Choose default command line output for nitrile_glove_defect_detection
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes nitrile_glove_defect_detection wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = nitrile_glove_defect_detection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in LoadImageButton.
function LoadImageButton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadImageButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla reset;
% Function to Get Image
[filename, pathname] = uigetfile({'*.jpg;*.tif;*.bmp;*.jpeg;*.png;*.gif','All Image Files';'*.*','All Files'}, 'Select an Image');
fileName = fullfile(pathname, filename);

% Read Image
Img = imread(fileName);

% Display Image
axis(handles.axesToDisplayImage);
imagesc(Img);



% --- Executes on button press in DetectDefectButton.
function DetectDefectButton_Callback(hObject, eventdata, handles)
% hObject    handle to DetectDefectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
input = get(handles.axesToDisplayImage, 'Children');
glove_img = get(input, 'CData');


% Get the value of the pop-out menu
if isempty(input)
    % Display an error message if the axes is empty
    errordlg('Error: You did not load image!','Error Message','modal');
else

    % Breach Detection
    [breachProps, breachNo] = nitrile_glove_breach_fingertip(glove_img);

    % Dirt Detection
    [dirtProps, dirtNo] = nitrile_glove_dirt_fingertip(glove_img);

    % Hole Detection
    [holeProps, holeNo] = nitrile_glove_hole(glove_img);

    axis(handles.axesToDisplayImage);
    imagesc(glove_img);
    hold on;
    % Label Breach Defects
    if breachNo>0
        for k = 1 : breachNo
            OPthisBBox = breachProps(k).BoundingBox;
            rectangle('Position', OPthisBBox, 'EdgeColor', 'r','LineWidth',1);
        end
        set(handles.BreachAnswer,'String',breachNo);
    else
        set(handles.BreachAnswer,'String',"0");
    end

    % Label Stain Defects
    if dirtNo >0
        for k = 1:dirtNo
            stainthisBBox = dirtProps(k).BoundingBox;
            rectangle('Position', stainthisBBox, 'EdgeColor', 'g','LineWidth',1);
        end
        set(handles.DirtAnswer,'String',dirtNo);
    else
        set(handles.DirtAnswer,'String',"0");
    end

    % Label Hole Defects
    if holeNo >0
        for k = 1:holeNo
            holethisBBox = holeProps(k).BoundingBox;
            rectangle('Position', holethisBBox, 'EdgeColor', 'b','LineWidth',1);
        end
        set(handles.HoleAnswer,'String',holeNo);
    else
        set(handles.HoleAnswer,'String',"0");
    end

end



% --- Executes on button press in ExitButton.
function ExitButton_Callback(hObject, eventdata, handles)
% hObject    handle to ExitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.BreachAnswer,'String',"");
set(handles.DirtAnswer,'String',"");
set(handles.HoleAnswer,'String',"");

close(nitrile_glove_defect_detection);


% --- Executes on button press in BackToMainPageButton.
function BackToMainPageButton_Callback(hObject, eventdata, handles)
% hObject    handle to BackToMainPageButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(nitrile_glove_defect_detection);
% go back to main menu
IPPR_Main_GDD();
