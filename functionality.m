classdef functionality
    
    methods(Static)
        %------------------------------------------------------------------
        % Main function to assign callbacks to all the GUI buttons and
        % menus
        %------------------------------------------------------------------
        function assignCallbacks(app)
            gHandles = app.gHandles;
            
            % Add frames from Images
            gHandles.FromFilesMenu.MenuSelectedFcn = {@functionality.FromFilesMenuClbk, app};
            % Add frames from Video
            gHandles.FromVideoMenu.MenuSelectedFcn = {@functionality.FromVideoMenuClbk, app};
            % New Project
            gHandles.NewProjectMenu.MenuSelectedFcn = {@functionality.NewProjectMenuClbk, app};
            % Pupillometry
            gHandles.PupillometryMenu.MenuSelectedFcn = {@functionality.PupillometryMenuClbk, app};
            
        end
        %------------------------------------------------------------------
        % CALLBACK FUNCTIONS
        %------------------------------------------------------------------
        
        function FromFilesMenuClbk(src, event, app)
            
            % Let user select one or more images
            functionality.writeToLog(app.gHandles.Log, "Select images to import.")
            tit = "Select images to import to the project";
            [fN,pth] = uigetfile({'*.jpg;*.tif;*.png', 'Images (*.jpg, *.tif, *.png)'},...
                tit, app.defPath, 'MultiSelect', 'on');
            if isequal(fN, 0)
                functionality.writeToLog(app.gHandles.Log, "aborted by user.")
                return
            end
            
            % If user selected only one file convert it to cell anyways so
            % that the same syntax (cell {} indexing) can be used
            if ~iscell(fN)
                fN = {fN};
            end
            
            % Add the images one by one
            msg = sprintf("Adding %u images...", length(fN));
            functionality.writeToLog(app.gHandles.Log, msg)
            success = zeros(length(fN),1,'logical');
            for i = 1:length(fN)
                im = imread([pth filesep fN{i}]);
                im = im2gray(im);
                % Actually add the image
                bool = functionality.addImageToProject(im,app.projectPath,app.projectName); 
                success(i) = bool;
                if ~bool
                    msg = "FAILED adding image: " + fN{i};
                    functionality.writeToLog(app.gHandles.Log, msg)
                end
            end
            msg = sprintf("Successfully added %u images", sum(bool));
            functionality.writeToLog(app.gHandles.Log, msg)
        end
        
        
        function FromVideoMenuClbk(src, event, app)
            
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
        
        function PupillometryMenuClbk(~,~,app)
            functionality.writeToLog(app.gHandles.Log, "Link to www.pupillometry.it")
            web('www.pupillometry.it', '-browser')
        end
        
        function NewProjectMenuClbk(~,~,app)
            [bool, projectFolder] = projManager.createNewProj(app.defPath,app.gHandles.Log);
            if bool
                app.defPath = projectFolder;
            end
        end
        
        %------------------------------------------------------------------
        % ADDITIONAL FUNCTIONS
        %------------------------------------------------------------------
        
        function writeToLog(logHandle, string)
            if isempty(logHandle.Value)
                logHandle.Value = string;
            else
                newValue = cat(1, logHandle.Value, string);
                logHandle.Value = newValue;
            end
            scroll(logHandle, 'bottom')
        end
        
        function bool = addImageToProject(img, projectPath, projectName)
            
% % % % % %             projectPath = "C:\Users\Leonardo\Desktop\sandbox\20210730_prova2";
% % % % % %             projectName = "prova2";
            
            xmlFullPath = projectPath + filesep +  "pLabelerProject.xml";
            S = readstruct(xmlFullPath);

            
            
            newImgID = S.projectInfo.lastImageID + 1;
            newImgFileName = sprintf("%05u" + "_frame_" + projectName + ".jpg", newImgID);
            
            imwrite(img, projectPath + filesep + "frames" + filesep + newImgFileName)
            
            if ~isfield(S,'images')
                % If there are no images in the XML
                S.images.image.frameFileName = newImgFileName;
                S.images.image.labelFileName = "";
                S.images.image.eyeBbox.x = [];
                S.images.image.eyeBbox.y = [];
                S.images.image.eyeBbox.width = [];
                S.images.image.eyeBbox.height = [];
                S.images.image.isEye = true;
                S.images.image.isBlinking = false;
                S.images.image.isRejected = false;
            else
                % Otherwise create a newImage struct
                newImage.frameFileName = newImgFileName;
                newImage.labelFileName = "";
                newImage.eyeBbox.x = [];
                newImage.eyeBbox.y = [];
                newImage.eyeBbox.width = [];
                newImage.eyeBbox.height = [];
                newImage.isEye = true;
                newImage.isBlinking = false;
                newImage.isRejected = false;
                % Concatenate the struct to the existing list
                S.images.image = cat(1, S.images.image, newImage);
            end
            
            % Update the XML file
            S.projectInfo.lastModified = string(datestr(now,'yyyymmdd_hhMMss'));
            S.projectInfo.lastImageID = newImgID;
            writestruct(S, xmlFullPath);
        end
        
    end
end