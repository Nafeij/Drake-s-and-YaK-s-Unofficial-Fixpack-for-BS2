package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_CameraCaravanLock extends Action
   {
       
      
      public function Action_CameraCaravanLock(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         saga.caravanCameraLock = def.varvalue != 0;
         end();
      }
      
      override protected function handleEnded() : void
      {
      }
      
      override public function triggerCameraAnchorReached() : void
      {
         end();
      }
   }
}
