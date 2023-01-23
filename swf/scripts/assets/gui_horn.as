package assets
{
   import game.gui.battle.GuiHorn;
   import passets.button_morale;
   import passets.horn_button;
   import passets.horn_enemy;
   
   public dynamic class gui_horn extends GuiHorn
   {
       
      
      public var buttonUse:horn_button;
      
      public var horn_enemy:horn_enemy;
      
      public var morale:button_morale;
      
      public function gui_horn()
      {
         super();
      }
   }
}
