package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_CameraSpline extends Action
   {
       
      
      public function Action_CameraSpline(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         saga.caravanCameraLock = false;
         var _loc1_:Number = def.varvalue;
         var _loc2_:Number = def.time;
         if(_loc1_ <= 0 && _loc2_ <= 0)
         {
            saga.logger.error("Camera Spline Invalid speed: " + _loc1_ + " time: " + _loc2_);
            end();
            return;
         }
         ++saga.cameraPanning;
         saga.performSceneCameraSpline(def.id,_loc1_,_loc2_);
         if(def.instant)
         {
            end();
         }
      }
      
      override protected function handleEnded() : void
      {
         --saga.cameraPanning;
      }
      
      override public function triggerCameraSplineComplete(param1:String) : void
      {
         end();
      }
      
      override public function triggerSceneExit(param1:String, param2:int) : void
      {
         end();
      }
      
      override public function fastForward() : Boolean
      {
         end();
         return true;
      }
   }
}
