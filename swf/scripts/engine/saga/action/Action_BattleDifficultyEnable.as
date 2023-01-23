package engine.saga.action
{
   import engine.battle.board.model.BattleBoard;
   import engine.saga.Saga;
   
   public class Action_BattleDifficultyEnable extends Action
   {
       
      
      public function Action_BattleDifficultyEnable(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:BattleBoard = saga.getBattleBoard();
         if(_loc1_)
         {
            _loc1_.difficultyDisabled = def.varvalue == 0;
         }
         end();
      }
   }
}
