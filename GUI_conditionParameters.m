% Signal Processing instruments
% Inputs:  
% conditionParametersGroup -- pannel to draw on
% handles                  -- rhythm handles
% 
% by Roman Pryamonosov, Roman Syunyaev, and Alexander Zolotarev

function GUI_conditionParameters(conditionParametersGroup, handles)
% New pushbutton with callback definition.
% Signal Conditioning Button Group and Buttons
fontSize=9;

 brush_checkbox = uicontrol('Parent',conditionParametersGroup,...
                             'Style','checkbox','FontSize',fontSize,...
                             'String','Brush',...
                             'Units','normalized',...
                             'Position',[0.5 0.835 0.5 0.075],...
                             'Callback',{@brush_checkbox_callback});
    function brush_checkbox_callback(src,~)
        handles.drawBrush = get(src,'Value');
    end

% brush_slider = uicontrol('Parent',conditionParametersGroup,...
%                             'Style', 'slider', 'Units','normalized',...
%                             'Position',[0.001 0.55 0.7 0.075],...
%                             'SliderStep',[.01 .2],...
%                             'Callback',{@brush_slider_callback});

%     function brush_slider_callback(src,~)
%         brushSize = 1.0 + get(src,'Value')*30;
% %         handles.activeCamData.brushSize = brushSize;
%         handles.brushSize = brushSize;
%         
%         % Make a circle mask
%         circleMask = zeros(1 + 2*ceil(brushSize), 1 + 2*ceil(brushSize));
%         for i=1:size(circleMask,1)
%             for j=1:size(circleMask,2)
%                 if (j - size(circleMask,2)/2-0.5)^2 + (i - size(circleMask,2)/2-0.5)^2 < brushSize^2
%                     circleMask(j,i) = 1;
%                 end
%             end
%         end
%         [row,col] = find(circleMask);
%         row = row - size(circleMask,2)/2 - 0.5;
%         col = col - size(circleMask,2)/2 - 0.5;
% %         handles.activeCamData.brushMaskIndices = [row,col];
%         handles.brushMaskIndices = [row,col];
%     end
                        
                        
removeBG_button = uicontrol('Parent',conditionParametersGroup,...
                            'Style','checkbox','FontSize',fontSize,...
                            'String','Remove Background',...
                            'Units','normalized',...
                            'Position',[0.01 0.9 0.9 0.1],...
                            'Callback',@removeBGcheckbox_callback);

fillHoles_checkbox = uicontrol('Parent',conditionParametersGroup,...
                            'Style','checkbox','FontSize',fontSize,...
                            'String','Fill Holes',...
                            'Units','normalized',...
                            'Position',[0.001 0.575 0.7 0.075],...
                            'Callback',@removeBG_callback);

bg_thresh_label = uicontrol('Parent',conditionParametersGroup, ...
                            'Style','text','FontSize',fontSize,...
                            'String','Threshold',...
                            'Units','normalized',...
                            'Position',[0 0.825 0.5 0.075]);

% bg_thresh_edit = uicontrol('Parent',conditionParametersGroup,'Style','edit',...
%                            'FontSize',fontSize,'String','0.3',...
%                            'Units','normalized',...
%                            'Position',[0.7 0.7 0.3 0.1],...
%                            'Callback', @removeBG_callback);
        
bg_thresh_slider = uicontrol('Parent',conditionParametersGroup,...
                            'Style', 'slider', 'Units','normalized',...
                            'Position',[0., 0.75, 0.9, 0.075],...
                            'SliderStep',[.01 .02],...
                            'Callback',{@removeBG_callback});
set(bg_thresh_slider,'Value',0.5);

removeIslandsCheckbox = uicontrol('Parent',conditionParametersGroup,'Style','checkbox',...
                          'FontSize',fontSize,'String','Remove Islands',...
                          'Units','normalized',...
                          'Position',[0 0.65 0.7 0.075],...
                          'Callback', {@removeBG_callback});
perc_ex_edit = uicontrol('Parent',conditionParametersGroup,'Style','edit',...
                         'FontSize',fontSize,'String','0.01',...
                         'Units','normalized',...
                         'Position',[0.7 0.65 0.3 0.075],...
                         'Callback',@removeBG_callback);

bin_button  = uicontrol('Parent',conditionParametersGroup,'Style','checkbox',...
                        'FontSize',fontSize,'String','Bin',...
                        'Units','normalized',...
                         'Position',[0 0.375 0.5 0.075]);
