function varargout = GUIDETEST(varargin)
% GUIDETEST MATLAB code for GUIDETEST.fig
%      GUIDETEST, by itself, creates a new GUIDETEST or raises the existing
%      singleton*.
%
%      H = GUIDETEST returns the handle to a new GUIDETEST or the handle to
%      the existing singleton*.
%
%      GUIDETEST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIDETEST.M with the given input arguments.
%
%      GUIDETEST('Property','Value',...) creates a new GUIDETEST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUIDETEST_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUIDETEST_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUIDETEST

% Last Modified by GUIDE v2.5 19-Nov-2017 15:58:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUIDETEST_OpeningFcn, ...
                   'gui_OutputFcn',  @GUIDETEST_OutputFcn, ...
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


% --- Executes just before GUIDETEST is made visible.
function GUIDETEST_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUIDETEST (see VARARGIN)

% Choose default command line output for GUIDETEST
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUIDETEST wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUIDETEST_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in LoadFile.
function LoadFile_Callback(hObject, eventdata, handles)
% hObject    handle to LoadFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
h = waitbar(0,'Initializing ...');
waitbar(0.5,h,'Halfway there...');
[FileName,PathName] = uigetfile({'*.cir';'*.txt';'*.*'},'File Selector');
addpath(PathName);
handles.SS = SpiceCircuit(FileName);
handles.SS.MNA.formMNA;
tmp = get(handles.Nodepop,'string'); % to get the actual list of items in the popup menu
for i = 1 : size(handles.SS.nodeSpace.NodeList,2)
tmp{size(tmp,2) + i} = string(handles.SS.nodeSpace.NodeList(i));
end
perc = 75;
waitbar(perc/100,h,sprintf('%d%% along...',perc));
set(handles.Nodepop,'string',tmp); % to update the popup menu items
tmp = get(handles.ChangeTransinput,'string'); % to get the actual list of items in the popup menu
if isempty(handles.SS.VoltageSources.elementList(1).dc) == false
    for i = 1 : size(handles.SS.VoltageSources.elementList,2)
        if handles.SS.VoltageSources.elementList(i).tran == 1
        tmp{size(tmp,2) + i} = string(handles.SS.VoltageSources.elementList(i).name);
        end
    end
end
if isempty(handles.SS.CurrentSources.elementList(1).dc) == false
    for i = 1 : size(handles.SS.CurrentSources.elementList,2)
        if handles.SS.CurrentSources.elementList(i).tran == 1
        tmp{size(tmp,2) + i + size(handles.SS.VoltageSources.elementList,2)} = string(handles.SS.CurrentSources.elementList(i).name);
        end
    end
end
tmp_new = tmp(~cellfun(@isempty, tmp));

% fh = figure;
% % eh = uicontrol('Style','edit','String',num2str(v));
% eh = uicontrol('Style','edit','String',tmp_new(1));

set(handles.ChangeTransinput,'string',tmp_new);
close(h);
set(handles.Loadbox,'value',1);
guidata(hObject,handles);
catch ME
    message = sprintf('Error in LoadFile():\n%s', ME.message);
	uiwait(warndlg(message));
end


% --- Executes on button press in Savebutton.
function Savebutton_Callback(hObject, eventdata, handles)
% hObject    handle to Savebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
for x = 1:size(handles.SS.Resistors.elementList,2)
    rownames_Resistor(x,1) = {handles.SS.Resistors.elementList(x).name};
    for y = 2:size(handles.SS.Resistors.nodes,2)+ 1
    rownames_Resistor(x,y) = {handles.SS.Resistors.nodes(x,y-1)};
    if(y == size(handles.SS.Resistors.nodes,2)+ 1 )
        for z = (y + 1):(size(handles.SS.Resistors.elementList(x).value,2)+ y)
            rownames_Resistor(x,z) = {handles.SS.Resistors.elementList(x).value};
        end
    end
    end
end
for x = 1:size(handles.SS.Capacitors.elementList,2)
    rownames_Capacitors(x,1) = {handles.SS.Capacitors.elementList(x).name};
    for y = 2:size(handles.SS.Capacitors.nodes,2)+ 1
    rownames_Capacitors(x,y) = {handles.SS.Capacitors.nodes(x,y-1)};
    if(y == size(handles.SS.Capacitors.nodes,2)+ 1 )
        for z = (y + 1):(size(handles.SS.Capacitors.elementList(x).value,2)+ y)
            rownames_Capacitors(x,z) = {handles.SS.Capacitors.elementList(x).value};
        end
    end
    end
