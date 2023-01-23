package game.gui.pages
{
   import engine.core.locale.Locale;
   import flash.text.TextField;
   import game.gui.IGuiContext;
   import game.gui.page.GuiCreditsSectionConfig;
   
   public class GuiCreditsSection2 extends GuiCreditsSectionBase
   {
       
      
      public var _body1:TextField;
      
      public var _body2:TextField;
      
      public var config:GuiCreditsSectionConfig;
      
      public function GuiCreditsSection2()
      {
         super();
      }
      
      override public function set textColor(param1:uint) : void
      {
         super.textColor = param1;
         if(this._body1)
         {
            this._body1.textColor = _textColor;
         }
         if(this._body2)
         {
            this._body2.textColor = _textColor;
         }
      }
      
      override public function cleanup() : void
      {
      }
      
      public function init(param1:GuiCreditsSectionConfig, param2:IGuiContext, param3:String, param4:String, param5:String) : void
      {
         super.initSectionBase(param2,param3);
         this._body1 = requireGuiChild("body1") as TextField;
         this._body2 = requireGuiChild("body2") as TextField;
         this._body1.mouseEnabled = false;
         this._body2.mouseEnabled = false;
         this.config = param1;
         this.doFormat(this._body1,0);
         this.doFormat(this._body2,1);
         this._body1.text = param4;
         this._body2.text = param5;
         this._body1.textColor = _textColor;
         this._body2.textColor = _textColor;
         var _loc6_:Locale = param2.locale;
         _loc6_.fixTextFieldFormat(this._body1);
         _loc6_.fixTextFieldFormat(this._body2);
         this._body1.height = Math.ceil(this._body1.textHeight + 10);
         this._body2.height = Math.ceil(this._body2.textHeight + 10);
         this.cacheAsBitmap = true;
      }
      
      public function doFormat(param1:TextField, param2:int) : void
      {
         var _loc3_:String = this.config.getAlign(param2);
         if(_loc3_)
         {
            param1.defaultTextFormat = duplicateTextFormat(param1,_loc3_);
         }
      }
   }
}
