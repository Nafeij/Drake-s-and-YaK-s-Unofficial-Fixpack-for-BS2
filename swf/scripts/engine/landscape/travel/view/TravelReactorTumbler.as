package engine.landscape.travel.view
{
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.math.MathUtil;
   import engine.resource.BitmapResource;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class TravelReactorTumbler extends TravelReactorSpriteBase
   {
       
      
      public var fallVelocity:Number = 0;
      
      public var rotationVelocity:Number = 0;
      
      public var GRAVITY:Number = 0.00001;
      
      public var TERMINAL:Number;
      
      public var targetY:Number;
      
      public function TravelReactorTumbler(param1:BitmapResource, param2:TravelReactorView, param3:Rectangle, param4:Point, param5:Number, param6:Number)
      {
         this.TERMINAL = this.GRAVITY * 10000;
         super(param1,param2);
         this.targetY = param5;
         var _loc7_:DisplayObjectWrapper = param1.getWrapperRect(param3);
         dow.addChild(_loc7_);
         _loc7_.x = -_loc7_.width / 2;
         _loc7_.y = -_loc7_.height / 2;
         dow.x = param4.x;
         dow.y = param4.y - _loc7_.height / 2;
         dow.alpha = 0;
         this.fallVelocity = Math.random() * this.TERMINAL * 0.2;
         this.rotationVelocity = MathUtil.randomInt(-100,100) * 0.002 * param6;
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
         if(dow.alpha < 1)
         {
            dow.alpha = Math.min(1,dow.alpha + param1 * 0.01);
         }
         dow.y += dow.alpha * this.fallVelocity * param1;
         dow.rotationDegrees += this.rotationVelocity * param1;
         this.fallVelocity += param1 * this.GRAVITY;
         this.fallVelocity = Math.min(this.TERMINAL,this.fallVelocity);
         if(dow.y > this.targetY)
         {
            terminated = true;
         }
      }
   }
}