end
for x = 1:size(handles.SS.Inductors.elementList,2)
    rownames_Inductors(x,1) = {handles.SS.Inductors.elementList(x).name};
    for y = 2:size(handles.SS.Inductors.nodes,2)+ 1
    rownames_Inductors(x,y) = {handles.SS.Inductors.nodes(x,y-1)};
    if(y == size(handles.SS.Inductors.nodes,2)+ 1 )
        for z = (y + 1):(size(handles.SS.Inductors.elementList(x).value,2)+ y)
            rownames_Inductors(x,z) = {handles.SS.Inductors.elementList(x).value};
        end
    end
    end
end
fileID = fopen('exp.txt','w');
fprintf(fileID,'Sample Test Circuit\n');
formatSpec = '%s  %d  %d  %d\n';
for x = 1:size(rownames_Resistor,1)
    fprintf(fileID,formatSpec,rownames_Resistor{x,:});
end
for x = 1:size(rownames_Capacitors,1)
   fprintf(fileID,formatSpec,rownames_Capacitors{x,:});
end
% for x = 1:size(rownames_Inductors,1)
%    fprintf(fileID,formatSpec,rownames_Inductors{x,:});
% end
fclose(fileID);
set(handles.Savebox,'value',1);
catch ME
	message = sprintf('Error in Savebutton():\n%s', ME.message);
	uiwait(warndlg(message));
end


% --- Executes on button press in LoadData.
function LoadData_Callback(hObject, eventdata, handles)
% hObject    handle to LoadData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.CirValueTable, 'data', [], 'RowName',[], 'ColumnName', []);
set(handles.CirProTable, 'data', [], 'RowName',[], 'ColumnName', []);
set(handles.SourceTable, 'data', [], 'RowName',[], 'ColumnName', []);
set(handles.Sourceinfo, 'data', [], 'RowName',[], 'ColumnName', []);
count = 0;
if isempty(handles.SS.Resistors.elementList(1).value) == false
for x = 1:size(handles.SS.Resistors.elementList,2)
    count = count + 1;
    handles.rownames_1(x,1) = {handles.SS.Resistors.elementList(x).name};
    handles.rownames_2(x,1) = {handles.SS.Resistors.elementList(x).name};
for i = 1:5
    if i == 1
        d_1(x,i) = handles.SS.Resistors.elementList(x).value;
        handles.columnnames_1(1,1) = {'Value'};
    end
    if i == 2
        d_2(x,i) = {handles.SS.Resistors.elementList(x).modelName};
        handles.columnnames_2(1,1) = {'ModelName'};
    end
    if i == 3
        d_2(x,i) = {handles.SS.Resistors.elementList(x).length};
        handles.columnnames_2(1,2) = {'Length'};
    end
    if i == 4
        d_2(x,i) = {handles.SS.Resistors.elementList(x).width};
        handles.columnnames_2(1,3) = {'Width'};
    end
    if i == 5
        d_2(x,i) = {handles.SS.Resistors.elementList(x).temperature};
        handles.columnnames_2(1,4) = {'Temperature'};
    end
%     
end
end
end
if isempty(handles.SS.Capacitors.elementList(1).value) == false
for x = 1:size(handles.SS.Capacitors.elementList,2)
    count = count + 1;
    handles.rownames_1(count,1) = {handles.SS.Capacitors.elementList(x).name};
    handles.rownames_2(count,1) = {handles.SS.Capacitors.elementList(x).name};
for i = 1:6
    if i == 1
        d_1(count,i) = handles.SS.Capacitors.elementList(x).value;
    end
    if i == 2
        d_2(count,i) = {handles.SS.Capacitors.elementList(x).modelName};
    end
    if i == 3
        d_2(count,i) = {handles.SS.Capacitors.elementList(x).length};
    end
    if i == 4
        d_2(count,i) = {handles.SS.Capacitors.elementList(x).width};
    end
    if i == 5
        d_2(count,i) = {handles.SS.Capacitors.elementList(x).IC};
        handles.columnnames_2(1,3) = {'IC'};
    end
%     
end   
end
end
if isempty(handles.SS.Inductors.elementList(1).value) == false
for x = 1:size(handles.SS.Inductors.elementList,2)
    count = count + 1;
    handles.rownames_1(count,1) = {handles.SS.Inductors.elementList(x).name};
    handles.rownames_2(count,1) = {handles.SS.Inductors.elementList(x).name};
