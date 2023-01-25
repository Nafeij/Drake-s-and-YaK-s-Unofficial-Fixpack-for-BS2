package engine.core.gp
{
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleCategory;
   import engine.core.util.Enum;
   import flash.utils.Dictionary;
   
   public class GpControlButton extends Enum
   {
      
      public static var swaps:Dictionary = new Dictionary();
      
      public static const Y:GpControlButton = new GpControlButton("Y",enumCtorKey);
      
      public static const B:GpControlButton = new GpControlButton("B",enumCtorKey);
      
      public static const A:GpControlButton = new GpControlButton("A",enumCtorKey);
      
      public static const X:GpControlButton = new GpControlButton("X",enumCtorKey);
      
      public static const L1:GpControlButton = new GpControlButton("L1",enumCtorKey);
      
      public static const R1:GpControlButton = new GpControlButton("R1",enumCtorKey);
      
      public static const L2:GpControlButton = new GpControlButton("L2",enumCtorKey);
      
      public static const R2:GpControlButton = new GpControlButton("R2",enumCtorKey);
      
      public static const L3:GpControlButton = new GpControlButton("L3",enumCtorKey);
      
      public static const R3:GpControlButton = new GpControlButton("R3",enumCtorKey);
      
      public static const MENU:GpControlButton = new GpControlButton("MENU",enumCtorKey);
      
      public static const START:GpControlButton = new GpControlButton("START",enumCtorKey);
      
      public static const TRACKPAD_PRESS:GpControlButton = new GpControlButton("TRACKPAD_PRESS",enumCtorKey);
      
      public static const AXIS_LEFT_H:GpControlButton = new GpControlButton("AXIS_LEFT_H",enumCtorKey);
      
      public static const AXIS_LEFT_V:GpControlButton = new GpControlButton("AXIS_LEFT_V",enumCtorKey);
      
      public static const AXIS_RIGHT_H:GpControlButton = new GpControlButton("AXIS_RIGHT_H",enumCtorKey);
      
      public static const AXIS_RIGHT_V:GpControlButton = new GpControlButton("AXIS_RIGHT_V",enumCtorKey);
      
      public static const AXIS_LEFT_T:GpControlButton = new GpControlButton("AXIS_LEFT_T",enumCtorKey);
      
      public static const AXIS_RIGHT_T:GpControlButton = new GpControlButton("AXIS_RIGHT_T",enumCtorKey);
      
      public static const D_D:GpControlButton = new GpControlButton("D_D",enumCtorKey);
      
      public static const D_L:GpControlButton = new GpControlButton("D_L",enumCtorKey);
      
      public static const D_LD:GpControlButton = new GpControlButton("D_LD",enumCtorKey);
      
      public static const D_LR:GpControlButton = new GpControlButton("D_LR",enumCtorKey);
      
      public static const D_LRD:GpControlButton = new GpControlButton("D_LRD",enumCtorKey);
      
      public static const D_LRU:GpControlButton = new GpControlButton("D_LRU",enumCtorKey);
      
      public static const D_LRUD:GpControlButton = new GpControlButton("D_LRUD",enumCtorKey);
      
      public static const D_LU:GpControlButton = new GpControlButton("D_LU",enumCtorKey);
      
      public static const D_LUD:GpControlButton = new GpControlButton("D_LUD",enumCtorKey);
      
      public static const D_R:GpControlButton = new GpControlButton("D_R",enumCtorKey);
      
      public static const D_RD:GpControlButton = new GpControlButton("D_RD",enumCtorKey);
      
      public static const D_RU:GpControlButton = new GpControlButton("D_RU",enumCtorKey);
      
      public static const D_RUD:GpControlButton = new GpControlButton("D_RUD",enumCtorKey);
      
      public static const D_U:GpControlButton = new GpControlButton("D_U",enumCtorKey);
      
      public static const D_UD:GpControlButton = new GpControlButton("D_UD",enumCtorKey);
      
      public static const LSTICK:GpControlButton = new GpControlButton("LSTICK",enumCtorKey);
      
      public static const RSTICK:GpControlButton = new GpControlButton("RSTICK",enumCtorKey);
      
      public static const LSTICK_LEFT:GpControlButton = new GpControlButton("LSTICK_LEFT",enumCtorKey);
      
      public static const LSTICK_RIGHT:GpControlButton = new GpControlButton("LSTICK_RIGHT",enumCtorKey);
      
      public static const LSTICK_UP:GpControlButton = new GpControlButton("LSTICK_UP",enumCtorKey);
      
      public static const LSTICK_DOWN:GpControlButton = new GpControlButton("LSTICK_DOWN",enumCtorKey);
      
      public static const RSTICK_LEFT:GpControlButton = new GpControlButton("RSTICK_LEFT",enumCtorKey);
      
      public static const RSTICK_RIGHT:GpControlButton = new GpControlButton("RSTICK_RIGHT",enumCtorKey);
      
      public static const RSTICK_UP:GpControlButton = new GpControlButton("RSTICK_UP",enumCtorKey);
      
      public static const RSTICK_DOWN:GpControlButton = new GpControlButton("RSTICK_DOWN",enumCtorKey);
      
      public static const TOUCH_BTN:GpControlButton = new GpControlButton("TOUCH_BTN",enumCtorKey);
      
      public static const TOUCH_PAD_0_X:GpControlButton = new GpControlButton("TOUCH_PAD_0_X",enumCtorKey);
      
      public static const TOUCH_PAD_0_Y:GpControlButton = new GpControlButton("TOUCH_PAD_0_Y",enumCtorKey);
      
      public static const TOUCH_PAD_1_X:GpControlButton = new GpControlButton("TOUCH_PAD_1_X",enumCtorKey);
      
      public static const TOUCH_PAD_1_Y:GpControlButton = new GpControlButton("TOUCH_PAD_1_Y",enumCtorKey);
      
      public static const BUTTON_CLUSTER:GpControlButton = new GpControlButton("BUTTON_CLUSTER",enumCtorKey);
      
      public static const DPAD:GpControlButton = new GpControlButton("DPAD",enumCtorKey);
      
      public static const POINTER:GpControlButton = new GpControlButton("POINTER",enumCtorKey);
      
      public static var REPLACE_MENU_BUTTON:GpControlButton = MENU;
      
      public static var HAS_STICK_BUTTONS:Boolean = true;
      
      private static var _dpads:Array = [DPAD,D_U,D_R,D_RU,D_D,D_UD,D_RD,D_RUD,D_L,D_LU,D_LR,D_LRU,D_LD,D_LUD,D_LRD,D_LRUD];
       
      
      private var nameLower:String;
      
      public function GpControlButton(param1:String, param2:Object)
      {
         super(param1,param2);
         this.nameLower = param1.toLowerCase();
      }
      
      public static function getSwapped(param1:GpControlButton) : GpControlButton
      {
         var _loc2_:GpControlButton = swaps[param1];
         return !!_loc2_ ? _loc2_ : param1;
      }
      
      public static function addSwapByNames(param1:Array) : void
      {
         if(param1.length != 2)
         {
            throw new ArgumentError("invalid swap by names [" + param1.join(",") + "]");
         }
         var _loc2_:GpControlButton = Enum.parse(GpControlButton,param1[0]) as GpControlButton;
         var _loc3_:GpControlButton = Enum.parse(GpControlButton,param1[1]) as GpControlButton;
         addSwap(_loc2_,_loc3_);
      }
      
      public static function addSwap(param1:GpControlButton, param2:GpControlButton) : void
      {
         swaps[param1] = param2;
         swaps[param2] = param1;
      }
      
      public static function clearSwaps() : void
      {
         swaps = new Dictionary();
      }
      
      public static function dpad_bits(param1:uint) : GpControlButton
      {
         param1 &= 15;
         return _dpads[param1];
      }
      
      public static function dpad(param1:Boolean, param2:Boolean, param3:Boolean, param4:Boolean) : GpControlButton
      {
         var _loc5_:uint = uint((param1 ? 1 : 0) | (param2 ? 2 : 0) | (param3 ? 4 : 0) | (param4 ? 8 : 0));
         return _dpads[_loc5_];
      }
      
      public function get swap() : GpControlButton
      {
         return getSwapped(this);
      }
      
      public function getLocName(param1:Locale, param2:String, param3:Boolean = false) : String
      {
         var _loc4_:* = null;
         var _loc5_:String = null;
         if(param2)
         {
            _loc4_ = "ctl_" + this.nameLower + "_" + param2 + "_name";
            _loc5_ = param1.translate(LocaleCategory.GP,_loc4_,true);
            if(!_loc5_)
            {
               _loc4_ = "ctl_" + this.nameLower + "_" + param2.charAt(0) + "_name";
               _loc5_ = param1.translate(LocaleCategory.GP,_loc4_,true);
            }
         }
         if(!_loc5_)
         {
            _loc4_ = "ctl_" + this.nameLower + "_name";
            _loc5_ = param1.translate(LocaleCategory.GP,_loc4_,param3);
         }
         return _loc5_;
      }
   }
}
