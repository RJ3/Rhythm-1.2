
function rhythm
close all; clc;
%% RHYTHM 1.2 (28/4/2018)
% Matlab software for analyzing optical mapping data
%
% Previous version by Matt Sulkin, Jake Laughner, Xinyuan Sophia Cui, Jed Jackoway
% Washington University in St. Louis -- Efimov Lab
%
% GUI functional and current version by: Roman Syunyaev, Roman Pryamonosov, and Alexander
% Zolotarev.
%
% For any questions and suggestions, please email us at:
% cgloschat@gmail.com or igor@wustl.edu
%
% Modification Log:
% 
% 2018 -- GUI was strongly refactored since Rhythm 1.1 by Roman Pryamonosov, Roman
% Syunyaev and Alexander Zolotarev. New features: multi view for signal
% data (icluding zooming), multi view for signal waves data, movie screen 
% synchronization. All data processing are in one popup menu. New
% functional can be written with minimal interaction (see user guide).
handles = rhythmHandles;
try
    editor_service = com.mathworks.mlservices.MLEditorServices;
    editor_app = editor_service.getEditorApplication;
    active_editor = editor_app.getActiveEditor;
    storage_location = active_editor.getStorageLocation;
    file = char(storage_location.getFile);
    handles.projectDir = fileparts(file);
    cd (handles.projectDir)
catch
    handles.projectDir = uigetdir('Select Project Directory');
end

%% Create GUI structure
scrn_size = get(0,'ScreenSize');
f = figure('Name','RHYTHM','Visible','off','Position',[scrn_size(3),scrn_size(4),1250,850],'NumberTitle','Off');
handles.cmap = colormap('Jet'); 

% Load Data
p1 = uipanel('Title','Display Data','FontSize',12,'Position',[.01 .01 .98 .98]);
filelist = uicontrol('Parent',p1,'Style','listbox','String','Files','Position',[10 660 150 150],'Callback',{@filelist_callback});
selectdir = uicontrol('Parent',p1,'Style','pushbutton','FontSize',12,'String','Select Directory','Position',[10 650 150 30],'Callback',{@selectdir_callback});
loadfile = uicontrol('Parent',p1,'Style','pushbutton','FontSize',12,'String','Load','Position',[10 620 150 30],'Callback',{@loadfile_callback});

% Movie Screens for Optical Data
movieScreen1 = axes('Parent',p1,'Units','Pixels','YTick',[],'XTick',[],...
                   'Units','normalized','Position',[0.14, 0.6, 0.25, 0.4],...
                   'color', 'black','box','on', 'linewidth',2, ...
                   'CameraUpVector',[0,1,1], 'YDir','reverse');
movieScreen2 = axes('Parent',p1,'Units','Pixels','YTick',[],'XTick',[],...
                   'Units','normalized','Position',[0.4, 0.6, 0.25, 0.4],...
                   'color', 'black','box','on', 'linewidth',2,...
                   'CameraUpVector',[0,1,1], 'YDir','reverse');
movieScreen3 = axes('Parent',p1,'Units','Pixels','YTick',[],'XTick',[],...
                   'Units','normalized','Position',[0.14, 0.18, 0.25, 0.4],...
                   'color', 'black','box','on', 'linewidth',2,...
                   'CameraUpVector',[0,1,1], 'YDir','reverse');
movieScreen4 = axes('Parent',p1,'Units','Pixels','YTick',[],'XTick',[],...
                   'Units','normalized','Position',[0.4, 0.18, 0.25, 0.4],...
                   'color', 'black','box','on', 'linewidth',2,...
                   'CameraUpVector',[0,1,1], 'YDir','reverse');

camHandles1 = cameraData;
camHandles2 = cameraData;
camHandles3 = cameraData;
camHandles4 = cameraData;
camHandles1.screen = movieScreen1;
camHandles2.screen = movieScreen2;
camHandles3.screen = movieScreen3;
camHandles4.screen = movieScreen4;

camHandles1.screenPos = [0.14, 0.6, 0.25, 0.4];
camHandles2.screenPos = [0.4, 0.6, 0.25, 0.4];
camHandles3.screenPos = [0.14, 0.18, 0.25, 0.4];
camHandles4.screenPos = [0.4, 0.18, 0.25, 0.4];


handles.allCamData = [camHandles1 camHandles2 camHandles3 camHandles4];

handles.activeCamData = camHandles1;
handles.activeScreen = movieScreen1;
handles.activeScreenNo = 1;
handles.activeScreen.XColor = 'red';
handles.activeScreen.YColor = 'red';
    
% Movie Slider for Controling Current Frame
movie_slider = uicontrol('Parent',f, 'Style', 'slider', 'Units','normalized',...
                         'Position',[0.15, 0.16, 0.5, 0.02],...
                         'SliderStep',[.001 .01],...
                         'Callback',{@movieslider_callback});
addlistener(movie_slider,'ContinuousValueChange',@movieslider_callback);

% Mouse Listening Function
set(f,'WindowButtonDownFcn',{@button_down_function});
set(f,'WindowButtonUpFcn',{@button_up_function});
set(f,'WindowButtonMotionFcn',{@button_motion_function});

% Signal Display Screens for Optical Action Potentials
% signal_scrn1 = axes('Parent',p1,'Color','w','XTick',[],'Position',[0.55 0.7 0.25 0.2]);
signal_scrn1 = axes('Parent',p1,'Units','Pixels','Color','w','XTick',[],'Position',[860, 695,350,115]);
signal_scrn2 = axes('Parent',p1,'Units','Pixels','Color','w','XTick',[],'Position',[860, 570,350,115]);
signal_scrn3 = axes('Parent',p1,'Units','Pixels','Color','w','XTick',[],'Position',[860, 445,350,115]);
signal_scrn4 = axes('Parent',p1,'Units','Pixels','Color','w','XTick',[],'Position',[860, 320,350,115]);
signal_scrn5 = axes('Parent',p1,'Units','Pixels','Color','w','Position',[860, 195,350,115]);
handles.signalScreens = [signal_scrn1, signal_scrn2, signal_scrn3,...
                         signal_scrn4, signal_scrn5];
xlabel('Time (sec)');

expwave_button = uicontrol('Parent',p1,'Style','pushbutton','FontSize',12,...
                            'String','Export OAPs','Units','normalized','Position',[0.9 0.14 0.08 0.04],...
                            'Callback',{@expwave_button_callback});
exptofile_button = uicontrol('Parent',p1,'Style','pushbutton','FontSize',12,...
                            'String','Export to file','Units','normalized','Position',[0.9 0.10 0.08 0.04],...
                            'Callback',{@exptofile_button_callback});
starttimemap_text = uicontrol('Parent',p1,'Style','text','FontSize',10,...
                            'String','Start Time','Units','normalized','Position',[0.68 0.14 0.07 0.04]);
starttimemap_edit = uicontrol('Parent',p1,'Style','edit','FontSize',14,...
                            'Units','normalized','Position',[0.75 0.14 0.05 0.04],...
                            'Callback',{@starttime_edit_callback});
endtimemap_text = uicontrol('Parent',p1,'Style','text','FontSize',10,...
                            'String','End Time','Units','normalized','Position',[0.8 0.14 0.05 0.04]);
endtimemap_edit = uicontrol('Parent',p1,'Style','edit','FontSize',14,...
                            'Units','normalized','Position',[0.85 0.14 0.05 0.04],...
                            'Callback',{@endtime_edit_callback});

% Sweep Bar Display for Optical Action Potentials
sweep_bar = axes ('Parent',p1,'Units','Pixels','Layer','top','Position',[860,195,350,625]);
set(sweep_bar,'NextPlot','replacechildren','Visible','off')
handles.sweepBar = sweep_bar;

% Video Control Buttons and Optical Action Potential Display
play_button = uicontrol('Parent',p1,'Style','pushbutton','FontSize',10,...
                        'String','Play Movie','Units','normalized',...
                        'Position',[0.23, 0.12, 0.08, 0.04],...
                        'Callback',{@play_button_callback});
