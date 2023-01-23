package game.gui.battle
{
   public interface IGuiBattleHudListener
   {
       
      
      function guiBattleHudDeployReady() : Boolean;
      
      function guiBattleHudWaveFlee() : Boolean;
      
      function guiBattleHudWaveFight() : Boolean;
   }
}
