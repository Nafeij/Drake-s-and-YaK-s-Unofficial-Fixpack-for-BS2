package engine.anim.def
{
   import engine.anim.view.IAnim;
   import engine.core.logging.ILogger;
   
   public class OrientedAnims
   {
       
      
      public var def:OrientedAnimsDef;
      
      public var library:IAnimLibrary;
      
      private var facingDirty:Boolean = true;
      
      private var _anim:IAnim;
      
      private var _facing:IAnimFacing;
      
      private var _repeatLimit:int;
      
      private var _timeLimitMs:int;
      
      private var orientedAnimsEventCallback:Function;
      
      private var animFinishedCallback:Function;
      
      private var logger:ILogger;
      
      public var hold:Boolean;
      
      public var holding:Boolean;
      
      public var frozen:Boolean = false;
      
      private var _remainingDistance:Number = -1;
      
      private var _accumulatedMovement:Number = 0;
      
      public var ignoreFreezeFrame:Boolean = true;
      
      private var layer:String;
      
      public var reverse:Boolean;
      
      public var playbackSpeed:Number = 1;
      
      public var singleFrameOffsetValid:Boolean;
      
      public var singleFrameOffset:int;
      
      public var priority:int;
      
      public function OrientedAnims(param1:String, param2:OrientedAnimsDef, param3:IAnimLibrary, param4:Function, param5:Function, param6:ILogger)
      {
         super();
         if(!param2)
         {
            throw new ArgumentError("OrientedAnims need a def, fool");
         }
         this.layer = param1;
         this.def = param2;
         this.library = param3;
         this.orientedAnimsEventCallback = param4;
         this.animFinishedCallback = param5;
         this.logger = param6;
      }
      
      public function cleanup() : void
      {
         this.def = null;
         this.library = null;
         if(this._anim != null)
         {
            this._anim.cleanup();
            this._anim = null;
         }
         this.orientedAnimsEventCallback = null;
         this.animFinishedCallback = null;
         this.logger = null;
      }
      
      public function toString() : String
      {
         return "[" + this.def.name + ", " + (!!this.library ? this.library.url : "no-library") + "]";
      }
      
      public function stop() : void
      {
         if(this._anim)
         {
            this._anim.stop();
         }
      }
      
      public function advance(param1:int) : int
      {
         if(this.holding)
         {
            return 0;
         }
         if(this.frozen == true && this.ignoreFreezeFrame == false)
         {
            return this.anim.advance(param1,true);
         }
         var _loc2_:IAnim = this.anim;
         if(_loc2_)
         {
            if(_loc2_.playing)
            {
               return _loc2_.advance(param1);
            }
            this.stop();
         }
         return 0;
      }
      
      private function setAnim(param1:IAnim) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         if(this._anim == param1)
         {
            return;
         }
         if(this._anim)
         {
            _loc4_ = this._accumulatedMovement;
            this._accumulatedMovement += this._anim.popAccumulatedMovement();
            _loc2_ = this._anim.playing;
            _loc3_ = this._anim.elapsedMs / this._anim.def.clip.durationMs;
            if(this._repeatLimit > this.anim.count)
            {
               this._repeatLimit -= this.anim.count;
            }
            if(this._timeLimitMs > this._anim.elapsedMs)
            {
               this._timeLimitMs -= this._anim.elapsedMs;
            }
            this._anim.stop();
         }
         this._anim = param1;
         if(this._anim)
         {
            if(!this._anim.def)
            {
               throw new ArgumentError("bad move, defless.");
            }
            this._anim.repeatLimit = this._repeatLimit;
            this._anim.timeLimitMs = this._timeLimitMs;
            this._anim.remainingDistance = this._remainingDistance;
            this._anim.reverse = this.reverse;
            this._anim.playbackSpeed = this.playbackSpeed;
            this._anim.singleFrameOffsetValid = this.singleFrameOffsetValid;
            this._anim.singleFrameOffset = this.singleFrameOffset;
            if(this.singleFrameOffsetValid)
            {
               this._anim.start(0);
               this.holding = true;
               return;
            }
            if(_loc2_)
            {
               _loc5_ = _loc3_ * this._anim.def.clip.durationMs;
               if(this.logger.isDebugEnabled)
               {
                  this.logger.debug("OrientedAnims.setAnim " + this._anim);
               }
               this._anim.start(_loc5_);
            }
         }
      }
      
      public function get anim() : IAnim
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         var _loc3_:IAnim = null;
         if(Boolean(this.def) && this.facingDirty)
         {
            this.facingDirty = false;
            _loc1_ = this.def.getAnim(this.facing);
            _loc2_ = Boolean(this._anim) && Boolean(this._anim.def) ? this._anim.def.name : null;
            if(_loc2_ != _loc1_)
            {
               _loc3_ = this.library.getAnim(this.layer,_loc1_,this.animEventCallback,this.orientedAnimsFinishedCallback);
               if(!_loc3_)
               {
                  if(Boolean(this.def) && Boolean(this.library))
                  {
                     this.logger.error("Failed to find next animation: layer=[" + this.layer + "] anim=[" + _loc1_ + "] for " + this);
                  }
               }
               this.setAnim(_loc3_);
            }
         }
         return this._anim;
      }
      
      public function orientedAnimsFinishedCallback(param1:IAnim) : void
      {
         if(!this.hold)
         {
            if(this.animFinishedCallback != null)
            {
               this.animFinishedCallback(param1);
            }
         }
         else if(!this.holding)
         {
            this.holding = true;
            if(this.orientedAnimsEventCallback != null)
            {
               this.orientedAnimsEventCallback(this,param1,"*hold");
            }
         }
      }
      
      public function animEventCallback(param1:IAnim, param2:String) : void
      {
         if(this.orientedAnimsEventCallback != null)
         {
            if(param2 == "@freeze")
            {
               this.frozen = true;
            }
            this.orientedAnimsEventCallback(this,param1,param2);
         }
      }
      
      public function get facing() : IAnimFacing
      {
         return this._facing;
      }
      
      public function set facing(param1:IAnimFacing) : void
      {
         if(this._facing != param1)
         {
            this._facing = param1;
            this.facingDirty = true;
         }
      }
      
      public function set repeatLimit(param1:int) : void
      {
         this._repeatLimit = param1;
         if(this._anim)
         {
            this._anim.repeatLimit = this._repeatLimit;
         }
      }
      
      public function set timeLimitMs(param1:int) : void
      {
         this._timeLimitMs = param1;
         if(this._anim)
         {
            this._anim.timeLimitMs = this._timeLimitMs;
         }
      }
      
      public function finishAsap() : void
      {
         if(this._anim)
         {
            this._anim.finishAsap();
            this._repeatLimit = this._anim.repeatLimit;
         }
      }
      
      public function get remainingDistance() : Number
      {
         return this._remainingDistance;
      }
      
      public function set remainingDistance(param1:Number) : void
      {
         this._remainingDistance = param1;
         if(this._anim)
         {
            this._anim.remainingDistance = this._remainingDistance;
         }
      }
      
      public function popAccumulatedMovement() : Number
      {
         var _loc1_:Number = this._accumulatedMovement;
         this._accumulatedMovement = 0;
         if(this._anim)
         {
            _loc1_ += this._anim.popAccumulatedMovement();
         }
         return _loc1_;
      }
   }
}
