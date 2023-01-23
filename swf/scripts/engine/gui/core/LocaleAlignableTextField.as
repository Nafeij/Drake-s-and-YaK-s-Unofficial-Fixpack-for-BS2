package engine.gui.core
{
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleFont;
   import engine.core.locale.LocaleInfo;
   import engine.core.util.StringUtil;
   import flash.text.TextField;
   
   public class LocaleAlignableTextField
   {
       
      
      public var textField:TextField;
      
      public var origY:Number;
      
      public var isVinque:Boolean;
      
      public function LocaleAlignableTextField(param1:TextField)
      {
         super();
         if(!param1)
         {
            throw new ArgumentError("Requires a textField");
         }
         this.textField = param1;
         this.origY = param1.y;
         var _loc2_:String = param1.defaultTextFormat.font;
         if(StringUtil.startsWith(_loc2_,LocaleFont.FACE_V))
         {
            this.isVinque = true;
         }
      }
      
      public static function ctor(param1:TextField) : LocaleAlignableTextField
      {
         if(!param1)
         {
            return null;
         }
         return new LocaleAlignableTextField(param1);
      }
      
      public function realign(param1:Locale, param2:Boolean = true) : void
      {
         var _loc4_:LocaleFont = null;
         this.textField.y = this.origY;
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
      
      public function set text(param1:String) : void
      {
         this.textField.text = param1;
      }
   }
}
