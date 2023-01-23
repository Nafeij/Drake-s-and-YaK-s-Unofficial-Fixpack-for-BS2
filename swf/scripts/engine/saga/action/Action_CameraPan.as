package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_CameraPan extends Action
   {
       
      
      private var wasCameraLocked:Boolean;
      
      public function Action_CameraPan(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         if(!def.anchor)
         {
            throw new ArgumentError("Invalid anchor [" + def.anchor + "]");
         }
         var _loc1_:Number = def.varvalue;
         if(_loc1_ < 0)
         {
            throw new ArgumentError("Invalid speed [" + def.varvalue + "]");
         }
         ++saga.cameraPanning;
         saga.performSceneCameraPan(def.anchor,def.varvalue);
         if(def.instant)
         {
            end();
         }
      }
      
      override protected function handleEnded() : void
      {
         --saga.cameraPanning;
      }
      
      override public function triggerCameraAnchorReached() : void
      {
         end();
      }
      
      override public function triggerSceneExit(param1:String, param2:int) : void
      {
         end();
      }
      
      override public function fastForward() : Boolean
      {
         if(!ended && !def.instant)
         {
            saga.performSceneCameraPan(def.anchor,0);
            if(!ended)
            {
               end(true);
            }
            return true;
         }
         return false;
      }
   }
}
