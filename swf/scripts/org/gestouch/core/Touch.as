package org.gestouch.core
{
   import flash.geom.Point;
   
   public class Touch
   {
       
      
      public var id:uint;
      
      public var target:Object;
      
      public var sizeX:Number;
      
      public var sizeY:Number;
      
      public var pressure:Number;
      
      protected var _location:Point;
      
      protected var _previousLocation:Point;
      
      protected var _beginLocation:Point;
      
      protected var _time:uint;
      
      protected var _beginTime:uint;
      
      public function Touch(param1:uint = 0)
      {
         super();
         this.id = param1;
      }
      
      public function get location() : Point
      {
         return this._location.clone();
      }
      
      gestouch_internal function setLocation(param1:Number, param2:Number, param3:uint) : void
      {
         this._location = new Point(param1,param2);
         this._beginLocation = this._location.clone();
         this._previousLocation = this._location.clone();
         this._time = param3;
         this._beginTime = param3;
      }
      
      gestouch_internal function updateLocation(param1:Number, param2:Number, param3:uint) : Boolean
      {
         if(this._location)
         {
            if(this._location.x == param1 && this._location.y == param2)
            {
               return false;
            }
            this._previousLocation.x = this._location.x;
            this._previousLocation.y = this._location.y;
            this._location.x = param1;
            this._location.y = param2;
            this._time = param3;
         }
         else
         {
            this.gestouch_internal::setLocation(param1,param2,param3);
         }
         return true;
      }
      
      public function get previousLocation() : Point
      {
         return this._previousLocation.clone();
      }
      
      public function get beginLocation() : Point
      {
         return this._beginLocation.clone();
      }
      
      public function get locationOffset() : Point
      {
         return this._location.subtract(this._beginLocation);
      }
      
      public function get time() : uint
      {
         return this._time;
      }
      
      gestouch_internal function setTime(param1:uint) : void
      {
         this._time = param1;
      }
      
      public function get beginTime() : uint
      {
         return this._beginTime;
      }
      
      gestouch_internal function setBeginTime(param1:uint) : void
      {
         this._beginTime = param1;
      }
      
      public function clone() : Touch
      {
         var _loc1_:Touch = new Touch(this.id);
         _loc1_._location = this._location.clone();
         _loc1_._beginLocation = this._beginLocation.clone();
         _loc1_.target = this.target;
         _loc1_.sizeX = this.sizeX;
         _loc1_.sizeY = this.sizeY;
         _loc1_.pressure = this.pressure;
         _loc1_._time = this._time;
         _loc1_._beginTime = this._beginTime;
         return _loc1_;
      }
      
      public function toString() : String
      {
         return "Touch [id: " + this.id + ", location: " + this.location + ", ...]";
      }
   }
}