filt_button = uicontrol('Parent',conditionParametersGroup,'Style','checkbox',...
                        'FontSize',fontSize,'String','Filter',...
                        'Units','normalized',...
                        'Position',[0 0.3 0.5 0.075]);
removeDrift_button = uicontrol('Parent',conditionParametersGroup,...
                        'Style','checkbox','FontSize',10,'String','Drift',...
                        'Units','normalized',...
                        'Position',[0 0.225 0.5 0.075]);
norm_button  = uicontrol('Parent',conditionParametersGroup,'Style','checkbox',...
                        'FontSize',fontSize,'String','Normalize',...
                        'Units','normalized',...
                        'Position',[0 0.15 1 0.075]);
inverse_button = uicontrol('Parent',conditionParametersGroup,...
                           'Style','checkbox','FontSize',fontSize,...
                           'String','Inverse signal',...
                           'Units','normalized',...
                         'Position',[0 0.075 1 0.075]);
apply_button = uicontrol('Parent',conditionParametersGroup,...
                         'Style','pushbutton','FontSize',fontSize,...
                         'String','Apply',...
                         'Units','normalized',...
                         'Position',[0 0 1 0.075],'Callback',@cond_sig_selcbk);
%Pop-up menu options
bin_popup = uicontrol('Parent',conditionParametersGroup,...
                      'Style','popupmenu','FontSize',fontSize,...
                      'String',{'3 x 3', '5 x 5', '7 x 7'},...
                      'Units','normalized',...
                      'Position',[0.5 0.375 0.5 0.075]);
filt_popup = uicontrol('Parent',conditionParametersGroup,...
                       'Style','popupmenu','FontSize',fontSize,...
                       'String',{'[0 50]','[0 75]', '[0 100]', '[0 150]'},...
                       'Units','normalized',...
                       'Position',[0.5 0.3 0.5 0.075]);
drift_popup = uicontrol('Parent',conditionParametersGroup,...
                        'Style','popupmenu','FontSize',fontSize,...
                        'String',{'1st Order','2nd Order', '3rd Order', '4th Order'},...
                        'Units','normalized',...
                        'Position',[0.5 0.225 0.5 0.075]);
set(filt_popup,'Value',3)
meanValues = mean(handles.activeCamData.cmosData, 3);
meanValues = meanValues - min(meanValues(:,:)) ;
meanValues = meanValues ./ max(meanValues(:,:)) ;
%figure;
%imshow(meanValues);

deviationValues = std(handles.activeCamData.cmosData,0,[3]);
deviationValues = deviationValues - min(deviationValues(:,:)) ;
deviationValues = deviationValues ./ max(deviationValues(:,:)) ;
%figure;
%imshow(deviationValues);

%sample = squeeze(handles.activeCamData.cmosData(36,30,:));
%[pxx,f] = pwelch(sample - mean(sample), handles.activeCamData.Fs);
%figure
%plot (pxx)
% fidi = fopen('d2_r6__001.txt');
% D = textscan(fidi, '%f%f%f%*f', 'CollectOutput',1);
% s = D{:}(:,2:3);
% Fs = handles.activeCamData.Fs;                                                  % Sampling Frequency (Hz)
% Ts = Fs * size(handles.activeCamData.cmosData,3);                                                  % Sampling Interval (sec)
% Fn = Fs/2;                                                  % Nyquist Frequency (Hz)
% t = D{:}(:,1)*Ts;                                           % Time Vector
% L = length(t);                                              % Vector Length
% FTs = fft(s-mean(s))/L;                                     % Fourier Transform (Subtract d-c Offset)
% Fv = linspace(0, 1, fix(L/2)+1)*Fn;                         % Frequency Vector
% Iv = 1:length(Fv);                                          % Index Vector
% [pks1,frqs1] = findpeaks(abs(FTs(Iv,1))*2, Fv, 'MinPeakHeight',0.05);
% [pks2,frqs2] = findpeaks(abs(FTs(Iv,2))*2, Fv, 'MinPeakHeight',0.05);
% figure(1)
% plot(Fv, abs(FTs(Iv,:))*2)
% hold on
% plot(frqs1, pks1, '^b')
% plot(frqs2, pks2, '^r')
% hold off
% grid
% axis([0  1000    ylim])


guidata(conditionParametersGroup, handles);
if (handles.activeCamData.isloaded)
    removeBG_callback(removeBG_button);
