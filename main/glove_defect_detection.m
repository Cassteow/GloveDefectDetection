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

% Last Modified by GUIDE v2.5 07-Feb-2023 23:28:59

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


% --- Executes on button press in btnDetect.
function btnDetect_Callback(hObject, eventdata, handles)
% hObject    handle to btnDetect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btnReset.
function btnReset_Callback(hObject, eventdata, handles)
% hObject    handle to btnReset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
