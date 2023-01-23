package engine.gui.core
{
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleFont;
   import engine.core.locale.LocaleInfo;
   import engine.core.util.StringUtil;
   import engine.gui.GuiUtil;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   
   public class ResizableTextField
   {
       
      
      public var textField:TextField;
      
      public var rect:Rectangle;
      
      public var isVinque:Boolean;
      
      public function ResizableTextField(param1:TextField)
      {
         super();
         if(!param1)
         {
            throw new ArgumentError("Requires a textField");
         }
         this.textField = param1;
         this.rect = param1.getRect(param1.parent);
         var _loc2_:String = param1.defaultTextFormat.font;
         if(StringUtil.startsWith(_loc2_,LocaleFont.FACE_V))
         {
            this.isVinque = true;
         }
      }
      
      public static function ctor(param1:TextField) : ResizableTextField
      {
         if(!param1)
         {
            return null;
         }
         return new ResizableTextField(param1);
      }
      
      public function scaleToFit(param1:Locale, param2:Boolean = true) : void
      {
         var _loc4_:LocaleFont = null;
         this.textField.x = this.rect.x;
         this.textField.y = this.rect.y;
         GuiUtil.scaleTextToFitRect(this.textField,this.rect,false,param2);
         var _loc3_:LocaleInfo = !!param1 ? param1.info : null;
         if(_loc3_)
         {
            _loc4_ = this.isVinque ? _loc3_.font_v : _loc3_.font_m;
            if(Boolean(_loc4_) && Boolean(_loc4_.offsetY))
            {
               this.textField.y += _loc4_.offsetY;
            }
         }
      }
      
      public function set mouseEnabled(param1:Boolean) : void
      {
         this.textField.mouseEnabled = param1;
      }
      
      public function set x(param1:Number) : void
      {
         this.textField.x = this.x;
         this.rect.x = this.x;
      }
      
      public function get x() : Number
      {
         return this.textField.x;
      }
      
      public function get y() : Number
      {
         return this.textField.y;
      }
      
      public function get height() : Number
      {
         return this.textField.height;
      }
      
      public function get width() : Number
      {
         return this.textField.width;
      }
      
      public function get filters() : Array
      {
         return this.textField.filters;
      }
      
      public function set filters(param1:Array) : void
      {
         this.textField.filters = param1;
      }
      
      public function set text(param1:String) : void
      {
         this.textField.text = param1;
      }
   }
}
