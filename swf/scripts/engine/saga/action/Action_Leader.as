package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_Leader extends Action
   {
       
      
      public function Action_Leader(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         if(!saga.caravan)
         {
            saga.logger.error("No caravan for " + this);
         }
         else
         {
            saga.caravan.leader = def.id;
         }
         end();
      }
   }
}
