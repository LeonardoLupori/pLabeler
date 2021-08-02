classdef projManager
    
    methods (Static)
        
        % Create a new project folder and initialize all files and folders
        function [bool, projectFolder] = createNewProj(startPath,logHandle)
            
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
            pName = string(answer{1});
            pName = strrep(pName, ' ', '-');    % remove whitespaces from projectName
            presentDate = string(datestr(now,'yyyymmdd'));
            foldName = presentDate + "_" + pName;
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
            S.projectInfo.creationDate = string(datestr(now,'yyyymmdd_hhMMss'));
            S.projectInfo.lastModified = string(datestr(now,'yyyymmdd_hhMMss'));
            S.projectInfo.lastImageID = 0;
            
            xmlFullPath = foldFullPath + filesep + "pLabelerProject.xml";
            writestruct(S, xmlFullPath, "StructNodeName", "pLabelerProject");
            
            projectFolder = foldFullPath;
            bool = true;
            functionality.writeToLog(logHandle, "New project created!")
        end
        
        % Add a new image to the XML struct 
        function S = addImgToXmlStruct(S, newImgFileName)
            
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
            
        end
        
        
        
        
    end
    
    
    
end