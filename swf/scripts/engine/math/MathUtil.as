package engine.math
{
   public class MathUtil
   {
      
      public static const PI_OVER_180:Number = Math.PI / 180;
      
      public static const PI_TIMES_2:Number = Math.PI * 2;
       
      
      public function MathUtil()
      {
         super();
      }
      
      public static function floatEquals(param1:Number, param2:Number, param3:Number = 0.00001) : Boolean
      {
         return Math.abs(param1 - param2) <= param3;
      }
      
      public static function clampValue(param1:Number, param2:Number, param3:Number) : Number
      {
         if(param1 < param2)
         {
            return param2;
         }
         if(param1 > param3)
         {
            return param3;
         }
         return param1;
      }
      
      public static function hash(param1:String) : uint
      {
         var _loc2_:uint = 5381;
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc2_ = (_loc2_ << 5) + _loc2_ + param1.charCodeAt(_loc3_);
            _loc3_++;
         }
         return _loc2_;
      }
      
      public static function lerp(param1:Number, param2:Number, param3:Number) : Number
      {
         return param1 + (param2 - param1) * param3;
      }
      
      public static function unlerp(param1:Number, param2:Number, param3:Number) : Number
      {
         if(param3 <= param1)
         {
            return 0;
         }
         if(param3 >= param2)
         {
            return 1;
         }
         return (param3 - param1) / (param2 - param1);
      }
      
      public static function mungeRadians(param1:Number) : Number
      {
         var _loc2_:int = 0;
         if(param1 > Math.PI)
         {
            _loc2_ = int((param1 + Math.PI) / (Math.PI * 2));
            return param1 - _loc2_ * (Math.PI * 2);
         }
         if(param1 < -Math.PI)
         {
            _loc2_ = int(-(param1 - Math.PI) / (Math.PI * 2));
            return param1 + _loc2_ * (Math.PI * 2);
         }
         return param1;
      }
      
      public static function mungeDegrees(param1:Number) : Number
      {
         var _loc2_:int = 0;
         if(param1 > 180)
         {
            _loc2_ = int((param1 + 180) / 360);
            return param1 - _loc2_ * 360;
         }
         if(param1 < -180)
         {
            _loc2_ = int(-(param1 - 180) / 360);
            return param1 + _loc2_ * 360;
         }
         return param1;
      }
      
      public static function radians2Pi(param1:Number) : Number
      {
         var _loc2_:int = 0;
         if(param1 > Math.PI * 2)
         {
            return param1 % (Math.PI * 2);
         }
         if(param1 < 0)
         {
            _loc2_ = int(-(param1 - Math.PI * 2) / (Math.PI * 2));
            return param1 + _loc2_ * (Math.PI * 2);
         }
         return param1;
      }
      
      public static function degrees2Radians(param1:Number) : Number
      {
         return param1 * Math.PI / 180;
      }
      
      public static function radians2Degrees(param1:Number) : Number
      {
         return param1 * 180 / Math.PI;
      }
      
      public static function randomInt(param1:int, param2:int) : int
      {
         if(param2 < param1)
         {
            throw new ArgumentError("MathUtil.randomInt invalid range");
         }
         var _loc3_:int = param2 - param1;
         return Math.round(Math.random() * _loc3_) + param1;
      }
      
      public static function manhattanDistance(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         var _loc5_:Number = Math.abs(param1 - param3);
         var _loc6_:Number = Math.abs(param2 - param4);
         return _loc5_ + _loc6_;
      }
      
      public static function distanceSquared(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         var _loc5_:Number = param1 - param3;
         var _loc6_:Number = param2 - param4;
         return _loc5_ * _loc5_ + _loc6_ * _loc6_;
      }
      
      public static function shuffle(param1:Array) : void
      {
         var _loc3_:int = 0;
         var _loc4_:* = undefined;
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            _loc3_ = Math.round(Math.random() * (param1.length - 1));
            if(_loc2_ != _loc3_)
            {
               _loc4_ = param1[_loc2_];
               param1[_loc2_] = param1[_loc3_];
               param1[_loc3_] = _loc4_;
            }
            _loc2_++;
         }
      }
      
      public static function map(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number) : Number
      {
         var _loc6_:Number = param3 - param2;
         var _loc7_:Number = param5 - param4;
         var _loc8_:Number = (param1 - param2) / (param3 - param2);
         return _loc7_ * _loc8_ + param4;
      }
      
      public static function stripDecimalPrecision(param1:Number, param2:int) : Number
      {
         return int(param1 * 10 * param2) / (10 * param2);
      }
   }
}
