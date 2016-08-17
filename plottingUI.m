function varargout = plottingUI(varargin)
% PLOTTINGUI MATLAB code for plottingUI.fig
%      PLOTTINGUI, by itself, creates a new PLOTTINGUI or raises the existing
%      singleton*.
%
%      H = PLOTTINGUI returns the handle to a new PLOTTINGUI or the handle to
%      the existing singleton*.
%
%      PLOTTINGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTTINGUI.M with the given input arguments.
%
%      PLOTTINGUI('Property','Value',...) creates a new PLOTTINGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before plottingUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to plottingUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help plottingUI

% Last Modified by GUIDE v2.5 15-Jul-2016 16:28:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @plottingUI_OpeningFcn, ...
                   'gui_OutputFcn',  @plottingUI_OutputFcn, ...
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


% --- Executes just before plottingUI is made visible.
function plottingUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to plottingUI (see VARARGIN)

% Choose default command line output for plottingUI
handles.output = hObject;
handles.key = varargin{1};
handles.data = varargin{2};
handles.headers = varargin{3};
handles.headers_stim = varargin{4};
handles.data_stim = varargin{5};
handles.plotClasses = cell(0);

col_cmpd = strcmp(handles.headers, 'Cmpd');
cmpd_list = unique(handles.key(:,col_cmpd));
handles.cmpd_list = cmpd_list;
dmso_idx = strcmp(cmpd_list,'DMSO');
set(handles.popupmenu2,'String',cmpd_list);
set(handles.popupmenu4,'String',cmpd_list);
set(handles.popupmenu6,'String',cmpd_list);
set(handles.popupmenu2,'Value',find(dmso_idx == 1));
cmpd_idx = strcmp(handles.key(:,col_cmpd),'DMSO');
key_cmpd = handles.key(cmpd_idx,:);
col_conc = strcmp(handles.headers,'Concentration');
conc = cell2mat(key_cmpd(:,col_conc));
set(handles.popupmenu3,'String',num2cell(unique(conc)));

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes plottingUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = plottingUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

idx = get(hObject,'Value'); val = get(hObject,'String');
cmpd = val{idx};
col_cmpd = strcmp(handles.headers,'Cmpd');
cmpd_idx = strcmp(handles.key(:,col_cmpd),cmpd);
key_cmpd = handles.key(cmpd_idx,:);
col_conc = strcmp(handles.headers,'Concentration');
conc = cell2mat(key_cmpd(:,col_conc));
set(handles.popupmenu3,'String',num2cell(unique(conc)));

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4
idx = get(hObject,'Value'); val = get(hObject,'String');
cmpd = val{idx};
col_cmpd = strcmp(handles.headers,'Cmpd');
cmpd_idx = strcmp(handles.key(:,col_cmpd),cmpd);
key_cmpd = handles.key(cmpd_idx,:);
col_conc = strcmp(handles.headers,'Concentration');
conc = cell2mat(key_cmpd(:,col_conc));
set(handles.popupmenu5,'String',num2cell(unique(conc)));

% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu5


% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu6.
function popupmenu6_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu6
idx = get(hObject,'Value'); val = get(hObject,'String');
cmpd = val{idx};
col_cmpd = strcmp(handles.headers,'Cmpd');
cmpd_idx = strcmp(handles.key(:,col_cmpd),cmpd);
key_cmpd = handles.key(cmpd_idx,:);
col_conc = strcmp(handles.headers,'Concentration');
conc = cell2mat(key_cmpd(:,col_conc));
set(handles.popupmenu7,'String',num2cell(unique(conc)));

% --- Executes during object creation, after setting all properties.
function popupmenu6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu7.
function popupmenu7_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu7


% --- Executes during object creation, after setting all properties.
function popupmenu7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cmpd1 = get(handles.popupmenu2,'Value');
cmpd2 = get(handles.popupmenu4,'Value');
cmpd3 = get(handles.popupmenu6,'Value');
cmpd = [handles.cmpd_list(cmpd1); handles.cmpd_list(cmpd2); handles.cmpd_list(cmpd3)];

conc1_list = get(handles.popupmenu3,'String');
conc2_list = get(handles.popupmenu5,'String');
conc3_list = get(handles.popupmenu7,'String');
conc1 = get(handles.popupmenu3,'Value');
conc2 = get(handles.popupmenu5,'Value');
conc3 = get(handles.popupmenu7,'Value');
conc = [conc1_list(conc1); conc2_list(conc2); conc3_list(conc3)];

%Plot the data!
createDrugPlot(handles.data, handles.key, handles.headers, cmpd, conc,...
    handles.headers_stim, handles.data_stim);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Here we will create the PCA plot!
figure();hold on; [handles.plotHandles, handles.plotHandles_header] = ...
    create_PCA_doseresponse3d(handles.key,handles.headers,'Cmpd',handles.data,0);
grid on; axis vis3d;
handles.col_handle_class = strcmp(handles.plotHandles_header,'ClassName');
handles.col_handle_marker = strcmp(handles.plotHandles_header,'MarkerHandles');
handles.col_handle_line = strcmp(handles.plotHandles_header,'LineHandles');

%Now set everything gray
setPCAcolor([0.5 0.5 0.5],handles.plotHandles,handles.col_handle_marker,...
    handles.col_handle_line,2);
guidata(hObject, handles);

% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
turnGray(handles);
val = get(hObject,'Value');
COI = get(hObject,'String');
if val == 1
    handles.plotClasses = [handles.plotClasses COI];
else
    idx = strcmp(handles.plotClasses, COI);
    handles.plotClasses(idx) = [];
end
highlightClass(handles);
guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
turnGray(handles);
val = get(hObject,'Value');
COI = get(hObject,'String');
if val == 1
    handles.plotClasses = [handles.plotClasses COI];
