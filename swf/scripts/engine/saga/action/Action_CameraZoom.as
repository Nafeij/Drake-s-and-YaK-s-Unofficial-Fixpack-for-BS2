package engine.saga.action
{
   import com.greensock.TweenMax;
   import engine.core.render.BoundedCamera;
   import engine.saga.Saga;
   import engine.scene.model.Scene;
   
   public class Action_CameraZoom extends Action
   {
       
      
      public function Action_CameraZoom(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc4_:BoundedCamera = null;
         var _loc1_:Scene = saga.getScene();
         var _loc2_:Number = def.time;
         var _loc3_:Number = def.varvalue;
         if(_loc1_ && _loc3_ > 0 && !isNaN(_loc3_))
         {
            _loc4_ = _loc1_._camera;
            if(_loc2_ <= 0 || isNaN(_loc2_))
            {
               _loc4_.zoom = _loc3_;
            }
            else
            {
               TweenMax.to(_loc4_,_loc2_,{
                  "zoom":_loc3_,
                  "onComplete":this.tweenCompleteHandler
               });
               if(!def.instant)
               {
                  return;
               }
            }
         }
         end();
      }
      
      public function tweenCompleteHandler() : void
      {
         end();
      }
   }
}
