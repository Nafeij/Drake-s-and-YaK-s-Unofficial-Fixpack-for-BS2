package engine.anim.view
{
   import engine.anim.def.AnimLoco;
   import engine.anim.def.IAnimFacing;
   import engine.anim.def.IAnimLibrary;
   import engine.anim.def.OrientedAnimMix;
   import engine.anim.def.OrientedAnims;
   import engine.anim.event.AnimControllerEvent;
   import engine.core.IUpdateable;
   import engine.core.logging.ILogger;
   import flash.events.EventDispatcher;
   
   public class AnimController extends EventDispatcher implements IUpdateable
   {
      
      public static var log_anim_events:Boolean = false;
       
      
      public var last:OrientedAnims;
      
      public var _current:OrientedAnims;
      
      public var queue:OrientedAnims;
      
      private var _library:IAnimLibrary;
      
      private var _ambientMix:OrientedAnimMix;
      
      private var _ambientMixName:String;
      
      public var _facing:IAnimFacing;
      
      private var _listener:IAnimControllerListener;
      
      private var _playAnimName:String;
      
      private var _playAnimLimit:int;
      
      private var _playAnimPlaybackSpeed:Number = 1;
      
      private var _playAnimTime:int;
      
      private var _playAnimHold:Boolean;
      
      private var _playAnimRestart:Boolean;
      
      private var _playAnimPriority:int;
      
      private var _playAnimReverse:Boolean;
      
      private var _elapsed:int;
      
      private var logger:ILogger;
      
      public var id:String;
      
      private var _accumulatedMovement:Number = 0;
      
      private var _remainingDistance:Number = 0;
      
      private var _ignoreFreezeFrame:Boolean = true;
      
      private var _layer:String;
      
      public var flips:Boolean;
      
      public var _color:uint = 4294967295;
      
      private var _useDefaultAmbientMix:Boolean;
      
      private var _playAnimSingleFrameOffsetValid:Boolean;
      
      private var _playAnimSingleFrameOffset:int;
      
      private var _inPlayAnim:Boolean;
      
      private var _locoId:String;
      
      private var _loco:AnimLoco;
      
      private var _locoStoppingAnimId:String;
      
      public var alpha:Number = 1;
      
      public function AnimController(param1:String, param2:IAnimLibrary, param3:IAnimControllerListener, param4:ILogger)
      {
         super();
         this.id = param1;
         this.logger = param4;
         this.library = param2;
         this._listener = param3;
      }
      
      public function get useDefaultAmbientMix() : Boolean
      {
         return this._useDefaultAmbientMix;
      }
      
      public function set useDefaultAmbientMix(param1:Boolean) : void
      {
         if(this._useDefaultAmbientMix == param1)
         {
            return;
         }
         this._useDefaultAmbientMix = param1;
         if(this._useDefaultAmbientMix)
         {
            this._checkDefaultAmbientMix();
         }
      }
      
      override public function toString() : String
      {
         return this.id;
      }
      
      public function set ambientMix(param1:String) : void
      {
         if(this._ambientMixName == param1)
         {
            return;
         }
         this._ambientMixName = param1;
         this.checkAmbientMixName();
      }
      
      public function setAmbientMixMasterState(param1:Boolean) : void
      {
         if(this._ambientMix != null)
         {
            this._ambientMix.masterState = param1;
         }
      }
      
      private function checkAmbientMixName() : void
      {
         if(this.library)
         {
            if(this._ambientMixName)
            {
               this._ambientMix = this.library.getAnimMix(this._layer,this._ambientMixName,this.orientedAnimsEventCallback);
               if(this._ambientMix)
               {
                  this._ambientMix.callback = this.ambientMixChangedHandler;
               }
               else
               {
                  this.logger.error("Invalid anim mix name: " + this._ambientMixName + " for " + this);
               }
            }
            else if(this._ambientMix)
            {
               this._ambientMix.callback = null;
               this._ambientMix.enabled = false;
               this._ambientMix = null;
            }
            this.checkAmbient();
         }
      }
      
      private function checkPlayAnimName() : void
      {
         var _loc1_:int = 0;
         if(this.library)
         {
            if(this._playAnimName)
            {
               _loc1_ = this._elapsed - this._playAnimTime;
               this.playAnim(this._playAnimName,this._playAnimLimit,this._playAnimHold,this._playAnimRestart,this._playAnimReverse,this._playAnimPlaybackSpeed,this._playAnimSingleFrameOffsetValid ? this._playAnimSingleFrameOffset : null,this._playAnimPriority);
               if(Boolean(this.current) && this.current.def.name == this._playAnimName)
               {
                  this.current.anim.advance(_loc1_);
               }
            }
         }
      }
      
      private function ambientMixChangedHandler(param1:OrientedAnimMix) : void
      {
         if(param1 == this._ambientMix)
         {
            if(this._inPlayAnim)
            {
               return;
            }
            if(this._locoId != null)
            {
               this.startLoco(this._locoId);
               return;
            }
            if(this._ambientMix.enabled)
            {
               this._startAmbient();
            }
         }
      }
      
      private function _startAmbient() : void
      {
         var _loc1_:OrientedAnims = null;
         if(this._ambientMix)
         {
            _loc1_ = this._ambientMix.current;
            this._ambientMix.enabled = true;
            if(Boolean(_loc1_) && Boolean(_loc1_.anim))
            {
               this.setCurrent(_loc1_);
            }
         }
      }
      
      private function checkAmbient() : void
      {
         if(!this._current)
         {
            if(this._locoId != null)
            {
               this.startLoco(this._locoId);
               return;
            }
            this._startAmbient();
         }
      }
      
      public function get isAmbient() : Boolean
      {
         if(!this._ambientMix && !this._current)
         {
            return true;
         }
         if(Boolean(this._ambientMix) && this._current == this._ambientMix._current)
         {
            return true;
         }
         return false;
      }
      
      private function setCurrent(param1:OrientedAnims) : void
      {
         if(this._current == param1)
         {
            return;
         }
         if(this._current)
         {
            if(this._locoStoppingAnimId && this._current.def && this._locoStoppingAnimId == this._current.def.name)
            {
               this._locoStoppingAnimId = null;
               if(this._listener)
               {
                  this._listener.animControllerHandler_loco(this,"ended");
               }
            }
            if(this._current.anim != null)
            {
               this._current.anim.stop();
            }
            this.last = this._current;
            this._accumulatedMovement += this._current.popAccumulatedMovement();
            this._remainingDistance = this._current.remainingDistance;
            if(this._current.def.flipsFacing)
            {
               this.flips = !this.flips;
            }
            this._current.cleanup();
         }
         this._current = param1;
         if(this._current)
         {
            if(!this._current.anim)
            {
               this._current = null;
               return;
            }
            this._current.facing = this._facing;
            this._current.remainingDistance = this._remainingDistance;
         }
         else
         {
            this._playAnimName = null;
            this._playAnimPriority = 0;
         }
         this.checkQueue();
         this.checkAmbient();
         if(this._listener)
         {
            this._listener.animControllerHandler_current(this);
         }
      }
      
      public function get anim() : IAnim
      {
         return !!this._current ? this._current.anim : null;
      }
      
      public function get currentPriority() : int
      {
         return !!this._current ? this._current.priority : 0;
      }
      
      public function get current() : OrientedAnims
      {
         return this._current;
      }
      
      public function get currentDefName() : String
      {
         return !!this._current ? this._current.def.name : null;
      }
      
      public function cleanup() : void
      {
         this._listener = null;
         if(this._ambientMix)
         {
            this._ambientMix.enabled = false;
            this._ambientMix = null;
         }
         this.setCurrent(null);
      }
      
      public function holdLastFrame(param1:String) : void
      {
         this.playAnim(param1,1,true,true,false,1,-1);
      }
      
      public function playAnim(param1:String, param2:int, param3:Boolean = false, param4:Boolean = false, param5:Boolean = false, param6:Number = 1, param7:* = null, param8:int = 0) : void
      {
         var _loc10_:IAnim = null;
         if(!param1)
         {
            throw new ArgumentError("AnimController null anim for " + this);
         }
         if(this._inPlayAnim)
         {
            this.logger.i("ANIM","AnimController.playAnim already in, do not re-enter");
            return;
         }
         this._playAnimSingleFrameOffsetValid = param7 != null;
         this._playAnimSingleFrameOffset = param7;
         this._playAnimName = param1;
         this._playAnimLimit = param2;
         this._playAnimTime = this._elapsed;
         this._playAnimHold = param3;
         this._playAnimReverse = param5;
         this._playAnimRestart = param4;
         this._playAnimPriority = param8;
         this._playAnimPlaybackSpeed = param6;
         if(!this.library)
         {
            return;
         }
         this.queue = null;
         if(Boolean(this._current) && this._current.def.name == param1)
         {
            if(!param4)
            {
               if(this._current.reverse != param5)
               {
                  this.current.playbackSpeed = param6;
                  return;
               }
            }
         }
         var _loc9_:OrientedAnims = this.library.getOrientedAnims(this._layer,param1,this.orientedAnimsEventCallback,this.animFinishedCallback);
         if(!_loc9_)
         {
            this.logger.i("ANIM","No such oriented animation " + param1 + " for " + this.id + " library=" + this.library.url);
            return;
         }
         this._inPlayAnim = true;
         _loc9_.repeatLimit = param2;
         _loc9_.hold = param3;
         _loc9_.ignoreFreezeFrame = this._ignoreFreezeFrame;
         _loc9_.reverse = param5;
         _loc9_.playbackSpeed = param6;
         _loc9_.singleFrameOffsetValid = this._playAnimSingleFrameOffsetValid;
         _loc9_.singleFrameOffset = this._playAnimSingleFrameOffset;
         _loc9_.priority = this._playAnimPriority;
         if(this._ambientMix)
         {
            this._ambientMix.enabled = false;
         }
         this.setCurrent(_loc9_);
         if(_loc9_ == this.current)
         {
            _loc10_ = _loc9_.anim;
            if(_loc10_)
            {
               _loc10_.start(0);
            }
         }
         this._inPlayAnim = false;
      }
      
      public function stop() : void
      {
         this._playAnimName = null;
         this._playAnimPriority = 0;
         if(!this._ambientMix || !this._ambientMix.enabled)
         {
            if(this.current)
            {
               this.setCurrent(null);
            }
         }
      }
      
      private function animFinishedCallback(param1:IAnim) : void
      {
         if(Boolean(this.current) && this.current.anim == param1)
         {
            dispatchEvent(new AnimControllerEvent(AnimControllerEvent.FINISHING,this,this.currentDefName,null));
            if(Boolean(this.current) && this.current.anim == param1)
            {
               this.setCurrent(null);
            }
         }
      }
      
      private function orientedAnimsEventCallback(param1:OrientedAnims, param2:IAnim, param3:String) : void
      {
         if(log_anim_events)
         {
            this.logger.i("ANIM","*** ANIM EVENT " + this.id + " \t" + param3 + " \t" + param1.def.name + " \t" + param2.def.name + " \t" + param2.def.clip.url);
         }
         if(this._listener)
         {
            this._listener.animControllerHandler_event(this,param1.def.name,param3);
         }
         dispatchEvent(new AnimControllerEvent(AnimControllerEvent.EVENT,this,param1.def.name,param3));
      }
      
      public function queueAnim(param1:String, param2:int, param3:Boolean) : void
      {
         var _loc4_:OrientedAnims = this.library.getOrientedAnims(this._layer,param1,this.orientedAnimsEventCallback,this.animFinishedCallback);
         this.queue = _loc4_;
         this.queue.repeatLimit = param2;
         this.queue.hold = param3;
         if(this._current)
         {
            this._current.finishAsap();
         }
         this.checkQueue();
      }
      
      private function checkQueue() : void
      {
         var _loc1_:OrientedAnims = null;
         if(Boolean(this.queue) && (!this.current || !this.current.anim.playing))
         {
            _loc1_ = this.queue;
            this.queue = null;
            if(this._ambientMix)
            {
               this._ambientMix.enabled = false;
            }
            this.setCurrent(_loc1_);
            if(_loc1_ == this.current)
            {
               this.current.anim.start(0);
            }
         }
      }
      
      public function update(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:OrientedAnims = null;
         if(this.id.indexOf("oddleif") > 0)
         {
            param1 = param1;
         }
         if(this.id.indexOf("nid") > 0)
         {
            param1 = param1;
         }
         while(param1 > 0)
         {
            _loc2_ = 0;
            this.checkQueue();
            if(!this._current)
            {
               break;
            }
            _loc3_ = this._current;
            _loc2_ = _loc3_.advance(param1);
            param1 -= _loc2_;
            this._elapsed += _loc2_;
            if(_loc2_ == 0 && this._current == _loc3_)
            {
               break;
            }
         }
         this._elapsed += param1;
         this.checkAmbient();
      }
      
      public function get facing() : IAnimFacing
      {
         return this._facing;
      }
      
      public function set facing(param1:IAnimFacing) : void
      {
         if(this._facing == param1)
         {
            return;
         }
         this._facing = param1;
         if(this._ambientMix)
         {
            this._ambientMix.facing = this._facing;
         }
         if(this._current)
         {
            this._current.facing = this._facing;
         }
         if(this.queue)
         {
            this.queue.facing = this._facing;
         }
      }
      
      public function get library() : IAnimLibrary
      {
         return this._library;
      }
      
      public function set library(param1:IAnimLibrary) : void
      {
         if(this._library == param1)
         {
            return;
         }
         this._library = param1;
         this._checkDefaultAmbientMix();
         this.checkPlayAnimName();
         this.checkAmbientMixName();
      }
      
      private function _checkDefaultAmbientMix() : void
      {
         if(!this._library)
         {
            return;
         }
         if(this._useDefaultAmbientMix)
         {
            if(!this._ambientMixName)
            {
               this.ambientMix = this._library.findDefaultAmbientMix();
            }
         }
         this._useDefaultAmbientMix = false;
      }
      
      public function popAccumulatedMovement() : Number
      {
         var _loc1_:Number = this._accumulatedMovement;
         this._accumulatedMovement = 0;
         if(this._current)
         {
            _loc1_ += this._current.popAccumulatedMovement();
         }
         return _loc1_;
      }
      
      public function get remainingDistance() : Number
      {
         return this._remainingDistance;
      }
      
      public function set remainingDistance(param1:Number) : void
      {
         this._remainingDistance = param1;
         if(this._current)
         {
            this._current.remainingDistance = this._remainingDistance;
         }
      }
      
      public function startLoco(param1:String) : void
      {
         if(!this.library)
         {
            return;
         }
         this._loco = this.library.getLoco(param1);
         if(!this._loco)
         {
            this.logger.error("AnimController.startLoco " + this + " NO LOCO " + param1);
            return;
         }
         this._locoId = !!this._loco.id ? this._loco.id : "";
         if(this._listener)
         {
            this._listener.animControllerHandler_loco(this,"starting");
         }
         if(this._loco.start)
         {
            this.playAnim(this._loco.start,1);
            this.queueAnim(this._loco.loop,0,true);
         }
         else
         {
            this.playAnim(this._loco.loop,0,true);
         }
      }
      
      public function stopLoco(param1:String) : void
      {
         var _loc2_:AnimLoco = this._loco;
         if(!_loc2_)
         {
            this.logger.error("AnimController.stopLoco " + this + " NO LOCO " + param1);
            return;
         }
         this._locoId = null;
         this._loco = null;
         if(this._listener != null)
         {
            this._listener.animControllerHandler_loco(this,"ending");
         }
         if(this._current != null && this._current.frozen == true)
         {
            this._current.frozen = false;
            this._current.repeatLimit = 1;
            return;
         }
         if(_loc2_.stop)
         {
            if(this.currentDefName != _loc2_.stop)
            {
               this._locoStoppingAnimId = _loc2_.stop;
               this.playAnim(_loc2_.stop,1);
            }
         }
         else if(_loc2_.loop)
         {
            if(this.currentDefName == _loc2_.loop)
            {
               if(this._listener != null)
               {
                  this._listener.animControllerHandler_loco(this,"ended");
               }
               this.stop();
            }
         }
      }
      
      public function get ignoreFreezeFrame() : Boolean
      {
         return this._ignoreFreezeFrame;
      }
      
      public function set ignoreFreezeFrame(param1:Boolean) : void
      {
         this._ignoreFreezeFrame = param1;
         if(this._current != null)
         {
            this._current.ignoreFreezeFrame = param1;
         }
      }
      
      public function get layer() : String
      {
         return this._layer;
      }
      
      public function set layer(param1:String) : void
      {
         this._layer = param1;
         if(this._ambientMix)
         {
            this._ambientMix.layer = param1;
         }
      }
      
      public function consumeFlip() : Boolean
      {
         if(this.flips)
         {
            this.flips = false;
            return true;
         }
         return false;
      }
      
      public function get color() : uint
      {
         return this._color;
      }
      
      public function set color(param1:uint) : void
      {
         if(this._color == param1)
         {
            return;
         }
         this._color = param1;
      }
      
      public function get loco() : AnimLoco
      {
         return this._loco;
      }
   }
}
