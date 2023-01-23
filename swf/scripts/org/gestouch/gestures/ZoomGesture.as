package org.gestouch.gestures
{
   import flash.geom.Point;
   import org.gestouch.core.GestureState;
   import org.gestouch.core.Touch;
   
   public class ZoomGesture extends AbstractContinuousGesture
   {
       
      
      public var slop:Number;
      
      public var lockAspectRatio:Boolean = true;
      
      protected var _touch1:Touch;
      
      protected var _touch2:Touch;
      
      protected var _transformVector:Point;
      
      protected var _initialDistance:Number;
      
      protected var _scaleX:Number = 1;
      
      protected var _scaleY:Number = 1;
      
      public function ZoomGesture(param1:Object = null)
      {
         this.slop = Gesture.DEFAULT_SLOP;
         super(param1);
      }
      
      public function get scaleX() : Number
      {
         return this._scaleX;
      }
      
      public function get scaleY() : Number
      {
         return this._scaleY;
      }
      
      override public function reflect() : Class
      {
         return ZoomGesture;
      }
      
      override protected function onTouchBegin(param1:Touch) : void
      {
         if(touchesCount > 2)
         {
            failOrIgnoreTouch(param1);
            return;
         }
         if(touchesCount == 1)
         {
            this._touch1 = param1;
         }
         else
         {
            this._touch2 = param1;
            this._transformVector = this._touch2.location.subtract(this._touch1.location);
            this._initialDistance = this._transformVector.length;
         }
      }
      
      override protected function onTouchMove(param1:Touch) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Point = null;
         if(touchesCount < 2)
         {
            return;
         }
         var _loc2_:Point = this._touch2.location.subtract(this._touch1.location);
         if(state == GestureState.POSSIBLE)
         {
            _loc3_ = _loc2_.length - this._initialDistance;
            _loc4_ = _loc3_ >= 0 ? _loc3_ : -_loc3_;
            if(_loc4_ < this.slop)
            {
               return;
            }
            if(this.slop > 0)
            {
               _loc5_ = _loc2_.clone();
               _loc5_.normalize(this._initialDistance + (_loc3_ >= 0 ? this.slop : -this.slop));
               this._transformVector = _loc5_;
            }
         }
         if(this.lockAspectRatio)
         {
            this._scaleX *= _loc2_.length / this._transformVector.length;
            this._scaleY = this._scaleX;
         }
         else
         {
            this._scaleX *= _loc2_.x / this._transformVector.x;
            this._scaleY *= _loc2_.y / this._transformVector.y;
         }
         this._transformVector.x = _loc2_.x;
         this._transformVector.y = _loc2_.y;
         updateLocation();
         if(state == GestureState.POSSIBLE)
         {
            setState(GestureState.BEGAN);
         }
         else
         {
            setState(GestureState.CHANGED);
         }
      }
      
      override protected function onTouchEnd(param1:Touch) : void
      {
         if(touchesCount == 0)
         {
            if(state == GestureState.BEGAN || state == GestureState.CHANGED)
            {
               setState(GestureState.ENDED);
            }
            else if(state == GestureState.POSSIBLE)
            {
               setState(GestureState.FAILED);
            }
         }
         else
         {
            if(param1 == this._touch1)
            {
               this._touch1 = this._touch2;
            }
            this._touch2 = null;
            if(state == GestureState.BEGAN || state == GestureState.CHANGED)
            {
               updateLocation();
               setState(GestureState.CHANGED);
            }
         }
      }
      
      override protected function resetNotificationProperties() : void
      {
         super.resetNotificationProperties();
         this._scaleX = this._scaleY = 1;
      }
   }
}
