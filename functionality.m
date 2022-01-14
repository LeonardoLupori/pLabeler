classdef functionality
    
    methods(Static)
        %------------------------------------------------------------------
        % Main function to assign callbacks to all the GUI buttons and
        % menus.
        %------------------------------------------------------------------
        function assignCallbacks(app)
            gHandles = app.gHandles;
            
            % FIGURE KEYPRESSES
            gHandles.fig_image.KeyPressFcn = {@functionality.keyParser,app};
            
            % New Project
            gHandles.NewProjectMenu.MenuSelectedFcn = {@functionality.NewProjectMenuClbk, app};
            % Load Project
            gHandles.LoadProjectMenu.MenuSelectedFcn = {@functionality.LoadProjectMenuClbk, app};
            % Add frames from Images
            gHandles.FromFilesMenu.MenuSelectedFcn = {@functionality.FromFilesMenuClbk, app};
            % Add frames from Video (SMART)
            gHandles.SmartMenu.MenuSelectedFcn = {@functionality.FromVideoMenuClbk, app};
            % Add frames from Video (RANDOM)
            gHandles.RandomMenu.MenuSelectedFcn = {@functionality.FromVideoMenuClbk, app};
            % EXPORT labeled images
            gHandles.ExportLabelsMenu.MenuSelectedFcn = {@functionality.exportLabeledImagesClbk, app};
            
            
            % DRAW PUPIL (button)
            gHandles.DrawPupButton.ButtonPushedFcn = {@functionality.DrawPupButtonClbk, app};
            % DRAW PUPIL (menu)
            gHandles.DrawPupilMenu.MenuSelectedFcn = {@functionality.DrawPupButtonClbk, app};
            % Delete PUPIL (menu)
            gHandles.DeletePupilMenu.MenuSelectedFcn = {@functionality.DeletePupButtonClbk , app};
            % DRAW eye BOUNDING BOX (button)
            gHandles.DrawBbButton.ButtonPushedFcn = {@functionality.DrawBbButtonClbk, app};
            % DRAW eye BOUNDING BOX (menu)
            gHandles.DrawBbMenu.MenuSelectedFcn = {@functionality.DrawBbButtonClbk, app};
            % Delete eye Bounding Box (menu)
            gHandles.DeleteBbMenu.MenuSelectedFcn = {@functionality.DeleteBbMenuClbk, app};
            % Delete all labels for this image
            gHandles.DeleteAllMenu.MenuSelectedFcn = {@functionality.DeleteAllMenuClbk, app};
            % Flag this image as rejected
            gHandles.RejectMenu.MenuSelectedFcn = {@functionality.RejectMenuClbk, app};
            % Flag this image as a BLINK
            gHandles.BlinkingMenu.MenuSelectedFcn = {@functionality.BlinkingMenuClbk, app};
            
            % INVERT image
            gHandles.InvertImCheckBox.ValueChangedFcn = {@functionality.InvertImCheckBoxClbk,app};
            % AUTO CONTRAST checkbox
            gHandles.AutoCntrCheckBox.ValueChangedFcn = {@functionality.AutoCntrCheckBoxClbk,app};
            % AUTO CONTRAST method switch
            gHandles.AutoCntrSwitchClbk.ValueChangedFcn = {@functionality.AutoCntrSwitchClbk, app};
            % Black SLIDER
            gHandles.BlackSlider.ValueChangedFcn = {@functionality.BlackSliderClbk ,app};
            % White SLIDER
            gHandles.WhiteSlider.ValueChangedFcn = {@functionality.WhiteSliderClbk ,app};
            
            % Previous image
            gHandles.PrevImButton.ButtonPushedFcn = {@functionality.PrevImButtonClbk, app};
            % Next Image
            gHandles.NextImButton.ButtonPushedFcn = {@functionality.NextImButtonClbk, app};
            
            % Pupillometry
            gHandles.PupillometryMenu.MenuSelectedFcn = {@functionality.PupillometryMenuClbk, app};
            % Tutorial
            app.gHandles.TutorialMenu.MenuSelectedFcn = {@functionality.TutorialMenuClbk, app};
            
        end
        
        
        %------------------------------------------------------------------
        % CALLBACK FUNCTIONS
        %------------------------------------------------------------------
        
        % NEW PROJECT
        function NewProjectMenuClbk(~,~,app)
            [bool, projectFolder, projectName, xmlStruct] = projManager.createNewProj(app.defPath,app.gHandles.Log);
            if bool
                app.defPath = string(projectFolder);
                app.projectName = string(projectName);
                app.projectPath = string(projectFolder);
                app.gHandles.CurrentProjectLabel.Text = "Current Project: " + ...
                    projectName;
                
                app.xmlStruct = xmlStruct;
                functionality.enableTool(app,'onlyForAddingImages','on')
                graphics.updateGraphics(app);
            end
        end
        
        % LOAD PROJECT
        function LoadProjectMenuClbk(~,~,app)
            % Search for a project .XML file
            tit = "Load a project XML file.";
            [fN,pth] = uigetfile({'*.xml', 'pLabeler Project (*.xml)'},...
                tit, app.defPath);
            figure(app.gHandles.fig_pLabeler)   % Give focus back to main UI
            if isequal(fN, 0)
                functionality.writeToLog(app.gHandles.Log, "No project loaded.")
                return
            end
            
            S = readstruct([pth filesep fN]);
            app.defPath = string(pth);
            app.projectName = string(S.projectInfo.projectName);
            app.projectPath = string(pth);
            app.currImgID = S.projectInfo.currentImgID;
            app.gHandles.CurrentProjectLabel.Text = "Current Project: " + ...
                S.projectInfo.projectName;
            app.xmlStruct = S;
            
            msg = sprintf("Loaded project: '%s'", string(S.projectInfo.projectName));
            functionality.writeToLog(app.gHandles.Log, msg)
            functionality.enableTool(app,'all','on')
            
            
            graphics.updateGraphics(app)
            
        end
        
        % ADD IMAGES from image FILES (.png, .jpg or .tif)
        function FromFilesMenuClbk(~,~,app)
            
            % Check if a project is currently loaded
            if strlength(app.projectPath) == 0 || strlength(app.projectName) == 0
                msg = "ERROR. No project loaded.";
                functionality.writeToLog(app.gHandles.Log, msg)
                return
            end
            
            % Let user select one or more images
            functionality.writeToLog(app.gHandles.Log, "Select images to import.")
            tit = "Select images to import to the project";
            [fN,pth] = uigetfile({'*.jpg;*.tif;*.png', 'Images (*.jpg, *.tif, *.png)'},...
                tit, app.defPath, 'MultiSelect', 'on');
            if isequal(fN, 0)
                functionality.writeToLog(app.gHandles.Log, "aborted by user.")
                return
            end
            
            % If user selected only one file, convert it to cell anyways so
            % that the same syntax (cell {} indexing) can be used
            if ~iscell(fN)
                fN = {fN};
            end
            
            functionality.enableTool(app,'all','off')
            app.gHandles.fig_image.Pointer = 'watch';
            app.gHandles.fig_pLabeler.Pointer = 'watch';
            
            % Add the images one by one
            msg = sprintf("Adding %u images...", length(fN));
            functionality.writeToLog(app.gHandles.Log, msg)
            success = zeros(length(fN),1,'logical');
            for i = 1:length(fN)
                if mod(i,20) == 0
                    msg = sprintf("processing image (%u/%u)...",i,length(fN));
                    functionality.writeToLog(app.gHandles.Log, msg)
                end
                im = imread([pth filesep fN{i}]);
                im = im2gray(im);
                % Actually add the image
                bool = functionality.addImageToProject(im,app);
                success(i) = bool;
                if ~bool
                    msg = "ERROR adding image: " + fN{i};
                    functionality.writeToLog(app.gHandles.Log, msg)
                end
            end
            
            functionality.updateStructFromFile(app)
            functionality.enableTool(app,'all','on')
            app.gHandles.fig_image.Pointer = 'arrow';
            app.gHandles.fig_pLabeler.Pointer = 'arrow';
            
            graphics.updateGraphics(app)
            
            msg = sprintf("Successfully added %u images", sum(bool));
            functionality.writeToLog(app.gHandles.Log, msg)
        end
        
        % ADD IMAGES from a VIDEO
        function FromVideoMenuClbk(src,~,app)
            
            % Check if a project is currently loaded
            if strlength(app.projectPath) == 0 || strlength(app.projectName) == 0
                msg = "ERROR. No project loaded.";
                functionality.writeToLog(app.gHandles.Log, msg)
                return
            end
            
            % Let user select one or more videos
            functionality.writeToLog(app.gHandles.Log, "Select video to import.")
            tit = "Select images to import to the project";
            filter = getFilterSpec(VideoReader.getFileFormats());
            [fN,pth] = uigetfile(filter,tit, app.defPath, 'MultiSelect', 'on');
            if isequal(fN, 0)
                functionality.writeToLog(app.gHandles.Log, "aborted by user.")
                return
            end
            
            % If user selected only one file, convert it to cell anyways so
            % that the same syntax (cell {} indexing) can be used
            if ~iscell(fN)
                fN = {fN};
            end
            
            % Specify how many frames to extract
            dlgtitle = "Frames extraction";
            prompt = "How many frames to extract?";
            dims = repmat([1,50], length(prompt),1);
            answer = inputdlg(prompt,dlgtitle,dims,"100");
            % Return if user clicks cancel
            if isempty(answer)
                functionality.writeToLog(app.gHandles.Log, "aborted by user.")
                return
            end
            % Check if the # of requested frames is a positive number
            reqFrames = round(str2double(answer{1}));
            if reqFrames < 1 || isnan(reqFrames)
                functionality.writeToLog(app.gHandles.Log,...
                    "Invalid number of requested frames.")
                return
            end
            
            functionality.enableTool(app,'all','off')
            app.gHandles.fig_image.Pointer = 'watch';
            app.gHandles.fig_pLabeler.Pointer = 'watch';
            
            % Cycle through all the videos
            for i = 1:length(fN)
                videoPath = [pth filesep fN{i}];
                if src == app.gHandles.SmartMenu
                    msg = sprintf('Smart extracting %u frames from video (%u/%u)...',...
                        reqFrames,i,length(fN));
                    functionality.writeToLog(app.gHandles.Log, msg)
                    extractedFrames = imageManager.extractFrameFromVideo_smart(...
                        videoPath, reqFrames);
                elseif src == app.gHandles.RandomMenu
                    msg = sprintf('Randomly extracting %u frames from video (%u/%u)...',...
                        reqFrames,i,length(fN));
                    functionality.writeToLog(app.gHandles.Log, msg)
                    extractedFrames = imageManager.extractFrameFromVideo_random(...
                        videoPath, reqFrames);
                end
                functionality.writeToLog(app.gHandles.Log, "Adding frames to the project...")
                % Add each extracted frame one by one
                framesAdded = 0;
                for j = 1:size(extractedFrames,3)
                    bool = functionality.addImageToProject(extractedFrames(:,:,j),app);
                    framesAdded = framesAdded + bool;
                end
                msg = sprintf("Successfully added %u images", framesAdded);
                functionality.writeToLog(app.gHandles.Log, msg)
            end
            
            functionality.updateStructFromFile(app)
            functionality.enableTool(app,'all','on')
            app.gHandles.fig_image.Pointer = 'arrow';
            app.gHandles.fig_pLabeler.Pointer = 'arrow';
            app.defPath = string(pth);
            
            graphics.updateGraphics(app)
            
            functionality.writeToLog(app.gHandles.Log, "Success.")
            
            
        end
        
        % EXPORT LABELED IMAGES
        function exportLabeledImagesClbk(~,~,app)
            msg = "Exporting this labeled Dataset...";
            functionality.writeToLog(app.gHandles.Log, msg)

            % Create a new folder tree for this exported dataset
            timeStr = datestr(now, "YYYYmmDD_hhMMss");
            foldName = string(timeStr) + "_exportedDataset";
            
            fullFramesFold = app.projectPath + filesep + foldName + filesep + "fullFrames" + filesep;
            annotFold = app.projectPath + filesep + foldName + filesep + "annotation" + filesep;
            pngFold = annotFold + "png" + filesep;
            
            mkdir(app.projectPath + filesep + foldName + filesep)
            mkdir(fullFramesFold)
            mkdir(annotFold)
            mkdir(pngFold)
            
            msg = "Created export folder:\n\t" + foldName;
            functionality.writeToLog(app.gHandles.Log, msg)

            % Create an empty struct with images info
            S = struct('filename',[],...
                'eye',[],...
                'blink',[],...
                'exp',[],...
                'w',[],...
                'h',[],...
                'roi_x',[],...
                'roi_y',[],...
                'roi_w',[],...
                'sub',[]);
            
            % Struct with all the images in the dataset
            imgStruct = app.xmlStruct.images.image;

            totalImages = size(imgStruct,2);
            skippedImages = 0;
            exportedImages = 0;

            count = 1;
            for i = 1:size(imgStruct,2)
                % Skip if the image has no label
                if imgStruct(i).labelFileName == ""
                    skippedImages = skippedImages + 1;
                    continue
                end
                % Skip if the image has no eye b-box
                if isstring(imgStruct(i).eyeBbox.x) && imgStruct(i).eyeBbox.x == ""
                    skippedImages = skippedImages + 1;
                    continue
                end
                % Skip if the image is rejected
                if imgStruct(i).isRejected
                    skippedImages = skippedImages + 1;
                    continue
                end
                
                % Determine the correct resize factor
                biggestEyeSize = max(imgStruct(i).eyeBbox.width, imgStruct(i).eyeBbox.height);
                resizeFactor = 128 / biggestEyeSize;
                
                % Load, resize and export the image
                img = imread(app.projectPath + filesep + "frames" + filesep + imgStruct(i).frameFileName);
                imgOut = imresize(img, resizeFactor);
                imwrite(imgOut, fullFramesFold + imgStruct(i).frameFileName)
                % Load, resize and export the label
                mask = imread(app.projectPath + filesep + "labels" + filesep + imgStruct(i).labelFileName);
                maskOut = imresize(mask, resizeFactor, 'nearest');
                imwrite(maskOut, pngFold + imgStruct(i).labelFileName)

                S(count).filename = imgStruct(i).frameFileName;
                S(count).eye = 1;
                S(count).blink = imgStruct(i).isBlinking;
                S(count).exp = 'pLabeler';
                S(count).w = size(imgOut,2);
                S(count).h = size(imgOut,1);
                S(count).roi_x = round(imgStruct(i).eyeBbox.x * resizeFactor);
                S(count).roi_y = round(imgStruct(i).eyeBbox.y * resizeFactor);
                S(count).roi_w = 128;
                S(count).sub = timeStr;
                
                exportedImages = exportedImages + 1;
                count = count+1;
            end
            
            % Save the annotations CSV file
            T = struct2table(S);
            writetable(T,annotFold + "annotations.csv")
            
            msg = "Dataset exported!";
            functionality.writeToLog(app.gHandles.Log, msg)

            msg = sprintf('Total: %u images.\n\t- %u Exported Images\n\t- %u Skipped Images',...
                totalImages, exportedImages, skippedImages);
            functionality.writeToLog(app.gHandles.Log, msg)
            
        end
        
        % Select PREVIOUS image
        function PrevImButtonClbk(~, ~, app)
            % Update the currImg ID value to the next available image ID
            idList = [app.xmlStruct.images.image.id];
            idx = find(idList == app.currImgID);
            if idx == 1
                app.currImgID = idList(end);
            else
                app.currImgID = idList(idx-1);
            end
            graphics.updateGraphics(app)
        end
        
        % Select NEXT image
        function NextImButtonClbk(~, ~, app)
            % Update the currImg ID value to the next available image ID
            idList = [app.xmlStruct.images.image.id];            
            idx = find(idList == app.currImgID);
            if idx == length(idList)
                app.currImgID = idList(1);
            else
                app.currImgID = idList(idx+1);
            end
            graphics.updateGraphics(app)
        end
        
        % Delete the PUPIL label of the current image
        function DeletePupButtonClbk(~, ~, app)
            imageManager.deletePupilLabel(app)
            graphics.updateGraphics(app)
        end
        
        % Draw a PUPIL label
        function DrawPupButtonClbk(~, ~, app)
            if ishandle(app.gHandles.ROI_pupil)
                return
            end
            graphics.interactivity(app, false)
            app.gHandles.overlayPupil.AlphaData(:) = 0;
            app.gHandles.ROI_pupil = drawellipse(app.gHandles.ax_image,'color',[0 1 1]);
        end
        
        % Draw the eye BOUNDING BOX
        function DrawBbButtonClbk(~, ~, app)
            if ishandle(app.gHandles.ROI_bBox)
                return
            end
            
            graphics.interactivity(app, false)
            
            if isempty(app.lastDrawnBbox)
                app.gHandles.ROI_bBox = drawrectangle(app.gHandles.ax_image,...
                    'color',[1 0 0],'AspectRatio',1, 'FixedAspectRatio', true);
            else
                sizeCurrentImg = size(app.gHandles.imgHandle.CData);
                if app.lastDrawnBbox(1) + app.lastDrawnBbox(3) < sizeCurrentImg(2) ||...
                        app.lastDrawnBbox(2) + app.lastDrawnBbox(4) < sizeCurrentImg(1)
                    app.gHandles.ROI_bBox = drawrectangle(app.gHandles.ax_image,...
                        'color',[1 0 0],'Position',app.lastDrawnBbox,'AspectRatio',1,...
                        'FixedAspectRatio', true);
                else
                    app.lastDrawnBbox = [];
                    app.gHandles.ROI_bBox = drawrectangle(app.gHandles.ax_image,...
                        'color',[1 0 0],'AspectRatio',1,'FixedAspectRatio', true);
                end
            end
            
            
        end
        
        % Delete the eye BOUNDING BOX
        function DeleteBbMenuClbk(~, ~, app)
            projManager.deleteBbox(app)
            graphics.updateGraphics(app)
        end
        
        % Delete both the eye bounding box and the pupil
        function DeleteAllMenuClbk(src, event, app)
            functionality.DeletePupButtonClbk(src, event, app)
            functionality.DeleteBbMenuClbk(src, event, app)
        end
        
        % Flag this image as rejected
        function RejectMenuClbk(~, ~, app)
            projManager.toggleRejectedXML(app)
            graphics.updateGraphics(app)
        end
        
        % Flag this image as a BLINK
        function BlinkingMenuClbk(~, ~, app)
            projManager.toggleBlinkXML(app)
            graphics.updateGraphics(app)
        end
        
        % AUTO-CONTRAST
        function AutoCntrCheckBoxClbk(src, ~, app)
            if src.Value    % If the chackbox was ticked
                functionality.enableTool(app, 'sliders', 'off')
                functionality.enableTool(app, 'autoContrastMethod', 'on')
            else            % If the chackbox was un-ticked
                functionality.enableTool(app, 'sliders', 'on')
                functionality.enableTool(app, 'autoContrastMethod', 'off')
            end
            
            graphics.updateGraphics(app)
        end
        
        % AUTO-CONTRAST METHOD
        function AutoCntrSwitchClbk(~, ~, app)
            graphics.updateGraphics(app)
        end
        
        % INVERT image
        function InvertImCheckBoxClbk(~, ~, app)
            graphics.updateGraphics(app)
        end
        
        % BLACK SLIDER
        function BlackSliderClbk(src, ~, app)
            if src.Value > app.gHandles.WhiteSlider.Value
                src.Value = app.gHandles.WhiteSlider.Value - 0.01;
            end
            graphics.updateGraphics(app)
        end
        
        % WHITE SLIDER
        function WhiteSliderClbk(src, ~, app)
            if src.Value < app.gHandles.BlackSlider.Value
                src.Value = app.gHandles.BlackSlider.Value + 0.01;
            end
            graphics.updateGraphics(app)
        end
        
        % Link to www.pupillometry.it website
        function PupillometryMenuClbk(~,~,app)
            functionality.writeToLog(app.gHandles.Log, "Link to www.pupillometry.it")
            web('www.pupillometry.it', '-browser')
        end
        
        % Link to the wiki of the software
        function TutorialMenuClbk(~, ~, app)
            functionality.writeToLog(app.gHandles.Log, "Link to pLabeler Wiki")
            web('https://github.com/LeonardoLupori/pLabeler/wiki', '-browser')
        end
        
        %------------------------------------------------------------------
        % ADDITIONAL FUNCTIONS
        %------------------------------------------------------------------
        
        % Tool for easily writing in the Log Window
        function writeToLog(logHandle, string)
            time = datestr(now, "[hh:MM:ss]");
            newString = time + "-" + string;
            
            if all(strlength(logHandle.Value) == 0)
                logHandle.Value = newString;
            else
                newValue = cat(1, logHandle.Value, newString);
                logHandle.Value = newValue;
            end
            drawnow
            scroll(logHandle, 'bottom')
        end
        
        % Function for adding single images to the project
        function bool = addImageToProject(img, app)
            
            projectPath = app.projectPath;
            projectName = app.projectName;
            
            % Load the XML as a struct
            xmlFullPath = projectPath + filesep +  "pLabelerProject.xml";
            S = readstruct(xmlFullPath);
            
            % Create a filename for the new image
            newImgID = S.projectInfo.lastImageID + 1;
