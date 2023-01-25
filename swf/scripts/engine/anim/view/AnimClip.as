package engine.anim.view
{
   import engine.anim.def.AnimClipChildDef;
   import engine.anim.def.AnimClipDef;
   import engine.anim.def.AnimEventDef;
   import engine.anim.def.AnimFrame;
   import engine.anim.def.AnimFrameChild;
   import engine.anim.def.IAnimEventDef;
   import engine.anim.def.IAnimFrameDef;
   import engine.core.logging.ILogger;
   import engine.core.util.ColorUtil;
   import engine.math.MathUtil;
   import flash.errors.IllegalOperationError;
   import flash.geom.Matrix;
   
   public class AnimClip
   {
      
      public static var last_gid:int = 0;
       
      
      private var _speedFactor:Number = 1;
      
      public var _def:AnimClipDef;
      
      private var _count:int;
      
      private var _elapsedMs:int;
      
      public var _currentFrameNumber:int;
      
      private var _startFrame:int = -1;
      
      private var _currentFrame:IAnimFrameDef;
      
      private var _playing:Boolean;
      
      private var _repeatLimit:int;
      
      private var _animEventCallback:Function;
      
      private var _finishedCallback:Function;
      
      public var logger:ILogger;
      
      private var _timeLimitMs:int;
      
      private var _sampled:Boolean;
      
      private var _children:Vector.<AnimClip>;
      
      public var childDef:AnimClipChildDef;
      
      public var x:Number = 0;
      
      public var y:Number = 0;
      
      public var rotation:Number = 0;
      
      public var _color:uint = 16777215;
      
      public var _compositeColor:uint = 16777215;
      
      public var scaleX:Number = 1;
      
      public var scaleY:Number = 1;
      
      public var blendMode:String;
      
      public var _alpha:Number = 1;
      
      public var _compositeAlpha:Number = 1;
      
      public var gid:int = 0;
      
      public var visible:Boolean = true;
      
      public var transformMatrix:Matrix;
      
      private var _lastLocomotiveFrame:int;
      
      private var _lastLocomotiveTile:Number = 0;
      
      private var _reverse:Boolean;
      
      public var accumulatedLocomotiveTiles:Number = 0;
      
      public var parent:AnimClip;
      
      public function AnimClip(param1:AnimClipDef, param2:Function, param3:Function, param4:ILogger)
      {
         var _loc6_:int = 0;
         var _loc7_:AnimClipChildDef = null;
         var _loc8_:AnimClip = null;
         super();
         if(!param1)
         {
            param1 = param1;
         }
         this._def = param1;
         this._animEventCallback = param2;
         this._finishedCallback = param3;
         this.logger = param4;
         this.gid = ++last_gid;
         if(Boolean(this._def) && !this._def._looping)
         {
            this.repeatLimit = 1;
         }
         var _loc5_:int = !!this._def ? this._def._aframes.numChildren : 0;
         if(_loc5_ > 0)
         {
            this._children = new Vector.<AnimClip>();
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               _loc7_ = this._def._aframes.getClipChild(_loc6_);
               if(!_loc7_.clip)
               {
                  param4.error("AnimClip [" + this._def._url + "] child is unresolved [" + _loc7_.url + "]");
               }
               else
               {
                  _loc8_ = new AnimClip(_loc7_.clip,null,null,param4);
                  _loc8_.childDef = _loc7_;
                  _loc8_.parent = this;
                  _loc8_._compositeAlpha = this._compositeAlpha * _loc8_._alpha;
                  _loc8_._compositeColor = ColorUtil.multiply(this._compositeColor,_loc8_._color);
                  this._children.push(_loc8_);
               }
               _loc6_++;
            }
         }
         this.updateChildFrames();
      }
      
      public function cleanup() : void
      {
         var _loc1_:AnimClip = null;
         this._def = null;
         this._animEventCallback = null;
         this._finishedCallback = null;
         this.logger = null;
         this._currentFrame = null;
         this.childDef = null;
         if(this._children)
         {
            if(this._children)
            {
               for each(_loc1_ in this._children)
               {
                  _loc1_.cleanup();
               }
               this._children = null;
            }
         }
      }
      
      public function toString() : String
      {
         return "AnimClip [id=" + (!!this._def ? this._def._id : "???") + ", count=" + this._count + "/" + this._repeatLimit + ", elapsed=" + this._elapsedMs + ", currentFrameNumber=" + this._currentFrameNumber + ", playing=" + this._playing + "]";
      }
      
      public function get elapsedMs() : int
      {
         return this._elapsedMs;
      }
      
      public function get remainingMs() : int
      {
         return this.duration - this._elapsedMs;
      }
      
      public function get count() : int
      {
         return this._count;
      }
      
      public function get def() : AnimClipDef
      {
         return this._def;
      }
      
      public function get frame() : int
      {
         return this._currentFrameNumber;
      }
      
      public function get startFrame() : int
      {
         return this._startFrame;
      }
      
      public function get playing() : Boolean
      {
         return this._playing;
      }
      
      public function start(param1:Number = 0) : void
      {
         var _loc2_:AnimClip = null;
         this._playing = true;
         if(this._def)
         {
            if(param1 < 0)
            {
               param1 = MathUtil.randomInt(0,this._def._numFrames - 1);
            }
            this._startFrame = Math.max(0,param1) % this._def._numFrames;
            this._currentFrameNumber = this._startFrame - 1;
            if(this._reverse)
            {
               this._elapsedMs = (this._def._numFrames - 1 - param1) * this._def._durationMs / this._def._numFrames;
            }
            else
            {
               this._elapsedMs = param1 * this._def._durationMs / this._def._numFrames;
            }
         }
         else
         {
            this._startFrame = 0;
            this._currentFrameNumber = -1;
            this._elapsedMs = 0;
         }
         this.setFrameNumber(param1);
         if(this._children)
         {
            for each(_loc2_ in this._children)
            {
               _loc2_.start(param1);
            }
         }
      }
      
      public function restart() : void
      {
         var _loc1_:AnimClip = null;
         this._playing = true;
         this._count = 0;
         this._currentFrameNumber = this._startFrame;
         this._elapsedMs = 0;
         if(this._children)
         {
            for each(_loc1_ in this._children)
            {
               _loc1_.restart();
            }
         }
      }
      
      public function stop() : void
      {
         var _loc1_:AnimClip = null;
         if(!this._def)
         {
            return;
         }
         this._playing = false;
         if(this._children)
         {
            for each(_loc1_ in this._children)
            {
               _loc1_.stop();
            }
         }
      }
      
      public function resume() : void
      {
         var _loc1_:AnimClip = null;
         this._playing = true;
         if(this._children)
         {
            for each(_loc1_ in this._children)
            {
               _loc1_.resume();
            }
         }
      }
      
      private function get interesting() : Boolean
      {
         return true;
      }
      
      public function setFrameNumber(param1:int) : Boolean
      {
         var _loc3_:AnimFrame = null;
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         var _loc6_:Vector.<IAnimEventDef> = null;
         var _loc7_:AnimEventDef = null;
         if(!this._def)
         {
            return false;
         }
         if(this._repeatLimit == 0 || this._repeatLimit > this._count)
         {
            param1 = Math.max(0,param1) % this._def._numFrames;
         }
         else
         {
            param1 = Math.min(Math.max(0,param1),this._def._numFrames - 1);
         }
         if(this._currentFrameNumber == param1)
         {
            return false;
         }
         if(this._def.locomotiveTilesTotal)
         {
            if(this._lastLocomotiveFrame != param1)
            {
               _loc3_ = this._def._aframes.frames[param1];
               _loc4_ = _loc3_.locomotiveTiles - this._lastLocomotiveTile;
               this.accumulatedLocomotiveTiles += _loc4_;
               this._lastLocomotiveFrame = param1;
               this._lastLocomotiveTile = _loc3_.locomotiveTiles;
            }
         }
         var _loc2_:int = this._currentFrameNumber;
         this._currentFrameNumber = param1;
         if(this._animEventCallback != null && Boolean(this._def._aframes))
         {
            _loc5_ = _loc2_ + 1;
            if(_loc2_ > this._currentFrameNumber)
            {
               while(_loc5_ <= this._def._numFrames)
               {
                  _loc6_ = this._def._aframes.getFrameEvents(_loc5_);
                  if(_loc6_)
                  {
                     for each(_loc7_ in _loc6_)
                     {
                        this._animEventCallback(this,_loc7_._id);
                     }
                  }
                  _loc5_++;
               }
               _loc5_ = 0;
            }
            while(_loc5_ <= this._currentFrameNumber)
            {
               _loc6_ = this._def._aframes.getFrameEvents(_loc5_);
               if(_loc6_)
               {
                  for each(_loc7_ in _loc6_)
                  {
                     this._animEventCallback(this,_loc7_._id);
                  }
               }
               _loc5_++;
            }
         }
         this.updateChildFrames();
         return true;
      }
      
      private function updateChildFrames() : void
      {
         var _loc3_:AnimClip = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:AnimFrameChild = null;
         if(!this._children || !this._def._aframes)
         {
            return;
         }
         var _loc1_:AnimFrame = this.def._aframes.getFrame(this.frame);
         var _loc2_:int = 0;
         while(_loc2_ < this._children.length)
         {
            _loc3_ = this._children[_loc2_];
            _loc4_ = this.frame + this.count * this._def._numFrames;
            _loc5_ = 0;
            _loc6_ = Math.max(0,_loc3_.childDef.parentStartFrame - 1);
            if(_loc3_.def.looping)
            {
               _loc5_ = (_loc3_._def._numFrames + _loc4_ - _loc6_) % _loc3_._def._numFrames;
            }
            else
            {
               _loc5_ = Math.max(0,Math.min(_loc3_._def.numFrames,this.frame - _loc6_));
            }
            _loc3_.setFrameNumber(_loc5_);
            _loc3_.visible = false;
            if(Boolean(_loc1_) && Boolean(_loc1_.children))
            {
               _loc7_ = _loc1_.children[_loc2_];
               if(_loc7_)
               {
                  _loc3_.color = _loc7_.color;
                  _loc3_.alpha = _loc7_.alpha;
                  _loc3_.blendMode = _loc7_.blendMode;
                  _loc3_.visible = _loc7_.visible;
                  if(_loc7_.transformMatrix)
                  {
                     _loc3_.transformMatrix = _loc7_.transformMatrix;
                  }
                  else
                  {
                     if(_loc7_.position)
                     {
                        _loc3_.x = _loc7_.position.x;
                        _loc3_.y = _loc7_.position.y;
                     }
                     else
                     {
                        _loc3_.x = _loc3_.y = 0;
                     }
                     _loc3_.rotation = _loc7_.rotation;
                     if(_loc7_.scale)
                     {
                        _loc3_.scaleX = _loc7_.scale.x;
                        _loc3_.scaleY = _loc7_.scale.y;
                     }
                     else
                     {
                        _loc3_.scaleX = _loc3_.scaleY = 1;
                     }
                  }
               }
            }
            else
            {
               _loc3_.color = 16777215;
               _loc3_.alpha = 1;
               _loc3_.blendMode = "normal";
               _loc3_.visible = false;
            }
            _loc2_++;
         }
      }
      
      public function set count(param1:int) : void
      {
         if(this._count != param1)
         {
            if(this.def.locomotiveTilesTotal)
            {
               this.accumulatedLocomotiveTiles += this.def.locomotiveTilesTotal - this._lastLocomotiveTile;
               if(param1 - this._count > 1)
               {
                  this.accumulatedLocomotiveTiles += this.def.locomotiveTilesTotal * (param1 - this._count - 1);
               }
               this._lastLocomotiveTile = 0;
               this._lastLocomotiveFrame = 0;
            }
            this._count = param1;
         }
      }
      
      public function advance(param1:int) : int
      {
         if(!this._def)
         {
            return param1;
         }
         if(!this._playing && this._def._numFrames > 0)
         {
            throw new IllegalOperationError("cannot advance a stopped anim");
         }
         if(this._speedFactor <= 0)
         {
            return 0;
         }
         if(this._def._numFrames > 0)
         {
            param1 = this.advanceFrames(param1);
         }
         else
         {
            param1 = this.advanceBitmap(param1);
         }
         this.checkFinished();
         return param1;
      }
      
      private function advanceFrames(param1:int) : int
      {
         var _loc2_:int = this._repeatLimit - this._count;
         var _loc3_:Number = this.duration;
         if(_loc3_ <= 0)
         {
            return 0;
         }
         var _loc4_:Number = 1 / _loc3_;
         if(_loc2_ > 0)
         {
            param1 = Math.min((_loc2_ - 1) * _loc3_ + (_loc3_ - this._elapsedMs),param1);
         }
         this._elapsedMs += param1;
         var _loc5_:int = this._elapsedMs / _loc3_;
         this.count += _loc5_;
         if(this.count < this.repeatLimit || this.repeatLimit == 0)
         {
            this._elapsedMs -= _loc5_ * _loc3_;
         }
         var _loc6_:int = this._elapsedMs * this._def._numFrames * _loc4_;
         _loc6_ = Math.min(this._def._numFrames - 1,_loc6_);
         var _loc7_:int = 0;
         if(this._reverse)
         {
            _loc7_ = (this._def._numFrames * 2 - 1 - _loc6_) % this._def.numFrames;
         }
         else
         {
            _loc7_ = _loc6_;
         }
         if(!this.setFrameNumber(_loc7_))
         {
            if(this._def._numFrames == 1)
            {
               if(_loc5_)
               {
                  this.updateChildFrames();
               }
            }
         }
         return param1;
      }
      
      private function advanceBitmap(param1:int) : int
      {
         if(this._timeLimitMs > 0)
         {
            param1 = Math.min(this._timeLimitMs - this._elapsedMs,param1);
         }
         this._elapsedMs += param1;
         return param1;
      }
      
      private function checkFinished() : void
      {
         if(this.repeatLimit > 0 && this.count >= this.repeatLimit)
         {
            this.finish();
            return;
         }
         if(this._timeLimitMs > 0 && this._elapsedMs >= this._timeLimitMs)
         {
            this.finish();
         }
      }
      
      private function finish() : void
      {
         this.stop();
         if(this._finishedCallback != null)
         {
            this._finishedCallback(this);
         }
      }
      
      public function get repeatLimit() : int
      {
         return this._repeatLimit;
      }
      
      public function set repeatLimit(param1:int) : void
      {
         this._repeatLimit = param1;
      }
      
      public function get timeLimitMs() : int
      {
         return this._timeLimitMs;
      }
      
      public function set timeLimitMs(param1:int) : void
      {
         this._timeLimitMs = param1;
      }
      
      private function get timeLimitedRepeatLimit() : int
      {
         var _loc1_:Number = NaN;
         if(this._timeLimitMs > 0)
         {
            _loc1_ = this.duration;
            if(_loc1_)
            {
               return Math.max(1,this._timeLimitMs / _loc1_);
            }
         }
         return 0;
      }
      
      public function get finishedCallback() : Function
      {
         return this._finishedCallback;
      }
      
      public function set finishedCallback(param1:Function) : void
      {
         this._finishedCallback = param1;
      }
      
      public function get speedFactor() : Number
      {
         return this._speedFactor;
      }
      
      public function get duration() : Number
      {
         if(this._speedFactor > 0)
         {
            return !!this.def ? this._def._durationMs / this._speedFactor : 0;
         }
         return 0;
      }
      
      public function set speedFactor(param1:Number) : void
      {
         if(this._speedFactor == param1)
         {
            return;
         }
         var _loc2_:Number = this.duration;
         var _loc3_:Number = 0;
         if(_loc2_ > 0)
         {
            _loc3_ = this._elapsedMs / _loc2_;
         }
         this._speedFactor = param1;
         var _loc4_:Number = this.duration;
         if(_loc4_ > 0)
         {
            this._elapsedMs = _loc3_ * _loc4_;
         }
      }
      
      public function get numChildren() : int
      {
         return !!this._children ? int(this._children.length) : 0;
      }
      
      public function getClipChild(param1:int) : AnimClip
      {
         return !!this._children ? this._children[param1] : null;
      }
      
      public function get alpha() : Number
      {
         return this._alpha;
      }
      
      public function get compositeApha() : Number
      {
         return this._compositeAlpha;
      }
      
      public function set alpha(param1:Number) : void
      {
         if(this._alpha == param1)
         {
            return;
         }
         this._alpha = param1;
         this.updateCompositeAlpha();
      }
      
      private function updateCompositeAlpha() : void
      {
         var _loc1_:AnimClip = null;
         this._compositeAlpha = !!this.parent ? this.parent._compositeAlpha * this._alpha : this._alpha;
         if(this._children)
         {
            for each(_loc1_ in this._children)
            {
               _loc1_._compositeAlpha = this._compositeAlpha * _loc1_._alpha;
            }
         }
      }
      
      public function get color() : uint
      {
         return this._color;
      }
      
      public function get compositeColor() : uint
      {
         return this._compositeColor;
      }
      
      public function set color(param1:uint) : void
      {
         if(this._color == param1)
         {
            return;
         }
         this._color = param1;
         this.updateCompositeColor();
      }
      
      private function updateCompositeColor() : void
      {
         var _loc1_:AnimClip = null;
         this._compositeColor = !!this.parent ? ColorUtil.multiply(this.parent._compositeColor,this._color) : this._color;
         if(this._children)
         {
            for each(_loc1_ in this._children)
            {
               _loc1_.updateCompositeColor();
            }
         }
      }
      
      public function set reverse(param1:Boolean) : void
      {
         this._reverse = param1;
      }
   }
}
