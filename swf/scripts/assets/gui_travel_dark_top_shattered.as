package assets
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.travel.GuiTravelTop_Shattered;
   import passets.trv_button_morale;
   import passets.trv_button_options;
   import passets.trv_dark_banner_renown;
   
   public dynamic class gui_travel_dark_top_shattered extends GuiTravelTop_Shattered
   {
       
      
      public var banner_renown:trv_dark_banner_renown;
      
      public var button$options:trv_button_options;
      
      public var button_morale:trv_button_morale;
      
      public var coin_flip:MovieClip;
      
      public var dust_effects:MovieClip;
      
      public var textDays:TextField;
      
      public var tooltip$days:TextField;
      
      public function gui_travel_dark_top_shattered()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      internal function frame1() : *
      {
         stop();
      }
   }
}
