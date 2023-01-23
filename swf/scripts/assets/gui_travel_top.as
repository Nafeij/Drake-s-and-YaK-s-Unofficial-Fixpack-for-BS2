package assets
{
   import flash.text.TextField;
   import game.gui.travel.GuiTravelTop;
   import passets.trv_banner_renown;
   import passets.trv_banner_supplies;
   import passets.trv_button_camp;
   import passets.trv_button_map;
   import passets.trv_button_morale;
   import passets.trv_button_options;
   import passets.trv_button_travel;
   import passets.trv_timer;
   
   public dynamic class gui_travel_top extends GuiTravelTop
   {
       
      
      public var $clansmen_label:TextField;
      
      public var $fighters_label:TextField;
      
      public var $varl_label:TextField;
      
      public var banner_renown:trv_banner_renown;
      
      public var banner_supplies:trv_banner_supplies;
      
      public var button$camp:trv_button_camp;
      
      public var button$map:trv_button_map;
      
      public var button$options:trv_button_options;
      
      public var button_morale:trv_button_morale;
      
      public var button_travel:trv_button_travel;
      
      public var textDays:TextField;
      
      public var textNumFighters:TextField;
      
      public var textNumPeasants:TextField;
      
      public var textNumVarl:TextField;
      
      public var timer:trv_timer;
      
      public var tooltip$days:TextField;
      
      public function gui_travel_top()
      {
         super();
         addFrameScript(0,this.frame1,28,this.frame29,57,this.frame58,111,this.frame112,155,this.frame156,185,this.frame186,215,this.frame216);
      }
      
      internal function frame1() : *
      {
         stop();
      }
      
      internal function frame29() : *
      {
         stop();
      }
      
      internal function frame58() : *
      {
         stop();
      }
      
      internal function frame112() : *
      {
         stop();
      }
      
      internal function frame156() : *
      {
         stop();
      }
      
      internal function frame186() : *
      {
         stop();
      }
      
      internal function frame216() : *
      {
         stop();
      }
   }
}
