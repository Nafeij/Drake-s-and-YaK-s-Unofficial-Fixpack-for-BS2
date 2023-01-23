package engine.saga.action
{
   import engine.battle.fsm.state.turn.cmd.BattleTurnCmdAction;
   import engine.saga.Saga;
   
   public class Action_BattleSuppressTurnEnd extends Action
   {
       
      
      public function Action_BattleSuppressTurnEnd(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         BattleTurnCmdAction.SUPPRESS_TURN_END = def.varvalue != 0;
         end();
      }
   }
}
