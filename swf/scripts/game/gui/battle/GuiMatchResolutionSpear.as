package game.gui.battle
{
   import flash.text.TextField;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   
   public class GuiMatchResolutionSpear extends GuiBase
   {
       
      
      public var _textLabel:TextField;
      
      public var _textValue:TextField;
      
      public function GuiMatchResolutionSpear()
      {
         super();
         mouseChildren = mouseEnabled = false;
         this._textLabel = getChildByName("textLabel") as TextField;
         this._textValue = getChildByName("textValue") as TextField;
      }
      
      public function init(param1:IGuiContext, param2:String) : void
      {
         super.initGuiBase(param1);
         this._textLabel.htmlText = param1.translate(param2);
         this.setTextValue(null);
         registerScalableTextfield(this._textLabel);
         registerScalableTextfield(this._textValue);
      }
      
      public function setTextValue(param1:String) : void
      {
         if(!this._textValue)
         {
            return;
         }
         if(param1)
         {
            this._textValue.text = param1;
            this._textValue.visible = true;
         }
         else
         {
            this._textValue.visible = false;
            this._textValue.text = "";
         }
         this.handleLocaleChange();
      }
      
      override public function handleLocaleChange() : void
      {
         super.handleLocaleChange();
         _context.locale.fixTextFieldFormat(this._textLabel,null,null,true);
         _context.locale.fixTextFieldFormat(this._textValue,null,null,true);
         scaleTextfields();
      }
      
      public function imposeRightBoundary(param1:Number) : void
      {
         changeScaleableWidth(this._textLabel,param1 - this._textLabel.x);
         this.handleLocaleChange();
      }
   }
}
