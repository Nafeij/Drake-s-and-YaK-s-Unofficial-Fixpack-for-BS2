package engine.saga
{
   import engine.battle.board.model.IBattleBoard;
   
   public interface IBattleBoardProvider
   {
       
      
      function getIBattleBoard() : IBattleBoard;
   }
}
