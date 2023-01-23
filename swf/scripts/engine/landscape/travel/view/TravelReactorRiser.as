package engine.landscape.travel.view
{
   import com.greensock.easing.Quad;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.math.MathUtil;
   import engine.resource.BitmapResource;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class TravelReactorRiser extends TravelReactorSpriteBase
   {
       
      
      public var targetPoint:Point;
      
      public var targetDurationMs:int;
      
      public var reached:Boolean;
      
      public var targetRemainingTime:int;
      
      public var startPoint:Point;
      
      public var startRotation:Number = 0;
      
      public var targetRotation:Number = 0;
      
      public var splineLocation:Number = 0;
      
      public var falling:Boolean;
      
      public var fallVelocity:Number = 0;
      
      public var rotationVelocity:Number = 0;
      
      public var rotationVelocityTarget:Number = 0;
      
      public var GRAVITY:Number = 0.00001;
      
      public var TERMINAL:Number;
      
      public var debrisRect:Rectangle;
      
      public var debrisDurationMs:int;
      
      public var index:int;
      
      public function TravelReactorRiser(param1:int, param2:Number, param3:BitmapResource, param4:Rectangle, param5:Point, param6:Point, param7:Number, param8:int, param9:TravelReactorView, param10:Rectangle, param11:int, param12:Boolean)
      {
         this.targetPoint = new Point();
         this.startPoint = new Point();
         this.TERMINAL = this.GRAVITY * 10000;
         super(param3,param9);
         this.index = param1;
         this.splineLocation = param2;
         this.targetRotation = param7;
         this.debrisRect = param10;
         this.debrisDurationMs = param11;
         var _loc13_:DisplayObjectWrapper = param3.getWrapperRect(param4);
         dow.addChild(_loc13_);
         if(param12)
         {
            _loc13_.scaleX = -1;
            _loc13_.x = _loc13_.width / 2;
         }
         else
         {
            _loc13_.x = -_loc13_.width / 2;
         }
         this.targetPoint.copyFrom(param6);
         this.startPoint.copyFrom(param5);
         dow.x = this.startPoint.x;
         dow.y = this.startPoint.y;
         this.targetDurationMs = param8;
         if(_loc13_.width <= 16)
         {
            this.targetDurationMs *= 0.8 + Math.random() * 0.2;
         }
         else if(_loc13_.width <= 32)
         {
            this.targetDurationMs *= 0.9 + Math.random() * 0.1;
         }
         this.targetRemainingTime = this.targetDurationMs;
         if(param8 <= 0)
         {
            this.reachTarget(false);
         }
         else
         {
            this.startRotation = MathUtil.randomInt(-270,270);
            dow.rotationDegrees = this.startRotation;
            this.makeDebris(1);
         }
      }
      
      override public function update(param1:int) : void
      {
         if(terminated)
         {
            return;
         }
         if(this.falling)
         {
            if(this.rotationVelocityTarget > this.rotationVelocity)
            {
               this.rotationVelocity = Math.min(this.rotationVelocityTarget,this.rotationVelocity + param1 / 100000);
            }
            else if(this.rotationVelocityTarget < this.rotationVelocity)
            {
               this.rotationVelocity = Math.max(this.rotationVelocityTarget,this.rotationVelocity - param1 / 100000);
            }
            dow.y += this.fallVelocity * param1;
            dow.rotationDegrees += this.rotationVelocity * param1;
            this.fallVelocity += param1 * this.GRAVITY;
            this.fallVelocity = Math.min(this.TERMINAL,this.fallVelocity);
            if(dow.y > this.startPoint.y)
            {
               terminated = true;
               if(view.def.landSoundEvent)
               {
                  view.context.soundDriver.playEvent(view.def.landSoundEvent);
               }
            }
            return;
         }
         if(this.reached)
         {
            if(this.splineLocation + dow.width < view.currentLocationCaravanEnd)
            {
               this.startFalling();
            }
            return;
         }
         if(param1 <= 0)
         {
            return;
         }
         this.targetRemainingTime -= param1;
         var _loc2_:Number = view.currentLocationCaravanStart;
         if(this.targetRemainingTime <= 0 || _loc2_ >= this.splineLocation)
         {
            this.reachTarget(true);
            return;
         }
         var _loc3_:int = this.targetDurationMs - this.targetRemainingTime;
         var _loc4_:Number = _loc3_ / this.targetDurationMs;
         _loc4_ = Math.min(1,_loc4_);
         _loc4_ *= _loc4_ * _loc4_;
         _loc4_ = Quad.easeOut(_loc4_,0,1,1);
         dow.x = MathUtil.lerp(this.startPoint.x,this.targetPoint.x,_loc4_);
         var _loc5_:Number = dow.y;
         dow.y = MathUtil.lerp(this.startPoint.y,this.targetPoint.y,_loc4_);
         this.fallVelocity = (dow.y - _loc5_) / param1;
         this.fallVelocity = Math.max(this.fallVelocity,-this.TERMINAL / 4);
         var _loc6_:Number = dow.rotationDegrees;
         dow.rotationDegrees = MathUtil.lerp(this.startRotation,this.targetRotation,_loc4_);
         this.rotationVelocity = (dow.rotationDegrees - _loc6_) / param1;
      }
      
      private function makeDebris(param1:Number) : void
      {
         var _loc2_:TravelReactorDebris = null;
         if(this.debrisRect)
         {
            _loc2_ = new TravelReactorDebris(br,view,this.debrisRect,new Point(dow.x,dow.y),this.debrisDurationMs * param1);
            view.addSprite(_loc2_);
         }
      }
      
      private function reachTarget(param1:Boolean) : void
      {
         this.fallVelocity = 0;
         this.rotationVelocity = 0;
         dow.rotationDegrees = this.targetRotation;
         dow.x = this.targetPoint.x;
         dow.y = this.targetPoint.y;
         this.reached = true;
         if(param1)
         {
            this.makeDebris(0.5);
            if(view.def.reachSoundEvent)
            {
               view.context.soundDriver.playEvent(view.def.reachSoundEvent);
            }
         }
      }
      
      private function startFalling() : void
      {
         if(this.falling)
         {
            return;
         }
         this.falling = true;
         if(!this.rotationVelocity)
         {
            this.rotationVelocityTarget = MathUtil.randomInt(-100,100) * 0.0002;
         }
         else
         {
            this.rotationVelocityTarget = this.rotationVelocity;
         }
         this.makeDebris(1);
         if(view.def.fallSoundEvent)
         {
            view.context.soundDriver.playEvent(view.def.fallSoundEvent);
         }
         view.uncountRiser(this);
      }
   }
}