for i = 1:6
    if i == 1
        d_1(count,i) = handles.SS.Inductors.elementList(x).value;
    end
    if i == 6
        d_2(count,i) = {handles.SS.Inductors.elementList(x).IC};
    end
%     
end   
end
end
count = 0;
if isempty(handles.SS.VoltageSources.elementList(1).dc) == false
for x = 1:size(handles.SS.VoltageSources.elementList,2)
    count = count + 1;
    handles.rownames_3(x,1) = {handles.SS.VoltageSources.elementList(x).name}; %value
    handles.rownames_4(x,1) = {handles.SS.VoltageSources.elementList(x).name}; %info
for i = 1:9
    if i == 1
        d_4(x,i) = {handles.SS.VoltageSources.elementList(x).dc};
        handles.columnnames_4(1,1) = {'DC'};
        d_3(x,i) = handles.SS.VoltageSources.elementList(x).dcValue;
        handles.columnnames_3(1,1) = {'DC Value'};
    end
    if i == 2
        d_4(x,i) = {handles.SS.VoltageSources.elementList(x).ac};
        handles.columnnames_4(1,2) = {'AC'};
        d_3(x,i) = handles.SS.VoltageSources.elementList(x).acMag;
        handles.columnnames_3(1,2) = {'AC Mag'};        
    end
    if i == 3
        d_3(x,i) = handles.SS.VoltageSources.elementList(x).acPhase;
        handles.columnnames_3(1,3) = {'AC Phase'};
        d_4(x,i) = {handles.SS.VoltageSources.elementList(x).DISTOF1};
        handles.columnnames_4(1,3) = {'DISTOF1'};
    end
    if i == 4
        handles.columnnames_3(1,4) = {'Of1Mag'}; 
        d_4(x,i) = {handles.SS.VoltageSources.elementList(x).DISTOF2};
        handles.columnnames_4(1,4) = {'DISTOF2'};
    end
    if i == 5
        handles.columnnames_3(1,5) = {'Of1Phase'}; 
        d_4(x,i) = {handles.SS.VoltageSources.elementList(x).DISTOF3};
        handles.columnnames_4(1,5) = {'DISTOF3'};
    end
    if i == 6
        handles.columnnames_3(1,6) = {'Of2Mag'}; 
        d_4(x,i) = {handles.SS.VoltageSources.elementList(x).tran};
        handles.columnnames_4(1,6) = {'Tran'};
    end
    if i == 7
        handles.columnnames_3(1,7) = {'Of2Phase'}; 
    end
    if i == 8
        handles.columnnames_3(1,8) = {'Of3Mag'}; 
    end
    if i == 9
        handles.columnnames_3(1,9) = {'of3Phase'}; 
    end
%     
end   
end
end
if isempty(handles.SS.CurrentSources.elementList(1).dc) == false
for x = 1:size(handles.SS.CurrentSources.elementList,2)
    count = count + 1;
    handles.rownames_3(count,1) = {handles.SS.CurrentSources.elementList(x).name}; %value
    handles.rownames_4(count,1) = {handles.SS.CurrentSources.elementList(x).name}; %info
for i = 1:9
    if i == 1
        d_4(count,i) = {handles.SS.CurrentSources.elementList(x).dc};
        d_3(count,i) = handles.SS.CurrentSources.elementList(x).dcValue;
    end
    if i == 2
        d_4(count,i) = {handles.SS.CurrentSources.elementList(x).ac};
        d_3(count,i) = handles.SS.CurrentSources.elementList(x).acMag;       
    end
    if i == 3
        d_3(count,i) = handles.SS.CurrentSources.elementList(x).acPhase;
        d_4(count,i) = {handles.SS.CurrentSources.elementList(x).DISTOF1};
    end
    if i == 4
        d_3(count,i) = handles.SS.CurrentSources.elementList(x).of1Mag;
        d_4(count,i) = {handles.SS.CurrentSources.elementList(x).DISTOF2};
    end
    if i == 5
        d_3(count,i) = handles.SS.CurrentSources.elementList(x).of1Phase;
        d_4(count,i) = {handles.SS.CurrentSources.elementList(x).DISTOF3};
    end
    if i == 6
        d_3(count,i) = handles.SS.CurrentSources.elementList(x).of2Mag;
        d_4(count,i) = {handles.SS.CurrentSources.elementList(x).tran};
    end
    if i == 7
        d_3(count,i) = handles.SS.CurrentSources.elementList(x).of2Phase;
    end
    if i == 8
        d_3(count,i) = handles.SS.CurrentSources.elementList(x).of3Mag;
    end
    if i == 9
        d_3(count,i) = handles.SS.CurrentSources.elementList(x).of3Phase;
    end
