package com.dncompute.geom
{
   import flash.geom.Point;
   
   public class GeomUtil
   {
       
      
      public function GeomUtil()
      {
         super();
      }
      
      public static function getLineSegmentIntersection(param1:Point, param2:Point, param3:Point, param4:Point) : Point
      {
         var _loc5_:Point = getLineIntersection(param1,param2,param3,param4);
         if(_loc5_ == null)
         {
            return null;
         }
         if(inRange(_loc5_,param1,param2) && inRange(_loc5_,param3,param4))
         {
            return _loc5_;
         }
         return null;
      }
      
      public static function getLineIntersection(param1:Point, param2:Point, param3:Point, param4:Point) : Point
      {
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc5_:Number = (param2.y - param1.y) / (param2.x - param1.x);
         var _loc6_:Number = (param4.y - param3.y) / (param4.x - param3.x);
         if(_loc5_ == _loc6_)
         {
            return null;
         }
         if(!isFinite(_loc5_))
         {
            _loc7_ = param1.x;
            _loc10_ = param3.y - _loc6_ * param3.x;
            _loc8_ = _loc6_ * _loc7_ + _loc10_;
         }
         else if(!isFinite(_loc6_))
         {
            _loc9_ = param1.y - _loc5_ * param1.x;
            _loc7_ = param3.x;
            _loc8_ = _loc5_ * _loc7_ + _loc9_;
         }
         else
         {
            _loc9_ = param1.y - _loc5_ * param1.x;
            _loc10_ = param3.y - _loc6_ * param3.x;
            _loc7_ = (_loc9_ - _loc10_) / (_loc6_ - _loc5_);
            _loc8_ = _loc5_ * _loc7_ + _loc9_;
         }
         return new Point(_loc7_,_loc8_);
      }
      
      private static function inRange(param1:Point, param2:Point, param3:Point) : Boolean
      {
         if(param2.x != param3.x)
         {
            return param1.x <= param2.x != param1.x < param3.x;
         }
         return param1.y <= param2.y != param1.y < param3.y;
      }
   }
}
