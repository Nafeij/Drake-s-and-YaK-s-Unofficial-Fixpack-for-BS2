package engine.gui
{
   import engine.core.gp.GpControlButton;
   import flash.display.BitmapData;
   import flash.utils.Dictionary;
   
   public class GuiGpControlButtons
   {
       
      
      public var visualCategory:String;
      
      public var controlButton2BitmapData:Dictionary;
      
      public var controlButton2Clazz:Dictionary;
      
      public var fallback:GuiGpControlButtons;
      
      public function GuiGpControlButtons(param1:String)
      {
         this.controlButton2BitmapData = new Dictionary();
         this.controlButton2Clazz = new Dictionary();
         super();
         this.visualCategory = param1;
      }
      
      public function addButton(param1:GpControlButton, param2:Class) : void
      {
         this.controlButton2Clazz[param1] = param2;
      }
      
      public function swapButtonUI(param1:GpControlButton, param2:GpControlButton) : void
      {
         var _loc3_:Class = this.controlButton2Clazz[param1];
         this.controlButton2Clazz[param1] = this.controlButton2Clazz[param2];
         this.controlButton2Clazz[param2] = _loc3_;
      }
      
      public function printControlButton2BitmapData() : String
      {
         var _loc2_:Object = null;
         var _loc3_:GpControlButton = null;
         var _loc4_:Class = null;
         var _loc1_:String = "";
         for(_loc2_ in this.controlButton2Clazz)
         {
            _loc3_ = _loc2_ as GpControlButton;
            _loc4_ = this.controlButton2Clazz[_loc2_];
            _loc1_ += "" + _loc3_.name + " " + _loc4_ + "\n";
         }
         return _loc1_;
      }
      
      public function ctorBitmapData(param1:GpControlButton) : BitmapData
      {
         var _loc5_:Class = null;
         var _loc2_:GpControlButton = param1.swap;
         var _loc3_:* = this.controlButton2BitmapData[_loc2_];
         var _loc4_:BitmapData = _loc3_ as BitmapData;
         if(_loc3_ == undefined)
         {
            _loc5_ = this.controlButton2Clazz[_loc2_];
            _loc4_ = !!_loc5_ ? new _loc5_() as BitmapData : null;
            if(!_loc4_)
            {
               if(this.fallback)
               {
                  _loc4_ = this.fallback.ctorBitmapData(param1);
               }
            }
            this.controlButton2BitmapData[_loc2_] = _loc4_;
         }
         return _loc4_;
      }
   }
}
