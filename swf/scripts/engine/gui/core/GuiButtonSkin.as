package engine.gui.core
{
   import flash.display.BitmapData;
   import flash.utils.Dictionary;
   
   public class GuiButtonSkin
   {
       
      
      private var states:Dictionary;
      
      public function GuiButtonSkin(param1:Object)
      {
         var _loc2_:Object = null;
         var _loc3_:DebugGuiButtonState = null;
         this.states = new Dictionary();
         super();
         for each(_loc2_ in param1.states)
         {
            _loc3_ = DebugGuiButtonState.registry.byName(_loc2_.name) as DebugGuiButtonState;
            this.states[_loc3_] = new GuiButtonSkinState(_loc2_.skin);
         }
      }
      
      public function getTextColor(param1:DebugGuiButtonState) : uint
      {
         return this.getSkinState(param1).textColor;
      }
      
      public function getTextSize(param1:DebugGuiButtonState) : uint
      {
         return this.getSkinState(param1).textSize;
      }
      
      public function getBitmap(param1:DebugGuiButtonState) : BitmapData
      {
         return this.getSkinState(param1).bitmap;
      }
      
      public function getSkinState(param1:DebugGuiButtonState) : GuiButtonSkinState
      {
         var _loc2_:GuiButtonSkinState = this.states[param1];
         if(_loc2_)
         {
            return _loc2_;
         }
         return this.states[DebugGuiButtonState.NORMAL];
      }
   }
}

import flash.display.BitmapData;

class GuiButtonSkinState
{
    
   
   public var textColor:uint;
   
   public var textSize:Number = 12;
   
   public var bitmap:BitmapData;
   
   public function GuiButtonSkinState(param1:Object)
   {
      super();
      this.textColor = param1.textColor;
      this.bitmap = param1.bitmap;
      if(param1.textSize)
      {
         this.textSize = param1.textSize;
      }
   }
}
