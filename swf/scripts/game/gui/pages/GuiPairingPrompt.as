package game.gui.pages
{
   import engine.core.locale.LocaleCategory;
   import flash.text.TextField;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   import game.gui.page.IGuiPairingPrompt;
   import game.gui.page.IGuiSagaPairingPromptListener;
   
   public class GuiPairingPrompt extends GuiBase implements IGuiPairingPrompt
   {
       
      
      public var listener:IGuiSagaPairingPromptListener;
      
      public var _text_prompt:TextField;
      
      private var xDel:Number = 10;
      
      private var yDel:Number = 20;
      
      private var xMin:Number = 0;
      
      private var yMin:Number = 0;
      
      private var xMax:Number = 2000;
      
      private var yMax:Number = 2000;
      
      public function GuiPairingPrompt()
      {
         stop();
         super();
      }
      
      public function cleanup() : void
      {
      }
      
      public function init(param1:IGuiContext, param2:IGuiSagaPairingPromptListener) : void
      {
         super.initGuiBase(param1,true);
         this.listener = param2;
         _context.logger.info("Initting the pairing prompt gui");
         this._text_prompt = requireGuiChild("text_prompt") as TextField;
         this._text_prompt.parent.x = 82;
         this._text_prompt.parent.y += 207;
         this._text_prompt.y = 870;
         this.updatePrompt();
      }
      
      override public function handleLocaleChange() : void
      {
         super.handleLocaleChange();
         this.updatePrompt();
      }
      
      private function updatePrompt() : void
      {
         var _loc1_:String = String(context.translateCategory("prompt",LocaleCategory.PLATFORM));
         context.locale.updateDisplayObjectTranslation(this._text_prompt,_loc1_,null,0);
      }
   }
}
