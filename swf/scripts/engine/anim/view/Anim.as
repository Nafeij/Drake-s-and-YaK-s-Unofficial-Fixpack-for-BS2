package engine.anim.view
{
   import engine.anim.def.AnimClipDef;
   import engine.anim.def.IAnimDef;
   import engine.core.logging.ILogger;
   
   public class Anim implements IAnim
   {
       
      
      private var _def:IAnimDef;
      
      private var _clip:AnimClip;
      
      private var _accumulatedMovement:Number = 0;
      
      private var _remainingDistance:Number = -1;
      
      private var _reverse:Boolean;
      
      private var _playbackSpeed:Number = 1;
      
      private var _singleFrameOffsetValid:Boolean;
      
      private var _singleFrameOffset:int;
      
      private var animEventCallback:Function;
      
      private var finishedCallback:Function;
      
      private var logger:ILogger;
      
      private var didFinish:Boolean;
      
      public function Anim(param1:IAnimDef, param2:Function, param3:Function, param4:ILogger)
      {
         super();
         this._def = param1;
         this.logger = param4;
         this.animEventCallback = param2;
         this.finishedCallback = param3;
         if(!param1.clip)
         {
            throw new ArgumentError("Invalid def, no clip: " + param1);
         }
         this._clip = new AnimClip(param1.clip as AnimClipDef,this.clipEventCallback,this.clipFinishedCallback,param4);
      }
      
      public function cleanup() : void
      {
         this._def = null;
         if(this._clip != null)
         {
            this._clip.stop();
            this._clip.cleanup();
         }
         this._clip = null;
         this.animEventCallback = null;
         this.finishedCallback = null;
         this.logger = null;
      }
      
      public function set reverse(param1:Boolean) : void
      {
         this._reverse = param1;
         if(this._clip)
         {
            this._clip.reverse = param1;
         }
      }
      
      public function set playbackSpeed(param1:Number) : void
      {
         this._playbackSpeed = param1;
         if(this._clip)
         {
            this._clip.speedFactor = this._playbackSpeed;
         }
      }
      
      private function clipEventCallback(param1:AnimClip, param2:String) : void
      {
         if(this.animEventCallback != null)
         {
            this.animEventCallback(this,param2);
         }
      }
      
      private function clipFinishedCallback(param1:AnimClip) : void
      {
         this.didFinish = true;
      }
      
      public function popAccumulatedMovement() : Number
      {
         var _loc1_:Number = this._accumulatedMovement;
         this._accumulatedMovement = 0;
         return _loc1_;
      }
      
      public function peekAccumulatedMovement() : Number
      {
         return this._accumulatedMovement;
      }
      
      public function setAccumulatedMovement(param1:Number) : void
      {
         this._accumulatedMovement = param1;
      }
      
      public function advance(param1:int, param2:Boolean = false) : int
      {
         if(!this._def || !this._clip)
         {
            return 0;
         }
         var _loc3_:Number = this._def.moveSpeed;
         var _loc4_:Number = 1;
         if(_loc3_)
         {
            if(this._remainingDistance <= 0)
            {
               _loc4_ = 0;
            }
         }
         if(param2 == false)
         {
            param1 = this._clip.advance(param1);
         }
         if(!this._def || !this._clip || !this._clip._def)
         {
            return param1;
         }
         if(_loc3_)
         {
            if(this._remainingDistance >= 0)
            {
               this._accumulatedMovement += Math.min(this._remainingDistance,param1 / 1000 * _loc3_ * _loc4_);
            }
            else
            {
               this._accumulatedMovement += param1 / 1000 * _loc3_ * _loc4_;
            }
         }
         else if(this._clip._def.locomotiveTilesTotal)
         {
            if(this._remainingDistance >= 0)
            {
               this._accumulatedMovement += Math.min(this._remainingDistance,this._clip.accumulatedLocomotiveTiles);
            }
            else
            {
               this._accumulatedMovement += this._clip.accumulatedLocomotiveTiles;
            }
            this._clip.accumulatedLocomotiveTiles = 0;
         }
         if(this.didFinish && this.finishedCallback != null)
         {
            this.finishedCallback(this);
         }
         return param1;
      }
      
      public function toString() : String
      {
         return "Anim [def=" + this._def + ", clip=" + this.clip + "]";
      }
      
      public function get elapsedMs() : int
      {
         return this._clip.elapsedMs;
      }
      
      public function get count() : int
      {
         return this._clip.count;
      }
      
      public function get def() : IAnimDef
      {
         return this._def;
      }
      
      public function get frame() : int
      {
         return this._clip.frame;
      }
      
      public function get playing() : Boolean
      {
         return this._clip.playing;
      }
      
      public function start(param1:int) : void
      {
         var _loc2_:Number = 0;
         var _loc3_:AnimClipDef = this._clip._def;
         if(Boolean(_loc3_) && _loc3_.durationMs > 0)
         {
            if(this._singleFrameOffsetValid)
            {
               if(this._singleFrameOffset >= 0)
               {
                  _loc2_ = this._singleFrameOffset;
               }
               else
               {
                  _loc2_ = _loc3_.numFrames + this._singleFrameOffset;
               }
            }
            else
            {
               _loc2_ = param1 * _loc3_.numFrames / _loc3_.durationMs;
               if(this._reverse)
               {
                  _loc2_ = (_loc3_._numFrames * 2 - 1 - _loc2_) % _loc3_.numFrames;
               }
               else
               {
                  _loc2_ = _loc2_;
               }
            }
         }
         this._clip.start(_loc2_);
         if(this._singleFrameOffsetValid)
         {
            this._clip.stop();
         }
      }
      
      public function restart() : void
      {
         this._clip.restart();
      }
      
      public function stop() : void
      {
         if(this._clip != null)
         {
            this._clip.stop();
         }
      }
      
      public function set frame(param1:int) : void
      {
         this._clip.setFrameNumber(param1);
      }
      
      public function set count(param1:int) : void
      {
         this._clip.count = param1;
      }
      
      public function get repeatLimit() : int
      {
         return this._clip.repeatLimit;
      }
      
      public function set repeatLimit(param1:int) : void
      {
         this._clip.repeatLimit = param1;
      }
      
      public function finishAsap() : void
      {
         this.repeatLimit = this._clip.count + 1;
      }
      
      public function get timeLimitMs() : int
      {
         return this._clip.timeLimitMs;
      }
      
      public function set timeLimitMs(param1:int) : void
      {
         this._clip.timeLimitMs = param1;
      }
      
      public function set remainingDistance(param1:Number) : void
      {
         this._remainingDistance = param1;
      }
      
      public function get clip() : AnimClip
      {
         return this._clip;
      }
      
      public function set singleFrameOffsetValid(param1:Boolean) : void
      {
         this._singleFrameOffsetValid = param1;
      }
      
      public function set singleFrameOffset(param1:int) : void
      {
         this._singleFrameOffset = param1;
      }
   }
}
