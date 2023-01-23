package engine.saga.action
{
   import engine.saga.Saga;
   import engine.scene.model.Scene;
   
   public class Action_CameraGlobalLock extends Action
   {
       
      
      public function Action_CameraGlobalLock(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:Scene = saga.getScene();
         if(_loc1_)
         {
            _loc1_.cameraGlobalLock = def.varvalue != 0;
         }
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
