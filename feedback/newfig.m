function varargout = newfig(varargin)
% NEWFIG MATLAB code for newfig.fig
%      NEWFIG, by itself, creates a new NEWFIG or raises the existing
%      singleton*.
%
%      H = NEWFIG returns the handle to a new NEWFIG or the handle to
%      the existing singleton*.
%
%      NEWFIG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NEWFIG.M with the given input arguments.
%
%      NEWFIG('Property','Value',...) creates a new NEWFIG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before newfig_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to newfig_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help newfig

% Last Modified by GUIDE v2.5 16-Feb-2026 19:22:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @newfig_OpeningFcn, ...
    'gui_OutputFcn',  @newfig_OutputFcn, ...
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

% --- Executes just before newfig is made visible.
function newfig_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to newfig (see VARARGIN)

% Choose default command line output for newfig
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes newfig wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = newfig_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% if we enabled the stream, assume that we're in live mode
live_mode = handles.stream.Value;

if live_mode

    % Program options
    HostName = 'localhost:801';

    % Make a new client
    MyClient = Client();

    while ~MyClient.IsConnected().Connected
        % Direct connection
        MyClient.Connect( HostName );
    end

    MyClient.EnableDeviceData(); % Enable ForcePlate/EMG... and other analog device data in the Vicon DataStream.
    MyClient.SetStreamMode( StreamMode.ClientPull );
else
    
    MyClient = [];
end

% Display and Save stuff
DispAndSave(hObject, eventdata, handles, MyClient);

if live_mode
    while MyClient.IsConnected().Connected
        MyClient.Disconnect();
        fprintf( '.' );
    end
end

clear MyClient;

function [] = DispAndSave(hObject, eventdata, handles, MyClient)

% if we enabled the stream, assume that we're in live mode
live_mode = handles.stream.Value;

cla
stop_time       = str2double(handles.stop_time.String);

% target rectangle
rectangle(handles.axes1, 'Position', [str2double(handles.xmin.String)                                           str2double(handles.ymax.String) * str2double(handles.target_min.String)/100 ...
                                      str2double(handles.stop_time.String) - str2double(handles.xmin.String)    str2double(handles.ymax.String) * (str2double(handles.target_max.String)-str2double(handles.target_min.String))/100], ...
                                      'Facecolor', [.8 1 .8], 'Edgecolor', 'none');

% define a line in the plot
h = line(handles.axes1, 'xdata', 0, 'ydata', 0, 'color', [.8 .8 .8]);
g = line(handles.axes1, 'xdata', 0, 'ydata', 0, 'color', 'red', 'linewidth', 2);
m = line(handles.axes1, 'xdata', 0, 'ydata', 0, 'color', 'blue', 'marker', 'o', 'markerfacecolor', 'blue');

handles.axes1.YLim = [str2double(handles.ymin.String) str2double(handles.ymax.String)];
handles.axes1.XLim = [str2double(handles.xmin.String) str2double(handles.xmax.String)];

grid on
box off

% determine channels
if strcmp(handles.feedback_type.String{handles.feedback_type.Value}, 'EMG versus angle')
    imax = 2; % two channels
    devices = {'Biodex', 'Mini wave EMG'};
    output_names = {'Angle', handles.channel_number.String};
    
    % in testing mode
    t = 0:(1/100):100;
    x = [.5*cos(t) + .5; .5*sin(t) + .5 + .1 * randn(size(t)) + 1];
    
    xlabel('Angle')
    ylabel('EMG')
    
elseif strcmp(handles.feedback_type.String{handles.feedback_type.Value}, 'EMG versus time')
    imax = 1; % one channel
    devices = {'Mini wave EMG'};
    output_names = {handles.channel_number.String};
    
    % in testing mode
    t = 0:(1/100):100;
    x = .5*sin(t) + .5 + .1 * randn(size(t)) + 1;
    
    xlabel('Time (s)')
    ylabel('EMG')
    
elseif strcmp(handles.feedback_type.String{handles.feedback_type.Value}, 'Angle versus time')
    imax = 1; % one channel
    devices = {'Biodex'};
    output_names = {'Angle'};
    
    % in testing mode
    t = 0:(1/100):100;
    x = .5*sin(t) + .5 + .1 * randn(size(t)) + 1;
    
    xlabel('Time (s)')
    ylabel('Angle')
    
elseif strcmp(handles.feedback_type.String{handles.feedback_type.Value}, 'Torque versus time')
    imax = 1; % one channel
    devices = {'Biodex'};
    output_names = {'Torque'};
    
    % in testing mode
    t = 0:(1/100):100;
    x = .5*sin(t) + .5 + .1 * randn(size(t)) + 1;
    
    xlabel('Time (s)')
    ylabel('Torque')