stop_button = uicontrol('Parent',p1,'Style','pushbutton','FontSize',10,...
                        'String','Stop Movie','Units','normalized',...
                        'Position',[0.31, 0.12, 0.08, 0.04]...
                        ,'Callback',{@stop_button_callback});
dispwave_button = uicontrol('Parent',p1,'Style','pushbutton','FontSize',10,...
                        'String','Display Wave','Units','normalized',...
                        'Position',[0.4, 0.12, 0.08, 0.04],...
                        'Callback',{@dispwave_button_callback});
expmov_button = uicontrol('Parent',p1,'Style','pushbutton','FontSize',10,...
                         'String','Export Movie','Units','normalized',...
                         'Position',[0.48, 0.12, 0.08, 0.04],...
                         'Callback',{@expmov_button_callback});
%% Statistical Results
%create button group- will display results for both voltage and calcium
results = uibuttongroup('Parent',p1,'Title','Statistics','FontSize',10,'Units','normalized','Position',[0.01 0.01 .95 0.09]);

handles.meanresults = uicontrol('Parent',results,'Style','text','FontSize',10,'String','Mean:','Units','normalized',...
    'Position',[0.01 0.01 .13 0.9],'HorizontalAlignment','Left','Visible','on');
handles.medianresults = uicontrol('Parent',results,'Style','text','FontSize',10,'String','Median:','Units','normalized',...
    'Position',[0.15 0.01 .13 .9],'HorizontalAlignment','Left','Visible','on');
handles.SDresults = uicontrol('Parent',results,'Style','text','FontSize',10,'String','S.D.:','Units','normalized',...
    'Position',[0.3 0.01 .13 .9],'HorizontalAlignment','Left','Visible','on');
handles.num_members_results = uicontrol('Parent',results,'Style','text','FontSize',10,'String','#Members:','Units','normalized',...
    'Position',[0.45 0.01 .13 .9],'HorizontalAlignment','Left','Visible','on');
handles.angleresults = uicontrol('Parent',results,'Style','text','FontSize',10,'String','Angle:','Units','normalized',...
    'Position',[0.6 0.01 .13 .9],'HorizontalAlignment','Left','Visible','on');
%Tau=uicontrol('Parent',results,'Style','text','FontSize',10,'String','Tau:','Units','normalized',...
%    'Position',[0.75 0.01 .13 .9],'HorizontalAlignment','Left','Visible','on');

          set(handles.meanresults,'String',handles.activeCamData.meanresults);
          set(handles.medianresults,'String',handles.activeCamData.medianresults);
          set(handles.SDresults,'String',handles.activeCamData.SDresults);
          set(handles.num_members_results,'String',handles.activeCamData.num_membersresults);
          set(handles.angleresults,'String',handles.activeCamData.angleresults);
          %set(Tau,'String',handles.activeCamData.Tau);
          
%% Optical Action Potential Analysis Button Group and Buttons
% Create Button Group
anal_data = uibuttongroup('Parent',p1,'Title','Analyze Data','FontSize',12,'Position',[0.001 0.25 0.13 0.5]);

% Invert Color Map Option
invert_cmap = uicontrol('Parent',anal_data,'Style','checkbox','FontSize',10,'String','Invert Colormaps','Position',[3 350 140 25],'Callback',{@invert_cmap_callback});

map = uibuttongroup('Parent',anal_data,'Title','Parameters', 'FontSize',12,'Position',[0.001 0.001 .98 .8]);

map_popup = uicontrol('Parent',anal_data,'Style','popupmenu','FontSize',10,...
                       'String',{'Condition Parameters','CV map', 'Activation map', 'APD\CaT map', 'Rise Time', 'Calcium Decay'},...
                       'Position',[3 320 140 25], 'Callback',{@mapPopUp_callback});

set(map_popup,'Value',1);
set(map_popup,'Enable','off')

GUI_conditionParameters(map, handles); %Make signal condition default
% syncBox = uicontrol('Parent',p1,'Style','checkbox','FontSize',10,...
%     'String','ScreenSync','Units','normalized','Position',[0.9 0 0.1 0.1],...
%     'Callback',{@syncBox_callback});

sync12 = uicontrol('Parent',p1,'Style','checkbox','Units','normalized','Position',[0.39 0.79 0.01 0.02],'Callback',{@sync_callback});
sync13 = uicontrol('Parent',p1,'Style','checkbox','Units','normalized','Position',[0.26 0.58 0.01 0.02],'Callback',{@sync_callback});
sync24 = uicontrol('Parent',p1,'Style','checkbox','Units','normalized','Position',[0.52 0.58 0.01 0.02],'Callback',{@sync_callback});
sync34 = uicontrol('Parent',p1,'Style','checkbox','Units','normalized','Position',[0.39 0.38 0.01 0.02],'Callback',{@sync_callback});


signalPanel = uipanel('Parent',p1,'Units','normalized','Position',[0.66 0.2 0.325 0.8], 'Visible','off');
auxSignalPanel = uipanel('Parent',signalPanel,'Units','normalized','Position',[0 -3 1 4]);
signalGroup = [signalPanelHandles, signalPanelHandles,...
               signalPanelHandles,signalPanelHandles,signalPanelHandles];

for ii=1:5
    signalGroup(ii).panel = uipanel('Title',strcat('Marker ',int2str(ii)),'Parent',auxSignalPanel, ...
        'Units','normalized','Position',[0, 1-0.2*ii, 1, 0.2], 'Visible','on');
end 

% create four signal axes for each signal group
for i_panel = 1:5
    signalGroup(i_panel).signalScreen = [axes('Parent',signalGroup(i_panel).panel,'Units','normalized','Color','w','Position',[0.13, 1.0-0.25*1, 0.85, 0.2]),...
                                         axes('Parent',signalGroup(i_panel).panel,'Units','normalized','Color','w','Position',[0.13, 1.0-0.25*2, 0.85, 0.2]),...
                                         axes('Parent',signalGroup(i_panel).panel,'Units','normalized','Color','w','Position',[0.13, 1.0-0.25*3, 0.85, 0.2]),...
                                         axes('Parent',signalGroup(i_panel).panel,'Units','normalized','Color','w','Position',[0.13, 1.0-0.25*4, 0.85, 0.2])];
    for i_scrn=1:4
        str = strcat('scrn ',num2str(i_scrn));
        ylabel(signalGroup(i_panel).signalScreen(i_scrn), str);
    end
    pos_tmp = get(signalGroup(i_panel).signalScreen(1),'Position');
    signalGroup(i_panel).sweepBar = axes ('Parent',signalGroup(i_panel).panel,'Units','Normalized','Layer','top','Position',[pos_tmp(1),0,pos_tmp(3),1]);
    set(signalGroup(i_panel).sweepBar ,'NextPlot','replacechildren','Visible','off');
end





handles.signalGroup = signalGroup;


signalSlider = uicontrol('Style','Slider','Parent',p1,...
      'Units','normalized','Position',[0.985 0.2 0.015 0.8],...
      'Value',1,'Callback',{@slider_callback1,auxSignalPanel}, 'Visible','off');

function sync_callback(src,eventdata,arg1)
    val12 = get(sync12,'Value');
    val13 = get(sync13,'Value');
    val24 = get(sync24,'Value');
    val34 = get(sync34,'Value');
    if (val12 && val13 && val24 && val34)   handles.bounds = [1,1,1,1]; end
    if (val12 && val13 && val24 && ~val34)  handles.bounds = [1,1,1,1]; end
    if (val12 && val13 && ~val24 && val34) handles.bounds = [1,1,1,1]; end
    if (val12 && val13 && ~val24 && ~val34) handles.bounds = [1,1,1,0]; end
    
    if (val12 && ~val13 && val24 && val34) handles.bounds = [1,1,1,1]; end
    if (val12 && ~val13 && ~val24 && val34) handles.bounds = [1,1,2,2]; end
    if (val12 && ~val13 && val24 && ~val34) handles.bounds = [1,1,0,1]; end
    if (val12 && ~val13 && ~val24 && ~val34) handles.bounds = [1,1,0,0]; end
    
    if (~val12 && val13 && val24 && val34)   handles.bounds = [1,1,1,1]; end
    if (~val12 && val13 && val24 && ~val34)  handles.bounds = [1,2,1,2]; end
    if (~val12 && val13 && ~val24 && val34) handles.bounds = [1,0,1,1]; end
    if (~val12 && val13 && ~val24 && ~val34) handles.bounds = [1,0,1,0]; end
    
    if (~val12 && ~val13 && val24 && val34) handles.bounds = [0,1,1,1]; end
    if (~val12 && ~val13 && ~val24 && val34) handles.bounds = [0,0,1,1]; end
    if (~val12 && ~val13 && val24 && ~val34) handles.bounds = [0,1,0,1]; end
    if (~val12 && ~val13 && ~val24 && ~val34) handles.bounds = [0,0,0,0]; end
    
    anyLoads = 0;
    for i_cam=1:4
        if handles.allCamData(i_cam).isloaded
            anyLoads = 1;
            break;
        end
    end
    if anyLoads
        movieslider_callback(movie_slider);
        redrawWaveScreens();
    end
