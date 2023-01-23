package engine.saga.action
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Quad;
   import engine.saga.Caravan;
   import engine.saga.Saga;
   
   public class Action_MapSpline extends Action
   {
       
      
      public var caravan:Caravan;
      
      public function Action_MapSpline(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         this.caravan = saga.caravan;
         if(!this.caravan)
         {
            throw new ArgumentError("No caravan for " + this);
         }
         var _loc1_:Number = def.time;
         var _loc2_:String = def.id;
         var _loc3_:String = def.anchor;
         var _loc4_:Number = def.varvalue;
         if(_loc1_ <= 0)
         {
            this.caravan.setMapSpline(_loc2_,_loc3_,_loc4_);
            end();
         }
         else
         {
            if(this.caravan.map_spline_id != _loc2_ || this.caravan.map_spline_key != _loc3_)
            {
               this.caravan.setMapSpline(_loc2_,_loc3_,0);
            }
            TweenMax.to(this.caravan,_loc1_,{
               "mapSplineT":_loc4_,
               "ease":Quad.easeInOut,
               "onComplete":this.tweenCompleteHandler
            });
            if(def.instant)
            {
               end();
            }
         }
      }
      
      private function tweenCompleteHandler() : void
      {
         end();
      }
      
      override protected function handleEnded() : void
      {
      }
      
      override public function triggerSceneExit(param1:String, param2:int) : void
      {
         TweenMax.killTweensOf(this.caravan);
         end();
      }
   }
}
