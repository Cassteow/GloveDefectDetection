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

% Last Modified by GUIDE v2.5 21-Mar-2023 18:35:02

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
       
         % Opening Detection
         [openingProps, openingNo] = cloth_glove_opening(glove_img);

         % Stain Detection
         [stainProps, stainNo] = cloth_glove_stain(glove_img);

         % Thread Detection
         [threadProps, threadNo] = cloth_glove_stitch(glove_img);

         axis(handles.axes1);
         imagesc(glove_img);
         hold on;
         % Label Opening Defects
         if openingNo>0
             for k = 1 : openingNo
                 OPthisBBox = openingProps(k).BoundingBox;
                 rectangle('Position', OPthisBBox, 'EdgeColor', 'g','LineWidth',1);
             end
             set(handles.openingAns,'String',openingNo);
         else
             set(handles.openingAns,'String',"0");
         end
         % Label Stain Defects
         if stainNo >0
             for k = 1:stainNo
                 stainthisBBox = stainProps(k).BoundingBox;
                 rectangle('Position', stainthisBBox, 'EdgeColor', 'r','LineWidth',1);
             end
             set(handles.stainAns,'String',stainNo);
         else
             set(handles.stainAns,'String',"0");
         end
         % Label Loose Thread Defects
         if threadNo >0
             for k = 1:threadNo
                 threadThisBox = threadProps(k).BoundingBox;
                 rectangle('Position', threadThisBox, 'EdgeColor', 'b','LineWidth',1);
             end
             set(handles.threadAns,'String',threadNo);
         else
             set(handles.threadAns,'String',"0");
         end

     end
                 



% --- Executes on button press in ExitButton.
function ExitButton_Callback(hObject, eventdata, handles)
% hObject    handle to ExitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.openingAns,'String',"");
set(handles.threadAns,'String',"");
set(handles.stainAns,'String',"");

close(cloth_glove_defect_detection);



% --- Executes on button press in btnReturnMain.
function btnReturnMain_Callback(hObject, eventdata, handles)
% hObject    handle to btnReturnMain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Close current interface
close(cloth_glove_defect_detection);
% go back to main menu
IPPR_Main_GDD();