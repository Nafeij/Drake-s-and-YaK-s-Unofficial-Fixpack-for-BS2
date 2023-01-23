package org.gestouch.gestures
{
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import org.gestouch.core.GestureState;
   import org.gestouch.core.Touch;
   
   public class LongPressGesture extends AbstractContinuousGesture
   {
       
      
      public var numTouchesRequired:uint = 1;
      
      public var minPressDuration:uint = 500;
      
      public var slop:Number;
      
      protected var _timer:Timer;
      
      protected var _numTouchesRequiredReached:Boolean;
      
      public function LongPressGesture(param1:Object = null)
      {
         this.slop = Gesture.DEFAULT_SLOP;
         super(param1);
      }
      
      override public function reflect() : Class
      {
         return LongPressGesture;
      }
      
      override public function reset() : void
      {
         super.reset();
         this._numTouchesRequiredReached = false;
         this._timer.reset();
      }
      
      override protected function preinit() : void
      {
         super.preinit();
         this._timer = new Timer(this.minPressDuration,1);
         this._timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.timer_timerCompleteHandler);
      }
      
      override protected function onTouchBegin(param1:Touch) : void
      {
         if(touchesCount > this.numTouchesRequired)
         {
            failOrIgnoreTouch(param1);
            return;
         }
         if(touchesCount == this.numTouchesRequired)
         {
            this._numTouchesRequiredReached = true;
            this._timer.reset();
            this._timer.delay = this.minPressDuration || 1;
            this._timer.start();
         }
      }
      
      override protected function onTouchMove(param1:Touch) : void
      {
         if(state == GestureState.POSSIBLE && this.slop > 0 && param1.locationOffset.length > this.slop)
         {
            setState(GestureState.FAILED);
         }
         else if(state == GestureState.BEGAN || state == GestureState.CHANGED)
         {
            updateLocation();
            setState(GestureState.CHANGED);
         }
      }
      
      override protected function onTouchEnd(param1:Touch) : void
      {
         if(this._numTouchesRequiredReached)
         {
            if(state == GestureState.BEGAN || state == GestureState.CHANGED)
            {
               updateLocation();
               setState(GestureState.ENDED);
            }
            else
            {
               setState(GestureState.FAILED);
            }
         }
         else
         {
            setState(GestureState.FAILED);
         }
      }
      
      protected function timer_timerCompleteHandler(param1:TimerEvent = null) : void
      {
         if(state == GestureState.POSSIBLE)
         {
            updateLocation();
            setState(GestureState.BEGAN);
         }
      }
   }
}
