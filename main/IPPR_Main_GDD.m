function varargout = IPPR_Main_GDD(varargin)
% IPPR_MAIN_GDD MATLAB code for IPPR_Main_GDD.fig
%      IPPR_MAIN_GDD, by itself, creates a new IPPR_MAIN_GDD or raises the existing
%      singleton*.
%
%      H = IPPR_MAIN_GDD returns the handle to a new IPPR_MAIN_GDD or the handle to
%      the existing singleton*.
%
%      IPPR_MAIN_GDD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IPPR_MAIN_GDD.M with the given input arguments.
%
%      IPPR_MAIN_GDD('Property','Value',...) creates a new IPPR_MAIN_GDD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before IPPR_Main_GDD_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to IPPR_Main_GDD_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help IPPR_Main_GDD

% Last Modified by GUIDE v2.5 21-Mar-2023 22:40:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @IPPR_Main_GDD_OpeningFcn, ...
                   'gui_OutputFcn',  @IPPR_Main_GDD_OutputFcn, ...
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


% --- Executes just before IPPR_Main_GDD is made visible.
function IPPR_Main_GDD_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to IPPR_Main_GDD (see VARARGIN)

% Choose default command line output for IPPR_Main_GDD
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes IPPR_Main_GDD wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = IPPR_Main_GDD_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnClothGlove.
function btnClothGlove_Callback(hObject, eventdata, handles)
% hObject    handle to btnClothGlove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(IPPR_Main_GDD);
cloth_glove_defect_detection();

% --- Executes on button press in btnRubberGlove.
function btnRubberGlove_Callback(hObject, eventdata, handles)
% hObject    handle to btnRubberGlove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(IPPR_Main_GDD);
rubber_glove_defect_detection();


% --- Executes on button press in exitBtn.
function exitBtn_Callback(hObject, eventdata, handles)
% hObject    handle to exitBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(IPPR_Main_GDD);


% --- Executes on button press in btnNitrileGlove.
function btnNitrileGlove_Callback(hObject, eventdata, handles)
% hObject    handle to btnNitrileGlove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