end
  
function slider_callback1(src,eventdata,arg1)
    val = get(src,'Value');
    set(arg1,'Position',[0, -val*3.0, 1, 4])
end

    function visualizeWaveScreens(sync )
        if (sync)
            set([signalPanel, signalSlider], 'Visible','on');
            for i=1:5
                set(handles.signalScreens(i),'Visible','off');
            end
            % sync all screen signals and markers
            movieslider_callback(movie_slider);
        else
            % unbound all screens

            set([signalPanel, signalSlider, ], 'Visible','off');
            for i=1:5
                set(handles.signalScreens(i),'Visible','on');
            end
        end
        anyLoads = 0;
        for i_cam=1:4
            if handles.allCamData(i_cam).isloaded
                anyLoads = 1;
                break;
            end
        end
        if anyLoads
            movieslider_callback(movie_slider);
        end
    end
% function syncBox_callback(src,eventdata,arg1)
%     val = get(src, 'Value');
%     if (val)
%         set([signalPanel, signalSlider], 'Visible','on');
%         for i=1:5
%             set(handles.signalScreens(i),'Visible','off');
%         end
%         % sync all screen signals and markers
%         handles.linked = 1;
%         movieslider_callback(movie_slider);
%     else
%         % unbound all screens
% 
%         set([signalPanel, signalSlider, ], 'Visible','off');
%         for i=1:5
%             set(handles.signalScreens(i),'Visible','on');
%         end
%         handles.linked = 0;
%         movieslider_callback(movie_slider);
%     end
% end

% Allow all GUI structures to be scaled when window is dragged
set([f,p1,filelist,selectdir,loadfile,...
    movieScreen1,movieScreen2,movieScreen3,movieScreen4,movie_slider,...
    signal_scrn1,signal_scrn2,signal_scrn3,...
    signal_scrn4,signal_scrn5,...
    sweep_bar,dispwave_button,play_button,stop_button,...
    expmov_button,expwave_button,exptofile_button...
    map,anal_data,starttimemap_text,starttimemap_edit...
    endtimemap_text,endtimemap_edit,...
    invert_cmap, map_popup],'Units','normalized');

% Disable buttons that will not be needed until data is loaded
set([play_button,stop_button,dispwave_button,expmov_button,starttimemap_edit,endtimemap_edit,...
    expwave_button,exptofile_button,invert_cmap],'Enable','off')

% Center GUI on screen
movegui(f,'center')
set(f,'Visible','on')



%% Create handles
handles.filename = [];
handles.cmosData = [];
handles.rawData = [];
handles.time = [];
handles.normflag = 0;
handles.Fs = 1000; % this is the default value. it will be overwritten
handles.starttime = 0;
handles.fileLength = 1;
handles.endtime = 1;
% handles.M = []; % this handle stores the locations of the markers

% handles.slide=-1; % parameter for recognize clicking location
%%minimum values pixels require to be drawn
% handles.minVisible = 6;
% handles.normalizeMinVisible = .3;
handles.cmap = colormap('Jet'); %saves the default colormap values

%% All Callback functions

% Callback for map menu
function mapPopUp_callback(~,~)
    map = uibuttongroup('Parent',anal_data,'Title','Parameters',...
                        'FontSize',10,'Position',[0.001 0.001 .98 .8]);
    
    colormap(handles.activeScreen, jet);
    switch get(map_popup,'Value')
        case 1
            % Conduction Velocity Map
            GUI_conditionParameters(map, handles); 
        case 2
            colormap(handles.activeScreen, bone);
            % New Conduction Velocity Map
            GUI_NewConductionVelocity(map, handles, f);
        case 3
            %activationMap
            GUI_ActivationMap(map, handles, f);
        case 4
            % APD Map
            GUI_ActionPotentialDurationMap(map, handles, f);
        case 5
            % Rise Time Map
            GUI_RiseTime(map, handles, f);
        case 6
            % Calcium Decay Map
            GUI_CalciumDecay(map, handles, f);
    end 
    
    set(handles.meanresults,'String',handles.activeCamData.meanresults);
    set(handles.medianresults,'String',handles.activeCamData.medianresults);
    set(handles.SDresults,'String',handles.activeCamData.SDresults);
    set(handles.num_members_results,'String',handles.activeCamData.num_membersresults);
    set(handles.angleresults,'String',handles.activeCamData.angleresults);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% USER FUNCTIONALITY
%% Listen for mouse clicks for the point-dragger
% When mouse button is clicked and held find associated marker
    function [i_temp,j_temp] = button_down_function(obj,~)
%         set(obj,'CurrentAxes',movieScreen1)
        ps = get(gca,'CurrentPoint');
        
        clickPosition = get(gca,'Position');
        
        if handles.expandedScreen>0 && isPosInsideOfRectangle (clickPosition, handles.expandedScreenPos)
            selectWindow(handles.allCamData(handles.expandedScreen).screen );
        else
            for i_cam=1:4
                if isPosInsideOfRectangle (clickPosition, handles.allCamData(i_cam).screenPos)
                    handles.activeScreenNo=i_cam;
                    selectWindow(handles.allCamData(i_cam).screen);
                    break;
                end
            end
        end
    end

    function [answer] = isPosInsideOfRectangle (pos, rectangle)
        answer = 1;
        if pos(1) - rectangle(1)<-1e-6 || pos(2) - rectangle(2)<-1e-6
            answer = 0;
        end
        if pos(1)+pos(3) - rectangle(1) - rectangle(3) >1e-6 || ...
           pos(2)+pos(4) - rectangle(2) - rectangle(4) >1e-6
            answer = 0;
        end
    end

%% When mouse button is released
    function button_up_function(~,~)
        handles.activeCamData.grabbed = -1;
        handles.grabbed = -1;
        handles.dispWaveClicked = 0;
    end

