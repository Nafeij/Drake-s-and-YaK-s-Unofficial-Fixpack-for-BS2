package engine.gui
{
   import engine.core.util.Enum;
   
   public class GuiButtonState extends Enum
   {
      
      public static const NORMAL:GuiButtonState = new GuiButtonState("NORMAL",1,null,enumCtorKey);
      
      public static const HOVER:GuiButtonState = new GuiButtonState("HOVER",2,NORMAL,enumCtorKey);
      
      public static const DOWN:GuiButtonState = new GuiButtonState("DOWN",3,HOVER,enumCtorKey);
      
      public static const TOGGLED:GuiButtonState = new GuiButtonState("TOGGLED",4,NORMAL,enumCtorKey);
      
      public static const TOGGLED_HOVER:GuiButtonState = new GuiButtonState("TOGGLED_HOVER",5,HOVER,enumCtorKey);
      
      public static const TOGGLED_DOWN:GuiButtonState = new GuiButtonState("TOGGLED_DOWN",6,DOWN,enumCtorKey);
      
      public static const DISABLED:GuiButtonState = new GuiButtonState("DISABLED",7,NORMAL,enumCtorKey);
      
      public static const DISABLED_TOGGLED:GuiButtonState = new GuiButtonState("DISABLED_TOGGLED",8,TOGGLED,enumCtorKey);
       
      
      private var _frame:int;
      
      private var _fallback:GuiButtonState;
      
      public function GuiButtonState(param1:String, param2:int, param3:GuiButtonState, param4:Object)
      {
         super(param1,param4);
         this._frame = param2;
         this._fallback = param3;
      }
      
      public function get frame() : int
      {
         return this._frame;
      }
      
      public function get fallbackFrame() : int
      {
         return Boolean(this._fallback) && this._fallback != this ? this._fallback._frame : this._frame;
      }
      
      public function getBestFrame(param1:int) : int
      {
         if(param1 < this._frame && this._fallback && this._fallback != this)
         {
            return this._fallback.getBestFrame(param1);
         }
         return this._frame;
      }
   }
}
