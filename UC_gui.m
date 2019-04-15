function varargout = UC_gui(varargin)
% UC_GUI MATLAB code for UC_gui.fig
%      UC_GUI, by itself, creates a new UC_GUI or raises the existing
%      singleton*.
%
%      H = UC_GUI returns the handle to a new UC_GUI or the handle to
%      the existing singleton*.
%
%      UC_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UC_GUI.M with the given input arguments.
%
%      UC_GUI('Property','Value',...) creates a new UC_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before UC_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to UC_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help UC_gui

% Last Modified by GUIDE v2.5 13-Apr-2019 05:45:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UC_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @UC_gui_OutputFcn, ...
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


% --- Executes just before UC_gui is made visible.
function UC_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to UC_gui (see VARARGIN)

% Choose default command line output for UC_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes UC_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = UC_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global units demand Pit Uit;
[file,path] = uigetfile('*.csv');
if isequal(file,0)
   disp('User selected Cancel');
else
   [fileName, pathName] = uigetfile('*.csv');
    units = csvread(fullfile(pathName,fileName));
end

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global units demand Pit Uit;
[file,path] = uigetfile('*.csv');
if isequal(file,0)
   disp('User selected Cancel');
else
   [fileName, pathName] = uigetfile('*.csv');
    demand = csvread(fullfile(pathName,fileName));
end


% --- Executes on button press in disp_unit.
function disp_unit_Callback(hObject, eventdata, handles)
% hObject    handle to disp_unit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in solve.
function solve_Callback(hObject, eventdata, handles)
% hObject    handle to solve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global units demand Pit Uit;
[Pit, Uit] = UC_gui_fn(units, demand, 0.1);


% --- Executes on button press in pit_disp.
function pit_disp_Callback(hObject, eventdata, handles)
% hObject    handle to pit_disp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global units demand Pit Uit;
plot(Pit');


% --- Executes on button press in u_disp.
function u_disp_Callback(hObject, eventdata, handles)
% hObject    handle to u_disp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global units demand Pit Uit;
%area(Uit')
imshow(Uit);
