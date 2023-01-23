package game.gui.pages
{
   import flash.text.TextField;
   import game.gui.IGuiContext;
   
   public class GuiCreditsSection1 extends GuiCreditsSectionBase
   {
       
      
      public var _body1:TextField;
      
      public function GuiCreditsSection1()
      {
         super();
      }
      
      override public function cleanup() : void
      {
      }
      
      override public function set textColor(param1:uint) : void
      {
         super.textColor = param1;
         if(this._body1)
         {
            this._body1.textColor = _textColor;
         }
      }
      
      public function init(param1:IGuiContext, param2:String, param3:String) : void
      {
         super.initSectionBase(param1,param2);
         this._body1 = requireGuiChild("body1") as TextField;
         this._body1.mouseEnabled = false;
         this._body1.text = param3;
         this._body1.textColor = _textColor;
         param1.locale.fixTextFieldFormat(this._body1);
         this._body1.height = Math.ceil(this._body1.textHeight + 10);
         this.cacheAsBitmap = true;
      }
   }
}
