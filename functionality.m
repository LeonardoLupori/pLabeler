classdef functionality
    
    methods(Static)
        
        function assignCallbacks(app)
            gHandles = app.gHandles;
            
            gHandles.PupillometryMenu.MenuSelectedFcn = {@functionality.PupillometryMenuClbk, app};
            
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
        
        function PupillometryMenuClbk(~, ~, app)
            
            web('www.pupillometry.it', '-browser')
        end
        
    end
    

end