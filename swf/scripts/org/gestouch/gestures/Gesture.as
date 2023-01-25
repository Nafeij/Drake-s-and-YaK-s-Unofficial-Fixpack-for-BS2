package org.gestouch.gestures
{
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.system.Capabilities;
   import flash.utils.Dictionary;
   import org.gestouch.core.Gestouch;
   import org.gestouch.core.GestureState;
   import org.gestouch.core.GesturesManager;
   import org.gestouch.core.IGestureTargetAdapter;
   import org.gestouch.core.Touch;
   import org.gestouch.core.gestouch_internal;
   import org.gestouch.events.GestureEvent;
   
   [Event(name="gestureFailed",type="org.gestouch.events.GestureEvent")]
   [Event(name="gesturePossible",type="org.gestouch.events.GestureEvent")]
   [Event(name="gestureStateChange",type="org.gestouch.events.GestureEvent")]
   public class Gesture extends EventDispatcher
   {
      
      public static var DEFAULT_SLOP:uint = Math.round(20 / 252 * Capabilities.screenDPI);
       
      
      public var gestureShouldReceiveTouchCallback:Function;
      
      public var gestureShouldBeginCallback:Function;
      
      public var gesturesShouldRecognizeSimultaneouslyCallback:Function;
      
      protected const _gesturesManager:GesturesManager = Gestouch.gesturesManager;
      
      protected var _touchesMap:Object;
      
      protected var _centralPoint:Point;
      
      protected var _gesturesToFail:Dictionary;
      
      protected var _pendingRecognizedState:GestureState;
      
      protected var _targetAdapter:IGestureTargetAdapter;
      
      protected var _enabled:Boolean = true;
      
      protected var _state:GestureState;
      
      protected var _idle:Boolean = true;
      
      protected var _touchesCount:uint = 0;
      
      public var _location:Point;
      
      public function Gesture(param1:Object = null)
      {
         this._touchesMap = {};
         this._centralPoint = new Point();
         this._gesturesToFail = new Dictionary(true);
         this._state = GestureState.POSSIBLE;
         this._location = new Point();
         super();
         this.preinit();
         this.target = param1;
      }
      
      gestouch_internal function get targetAdapter() : IGestureTargetAdapter
      {
         return this._targetAdapter;
      }
      
      protected function get targetAdapter() : IGestureTargetAdapter
      {
         return this._targetAdapter;
      }
      
      public function get target() : Object
      {
         return !!this._targetAdapter ? this._targetAdapter.target : null;
      }
      
      public function set target(param1:Object) : void
      {
         var _loc2_:Object = this.target;
         if(_loc2_ == param1)
         {
            return;
         }
         this.uninstallTarget(_loc2_);
         this._targetAdapter = !!param1 ? Gestouch.gestouch_internal::createGestureTargetAdapter(param1) : null;
         this.installTarget(param1);
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         if(this._enabled == param1)
         {
            return;
         }
         this._enabled = param1;
         if(!this._enabled)
         {
            if(this.state == GestureState.POSSIBLE)
            {
               this.setState(GestureState.FAILED);
            }
            else if(this.state == GestureState.BEGAN || this.state == GestureState.CHANGED)
            {
               this.setState(GestureState.CANCELLED);
            }
         }
      }
      
      public function get state() : GestureState
      {
         return this._state;
      }
      
      gestouch_internal function get idle() : Boolean
      {
         return this._idle;
      }
      
      public function get touchesCount() : uint
      {
         return this._touchesCount;
      }
      
      public function get location() : Point
      {
         return this._location.clone();
      }
      
      public function reflect() : Class
      {
         throw Error("reflect() is abstract method and must be overridden.");
      }
      
      public function isTrackingTouch(param1:uint) : Boolean
      {
         return this._touchesMap[param1] != undefined;
      }
      
      public function reset() : void
      {
         var _loc2_:* = undefined;
         var _loc3_:Gesture = null;
         if(this.gestouch_internal::idle)
         {
            return;
         }
         var _loc1_:GestureState = this.state;
         this._location.x = 0;
         this._location.y = 0;
         this._touchesMap = {};
         this._touchesCount = 0;
         this._idle = true;
         for(_loc2_ in this._gesturesToFail)
         {
            _loc3_ = _loc2_ as Gesture;
            _loc3_.removeEventListener(GestureEvent.GESTURE_STATE_CHANGE,this.gestureToFail_stateChangeHandler);
         }
         this._pendingRecognizedState = null;
         if(_loc1_ == GestureState.POSSIBLE)
         {
            this.setState(GestureState.FAILED);
         }
         else if(_loc1_ == GestureState.BEGAN || _loc1_ == GestureState.CHANGED)
         {
            this.setState(GestureState.CANCELLED);
         }
         else
         {
            this.setState(GestureState.POSSIBLE);
         }
      }
      
      public function dispose() : void
      {
         this.reset();
         this.target = null;
         this.gestureShouldReceiveTouchCallback = null;
         this.gestureShouldBeginCallback = null;
         this.gesturesShouldRecognizeSimultaneouslyCallback = null;
         this._gesturesToFail = null;
      }
      
      gestouch_internal function canBePreventedByGesture(param1:Gesture) : Boolean
      {
         return true;
      }
      
      gestouch_internal function canPreventGesture(param1:Gesture) : Boolean
      {
         return true;
      }
      
      public function requireGestureToFail(param1:Gesture) : void
      {
         if(!param1)
         {
            throw new ArgumentError();
         }
         this._gesturesToFail[param1] = true;
      }
      
      protected function preinit() : void
      {
      }
      
      protected function installTarget(param1:Object) : void
      {
         if(param1)
         {
            this._gesturesManager.gestouch_internal::addGesture(this);
         }
      }
      
      protected function uninstallTarget(param1:Object) : void
      {
         if(param1)
         {
            this._gesturesManager.gestouch_internal::removeGesture(this);
         }
      }
      
      protected function ignoreTouch(param1:Touch) : void
      {
         if(param1.id in this._touchesMap)
         {
            delete this._touchesMap[param1.id];
            --this._touchesCount;
         }
      }
      
      protected function failOrIgnoreTouch(param1:Touch) : void
      {
         if(this.state == GestureState.POSSIBLE)
         {
            this.setState(GestureState.FAILED);
         }
         else
         {
            this.ignoreTouch(param1);
         }
      }
      
      protected function onTouchBegin(param1:Touch) : void
      {
      }
      
      protected function onTouchMove(param1:Touch) : void
      {
      }
      
      protected function onTouchEnd(param1:Touch) : void
      {
      }
      
      protected function onTouchCancel(param1:Touch) : void
      {
      }
      
      protected function setState(param1:GestureState) : Boolean
      {
         var _loc3_:Gesture = null;
         var _loc4_:* = undefined;
         if(this._state == param1 && this._state == GestureState.CHANGED)
         {
            if(hasEventListener(GestureEvent.GESTURE_STATE_CHANGE))
            {
               dispatchEvent(new GestureEvent(GestureEvent.GESTURE_STATE_CHANGE,this._state,this._state));
            }
            if(hasEventListener(GestureEvent.GESTURE_CHANGED))
            {
               dispatchEvent(new GestureEvent(GestureEvent.GESTURE_CHANGED,this._state,this._state));
            }
            this.resetNotificationProperties();
            return true;
         }
         if(!this._state.gestouch_internal::canTransitionTo(param1))
         {
            throw new IllegalOperationError("You cannot change from state " + this._state + " to state " + param1 + ".");
         }
         if(param1 != GestureState.POSSIBLE)
         {
            this._idle = false;
         }
         if(param1 == GestureState.BEGAN || param1 == GestureState.RECOGNIZED)
         {
            for(_loc4_ in this._gesturesToFail)
            {
               _loc3_ = _loc4_ as Gesture;
               if(!_loc3_.gestouch_internal::idle && _loc3_.state != GestureState.POSSIBLE && _loc3_.state != GestureState.FAILED)
               {
                  this.setState(GestureState.FAILED);
                  return false;
               }
            }
            for(_loc4_ in this._gesturesToFail)
            {
               _loc3_ = _loc4_ as Gesture;
               if(_loc3_.state == GestureState.POSSIBLE)
               {
                  this._pendingRecognizedState = param1;
                  for(_loc4_ in this._gesturesToFail)
                  {
                     _loc3_ = _loc4_ as Gesture;
                     _loc3_.addEventListener(GestureEvent.GESTURE_STATE_CHANGE,this.gestureToFail_stateChangeHandler,false,0,true);
                  }
                  return false;
               }
            }
            if(this.gestureShouldBeginCallback != null && !this.gestureShouldBeginCallback(this))
            {
               this.setState(GestureState.FAILED);
               return false;
            }
         }
         var _loc2_:GestureState = this._state;
         this._state = param1;
         if(this._state.gestouch_internal::isEndState)
         {
            this._gesturesManager.gestouch_internal::scheduleGestureStateReset(this);
         }
         if(hasEventListener(GestureEvent.GESTURE_STATE_CHANGE))
         {
            dispatchEvent(new GestureEvent(GestureEvent.GESTURE_STATE_CHANGE,this._state,_loc2_));
         }
         if(hasEventListener(this._state.gestouch_internal::toEventType()))
         {
            dispatchEvent(new GestureEvent(this._state.gestouch_internal::toEventType(),this._state,_loc2_));
         }
         this.resetNotificationProperties();
         if(this._state == GestureState.BEGAN || this._state == GestureState.RECOGNIZED)
         {
            this._gesturesManager.gestouch_internal::onGestureRecognized(this);
         }
         return true;
      }
      
      gestouch_internal function setState_internal(param1:GestureState) : void
      {
         this.setState(param1);
      }
      
      protected function updateCentralPoint() : void
      {
         var _loc1_:Point = null;
         var _loc4_:String = null;
         var _loc2_:Number = 0;
         var _loc3_:Number = 0;
         for(_loc4_ in this._touchesMap)
         {
            _loc1_ = (this._touchesMap[int(_loc4_)] as Touch).location;
            _loc2_ += _loc1_.x;
            _loc3_ += _loc1_.y;
         }
         this._centralPoint.x = _loc2_ / this._touchesCount;
         this._centralPoint.y = _loc3_ / this._touchesCount;
      }
      
      protected function updateLocation() : void
      {
         this.updateCentralPoint();
         this._location.x = this._centralPoint.x;
         this._location.y = this._centralPoint.y;
      }
      
      protected function resetNotificationProperties() : void
      {
      }
      
      gestouch_internal function touchBeginHandler(param1:Touch) : void
      {
         this._touchesMap[param1.id] = param1;
         ++this._touchesCount;
         this.onTouchBegin(param1);
         if(this._touchesCount == 1 && this.state == GestureState.POSSIBLE)
         {
            this._idle = false;
         }
      }
      
      gestouch_internal function touchMoveHandler(param1:Touch) : void
      {
         this._touchesMap[param1.id] = param1;
         this.onTouchMove(param1);
      }
      
      gestouch_internal function touchEndHandler(param1:Touch) : void
      {
         delete this._touchesMap[param1.id];
         --this._touchesCount;
         this.onTouchEnd(param1);
      }
      
      gestouch_internal function touchCancelHandler(param1:Touch) : void
      {
         delete this._touchesMap[param1.id];
         --this._touchesCount;
         this.onTouchCancel(param1);
         if(!this.state.gestouch_internal::isEndState)
         {
            if(this.state == GestureState.BEGAN || this.state == GestureState.CHANGED)
            {
               this.setState(GestureState.CANCELLED);
            }
            else
            {
               this.setState(GestureState.FAILED);
            }
         }
      }
      
      protected function gestureToFail_stateChangeHandler(param1:GestureEvent) : void
      {
         var _loc2_:* = undefined;
         var _loc3_:Gesture = null;
         if(!this._pendingRecognizedState || this.state != GestureState.POSSIBLE)
         {
            return;
         }
         if(param1.newState == GestureState.FAILED)
         {
            for(_loc2_ in this._gesturesToFail)
            {
               _loc3_ = _loc2_ as Gesture;
               if(_loc3_.state == GestureState.POSSIBLE)
               {
                  return;
               }
            }
            this.setState(this._pendingRecognizedState);
         }
         else if(param1.newState != GestureState.POSSIBLE)
         {
            this.setState(GestureState.FAILED);
         }
      }
   }
}
