classdef functionality
    
    methods(Static)
        %------------------------------------------------------------------
        % Main function to assign callbacks to all the GUI buttons and
        % menus
        %------------------------------------------------------------------
        function assignCallbacks(app)
            gHandles = app.gHandles;
            
            
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
            
            
            % Pupillometry
            gHandles.PupillometryMenu.MenuSelectedFcn = {@functionality.PupillometryMenuClbk, app};
            
        end
        %------------------------------------------------------------------
        % CALLBACK FUNCTIONS
        %------------------------------------------------------------------
        
        % NEW PROJECT
        function NewProjectMenuClbk(~,~,app)
            [bool, projectFolder, projectName] = projManager.createNewProj(app.defPath,app.gHandles.Log);
            if bool
                app.defPath = string(projectFolder);
                app.projectName = string(projectName);
                app.projectPath = string(pth);
                app.gHandles.CurrentProjectLabel.Text = "Current Project: " + ...
                projectName;
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
            app.gHandles.CurrentProjectLabel.Text = "Current Project: " + ...
                S.projectInfo.projectName;
            
            msg = sprintf("Loaded project: '%s'", S.projectInfo.projectName);
            functionality.writeToLog(app.gHandles.Log, msg)
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
                bool = functionality.addImageToProject(im,app.projectPath,app.projectName); 
                success(i) = bool;
                if ~bool
                    msg = "ERROR adding image: " + fN{i};
                    functionality.writeToLog(app.gHandles.Log, msg)
                end
            end
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
                    bool = functionality.addImageToProject(extractedFrames(:,:,j),...
                        app.projectPath,app.projectName);
                    framesAdded = framesAdded + bool;
                end
                msg = sprintf("Successfully added %u images", framesAdded);
                functionality.writeToLog(app.gHandles.Log, msg)
            end
            functionality.writeToLog(app.gHandles.Log, "Success.")
            
            
        end
        
        function PrevImButtonClbk(src, event)
        end
        
        function NextImButtonClbk(src, event)
        end
        
        function DeletePupButtonClbk(src, event)
        end
        
        function DrawPupButtonClbk(src, event)
        end
        
        function DrawBbButtonClbk(src, event)
        end
        
        function AutoCntrSwitchClbk(src, event)
        end
        
        function AutoCntrCheckBoxClbk(src, event)
        end
        
        function InvertImCheckBoxClbk(src, event)
        end
        
        function BlackSliderClbk(src, event)
        end
        
        function WhiteSliderClbk(src, event)
        end
        
        function HelpMenuClbk(src, event)
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
        function bool = addImageToProject(img, projectPath, projectName)
                        
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
            
            bool = true;
        end
        
        
    end
end