package engine.saga.action
{
   import engine.landscape.travel.model.Travel;
   import engine.saga.Saga;
   import engine.scene.model.Scene;
   
   public class Action_CameraCaravanAnchor extends Action
   {
       
      
      public function Action_CameraCaravanAnchor(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:Scene = saga.getScene();
         var _loc2_:Travel = Boolean(_loc1_) && Boolean(_loc1_.landscape) ? _loc1_.landscape.travel : null;
         if(_loc2_)
         {
            _loc2_.allowCameraCaravanAnchor = def.varvalue != 0;
         }
         end();
      }
   }
}
