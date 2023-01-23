package engine.saga.action
{
   import engine.battle.fsm.BattleTurnOrder;
   import engine.saga.Saga;
   
   public class Action_BattleSuppressPillage extends Action
   {
       
      
      public function Action_BattleSuppressPillage(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         BattleTurnOrder.SUPPRESS_PILLAGE = def.varvalue != 0;
         end();
      }
   }
}
