package game.gui.pages
{
   import flash.text.TextField;
   import flash.text.TextFormat;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   
   public class GuiCreditsSectionBase extends GuiBase
   {
       
      
      public var _header:TextField;
      
      protected var _textColor:uint = 16777215;
      
      protected var _headerColor:uint = 16777215;
      
      public function GuiCreditsSectionBase()
      {
         super();
      }
      
      public static function duplicateTextFormat(param1:TextField, param2:String = null) : TextFormat
      {
         var _loc3_:TextFormat = param1.defaultTextFormat;
         if(!param2)
         {
            param2 = _loc3_.align;
         }
         return new TextFormat(_loc3_.font,_loc3_.size,_loc3_.color,_loc3_.bold,_loc3_.italic,_loc3_.underline,_loc3_.url,_loc3_.target,param2,_loc3_.leftMargin,_loc3_.rightMargin,_loc3_.indent,_loc3_.leading);
      }
      
      public function set textColor(param1:uint) : void
      {
         this._textColor = param1;
      }
      
      public function set headerColor(param1:uint) : void
      {
         this._headerColor = param1;
         if(this._header)
         {
            this._header.textColor = this._headerColor;
         }
      }
      
      public function cleanup() : void
      {
         super.cleanupGuiBase();
         if(this.parent)
         {
            this.parent.removeChild(this);
         }
         this._header = null;
      }
      
      public function initSectionBase(param1:IGuiContext, param2:String) : void
      {
         super.initGuiBase(param1);
         this._header = requireGuiChild("header") as TextField;
         this.mouseChildren = false;
         this.mouseEnabled = false;
         this._header.mouseEnabled = false;
         this._header.text = !!param2 ? param2 : "";
         this._header.textColor = this._textColor;
         param1.locale.fixTextFieldFormat(this._header);
      }
   }
}
