% GUI for Activation Map 
% Inputs: 
% activationMapGroup -- pannel to draw on
% handles     -- rhythm handles
% f           -- figure of the main rhythm window
% 
% by Roman Pryamonosov, Roman Syunyaev, and Alexander Zolotarev

function GUI_ActivationMap(activationMapGroup,handles, f)
starttimeamap_text = uicontrol('Parent',activationMapGroup, ...
                                       'Style','text','FontSize',10, ...
                                       'String','Start Time',...
                                       'Units','normalized',...
                                       'Position',[.05 .8 .5 .1]);
starttimeamap_edit = uicontrol('Parent',activationMapGroup,...
                                       'Style','edit','FontSize',10, ... 
                                       'Units','normalized',...
                                       'Position',[0.6 0.8 .3 .15],...
                                       'Callback',@startTime_callback);
endtimeamap_text   = uicontrol('Parent',activationMapGroup, ...
                                       'Style','text','FontSize',10,...
                                       'String','End Time',...
                                       'Units','normalized',...
                                       'Position',[0.05 0.5 0.5 0.15]);
endtimeamap_edit   = uicontrol('Parent',activationMapGroup,...
                                       'Style','edit','FontSize',10,...
                                       'Units','normalized',...
                                       'Position',[0.6 0.5 0.3 0.15],...
                                       'Callback',@endTime_callback);
create_amap_button  = uicontrol('Parent',activationMapGroup,...
                                       'Style','pushbutton',...
                                       'FontSize',10,...
                                       'String','Calculate',...
                                       'Units','normalized',...
                                       'Position',[0.01 0.1 0.7 0.15],...
                                       'Callback',@createamap_button_callback);
export_icon = imread('icon.png');
export_icon = imresize(export_icon, [20, 20]);
export_button = uicontrol('Parent',activationMapGroup,'Style','pushbutton',...
                        'Units','normalized',...
                        'Position',[0.75, 0.1, 0.15, 0.15]...
                        ,'Callback',{@export_button_callback});                                  
set(export_button,'CData',export_icon)                                  
set(starttimeamap_edit, 'String', '0.75');
set(endtimeamap_edit, 'String', '0.85');
startTime_callback(starttimeamap_edit);
% Save handles in figure with handle f.
guidata(activationMapGroup, handles);



% callback functions
%% ACTIVATION MAP
%% Button to create activation map
    function startTime_callback(source,~)
        val_start = str2double(get(source,'String'));
        val_end = str2double(get(endtimeamap_edit,'String'));
        if (val_start < 0)
            set(source,'String', 0);
            val_start = 0;
        end
        if (val_start >= val_end)
            set(source,'String', num2str(val_start));
            val_start = val_end;
            val_end = val_start+0.01;
            set(endtimeamap_edit,'String', num2str(val_end));
            set(source,'String', num2str(val_start));
        end
        drawTimeLines(val_start, val_end, handles, f);
    end

    function endTime_callback(source,~)
        val_start = str2double(get(starttimeamap_edit,'String'));
        val_end = str2double(get(source,'String'));
        if (val_start >= val_end)
            set(source,'String', num2str(val_start+0.01));
            val_end = val_start+0.01;
        end
        drawTimeLines(val_start, val_end, handles, f);
    end 

    function drawTimeLines(val_start, val_end, handles, f)
        if val_start >= 0 && val_start <= handles.time(end)
            if val_end >= 0 && val_end <= handles.time(end)
                % set boundaries to draw time lines
                pointB = [0 1]; 
                playTimeA = [(handles.time(handles.frame)-handles.starttime)*handles.timeScale (handles.time(handles.frame)-handles.starttime)*handles.timeScale];
                startLineA = [(val_start-handles.starttime)*handles.timeScale (val_start-handles.starttime)*handles.timeScale]; 
                endLineA = [(val_end-handles.starttime)*handles.timeScale (val_end-handles.starttime)*handles.timeScale];
                if (handles.bounds(handles.activeScreenNo) == 0)
                    set(f,'CurrentAxes',handles.sweepBar); cla;
                    plot(startLineA, pointB, 'g', 'Parent', handles.sweepBar)
                    hold on
                    axis([0 handles.time(end) 0 1])
                    plot(playTimeA, pointB, 'r', 'Parent', handles.sweepBar)
                    hold on
                    plot(endLineA, pointB, '-g','Parent',handles.sweepBar)
                    hold off; axis off
                    hold off 
                else
                    hold on
                    for i_group=1:5
                        set(f,'CurrentAxes',handles.signalGroup(i_group).sweepBar); cla;
                        plot(startLineA, pointB, 'g', 'Parent', handles.signalGroup(i_group).sweepBar)
                        hold on;
                        plot(playTimeA, pointB, 'r', 'Parent', handles.signalGroup(i_group).sweepBar)
                        hold on;
                        plot(endLineA, pointB, '-g','Parent', handles.signalGroup(i_group).sweepBar)
                        axis([0 handles.time(end) 0 1])
                        hold off; axis off;
                        hold off;
                    end
                    
                end
            else
                error = 'The END TIME must be greater than %d and less than %.3f.';
                msgbox(sprintf(error,0,max(handles.time)),'Incorrect Input','Warn');
                set(endtimeamap_edit,'String',max(handles.time))
            end
        else
            error = 'The START TIME must be greater than %d and less than %.3f.';
            msgbox(sprintf(error,0,max(handles.time)),'Incorrect Input','Warn');
            set(starttimeamap_edit,'String',0)
        end
    end

    function createamap_button_callback(~,~)
        % get the bounds of the activation window
        a_start = str2double(get(starttimeamap_edit,'String'));
        a_end = str2double(get(endtimeamap_edit,'String'));
        drawTimeLines(a_start, a_end, handles, f);
        handles.a_start = a_start;
        handles.a_end = a_end;
        axes(handles.activeCamData.screen)
        gg=msgbox('Building  Activation Map...');
        aMap(handles.activeCamData.cmosData,handles.a_start,handles.a_end,...
            handles.activeCamData.Fs,handles.activeCamData.cmap, handles.activeCamData.screen, handles);
        handles.activeCamData.drawMap = 1;
        close(gg)
    end

%% Export picture from the screen
    function export_button_callback(~,~)  
       if isempty(handles.activeCamData.saveData)
           error = 'ExportedData must exist! Function cancelled.';
           msgbox(error,'Incorrect Input','Error');
           return
       else
        figure;
            startp = round(handles.a_start*handles.activeCamData.Fs);
            endp = round(handles.activeCamData.Fs*handles.a_end);
            contourf(flipud(handles.activeCamData.saveData),endp-startp,'LineColor','none');
        colormap jet;
        colorbar;
       end
    end
end