function selectWindow(clickedScreen)
    persistent chk; % check if we already clicked
    persistent screenSelected; % handle of previous clicked object

    handles.activeScreen = clickedScreen;
    handles.activeCamData = handles.allCamData(handles.activeScreenNo);
    
    for i=1:4
        handles.allCamData(i).screen.XColor = 'black';
        handles.allCamData(i).screen.YColor = 'black';
    end
    handles.activeScreen.XColor = 'red';
    handles.activeScreen.YColor = 'red';
    
    %disp ("ChooseScreen_here");
    
    if(screenSelected ~= clickedScreen)
        % case when two successive clicks were on different windows
        % fast clicks on different windows are not double-clicks 
        chk = [];
        screenSelected = clickedScreen;
        
        % redraw singal_screens for unbound screen
        %if ~handles.linked
        redrawWaveScreens();    
    end
    if isempty(chk)
        chk = 1;
        screenSelected = clickedScreen;
        
        ps = get(clickedScreen,'CurrentPoint');
        
        i_temp = round(ps(1,1));
        j_temp = round(ps(2,2));
        
        % grab marker
        %if handles.linked
        if handles.bounds(handles.activeScreenNo) == 1
            M = handles.markers1;
        elseif handles.bounds(handles.activeScreenNo) == 2
            M = handles.markers2;
        else
            M = handles.activeCamData.markers;
        end
        % if one of the markers on the movie screen is clicked
        if i_temp<=size(handles.activeCamData.cmosData,1) ||...
                j_temp<size(handles.activeCamData.cmosData,2) ||...
                i_temp>1 || j_temp>1
            if size(M,1) > 0
                for i=1:size(M,1)
                    if isPosInsideOfRectangle( [i_temp,j_temp,0.1,0.1], [M(i,1)-1, M(i,2)-1, 3, 3] )
                        if handles.bounds(handles.activeScreenNo) > 0
                            handles.grabbed = i;
                        else
                            handles.activeCamData.grabbed = i;
                        end
                        break
                    end
                end
            end
        end
       
        if (~handles.dispWaveClicked)
            pause(0.5); %Add a delay to distinguish single click from a double click
        end
        if chk == 1
            % end of single click case
            chk = [];
        end
    else
        % case of double-click
        % disable all small screens
        if handles.expandedScreen == 0
            set([sync12,sync13,sync24,sync34], 'Visible', 'off');
            for i=1:4
                handles.allCamData(i).isVisible=0;
                set(handles.allCamData(i).screen, 'Visible', 'off');
                if isempty(get(handles.allCamData(i).screen,'Children'))
                    continue;
                elseif size(get(handles.allCamData(i).screen,'Children'),1) == 1
                    set(get(handles.allCamData(i).screen,'Children'), 'Visible', 'off');
                elseif size(get(handles.allCamData(i).screen,'Children'),1)>1
                    for j=1:size(get(handles.allCamData(i).screen,'Children'),1)
                        child = get(handles.allCamData(i).screen,'Children');
                        set(child(j), 'Visible', 'off');            
                    end
                end
            end
            
            set(handles.activeCamData.screen,'Position',[0.14,0.18,0.51,0.82]);
            set(handles.activeCamData.screen, 'Visible', 'on');
            handles.activeCamData.isVisible=1;
            if ~isempty(get(handles.activeCamData.screen,'Children'))
                if size(get(handles.activeCamData.screen,'Children'),1) == 1
                    set(get(handles.activeCamData.screen,'Children'), 'Visible', 'on');
                else
                    for j=1:size(get(handles.activeCamData.screen,'Children'),1)
                        child = get(handles.activeCamData.screen,'Children');
                        set(child(j), 'Visible', 'on');            
                    end
                end
            end
        
            handles.expandedScreen = handles.activeScreenNo;
        else
            switch handles.expandedScreen
                case 1
                    set(clickedScreen,'Position',[0.14, 0.6, 0.25, 0.4]);
                case 2
                    set(clickedScreen,'Position',[0.4, 0.6, 0.25, 0.4]);
                case 3
                    set(clickedScreen,'Position',[0.14, 0.18, 0.25, 0.4]);
                case 4
                    set(clickedScreen,'Position',[0.4, 0.18, 0.25, 0.4]);
            end
            
            set([sync12,sync13,sync24,sync34], 'Visible', 'on');
            for i=1:4
                set(handles.allCamData(i).screen, 'Visible', 'on');
                handles.allCamData(i).isVisible=1;
                if isempty(get(handles.allCamData(i).screen,'Children'))
                    continue;
                elseif size(get(handles.allCamData(i).screen,'Children'),1) == 1
                    set(get(handles.allCamData(i).screen,'Children'), 'Visible', 'on');
                elseif size(get(handles.allCamData(i).screen,'Children'),1)>1
                    for j=1:size(get(handles.allCamData(i).screen,'Children'),1)
                        child = get(handles.allCamData(i).screen,'Children');
                        set(child(j), 'Visible', 'on');            
                    end
                end
                movieslider_callback(movie_slider);
                %set(handles.allCamData(i).screen, 'Ydir','reverse');
                %drawFrame(handles.frame, handles.allCamData(i));
            end
            
            handles.expandedScreen = 0;
        end
        chk = [];
    end
end

    function redrawWaveScreens()
        if handles.bounds(handles.activeScreenNo) == 0
            visualizeWaveScreens(0);
            for i_cam=1:5
                cla(handles.signalScreens(i_cam));
            end
            M = handles.activeCamData.markers; [a,~]=size(M);
            hold on
            for x=1:a
                plot(handles.time(1:handles.activeCamData.maxFrame),...
                    squeeze(handles.activeCamData.cmosData(M(x,2),M(x,1),:)),...
                            handles.markerColors(x),'LineWidth',2,'Parent',handles.signalScreens(x));
                set(handles.activeScreen,'YTick',[],'XTick',[]);% Hide tick markes
            end
            hold off
        elseif handles.bounds(handles.activeScreenNo) == 1
            % draw signal screens for the screen group 1
            visualizeWaveScreens(1);
            for i_marker=1:5
                for i_cam = 1:4
                    cla(signalGroup(i_marker).signalScreen(i_cam));
                end
            end
            
            M = handles.markers1;
            msize = size(handles.markers1,1);
            hold on
            for i_marker=1:msize
                for i_cam = 1:4
                    if (handles.allCamData(i_cam).isloaded && handles.bounds(i_cam) == 1)
                        plot(handles.time(1:handles.allCamData(i_cam).maxFrame),...
                            squeeze(handles.allCamData(i_cam).cmosData(M(i_marker,2),M(i_marker,1),:)),...
                            handles.markerColors(i_marker),'LineWidth',2,...
                            'Parent',signalGroup(i_marker).signalScreen(i_cam))
                    end
                end
            end
            hold off
        elseif handles.bounds(handles.activeScreenNo) == 2
            visualizeWaveScreens(1);
            % draw signal screens for the screen group 2
            for i_marker=1:5
                for i_cam = 1:4
                    cla(signalGroup(i_marker).signalScreen(i_cam));
                end
            end
            
            M = handles.markers2;
            msize = size(handles.markers2,1);
            hold on
            for i_marker=1:msize
                for i_cam = 1:4
                    if (handles.allCamData(i_cam).isloaded && handles.bounds(i_cam) == 2)
                        plot(handles.time(1:handles.allCamData(i_cam).maxFrame),...
                            squeeze(handles.allCamData(i_cam).cmosData(M(i_marker,2),M(i_marker,1),:)),...
                            handles.markerColors(i_marker),'LineWidth',2,...
                            'Parent',signalGroup(i_marker).signalScreen(i_cam))
                    end
                end
            end
            hold off
        end
    end

%% Update appropriate screens or slider when mouse is moved
    function button_motion_function(obj,~)
        % Update movie screen marker location
        if handles.bounds(handles.activeScreenNo) > 0
            grabbed = handles.grabbed;
        else
            grabbed = handles.activeCamData.grabbed;
        end
        if grabbed > -1
            set(obj,'CurrentAxes',handles.activeScreen)
            ps = get(handles.activeScreen,'CurrentPoint');
            i_temp = round(ps(1,1));
            j_temp = round(ps(2,2));
            if i_temp<=size(handles.activeCamData.cmosData,1) && i_temp>1 && ...
                  j_temp<=size(handles.activeCamData.cmosData,2) && j_temp>1
                
                i = i_temp;
                j = j_temp;
                
