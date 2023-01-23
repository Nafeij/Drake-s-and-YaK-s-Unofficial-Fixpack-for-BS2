package com.dncompute.graphics
{
   import com.dncompute.geom.GeomUtil;
   import flash.display.Graphics;
   import flash.geom.Point;
   
   public class GraphicsUtil
   {
       
      
      public function GraphicsUtil()
      {
         super();
      }
      
      public static function drawArrow(param1:Graphics, param2:Point, param3:Point, param4:Object = null) : void
      {
         var _loc5_:ArrowStyle = null;
         if(param2.equals(param3))
         {
            return;
         }
         if(param4 == null)
         {
            _loc5_ = new ArrowStyle();
         }
         else if(param4 is ArrowStyle)
         {
            _loc5_ = param4 as ArrowStyle;
         }
         else
         {
            _loc5_ = new ArrowStyle(param4);
         }
         var _loc6_:Point = param3.subtract(param2);
         var _loc7_:Number = _loc5_.headWidth != -1 ? _loc5_.headWidth / 2 : _loc5_.headLength / 2;
         var _loc8_:Point = new Point(_loc6_.y,-_loc6_.x);
         _loc8_.normalize(_loc5_.shaftThickness / 2);
         var _loc9_:Point = param2.add(_loc8_);
         var _loc10_:Point = param2.subtract(_loc8_);
         var _loc11_:Point = param3.add(_loc8_);
         var _loc12_:Point = param3.subtract(_loc8_);
         var _loc13_:Point = _loc6_.clone();
         _loc13_.normalize(_loc13_.length - _loc5_.headLength);
         _loc13_ = _loc13_.add(param2);
         var _loc14_:Point = _loc8_.clone();
         _loc14_.normalize(_loc7_);
         var _loc15_:Point = _loc13_.add(_loc14_);
         var _loc16_:Point = _loc13_.subtract(_loc14_);
         var _loc17_:Point = Point.interpolate(param3,_loc13_,_loc5_.shaftPosition);
         var _loc18_:Point = GeomUtil.getLineIntersection(_loc9_,_loc11_,_loc17_,_loc15_);
         var _loc19_:Point = GeomUtil.getLineIntersection(_loc10_,_loc12_,_loc17_,_loc16_);
         var _loc20_:Point = Point.interpolate(param3,_loc13_,_loc5_.edgeControlPosition);
         var _loc21_:Point = _loc8_.clone();
         _loc21_.normalize(_loc7_ * _loc5_.edgeControlSize);
         var _loc22_:Point = _loc20_.add(_loc21_);
         var _loc23_:Point = _loc20_.subtract(_loc21_);
         param1.moveTo(_loc9_.x,_loc9_.y);
         param1.lineTo(_loc18_.x,_loc18_.y);
         param1.lineTo(_loc15_.x,_loc15_.y);
         param1.curveTo(_loc22_.x,_loc22_.y,param3.x,param3.y);
         param1.curveTo(_loc23_.x,_loc23_.y,_loc16_.x,_loc16_.y);
         param1.lineTo(_loc19_.x,_loc19_.y);
         param1.lineTo(_loc10_.x,_loc10_.y);
         param1.lineTo(_loc9_.x,_loc9_.y);
      }
      
      public static function drawArrowHead(param1:Graphics, param2:Point, param3:Point, param4:Object = null) : void
      {
         var _loc5_:ArrowStyle = null;
         if(param4 == null)
         {
            _loc5_ = new ArrowStyle();
         }
         else if(param4 is ArrowStyle)
         {
            _loc5_ = param4 as ArrowStyle;
         }
         else
         {
            _loc5_ = new ArrowStyle(param4);
         }
         var _loc6_:Point = param3.subtract(param2);
         var _loc7_:Number = _loc5_.headWidth != -1 ? _loc5_.headWidth / 2 : _loc6_.length / 2;
         var _loc8_:Point = _loc6_.clone();
         _loc8_.normalize(_loc6_.length * _loc5_.shaftPosition);
         _loc8_ = param2.add(_loc8_);
         _loc6_ = new Point(_loc6_.y,-_loc6_.x);
         var _loc9_:Point = _loc6_.clone();
         _loc9_.normalize(_loc5_.shaftControlSize * _loc7_);
         var _loc10_:Point = Point.interpolate(param2,_loc8_,_loc5_.shaftControlPosition);
         var _loc11_:Point = _loc10_.add(_loc9_);
         var _loc12_:Point = _loc10_.subtract(_loc9_);
         _loc6_.normalize(_loc7_);
         var _loc13_:Point = param2.add(_loc6_);
         var _loc14_:Point = param2.subtract(_loc6_);
         var _loc15_:Point = Point.interpolate(param2,param3,_loc5_.edgeControlPosition);
         _loc6_.normalize(_loc7_ * _loc5_.edgeControlSize);
         var _loc16_:Point = _loc15_.add(_loc6_);
         var _loc17_:Point = _loc15_.subtract(_loc6_);
         param1.moveTo(_loc13_.x,_loc13_.y);
         param1.curveTo(_loc11_.x,_loc11_.y,_loc8_.x,_loc8_.y);
         param1.curveTo(_loc12_.x,_loc12_.y,_loc14_.x,_loc14_.y);
         param1.curveTo(_loc17_.x,_loc17_.y,param3.x,param3.y);
         param1.curveTo(_loc16_.x,_loc16_.y,_loc13_.x,_loc13_.y);
      }
   }
}
