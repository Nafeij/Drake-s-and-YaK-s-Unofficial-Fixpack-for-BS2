package assets
{
   import flash.display.MovieClip;
   import game.gui.battle.GuiPropPopup;
   import passets.prop_popup_icon;
   import passets.self_tooltip_line;
   import passets.self_tooltip_line_error;
   
   public dynamic class prop_popup extends GuiPropPopup
   {
       
      
      public var button:prop_popup_icon;
      
      public var checkmark:MovieClip;
      
      public var tooltip:self_tooltip_line;
      
      public var tooltip_error:self_tooltip_line_error;
      
      public function prop_popup()
      {
         super();
      }
   }
}