%                 if handles.linked
                if handles.bounds(handles.activeScreenNo) == 1
                    handles.markers1(handles.grabbed,:) = [i_temp j_temp];
                    
                    % plot signals for all loaded screens and set markers
                    for i_cam = 1:4
                        if (handles.allCamData(i_cam).isloaded && handles.bounds(i_cam) == 1)
                            plot(handles.time(1:handles.allCamData(i_cam).maxFrame),...
                                squeeze(handles.allCamData(i_cam).cmosData(j,i,:)),...
                                handles.markerColors(grabbed),'LineWidth',2,...
                                'Parent',signalGroup(grabbed).signalScreen(i_cam))
                        end
                    end
                    
                    handles.markers1(handles.grabbed,:) = [i j];

                    cla
                    movieslider_callback(movie_slider);
                elseif handles.bounds(handles.activeScreenNo) == 2
                        handles.markers2(handles.grabbed,:) = [i_temp j_temp];
                    
                    % plot signals for all loaded screens and set markers
                    for i_cam = 1:4
                        if (handles.allCamData(i_cam).isloaded && ...
                                handles.bounds(i_cam) == 2)
                            plot(handles.time(1:handles.allCamData(i_cam).maxFrame),...
                                squeeze(handles.allCamData(i_cam).cmosData(j,i,:)),...
                                handles.markerColors(grabbed),'LineWidth',2,...
                                'Parent',signalGroup(grabbed).signalScreen(i_cam))
                        end
                    end
                    
                    handles.markers2(handles.grabbed,:) = [i j];

                    cla
                    movieslider_callback(movie_slider);
                else
                    handles.activeCamData.markers(grabbed,:) = [i_temp j_temp];
                
                    plot(handles.time(1:handles.activeCamData.maxFrame),...
                        squeeze(handles.activeCamData.cmosData(j,i,:)),...
                        handles.markerColors(handles.activeCamData.grabbed),'LineWidth',2,...
                        'Parent',handles.signalScreens(handles.activeCamData.grabbed))
                    handles.activeCamData.markers(handles.activeCamData.grabbed,:) = [i j];

                    cla
                    drawFrame(handles.frame, handles.activeScreenNo);
                end
            end
        end
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOAD DATA
%% List that contains all files in directory
    function filelist_callback(source,~)
        str = get(source, 'String');
        val = get(source,'Value');
        file = char(str(val));
        handles.filename = file;
    end

    
%% Load selected files in filelist
    function loadfile_callback(~,~)
        if isempty(handles.filename)
            msgbox('Warning: No data selected','Title','warn')
        else
            firstLoad = 1;
            for i=1:4
                if handles.activeScreenNo ~= i && handles.allCamData(i).isloaded
                    firstLoad = 0;
                    break;
                end
            end
            set(map_popup,'Enable','on');
            % Clear off all images from previous set of data
            cla(handles.activeScreen); 
            for i_cam=1:5
                cla(handles.signalScreens(i_cam));
            end
            handles.activeCamData = handles.allCamData(handles.activeScreenNo);
            if firstLoad
                cla(sweep_bar);
                handles.frame = 1;% this handles indicate the current frame being displayed by the movie screen
                handles.normflag = 0;% this handle indicates if normalize is clicked
                handles.activeCamData.markers = [];
                handles.slide=-1;% this handle indicate if the movie slider is clicked
            end
            % Initialize handles
            handles.activeCamData.wave_window = 1;% this handle indicate the window number of the next wave displayed
            handles.activeCamData.markers = []; % this handle stores the locations of the markers
            % Check for *.mat file, if none convert
            filename = [handles.dir,'/',handles.filename];
            
            % Check for existence of already converted *.mat file
            if ~exist([filename(1:end-3),'mat'],'file')
                % Convert data and save out *.mat file
                CMOSconverter(handles.dir,handles.filename);
            end
            % Load data from *.mat file
            Data = load([filename(1:end-3),'mat']);
            
            % check if a loaded data has framerate as the previous loaded data
            differentFs = 0;
            for i_cam=1:4
                if handles.allCamData(i_cam).isloaded
                    if handles.allCamData(i_cam).Fs ~= handles.activeCamData.Fs
                        differentFs = 1;
                    end
                end
            end
            if differentFs && ~firstLoad
                msgbox('Warning: All loaded data should have an equal framerate!','Title','help')
            else
            
                % Check for dual camera data
                if isfield(Data,'cmosData2')
                    disp('dual camera');
                    %pop-up window for camera choice
                    questdual=questdlg('Please choose a camera', 'Camera Choice', 'Camera1', 'Camera2', 'Camera1');
                    % Load Camera1 data
                    if strcmp(questdual,'Camera1')
                        handles.activeCamData.cmosData = double(Data.cmosData(:,:,2:end));
                        handles.activeCamData.bg = double(Data.bgimage);
                    end
                    % Load Camera2 data
                    if strcmp(questdual,'Camera2')
                        handles.activeCamData.cmosData = double(Data.cmosData2(:,:,2:end));
                        handles.activeCamData.bg = double(Data.bgimage2);
                    end
                    handles.activeCamData.isloaded = 1;
                    
                    % Save out the frequency, cameras alternate, divide by 2
                    handles.activeCamData.Fs = double(Data.frequency);
                    % Save out pacing spike. Note: Data.channel1 is not
                    % necessarily the ecg channel. Correspondes to analog1
                    % input to SciMedia box
                    %handles.ecg = Data.channel{1}(1:size(Data.channel{1},2)/2)*-1;
                    %comment ecg 
                     % Save out added analog temporal resolution
%                     handles.nRate = Data.nRate;
                else
                    % Load from single camera
                    handles.activeCamData.isloaded = 1;
                    handles.activeCamData.cmosData = double(Data.cmosData(:,:,2:end));
                    handles.activeCamData.bg = double(Data.bgimage); 

                    % Save out pacing spike
                    %handles.activeCamData.ecg = Data.channel{1}(2:end)*-1;

                    % Save out added analog temporal resolution
                    % handles.activeCamData.nRate = Data.nRate;
                    % Save out frequency
                    handles.activeCamData.Fs = double(Data.frequency);
                    % Save out analog 
                end


                handles.activeCamData.cmosRawData = handles.activeCamData.cmosData; % Save a variable to preserve  the raw cmos data
                handles.activeCamData.bgRGB = real2rgb(handles.activeCamData.bg,'gray'); % Convert background to grayscale 

                handles.activeCamData.maxFrame = size(handles.activeCamData.cmosData,3);
%                 disp( handles.activeCamData.maxFrame);
                if (handles.maxFrame < handles.activeCamData.maxFrame)
                    handles.maxFrame = handles.activeCamData.maxFrame;
                end
                %%%%%%%%% WINDOWED DATA %%%%%%%%%%
                handles.matrixMax = .9 * max(handles.activeCamData.cmosData(:));
                % Initialize movie screen to the first frame
                set(f,'CurrentAxes',handles.activeScreen)

                G = real2rgb (handles.activeCamData.bg, 'gray');
                if handles.frame <= handles.activeCamData.maxFrame
                    Mframe = handles.activeCamData.cmosData(:,:,handles.frame);
                else
                    Mframe = handles.activeCamData.cmosData(:,:,end);
                end
                J = real2rgb(Mframe, 'jet');
                A = real2rgb(Mframe >= handles.minVisible, 'gray');
                I = J .* A + G .* (1-A);
                image(I,'Parent',handles.activeScreen);

                set(handles.activeScreen,'NextPlot','replacechildren','YLim',[0.5 size(I,1)+0.5],...
                    'YTick',[],'XLim',[0.5 size(I,2)+0.5],'XTick',[])
                % Scale signal screens and sweep bar to appropriate time scale
                timeStep = 1.0/handles.activeCamData.Fs;
                %handles.time = 0:timeStep:size(handles.cmosData,3)*timeStep-timeStep;
                handles.time = 0:timeStep:(handles.maxFrame-1)*timeStep;
                
                for i_signal_scrn=1:5
                    set(handles.signalScreens(i_signal_scrn),'XLim',[min(handles.time) max(handles.time)])
                    set(handles.signalScreens(i_signal_scrn),'NextPlot','replacechildren')
                    for i_cam=1:4
                        set(signalGroup(i_signal_scrn).signalScreen(i_cam),'XLim',[min(handles.time) max(handles.time)])
                        set(signalGroup(i_signal_scrn).signalScreen(i_cam),'NextPlot','replacechildren')
                    end
                end    

                % Fill times into activation map editable textboxes
                handles.starttime = 0;
                handles.endtime = max(handles.time);
                handles.timeScale = handles.time(end)/(handles.endtime - handles.starttime);
                set(starttimemap_edit,'String',num2str(handles.starttime))
                set(endtimemap_edit,'String',num2str(handles.endtime))
                % Initialize movie slider to the first frame
                if (firstLoad)
                    set(movie_slider,'Value',0)
                    drawFrame(1, handles.activeScreenNo);
                    set([play_button,stop_button,dispwave_button,expmov_button,...
                        starttimemap_edit,endtimemap_edit,expwave_button,exptofile_button,invert_cmap],'Enable','on')
                else
                    drawFrame(handles.frame, handles.activeScreenNo);
                    redrawWaveScreens();
                end
                
            end
        end
    end

