package passets
{
   import flash.display.MovieClip;
   import game.gui.battle.GuiSelfPopupBasic;
   
   public dynamic class self_popup_basic extends GuiSelfPopupBasic
   {
       
      
      public var ability_button:ability_button_basic;
      
      public var button$attack:attack_button;
      
      public var button$end_turn:end_turn_button;
      
      public var button$move:move_button;
      
      public var button$rest:rest_button;
      
      public var crescent_in:MovieClip;
      
      public function self_popup_basic()
      {
         super();
      }
   }
}
