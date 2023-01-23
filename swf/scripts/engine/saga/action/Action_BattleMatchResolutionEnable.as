package engine.saga.action
{
   import engine.battle.board.model.BattleBoard;
   import engine.saga.Saga;
   
   public class Action_BattleMatchResolutionEnable extends Action
   {
       
      
      public function Action_BattleMatchResolutionEnable(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:BattleBoard = saga.getBattleBoard();
         _loc1_.matchResolutionEnabled = def.varvalue != 0;
         end();
      }
   }
}
