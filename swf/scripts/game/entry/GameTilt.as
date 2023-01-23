package game.entry
{
   import engine.math.MathUtil;
   import engine.scene.view.SceneMouseAdapter;
   
   public class GameTilt
   {
      
      private static const oo_PI:Number = 1 / Math.PI;
      
      private static var RECENTER_DELAY_SECS:Number = 3.5;
       
      
      public var tiltCentered:Boolean;
      
      public var tiltRollCenterRadians:Number = 0;
      
      public var tiltPitchCenterRadians:Number = 0;
      
      public var tiltRollRadians:Number = 0;
      
      public var tiltPitchRadians:Number = 0;
      
      public var tiltPanX:Number = 0;
      
      public var tiltPanY:Number = 0;
      
      public var flipTilt:Boolean = false;
      
      public var tiltMagnitude:Number = 100;
      
      private var lastDeltaTiltMax:Number = 0;
      
      private var recenterDelay:int;
      
      private var tiltRecenterSpeed:Number = 0.5;
      
      private var tiltActiveDamp:Number = 1;
      
      public function GameTilt()
      {
         super();
      }
      
      final public function setTiltRadians(param1:Number, param2:Number) : void
      {
         var _loc3_:Number = Math.abs(this.tiltPitchRadians - param2);
         var _loc4_:Number = Math.abs(this.tiltRollRadians - param1);
         var _loc5_:Number = Math.max(_loc4_,_loc3_);
         if(_loc5_ > 0.2)
         {
            this.recenterDelay = Math.max(this.recenterDelay,RECENTER_DELAY_SECS * _loc5_ * 1000);
         }
         this.lastDeltaTiltMax = Math.max(this.lastDeltaTiltMax,_loc5_);
         this.tiltPitchRadians = param2;
         this.tiltRollRadians = param1;
         if(!this.tiltCentered)
         {
            this.tiltRollCenterRadians = param1;
            this.tiltPitchCenterRadians = param2;
            this.tiltCentered = true;
         }
      }
      
      private function computeTiltPan() : void
      {
         this.tiltPanX = this.tiltPitchRadians - this.tiltPitchCenterRadians;
         this.tiltPanY = this.tiltRollRadians - this.tiltRollCenterRadians;
         this.tiltPanX = Math.min(0.5,Math.max(-0.5,this.tiltPanX * oo_PI)) * 2;
         this.tiltPanY = -Math.min(0.5,Math.max(-0.5,this.tiltPanY * oo_PI)) * 2;
         this.tiltPanX *= this.tiltMagnitude;
         this.tiltPanY *= this.tiltMagnitude;
         if(this.flipTilt)
         {
            this.tiltPanX *= -1;
            this.tiltPanY *= -1;
         }
      }
      
      public function update(param1:int) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(this.tiltCentered)
         {
            this.recenterDelay = Math.max(0,this.recenterDelay - param1);
            if(this.recenterDelay <= 0)
            {
               _loc2_ = Math.min(1,this.tiltRecenterSpeed * param1 / 1000);
               _loc3_ = Math.min(1,this.tiltActiveDamp * param1 / 1000);
               this.lastDeltaTiltMax = MathUtil.lerp(this.lastDeltaTiltMax,0,_loc3_);
               _loc4_ = Math.max(0,Math.min(1,1 - this.lastDeltaTiltMax));
               _loc2_ *= _loc4_;
               this.tiltRollCenterRadians = MathUtil.lerp(this.tiltRollCenterRadians,this.tiltRollRadians,_loc2_);
               this.tiltPitchCenterRadians = MathUtil.lerp(this.tiltPitchCenterRadians,this.tiltPitchRadians,_loc2_);
            }
         }
         this.computeTiltPan();
         if(SceneMouseAdapter.instanceCamera)
         {
            SceneMouseAdapter.instanceCamera.setTiltOffset(this.tiltPanX,this.tiltPanY);
         }
      }
   }
}