end
    function removeBG_callback(hObject,~)
        %threshold = str2double(get(bg_thresh_edit,'String'));
        val = get(bg_thresh_slider,'Value');
        
        maxBG = max (handles.activeCamData.bg);
        minBG = min (handles.activeCamData.bg);
        
        frame = handles.activeCamData.bgRGB;
        BG = mat2gray(frame);

        BW = im2bw(BG,val); % create mask
        
        handles.activeCamData.thresholdSegmentation = BW;
        handles.activeCamData.finalSegmentation = handles.activeCamData.brushSegmentation | handles.activeCamData.thresholdSegmentation;
        
        handles.isFillHoles = get(fillHoles_checkbox,'Value');
        if handles.isFillHoles
            handles.activeCamData.finalSegmentation = imfill(handles.activeCamData.finalSegmentation,'holes'); %fill holes
        end
        
        handles.isRemoveIslands = get(removeIslandsCheckbox,'Value');
        handles.removeIslandsPercent = str2double (get(perc_ex_edit, 'String'));
        if handles.isRemoveIslands
            handles.activeCamData.finalSegmentation = bwareaopen(handles.activeCamData.finalSegmentation , ceil(handles.removeIslandsPercent*size(BG ,1)*size(BG,2))); % remove islands
        end
        drawFrame(handles.frame ,handles.activeScreenNo);
    end

    function removeBGcheckbox_callback(hObject,eventdata)
        removeBG_callback(hObject);
        handles.drawSegmentation = get(hObject,'Value');
        drawFrame(handles.frame ,handles.activeScreenNo);
    end

% Condition Signals Selection Change Callback
    function cond_sig_selcbk(hObject,~)
        % Read check box
        removeBG_state =get(removeBG_button,'Value');
        bin_state = get(bin_button,'Value');
        filt_state = get(filt_button,'Value');
        drift_state = get(removeDrift_button,'Value');
        norm_state = get(norm_button,'Value');
        inverse_state = get(inverse_button,'Value'); 
        %denoise_state = get(denoise_button,'Value');
        % Grab pop up box values
        bin_pop_state = get(bin_popup,'Value');
        
        % Create variable for tracking conditioning progress
        trackProg = [removeBG_state filt_state bin_state drift_state norm_state inverse_state];
        trackProg = sum(trackProg);
        counter = 0;
        g1 = waitbar(counter,'Conditioning Signal');
        
        % Return to raw unfiltered cmos data
        
        handles.normflag = 0; % Initialize normflag
        handles.activeCamData.cmosData = handles.activeCamData.cmosRawData;
        
        % Condition Signals
        % Remove Background
        if removeBG_state == 1
            % Update counter % progress bar
            counter = counter + 1;
            waitbar(counter/trackProg,g1,'Removing Background');
            %bg_thresh = str2double(get(bg_thresh_edit,'String'));
            %perc_ex = str2double(get(perc_ex_edit,'String'));
            %handles.activeCamData.cmosData = remove_BKGRD(handles.activeCamData.cmosData,handles.activeCamData.bg,bg_thresh,perc_ex);
            handles.activeCamData.cmosData = handles.activeCamData.cmosData.* handles.activeCamData.finalSegmentation;
        end
        % Bin Data
        if bin_state == 1
            % Update counter % progress bar
            counter = counter + 1;
            waitbar(counter/trackProg,g1,'Binning Data');
            if bin_pop_state == 3
                bin_size = 7;
            elseif bin_pop_state == 2
                bin_size = 5;
            else
                bin_size = 3;
            end
            handles.activeCamData.cmosData = binning(handles.activeCamData.cmosData,bin_size);
        end
        % Filter Data
        if filt_state == 1
            % Update counter % progress bar
            counter = counter + 1;
            waitbar(counter/trackProg,g1,'Filtering Data');
            filt_pop_state = get(filt_popup,'Value');
            if filt_pop_state == 4
                or = 100;
                lb = 0.5;
                hb = 150;
            elseif filt_pop_state == 3
                or = 100;
                lb = 0.5;
                hb = 100;
            elseif filt_pop_state == 2
                or = 100;
                lb = 0.5;
                hb = 75;
            else
                or = 100;
                lb = 0.5;
                hb = 50;
            end
            handles.activeCamData.cmosData = filter_data(handles.activeCamData.cmosData,handles.activeCamData.Fs, or, lb, hb);
        end
        % Remove Drift
        if drift_state == 1
            % Update counter % progress bar
            counter = counter + 1;
            waitbar(counter/trackProg,g1,'Removing Drift');
            % Gather drift values and adjust for drift
            ord_val = get(drift_popup,'Value');
            ord_str = get(drift_popup,'String');
            handles.activeCamData.cmosData = remove_Drift(handles.activeCamData.cmosData,ord_str(ord_val));
        end
        % Normalize Data
        if norm_state == 1
            % Update counter % progress bar
            counter = counter + 1;
            waitbar(counter/trackProg,g1,'Normalizing Data');
            % Normalize data
            handles.activeCamData.cmosData = normalize_data(handles.activeCamData.cmosData);
            
            handles.normflag = 1;
        end
        %Inverse Data
        if inverse_state==1
            counter = counter + 1;
            waitbar(counter/trackProg,g1,'Inversing Data');
            handles.activeCamData.cmosData=-handles.activeCamData.cmosData+max(handles.activeCamData.cmosData(:))+min(handles.activeCamData.cmosData(:));
        end
        % Denoise Data
        %if denoise_state == 1
            % Update counter % progress bar
        %    counter = counter + 1;
        %    waitbar(counter/trackProg,g1,'Denoising Data');
            % Denoise data
        %    handles.activeCamData.cmosData = denoise_data(handles.activeCamData.cmosData,handles.activeCamData.Fs,handles.activeCamData.bg);
        %end
        
        % Delete the progress bar 
        delete(g1)
        % Save conditioned signal
        hObject.UserData = handles.activeCamData.cmosData;

