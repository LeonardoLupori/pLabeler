classdef graphics
    methods(Static)
        
        function handles = createFigures()
            
            % MAIN FIGURE WINDOW
            screenSize = get(0, 'ScreenSize');
            %width = floor(screenSize(3) * (2/4));
            %heigth = floor(screenSize(4) * (2/4));
            
            width = 640;
            heigth = 480;
            
            handles.fig_image = figure('Color',[0.1,0.1,0.1],...
                'Position',[(screenSize(3)-width)/2 (screenSize(4)-heigth)/2 width heigth],...
                'Name','pLabeler - display window',...
                'NumberTitle','off',...
                'MenuBar','none');
            
            % Create the axes
            handles.ax_image = axes('Parent',handles.fig_image,...
                'Units','normalized',...
                'Position',[0 0 1 1]);
            
            handles.imgHandle = imshow(imread('media/pLabelerWelcome.png'),...
                'Parent', handles.ax_image);
            % Create the transparent overlays for the pupil
            overlaySize = [size(handles.imgHandle.CData,1),size(handles.imgHandle.CData,2)];
            handles.overlayPupil = graphics.createOverlay(handles.ax_image, overlaySize);
            % Create a dummy rectangle for the handle
            handles.overlayRectangle = rectangle(handles.ax_image,...
                    'Position',[0 0 0 0],...
                    'EdgeColor', [1 0 0], 'LineWidth', 2, 'LineStyle', ':');
            
            handles.blinkHandle = [];
            handles.rejectHandle = [];
            
            handles.ROI_pupil = [];
            handles.ROI_bBox = [];
            
            axtoolbar(handles.ax_image,{'pan','zoomin','zoomout','restoreview'});
            enableDefaultInteractivity(handles.ax_image);
            
            % For graphical design
            handles.ax_image.Title.FontSize = 16;
            handles.ax_image.Title.Color = [0,.7,.7];
            
            
            %--------------------------------------------------------------
            % MAIN UI AND OPTIONS FIGURE
            %--------------------------------------------------------------
            
            % Create fig_pLabeler and hide until all components are created
            handles.fig_pLabeler = uifigure('Visible', 'off');
            handles.fig_pLabeler.Color = [0.149 0.149 0.149];
            handles.fig_pLabeler.Position = [100 100 350 470];
            handles.fig_pLabeler.Name = 'pLabeler';
            handles.fig_pLabeler.Icon = 'media/icon.png';
            handles.fig_pLabeler.Tag = 'fig_UI';

            % Create FileMenu
            handles.FileMenu = uimenu(handles.fig_pLabeler);
            handles.FileMenu.Text = 'File';

            % Create NewProjectMenu
            handles.NewProjectMenu = uimenu(handles.FileMenu);
            handles.NewProjectMenu.Tooltip = {'Create a new project folder for labeling pupils'};
            handles.NewProjectMenu.Accelerator = 'N';
            handles.NewProjectMenu.Text = 'New Project';

            % Create LoadProjectMenu
            handles.LoadProjectMenu = uimenu(handles.FileMenu);
            handles.LoadProjectMenu.Accelerator = 'L';
            handles.LoadProjectMenu.Text = 'Load Project';

            % Create AddImgsMenu
            handles.AddImgsMenu = uimenu(handles.FileMenu);
            handles.AddImgsMenu.Separator = 'on';
            handles.AddImgsMenu.Text = 'Add Images to current project';

            % Create FromFilesMenu
            handles.FromFilesMenu = uimenu(handles.AddImgsMenu);
            handles.FromFilesMenu.Text = 'From Files';

            % Create FromVideoMenu
            handles.FromVideoMenu = uimenu(handles.AddImgsMenu);
            handles.FromVideoMenu.Text = 'From Video';
            
            % Create SmartMenu
            handles.SmartMenu = uimenu(handles.FromVideoMenu);
            handles.SmartMenu.Tooltip = {'Slow. PCA-based frames selection to get the most differing frames'};
            handles.SmartMenu.Text = 'Smart sample(PCA)';

            % Create RandomMenu
            handles.RandomMenu = uimenu(handles.FromVideoMenu);
            handles.RandomMenu.Tooltip = {'Fast. Random selection of frames'};
            handles.RandomMenu.Text = 'Random sample';

            % Create ExportLabelsMenu
            handles.ExportLabelsMenu = uimenu(handles.FileMenu);
            handles.ExportLabelsMenu.Separator = 'on';
            handles.ExportLabelsMenu.Text = 'Export Labeled Images';
            handles.ExportLabelsMenu.Enable = 'off';

            % Create LabelingMenu
            handles.LabelingMenu = uimenu(handles.fig_pLabeler);
            handles.LabelingMenu.Text = 'Labeling';

            % Create DrawBbMenu
            handles.DrawBbMenu = uimenu(handles.LabelingMenu);
            handles.DrawBbMenu.Text = 'Draw Eye bounding-box  (Q)';

            % Create DeleteBbMenu
            handles.DeleteBbMenu = uimenu(handles.LabelingMenu);
            handles.DeleteBbMenu.Text = 'Delete Eye bounding-box  (shift+del)';

            % Create DrawPupilMenu
            handles.DrawPupilMenu = uimenu(handles.LabelingMenu);
            handles.DrawPupilMenu.Separator = 'on';
            handles.DrawPupilMenu.Text = 'Draw Pupil  (E)';

            % Create DeletePupilMenu
            handles.DeletePupilMenu = uimenu(handles.LabelingMenu);
            handles.DeletePupilMenu.Text = 'Delete Pupil  (del)';

            % Create DeleteAllMenu
            handles.DeleteAllMenu = uimenu(handles.LabelingMenu);
            handles.DeleteAllMenu.Separator = 'on';
            handles.DeleteAllMenu.Text = 'Clear Labels';
            
            % Create BlinkingMenu
            handles.BlinkingMenu = uimenu(handles.LabelingMenu);
            handles.BlinkingMenu.Separator = 'on';
            handles.BlinkingMenu.Text = 'Flag as blink  (B)';
            
            % Create RejectMenu
            handles.RejectMenu = uimenu(handles.LabelingMenu);
            handles.RejectMenu.Separator = 'on';
            handles.RejectMenu.Text = 'Flag as rejected  (X)';

            % Create HelpMenu
            handles.HelpMenu = uimenu(handles.fig_pLabeler);
            handles.HelpMenu.Text = 'Help';

            % Create TutorialMenu
            handles.TutorialMenu = uimenu(handles.HelpMenu);
            handles.TutorialMenu.Text = 'Tutorial';

            % Create PupillometryMenu
            handles.PupillometryMenu = uimenu(handles.HelpMenu);
            handles.PupillometryMenu.Text = 'Pupillometry';

            % Create LogLabel
            handles.LogLabel = uilabel(handles.fig_pLabeler);
            handles.LogLabel.FontColor = [0.9412 0.9412 0.9412];
            handles.LogLabel.Position = [11 209 29 22];
            handles.LogLabel.Text = 'Log:';

            % Create Log
            handles.Log = uitextarea(handles.fig_pLabeler);
            handles.Log.BackgroundColor = [0.9412 0.9412 0.9412];
            handles.Log.Position = [11 41 330 170];
            handles.Log.Editable = 'off';

            % Create CurrentProjectLabel
            handles.CurrentProjectLabel = uilabel(handles.fig_pLabeler);
            handles.CurrentProjectLabel.BackgroundColor = [0 0 0];
            handles.CurrentProjectLabel.FontSize = 11;
            handles.CurrentProjectLabel.FontAngle = 'italic';
            handles.CurrentProjectLabel.FontColor = [1 1 1];
            handles.CurrentProjectLabel.Position = [11 11 329 20];
            handles.CurrentProjectLabel.Text = 'Current Project: ';

            % Create ImAdjPanel
            handles.ImAdjPanel = uipanel(handles.fig_pLabeler);
            handles.ImAdjPanel.ForegroundColor = [0.9412 0.9412 0.9412];
            handles.ImAdjPanel.Title = 'Image Adjustments';
            handles.ImAdjPanel.BackgroundColor = [0.149 0.149 0.149];
            handles.ImAdjPanel.FontSize = 13;
            handles.ImAdjPanel.Position = [11 245 330 137];

            % Create WhiteSliderLabel
            handles.WhiteSliderLabel = uilabel(handles.ImAdjPanel);
            handles.WhiteSliderLabel.FontColor = [0.9412 0.9412 0.9412];
            handles.WhiteSliderLabel.Enable = 'off';
            handles.WhiteSliderLabel.Position = [11 24 36 22];
            handles.WhiteSliderLabel.Text = 'White';

            % Create WhiteSlider
            handles.WhiteSlider = uislider(handles.ImAdjPanel);
            handles.WhiteSlider.Limits = [0 1];
            handles.WhiteSlider.MajorTicks = [];
            handles.WhiteSlider.MinorTicks = [];
            handles.WhiteSlider.Tag = 'slider_wht';
            handles.WhiteSlider.Enable = 'off';
            handles.WhiteSlider.Tooltip = {'Adjust the white level of the current image'};
            handles.WhiteSlider.Position = [60 33 251 3];
            handles.WhiteSlider.Value = 1;

            % Create BlackSliderLabel
            handles.BlackSliderLabel = uilabel(handles.ImAdjPanel);
            handles.BlackSliderLabel.FontColor = [0.9412 0.9412 0.9412];
            handles.BlackSliderLabel.Enable = 'off';
            handles.BlackSliderLabel.Position = [11 4 35 22];
            handles.BlackSliderLabel.Text = 'Black';

            % Create BlackSlider
            handles.BlackSlider = uislider(handles.ImAdjPanel);
            handles.BlackSlider.Limits = [0 1];
            handles.BlackSlider.MajorTicks = [];
            handles.BlackSlider.MinorTicks = [];
            handles.BlackSlider.Tag = 'slider_blk';
            handles.BlackSlider.Enable = 'off';
            handles.BlackSlider.Tooltip = {'Adjust the black level of the current image'};
            handles.BlackSlider.Position = [60 13 251 3];
            handles.BlackSlider.Value = 0;

            % Create InvertImCheckBox
            handles.InvertImCheckBox = uicheckbox(handles.ImAdjPanel);
            handles.InvertImCheckBox.Text = 'Invert Image';
            handles.InvertImCheckBox.FontColor = [0.9412 0.9412 0.9412];
            handles.InvertImCheckBox.Position = [11 84 160 22];

            % Create AutoCntrCheckBox
            handles.AutoCntrCheckBox = uicheckbox(handles.ImAdjPanel);
            handles.AutoCntrCheckBox.Text = 'Auto Contrast';
            handles.AutoCntrCheckBox.FontColor = [0.9412 0.9412 0.9412];
            handles.AutoCntrCheckBox.Position = [11 54 160 22];
            handles.AutoCntrCheckBox.Value = true;

            % Create AutoCntrSwitch
            handles.AutoCntrSwitch = uiswitch(handles.ImAdjPanel, 'slider');
            handles.AutoCntrSwitch.Items = {'best fit', 'min/max'};
            handles.AutoCntrSwitch.FontColor = [0.9412 0.9412 0.9412];
            handles.AutoCntrSwitch.Position = [222 58 41 18];
            handles.AutoCntrSwitch.Value = 'best fit';

            % Create NextImButton
            handles.NextImButton = uibutton(handles.fig_pLabeler, 'push');
            handles.NextImButton.Enable = 'off';
            handles.NextImButton.Position = [181 390 160 21];
            handles.NextImButton.Text = 'Next Image (D) >';

            % Create PrevImButton
            handles.PrevImButton = uibutton(handles.fig_pLabeler, 'push');
            handles.PrevImButton.Enable = 'off';
            handles.PrevImButton.Position = [11 390 160 21];
            handles.PrevImButton.Text = '< Prev Image (A)';

            % Create DrawPupButton
            handles.DrawPupButton = uibutton(handles.fig_pLabeler, 'push');
            handles.DrawPupButton.Enable = 'off';
            handles.DrawPupButton.Position = [11 421 160 41];
            handles.DrawPupButton.Text = 'Draw Pupil(E)';

            % Create DrawBbButton
            handles.DrawBbButton = uibutton(handles.fig_pLabeler, 'push');
            handles.DrawBbButton.Enable = 'off';
            handles.DrawBbButton.Position = [181 421 160 40];
            handles.DrawBbButton.Text = 'Draw BBox (Q)';

            % Show the figure after all components are created
            handles.fig_pLabeler.Visible = 'on';
        end
        
        function processedImg = imageProprocess(inputImage, app)
            
            processedImg = inputImage;
            
            % INVERT IMAGE
            toInvert = app.gHandles.InvertImCheckBox.Value;
            if toInvert
                processedImg = imcomplement(processedImg);
            end
            
            % CONTRAST ADJUSTMENT
            autoContrast = app.gHandles.AutoCntrCheckBox.Value;
            if autoContrast
                % Get the contrast limits based on the selected method
                if strcmpi(app.gHandles.AutoCntrSwitch.Value, 'min/max')
                    imLimits = [min(inputImage(:)), max(inputImage(:))];
                elseif strcmpi(app.gHandles.AutoCntrSwitch.Value, 'best fit')
                    imLimits = [quantile(inputImage(:), .02),...
                        quantile(inputImage(:), .98)];
                end
                imLimits = imLimits./ 255;
            else
                imLimits = [app.gHandles.BlackSlider.Value,...
                    app.gHandles.WhiteSlider.Value];
            end
            % Rescale the image values
            processedImg = imadjust(processedImg, imLimits);
        end
        
        function [img, label, isBlinking, isRejected, imNumber, imName, bBox] = getCurrImage(app)
            if app.currImgID == 0
                msg = "No image selected to display";
                functionality.writeToLog(app.gHandles.Log, msg)
                return
            end
            
            % Locate the current image in the XML based on its ID
            imList = app.xmlStruct.images.image;
            [imName, idx] = functionality.imageID2name(app.currImgID,...
                app.xmlStruct);
            imNumber = [idx, length(app.xmlStruct.images.image)];
            
            % Load the frame
            img = imread(app.projectPath + filesep + "frames" + filesep + imName);
            % Try to load labels if they exist
            if strlength(imList(idx).labelFileName) == 0
                label = [];
            else
                label = imread(app.projectPath + filesep + "labels" + filesep + imList(idx).labelFileName);
            end
            
            % Eye Bounding Box
            bBox = imList(idx).eyeBbox;
            
            % Booleans
            isBlinking = imList(idx).isBlinking;
            isRejected = imList(idx).isRejected;
            
        end
        
        function updateGraphics(app)
            if ~isfield(app.xmlStruct,'images')
                img = imread('media/pLabelerWelcome.png');
                label = [];
                isBlinking = 0;
                isRejected = 0;
                imNumber = [1, 1]; 
                imName = "Welcome"; 
                bBox = struct('x',0,'y',0,'width',0,'height',0);
            else
                % Get the current image along with some metadata
                [img, label, isBlinking, isRejected, imNumber, imName, bBox] = graphics.getCurrImage(app);
                img = graphics.imageProprocess(img, app);
            end
            
            % Check if the new Img has the same resolution as the old one
            % and update the Image showed
            oldRes = size(app.gHandles.imgHandle.CData);
            newRes = size(img);
            if newRes(1) == oldRes(1) && newRes(2) == oldRes(2)
                % Update the data on the displayed image object
                app.gHandles.imgHandle.CData = img;
            else
                app.gHandles.imgHandle = imshow(img,'Parent',app.gHandles.ax_image);
                graphics.interactivity(app, true)
                app.gHandles.overlayPupil = graphics.createOverlay(app.gHandles.ax_image, size(img));
                graphics.createBbox(app)
            end
            
            % Update the pupil area showed
            if isempty(label)
                newMask = zeros(size(app.gHandles.imgHandle.CData,1),...
                    size(app.gHandles.imgHandle.CData,2), 'double');
            else
                newMask = graphics.label2mask(label) * 0.4;
            end
            graphics.updateOverlays(app, newMask, [])
            
            % Update the eye Bounding box showed
            newRectPos = functionality.bBoxStruct2position(bBox);
            app.gHandles.overlayRectangle.Position = newRectPos;
            
            % Update the figure title
            figTitle = sprintf("pLabeler - display window - (%u/%u) - %s",...
                imNumber(1), imNumber(2), imName);
            app.gHandles.fig_image.Name = figTitle;
            colormap(app.gHandles.ax_image,'gray')
            
            % Delete existing blink and rejected text objects
            if ishandle(app.gHandles.blinkHandle)
                delete(app.gHandles.blinkHandle)
            end
            if ishandle(app.gHandles.rejectHandle)
                delete(app.gHandles.rejectHandle)
            end
            
            % Draw new blinking and rejected text objects if appropiate
            if isBlinking
                app.gHandles.blinkHandle = text(5,30,'Blink','FontSize',40,...
                    'Color',[.39, .83 .07],'FontWeight','bold');
            end
            if isRejected
                x = round(size(img,2)/2) - 100;
                y = round(size(img,1)/2);
                app.gHandles.rejectHandle = text(x,y,'Rejected','FontSize',40,...
                    'Color',[.9, 0 0],'FontWeight','bold');
            end
            
        end
        
        function overlayHandle = createOverlay(targetAx, overlaySize)
            % Generate uniform image to overlay
            pupilOverlay = zeros([overlaySize,3],'uint8');
            pupilOverlay(:,:,2:3) = 255;
            
            completelyTransparent = zeros(overlaySize,'double');
            % Draw the overlay for the pupil and the eye bounding box
            hold(targetAx,'on')
            overlayHandle = imshow(pupilOverlay,'Parent',targetAx);
            % Set the transparency to zero
            overlayHandle.AlphaData = completelyTransparent;
            hold(targetAx,'off')
        end
        
        function createBbox(app)
            if ~ishandle(app.gHandles.overlayRectangle)
                app.gHandles.overlayRectangle = rectangle(app.gHandles.ax_image,...
                    'Position',[0 0 0 0],'EdgeColor', [1 0 0],...
                    'LineWidth', 2, 'LineStyle', ':');
            end
        end
        
        function updateOverlays(app, newMask, bBox)
            if ~isempty(newMask)
                if islogical(newMask)
                    transparency = 0.4;
                    newMask = newMask*transparency;
                end
                app.gHandles.overlayPupil.AlphaData = newMask;
            end
            if ~isempty(bBox)
                if isstruct(bBox)
                    app.gHandles.overlayRectangle.Position = [bBox.x, bBox.y, bBox.width, bBox.height];
                else
                    app.gHandles.overlayRectangle.Position = bBox;
                end
                app.lastDrawnBbox = app.gHandles.overlayRectangle.Position;
            end
        end
        
        function mask = label2mask(labelImg)
            mask = double(labelImg(:,:,1) / 255);
        end
        
        function interactivity(app, state)
            if state
                axtoolbar(app.gHandles.ax_image,{'pan','zoomin','zoomout','restoreview'});
                enableDefaultInteractivity(app.gHandles.ax_image);
            else
                disableDefaultInteractivity(app.gHandles.ax_image);
            end
        end
        
    end
end














