package engine.core.util
{
   import engine.math.MathUtil;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.ColorTransform;
   
   public class ColorUtil
   {
       
      
      public function ColorUtil()
      {
         super();
      }
      
      public static function colorMatrix(param1:uint) : ColorMatrixFilter
      {
         var _loc2_:Argb = new Argb(param1);
         return new ColorMatrixFilter([_loc2_.r,0,0,0,0,0,_loc2_.g,0,0,0,0,0,_loc2_.b,0,0,0,0,0,_loc2_.a,0]);
      }
      
      public static function colorTransform(param1:uint, param2:ColorTransform) : ColorTransform
      {
         if(!param2)
         {
            param2 = new ColorTransform();
         }
         param2.color = param1;
         var _loc3_:uint = param1 >> 16 & 255;
         var _loc4_:uint = param1 >> 8 & 255;
         var _loc5_:uint = param1 >> 0 & 255;
         param2.redMultiplier = _loc3_ / 255;
         param2.greenMultiplier = _loc4_ / 255;
         param2.blueMultiplier = _loc5_ / 255;
         param2.alphaMultiplier = 1;
         param2.redOffset = 0;
         param2.greenOffset = 0;
         param2.blueOffset = 0;
         param2.alphaOffset = 0;
         return param2;
      }
      
      public static function randomColor() : uint
      {
         return 50 + Math.random() * 200 << 24 | 50 + Math.random() * 200 << 16 | 50 + Math.random() * 200 << 8 | 50 + Math.random() * 200;
      }
      
      public static function colorStr(param1:uint, param2:String = "#", param3:Boolean = false) : String
      {
         var _loc7_:String = null;
         var _loc4_:String = (param1 >> 16 & 255).toString(16);
         var _loc5_:String = (param1 >> 8 & 255).toString(16);
         var _loc6_:String = (param1 >> 0 & 255).toString(16);
         if(_loc4_.length == 1)
         {
            _loc4_ = "0" + _loc4_;
         }
         if(_loc5_.length == 1)
         {
            _loc5_ = "0" + _loc5_;
         }
         if(_loc6_.length == 1)
         {
            _loc6_ = "0" + _loc6_;
         }
         if(param3)
         {
            _loc7_ = (param1 >> 24 & 255).toString(16);
            if(_loc7_.length == 1)
            {
               _loc7_ = "0" + _loc7_;
            }
         }
         else
         {
            _loc7_ = "";
         }
         return (!!param2 ? param2 : "") + _loc7_ + _loc4_ + _loc5_ + _loc6_;
      }
      
      public static function lerpColor(param1:uint, param2:uint, param3:Number) : uint
      {
         var _loc4_:uint = param1 >> 24 & 255;
         var _loc5_:uint = param1 >> 16 & 255;
         var _loc6_:uint = param1 >> 8 & 255;
         var _loc7_:uint = param1 >> 0 & 255;
         var _loc8_:uint = param2 >> 24 & 255;
         var _loc9_:uint = param2 >> 16 & 255;
         var _loc10_:uint = param2 >> 8 & 255;
         var _loc11_:uint = param2 >> 0 & 255;
         var _loc12_:uint = MathUtil.lerp(_loc4_,_loc8_,param3);
         var _loc13_:uint = MathUtil.lerp(_loc5_,_loc9_,param3);
         var _loc14_:uint = MathUtil.lerp(_loc6_,_loc10_,param3);
         var _loc15_:uint = MathUtil.lerp(_loc7_,_loc11_,param3);
         return _loc12_ << 24 | _loc13_ << 16 | _loc14_ << 8 | _loc15_;
      }
      
      public static function greyen(param1:uint, param2:Number) : uint
      {
         return lerpColor(param1,8947848,param2);
      }
      
      public static function multiply(param1:uint, param2:uint) : uint
      {
         var _loc3_:uint = param1 >> 24 & 255;
         var _loc4_:uint = param1 >> 16 & 255;
         var _loc5_:uint = param1 >> 8 & 255;
         var _loc6_:uint = param1 >> 0 & 255;
         var _loc7_:uint = param2 >> 24 & 255;
         var _loc8_:uint = param2 >> 16 & 255;
         var _loc9_:uint = param2 >> 8 & 255;
         var _loc10_:uint = param2 >> 0 & 255;
         var _loc11_:Number = 1 / 255;
         var _loc12_:uint = _loc3_ * _loc7_ * _loc11_;
         var _loc13_:uint = _loc4_ * _loc8_ * _loc11_;
         var _loc14_:uint = _loc5_ * _loc9_ * _loc11_;
         var _loc15_:uint = _loc6_ * _loc10_ * _loc11_;
         _loc12_ = _loc12_ << 24 & 4278190080;
         _loc13_ = _loc13_ << 16 & 16711680;
         _loc14_ = _loc14_ << 8 & 65280;
         _loc15_ = _loc15_ << 0 & 255;
         return _loc12_ | _loc13_ | _loc14_ | _loc15_;
      }
   }
}
