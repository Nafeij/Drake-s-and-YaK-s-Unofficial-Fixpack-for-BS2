package assets
{
   import flash.text.TextField;
   import game.gui.travel.GuiTravelTop;
   import passets.trv_button_morale;
   import passets.trv_button_options;
   import passets.trv_dark_banner_renown;
   import passets.trv_dark_button_camp;
   import passets.trv_dark_button_map;
   import passets.trv_dark_button_travel;
   import passets.trv_dark_timer;
   
   public dynamic class gui_travel_dark_top extends GuiTravelTop
   {
       
      
      public var banner_renown:trv_dark_banner_renown;
      
      public var button$camp:trv_dark_button_camp;
      
      public var button$map:trv_dark_button_map;
      
      public var button$options:trv_button_options;
      
      public var button_morale:trv_button_morale;
      
      public var button_travel:trv_dark_button_travel;
      
      public var textDays:TextField;
      
      public var timer:trv_dark_timer;
      
      public var tooltip$days:TextField;
      
      public function gui_travel_dark_top()
      {
         super();
      }
   }
}
