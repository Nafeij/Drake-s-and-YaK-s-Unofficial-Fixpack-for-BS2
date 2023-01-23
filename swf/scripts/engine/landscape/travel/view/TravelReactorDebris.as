package engine.landscape.travel.view
{
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.resource.BitmapResource;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class TravelReactorDebris extends TravelReactorSpriteBase
   {
       
      
      public var fallVelocity:Number = 0;
      
      public var rotationVelocity:Number = 0;
      
      public var GRAVITY:Number = 0.00001;
      
      public var TERMINAL:Number;
      
      public var durationMs:int = 0;
      
      public var elapsedMs:int = 0;
      
      public function TravelReactorDebris(param1:BitmapResource, param2:TravelReactorView, param3:Rectangle, param4:Point, param5:int)
      {
         this.TERMINAL = this.GRAVITY * 10000;
         super(param1,param2);
         this.durationMs = param5;
         var _loc6_:DisplayObjectWrapper = param1.getWrapperRect(param3);
         dow.addChild(_loc6_);
         _loc6_.x = -_loc6_.width / 2;
         dow.x = param4.x + _loc6_.width / 2;
         dow.y = param4.y;
         dow.alpha = 0.5;
         this.fallVelocity = this.TERMINAL * 0.25;
      }
      
      override public function cleanup() : void
      {
         super.cleanup();
      }
      
      override public function update(param1:int) : void
      {
         if(terminated)
         {
            return;
         }
         this.elapsedMs += param1;
         if(this.elapsedMs < this.durationMs)
         {
            if(dow.alpha < 1)
            {
               dow.alpha = Math.min(1,this.elapsedMs / 500);
            }
         }
         dow.y += dow.alpha * this.fallVelocity * param1;
         dow.rotationDegrees += this.rotationVelocity * param1;
         if(this.elapsedMs > this.durationMs)
         {
            if(dow.alpha > 0)
            {
               dow.alpha = Math.max(0,1 - (this.elapsedMs - this.durationMs) / 2000);
            }
            if(dow.alpha <= 0)
            {
               terminated = true;
            }
         }
      }
   }
}