else
    idx = strcmp(handles.plotClasses, COI);
    handles.plotClasses(idx) = [];
end
highlightClass(handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of radiobutton2


% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
turnGray(handles);
val = get(hObject,'Value');
COI = get(hObject,'String');
if val == 1
    handles.plotClasses = [handles.plotClasses COI];
else
    idx = strcmp(handles.plotClasses, COI);
    handles.plotClasses(idx) = [];
end
highlightClass(handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of radiobutton3


% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
turnGray(handles);
val = get(hObject,'Value');
COI = get(hObject,'String');
if val == 1
    handles.plotClasses = [handles.plotClasses COI];
else
    idx = strcmp(handles.plotClasses, COI);
    handles.plotClasses(idx) = [];
end
highlightClass(handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of radiobutton4


% --- Executes on button press in radiobutton5.
function radiobutton5_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
turnGray(handles);
val = get(hObject,'Value');
COI = get(hObject,'String');
if val == 1
    handles.plotClasses = [handles.plotClasses COI];
else
    idx = strcmp(handles.plotClasses, COI);
    handles.plotClasses(idx) = [];
end
highlightClass(handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of radiobutton5


% --- Executes on button press in radiobutton6.
function radiobutton6_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
turnGray(handles);
val = get(hObject,'Value');
COI = get(hObject,'String');
if val == 1
    handles.plotClasses = [handles.plotClasses COI];
else
    idx = strcmp(handles.plotClasses, COI);
    handles.plotClasses(idx) = [];
end
highlightClass(handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of radiobutton6


% --- Executes on button press in radiobutton7.
function radiobutton7_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
turnGray(handles);
val = get(hObject,'Value');
COI = get(hObject,'String');
if val == 1
    handles.plotClasses = [handles.plotClasses COI];
else
    idx = strcmp(handles.plotClasses, COI);
    handles.plotClasses(idx) = [];
end
highlightClass(handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of radiobutton7


% --- Executes on button press in radiobutton8.
function radiobutton8_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
turnGray(handles);
val = get(hObject,'Value');
COI = get(hObject,'String');
if val == 1
    handles.plotClasses = [handles.plotClasses COI];
else
    idx = strcmp(handles.plotClasses, COI);
    handles.plotClasses(idx) = [];
end
highlightClass(handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of radiobutton8


% --- Executes on button press in radiobutton9.
function radiobutton9_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
turnGray(handles);
val = get(hObject,'Value');
COI = get(hObject,'String');
if val == 1
    handles.plotClasses = [handles.plotClasses COI];
else
    idx = strcmp(handles.plotClasses, COI);
    handles.plotClasses(idx) = [];
end
highlightClass(handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of radiobutton9


% --- Executes on button press in radiobutton10.
function radiobutton10_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
turnGray(handles);
val = get(hObject,'Value');
COI = get(hObject,'String');
if val == 1
    handles.plotClasses = [handles.plotClasses COI];
else
    idx = strcmp(handles.plotClasses, COI);
    handles.plotClasses(idx) = [];
end
highlightClass(handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of radiobutton10


% --- Executes on button press in radiobutton11.
function radiobutton11_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
turnGray(handles);
val = get(hObject,'Value');
COI = get(hObject,'String');
if val == 1
    handles.plotClasses = [handles.plotClasses COI];
else
    idx = strcmp(handles.plotClasses, COI);
    handles.plotClasses(idx) = [];
end
highlightClass(handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of radiobutton11


% --- Executes on button press in radiobutton12.
function radiobutton12_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
turnGray(handles);
val = get(hObject,'Value');
COI = get(hObject,'String');
if val == 1
    handles.plotClasses = [handles.plotClasses COI];
else
    idx = strcmp(handles.plotClasses, COI);
    handles.plotClasses(idx) = [];
end
highlightClass(handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of radiobutton12


% --- Executes on button press in radiobutton13.
function radiobutton13_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
turnGray(handles);
val = get(hObject,'Value');
COI = get(hObject,'String');
if val == 1
    handles.plotClasses = [handles.plotClasses COI];
else
    idx = strcmp(handles.plotClasses, COI);
    handles.plotClasses(idx) = [];
end
highlightClass(handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of radiobutton13


% --- Executes on button press in radiobutton14.
function radiobutton14_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
turnGray(handles);
val = get(hObject,'Value');
COI = get(hObject,'String');
if val == 1
    handles.plotClasses = [handles.plotClasses COI];
else
    idx = strcmp(handles.plotClasses, COI);
    handles.plotClasses(idx) = [];
end
highlightClass(handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of radiobutton14

function turnGray(handles)
setPCAcolor([0.5 0.5 0.5],handles.plotHandles,handles.col_handle_marker,...
    handles.col_handle_line,2);

function highlightClass(handles)
if isempty(handles.plotClasses) == 0
    COI_idx = zeros(size(handles.plotHandles,1),1);
    dmso_idx = strcmp(handles.plotHandles(:,handles.col_handle_class),'Control');
    %First set DMSO to black (just because)
    setPCAcolor([0 0 0],handles.plotHandles(dmso_idx,:),...
        handles.col_handle_marker,handles.col_handle_line,3);
    %Now set colors for the compound of interest
    for i = 1:numel(handles.plotClasses)
        temp = strcmp(handles.plotHandles(:,handles.col_handle_class),handles.plotClasses{i});
        COI_idx = COI_idx + temp;
    end
    COI_idx = logical(COI_idx);
    colors = hsv(sum(COI_idx));
    setPCAcolor(colors,handles.plotHandles(COI_idx,:),...
        handles.col_handle_marker,handles.col_handle_line,3);
end
