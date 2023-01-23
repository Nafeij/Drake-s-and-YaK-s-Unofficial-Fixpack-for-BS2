package engine.gui.core
{
   import engine.core.util.BitmapUtil;
   import flash.display.BitmapData;
   import flash.display.StageQuality;
   import flash.geom.Rectangle;
   import flash.text.AntiAliasType;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   
   public class GuiLabel extends GuiSprite
   {
       
      
      public var label:TextField;
      
      public function GuiLabel(param1:String = "Minion Pro", param2:int = 16, param3:uint = 0, param4:Boolean = true)
      {
         this.label = new TextField();
         super();
         this.label.name = "text";
         addChild(this.label);
         setSize(100,param2);
         var _loc5_:TextFormat = new TextFormat(param1,param2,param3,param4);
         _loc5_.align = TextFormatAlign.LEFT;
         this.label.defaultTextFormat = _loc5_;
         this.label.antiAliasType = AntiAliasType.NORMAL;
         this.label.textColor = param3;
         this.label.selectable = false;
         this.label.mouseEnabled = false;
         this.label.maxChars = 0;
         this.label.y = 0;
         this.label.autoSize = TextFieldAutoSize.LEFT;
         this.cacheAsBitmap = true;
      }
      
      public function createBitmapData() : BitmapData
      {
         var _loc1_:Rectangle = getBounds(null);
         var _loc2_:BitmapData = new BitmapData(_loc1_.width,_loc1_.height,true,0);
         BitmapUtil.drawWithQuality(_loc2_,this,null,null,null,null,true,StageQuality.BEST);
         return _loc2_;
      }
      
      override public function toString() : String
      {
         return "GuiLabel [text=" + this.label.text + ", color=" + this.label.textColor.toString(16) + "]";
      }
      
      override public function set cacheAsBitmap(param1:Boolean) : void
      {
         this.label.cacheAsBitmap = param1;
         super.cacheAsBitmap = param1;
      }
      
      override protected function resizeHandler() : void
      {
         this.label.width = this.width;
         this.label.height = this.height;
         super.resizeHandler();
      }
      
      public function get text() : String
      {
         return this.label.text;
      }
      
      public function set text(param1:String) : void
      {
         this.label.htmlText = param1;
         this.label.width = this.width;
         this.label.height = this.height;
      }
      
      public function get textColor() : uint
      {
         return this.label.textColor;
      }
      
      public function set textColor(param1:uint) : void
      {
         this.label.textColor = param1;
      }
      
      public function get textFormatAlign() : String
      {
         return this.label.defaultTextFormat.align;
      }
      
      public function set textFormatAlign(param1:String) : void
      {
         var _loc2_:TextFormat = this.label.defaultTextFormat;
         _loc2_.align = param1;
         this.label.setTextFormat(_loc2_);
         this.label.defaultTextFormat = _loc2_;
      }
      
      public function get textFormatSize() : Number
      {
         return !!this.label.defaultTextFormat.size ? this.label.defaultTextFormat.size as Number : 12;
      }
      
      public function set textFormatSize(param1:Number) : void
      {
         var _loc2_:TextFormat = this.label.defaultTextFormat;
         _loc2_.size = param1;
         this.label.setTextFormat(_loc2_);
         this.label.defaultTextFormat = _loc2_;
      }
      
      public function sizeToContent() : void
      {
         setSize(this.label.textWidth,this.label.textHeight);
      }
   }
}