%             newImgFileName = sprintf("%05u" + "_frame_" + projectName + ".jpg", newImgID);
            newImgFileName = sprintf("%05u" + "_frame_" + projectName + ".png", newImgID);
            
            % Write the image in the "frames" folder
            imwrite(img, projectPath + filesep + "frames" + filesep + newImgFileName)
            
            % Update the XML with info of this new image
            S = projManager.addImgToXmlStruct(S, newImgFileName);
            writestruct(S, xmlFullPath);
            
            if app.currImgID == 0
                app.currImgID = newImgID;
            end
            
            bool = true;
        end
        
        % Load the latest XML file as a GUI property
        function updateStructFromFile(app)
            S = readstruct(app.projectPath + filesep + "pLabelerProject.xml");
            app.xmlStruct = S;
        end
        
        % Save the data in the xmlStruct GUI property in the project XML
        function updateXMLfileFromStruct(app)
            xmlFullPath = app.projectPath + filesep +  "pLabelerProject.xml";
            writestruct(app.xmlStruct, xmlFullPath);
        end
        
        % Get the image name and the index in the images XML struct of an
        % image from its ID
        function [imageName, imageIndex] = imageID2name(imageID, xmlStruct)  
            imList = xmlStruct.images.image;
            % Locate the current image in the XML based on its ID
            idx = find([imList.id] == imageID);
            imageIndex = idx;
            imageName = imList(idx).frameFileName;
        end
        
        % Convert strings in logical (e.g., "True" to true)
