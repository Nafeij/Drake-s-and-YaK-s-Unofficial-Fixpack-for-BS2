package assets
{
   import flash.display.MovieClip;
   import game.gui.battle.initiative.GuiWaveTurnCounter;
   
   public dynamic class wave_turn_counter extends GuiWaveTurnCounter
   {
       
      
      public var countTextHolder:MovieClip;
      
      public var timer_ring_wave:MovieClip;
      
      public var toolTip:nineSliceToolTip;
      
      public function wave_turn_counter()
      {
         super();
      }
   }
}
