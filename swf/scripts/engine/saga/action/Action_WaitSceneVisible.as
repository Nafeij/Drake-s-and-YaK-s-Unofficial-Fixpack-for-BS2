package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_WaitSceneVisible extends Action
   {
       
      
      public function Action_WaitSceneVisible(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         if(saga.isSceneVisible())
         {
            end();
         }
      }
      
      override public function handleTriggerSceneVisible(param1:String, param2:int) : void
      {
         end();
      }
   }
}