%         function bool = str2logical(str)
%             trueList = ["True","true","1"];
%             falseList = ["False","false","0"];
%             if ismember(str,trueList)
%                 bool = true;
%             elseif ismember(str,falseList)
%                 bool = false;
%             else
%                 error("Unrecognized string")
%             end
%         end
        
        % Enable or disable groups of UI elements
        function enableTool(app, handleSubset, state)
            switch handleSubset
                case 'buttons'
                    handleList = [app.gHandles.DrawPupButton, app.gHandles.DrawBbButton,...
                        app.gHandles.PrevImButton, app.gHandles.NextImButton];
                case 'sliders'
                    handleList = [app.gHandles.WhiteSlider, app.gHandles.BlackSlider,...
                        app.gHandles.WhiteSliderLabel, app.gHandles.BlackSliderLabel];
                case 'autoContrastMethod'
                    handleList = app.gHandles.AutoCntrSwitch;
                case 'all'
                    handleList = [app.gHandles.FileMenu, app.gHandles.LabelingMenu,...
                        app.gHandles.HelpMenu,...
                        app.gHandles.DrawPupButton, app.gHandles.DrawBbButton,...
                        app.gHandles.PrevImButton, app.gHandles.NextImButton,...
                        app.gHandles.InvertImCheckBox, app.gHandles.AutoCntrCheckBox,...
                        app.gHandles.AutoCntrSwitch, app.gHandles.WhiteSlider,...
                        app.gHandles.WhiteSliderLabel, app.gHandles.BlackSlider,...
                        app.gHandles.BlackSliderLabel, app.gHandles.AddImgsMenu,...
                        app.gHandles.ExportLabelsMenu];
                case 'noProjectLoaded'
                    handleList = [app.gHandles.AddImgsMenu, app.gHandles.LabelingMenu,...
                        app.gHandles.DrawPupButton, app.gHandles.DrawBbButton,...
                        app.gHandles.PrevImButton, app.gHandles.NextImButton,...
                        app.gHandles.InvertImCheckBox, app.gHandles.AutoCntrCheckBox,...
                        app.gHandles.AutoCntrSwitch, app.gHandles.WhiteSlider,...
                        app.gHandles.WhiteSliderLabel, app.gHandles.BlackSlider,...
                        app.gHandles.BlackSliderLabel];
                case 'onlyForAddingImages'
                    handleList = [app.gHandles.NewProjectMenu, app.gHandles.LoadProjectMenu,...
                        app.gHandles.AddImgsMenu];
            end
            
            % Enable or disable all the elements of the handle subset
            for i = 1:length(handleList)
                handleList(i).Enable = state;
            end
        end
        
        % Parse key press to execute functions
        function keyParser(src,event,app)
            
            % Prevent keyboards interactions if any of this conditions is
            % met
            conditionsForSkipping = ...
                strlength(app.projectName) == 0 ||...   % No project was loaded
                ~isfield(app.xmlStruct,'images') ||...    % No images field in the XML
                ~isfield(app.xmlStruct.images,'image');
            if conditionsForSkipping
                return
            end
            
            
            key = event.Key;
            modifier = event.Modifier;
            
            switch key
                case 'a'
                    functionality.PrevImButtonClbk(src, event, app)
                case 'd'
                    functionality.NextImButtonClbk(src, event, app)
                case 'e'
                    functionality.DrawPupButtonClbk(src, event, app)
                case 'q'
                    functionality.DrawBbButtonClbk(src, event, app)
                case 'b'
                    functionality.BlinkingMenuClbk(src, event, app)
                case 'x'
                    functionality.RejectMenuClbk(src, event, app)
                case {'space', 'return'}     
                    % when the user "accepts" a pupil ROI
                    if ishandle(app.gHandles.ROI_pupil)
                        mask = createMask(app.gHandles.ROI_pupil, app.gHandles.imgHandle);
                        graphics.updateOverlays(app, mask, [])
                        delete(app.gHandles.ROI_pupil)
                        imageManager.addPupilLabel(app, mask)
                    end
                    % when the user "accepts" an eye bounding box
                    if ishandle(app.gHandles.ROI_bBox)
                        boxStruct = functionality.pos2bBoxStruct(floor(app.gHandles.ROI_bBox.Position));
                        graphics.updateOverlays(app, [], boxStruct)
                        delete(app.gHandles.ROI_bBox)
                        projManager.addBbox(app, boxStruct);
                    end
                    graphics.interactivity(app, true)
                    
                case {'escape', 'backspace'}
                    if ishandle(app.gHandles.ROI_pupil)
                        delete(app.gHandles.ROI_pupil)
                    end
                    if ishandle(app.gHandles.ROI_bBox)
                        delete(app.gHandles.ROI_bBox)
                    end
                    graphics.interactivity(app, true)
                case 'delete'
                    if strcmp(modifier, 'shift')
                        functionality.DeleteBbMenuClbk(src, event, app)
                    else
                        functionality.DeletePupButtonClbk(src, event, app)
                    end
            end
            
            
        end
        
        % Converts the bounding box struct in a "position" vector (x,y,w,h)
        function positionVector = bBoxStruct2position(struct)
            if ~isnumeric(struct.x) || isnan(struct.x)
                positionVector = zeros(4,1);
            else
                positionVector = [struct.x,struct.y,struct.width,struct.height];
            end
        end
        
        % Converts a "position" vector (x,y,w,h) into a bounding box struct
        function bBoxStruct = pos2bBoxStruct(positionVector)
            if isempty(positionVector)
                bBoxStruct = struct('x',NaN,'y',NaN, 'width',NaN, 'height',NaN);
            else
                bBoxStruct = struct('x', positionVector(1),'y', positionVector(2),...
                    'width',positionVector(3),'height',positionVector(4));
            end
        end
    end
end




