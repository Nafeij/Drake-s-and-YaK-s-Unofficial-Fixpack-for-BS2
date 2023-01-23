package as3isolib.geom
{
   import flash.geom.Point;
   
   public class Pt extends Point
   {
       
      
      public var z:Number = 0;
      
      public function Pt(param1:Number = 0, param2:Number = 0, param3:Number = 0)
      {
         super();
         this.x = param1;
         this.y = param2;
         this.z = param3;
      }
      
      public static function distance(param1:Pt, param2:Pt) : Number
      {
         var _loc3_:Number = param2.x - param1.x;
         var _loc4_:Number = param2.y - param1.y;
         var _loc5_:Number = param2.z - param1.z;
         return Math.sqrt(_loc3_ * _loc3_ + _loc4_ * _loc4_ + _loc5_ * _loc5_);
      }
      
      public static function theta(param1:Pt, param2:Pt) : Number
      {
         var _loc3_:Number = param2.x - param1.x;
         var _loc4_:Number = param2.y - param1.y;
         var _loc5_:Number = Math.atan(_loc4_ / _loc3_);
         if(_loc3_ < 0)
         {
            _loc5_ += Math.PI;
         }
         if(_loc3_ >= 0 && _loc4_ < 0)
         {
            _loc5_ += Math.PI * 2;
         }
         return _loc5_;
      }
      
      public static function angle(param1:Pt, param2:Pt) : Number
      {
         return theta(param1,param2) * 180 / Math.PI;
      }
      
      public static function polar(param1:Pt, param2:Number, param3:Number = 0) : Pt
      {
         var _loc4_:Number = param1.x + Math.cos(param3) * param2;
         var _loc5_:Number = param1.y + Math.sin(param3) * param2;
         var _loc6_:Number = param1.z;
         return new Pt(_loc4_,_loc5_,_loc6_);
      }
      
      public static function interpolate(param1:Pt, param2:Pt, param3:Number) : Pt
      {
         if(param3 <= 0)
         {
            return param1;
         }
         if(param3 >= 1)
         {
            return param2;
         }
         var _loc4_:Number = (param2.x - param1.x) * param3 + param1.x;
         var _loc5_:Number = (param2.y - param1.y) * param3 + param1.y;
         var _loc6_:Number = (param2.z - param1.z) * param3 + param1.z;
         return new Pt(_loc4_,_loc5_,_loc6_);
      }
      
      override public function get length() : Number
      {
         return Math.sqrt(x * x + y * y + this.z * this.z);
      }
      
      override public function clone() : Point
      {
         return new Pt(x,y,this.z);
      }
      
      override public function toString() : String
      {
         return "x:" + x + " y:" + y + " z:" + this.z;
      }
      
      public function set3(param1:Number, param2:Number, param3:Number) : void
      {
         this.x = param1;
         this.y = param2;
         this.z = param3;
      }
   }
}
