package assets
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.pages.GuiSaveLoad;
   import passets.xsave_button_end;
   import passets.xsave_common_arrow_button;
   
   public dynamic class save_saveload extends GuiSaveLoad
   {
       
      
      public var buttonNext:xsave_common_arrow_button;
      
      public var buttonPrev:xsave_common_arrow_button;
      
      public var button_close:xsave_button_end;
      
      public var chits:xsave_chits_group;
      
      public var scroller:MovieClip;
      
      public var text$load_game:TextField;
      
      public function save_saveload()
      {
         super();
      }
   }
}
