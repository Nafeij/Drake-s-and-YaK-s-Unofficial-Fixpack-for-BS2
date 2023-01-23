package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_CameraSplinePause extends Action
   {
       
      
      public function Action_CameraSplinePause(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         saga.performSceneCameraSplinePause(def.varvalue != 0);
         end();
      }
   }
}
