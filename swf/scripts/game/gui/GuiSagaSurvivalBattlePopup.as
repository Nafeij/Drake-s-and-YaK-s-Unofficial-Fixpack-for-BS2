package game.gui
{
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.KeyBinder;
   import flash.events.Event;
   import flash.text.TextField;
   import flash.ui.Keyboard;
   
   public class GuiSagaSurvivalBattlePopup extends GuiBase implements IGuiSagaSurvivalBattlePopup
   {
       
      
      private var _text_progress:TextField;
      
      private var _text_total:TextField;
      
      private var _text_desc:TextField;
      
      private var _button$continue:ButtonWithIndex;
      
      private var cmd_space:Cmd;
      
      public function GuiSagaSurvivalBattlePopup()
      {
         this.cmd_space = new Cmd("ssbp_space",this.cmdSpaceFunc);
         super();
         this._text_progress = requireGuiChild("text_progress") as TextField;
         this._text_total = requireGuiChild("text_total") as TextField;
         this._text_desc = requireGuiChild("text_desc") as TextField;
         this._button$continue = requireGuiChild("button$continue") as ButtonWithIndex;
         this._text_progress.mouseEnabled = false;
         this._text_total.mouseEnabled = false;
         this._text_desc.mouseEnabled = false;
         this._button$continue.guiButtonContext = _context;
         this._button$continue.setDownFunction(this.buttonContinueHandler);
      }
      
      private function cmdSpaceFunc(param1:CmdExec) : void
      {
         this.buttonContinueHandler(null);
      }
      
      public function init(param1:IGuiContext, param2:String) : void
      {
         super.initGuiBase(param1);
         KeyBinder.keybinder.bind(false,false,false,Keyboard.SPACE,this.cmd_space,"");
         this._text_desc.htmlText = param2;
         var _loc3_:int = _context.saga.survivalProgress;
         _loc3_++;
         this._text_progress.text = _loc3_.toString();
         this._text_total.text = "/" + _context.saga.survivalTotal.toString();
      }
      
      private function buttonContinueHandler(param1:*) : void
      {
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      public function cleanup() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         KeyBinder.keybinder.unbind(this.cmd_space);
         this.cmd_space.cleanup();
      }
   }
}
