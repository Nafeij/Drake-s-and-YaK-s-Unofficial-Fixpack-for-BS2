package engine.gui
{
   import com.stoicstudio.platform.PlatformFlash;
   import engine.core.gp.GpControlButton;
   import engine.core.gp.GpDevice;
   import engine.core.gp.GpDeviceType;
   import engine.core.gp.GpSource;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Stage;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   
   public class GuiGp
   {
      
      private static var type2controlButtos:Dictionary = new Dictionary();
      
      private static var primaryBmp2ControlButton:Dictionary = new Dictionary();
      
      public static var FORCE_VIS:String = null;
      
      public static const PLACEMENT_ADJUST_INNER:String = "PLACEMENT_ADJUSTMENT_INNER";
      
      public static const PLACEMENT_ADJUST_OUTER:String = "PLACEMENT_ADJUSTMENT_OUTER";
      
      public static const PLACEMENT_ADJUST_NONE:String = "PLACEMENT_ADJUSTMENT_NONE";
       
      
      public function GuiGp()
      {
         super();
      }
      
      public static function getControlButtonsForType(param1:GpDeviceType) : GuiGpControlButtons
      {
         if(!param1)
         {
            return null;
         }
         return getControlButtonsForVisualCategory(param1.visualCategory);
      }
      
      public static function getControlButtonsForVisualCategory(param1:String) : GuiGpControlButtons
      {
         if(!param1)
         {
            return null;
         }
         var _loc2_:GuiGpControlButtons = type2controlButtos[param1];
         if(!_loc2_)
         {
            _loc2_ = new GuiGpControlButtons(param1);
            type2controlButtos[param1] = _loc2_;
         }
         return _loc2_;
      }
      
      public static function ctorBitmapForType(param1:GpDeviceType, param2:GpControlButton, param3:Boolean = false) : GuiGpBitmap
      {
         return ctorBitmapForVisualCategory(!!param1 ? param1.visualCategory : null,param2,param3);
      }
      
      public static function ctorBitmapForVisualCategory(param1:String, param2:GpControlButton, param3:Boolean = false) : GuiGpBitmap
      {
         var _loc6_:GuiGpBitmap = null;
         var _loc4_:GuiGpControlButtons = getControlButtonsForVisualCategory(param1);
         var _loc5_:BitmapData = !!_loc4_ ? _loc4_.ctorBitmapData(param2) : null;
         _loc6_ = new GuiGpBitmap(_loc5_,param3);
         _loc6_.name = (!!param1 ? param1 : "none") + "_" + param2.name;
         return _loc6_;
      }
      
      public static function ctorPrimaryBitmap(param1:GpControlButton, param2:Boolean = false) : GuiGpBitmap
      {
         if(!param1)
         {
            return null;
         }
         var _loc3_:GpDeviceType = GpSource.primaryDeviceType;
         var _loc4_:String = !!_loc3_ ? _loc3_.visualCategory : null;
         if(FORCE_VIS)
         {
            _loc4_ = FORCE_VIS;
         }
         var _loc5_:GuiGpBitmap = ctorBitmapForVisualCategory(_loc4_,param1,param2);
         primaryBmp2ControlButton[_loc5_] = param1;
         return _loc5_;
      }
      
      public static function releasePrimaryBitmap(param1:GuiGpBitmap) : void
      {
         if(param1)
         {
            param1.cleanup();
            delete primaryBmp2ControlButton[param1];
         }
      }
      
      public static function handlePrimaryDeviceChanged() : void
      {
         var _loc2_:Object = null;
         var _loc3_:GuiGpBitmap = null;
         var _loc4_:GpControlButton = null;
         var _loc5_:BitmapData = null;
         var _loc1_:GuiGpControlButtons = getControlButtonsForType(GpSource.primaryDeviceType);
         for(_loc2_ in primaryBmp2ControlButton)
         {
            _loc3_ = _loc2_ as GuiGpBitmap;
            _loc4_ = primaryBmp2ControlButton[_loc2_];
            _loc5_ = !!_loc1_ ? _loc1_.ctorBitmapData(_loc4_) : null;
            _loc3_.bitmapData = _loc5_;
         }
      }
      
      public static function placeIconCenter(param1:DisplayObject, param2:DisplayObject) : void
      {
         var _loc3_:Rectangle = param1.getBounds(param2.parent);
         var _loc4_:Rectangle = param2.getBounds(null);
         param2.x = (_loc3_.left + _loc3_.right) / 2 - (_loc4_.right + _loc4_.left) / 2;
         param2.y = (_loc3_.top + _loc3_.bottom) / 2 - (_loc4_.bottom + _loc4_.top) / 2;
         fitToScreen(param2);
      }
      
      public static function placeIconBottom(param1:DisplayObject, param2:DisplayObject, param3:GuiGpAlignV = null, param4:GuiGpAlignH = null) : void
      {
         param4 = !!param4 ? param4 : GuiGpAlignH.C;
         param3 = !!param3 ? param3 : GuiGpAlignV.S;
         placeIcon(param1,null,param2,param4,param3);
      }
      
      public static function placeIconRight(param1:DisplayObject, param2:DisplayObject, param3:GuiGpAlignV = null, param4:GuiGpAlignH = null) : void
      {
         param4 = !!param4 ? param4 : GuiGpAlignH.E;
         param3 = !!param3 ? param3 : GuiGpAlignV.C;
         placeIcon(param1,null,param2,param4,param3);
      }
      
      public static function placeIconLeft(param1:DisplayObject, param2:DisplayObject, param3:GuiGpAlignV = null, param4:GuiGpAlignH = null) : void
      {
         param4 = !!param4 ? param4 : GuiGpAlignH.W;
         param3 = !!param3 ? param3 : GuiGpAlignV.C;
         placeIcon(param1,null,param2,param4,param3);
      }
      
      public static function placeIcon(param1:DisplayObject, param2:Rectangle, param3:DisplayObject, param4:GuiGpAlignH, param5:GuiGpAlignV, param6:int = 0, param7:int = 0) : void
      {
         if(!param3 || !param3.parent)
         {
            return;
         }
         if(!param2)
         {
            if(!param1)
            {
               return;
            }
            param2 = param1.getBounds(param3.parent);
         }
         var _loc8_:Rectangle = param3.getBounds(param3.parent);
         if(_loc8_.isEmpty())
         {
            _loc8_.setTo(0,0,52,52);
         }
         param3.x = param3.y = 0;
         switch(param4)
         {
            case GuiGpAlignH.W_LEFT:
               param3.x = param2.left - _loc8_.width;
               break;
            case GuiGpAlignH.W:
               param3.x = param2.left - _loc8_.width / 2;
               break;
            case GuiGpAlignH.W_RIGHT:
               param3.x = param2.left;
               break;
            case GuiGpAlignH.C_LEFT:
               param3.x = (param2.left + param2.right) / 2 - _loc8_.width;
               break;
            case GuiGpAlignH.C:
               param3.x = (param2.left + param2.right - _loc8_.width) / 2;
               break;
            case GuiGpAlignH.C_RIGHT:
               param3.x = (param2.left + param2.right) / 2;
               break;
            case GuiGpAlignH.E_LEFT:
               param3.x = param2.right - _loc8_.width;
               break;
            case GuiGpAlignH.E:
               param3.x = param2.right - _loc8_.width / 2;
               break;
            case GuiGpAlignH.E_RIGHT:
               param3.x = param2.right;
         }
         switch(param5)
         {
            case GuiGpAlignV.N_UP:
               param3.y = param2.top - _loc8_.height;
               break;
            case GuiGpAlignV.N:
               param3.y = param2.top - _loc8_.height / 2;
               break;
            case GuiGpAlignV.N_DOWN:
               param3.y = param2.top;
               break;
            case GuiGpAlignV.C_UP:
               param3.y = (param2.top + param2.bottom) / 2 - _loc8_.height;
               break;
            case GuiGpAlignV.C:
               param3.y = (param2.top + param2.bottom - _loc8_.height) / 2;
               break;
            case GuiGpAlignV.C_DOWN:
               param3.y = (param2.top + param2.bottom) / 2;
               break;
            case GuiGpAlignV.S_UP:
               param3.y = param2.bottom - _loc8_.height;
               break;
            case GuiGpAlignV.S:
               param3.y = param2.bottom - _loc8_.height / 2;
               break;
            case GuiGpAlignV.S_DOWN:
               param3.y = param2.bottom;
         }
         param3.x += param6;
         param3.y += param7;
         fitToScreen(param3);
      }
      
      public static function placeIconTop(param1:DisplayObject, param2:DisplayObject, param3:GuiGpAlignH = null, param4:GuiGpAlignV = null) : void
      {
         param3 = !!param3 ? param3 : GuiGpAlignH.C;
         param4 = !!param4 ? param4 : GuiGpAlignV.N;
         placeIcon(param1,null,param2,param3,param4);
      }
      
      public static function fitToScreen(param1:DisplayObject) : void
      {
         var _loc2_:DisplayObject = PlatformFlash.stage;
         var _loc3_:Stage = PlatformFlash.stage;
         var _loc4_:Rectangle = param1.getBounds(_loc2_);
         if(_loc4_.left < 0)
         {
            param1.x += -_loc4_.left;
         }
         if(_loc4_.top < 0)
         {
            param1.y += -_loc4_.top;
         }
         if(_loc4_.right > _loc3_.stageWidth)
         {
            param1.x -= _loc4_.right - _loc3_.stageWidth;
         }
         if(_loc4_.bottom > _loc3_.stageHeight)
         {
            param1.y -= _loc4_.bottom - _loc3_.stageHeight;
         }
         param1.x = int(param1.x);
         param1.y = int(param1.y);
      }
      
      public static function computeStickAngle(param1:Number) : Number
      {
         var _loc2_:GpDevice = GpSource.primaryDevice;
         if(!_loc2_)
         {
            return NaN;
         }
         var _loc3_:Number = _loc2_.getStickValue(GpControlButton.AXIS_LEFT_H);
         var _loc4_:Number = _loc2_.getStickValue(GpControlButton.AXIS_LEFT_V);
         var _loc5_:Number = _loc3_ * _loc3_ + _loc4_ * _loc4_;
         if(_loc5_ <= param1)
         {
            return NaN;
         }
         return Math.atan2(_loc4_,_loc3_) * 180 / Math.PI;
      }
   }
}
