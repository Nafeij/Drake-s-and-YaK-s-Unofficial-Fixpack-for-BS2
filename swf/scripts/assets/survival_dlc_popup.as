package assets
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.GuiSurvivalPitchPopup;
   import passets.ssbp_button_no;
   import passets.ssbp_button_restore;
   import passets.ssbp_button_yes;
   
   public dynamic class survival_dlc_popup extends GuiSurvivalPitchPopup
   {
       
      
      public var bmpholder_common__gui__survival_battle_popup__poppening_art:MovieClip;
      
      public var button$accept:ssbp_button_yes;
      
      public var button$decline:ssbp_button_no;
      
      public var button$restore:ssbp_button_restore;
      
      public var text$ss_dlc_pitch:TextField;
      
      public var text$ss_welcome_title:TextField;
      
      public var text_price:TextField;
      
      public function survival_dlc_popup()
      {
         super();
      }
   }
}
