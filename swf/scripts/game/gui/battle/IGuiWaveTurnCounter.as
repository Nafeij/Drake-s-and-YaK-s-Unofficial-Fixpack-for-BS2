package game.gui.battle
{
   import engine.battle.wave.BattleWave;
   
   public interface IGuiWaveTurnCounter
   {
       
      
      function SetTurnCount(param1:BattleWave) : void;
      
      function get visible() : Boolean;
      
      function set visible(param1:Boolean) : void;
   }
}
