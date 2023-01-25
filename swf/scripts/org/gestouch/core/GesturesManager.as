package org.gestouch.core
{
   import flash.display.DisplayObject;
   import flash.display.Shape;
   import flash.display.Stage;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   import org.gestouch.extensions.native.NativeTouchHitTester;
   import org.gestouch.gestures.Gesture;
   import org.gestouch.input.NativeInputAdapter;
   
   public class GesturesManager
   {
       
      
      protected const _frameTickerShape:Shape = new Shape();
      
      protected var _gesturesMap:Dictionary;
      
      protected var _gesturesForTouchMap:Dictionary;
      
      protected var _gesturesForTargetMap:Dictionary;
      
      protected var _dirtyGesturesCount:uint = 0;
      
      protected var _dirtyGesturesMap:Dictionary;
      
      protected var _stage:Stage;
      
      public function GesturesManager()
      {
         this._gesturesMap = new Dictionary(true);
         this._gesturesForTouchMap = new Dictionary();
         this._gesturesForTargetMap = new Dictionary(true);
         this._dirtyGesturesMap = new Dictionary(true);
         super();
      }
      
      protected function onStageAvailable(param1:Stage) : void
      {
         var _loc2_:* = undefined;
         this._stage = param1;
         Gestouch.inputAdapter = new NativeInputAdapter(param1);
         Gestouch.addTouchHitTester(new NativeTouchHitTester(param1));
      }
      
      protected function resetDirtyGestures() : void
      {
         var _loc1_:Object = null;
         for(_loc1_ in this._dirtyGesturesMap)
         {
            (_loc1_ as Gesture).reset();
         }
         this._dirtyGesturesCount = 0;
         this._dirtyGesturesMap = new Dictionary(true);
         this._frameTickerShape.removeEventListener(Event.ENTER_FRAME,this.enterFrameHandler);
      }
      
      gestouch_internal function addGesture(param1:Gesture) : void
      {
         var _loc4_:DisplayObject = null;
         if(!param1)
         {
            throw new ArgumentError("Argument \'gesture\' must be not null.");
         }
         var _loc2_:Object = param1.target;
         if(!_loc2_)
         {
            throw new IllegalOperationError("Gesture must have target.");
         }
         var _loc3_:Vector.<Gesture> = this._gesturesForTargetMap[_loc2_] as Vector.<Gesture>;
         if(_loc3_)
         {
            if(_loc3_.indexOf(param1) == -1)
            {
               _loc3_.push(param1);
            }
         }
         else
         {
            _loc3_ = this._gesturesForTargetMap[_loc2_] = new Vector.<Gesture>();
            _loc3_[0] = param1;
         }
         this._gesturesMap[param1] = true;
         if(!this._stage)
         {
            _loc4_ = _loc2_ as DisplayObject;
            if(_loc4_)
            {
               if(_loc4_.stage)
               {
                  this.onStageAvailable(_loc4_.stage);
               }
               else
               {
                  _loc4_.addEventListener(Event.ADDED_TO_STAGE,this.gestureTarget_addedToStageHandler,false,0,true);
               }
            }
         }
      }
      
      gestouch_internal function removeGesture(param1:Gesture) : void
      {
         var _loc3_:Vector.<Gesture> = null;
         if(!param1)
         {
            throw new ArgumentError("Argument \'gesture\' must be not null.");
         }
         var _loc2_:Object = param1.target;
         if(_loc2_)
         {
            _loc3_ = this._gesturesForTargetMap[_loc2_] as Vector.<Gesture>;
            if(_loc3_.length > 1)
            {
               _loc3_.splice(_loc3_.indexOf(param1),1);
            }
            else
            {
               delete this._gesturesForTargetMap[_loc2_];
               if(_loc2_ is IEventDispatcher)
               {
                  (_loc2_ as IEventDispatcher).removeEventListener(Event.ADDED_TO_STAGE,this.gestureTarget_addedToStageHandler);
               }
            }
         }
         delete this._gesturesMap[param1];
         param1.reset();
      }
      
      gestouch_internal function scheduleGestureStateReset(param1:Gesture) : void
      {
         if(!this._dirtyGesturesMap[param1])
         {
            this._dirtyGesturesMap[param1] = true;
            ++this._dirtyGesturesCount;
            this._frameTickerShape.addEventListener(Event.ENTER_FRAME,this.enterFrameHandler);
         }
      }
      
      gestouch_internal function onGestureRecognized(param1:Gesture) : void
      {
         var _loc3_:Object = null;
         var _loc4_:Gesture = null;
         var _loc5_:Object = null;
         var _loc2_:Object = param1.target;
         for(_loc3_ in this._gesturesMap)
         {
            _loc4_ = _loc3_ as Gesture;
            _loc5_ = _loc4_.target;
            if(_loc4_ != param1 && _loc2_ && _loc5_ && _loc4_.enabled && _loc4_.state == GestureState.POSSIBLE)
            {
               if(_loc5_ == _loc2_ || param1.gestouch_internal::targetAdapter.contains(_loc5_) || _loc4_.gestouch_internal::targetAdapter.contains(_loc2_))
               {
                  if(param1.gestouch_internal::canPreventGesture(_loc4_) && _loc4_.gestouch_internal::canBePreventedByGesture(param1) && (param1.gesturesShouldRecognizeSimultaneouslyCallback == null || !param1.gesturesShouldRecognizeSimultaneouslyCallback(param1,_loc4_)) && (_loc4_.gesturesShouldRecognizeSimultaneouslyCallback == null || !_loc4_.gesturesShouldRecognizeSimultaneouslyCallback(_loc4_,param1)))
                  {
                     _loc4_.gestouch_internal::setState_internal(GestureState.FAILED);
                  }
               }
            }
         }
      }
      
      gestouch_internal function onTouchBegin(param1:Touch) : void
      {
         var _loc2_:Gesture = null;
         var _loc3_:uint = 0;
         var _loc5_:Object = null;
         var _loc7_:Vector.<Object> = null;
         var _loc9_:Vector.<Gesture> = null;
         var _loc4_:Vector.<Gesture> = this._gesturesForTouchMap[param1] as Vector.<Gesture>;
         if(!_loc4_)
         {
            _loc4_ = new Vector.<Gesture>();
            this._gesturesForTouchMap[param1] = _loc4_;
         }
         else
         {
            _loc4_.length = 0;
         }
         _loc5_ = param1.target;
         var _loc6_:IDisplayListAdapter = Gestouch.gestouch_internal::getDisplayListAdapter(_loc5_);
         if(!_loc6_)
         {
            throw new Error("Display list adapter not found for target of type \'" + getQualifiedClassName(_loc5_) + "\'.");
         }
         _loc7_ = _loc6_.getHierarchy(_loc5_);
         var _loc8_:uint = _loc7_.length;
         if(_loc8_ == 0)
         {
            throw new Error("No hierarchy build for target \'" + _loc5_ + "\'. Something is wrong with that IDisplayListAdapter.");
         }
         if(Boolean(this._stage) && !(_loc7_[_loc8_ - 1] is Stage))
         {
            _loc7_[_loc8_] = this._stage;
         }
         for each(_loc5_ in _loc7_)
         {
            _loc9_ = this._gesturesForTargetMap[_loc5_] as Vector.<Gesture>;
            if(_loc9_)
            {
               _loc3_ = _loc9_.length;
               while(_loc3_-- > 0)
               {
                  _loc2_ = _loc9_[_loc3_];
                  if(_loc2_.enabled && (_loc2_.gestureShouldReceiveTouchCallback == null || _loc2_.gestureShouldReceiveTouchCallback(_loc2_,param1)))
                  {
                     _loc4_.unshift(_loc2_);
                  }
               }
            }
         }
         _loc3_ = _loc4_.length;
         while(_loc3_-- > 0)
         {
            _loc2_ = _loc4_[_loc3_];
            if(!this._dirtyGesturesMap[_loc2_])
            {
               _loc2_.gestouch_internal::touchBeginHandler(param1);
            }
            else
            {
               _loc4_.splice(_loc3_,1);
            }
         }
      }
      
      gestouch_internal function onTouchMove(param1:Touch) : void
      {
         var _loc3_:Gesture = null;
         var _loc2_:Vector.<Gesture> = this._gesturesForTouchMap[param1] as Vector.<Gesture>;
         var _loc4_:uint = _loc2_.length;
         while(_loc4_-- > 0)
         {
            _loc3_ = _loc2_[_loc4_];
            if(!this._dirtyGesturesMap[_loc3_] && _loc3_.isTrackingTouch(param1.id))
            {
               _loc3_.gestouch_internal::touchMoveHandler(param1);
            }
            else
            {
               _loc2_.splice(_loc4_,1);
            }
         }
      }
      
      gestouch_internal function onTouchEnd(param1:Touch) : void
      {
         var _loc3_:Gesture = null;
         var _loc2_:Vector.<Gesture> = this._gesturesForTouchMap[param1] as Vector.<Gesture>;
         var _loc4_:uint = _loc2_.length;
         while(_loc4_-- > 0)
         {
            _loc3_ = _loc2_[_loc4_];
            if(!this._dirtyGesturesMap[_loc3_] && _loc3_.isTrackingTouch(param1.id))
            {
               _loc3_.gestouch_internal::touchEndHandler(param1);
            }
         }
         _loc2_.length = 0;
         delete this._gesturesForTouchMap[param1];
      }
      
      gestouch_internal function onTouchCancel(param1:Touch) : void
      {
         var _loc3_:Gesture = null;
         var _loc2_:Vector.<Gesture> = this._gesturesForTouchMap[param1] as Vector.<Gesture>;
         var _loc4_:uint = _loc2_.length;
         while(_loc4_-- > 0)
         {
            _loc3_ = _loc2_[_loc4_];
            if(!this._dirtyGesturesMap[_loc3_] && _loc3_.isTrackingTouch(param1.id))
            {
               _loc3_.gestouch_internal::touchCancelHandler(param1);
            }
         }
         _loc2_.length = 0;
         delete this._gesturesForTouchMap[param1];
      }
      
      protected function gestureTarget_addedToStageHandler(param1:Event) : void
      {
         var _loc2_:DisplayObject = param1.target as DisplayObject;
         _loc2_.removeEventListener(Event.ADDED_TO_STAGE,this.gestureTarget_addedToStageHandler);
         if(!this._stage)
         {
            this.onStageAvailable(_loc2_.stage);
         }
      }
      
      private function enterFrameHandler(param1:Event) : void
      {
         this.resetDirtyGestures();
      }
   }
}
