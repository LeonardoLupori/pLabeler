classdef pLabeler < handle
    
    properties
        gHandles      % Struct with handles of GUI's graphic objects
        defPath = 'C:\';
        projectPath = "";
        projectName = "";
        
        currImgID = 0;
        
        xmlStruct = [];
        lastDrawnBbox = [];
    end
    
    methods
        %------------------------------------------------------------------
        % CLASS CONSTRUCTOR METHOD
        %-----------------------------------------------------------------
        function app = pLabeler()
            
            % Make sure only one GUI instance is called at a time
            figs = findobj(allchild(groot), 'flat', 'Tag', 'fig_UI');
            if isempty(figs)
                % Build the GUI is no GUI is already displayed
                buildApp(app)   
            else
                % Give back focus to the GUI if one instance exists
                figure(figs(1))
            end
            
        end
        %-----------------------------------------------------------------
        %-----------------------------------------------------------------
        
        function buildApp(app)
            % Create all the graphics elements in the 2 figures
            app.gHandles = graphics.createFigures();
            % Assign callbacks to all the buttons in the GUI
            functionality.assignCallbacks(app)
            % Add custom CloseRequestFcn to all the figures
            app.gHandles.fig_image.CloseRequestFcn = @app.closeFunction;
            app.gHandles.fig_pLabeler.CloseRequestFcn = @app.closeFunction;
        end
        
        function closeFunction(app,~,~)
            % Store the currentImgID in the XML file
            projManager.updateXML_currentImgID(app)
            
            delete(app.gHandles.fig_image)
            delete(app.gHandles.fig_pLabeler)
        end
        
    end
    
end