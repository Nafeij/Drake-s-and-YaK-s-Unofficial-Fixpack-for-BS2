package passets
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.battle.initiative.GuiInitiativeStatFlag;
   
   public dynamic class statflag_enemy extends GuiInitiativeStatFlag
   {
       
      
      public var injury_icon:MovieClip;
      
      public var textArmor:TextField;
      
      public var textArmorBreak:TextField;
      
      public var textExertion:TextField;
      
      public var textStrength:TextField;
      
      public var textWillpower:TextField;
      
      public var tooltip:stat_tooltip;
      
      public function statflag_enemy()
      {
         super();
      }
   }
}
