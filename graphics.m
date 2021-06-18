classdef graphics
    methods(Static)
        
        function handles = createFigures()
            % MAIN FIGURE WINDOW
            % -------------------------------------------------------------
            screenSize = get(0, 'ScreenSize');
            %width = floor(screenSize(3) * (2/4));
            %heigth = floor(screenSize(4) * (2/4));
            
            width = 640;
            heigth = 480;
            
            handles.fig_image = figure('Color',[0.1,0.1,0.1],...
                'Position',[(screenSize(3)-width)/2 (screenSize(4)-heigth)/2 width heigth],...
                'Name','pLabeler - a MATLAB labeler for pupils',...
                'NumberTitle','off',...
                'MenuBar','none');
            
            % Create the axes
            handles.ax_image = axes('Parent',handles.fig_image,...
                'Units','normalized',...
                'Position',[0 0 1 1]);
            
            handles.imgHandle = imshow(imread('pLabelerWelcome.png'),...
                'Parent', handles.ax_image);
            
            axtoolbar(handles.ax_image,{'pan','zoomin','zoomout','restoreview'});
            enableDefaultInteractivity(handles.ax_image);
            
            % For graphical design
            handles.ax_image.Title.FontSize = 16;
            handles.ax_image.Title.Color = [0,.7,.7];
            
            
            % LUMINANCE SLIDERS FIGURE
            %--------------------------------------------------------------
            width = 450;
            heigth = 140;
            handles.fig_lumSlid = uifigure('Resize', 'off',...
                'Name', 'Luminance Sliders',...
                'NumberTitle','off',...
                'MenuBar','none',...
                'Position',[screenSize(3)-width-25 50 width heigth]);
            grid = uigridlayout(handles.fig_lumSlid,...
                'ColumnWidth',{'1x','5x'},...
                'RowHeight',{'1x', '1x'});
            
            % Black Control Slider
            uilabel('Parent',grid,'Text','Black');
            handles.blackSlider = uislider('Parent', grid,...
                'Value', 0,...
                'Limits', [0, 1],...
                'Tag','blkSl');
            
            % White Control Slider
            uilabel('Parent',grid,'Text','White');
            handles.whiteSlider = uislider('Parent', grid,...
                'Value', 1,...
                'Limits', [0, 1],...
                'Tag','whtSl');
            
            
            %--------------------------------------------------------------
            % MAIN UI AND OPTIONS FIGURE
            %--------------------------------------------------------------
            width = 400;
            heigth = 250;
            handles.fig_ui = uifigure('Resize', 'off',...
                'Name', 'pLabeler',...
                'NumberTitle','off',...
                'Position',[25, (screenSize(4)-heigth-50), width, heigth]);
            
            
            handles.menu_file = uimenu(handles.fig_ui, 'text','File');
            handles.menu_newProj = uimenu(handles.menu_file, 'text','New Project','Accelerator','N');
            handles.menu_loadProj = uimenu(handles.menu_file, 'text','Load Project','Accelerator','L');
            
            
            
            
            
            % Main Grid
            handles.mainGrid = uigridlayout(handles.fig_ui,...
                'RowHeight',{'fit','fit','fit'});
            
            
            handles.IO_grid = uigridlayout(handles.mainGrid,...
                'ColumnWidth',{'fit'},...
                'RowHeight',{'fit','fit','fit'});
            handles.loadImgBtn = uibutton('Parent',handles.IO_grid,'Text','LOAD IMAGE',...
                'FontWeight','bold','ButtonPushedFcn',@app.loadImage);
            handles.loadImgBtn.Layout.Column = [1,2];
        end
        
        function showTutorial()
            f = uifigure('Resize', 'off',...
                'Name', 'Tutorial',...
                'NumberTitle','off',...
                'ToolBar','none',...
                'MenuBar','none');
            
            mainGrid = uigridlayout(f,[1,2]);
            
            panel_left = uipanel(mainGrid,'Title','Left');
            panel_right = uipanel(mainGrid,'Title','Right');
            
            grid_L = uigridlayout(panel_left,...
                'ColumnWidth',{'1x','4x'});
            
            uilabel('Parent',grid_L,'Text','A:','FontWeight','bold',...
                'HorizontalAlignment','right');
            uilabel('Parent',grid_L,'Text','Previous image');
            
            uilabel('Parent',grid_L,'Text','S:','FontWeight','bold',...
                'HorizontalAlignment','right');
            uilabel('Parent',grid_L,'Text','Next image');
        end
        
        function img = welcomeImage(imageSize)
            img = zeros(imageSize(2), imageSize(1), 3,'uint8');
            
        end
    end
end














