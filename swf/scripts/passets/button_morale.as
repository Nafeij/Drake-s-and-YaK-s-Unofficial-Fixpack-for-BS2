package passets
{
   import flash.display.MovieClip;
   import game.gui.travel.GuiTravelTopMorale;
   
   public dynamic class button_morale extends GuiTravelTopMorale
   {
       
      
      public var button$morale_tt_high:button_morale_high;
      
      public var button$morale_tt_low:button_morale_low;
      
      public var button$morale_tt_med:button_morale_med;
      
      public var button$morale_tt_medhigh:button_morale_medhigh;
      
      public var button$morale_tt_medlow:button_morale_medlow;
      
      public var holderOfText:MovieClip;
      
      public var tooltip:block;
      
      public var tooltip_marker:MovieClip;
      
      public function button_morale()
      {
         super();
      }
   }
}
