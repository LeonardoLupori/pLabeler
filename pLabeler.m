classdef pLabeler < handle
    
    properties
        graph_handles      % Struct with handles of GUI's graphic objects
    end
    
    methods
        %------------------------------------------------------------------
        % CLASS CONSTRUCTOR METHOD
        function app = pLabeler()
            
            app.graph_handles = graphics.createFigures();
            
            % Add custom CloseRequestFcn to all the figures
            app.graph_handles.fig_image.CloseRequestFcn = @app.closeFunction;
            app.graph_handles.fig_lumSlid.CloseRequestFcn = @app.closeFunction;
            app.graph_handles.fig_ui.CloseRequestFcn = @app.closeFunction;
            
            
            
        end
        
        function closeFunction(app,~,~)
            delete(app.graph_handles.fig_image)
            delete(app.graph_handles.fig_lumSlid)
            delete(app.graph_handles.fig_ui)
        end
        
    end
    
end