%     
end   
end
end
set(handles.CirValueTable, 'data', d_1, 'RowName',handles.rownames_1, 'ColumnName', handles.columnnames_1);
set(handles.CirProTable, 'data', d_2, 'RowName',handles.rownames_2, 'ColumnName', handles.columnnames_2);
set(handles.SourceTable, 'data', d_3, 'RowName',handles.rownames_3, 'ColumnName', handles.columnnames_3);
set(handles.Sourceinfo, 'data', d_4, 'RowName',handles.rownames_4, 'ColumnName', handles.columnnames_4);
guidata(hObject,handles);

% --- Executes on selection change in AanlysisMe.
function AanlysisMe_Callback(hObject, eventdata, handles)
% hObject    handle to AanlysisMe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns AanlysisMe contents as cell array
%        contents{get(hObject,'Value')} returns selected item from AanlysisMe


% --- Executes during object creation, after setting all properties.
function AanlysisMe_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AanlysisMe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in TabOne.
function TabOne_Callback(hObject, eventdata, handles)
% hObject    handle to TabOne (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.uipanel9,'Visible','Off');
set(handles.CirPanel,'Visible','On');
guidata(hObject,handles);

% --- Executes on button press in TabTwo.
function TabTwo_Callback(hObject, eventdata, handles)
% hObject    handle to TabTwo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.CirPanel,'Visible','Off');
set(handles.uipanel9,'Visible','On');
guidata(hObject,handles);


% --- Executes on selection change in selectTablePopup.
function selectTablePopup_Callback(hObject, eventdata, handles)
% hObject    handle to selectTablePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
d_1 = {};
handles.rownames_1 = {};
handles.columnnames_1 = {};
set(handles.cirEleValTable, 'data',[], 'RowName',[], 'ColumnName', []);
v = get(handles.selectTablePopup,'Value'); %get currently selected option from menu
if v == 2 %if linear circuit element is selected
count = 0;
if isempty(handles.SS.Resistors.elementList(1).value) == false
for x = 1:size(handles.SS.Resistors.elementList,2)
    count = count + 1;
    handles.rownames_1(count,1) = {handles.SS.Resistors.elementList(x).name};
for i = 1:5
    if i == 1
        d_1(count,i) = {handles.SS.Resistors.elementList(x).value};
        handles.columnnames_1(1,1) = {'Value'};
    end
    if i == 2
        d_1(count,i) = {handles.SS.Resistors.elementList(x).modelName};
        handles.columnnames_1(1,2) = {'ModelName'};
    end
    if i == 3
        d_1(count,i) = {handles.SS.Resistors.elementList(x).length};
        handles.columnnames_1(1,3) = {'Length'};
    end
    if i == 4
        d_1(count,i) = {handles.SS.Resistors.elementList(x).width};
        handles.columnnames_1(1,4) = {'Width'};
    end
    if i == 5
        d_1(count,i) = {handles.SS.Resistors.elementList(x).temperature};
        handles.columnnames_1(1,5) = {'Temperature'};
    end
%     
end
end
end
    
if isempty(handles.SS.Capacitors.elementList(1).value) == false
for x = 1:size(handles.SS.Capacitors.elementList,2)
    count = count + 1;
    handles.rownames_1(count,1) = {handles.SS.Capacitors.elementList(x).name};
for i = 1:6
    if i == 1
        d_1(count,i) = {handles.SS.Capacitors.elementList(x).value};
    end
    if i == 2
        d_1(count,i) = {handles.SS.Capacitors.elementList(x).modelName};
    end
    if i == 3
        d_1(count,i) = {handles.SS.Capacitors.elementList(x).length};
    end
    if i == 4
        d_1(count,i) = {handles.SS.Capacitors.elementList(x).width};
    end
    if i == 5
        d_1(count,i) = {handles.SS.Capacitors.elementList(x).IC};
        handles.columnnames_1(1,6) = {'IC'};
    end
%     
end   
end
end

if isempty(handles.SS.Inductors.elementList(1).value) == false
for x = 1:size(handles.SS.Inductors.elementList,2)
    count = count + 1;
    handles.rownames_1(count,1) = {handles.SS.Inductors.elementList(x).name};