end

% pre-allocate 
M = stop_time * 100;
all_values  = nan(M,imax);
plot_values = nan(M,imax);
time        = nan(M,1);

% continue until we pas the stop_time
tic;
sample_time = 0;
k = 0;

while sample_time < stop_time
    
    k = k+1;
    
    if live_mode
    
        % Get a frame
        while MyClient.GetFrame().Result.Value ~= Result.Success
        end

        % Get the number of subsamples associated with this device.
        % The system runs at 100Hz, but some analog devices work at eg 1000Hz.
        Output_GetDeviceOutputName          = MyClient.GetDeviceOutputName('Biodex', str2double(handles.channel_number.String));
        Output_GetDeviceOutputSubsamples    = MyClient.GetDeviceOutputSubsamples('Biodex', Output_GetDeviceOutputName.DeviceOutputName );
    else    
        Output_GetDeviceOutputSubsamples.DeviceOutputSubsamples = 5;
    end
    
    if Output_GetDeviceOutputSubsamples.DeviceOutputSubsamples > 0
  
        for i = 1:imax % loop over channels
            DeviceName = devices{i};
            Output_GetDeviceOutputName.DeviceOutputName = output_names{i};            
           
            values = nan(1, Output_GetDeviceOutputSubsamples.DeviceOutputSubsamples);
            for DeviceOutputSubsample = 1:Output_GetDeviceOutputSubsamples.DeviceOutputSubsamples
                
                if live_mode
                    % Get the device output value
                    values(DeviceOutputSubsample) = MyClient.GetDeviceOutputValue(DeviceName, Output_GetDeviceOutputName.DeviceOutputName, DeviceOutputSubsample).Value;

                else % testing mode
                    values(DeviceOutputSubsample) = x(i,k);
                end
            end
            
            % only do scaling and offset for the vertical axis
            if i == imax
                scale_fac   = str2double(handles.scale_factor.String);
                offset      = str2double(handles.baseline.String);
            else
                scale_fac   = 1;
                offset      = 0;
            end

            % take average over subsamples
            all_values(k,i) = (mean(values) - offset) * scale_fac;
            
            % optionally filter
            if handles.do_filter.Value
                plot_values(1:k,i) = movmean(abs(all_values(1:k,i)), [str2double(handles.filter_samps.String) 0]);
            else
                plot_values(1:k,i) = all_values(1:k,i);
            end
        end

        % check the current time
        if live_mode
            sample_time = toc;
        else
            sample_time = t(k);
        end
        
        time(k,1) = sample_time;
        
        if handles.do_filter.Value
            time_filt = time - str2double(handles.filter_samps.String)/200;
        else
            time_filt = time;
        end
        
        if imax == 2 % if we have 2 channels, plot them against each other
            X1 = all_values(:,1);
            X2 = all_values(:,2);
            Y1 = plot_values(:,1);
            Y2 = plot_values(:,2);
        else
            X1 = time;
            X2 = all_values(:,1);
            Y1 = time_filt;
            Y2 = plot_values(:,1);
        end
            
        % plot
        N = max(k - str2double(handles.Npoints.String), 1);
        set(h, 'xdata', X1(N:end),  'ydata', X2(N:end))
        set(g, 'xdata', Y1(N:end),  'ydata', Y2(N:end))
        set(m, 'xdata', Y1(k),    'ydata', Y2(k))

        handles.axes1.XLim = [str2double(handles.xmin.String) str2double(handles.xmax.String)] + Y1(k);
        drawnow;
    end
end


disp(['max = ', num2str(max(plot_values))]);
disp(['mean = ', num2str(mean(plot_values, 'omitnan'))]);





function scale_factor_Callback(hObject, eventdata, handles)
% hObject    handle to scale_factor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scale_factor as text
%        str2double(get(hObject,'String')) returns contents of scale_factor as a double

handles.scalefac = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function scale_factor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scale_factor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in feedback_type.
function feedback_type_Callback(hObject, eventdata, handles)
% hObject    handle to feedback_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns feedback_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from feedback_type


% --- Executes during object creation, after setting all properties.
function feedback_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to feedback_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function channel_number_Callback(hObject, eventdata, handles)
% hObject    handle to channel_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of channel_number as text
%        str2double(get(hObject,'String')) returns contents of channel_number as a double


% --- Executes during object creation, after setting all properties.
function channel_number_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stop_time_Callback(hObject, eventdata, handles)
% hObject    handle to stop_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stop_time as text
%        str2double(get(hObject,'String')) returns contents of stop_time as a double


