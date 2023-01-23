package engine.core.render
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Quad;
   import engine.math.MathUtil;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   
   public class CameraDrifter
   {
      
      public static var FAST:Boolean;
      
      public static const DRIFT_CHECK_DELAY:int = 2000;
      
      public static const ANCHOR_CHECK_DELAY:int = 200;
       
      
      private var _anchorSpeed:Number = 0;
      
      private var _driftMax:Number = 0;
      
      private var _anchor:Point;
      
      public var camera:BoundedCamera;
      
      private var driftTween:TweenMax;
      
      private var _drift:Point;
      
      public var driftV:Point;
      
      private var _pause:Boolean = false;
      
      private var _enableDrift:Boolean = true;
      
      private var driftTimer:Timer;
      
      private var _anchorTimering:Boolean;
      
      private var _anchorTimerRemaining:int;
      
      private var _pauseBreaksAnchor:Boolean;
      
      public var CAMERA_SNAP_THRESHOLD:Number = 0;
      
      private var _anchorTweening:Boolean;
      
      private var _anchorTweenDuration:int;
      
      private var _anchorTweenElapsed:int;
      
      private var _anchorTweenTarget:Point;
      
      private var _anchorTweenStart:Point;
      
      private var _anchorTweenRange:Point;
      
      private var ease:Function;
      
      private var _isAnchorAnimating:Boolean;
      
      private var cleanedup:Boolean;
      
      public function CameraDrifter(param1:Camera)
      {
         this._drift = new Point();
         this.driftV = new Point();
         this.driftTimer = new Timer(DRIFT_CHECK_DELAY,1);
         this._anchorTweenTarget = new Point();
         this._anchorTweenStart = new Point();
         this._anchorTweenRange = new Point();
         this.ease = Quad.easeInOut;
         super();
         this.camera = param1 as BoundedCamera;
         this.driftTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.driftTimerCompleteHandler);
         this.checkAnchor();
      }
      
      private function startAnchorTween() : void
      {
         if(this._pause || this._anchorTweening || !this._anchor)
         {
            return;
         }
         if(this.anchorSpeed <= 0)
         {
            return;
         }
         var _loc1_:Point = new Point(this._anchor.x - this.camera.unclampedX,this._anchor.y - this.camera.unclampedY);
         var _loc2_:Number = Math.max(0.5,_loc1_.length / this.anchorSpeed) * this.camera.scale;
         if(FAST && Boolean(_loc2_))
         {
            _loc2_ = Math.max(0.25,_loc2_ / 4);
         }
         this._anchorTweening = true;
         this._anchorTweenDuration = _loc2_ * 1000;
         this._anchorTweenElapsed = 0;
         this._anchorTweenStart.setTo(this.camera.unclampedX,this.camera.unclampedY);
         this._anchorTweenTarget.setTo(this._anchor.x,this._anchor.y);
         this._anchorTweenRange.setTo(this._anchorTweenTarget.x - this._anchorTweenStart.x,this._anchorTweenTarget.y - this._anchorTweenStart.y);
      }
      
      private function driftTimerCompleteHandler(param1:TimerEvent) : void
      {
         this.driftTweenCompleteHandler();
      }
      
      public function get pause() : Boolean
      {
         return this._pause;
      }
      
      private function checkAnchorAnimating() : void
      {
         this.isAnchorAnimating = Boolean(this._anchor) && (this._anchorTweening || this._anchorTimering);
      }
      
      public function forceAnchor() : void
      {
         if(this._anchor)
         {
            this.camera.setPosition(this._anchor.x,this._anchor.y);
         }
         this._anchorTweening = false;
         this._anchorTimering = false;
         this.checkAnchorAnimating();
      }
      
      public function get isAnchorAnimating() : Boolean
      {
         return this._isAnchorAnimating;
      }
      
      public function set isAnchorAnimating(param1:Boolean) : void
      {
         if(this._isAnchorAnimating == param1)
         {
            return;
         }
         this._isAnchorAnimating = param1;
         if(!this._isAnchorAnimating)
         {
            if(!this.cleanedup)
            {
               this.camera.dispatchEvent(new Event(Camera.EVENT_ANCHOR_REACHED));
            }
         }
      }
      
      public function set pause(param1:Boolean) : void
      {
         if(this._pause != param1)
         {
            this._pause = param1;
            if(this._pauseBreaksAnchor)
            {
               this.anchor = null;
            }
            this.checkAnchor();
         }
      }
      
      public function cleanup() : void
      {
         this.driftTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.driftTimerCompleteHandler);
         this.stopAnchor();
         this.stopDrift();
         this.driftTimer = null;
         this._anchorTimering = false;
         this.pause = false;
         this.camera = null;
         this.driftTimer = null;
      }
      
      private function stopAnchor() : void
      {
         if(this._anchorTweening)
         {
            this._anchorTweening = false;
            this.checkAnchorAnimating();
         }
      }
      
      private function checkAnchor(param1:Boolean = false, param2:Boolean = false) : void
      {
         this.stopDrift();
         this._anchorTimering = false;
         if(this._pause)
         {
            this.stopAnchor();
            return;
         }
         if(this.camera && this._anchor && this.anchorSpeed > 0 && (this.camera.unclampedX != this._anchor.x || this.camera.unclampedY != this._anchor.y))
         {
            this._anchorTimering = false;
            if(param2)
            {
               this.camera.x = this._anchor.x;
               this.camera.y = this._anchor.y;
            }
            else if(param1)
            {
               this.ease = Quad.easeOut;
               this.startAnchorTween();
            }
            else
            {
               this.ease = Quad.easeInOut;
               this._anchorTimering = true;
               this._anchorTimerRemaining = ANCHOR_CHECK_DELAY * Math.max(1,this.camera.scale);
            }
            this.checkAnchorAnimating();
            return;
         }
         if(this.driftMax > 0)
         {
            if(!this.pause && !this._anchorTweening && Boolean(this.driftTimer))
            {
               this.driftTimer.reset();
               this.driftTimer.start();
            }
         }
         this.checkAnchorAnimating();
      }
      
      private function stopDrift() : void
      {
         if(Boolean(this.driftTimer) && this.driftTimer.running)
         {
            this.driftTimer.stop();
         }
         if(this.driftTween)
         {
            this.driftTween.kill();
            this.driftTween = null;
         }
      }
      
      public function get driftX() : Number
      {
         return this._drift.x;
      }
      
      public function get driftY() : Number
      {
         return this._drift.y;
      }
      
      public function set driftX(param1:Number) : void
      {
         var _loc2_:Number = param1 - this._drift.x;
         this._drift.x = param1;
         if(!this._pause)
         {
            if(this.camera)
            {
               this.camera.x += _loc2_;
            }
         }
      }
      
      public function set driftY(param1:Number) : void
      {
         var _loc2_:Number = param1 - this._drift.y;
         this._drift.y = param1;
         if(!this._pause)
         {
            if(this.camera)
            {
               this.camera.y += _loc2_;
            }
         }
      }
      
      private function driftTweenCompleteHandler() : void
      {
         if(this._pause || this._anchorTweening || this.driftMax <= 0)
         {
            return;
         }
         var _loc1_:Number = 1;
         this.driftV.x = MathUtil.clampValue(this.driftMax * _loc1_ * (2 * Math.random() - 1),-this.driftMax,this.driftMax);
         this.driftV.y = MathUtil.clampValue(this.driftMax * _loc1_ * (2 * Math.random() - 1),-this.driftMax,this.driftMax);
         var _loc2_:Number = DRIFT_CHECK_DELAY / 1000;
         var _loc3_:Number = _loc2_ + 0.5 * (Math.random() - 0.5) * Math.max(1,this.camera.scale);
         this.driftTween = TweenMax.to(this,_loc3_,{
            "driftX":this.driftV.x,
            "driftY":this.driftV.y,
            "ease":Quad.easeInOut,
            "onComplete":this.driftTweenCompleteHandler
         });
      }
      
      public function get pauseBreaksAnchor() : Boolean
      {
         return this._pauseBreaksAnchor;
      }
      
      public function set pauseBreaksAnchor(param1:Boolean) : void
      {
         this._pauseBreaksAnchor = param1;
      }
      
      public function get anchor() : Point
      {
         return this._anchor;
      }
      
      public function set anchor(param1:Point) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:BoundedCamera = null;
         var _loc5_:Boolean = false;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         if(param1)
         {
            _loc2_ = param1.x;
            _loc3_ = param1.y;
            _loc4_ = this.camera as BoundedCamera;
            if(Boolean(_loc4_) && !_loc4_.boundsDisabled)
            {
               _loc2_ = _loc4_.clampX(_loc2_,true);
               _loc3_ = _loc4_.clampY(_loc3_,true);
            }
            _loc2_ = int(_loc2_);
            _loc3_ = int(_loc3_);
            if(!this._anchor || this._anchor.x != _loc2_ || this._anchor.y != _loc3_)
            {
               _loc5_ = false;
               if(Boolean(this._anchor) && this.CAMERA_SNAP_THRESHOLD > 0)
               {
                  _loc6_ = MathUtil.manhattanDistance(this.anchor.x,this.anchor.y,this.camera.unclampedX,this.camera.unclampedY);
                  if(_loc6_ < this.CAMERA_SNAP_THRESHOLD)
                  {
                     _loc7_ = MathUtil.manhattanDistance(this.anchor.x,this.anchor.y,_loc2_,_loc3_);
                     if(_loc7_ < this.CAMERA_SNAP_THRESHOLD)
                     {
                        _loc5_ = true;
                     }
                  }
               }
               this._anchor = new Point(_loc2_,_loc3_);
               this.stopAnchor();
               this.checkAnchor(true,_loc5_);
            }
         }
         else if(this._anchor)
         {
            this._anchor = null;
            this.stopAnchor();
         }
      }
      
      public function get anchorSpeed() : Number
      {
         return this._anchorSpeed;
      }
      
      public function set anchorSpeed(param1:Number) : void
      {
         if(this._anchorSpeed != param1)
         {
            this._anchorSpeed = param1;
            this.stopAnchor();
            this.checkAnchor();
         }
      }
      
      public function get driftMax() : Number
      {
         return this._driftMax;
      }
      
      public function set driftMax(param1:Number) : void
      {
         if(this._driftMax != param1)
         {
            this._driftMax = param1;
            this.stopAnchor();
            this.checkAnchor();
         }
      }
      
      public function update(param1:int) : void
      {
         if(this._anchorTimering)
         {
            this._anchorTimerRemaining -= param1;
            if(this._anchorTimerRemaining <= 0)
            {
               this._anchorTimering = false;
               this.startAnchorTween();
               return;
            }
         }
         if(this._anchorTweening)
         {
            this._anchorTweenElapsed = Math.min(this._anchorTweenDuration,this._anchorTweenElapsed + param1);
            this._anchorTweenTarget.setTo(this._anchor.x,this._anchor.y);
            if(this.ease == Quad.easeOut)
            {
               this.camera.unclampedX = Quad.easeOut(this._anchorTweenElapsed,this._anchorTweenStart.x,this._anchorTweenRange.x,this._anchorTweenDuration);
               this.camera.unclampedY = Quad.easeOut(this._anchorTweenElapsed,this._anchorTweenStart.y,this._anchorTweenRange.y,this._anchorTweenDuration);
            }
            else if(this.ease == Quad.easeInOut)
            {
               this.camera.unclampedX = Quad.easeInOut(this._anchorTweenElapsed,this._anchorTweenStart.x,this._anchorTweenRange.x,this._anchorTweenDuration);
               this.camera.unclampedY = Quad.easeInOut(this._anchorTweenElapsed,this._anchorTweenStart.y,this._anchorTweenRange.y,this._anchorTweenDuration);
            }
            else
            {
               this.camera.unclampedX = this.ease(this._anchorTweenElapsed,this._anchorTweenStart.x,this._anchorTweenRange.x,this._anchorTweenDuration);
               this.camera.unclampedY = this.ease(this._anchorTweenElapsed,this._anchorTweenStart.y,this._anchorTweenRange.y,this._anchorTweenDuration);
            }
            if(this._anchorTweenElapsed >= this._anchorTweenDuration)
            {
               this._anchorTweening = false;
               this.checkAnchor();
            }
         }
      }
   }
}
