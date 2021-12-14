classdef projManager
    
    methods (Static)
        
        % Create a new project folder and initialize all files and folders
        function [bool, projectFolder, projectName, xmlStruct] = createNewProj(startPath,logHandle)
            
            % Default outputs
            bool = false;
            projectFolder = [];
            
            % Select folder for the new project
            %--------------------------------------------------------------
            functionality.writeToLog(logHandle, "Creating New Project...")
            tit = "Select a folder to save the project";
            selpath = uigetdir(startPath,tit);
            % Return if user clicks cancel
            if isequal(selpath,0)
                functionality.writeToLog(logHandle, "aborted by user.")
                return
            end
            
            % Get info for the new project
            %--------------------------------------------------------------
            dlgtitle = "New Project Info";
            prompt = ["Project Name",...
                "Experimenter",...
                "Comments"];
            dims = repmat([1,50], length(prompt),1);
            answer = inputdlg(prompt,dlgtitle,dims);
            % Return if user clicks cancel
            if isempty(answer)
                functionality.writeToLog(logHandle, "aborted by user.")
                return
            end
            
            % Create project folder
            %--------------------------------------------------------------
            projectName = string(answer{1});
            projectName = strrep(projectName, ' ', '-');    % remove whitespaces from projectName
            presentDate = string(datestr(now,'yyyymmdd'));
            foldName = presentDate + "_" + projectName;
            foldFullPath = string(selpath) + filesep +  foldName;
            status = mkdir(foldFullPath);
            if isequal(status,0)
                functionality.writeToLog(logHandle, "ERROR creating project folder")
                return
            end
            % Create subfolders
            status(1) = mkdir(foldFullPath + filesep + "frames");
            status(2) = mkdir(foldFullPath + filesep + "labels");
            status(3) = mkdir(foldFullPath + filesep + "backups");
            if any(status == 0)
                functionality.writeToLog(logHandle, "ERROR creating subfolders")
            end
            
            % Create XML project file
            %--------------------------------------------------------------
            S.projectInfo.projectName = string(answer{1});
            S.projectInfo.experimenter = string(answer{2});
            S.projectInfo.comments = string(answer{3});
            S.projectInfo.currentImgID = 0;
            S.projectInfo.creationDate = string(datestr(now,'yyyymmdd_hhMMss'));
            S.projectInfo.lastModified = string(datestr(now,'yyyymmdd_hhMMss'));
            S.projectInfo.lastImageID = 0;
            
            xmlFullPath = foldFullPath + filesep + "pLabelerProject.xml";
            writestruct(S, xmlFullPath, "StructNodeName", "pLabelerProject");
            xmlStruct = S;
            
            projectFolder = foldFullPath;
            bool = true;
            functionality.writeToLog(logHandle, "New project created!")
        end
        
        % Add a new image to the XML struct 
        function S = addImgToXmlStruct(S, newImgFileName)
            
            newImgID = S.projectInfo.lastImageID + 1;
            
            if ~isfield(S,'images')
                % If there are no images in the XML
                S.images.image.id = newImgID;
                S.images.image.frameFileName = newImgFileName;
                S.images.image.labelFileName = "";
                S.images.image.eyeBbox.x = NaN;
                S.images.image.eyeBbox.y = NaN;
                S.images.image.eyeBbox.width = NaN;
                S.images.image.eyeBbox.height = NaN;
                S.images.image.isEye = 1;
                S.images.image.isBlinking = 0;
                S.images.image.isRejected = 0;
            else
                % Otherwise create a newImage struct
                newImage.id = newImgID;
                newImage.frameFileName = newImgFileName;
                newImage.labelFileName = "";
                newImage.eyeBbox.x = NaN;
                newImage.eyeBbox.y = NaN;
                newImage.eyeBbox.width = NaN;
                newImage.eyeBbox.height = NaN;
                newImage.isEye = 1;
                newImage.isBlinking = 0;
                newImage.isRejected = 0;
                % Concatenate the struct to the existing list
                S.images.image = cat(2, S.images.image, newImage);
            end
            
            % Update the XML file
            S.projectInfo.lastModified = string(datestr(now,'yyyymmdd_hhMMss'));
            S.projectInfo.lastImageID = newImgID;
            
        end
        
        % Update the saved XML with the ID of the current image to restore
        % it upon closing and reopening the app
        function updateXML_currentImgID(app)
            %Load xml as a struct
            xmlFullPath = app.projectPath + filesep + "pLabelerProject.xml";
            S = readstruct(xmlFullPath);
            % Change values
            S.projectInfo.currentImgID = app.currImgID;
            S.projectInfo.lastModified = string(datestr(now,'yyyymmdd_hhMMss'));
            % Save back the XML
            writestruct(S, xmlFullPath);
            
        end
        
        % Add bounding box info to the XML file
        function addBbox(app, bBoxStruct)
            functionality.updateStructFromFile(app)
            
            % Get info for the current image
            [imName, imageIndex] = functionality.imageID2name(app.currImgID,...
                app.xmlStruct);
            app.xmlStruct.images.image(imageIndex).eyeBbox = bBoxStruct;
            functionality.updateXMLfileFromStruct(app)
            
            msg = sprintf("Eye bBox saved: %s",imName);
            functionality.writeToLog(app.gHandles.Log, msg)
        end
        
        % Delete bounding box info from the XML file
        function deleteBbox(app)
            functionality.updateStructFromFile(app)
            % Get info for the current image
            [imName, imageIndex] = functionality.imageID2name(app.currImgID,...
                app.xmlStruct);
            % Seth the bbox info as NaN
            emptyStruct = functionality.pos2bBoxStruct([NaN, NaN, NaN, NaN]);
            app.xmlStruct.images.image(imageIndex).eyeBbox = emptyStruct;
            % Save back the struct in the XML file
            functionality.updateXMLfileFromStruct(app)
            
            msg = sprintf("Eye bBox deleted: %s",imName);
            functionality.writeToLog(app.gHandles.Log, msg)
        end
        
        % Toggle (true/false) the state of the isBlinking field in the XML
        % for the current image
        function toggleBlinkXML(app)
            functionality.updateStructFromFile(app)
            % Get info for the current image
            [~, imageIndex] = functionality.imageID2name(app.currImgID,...
                app.xmlStruct);
            oldStatus = app.xmlStruct.images.image(imageIndex).isBlinking;
            newStatus = double(~oldStatus);
            app.xmlStruct.images.image(imageIndex).isBlinking = newStatus;
            % Save back the struct in the XML file
            functionality.updateXMLfileFromStruct(app)
            if newStatus
                msg = "Blink";
            else
                msg = "Not a blink";
            end
            functionality.writeToLog(app.gHandles.Log, msg)
        end
        
        % Toggle (true/false) the state of the isRejected field in the XML
        % for the current image
        function toggleRejectedXML(app)
            functionality.updateStructFromFile(app)
            % Get info for the current image
            [~, imageIndex] = functionality.imageID2name(app.currImgID,...
                app.xmlStruct);
            oldStatus = app.xmlStruct.images.image(imageIndex).isRejected;
            newStatus = double(~oldStatus);
            app.xmlStruct.images.image(imageIndex).isRejected = newStatus;
            % Save back the struct in the XML file
            functionality.updateXMLfileFromStruct(app)
            if newStatus
                msg = "Rejected";
            else
                msg = "Accepted";
            end
            functionality.writeToLog(app.gHandles.Log, msg)
        end
        
        
    end 
end