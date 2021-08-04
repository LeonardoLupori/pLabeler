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
            
            
            % DRAW PUPIL (button)
            gHandles.DrawPupButton.ButtonPushedFcn = {@functionality.DrawPupButtonClbk, app};
%             gHandles.DrawPupilMenu.MenuSelectedFcn = 
%             
%             gHandles.DrawBbButton.ButtonPushedFcn = 
%             gHandles.DrawBbMenu.MenuSelectedFcn = 
            
                        
            
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
                functionality.enableTool(app,'buttons','on')
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
            
            msg = sprintf("Loaded project: '%s'", S.projectInfo.projectName);
            functionality.writeToLog(app.gHandles.Log, msg)
            functionality.enableTool(app,'buttons','on')
            
            
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
            functionality.writeToLog(app.gHandles.Log, "Success.")
            
            
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
        
        function DeletePupButtonClbk(src, event)
        end
        
        function DrawPupButtonClbk(~, ~, app)
            disableDefaultInteractivity(app.gHandles.ax_image)
            app.gHandles.ROI_pupil = drawellipse(app.gHandles.ax_image,'color',[0 1 1]);
        end
        
        function DrawBbButtonClbk(src, event)
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
            newImgFileName = sprintf("%05u" + "_frame_" + projectName + ".jpg", newImgID);
            
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
        
        % Convert strings in logical (e.g., "True" to true)
        function bool = str2logical(str)
            trueList = ["True","true","1"];
            falseList = ["False","false","0"];
            if ismember(str,trueList)
                bool = true;
            elseif ismember(str,falseList)
                bool = false;
            else
                error("Unrecognized string")
            end
        end
        
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
            end
            
            % Enable or disable all the elements of the handle subset
            for i = 1:length(handleList)
                handleList(i).Enable = state;
            end
        end
        
        % Parse key press to execute functions
        function keyParser(src,event,app)
            
            key = event.Key;
            modifier = event.Modifier;
            
            switch key
                case 'a'
                    functionality.PrevImButtonClbk(src, event, app)
                case 'd'
                    functionality.NextImButtonClbk(src, event, app)
                case 'e'
                    functionality.DrawPupButtonClbk(src, event, app)
                % SPACEBAR is generally used to "confirm" temporary
                % edits that the user might do like drawing a pupil or a
                % bounding box
                case {'space', 'return'}     
                    if ishandle(app.gHandles.ROI_pupil)
                        % Create Mask from the ROI abject
                        mask = createMask(app.gHandles.ROI_pupil, app.gHandles.imgHandle);
                        mask = mask*0.4;
                        graphics.updateOverlays(app, mask, [])
                        delete(app.gHandles.ROI_pupil)
                        enableDefaultInteractivity(app.gHandles.ax_image);
                        axtoolbar(app.gHandles.ax_image,{'pan','zoomin','zoomout','restoreview'});
                    end
                case 'escape'
                    if ishandle(app.gHandles.ROI_pupil)
                        delete(app.gHandles.ROI_pupil)
                    end
            end
            
            
        end
        
    end
end




