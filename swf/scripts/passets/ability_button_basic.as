package passets
{
   import flash.display.MovieClip;
   import game.gui.battle.GuiPopupAbilityButton;
   
   public dynamic class ability_button_basic extends GuiPopupAbilityButton
   {
       
      
      public var blocker:MovieClip;
      
      public var placeholder:MovieClip;
      
      public var tt:self_tooltip_line;
      
      public var tt_whynot:self_tooltip_line_error;
      
      public function ability_button_basic()
      {
         super();
      }
   }
}
