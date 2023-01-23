package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_WaitReady extends Action
   {
       
      
      public function Action_WaitReady(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         if(saga.isSceneLoaded())
         {
            saga.isSceneLoaded();
            end();
         }
      }
      
      override protected function handleTriggerSceneLoaded(param1:String, param2:int) : void
      {
         end();
      }
      
      override public function triggerFlashPageReady(param1:String) : void
      {
         end();
      }
   }
}