for i = 1:6
    if i == 1
        d_1(count,i) = {handles.SS.Inductors.elementList(x).value};
    end
    if i == 2
        d_1(count,i) = {handles.SS.Inductors.elementList(x).modelName};
    end
    if i == 3
        d_1(count,i) = {handles.SS.Inductors.elementList(x).length};
    end
    if i == 4
        d_1(count,i) = {handles.SS.Inductors.elementList(x).width};
    end
    if i == 5
        d_1(count,i) = {handles.SS.Inductors.elementList(x).IC};
    end
%     
end   
end
end

elseif v == 4 %if source is selected 
    count = 0;
if isempty(handles.SS.VoltageSources.elementList(1).dc) == false
for x = 1:size(handles.SS.VoltageSources.elementList,2)
    count = count + 1;
    handles.rownames_1(count,1) = {handles.SS.VoltageSources.elementList(x).name}; 
for i = 1:15
    if i == 1
        d_1(count,i) = {handles.SS.VoltageSources.elementList(x).dc};
        handles.columnnames_1(1,i) = {'DC'};
    end
    if i == 2
        d_1(count,i) = {handles.SS.VoltageSources.elementList(x).dcValue};
        handles.columnnames_1(1,i) = {'DC Value'};      
    end
    if i == 3
        d_1(count,i) = {handles.SS.VoltageSources.elementList(x).ac};
        handles.columnnames_1(1,i) = {'AC'};
    end
    if i == 4
        d_1(count,i) = {handles.SS.VoltageSources.elementList(x).acMag};
        handles.columnnames_1(1,i) = {'AC Mag'};  
    end
    if i == 5
        d_1(count,i) ={handles.SS.VoltageSources.elementList(x).acPhase};
        handles.columnnames_1(1,i) = {'AC Phase'};
    end
    if i == 6
        d_1(count,i) = {handles.SS.VoltageSources.elementList(x).DISTOF1};
        handles.columnnames_1(1,i) = {'DISTOF1'};
    end
    if i == 7
        d_1(count,i) = {handles.SS.VoltageSources.elementList(x).DISTOF2};
        handles.columnnames_1(1,i) = {'DISTOF2'};
    end
    if i == 8
        d_1(count,i) = {handles.SS.VoltageSources.elementList(x).DISTOF3};
        handles.columnnames_1(1,i) = {'DISTOF3'};
    end
    if i == 9
        handles.columnnames_1(1,i) = {'Of1Mag'}; 
    end
    if i == 10
        handles.columnnames_1(1,i) = {'Of1Phase'}; 
    end
    if i == 11
        handles.columnnames_1(1,i) = {'Of2Mag'}; 
    end
    if i == 12
        handles.columnnames_1(1,i) = {'Of2Phase'};
    end
    if i == 13
        handles.columnnames_1(1,i) = {'Of3Mag'}; 
    end
    if i == 14
        handles.columnnames_1(1,i) = {'of3Phase'};
    end
    if i == 15
        if handles.SS.VoltageSources.elementList(x).tran ~= 1
        d_1(count,i) = {handles.SS.VoltageSources.elementList(x).tran};
        handles.columnnames_1(1,i) = {'Tran'};
        else
        d_1(count,i) = {class(handles.SS.VoltageSources.elementList(1).tranInput)};
        handles.columnnames_1(1,i) = {'Trantype'};
        end
    end
%     
end   
end
end
elseif v == 5 %if source is selected 
    count = 0;
if isempty(handles.SS.CurrentSources.elementList(1).dc) == false
for x = 1:size(handles.SS.CurrentSources.elementList,2)
    count = count + 1;
    handles.rownames_1(count,1) = {handles.SS.CurrentSources.elementList(x).name};
