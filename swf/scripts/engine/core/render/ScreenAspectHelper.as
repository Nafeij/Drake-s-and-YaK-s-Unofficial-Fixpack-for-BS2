package engine.core.render
{
   import engine.math.MathUtil;
   
   public class ScreenAspectHelper
   {
      
      public static const RATIO_CINEMASCOPE:Number = 2.35;
      
      public static const RATIO_WIDESCREEN:Number = 1.7777777777777777;
      
      public static const RATIO_STANDARD:Number = 1.3333333333333333;
      
      public static const HEIGHT_NATIVE:Number = 1536;
      
      public static const WIDTH_STANDARD:Number = 2048;
      
      public static const WIDTH_NATIVE:Number = HEIGHT_NATIVE * RATIO_WIDESCREEN;
      
      public static const HEIGHT_CINEMASCOPE:Number = WIDTH_NATIVE / RATIO_CINEMASCOPE;
      
      public static var ENABLE_UHD:Boolean = true;
       
      
      public function ScreenAspectHelper()
      {
         super();
      }
      
      public static function getNativeScreenScale(param1:Number, param2:Number, param3:Number = 2730.6666666666665, param4:Number = 1536) : Number
      {
         var _loc5_:Number = param1 / param3;
         var _loc6_:Number = param2 / param4;
         return Math.min(1,Math.min(_loc5_,_loc6_));
      }
      
      public static function fitCamera(param1:Number, param2:Number, param3:FitConstraints, param4:FitData) : void
      {
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         if(isNaN(param1) || isNaN(param2) || param2 == 0 || param1 == 0)
         {
            param4.width = Math.max(param3.minWidth,Math.min(param3.maxWidth,param3.width));
            param4.height = Math.max(param3.minHeight,Math.min(param3.maxHeight,param3.height));
            param4.innerScale = 1;
            return;
         }
         param4.width = Math.max(param3.minWidth,Math.min(param3.maxWidth,param1));
         param4.height = Math.max(param3.minHeight,Math.min(param3.maxHeight,param2));
         if(param3.cinemascope || param3.minHeight == param3.maxHeight)
         {
            _loc7_ = param1 / param2;
            _loc8_ = (_loc7_ - Number(ScreenAspectHelper.RATIO_STANDARD)) / (Number(ScreenAspectHelper.RATIO_WIDESCREEN) - Number(ScreenAspectHelper.RATIO_STANDARD));
            _loc8_ = Math.max(0,Math.min(1,_loc8_));
            param4.width = MathUtil.lerp(param3.minWidth,param3.maxWidth,_loc8_);
            if(param3.cinemascope)
            {
               if(_loc7_ < ScreenAspectHelper.RATIO_WIDESCREEN)
               {
                  _loc9_ = param4.width / Number(ScreenAspectHelper.RATIO_WIDESCREEN);
                  param4.height = Math.max(param4.height,_loc9_);
               }
            }
         }
         var _loc5_:Number = param1 / param4.width;
         var _loc6_:Number = param2 / param4.height;
         param4.innerScale = Math.min(1,Math.min(_loc5_,_loc6_));
         param4.height = Math.min(param3.maxHeight,param4.height);
         _fitCameraScaleUpUHD(param1,param2,param4);
      }
      
      private static function _fitCameraScaleUpUHD(param1:Number, param2:Number, param3:FitData) : void
      {
         if(!ENABLE_UHD)
         {
            return;
         }
         if(param3.width >= param1 || param3.height >= param2)
         {
            param3.outerScale = 1;
            return;
         }
         var _loc4_:Number = param1 / param3.width;
         var _loc5_:Number = param2 / param3.height;
         var _loc6_:Number = Math.min(_loc4_,_loc5_);
         param3.outerScale = _loc6_;
      }
      
      public static function fitCameraGuiPage(param1:Number, param2:Number, param3:FitConstraints, param4:FitData) : void
      {
         if(isNaN(param1) || isNaN(param2) || param2 == 0 || param1 == 0)
         {
            param4.width = Math.max(param3.minWidth,Math.min(param3.maxWidth,param3.width));
            param4.height = Math.max(param3.minHeight,Math.min(param3.maxHeight,param3.height));
            param4.innerScale = 1;
            return;
         }
         var _loc5_:Number = param1 / param3.maxWidth;
         var _loc6_:Number = param1 / param3.minWidth;
         var _loc7_:Number = Math.max(_loc5_,_loc6_);
         var _loc8_:Number = param2 / param3.maxHeight;
         var _loc9_:Number = param2 / param3.minHeight;
         var _loc10_:Number = Math.max(_loc8_,_loc9_);
         param4.innerScale = Math.min(_loc7_,_loc10_);
         param4.width = Math.min(param1,param3.maxWidth * param4.innerScale);
         param4.height = Math.min(param2,param3.maxHeight * param4.innerScale);
      }
   }
}
