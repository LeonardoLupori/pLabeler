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
                'Name','pLabeler - display window',...
                'NumberTitle','off',...
                'MenuBar','none');
            
            % Create the axes
            handles.ax_image = axes('Parent',handles.fig_image,...
                'Units','normalized',...
                'Position',[0 0 1 1]);
            
            handles.imgHandle = imshow(imread('media/pLabelerWelcome.png'),...
                'Parent', handles.ax_image);
            
            axtoolbar(handles.ax_image,{'pan','zoomin','zoomout','restoreview'});
            enableDefaultInteractivity(handles.ax_image);
            
            % For graphical design
            handles.ax_image.Title.FontSize = 16;
            handles.ax_image.Title.Color = [0,.7,.7];
            
            
            %--------------------------------------------------------------
            % MAIN UI AND OPTIONS FIGURE
            %--------------------------------------------------------------
            
            % Create fig_pLabeler and hide until all components are created
            handles.fig_pLabeler = uifigure('Visible', 'off');
            handles.fig_pLabeler.Color = [0.149 0.149 0.149];
            handles.fig_pLabeler.Position = [100 100 350 470];
            handles.fig_pLabeler.Name = 'pLabeler';
            handles.fig_pLabeler.Icon = 'media/icon.png';
            handles.fig_pLabeler.Tag = 'fig_UI';

            % Create FileMenu
            handles.FileMenu = uimenu(handles.fig_pLabeler);
            handles.FileMenu.Text = 'File';

            % Create NewProjectMenu
            handles.NewProjectMenu = uimenu(handles.FileMenu);
            handles.NewProjectMenu.Tooltip = {'Create a new project folder for labeling pupils'};
            handles.NewProjectMenu.Accelerator = 'N';
            handles.NewProjectMenu.Text = 'New Project';

            % Create LoadProjectMenu
            handles.LoadProjectMenu = uimenu(handles.FileMenu);
            handles.LoadProjectMenu.Accelerator = 'L';
            handles.LoadProjectMenu.Text = 'Load Project';

            % Create SaveProjectMenu
            handles.SaveProjectMenu = uimenu(handles.FileMenu);
            handles.SaveProjectMenu.Accelerator = 'S';
            handles.SaveProjectMenu.Text = 'Save Project';

            % Create AddImgsMenu
            handles.AddImgsMenu = uimenu(handles.FileMenu);
            handles.AddImgsMenu.Separator = 'on';
            handles.AddImgsMenu.Text = 'Add Images to current project';

            % Create FromFilesMenu
            handles.FromFilesMenu = uimenu(handles.AddImgsMenu);
            handles.FromFilesMenu.Text = 'From Files';

            % Create FromVideoMenu
            handles.FromVideoMenu = uimenu(handles.AddImgsMenu);
            handles.FromVideoMenu.Text = 'From Video';

            % Create ExportLabelsMenu
            handles.ExportLabelsMenu = uimenu(handles.FileMenu);
            handles.ExportLabelsMenu.Separator = 'on';
            handles.ExportLabelsMenu.Text = 'Export Labeled Images';

            % Create LabelingMenu
            handles.LabelingMenu = uimenu(handles.fig_pLabeler);
            handles.LabelingMenu.Text = 'Labeling';

            % Create DrawBbMenu
            handles.DrawBbMenu = uimenu(handles.LabelingMenu);
            handles.DrawBbMenu.Text = 'Draw Eye bounding-box';

            % Create DeleteBbMenu
            handles.DeleteBbMenu = uimenu(handles.LabelingMenu);
            handles.DeleteBbMenu.Text = 'Delete Eye bounding-box';

            % Create DrawPupilMenu
            handles.DrawPupilMenu = uimenu(handles.LabelingMenu);
            handles.DrawPupilMenu.Separator = 'on';
            handles.DrawPupilMenu.Text = 'Draw Pupil';

            % Create DeletePupilMenu
            handles.DeletePupilMenu = uimenu(handles.LabelingMenu);
            handles.DeletePupilMenu.Text = 'Delete Pupil';

            % Create DeleteAllMenu
            handles.DeleteAllMenu = uimenu(handles.LabelingMenu);
            handles.DeleteAllMenu.Separator = 'on';
            handles.DeleteAllMenu.Text = 'Delete all labels';

            % Create HelpMenu
            handles.HelpMenu = uimenu(handles.fig_pLabeler);
            handles.HelpMenu.Text = 'Help';

            % Create TutorialMenu
            handles.TutorialMenu = uimenu(handles.HelpMenu);
            handles.TutorialMenu.Text = 'Tutorial';

            % Create PupillometryMenu
            handles.PupillometryMenu = uimenu(handles.HelpMenu);
            handles.PupillometryMenu.Text = 'Pupillometry';

            % Create LogLabel
            handles.LogLabel = uilabel(handles.fig_pLabeler);
            handles.LogLabel.FontColor = [0.9412 0.9412 0.9412];
            handles.LogLabel.Position = [11 209 29 22];
            handles.LogLabel.Text = 'Log:';

            % Create Log
            handles.Log = uitextarea(handles.fig_pLabeler);
            handles.Log.BackgroundColor = [0.9412 0.9412 0.9412];
            handles.Log.Position = [11 41 330 170];

            % Create CurrentProjectLabel
            handles.CurrentProjectLabel = uilabel(handles.fig_pLabeler);
            handles.CurrentProjectLabel.BackgroundColor = [0 0 0];
            handles.CurrentProjectLabel.FontSize = 11;
            handles.CurrentProjectLabel.FontAngle = 'italic';
            handles.CurrentProjectLabel.FontColor = [1 1 1];
            handles.CurrentProjectLabel.Position = [11 11 329 20];
            handles.CurrentProjectLabel.Text = 'Current Project: ';

            % Create ImAdjPanel
            handles.ImAdjPanel = uipanel(handles.fig_pLabeler);
            handles.ImAdjPanel.ForegroundColor = [0.9412 0.9412 0.9412];
            handles.ImAdjPanel.Title = 'Image Adjustments';
            handles.ImAdjPanel.BackgroundColor = [0.149 0.149 0.149];
            handles.ImAdjPanel.FontSize = 13;
            handles.ImAdjPanel.Position = [11 245 330 137];

            % Create WhiteSliderLabel
            handles.WhiteSliderLabel = uilabel(handles.ImAdjPanel);
            handles.WhiteSliderLabel.FontColor = [0.9412 0.9412 0.9412];
            handles.WhiteSliderLabel.Enable = 'off';
            handles.WhiteSliderLabel.Position = [11 24 36 22];
            handles.WhiteSliderLabel.Text = 'White';

            % Create WhiteSlider
            handles.WhiteSlider = uislider(handles.ImAdjPanel);
            handles.WhiteSlider.Limits = [0 1];
            handles.WhiteSlider.MajorTicks = [];
            handles.WhiteSlider.MinorTicks = [];
            handles.WhiteSlider.Tag = 'slider_wht';
            handles.WhiteSlider.Enable = 'off';
            handles.WhiteSlider.Tooltip = {'Adjust the white level of the current image'};
            handles.WhiteSlider.Position = [60 33 251 3];
            handles.WhiteSlider.Value = 1;

            % Create BlackSliderLabel
            handles.BlackSliderLabel = uilabel(handles.ImAdjPanel);
            handles.BlackSliderLabel.FontColor = [0.9412 0.9412 0.9412];
            handles.BlackSliderLabel.Enable = 'off';
            handles.BlackSliderLabel.Position = [11 4 35 22];
            handles.BlackSliderLabel.Text = 'Black';

            % Create BlackSlider
            handles.BlackSlider = uislider(handles.ImAdjPanel);
            handles.BlackSlider.Limits = [0 1];
            handles.BlackSlider.MajorTicks = [];
            handles.BlackSlider.MinorTicks = [];
            handles.BlackSlider.Tag = 'slider_blk';
            handles.BlackSlider.Enable = 'off';
            handles.BlackSlider.Tooltip = {'Adjust the black level of the current image'};
            handles.BlackSlider.Position = [60 13 251 3];

            % Create InvertImCheckBox
            handles.InvertImCheckBox = uicheckbox(handles.ImAdjPanel);
            handles.InvertImCheckBox.Text = 'Invert Image';
            handles.InvertImCheckBox.FontColor = [0.9412 0.9412 0.9412];
            handles.InvertImCheckBox.Position = [11 84 160 22];

            % Create AutoCntrCheckBox
            handles.AutoCntrCheckBox = uicheckbox(handles.ImAdjPanel);
            handles.AutoCntrCheckBox.Text = 'Auto Contrast';
            handles.AutoCntrCheckBox.FontColor = [0.9412 0.9412 0.9412];
            handles.AutoCntrCheckBox.Position = [11 54 160 22];
            handles.AutoCntrCheckBox.Value = true;

            % Create AutoCntrSwitch
            handles.AutoCntrSwitch = uiswitch(handles.ImAdjPanel, 'slider');
            handles.AutoCntrSwitch.Items = {'best fit', 'min/max'};
            handles.AutoCntrSwitch.FontColor = [0.9412 0.9412 0.9412];
            handles.AutoCntrSwitch.Position = [222 58 41 18];
            handles.AutoCntrSwitch.Value = 'best fit';

            % Create NextImButton
            handles.NextImButton = uibutton(handles.fig_pLabeler, 'push');
            handles.NextImButton.Enable = 'off';
            handles.NextImButton.Position = [181 390 160 21];
            handles.NextImButton.Text = 'Next Image (D) >';

            % Create PrevImButton
            handles.PrevImButton = uibutton(handles.fig_pLabeler, 'push');
            handles.PrevImButton.Enable = 'off';
            handles.PrevImButton.Position = [11 390 160 21];
            handles.PrevImButton.Text = '< Prev Image (A)';

            % Create DeletePupButton
            handles.DeletePupButton = uibutton(handles.fig_pLabeler, 'push');
            handles.DeletePupButton.Enable = 'off';
            handles.DeletePupButton.Position = [260 540 100 30];
            handles.DeletePupButton.Text = 'Delete Pupil (Q)';

            % Create DrawPupButton
            handles.DrawPupButton = uibutton(handles.fig_pLabeler, 'push');
            handles.DrawPupButton.Enable = 'off';
            handles.DrawPupButton.Position = [11 421 160 41];
            handles.DrawPupButton.Text = 'Draw Pupil(E)';

            % Create DrawBbButton
            handles.DrawBbButton = uibutton(handles.fig_pLabeler, 'push');
            handles.DrawBbButton.Enable = 'off';
            handles.DrawBbButton.Position = [181 421 160 40];
            handles.DrawBbButton.Text = 'Draw BBox (Q)';

            % Show the figure after all components are created
            handles.fig_pLabeler.Visible = 'on';
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
        
    end
end














