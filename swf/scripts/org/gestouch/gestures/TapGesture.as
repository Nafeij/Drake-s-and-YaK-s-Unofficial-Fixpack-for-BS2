package org.gestouch.gestures
{
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   import org.gestouch.core.GestureState;
   import org.gestouch.core.Touch;
   import org.gestouch.core.gestouch_internal;
   
   public class TapGesture extends AbstractDiscreteGesture
   {
       
      
      public var numTouchesRequired:uint = 1;
      
      public var numTapsRequired:uint = 1;
      
      public var slop:Number;
      
      public var maxTapDelay:uint = 400;
      
      public var maxTapDuration:uint = 1500;
      
      public var maxTapDistance:Number;
      
      protected var _timer:Timer;
      
      protected var _numTouchesRequiredReached:Boolean;
      
      protected var _tapCounter:uint = 0;
      
      protected var _touchBeginLocations:Vector.<Point>;
      
      public function TapGesture(param1:Object = null)
      {
         this.slop = Gesture.DEFAULT_SLOP << 2;
         this.maxTapDistance = Gesture.DEFAULT_SLOP << 2;
         this._touchBeginLocations = new Vector.<Point>();
         super(param1);
      }
      
      override public function reflect() : Class
      {
         return TapGesture;
      }
      
      override public function reset() : void
      {
         this._numTouchesRequiredReached = false;
         this._tapCounter = 0;
         this._timer.reset();
         this._touchBeginLocations.length = 0;
         super.reset();
      }
      
      override gestouch_internal function canPreventGesture(param1:Gesture) : Boolean
      {
         if(param1 is TapGesture && (param1 as TapGesture).numTapsRequired > this.numTapsRequired)
         {
            return false;
         }
         return true;
      }
      
      override protected function preinit() : void
      {
         super.preinit();
         this._timer = new Timer(this.maxTapDelay,1);
         this._timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.timer_timerCompleteHandler);
      }
      
      override protected function onTouchBegin(param1:Touch) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:Point = null;
         if(touchesCount > this.numTouchesRequired)
         {
            failOrIgnoreTouch(param1);
            return;
         }
         if(touchesCount == 1)
         {
            this._timer.reset();
            this._timer.delay = this.maxTapDuration;
            this._timer.start();
         }
         if(this.numTapsRequired > 1)
         {
            if(this._tapCounter == 0)
            {
               this._touchBeginLocations.push(param1.location);
            }
            else
            {
               _loc2_ = false;
               for each(_loc3_ in this._touchBeginLocations)
               {
                  if(Point.distance(param1.location,_loc3_) <= this.maxTapDistance)
                  {
                     _loc2_ = true;
                     break;
                  }
               }
               if(!_loc2_)
               {
                  setState(GestureState.FAILED);
                  return;
               }
            }
         }
         if(touchesCount == this.numTouchesRequired)
         {
            this._numTouchesRequiredReached = true;
            updateLocation();
         }
      }
      
      override protected function onTouchMove(param1:Touch) : void
      {
         if(this.slop >= 0 && param1.locationOffset.length > this.slop)
         {
            setState(GestureState.FAILED);
         }
      }
      
      override protected function onTouchEnd(param1:Touch) : void
      {
         if(!this._numTouchesRequiredReached)
         {
            setState(GestureState.FAILED);
         }
         else if(touchesCount == 0)
         {
            this._numTouchesRequiredReached = false;
            ++this._tapCounter;
            this._timer.reset();
            if(this._tapCounter == this.numTapsRequired)
            {
               setState(GestureState.RECOGNIZED);
            }
            else
            {
               this._timer.delay = this.maxTapDelay;
               this._timer.start();
            }
         }
      }
      
      protected function timer_timerCompleteHandler(param1:TimerEvent) : void
      {
         if(state == GestureState.POSSIBLE)
         {
            setState(GestureState.FAILED);
         }
      }
   }
}
