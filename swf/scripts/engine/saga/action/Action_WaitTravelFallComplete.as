package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_WaitTravelFallComplete extends Action
   {
       
      
      public function Action_WaitTravelFallComplete(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         if(!saga.isTravelFalling())
         {
            saga.isTravelFalling();
            end();
         }
      }
      
      override public function handleTriggerTravelFallComplete() : void
      {
         end();
      }
   }
}
