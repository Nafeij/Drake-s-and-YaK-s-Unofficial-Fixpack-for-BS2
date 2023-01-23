package game.gui.pages
{
   import engine.core.util.StringUtil;
   import game.gui.GuiIcon;
   import game.gui.IGuiContext;
   
   public class GuiCreditsSectionBitmap extends GuiCreditsSectionBase
   {
       
      
      public var icons:Vector.<GuiIcon>;
      
      public var iconBottom:int;
      
      private var LINEBREAK_HEIGHT:int = 20;
      
      public function GuiCreditsSectionBitmap()
      {
         this.icons = new Vector.<GuiIcon>();
         super();
      }
      
      override public function cleanup() : void
      {
         var _loc1_:GuiIcon = null;
         for each(_loc1_ in this.icons)
         {
            if(_loc1_)
            {
               _loc1_.release();
               _loc1_ = null;
            }
         }
      }
      
      override public function get height() : Number
      {
         return Math.max(super.height,this.iconBottom);
      }
      
      public function init(param1:IGuiContext, param2:String, param3:String) : void
      {
         var _loc5_:String = null;
         super.initSectionBase(param1,param2);
         _header.cacheAsBitmap = true;
         this.iconBottom = _header.y + _header.height;
         var _loc4_:Array = param3.split("\n");
         for each(_loc5_ in _loc4_)
         {
            _loc5_ = StringUtil.stripSurroundingSpace(_loc5_);
            if(!_loc5_)
            {
               this.iconBottom += this.LINEBREAK_HEIGHT;
            }
            else
            {
               this.addBitmapLine(param1,_loc5_);
            }
         }
      }
      
      private function addBitmapLine(param1:IGuiContext, param2:String) : void
      {
         var _loc3_:Array = param2.split(",");
         var _loc4_:GuiIcon = param1.getIcon(_loc3_[0]);
         var _loc5_:int = _loc4_.width;
         var _loc6_:int = _loc4_.height;
         if(_loc3_.length < 2)
         {
            throw new ArgumentError("bmp line does not have size token after a comma: [" + param2 + "]");
         }
         var _loc7_:String = _loc3_[1];
         var _loc8_:Array = _loc7_.split("x");
         if(_loc8_.length < 2)
         {
            throw new ArgumentError("bmp size doesn\'t have exactly 2 elements: [" + param2 + "]");
         }
         var _loc9_:int = int(_loc8_[0]);
         var _loc10_:int = int(_loc8_[1]);
         _loc5_ = Math.max(_loc5_,_loc9_);
         _loc6_ = Math.max(_loc6_,_loc10_);
         addChild(_loc4_);
         this.icons.push(_loc4_);
         _loc4_.y = this.iconBottom;
         _loc4_.x = -_loc5_ / 2;
         this.iconBottom += _loc6_;
      }
   }
}
