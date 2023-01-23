package starling.utils
{
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import starling.errors.AbstractClassError;
   
   public class MathUtil
   {
      
      private static const TWO_PI:Number = Math.PI * 2;
       
      
      public function MathUtil()
      {
         super();
         throw new AbstractClassError();
      }
      
      public static function intersectLineWithXYPlane(param1:Vector3D, param2:Vector3D, param3:Point = null) : Point
      {
         if(param3 == null)
         {
            param3 = new Point();
         }
         var _loc4_:Number = param2.x - param1.x;
         var _loc5_:Number = param2.y - param1.y;
         var _loc6_:Number = param2.z - param1.z;
         var _loc7_:Number = -param1.z / _loc6_;
         param3.x = param1.x + _loc7_ * _loc4_;
         param3.y = param1.y + _loc7_ * _loc5_;
         return param3;
      }
      
      public static function normalizeAngle(param1:Number) : Number
      {
         param1 %= TWO_PI;
         if(param1 < -Math.PI)
         {
            param1 += TWO_PI;
         }
         if(param1 > Math.PI)
         {
            param1 -= TWO_PI;
         }
         return param1;
      }
      
      public static function clamp(param1:Number, param2:Number, param3:Number) : Number
      {
         return param1 < param2 ? param2 : (param1 > param3 ? param3 : param1);
      }
   }
}
