package assets
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.GuiOptionsAudio;
   
   public dynamic class opt_audio extends GuiOptionsAudio
   {
       
      
      public var $opt_audio:TextField;
      
      public var $opt_subtitles:TextField;
      
      public var bus_master:MovieClip;
      
      public var bus_music:MovieClip;
      
      public var bus_sfx:MovieClip;
      
      public var button_cc:gui_xcc_button;
      
      public var button_close:button_options_close;
      
      public function opt_audio()
      {
         super();
      }
   }
}