%% Select directory for optical files
    function selectdir_callback(~,~)
        dir_name = uigetdir;
        if dir_name ~= 0
            handles.dir = dir_name;
            search_name = [dir_name,'/*.rsh'];
            search_nameNew = [dir_name,'/*.gsh'];
            files = struct2cell(dir(search_name));
            filesNew = struct2cell(dir(search_nameNew));
            handles.file_list = [files(1,:)'; filesNew(1,:)'];
            set(filelist,'String',handles.file_list)
            handles.filename = char(handles.file_list(1));
        end
    end
%% MOVIE SCREEN
%% Movie Slider Functionality
    function movieslider_callback(source,~)
        val = get(source,'Value');
%         i = round(val*size(handles.cmosData,3))+1;
        i = round(val*handles.maxFrame)+1;
        handles.frame = i;
        if handles.frame == handles.maxFrame + 1
            i = handles.maxFrame;
            handles.frame = handles.maxFrame;
        end
        
        % Update movie screen
        
        for i_cam=1:4
            %handles.allCamData(i_cam).drawMap = 0;
            if handles.allCamData(i_cam).isloaded == 1 && handles.allCamData(i_cam).isVisible == 1
                set(handles.allCamData(i_cam).screen,'NextPlot','replacechildren','YTick',[],'XTick',[]);
                set(f,'CurrentAxes',handles.allCamData(i_cam).screen)
                
                drawFrame(i, i_cam);
            end
        end
        
        % Update sweep bar
         if (handles.bounds(handles.activeScreenNo) == 0)
            set(f,'CurrentAxes',sweep_bar)
            a = [(handles.time(i)-handles.starttime)*handles.timeScale (handles.time(i)-handles.starttime)*handles.timeScale];b = [0 1]; cla
            plot(a,b,'r','Parent',sweep_bar)
            set(sweep_bar,'Layer','top');
%             axis([handles.starttime handles.endtime 0 1])
            axis([0 handles.time(end) 0 1])
            hold off; axis off;
         else
             for i_group=1:5
                 set(f,'CurrentAxes',signalGroup(i_group).sweepBar);
                 a = [(handles.time(i)-handles.starttime)*handles.timeScale (handles.time(i)-handles.starttime)*handles.timeScale];b = [0 1]; %cla
                 plot(a,b,'r','Parent',signalGroup(i_group).sweepBar)
                 %             axis([handles.starttime handles.endtime 0 1])
                 axis([0 handles.time(end) 0 1])
                 hold off;  axis off;
             end
         end
    end

%% Draw
function drawFrame(frame, camNo)
    for i=1:4
        handles.allCamData(i).screen.XColor = 'black';
        handles.allCamData(i).screen.YColor = 'black';
    end
    handles.activeScreen.XColor = 'red';
    handles.activeScreen.YColor = 'red';
    
    if handles.allCamData(camNo).isloaded==1 
        if ~handles.allCamData(camNo).drawMap
            G = handles.allCamData(camNo).bgRGB;
            if (frame <= handles.allCamData(camNo).maxFrame)
                Mframe = handles.allCamData(camNo).cmosData(:,:,frame);
            else
                Mframe = handles.allCamData(camNo).cmosData(:,:,end);
            end
            if handles.normflag == 0
                Mmax = handles.matrixMax;
                Mmin = handles.minVisible;
                numcol = size(jet,1);
                J = ind2rgb(round((Mframe - Mmin) ./ (Mmax - Mmin) * (numcol - 1)), 'jet');
                A = real2rgb(Mframe >= handles.minVisible, 'gray');
            else
                J = real2rgb(Mframe, 'jet');
                A = real2rgb(Mframe >= handles.normalizeMinVisible, 'gray');
            end

            I = J .* A + G .* (1 - A);

            image(I,'Parent',handles.allCamData(camNo).screen);
        end
        
        % plotMarkers
%         if handles.linked
        if handles.bounds(camNo) == 1
            M = handles.markers1;
        elseif handles.bounds(camNo) == 2
            M = handles.markers2;
        else
            M = handles.allCamData(camNo).markers;
        end
        [a,~]=size(M);
        hold on
        for x=1:a
            plot(M(x,1),M(x,2),'wp','MarkerSize',12,'MarkerFaceColor',...
                handles.markerColors(x),'MarkerEdgeColor','w','Parent',handles.allCamData(camNo).screen);
            
            set(handles.allCamData(camNo).screen,'YTick',[],'XTick',[]);% Hide tick markes
        end
        hold off
        
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DISPLAY CONTROL
%% Play button functionality
    function play_button_callback(~,~)
        isAnyCamLoaded=0;
        for i_cam=1:4
            handles.allCamData(i_cam).drawMap=0;
            isAnyCamLoaded = isAnyCamLoaded + handles.allCamData(i_cam).isloaded;
        end
        if isempty(isAnyCamLoaded == 0)
            msgbox('Warning: No data selected','Title','warn')
        else
            handles.playback = 1; % if the PLAY button is clicked
            startframe = handles.frame;
            % Update movie screen with new frames
            for i = startframe:5:handles.maxFrame
                if handles.playback == 1 % recheck if the PLAY button is clicked
                    for i_cam=1:4
                        if handles.allCamData(i_cam).isloaded == 1 && handles.allCamData(i_cam).isVisible==1 
                            set(handles.allCamData(i_cam).screen,'NextPlot','replacechildren','YTick',[],'XTick',[]);
                            set(f,'CurrentAxes',handles.allCamData(i_cam).screen)
                            drawFrame(i, i_cam);
                        end
                    end
                    handles.frame = i;
                    pause(0.01)
                    % Update movie slider
                    set(movie_slider,'Value',(i-1)/handles.maxFrame)

                    % Update sweep bar
                    if (handles.bounds(handles.activeScreenNo) == 0)
                        set(f,'CurrentAxes',sweep_bar)
                        a = [(handles.time(i)-handles.starttime)*handles.timeScale (handles.time(i)-handles.starttime)*handles.timeScale];b = [0 1]; cla
                        plot(a,b,'r','Parent',sweep_bar)
                        set(sweep_bar,'Layer','top');
                        %             axis([handles.starttime handles.endtime 0 1])
                        axis([0 handles.time(end) 0 1])

                        hold off; axis off;
                    else
                        for i_group=1:5
                             set(f,'CurrentAxes',signalGroup(i_group).sweepBar);
                             a = [(handles.time(i)-handles.starttime)*handles.timeScale (handles.time(i)-handles.starttime)*handles.timeScale]; b = [0 1]; %cla
                             plot(a,b,'r','Parent',signalGroup(i_group).sweepBar)
                             %             axis([handles.starttime handles.endtime 0 1])
                             axis([0 handles.time(end) 0 1])

                             hold off;  axis off;
                         end
                    end
                    pause(0.01); pause(0.01)
                    
                else
                    break
                end
            end
            handles.frame = min(handles.frame, handles.maxFrame);            
            for i_cam=1:4
                if handles.allCamData(i_cam).isloaded == 1 && handles.allCamData(i_cam).isVisible == 1
                    set(handles.allCamData(i_cam).screen,'NextPlot','replacechildren','YTick',[],'XTick',[]);
                    set(f,'CurrentAxes',handles.allCamData(i_cam).screen)
                    drawFrame(i, i_cam);
                end
            end
            handles.frame = i;
            pause(0.01)
            % Update movie slider
            set(movie_slider,'Value',(i-1)/handles.maxFrame)

            % Update sweep bar
            if (handles.bounds(handles.activeScreenNo) == 0)
                set(f,'CurrentAxes',sweep_bar)
                a = [(handles.time(i)-handles.starttime)*handles.timeScale (handles.time(i)-handles.starttime)*handles.timeScale]; b = [0 1]; cla
                plot(a,b,'r','Parent',sweep_bar)
                set(sweep_bar,'Layer','top');
                %             axis([handles.starttime handles.endtime 0 1])
                axis([0 handles.time(end) 0 1])

                hold off; axis off;
            else
                for i_group=1:5
                    set(f,'CurrentAxes',signalGroup(i_group).sweepBar);
                    a = [(handles.time(i)-handles.starttime)*handles.timeScale (handles.time(i)-handles.starttime)*handles.timeScale]; b = [0 1]; %cla
                    plot(a,b,'r','Parent',signalGroup(i_group).sweepBar)
                    %             axis([handles.starttime handles.endtime 0 1])
                    axis([0 handles.time(end) 0 1])

                    hold off;  axis off;
                end
            end
        end
    end

