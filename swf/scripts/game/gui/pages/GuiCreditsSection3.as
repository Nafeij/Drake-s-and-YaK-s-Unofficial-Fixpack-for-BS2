package game.gui.pages
{
   import flash.text.TextField;
   import game.gui.IGuiContext;
   
   public class GuiCreditsSection3 extends GuiCreditsSectionBase
   {
       
      
      public var _body1:TextField;
      
      public var _body2:TextField;
      
      public var _body3:TextField;
      
      public function GuiCreditsSection3()
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
         if(this._body3)
         {
            this._body3.textColor = _textColor;
         }
      }
      
      override public function cleanup() : void
      {
      }
      
      public function init(param1:IGuiContext, param2:String, param3:String, param4:String, param5:String) : void
      {
         super.initSectionBase(param1,param2);
         this._body1 = requireGuiChild("body1") as TextField;
         this._body2 = requireGuiChild("body2") as TextField;
         this._body3 = requireGuiChild("body3") as TextField;
         this._body1.mouseEnabled = false;
         this._body2.mouseEnabled = false;
         this._body3.mouseEnabled = false;
         this._body1.textColor = _textColor;
         this._body2.textColor = _textColor;
         this._body3.textColor = _textColor;
         this._body1.text = param3;
         this._body2.text = param4;
         this._body3.text = param5;
         param1.locale.fixTextFieldFormat(this._body1);
         param1.locale.fixTextFieldFormat(this._body2);
         param1.locale.fixTextFieldFormat(this._body3);
         this._body1.height = Math.ceil(this._body1.textHeight + 10);
         this._body2.height = Math.ceil(this._body2.textHeight + 10);
         this._body3.height = Math.ceil(this._body3.textHeight + 10);
         this.cacheAsBitmap = true;
      }
   }
}
