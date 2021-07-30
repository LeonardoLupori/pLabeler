classdef imageManager
    
    methods (Static)
        
        function importFrames
        end
        
        
        
        
        
        function extractedFrames = extractFrameFromVideo(videoPath, reqFrames)
            
            v = VideoReader(videoPath);

            % Choose randomly 10 times more frames than requested
            putativeFramesNumber = min(reqFrames*10, v.NumFrames);
            framesIdx = randperm(v.NumFrames, reqFrames*10);
            framesIdx = sort(framesIdx, 'ascend');
            % Load those frames
            movie = zeros(v.Height, v.Width, putativeFramesNumber);
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
            reshMov = reshape(resizedMovie, resizeTo^2, size(movie,3));
            coeff = pca(reshMov);
            % Take the first Principal Component
            pc1 = coeff(:,1);
            % We draw requested frames from evenly spaced quantiles of the
            % distribution of the first PC in order to draw frames that are
            % as different as possible
            quantiles = quantile(pc1, reqFrames);
            
            % Find the index of the frame closest to each quantile            
            temp = repmat(pc1, 1, reqFrames);
            diffs = abs(temp-quantiles);
            [~, selectedFramesIdx] = min(diffs,[],1);
            
            % Get the output frames
            extractedFrames = movie(:,:,selectedFramesIdx);
            
        end
        
        
        
    end
    
    
end