% --- Executes during object creation, after setting all properties.
function stop_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stop_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in do_filter.
function do_filter_Callback(hObject, eventdata, handles)
% hObject    handle to do_filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of do_filter


function filter_samps_Callback(hObject, eventdata, handles)
% hObject    handle to filter_samps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filter_samps as text
%        str2double(get(hObject,'String')) returns contents of filter_samps as a double


% --- Executes during object creation, after setting all properties.
function filter_samps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filter_samps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function baseline_Callback(hObject, eventdata, handles)
% hObject    handle to baseline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of baseline as text
%        str2double(get(hObject,'String')) returns contents of baseline as a double


% --- Executes during object creation, after setting all properties.
function baseline_CreateFcn(hObject, eventdata, handles)
% hObject    handle to baseline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in stream.
function stream_Callback(hObject, eventdata, handles)
% hObject    handle to stream (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of stream

Client.LoadViconDataStreamSDK();


function xmin_Callback(hObject, eventdata, handles)
% hObject    handle to xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xmin as text
%        str2double(get(hObject,'String')) returns contents of xmin as a double

handles.axes1.YLim = [str2double(handles.ymin.String) str2double(handles.ymax.String)];
handles.axes1.XLim = [str2double(handles.xmin.String) str2double(handles.xmax.String)];

% --- Executes during object creation, after setting all properties.
function xmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function xmax_Callback(hObject, eventdata, handles)
% hObject    handle to xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xmax as text
%        str2double(get(hObject,'String')) returns contents of xmax as a double

handles.axes1.YLim = [str2double(handles.ymin.String) str2double(handles.ymax.String)];
handles.axes1.XLim = [str2double(handles.xmin.String) str2double(handles.xmax.String)];


% --- Executes during object creation, after setting all properties.
function xmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ymin_Callback(hObject, eventdata, handles)
% hObject    handle to ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ymin as text
%        str2double(get(hObject,'String')) returns contents of ymin as a double

handles.axes1.YLim = [str2double(handles.ymin.String) str2double(handles.ymax.String)];
handles.axes1.XLim = [str2double(handles.xmin.String) str2double(handles.xmax.String)];

% --- Executes during object creation, after setting all properties.
function ymin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ymax_Callback(hObject, eventdata, handles)
% hObject    handle to ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ymax as text
%        str2double(get(hObject,'String')) returns contents of ymax as a double

handles.axes1.YLim = [str2double(handles.ymin.String) str2double(handles.ymax.String)];
handles.axes1.XLim = [str2double(handles.xmin.String) str2double(handles.xmax.String)];

rectangle(handles.axes1, 'Position', [str2double(handles.xmin.String)                                   str2double(handles.ymax.String) * str2double(handles.target_min.String)/100 ...
                                      str2double(handles.xmax.String) - str2double(handles.xmin.String) str2double(handles.ymax.String) * (str2double(handles.target_max.String)-str2double(handles.target_min.String))/100], ...
                                      'Facecolor', [.8 1 .8], 'Edgecolor', 'none');

% --- Executes during object creation, after setting all properties.
function ymax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.ylim = str2double(get(hObject,'String'));



function target_min_Callback(hObject, eventdata, handles)
% hObject    handle to target_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of target_min as text
%        str2double(get(hObject,'String')) returns contents of target_min as a double

rectangle(handles.axes1, 'Position', [str2double(handles.xmin.String)                                   str2double(handles.ymax.String) * str2double(handles.target_min.String)/100 ...
                                      str2double(handles.xmax.String) - str2double(handles.xmin.String) str2double(handles.ymax.String) * (str2double(handles.target_max.String)-str2double(handles.target_min.String))/100], ...
                                      'Facecolor', [.8 1 .8], 'Edgecolor', 'none');

% --- Executes during object creation, after setting all properties.
function target_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to target_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function target_max_Callback(hObject, eventdata, handles)
% hObject    handle to target_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of target_max as text
%        str2double(get(hObject,'String')) returns contents of target_max as a double

rectangle(handles.axes1, 'Position', [str2double(handles.xmin.String)                                   str2double(handles.ymax.String) * str2double(handles.target_min.String)/100 ...
                                      str2double(handles.xmax.String) - str2double(handles.xmin.String) str2double(handles.ymax.String) * (str2double(handles.target_max.String)-str2double(handles.target_min.String))/100], ...
                                      'Facecolor', [.8 1 .8], 'Edgecolor', 'none');

% --- Executes during object creation, after setting all properties.
function target_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to target_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Npoints_Callback(hObject, eventdata, handles)
% hObject    handle to Npoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Npoints as text
%        str2double(get(hObject,'String')) returns contents of Npoints as a double


% --- Executes during object creation, after setting all properties.
function Npoints_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Npoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
