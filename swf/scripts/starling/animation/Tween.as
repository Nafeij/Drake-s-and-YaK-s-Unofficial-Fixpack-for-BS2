package starling.animation
{
   import starling.core.starling_internal;
   import starling.events.Event;
   import starling.events.EventDispatcher;
   
   public class Tween extends EventDispatcher implements IAnimatable
   {
      
      private static const HINT_MARKER:String = "#";
      
      private static var sTweenPool:Vector.<Tween> = new Vector.<Tween>(0);
       
      
      private var mTarget:Object;
      
      private var mTransitionFunc:Function;
      
      private var mTransitionName:String;
      
      private var mProperties:Vector.<String>;
      
      private var mStartValues:Vector.<Number>;
      
      private var mEndValues:Vector.<Number>;
      
      private var mUpdateFuncs:Vector.<Function>;
      
      private var mOnStart:Function;
      
      private var mOnUpdate:Function;
      
      private var mOnRepeat:Function;
      
      private var mOnComplete:Function;
      
      private var mOnStartArgs:Array;
      
      private var mOnUpdateArgs:Array;
      
      private var mOnRepeatArgs:Array;
      
      private var mOnCompleteArgs:Array;
      
      private var mTotalTime:Number;
      
      private var mCurrentTime:Number;
      
      private var mProgress:Number;
      
      private var mDelay:Number;
      
      private var mRoundToInt:Boolean;
      
      private var mNextTween:Tween;
      
      private var mRepeatCount:int;
      
      private var mRepeatDelay:Number;
      
      private var mReverse:Boolean;
      
      private var mCurrentCycle:int;
      
      public function Tween(param1:Object, param2:Number, param3:Object = "linear")
      {
         super();
         this.reset(param1,param2,param3);
      }
      
      internal static function getPropertyHint(param1:String) : String
      {
         if(param1.indexOf("color") != -1 || param1.indexOf("Color") != -1)
         {
            return "rgb";
         }
         var _loc2_:int = param1.indexOf(HINT_MARKER);
         if(_loc2_ != -1)
         {
            return param1.substr(_loc2_ + 1);
         }
         return null;
      }
      
      internal static function getPropertyName(param1:String) : String
      {
         var _loc2_:int = param1.indexOf(HINT_MARKER);
         if(_loc2_ != -1)
         {
            return param1.substring(0,_loc2_);
         }
         return param1;
      }
      
      starling_internal internal static function fromPool(param1:Object, param2:Number, param3:Object = "linear") : Tween
      {
         if(sTweenPool.length)
         {
            return sTweenPool.pop().reset(param1,param2,param3);
         }
         return new Tween(param1,param2,param3);
      }
      
      starling_internal internal static function toPool(param1:Tween) : void
      {
         param1.mOnStart = param1.mOnUpdate = param1.mOnRepeat = param1.mOnComplete = null;
         param1.mOnStartArgs = param1.mOnUpdateArgs = param1.mOnRepeatArgs = param1.mOnCompleteArgs = null;
         param1.mTarget = null;
         param1.mTransitionFunc = null;
         param1.removeEventListeners();
         sTweenPool.push(param1);
      }
      
      public function reset(param1:Object, param2:Number, param3:Object = "linear") : Tween
      {
         this.mTarget = param1;
         this.mCurrentTime = 0;
         this.mTotalTime = Math.max(0.0001,param2);
         this.mProgress = 0;
         this.mDelay = this.mRepeatDelay = 0;
         this.mOnStart = this.mOnUpdate = this.mOnRepeat = this.mOnComplete = null;
         this.mOnStartArgs = this.mOnUpdateArgs = this.mOnRepeatArgs = this.mOnCompleteArgs = null;
         this.mRoundToInt = this.mReverse = false;
         this.mRepeatCount = 1;
         this.mCurrentCycle = -1;
         this.mNextTween = null;
         if(param3 is String)
         {
            this.transition = param3 as String;
         }
         else
         {
            if(!(param3 is Function))
            {
               throw new ArgumentError("Transition must be either a string or a function");
            }
            this.transitionFunc = param3 as Function;
         }
         if(this.mProperties)
         {
            this.mProperties.length = 0;
         }
         else
         {
            this.mProperties = new Vector.<String>(0);
         }
         if(this.mStartValues)
         {
            this.mStartValues.length = 0;
         }
         else
         {
            this.mStartValues = new Vector.<Number>(0);
         }
         if(this.mEndValues)
         {
            this.mEndValues.length = 0;
         }
         else
         {
            this.mEndValues = new Vector.<Number>(0);
         }
         if(this.mUpdateFuncs)
         {
            this.mUpdateFuncs.length = 0;
         }
         else
         {
            this.mUpdateFuncs = new Vector.<Function>(0);
         }
         return this;
      }
      
      public function animate(param1:String, param2:Number) : void
      {
         if(this.mTarget == null)
         {
            return;
         }
         var _loc3_:int = this.mProperties.length;
         var _loc4_:Function = this.getUpdateFuncFromProperty(param1);
         this.mProperties[_loc3_] = getPropertyName(param1);
         this.mStartValues[_loc3_] = Number.NaN;
         this.mEndValues[_loc3_] = param2;
         this.mUpdateFuncs[_loc3_] = _loc4_;
      }
      
      public function scaleTo(param1:Number) : void
      {
         this.animate("scaleX",param1);
         this.animate("scaleY",param1);
      }
      
      public function moveTo(param1:Number, param2:Number) : void
      {
         this.animate("x",param1);
         this.animate("y",param2);
      }
      
      public function fadeTo(param1:Number) : void
      {
         this.animate("alpha",param1);
      }
      
      public function rotateTo(param1:Number, param2:String = "rad") : void
      {
         this.animate("rotation#" + param2,param1);
      }
      
      public function advanceTime(param1:Number) : void
      {
         var _loc2_:int = 0;
         var _loc9_:Function = null;
         var _loc10_:Function = null;
         var _loc11_:Array = null;
         if(param1 == 0 || this.mRepeatCount == 1 && this.mCurrentTime == this.mTotalTime)
         {
            return;
         }
         var _loc3_:Number = this.mCurrentTime;
         var _loc4_:Number = this.mTotalTime - this.mCurrentTime;
         var _loc5_:Number = param1 > _loc4_ ? param1 - _loc4_ : 0;
         this.mCurrentTime += param1;
         if(this.mCurrentTime <= 0)
         {
            return;
         }
         if(this.mCurrentTime > this.mTotalTime)
         {
            this.mCurrentTime = this.mTotalTime;
         }
         if(this.mCurrentCycle < 0 && _loc3_ <= 0 && this.mCurrentTime > 0)
         {
            ++this.mCurrentCycle;
            if(this.mOnStart != null)
            {
               this.mOnStart.apply(this,this.mOnStartArgs);
            }
         }
         var _loc6_:Number = this.mCurrentTime / this.mTotalTime;
         var _loc7_:Boolean = this.mReverse && this.mCurrentCycle % 2 == 1;
         var _loc8_:int = this.mStartValues.length;
         this.mProgress = _loc7_ ? this.mTransitionFunc(1 - _loc6_) : this.mTransitionFunc(_loc6_);
         _loc2_ = 0;
         while(_loc2_ < _loc8_)
         {
            if(this.mStartValues[_loc2_] != this.mStartValues[_loc2_])
            {
               this.mStartValues[_loc2_] = this.mTarget[this.mProperties[_loc2_]] as Number;
            }
            _loc9_ = this.mUpdateFuncs[_loc2_] as Function;
            _loc9_(this.mProperties[_loc2_],this.mStartValues[_loc2_],this.mEndValues[_loc2_]);
            _loc2_++;
         }
         if(this.mOnUpdate != null)
         {
            this.mOnUpdate.apply(this,this.mOnUpdateArgs);
         }
         if(_loc3_ < this.mTotalTime && this.mCurrentTime >= this.mTotalTime)
         {
            if(this.mRepeatCount == 0 || this.mRepeatCount > 1)
            {
               this.mCurrentTime = -this.mRepeatDelay;
               ++this.mCurrentCycle;
               if(this.mRepeatCount > 1)
               {
                  --this.mRepeatCount;
               }
               if(this.mOnRepeat != null)
               {
                  this.mOnRepeat.apply(this,this.mOnRepeatArgs);
               }
            }
            else
            {
               _loc10_ = this.mOnComplete;
               _loc11_ = this.mOnCompleteArgs;
               dispatchEventWith(Event.REMOVE_FROM_JUGGLER);
               if(_loc10_ != null)
               {
                  _loc10_.apply(this,_loc11_);
               }
            }
         }
         if(_loc5_)
         {
            this.advanceTime(_loc5_);
         }
      }
      
      private function getUpdateFuncFromProperty(param1:String) : Function
      {
         var _loc2_:Function = null;
         var _loc3_:String = getPropertyHint(param1);
         switch(_loc3_)
         {
            case null:
               _loc2_ = this.updateStandard;
               break;
            case "rgb":
               _loc2_ = this.updateRgb;
               break;
            case "rad":
               _loc2_ = this.updateRad;
               break;
            case "deg":
               _loc2_ = this.updateDeg;
               break;
            default:
               _loc2_ = this.updateStandard;
         }
         return _loc2_;
      }
      
      private function updateStandard(param1:String, param2:Number, param3:Number) : void
      {
         var _loc4_:Number = param2 + this.mProgress * (param3 - param2);
         if(this.mRoundToInt)
         {
            _loc4_ = Math.round(_loc4_);
         }
         this.mTarget[param1] = _loc4_;
      }
      
      private function updateRgb(param1:String, param2:Number, param3:Number) : void
      {
         var _loc4_:uint = uint(param2);
         var _loc5_:uint = uint(param3);
         var _loc6_:uint = _loc4_ >> 24 & 255;
         var _loc7_:uint = _loc4_ >> 16 & 255;
         var _loc8_:uint = _loc4_ >> 8 & 255;
         var _loc9_:uint = _loc4_ & 255;
         var _loc10_:uint = _loc5_ >> 24 & 255;
         var _loc11_:uint = _loc5_ >> 16 & 255;
         var _loc12_:uint = _loc5_ >> 8 & 255;
         var _loc13_:uint = _loc5_ & 255;
         var _loc14_:uint = _loc6_ + (_loc10_ - _loc6_) * this.mProgress;
         var _loc15_:uint = _loc7_ + (_loc11_ - _loc7_) * this.mProgress;
         var _loc16_:uint = _loc8_ + (_loc12_ - _loc8_) * this.mProgress;
         var _loc17_:uint = _loc9_ + (_loc13_ - _loc9_) * this.mProgress;
         this.mTarget[param1] = _loc14_ << 24 | _loc15_ << 16 | _loc16_ << 8 | _loc17_;
      }
      
      private function updateRad(param1:String, param2:Number, param3:Number) : void
      {
         this.updateAngle(Math.PI,param1,param2,param3);
      }
      
      private function updateDeg(param1:String, param2:Number, param3:Number) : void
      {
         this.updateAngle(180,param1,param2,param3);
      }
      
      private function updateAngle(param1:Number, param2:String, param3:Number, param4:Number) : void
      {
         while(Math.abs(param4 - param3) > param1)
         {
            if(param3 < param4)
            {
               param4 -= 2 * param1;
            }
            else
            {
               param4 += 2 * param1;
            }
         }
         this.updateStandard(param2,param3,param4);
      }
      
      public function getEndValue(param1:String) : Number
      {
         var _loc2_:int = this.mProperties.indexOf(param1);
         if(_loc2_ == -1)
         {
            throw new ArgumentError("The property \'" + param1 + "\' is not animated");
         }
         return this.mEndValues[_loc2_] as Number;
      }
      
      public function get isComplete() : Boolean
      {
         return this.mCurrentTime >= this.mTotalTime && this.mRepeatCount == 1;
      }
      
      public function get target() : Object
      {
         return this.mTarget;
      }
      
      public function get transition() : String
      {
         return this.mTransitionName;
      }
      
      public function set transition(param1:String) : void
      {
         this.mTransitionName = param1;
         this.mTransitionFunc = Transitions.getTransition(param1);
         if(this.mTransitionFunc == null)
         {
            throw new ArgumentError("Invalid transiton: " + param1);
         }
      }
      
      public function get transitionFunc() : Function
      {
         return this.mTransitionFunc;
      }
      
      public function set transitionFunc(param1:Function) : void
      {
         this.mTransitionName = "custom";
         this.mTransitionFunc = param1;
      }
      
      public function get totalTime() : Number
      {
         return this.mTotalTime;
      }
      
      public function get currentTime() : Number
      {
         return this.mCurrentTime;
      }
      
      public function get progress() : Number
      {
         return this.mProgress;
      }
      
      public function get delay() : Number
      {
         return this.mDelay;
      }
      
      public function set delay(param1:Number) : void
      {
         this.mCurrentTime = this.mCurrentTime + this.mDelay - param1;
         this.mDelay = param1;
      }
      
      public function get repeatCount() : int
      {
         return this.mRepeatCount;
      }
      
      public function set repeatCount(param1:int) : void
      {
         this.mRepeatCount = param1;
      }
      
      public function get repeatDelay() : Number
      {
         return this.mRepeatDelay;
      }
      
      public function set repeatDelay(param1:Number) : void
      {
         this.mRepeatDelay = param1;
      }
      
      public function get reverse() : Boolean
      {
         return this.mReverse;
      }
      
      public function set reverse(param1:Boolean) : void
      {
         this.mReverse = param1;
      }
      
      public function get roundToInt() : Boolean
      {
         return this.mRoundToInt;
      }
      
      public function set roundToInt(param1:Boolean) : void
      {
         this.mRoundToInt = param1;
      }
      
      public function get onStart() : Function
      {
         return this.mOnStart;
      }
      
      public function set onStart(param1:Function) : void
      {
         this.mOnStart = param1;
      }
      
      public function get onUpdate() : Function
      {
         return this.mOnUpdate;
      }
      
      public function set onUpdate(param1:Function) : void
      {
         this.mOnUpdate = param1;
      }
      
      public function get onRepeat() : Function
      {
         return this.mOnRepeat;
      }
      
      public function set onRepeat(param1:Function) : void
      {
         this.mOnRepeat = param1;
      }
      
      public function get onComplete() : Function
      {
         return this.mOnComplete;
      }
      
      public function set onComplete(param1:Function) : void
      {
         this.mOnComplete = param1;
      }
      
      public function get onStartArgs() : Array
      {
         return this.mOnStartArgs;
      }
      
      public function set onStartArgs(param1:Array) : void
      {
         this.mOnStartArgs = param1;
      }
      
      public function get onUpdateArgs() : Array
      {
         return this.mOnUpdateArgs;
      }
      
      public function set onUpdateArgs(param1:Array) : void
      {
         this.mOnUpdateArgs = param1;
      }
      
      public function get onRepeatArgs() : Array
      {
         return this.mOnRepeatArgs;
      }
      
      public function set onRepeatArgs(param1:Array) : void
      {
         this.mOnRepeatArgs = param1;
      }
      
      public function get onCompleteArgs() : Array
      {
         return this.mOnCompleteArgs;
      }
      
      public function set onCompleteArgs(param1:Array) : void
      {
         this.mOnCompleteArgs = param1;
      }
      
      public function get nextTween() : Tween
      {
         return this.mNextTween;
      }
      
      public function set nextTween(param1:Tween) : void
      {
         this.mNextTween = param1;
      }
   }
}
