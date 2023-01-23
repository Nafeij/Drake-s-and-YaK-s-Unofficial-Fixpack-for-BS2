package assets
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.GuiOptionsLang;
   import passets.lang_button_arrow;
   import passets.lang_chits_group;
   
   public dynamic class lang extends GuiOptionsLang
   {
       
      
      public var button_close:button_options_close;
      
      public var button_holder:MovieClip;
      
      public var button_next:lang_button_arrow;
      
      public var button_prev:lang_button_arrow;
      
      public var chits:lang_chits_group;
      
      public var text$language:TextField;
      
      public function lang()
      {
         super();
      }
   }
}