for i = 1:15
    if i == 1
        d_1(count,i) = {handles.SS.CurrentSources.elementList(x).dc};
        handles.columnnames_1(1,i) = {'DC'};
    end
    if i == 2
        d_1(count,i) = {handles.SS.CurrentSources.elementList(x).dcValue};
        handles.columnnames_1(1,i) = {'DC Value'};
    end
    if i == 3
        d_1(count,i) = {handles.SS.CurrentSources.elementList(x).ac};
        handles.columnnames_1(1,i) = {'AC'};
    end
    if i == 4
        d_1(count,i) = {handles.SS.CurrentSources.elementList(x).acMag};  
        handles.columnnames_1(1,i) = {'AC Mag'};
    end
    if i == 5
        d_1(count,i) = {handles.SS.CurrentSources.elementList(x).acPhase};
        handles.columnnames_1(1,i) = {'AC Phase'};
    end
    if i == 6
        d_1(count,i) = {handles.SS.CurrentSources.elementList(x).DISTOF1};
        handles.columnnames_1(1,i) = {'DISTOF1'};
    end
    if i == 7
        d_1(count,i) = {handles.SS.CurrentSources.elementList(x).DISTOF2};
        handles.columnnames_1(1,i) = {'DISTOF2'};
    end
    if i == 8
        d_1(count,i) = {handles.SS.CurrentSources.elementList(x).DISTOF3};
        handles.columnnames_1(1,i) = {'DISTOF3'};
    end
    if i == 9
        d_1(count,i) = {handles.SS.CurrentSources.elementList(x).of1Mag};
         handles.columnnames_1(1,i) = {'Of1Mag'};
    end
    if i == 10
        d_1(count,i) = {handles.SS.CurrentSources.elementList(x).of1Phase};
        handles.columnnames_1(1,i) = {'Of1Phase'};
    end
    if i == 11
        d_1(count,i) = {handles.SS.CurrentSources.elementList(x).of2Mag};
        handles.columnnames_1(1,i) = {'Of2Mag'};        
    end
    if i == 12
        d_1(count,i) = {handles.SS.CurrentSources.elementList(x).of2Phase};
        handles.columnnames_1(1,i) = {'Of2Phase'}; 
    end
    if i == 13
        d_1(count,i) = {handles.SS.CurrentSources.elementList(x).of3Mag};
        handles.columnnames_1(1,i) = {'Of3Mag'}; 
    end
    if i == 14
        d_1(count,i) = {handles.SS.CurrentSources.elementList(x).of3Phase};
        handles.columnnames_1(1,i) = {'of3Phase'}; 
    end
    if i == 15
        d_1(count,i) = {handles.SS.CurrentSources.elementList(x).tran};
        handles.columnnames_1(1,i) = {'Tran'};
        d_1(count,i) = {class(handles.SS.CurrentSources.elementList(1).tranInput)};
        handles.columnnames_1(1,i) = {'Trantype'};
    end
%     
end   
end
end
end
set(handles.cirEleValTable, 'data', d_1, 'RowName',handles.rownames_1, 'ColumnName', handles.columnnames_1);
guidata(hObject,handles);

% Hints: contents = cellstr(get(hObject,'String')) returns selectTablePopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selectTablePopup

function selectTablePopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AanlysisMe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in selectTablePopup.


% --- Executes on button press in PlotButton.
function PlotButton_Callback(hObject, eventdata, handles)
% hObject    handle to PlotButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
try
v2 = get(handles.Nodepop,'Value');
% fh = figure;
% eh = uicontrol('Style','edit','String',num2str(v2));
h = waitbar(0,'Initializing ...');
waitbar(0.5,h,'Halfway there...');
hold on;
f = figure;
plot(handles.t1,handles.y1(:,v2));
perc = 75;
waitbar(perc/100,h,sprintf('%d%% along...',perc));
title('LinearTransientZeroICdae23t');
xlabel('time'); % x-axis label
ylabel('Voltage');
str = string(handles.SS.nodeSpace.NodeList(v2-1));
close(h);
legend(str);
hold off;
guidata(hObject,handles);
catch ME
    message = sprintf('Error in LoadFile():\n%s', ME.message);
	uiwait(warndlg(message));
end
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in Nodepop.
function Nodepop_Callback(hObject, eventdata, handles)
% hObject    handle to Nodepop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Nodepop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Nodepop


