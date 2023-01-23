package assets
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.GuiSagaOptionsDifficulty;
   
   public dynamic class difficulty extends GuiSagaOptionsDifficulty
   {
       
      
      public var $difficulty:TextField;
      
      public var button$easy:gui_diff_button;
      
      public var button$hard:gui_diff_button;
      
      public var button$normal:gui_diff_button;
      
      public var button_close:button_options_close;
      
      public var tooltip:MovieClip;
      
      public function difficulty()
      {
         super();
      }
   }
}
