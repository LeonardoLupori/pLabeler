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
            % Pupillometry
            gHandles.PupillometryMenu.MenuSelectedFcn = {@functionality.PupillometryMenuClbk, app};
            
        end
        %------------------------------------------------------------------
        % CALLBACK FUNCTIONS
        %------------------------------------------------------------------
        
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
        
        function PupillometryMenuClbk(~, ~, app)
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
        
        
        
    end
end