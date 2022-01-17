classdef imageManager
    
    methods (Static)
        
        % Extract frames SMART
        function extractedFrames = extractFrameFromVideo_smart(videoPath, reqFrames)
            
            v = VideoReader(videoPath);

            % Choose randomly X times more frames than requested
            multiplier = 50;
            putativeFramesNumber = min(reqFrames*multiplier, v.NumFrames);
            framesIdx = randperm(v.NumFrames, reqFrames*multiplier);
            framesIdx = sort(framesIdx, 'ascend');
            % Load those frames
            movie = zeros(v.Height, v.Width, putativeFramesNumber, 'uint8');
            for i=1:putativeFramesNumber
                % Set the video time to grab next frame indexed in framesIdx
                curTime = (framesIdx(i)-1) * (1/v.FrameRate);
                v.CurrentTime = curTime;
                % Grab frame and process it
                movie(:,:,i) = im2gray(v.readFrame);
            end
            % Compute PCA to find most differing frames
            % Timepoints are variables and pixels are observations
            resizeTo = 64;
            resizedMovie = imresize(movie, [resizeTo, resizeTo]);
            resizedMovie = double(resizedMovie);
            reshMov = reshape(resizedMovie, resizeTo^2, size(movie,3));
            coeff = pca(reshMov);
            % Take the first Principal Component
            pc1 = coeff(:,1);
            % We draw requested frames from evenly spaced quantiles of the
            % distribution of the first PC in order to draw frames that are
            % as different as possible
            quantiles = quantile(pc1, linspace(0,1,reqFrames));
            
            % Find the index of the frame closest to each quantile            
            temp = repmat(pc1, 1, reqFrames);
            diffs = abs(temp-quantiles');
            [~, selectedFramesIdx] = min(diffs,[],1);
            
            % Get the output frames
            extractedFrames = movie(:,:,selectedFramesIdx);
            
        end
        
        % Extract frames RANDOM
        function extractedFrames = extractFrameFromVideo_random(videoPath, reqFrames)
            v = VideoReader(videoPath);

            % Choose randomly the number of requested frames
            framesIdx = randperm(v.NumFrames, reqFrames);
            framesIdx = sort(framesIdx, 'ascend');
            % Load those frames
            movie = zeros(v.Height, v.Width, reqFrames,'uint8');
            for i=1:reqFrames
                % Set the video time to grab next frame indexed in framesIdx
                curTime = (framesIdx(i)-1) * (1/v.FrameRate);
                v.CurrentTime = curTime;
                % Grab frame and process it
                movie(:,:,i) = im2gray(v.readFrame);
            end
            
            % Get the output frames
            extractedFrames = movie;
        end
        
        % Save a pupil label image and update the XML file
        function addPupilLabel(app, mask)
            functionality.updateStructFromFile(app)
            % Creathe the label image
            label = zeros([size(app.gHandles.imgHandle.CData),3], 'uint8');
            label(:,:,1) = uint8(mask*255);
            
            % Get info for the current image
            [imageName, imageIndex] = functionality.imageID2name(app.currImgID,...
                app.xmlStruct);
            % New filename for the .png image
            [~,labelName,~] = fileparts(imageName);
            labelName = labelName + ".png";
            
            % Write feedback to the Log text area
            oldLabelName = app.xmlStruct.images.image(imageIndex).labelFileName;
            if strlength(oldLabelName) == 0
                msg = sprintf("Saved pupil label: %s",labelName);
            else
                msg = sprintf("Updated pupil label: %s",labelName);
            end
            
            % Write the image
            imwrite(label, app.projectPath + filesep + "labels" + filesep + labelName)
            % Write the updated XML file
            app.xmlStruct.images.image(imageIndex).labelFileName = labelName;
            functionality.updateXMLfileFromStruct(app)
            
            
            functionality.writeToLog(app.gHandles.Log, msg)
        end
        
        % Delete the pupil label image and update the XML file
        function deletePupilLabel(app)
            functionality.updateStructFromFile(app)
            
            % Get info for the current image
            [imageName, imageIndex] = functionality.imageID2name(app.currImgID,...
                app.xmlStruct);
            % Get the filename for the .png label image
            [~,labelName,~] = fileparts(imageName);
            labelName = labelName + ".png";
            labelFullName = app.projectPath + filesep + "labels" + filesep + labelName;
            % Delete the .png label image
            if isfile(labelFullName)
                delete(labelFullName)
                msg = sprintf("Deleted pupil label: %s",labelName);
            else
                msg = "No label image to delete";
            end
            % Remove the image label filename from the XML
            app.xmlStruct.images.image(imageIndex).labelFileName = "";
            functionality.updateXMLfileFromStruct(app)
            
            % Write feedback to the Log text area
            functionality.writeToLog(app.gHandles.Log, msg)
            
        end
        
    end
    
    
end