%% Stop button functionality
    function stop_button_callback(~,~)
        handles.playback = 0;
    end

%% Display Wave Button Functionality
    function dispwave_button_callback(~,~)
        handles.dispWaveClicked = 1;
        %set input point
        for i=1:4
             assert(strcmp(get(handles.allCamData(i).screen,'YDir'),'reverse'));  
             handles.allCamData(i).drawMap=0;
        end
        
        axis ij
        [i_temp,j_temp] = myginput(1,'circle');
        handles.activeCamData.drawMap = 0;
        % call button_down_function to select movieScreen before marker adding
        button_down_function(handles.activeCamData.screen);
    	
        i = round(i_temp); j = round(j_temp);
        
        %make sure pixel selected is within movieScreen
        assignin('base', 'DataFromwave', handles.activeCamData.cmosData(:,:,1));
        if i_temp>size(handles.activeCamData.cmosData,1) ||...
                j_temp>size(handles.activeCamData.cmosData,2) ||...
                i_temp<=1 || j_temp<=1
            msgbox('Warning: Pixel Selection out of Boundary','Title','help')
        else
            % Find the correct wave window
%             if (handles.linked)
            if handles.bounds(handles.activeScreenNo) == 1
                if handles.wave_window1 == 6
                    handles.wave_window1 = 1;
                end
                wave_window = handles.wave_window1;

                for i_cam = 1:4
                    if handles.allCamData(i_cam).isloaded && handles.bounds(i_cam) == 1
                       plot(handles.time(1:handles.allCamData(i_cam).maxFrame), ...
                                squeeze(handles.allCamData(i_cam).cmosData(j,i,:)),...
                                handles.markerColors(wave_window),'LineWidth',2, ...
                                'Parent',signalGroup(wave_window).signalScreen(i_cam));
                    end
                end
                handles.markers1(wave_window,:) = [i j];
            elseif handles.bounds(handles.activeScreenNo) == 2
                if handles.wave_window2 == 6
                    handles.wave_window2 = 1;
                end
                wave_window = handles.wave_window2;

                for i_cam = 1:4
                    if handles.allCamData(i_cam).isloaded && handles.bounds(i_cam) == 2
                       plot(handles.time(1:handles.allCamData(i_cam).maxFrame),...
                           squeeze(handles.allCamData(i_cam).cmosData(j,i,:)),...
                                handles.markerColors(wave_window),'LineWidth',2, ...
                                'Parent',signalGroup(wave_window).signalScreen(i_cam));
                    end
                end
                handles.markers2(wave_window,:) = [i j];
            else
                % unlinked screen case
                if handles.activeCamData.wave_window == 6
                    handles.activeCamData.wave_window = 1;
                end
                wave_window = handles.activeCamData.wave_window;

                plot(handles.time(1:handles.activeCamData.maxFrame),...
                    squeeze(handles.activeCamData.cmosData(j,i,:)),...
                            handles.markerColors(wave_window),'LineWidth',2,...
                            'Parent',handles.signalScreens(wave_window));
                handles.activeCamData.markers(wave_window,:) = [i j];
            end
        end
        cla
        if handles.bounds(handles.activeScreenNo) == 1
            handles.wave_window1 = wave_window + 1;
            movieslider_callback(movie_slider);
        elseif handles.bounds(handles.activeScreenNo) == 2
            handles.wave_window2 = wave_window + 1;
            movieslider_callback(movie_slider);
        
        else
            handles.activeCamData.wave_window = wave_window + 1; % Dial up the wave window count
            movieslider_callback(movie_slider); %drawFrame(handles.frame,handles.activeScreenNo);
        end
        % Update movie screen with new markers
        
    end
%% Export movie to .avi file
%Construct a VideoWriter object and view its properties. Set the frame rate to 60 frames per second:
    function expmov_button_callback(~,~)        
        % Save the movie to the same directory as the cmos data
        % Request the directory for saving the file
        dir = uigetdir;
        % If the cancel button is selected cancel the function
        if dir == 0
            return
        end
        % Request the desired name for the movie file
        filename = inputdlg('Enter Filename:');
        filename = char(filename);
        % Check to make sure a value was entered
        if isempty(filename)
            error = 'A filename must be entered! Function cancelled.';
            msgbox(error,'Incorrect Input','Error');
            return
        end
        filename = char(filename);
        % Create path to file
        movname = fullfile(dir,strcat(filename,'_movie.avi'));
        % Create the figure to be filmed        
        fig=figure('Name',[filename ' movie'],'NextPlot','replacechildren','NumberTitle','off',...
            'Visible','off','OuterPosition',[170, 140, 556,715]);
        % Start writing the video
        vidObj = VideoWriter(movname,'Motion JPEG AVI');
        open(vidObj);
        movegui(fig,'center')
        set(fig,'Visible','on')
        axis tight
        set(gca,'nextplot','replacechildren');
        % Designate the step of based on the frequency
        
        % Creat pop up screen; the start time and end time are determined
        % by the windowing of the signals on the Rhythm GUI interface
        
        % Grab start and stop time times and convert to index values by
        % multiplying by frequency, add one to shift from zero
        start = str2double(get(starttimemap_edit,'String'))*handles.activeCamData.Fs+1;   
        fin = str2double(get(endtimemap_edit,'String'))*handles.activeCamData.Fs+1;
        % Designate the resolution of the video: ex. 5 = every fifth frame
        step = 2;
        for i = start:step:fin
            % Plot sweep bar on bottom subplot
            subplot('Position',[0.05, 0.1, 0.9,0.15])
            a = [handles.time(i) handles.time(i)];
            
            b = [-50 50];
            cla
            plot(a,b,'r','LineWidth',1.5,'linestyle','--');hold on
            % Plot ecg data on bottom subplot
            subplot('Position',[0.05, 0.1, 0.9,0.15])
            % Create a variable for the endtime index
            endtime = round(handles.endtime*handles.activeCamData.Fs);
            % Plot the desired
            %plot(handles.time(start:endtime),handles.ecg(start:endtime));
            plot(handles.time(start:endtime),squeeze(handles.activeCamData.cmosData(60,62,start:endtime)), 'LineWidth',1.5);
            % 
            axis([handles.time(start) handles.time(end) min(squeeze(handles.activeCamData.cmosData(60,62,start:endtime))) max(squeeze(handles.activeCamData.cmosData(60,62,start:endtime)))]);
            % Set the xick mark to start from zero
            xlabel('Time (sec)');hold on
            % Image movie frames on the top subplot
            subplot('Position',[0.05, 0.28, 0.9,0.68])
            % Update image
            G = handles.activeCamData.bgRGB;
            Mframe = handles.activeCamData.cmosData(:,:,i);
            if handles.normflag == 0
                Mmax = handles.matrixMax;
                Mmin = handles.minVisible;
                numcol = size(jet,1);
                J = ind2rgb(round((Mframe - Mmin) ./ (Mmax - Mmin) * (numcol - 1)), jet);
                A = real2rgb(Mframe >= handles.minVisible, 'gray');
            else
                J = real2rgb(Mframe, 'jet');
                A = real2rgb(Mframe >= handles.normalizeMinVisible, 'gray');
            end
            
            I = J .* A + G .* (1 - A);
            image(I);
            axis off; hold off
            F = getframe(fig);
            writeVideo(vidObj,F);% Write each frame to the file.
        end
        close(fig);
        close(vidObj); % Close the file.
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SIGNAL SCREENS
%% Start Time Editable Textbox for Signal Screens
    function starttime_edit_callback(source,~)
        %get the val01 (lower limit) and val02 (upper limit) plot values
        val01 = str2double(get(source,'String'));
        val02 = str2double(get(endtimemap_edit,'String'));
        if (val01 >= val02)
            set(source,'String', num2str(val02));
            val01 = val02;
            val02 = val01+0.01;
            set(endtimemap_edit,'String', num2str(val02));
            
        end
        if val01 >= 0 && val01 <= (size(handles.activeCamData.cmosData,3)-1)*handles.Fs
            for i_screen=1:5
                set(handles.signalScreens(i_screen),'XLim',[val01 val02]);
                for i_cam=1:4
                    set(signalGroup(i_screen).signalScreen(i_cam),'XLim',[val01 val02]);
                end
            end
            if (handles.bounds(handles.activeScreenNo) == 0)
                set(sweep_bar,'XLim',[val01 val02]);
            else
                for iii=1:5
                    set(signalGroup(iii).sweepBar,'XLim',[val01 val02]);
                end  
            end
        else
            error = 'The START TIME must be greater than %d and less than %.3f.';
            msgbox(sprintf(error,0,max(handles.time)),'Incorrect Input','Warn');
            set(source,'String',0)
        end
        % Update the start time value
        handles.starttime = val01;
        handles.endtime = val02;
        handles.timeScale = handles.time(end)/(handles.endtime - handles.starttime);
        movieslider_callback(movie_slider);
    end

