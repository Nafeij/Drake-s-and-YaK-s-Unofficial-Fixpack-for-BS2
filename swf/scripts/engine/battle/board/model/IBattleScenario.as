package engine.battle.board.model
{
   public interface IBattleScenario
   {
       
      
      function doCompleteAll() : void;
      
      function doCompleteAllHints() : void;
      
      function handleBattleStarted() : void;
      
      function handleBattleWin() : void;
      
      function handleFreeTurn(param1:IBattleEntity) : void;
      
      function handleTurnStart(param1:IBattleEntity) : void;
      
      function get complete() : Boolean;
   }
}