% --- Executes during object creation, after setting all properties.
function Nodepop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Nodepop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Rewrite.
function Rewrite_Callback(hObject, eventdata, handles)
% hObject    handle to Rewrite (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% try
try
h = waitbar(0,'Initializing ...');
tableData_Value = get(handles.cirEleValTable, 'data');
tableData_Value = tableData_Value';
for x = 1 : size(handles.rownames_1',2)
    v = get(handles.selectTablePopup,'Value'); %get currently selected option from menu
    if v == 2 %if linear circuit element is selected
        if x <= size(handles.SS.Resistors.elementList,2)
           handles.SS.Resistors.elementList(x).value = str2double(tableData_Value(x,1));
        elseif x <= (size(handles.SS.Resistors.elementList,2) + size(handles.SS.Capacitors.elementList,2))
           handles.SS.Capacitors.elementList(x - size(handles.SS.Resistors.elementList,2)).value = str2double(tableData_Value(x,1));
        end
    end
end
perc = 75;
waitbar(0.5,h,'Halfway there...');
waitbar(perc/100,h,sprintf('%d%% along...',perc));
v = get(handles.AanlysisMe,'Value'); %get currently selected option from menu
if v == 2
   handles.SS.MNA.formMNA;
   tic;  [handles.t1,handles.y1] = handles.SS.MNA.linearTransientZeroICdae23t(handles.tmax, [1 2  3]);toc
end
close(h);
catch ME
message = sprintf('Error in Rewrite():\n%s', ME.message);
uiwait(warndlg(message));
end
guidata(hObject,handles);
% catch ME
%     message = sprintf('Error in Rewrite():\n%s', ME.message);
% 	uiwait(warndlg(message));
% end



% --- Executes on button press in Loadbox.
function Loadbox_Callback(hObject, eventdata, handles)
% hObject    handle to Loadbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Loadbox


% --- Executes on button press in Savebox.
function Savebox_Callback(hObject, eventdata, handles)
% hObject    handle to Savebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Savebox



function Tmax_Callback(hObject, eventdata, handles)
% hObject    handle to Tmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Tmax as text
%        str2double(get(hObject,'String')) returns contents of Tmax as a double


% --- Executes during object creation, after setting all properties.
function Tmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Tmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Analysisbutton.
function Analysisbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Analysisbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
v = get(handles.AanlysisMe,'Value'); %get currently selected option from menu
h = waitbar(0,'Initializing ...');
handles.tmax = str2num(char(get(handles.Tmax,'String')));
if v == 2
   tic;  [handles.t1,handles.y1] = handles.SS.MNA.linearTransientZeroICdae23t(handles.tmax, [1 2  3]);toc
   perc = 75;
   waitbar(0.5,h,'Halfway there...');
   waitbar(perc/100,h,sprintf('%d%% along...',perc));
end
close(h);
guidata(hObject,handles);


% --- Executes on button press in ChangeTransinput.
function ChangeTransinput_Callback(hObject, eventdata, handles)
% hObject    handle to ChangeTransinput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
h = waitbar(0,'Initializing ...');
handles.f = figure('NumberTitle', 'off', 'Name', 'Trans Info');
d_2 = {};
handles.rownames_2 = {};
handles.columnnames_2 = {};
v_new = get(handles.ChangeTransinput,'Value'); %get currently selected option from menu
% x = get(handles.selectTablePopup,'String');
% fh = figure;
% eh = uicontrol('Style','edit','String',num2str(v_new));
% eh = uicontrol('Style','edit','String',x);
if v_new <= size(handles.SS.VoltageSources.elementList,2) + 1
    handles.rownames_2(1,1) = {handles.SS.VoltageSources.elementList(v_new - 1).name};
   if string(class(handles.SS.VoltageSources.elementList(v_new - 1).tranInput)) == 'tranSin'
        for i = 1:4
            if i == 1
                handles.colnames_2(1,i) = {'VO'};
%                 d_2(1,i) = {handles.SS.VoltageSources.elementList(v_new - 1).tranInput.VO};
            end
            if i == 2
                handles.colnames_2(1,i) = {'VA'};
%                 d_2(1,i) = {handles.SS.VoltageSources.elementList(v_new - 1).tranInput.VA};
            end
            if i == 3
                handles.colnames_2(1,i) = {'W'};
%                 d_2(1,i) = {handles.SS.VoltageSources.elementList(v_new - 1).tranInput.W};
            end
            if i == 4
                handles.colnames_2(1,i) = {'TD'};
%                 d_2(1,i) = {handles.SS.VoltageSources.elementList(v_new - 1).tranInput.TD};
            end
        end
    end
    if string(class(handles.SS.VoltageSources.elementList(v_new - 1).tranInput)) == 'tranPWL'
        for i = 1:5
            if i == 1
                handles.colnames_2(1,i) = {'x'};
%                 d_2(1,i) = {handles.SS.VoltageSources.elementList(v_new - 1).tranInput.x};
            end
            if i == 2
                handles.colnames_2(1,i) = {'y'};
%                 d_2(1,i) = {handles.SS.VoltageSources.elementList(v_new - 1).tranInput.y};
            end
            if i == 3
                handles.colnames_2(1,i) = {'Vf'};
                d_2(1,i) = {handles.SS.VoltageSources.elementList(v_new - 1).tranInput.Vf};
            end
            if i == 4
                handles.colnames_2(1,i) = {'xs'};
                d_2(1,i) = {handles.SS.VoltageSources.elementList(v_new - 1).tranInput.xs};
            end
            if i == 5
                handles.colnames_2(1,i) = {'ys'};
                d_2(1,i) = {handles.SS.VoltageSources.elementList(v_new - 1).tranInput.ys};
            end
        end
    end
    if string(class(handles.SS.VoltageSources.elementList(v_new - 1).tranInput)) == 'tranPulse'
        for i = 1:7
            if i == 1
                handles.colnames_2(1,i) = {'x'};
%                 d_2(1,i) = {handles.SS.VoltageSources.elementList(v_new - 1).tranInput.x};
            end
            if i == 2
                handles.colnames_2(1,i) = {'y'};
%                 d_2(1,i) = {handles.SS.VoltageSources.elementList(v_new - 1).tranInput.y};
            end
            if i == 3
                handles.colnames_2(1,i) = {'Vf'};
                d_2(1,i) = {handles.SS.VoltageSources.elementList(v_new - 1).tranInput.Vf};
            end
            if i == 4
                handles.colnames_2(1,i) = {'PER'};
                d_2(1,i) = {handles.SS.VoltageSources.elementList(v_new - 1).tranInput.PER};
            end
            if i == 5
                handles.colnames_2(1,i) = {'TD'};
                d_2(1,i) = {handles.SS.VoltageSources.elementList(v_new - 1).tranInput.TD};
            end
            if i == 6
                handles.colnames_2(1,i) = {'xs'};
%                 d_2(1,i) = {handles.SS.VoltageSources.elementList(v_new - 1).tranInput.xs};
            end
            if i == 7
                handles.colnames_2(1,i) = {'ys'};
%                 d_2(1,i) = {handles.SS.VoltageSources.elementList(v_new - 1).tranInput.ys};
            end
        end
    end
    if string(class(handles.SS.VoltageSources.elementList(v_new - 1).tranInput)) == 'tranExpSin'
        for i = 1:6
            if i == 1
                handles.colnames_2(1,i) = {'VO'};
                d_2(1,i) = {handles.SS.VoltageSources.elementList(v_new - 1).tranInput.VO};
            end
            if i == 2
                handles.colnames_2(1,i) = {'VA'};
                d_2(1,i) = {handles.SS.VoltageSources.elementList(v_new - 1).tranInput.VA};
            end
            if i == 3
                handles.colnames_2(1,i) = {'W'};
                d_2(1,i) = {handles.SS.VoltageSources.elementList(v_new - 1).tranInput.W};
            end
            if i == 4
                handles.colnames_2(1,i) = {'TD'};
                d_2(1,i) = {handles.SS.VoltageSources.elementList(v_new - 1).tranInput.TD};
            end
            if i == 5
                handles.colnames_2(1,i) = {'THETA'};
                d_2(1,i) = {handles.SS.VoltageSources.elementList(v_new - 1).tranInput.THETA};
            end
            if i == 6
                handles.colnames_2(1,i) = {'symF'};
                d_2(1,i) = {handles.SS.VoltageSources.elementList(v_new - 1).tranInput.symF};
            end
        end
    end
else
    
end
perc = 75;
waitbar(0.5,h,'Halfway there...');
handles.t = uitable(handles.f, 'Position',[150 150 260 204]);
set(handles.t, 'data', d_2, 'RowName',handles.rownames_2, 'ColumnName', handles.colnames_2);
% Auto-resize:
reformatTable(handles.t,handles.f);
waitbar(perc/100,h,sprintf('%d%% along...',perc));
close(h);
catch ME
message = sprintf('Error in Rewrite():\n%s', ME.message);
uiwait(warndlg(message));
end
guidata(hObject,handles);

function reformatTable(hTable,fig)
% Examples:
%    reformatTable with no input argument formats the current axes with focus.
%    reformatTable(axisHandle) formats Figure specified as input handle
if nargin == 0
      fig = gcf;
      hTable = get(gcf,'children');
      warning(['No input arguments specified to REFORMATTABLE. Formatting Figure ',num2str(gcf),' by default.']); 
end
try
      hTableExtent = get(hTable,'Extent');
      hTablePosition = get(hTable,'Position');
      set(hTable,'Position',[20 20 round(1.5*hTableExtent(3)) round(1.5*hTableExtent(4))]);
      set(fig,'position',[200 200 round(2*hTableExtent(3)) round(2*hTableExtent(4))]);
catch ME
      error('FIGURE with UITABLE not open or in focus. Please ensure UITABLE is created');
end