%% End Time Editable Textbox for Signal Screens
    function endtime_edit_callback(source,~)
        val01 = str2double(get(starttimemap_edit,'String'));
        val02 = str2double(get(source,'String'));
        if (val01 >= val02)
            set(source,'String', num2str(val01+0.01));
            val02 = val01+0.01;
        end
        if val02 >= 0 && val02 <= (size(handles.activeCamData.cmosData,3)-1)*handles.activeCamData.Fs
            for i_screen=1:5
                set(handles.signalScreens(i_screen),'XLim',[val01 val02]);
                for i_cam=1:4
                    set(signalGroup(i_screen).signalScreen(i_cam),'XLim',[val01 val02]);
                end
            end
            if (handles.bounds(handles.activeScreenNo) == 0)
                set(sweep_bar,'XLim',[val01 val02]);
            else
                for iii=1:5
                    set(signalGroup(iii).sweepBar,'XLim',[val01 val02]);
                end    
            end
        else
            error = 'The END TIME must be greater than %d and less than %.3f.';
            msgbox(sprintf(error,0,max(handles.time)),'Incorrect Input','Warn');
            set(source,'String',max(handles.time))
        end
        % Update the end time value
        handles.endtime = val02;
        handles.timeScale = handles.time(end)/(handles.endtime - handles.starttime);
        movieslider_callback(movie_slider);
    end

%% Export signal waves to new screen
    function expwave_button_callback(~,~)
        M = handles.activeCamData.markers; colax='bgykcm'; [a,~]=size(M);
        if isempty(M)&&isempty(handles.markers1)
            msgbox('No wave to export. Please use "Display Wave" button to select pixels on movie screen.','Icon','help')
        else
            w=figure('Name','Signal Waves','NextPlot','add','NumberTitle','off',...
                'Visible','on','OuterPosition',[100, 50, 555,120*a+80]);
        end
        if handles.bounds(handles.activeScreenNo) == 0
            for x = 1:a
                subplot('Position',[0.06 (120*(a-x)+70)/(120*a+80) 0.9 110/(120*a+80)]);
                plot(handles.time(1:handles.activeCamData.maxFrame), ...
                    squeeze(handles.activeCamData.cmosData(M(x,2),M(x,1),:)),'color',colax(x),'LineWidth',2)
                xlim([handles.starttime handles.endtime]);
                hold on
                if x == a
                else
                    set(gca,'XTick',[])
                end
            end
            set(signal_scrn5,'XLim',[min(handles.time) max(handles.time)])
            xlabel('Time (sec)')
            hold off
            movegui(w,'center')
            %set(w,'Visible','on')
        elseif handles.bounds(handles.activeScreenNo) == 1
            M = handles.markers1;
            msize = size(handles.markers1,1);
            hold on
            number_of_bounds=0;
            for i=1:4
                if handles.bounds(i)==1 
                    number_of_bounds=number_of_bounds+1;
                end
            end
                for i_marker=1:msize
                    for i_cam = 1:4
                        
                        if (handles.allCamData(i_cam).isloaded && handles.bounds(i_cam) == 1)
                            subplot(msize,number_of_bounds, i_cam+(i_marker-1)*number_of_bounds);
                            plot(handles.time(1:handles.allCamData(i_cam).maxFrame),...
                                squeeze(handles.allCamData(i_cam).cmosData(M(i_marker,2),M(i_marker,1),:)),...
                                handles.markerColors(i_marker),'LineWidth',2)
                            %hold on
                            movegui(w,'center')
                            set(w,'Visible','on')
                            set(w, 'Position', get(0, 'Screensize'));
                        end
                    end
                end
        elseif handles.bounds(handles.activeScreenNo) == 2
            M = handles.markers2;
            msize = size(handles.markers2,1);
            hold on
            number_of_bounds=0;
            for i=1:4
                if handles.bounds(i)==2 
                    number_of_bounds=number_of_bounds+1;
                end
            end
                for i_marker=1:msize
                    for i_cam = 1:4
                        
                        if (handles.allCamData(i_cam).isloaded && handles.bounds(i_cam) == 1)
                            subplot(msize,number_of_bounds, i_cam+(i_marker-1)*number_of_bounds);
                            plot(handles.time(1:handles.allCamData(i_cam).maxFrame),...
                                squeeze(handles.allCamData(i_cam).cmosData(M(i_marker,2),M(i_marker,1),:)),...
                                handles.markerColors(i_marker),'LineWidth',2)
                            %hold on
                            movegui(w,'center')
                            set(w,'Visible','on')
                            set(w, 'Position', get(0, 'Screensize'));
                        end
                    end
                end
        end

    end

%% Export signal waves to file
function exptofile_button_callback(~,~)
        M = handles.activeCamData.markers; [a,~]=size(M);
        if isempty(M)&&isempty(handles.markers1)
            msgbox('No wave to export. Please use "Display Wave" button to select pixels on movie screen.','Icon','help')
        else
            if handles.bounds(handles.activeScreenNo) == 0 % case for ungrouped screen
                A = zeros(handles.activeCamData.maxFrame,a+1);
                for x = 1:a
                    for t = 1:handles.activeCamData.maxFrame
                        A(t,1) = handles.time(t);
                        A(t,x+1) = handles.activeCamData.cmosData(M(x,2),M(x,1),t);
                    end
                end
            else % here case for both screen groups 1 or 2
                if handles.bounds(handles.activeScreenNo) == 1
                    M = handles.markers1;
                elseif handles.bounds(handles.activeScreenNo) == 2
                    M = handles.markers2;
                end
                msize = size(M,1);
                A = zeros(handles.activeCamData.maxFrame, 4*msize+1);
                
                for i_marker=1:msize
                    for i_cam = 1:4
                        if (handles.allCamData(i_cam).isloaded && handles.bounds(i_cam) == handles.bounds(handles.activeScreenNo))
                            for t = 1:handles.allCamData(i_cam).maxFrame
                                A(t,(i_marker-1)*4+i_cam+1) = handles.allCamData(i_cam).cmosData(M(i_marker,2),M(i_marker,1),t);
                                A(t,1) = handles.time(t);
                            end
                        end
                    end
                end
            end
        end
        [filename, path] = uiputfile('output.txt');
        dlmwrite(strcat(path,filename), A,'\t');
    end


% INVERT COLORMAP: inverts the colormaps for all isochrone maps
    function invert_cmap_callback(~,~)
        % Function Description: The checkbox function like toggle button. 
        % There are only 2 options and since the box starts unchecked, 
        % checking it will invert the map, uncheckecking it will invert it 
        % back to its original state. As such no additional code is needed.
        
        % grab the current value of the colormap
        cmap = handles.cmap;
        % invert the existing colormap values
        handles.cmap = flipud(cmap);
    end
end