% Save handles in figure with handle f.
        guidata(conditionParametersGroup, handles);
        guidata(handles.activeScreen, handles);
        if isempty(handles.activeCamData.cmosData)
            msgbox('Warning: No data selected','Title','warn')
        else
            cla(handles.activeScreen);
            handles.matrixMax = .9 * max(handles.activeCamData.cmosData(:));
            currentframe = handles.frame;
            if handles.normflag == 0
                drawFrame(currentframe, handles.activeScreenNo);
                hold on
            else
                drawFrame(currentframe, handles.activeScreenNo);
                caxis([0 1])
                hold on
            end
            set(handles.activeScreen,'YTick',[],'XTick',[]);% Hide tick markes
        end
        
    end
function drawFrame(frame, camNo)
        for i=1:4
            handles.allCamData(i).screen.XColor = 'black';
            handles.allCamData(i).screen.YColor = 'black';
        end
        handles.activeScreen.XColor = 'red';
        handles.activeScreen.YColor = 'red';

        if handles.allCamData(camNo).isloaded==1

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

            I = J .* A + G .* (1 - A) ;
            
            removeBGthreshold = get(removeBG_button,'Value');
            handles.activeCamData.removeBGthreshold = removeBGthreshold;
            if (removeBGthreshold)
                mask = handles.activeCamData.finalSegmentation;
                maskedI = I;
                [row,col] = find(mask~=0);
                for i=1:size(row,1)
                    maskedI(row(i),col(i),1) = 1;
                end
            end
            
            %image(maskedI,'Parent',handles.allCamData(camNo).screen);

            if handles.bounds(camNo) == 1
                M = handles.markers1;
            elseif handles.bounds(camNo) == 2
                M = handles.markers2;
            else
                M = handles.allCamData(camNo).markers;
            end
            [a,~]=size(M);
            hold(handles.allCamData(camNo).screen,'on')
            if removeBGthreshold
                image(maskedI,'Parent',handles.allCamData(camNo).screen);
            else
                image(I,'Parent',handles.allCamData(camNo).screen);
            end
            for xx=1:a
                plot(M(xx,1),M(xx,2),'wp','MarkerSize',12,'MarkerFaceColor',...
                    handles.markerColors(xx),'MarkerEdgeColor','w','Parent',handles.allCamData(camNo).screen);

                set(handles.allCamData(camNo).screen,'YTick',[],'XTick',[]);% Hide tick markes
            end
            hold(handles.allCamData(camNo).screen,'off')
            
        end
        % redraw signal screens
        if handles.bounds(handles.activeScreenNo) == 0
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
            
            for i_marker=1:5
                for i_cam = 1:4
                    cla(handles.signalGroup(i_marker).signalScreen(i_cam));
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
                            'Parent',handles.signalGroup(i_marker).signalScreen(i_cam))
                    end
                end
            end
            hold off
        elseif handles.bounds(handles.activeScreenNo) == 2
            % draw signal screens for the screen group 2
            for i_marker=1:5
                for i_cam = 1:4
                    cla(handles.signalGroup(i_marker).signalScreen(i_cam));
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
                            'Parent',handles.signalGroup(i_marker).signalScreen(i_cam))
                    end
                end
            end
            hold off
        end
         set(handles.activeScreen,'YTick',[],'XTick',[]);% Hide tick markes
    end
guidata(conditionParametersGroup, handles);
end