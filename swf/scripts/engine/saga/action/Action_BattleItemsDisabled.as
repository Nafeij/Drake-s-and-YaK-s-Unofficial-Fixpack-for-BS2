package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_BattleItemsDisabled extends Action
   {
       
      
      public function Action_BattleItemsDisabled(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         saga.battleItemsDisabled = def.varvalue != 0;
         end();
      }
   }
}
