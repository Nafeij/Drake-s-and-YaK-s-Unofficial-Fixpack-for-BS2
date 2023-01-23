package engine.saga.action
{
   import engine.battle.board.model.BattleObjective;
   import engine.saga.Saga;
   
   public class Action_BattleWaitObjectiveOpened extends Action
   {
       
      
      public function Action_BattleWaitObjectiveOpened(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
      }
      
      override public function triggerBattleObjectiveOpened(param1:BattleObjective) : void
      {
         end();
      }
   }
}
