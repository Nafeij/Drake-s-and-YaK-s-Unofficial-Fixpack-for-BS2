package assets
{
   import flash.display.MovieClip;
   import game.gui.battle.initiative.GuiInitiative;
   import passets.active_frame;
   import passets.infobar;
   import passets.init_order;
   import passets.lowTime;
   import passets.statflags;
   
   public dynamic class battle_initiative extends GuiInitiative
   {
       
      
      public var __waveTurnCounter:wave_turn_counter;
      
      public var activeFrame:active_frame;
      
      public var backing_texture_bottom:MovieClip;
      
      public var backing_texture_left:MovieClip;
      
      public var frameLeft:MovieClip;
      
      public var infoBar:infobar;
      
      public var lowTime:lowTime;
      
      public var nameflagEnemy:MovieClip;
      
      public var nameflagPlayer:MovieClip;
      
      public var order:init_order;
      
      public var statFlags:statflags;
      
      public var waveTurnCounterBackground:MovieClip;
      
      public function battle_initiative()
      {
         super();
      }
   }
}
