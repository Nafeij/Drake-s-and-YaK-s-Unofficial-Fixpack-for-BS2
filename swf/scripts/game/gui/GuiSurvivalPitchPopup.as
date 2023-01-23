package game.gui
{
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.KeyBinder;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleCategory;
   import engine.gui.GuiContextEvent;
   import flash.events.Event;
   import flash.text.TextField;
   import flash.ui.Keyboard;
   
   public class GuiSurvivalPitchPopup extends GuiBase implements IGuiSurvivalPitchPopup
   {
       
      
      private var _button$accept:ButtonWithIndex;
      
      private var _button$decline:ButtonWithIndex;
      
      private var _button$restore:ButtonWithIndex;
      
      private var _text$ss_dlc_pitch:TextField;
      
      private var _text_price:TextField;
      
      private var _isAccepted:Boolean;
      
      private var _isRestore:Boolean;
      
      private var gplayer:int;
      
      private var cmd_accept:Cmd;
      
      private var cmd_decline:Cmd;
      
      private var cmd_restore:Cmd;
      
      public function GuiSurvivalPitchPopup()
      {
         this.cmd_accept = new Cmd("survival_pitch_accept",this.func_cmd_accept);
         this.cmd_decline = new Cmd("survival_pitch_accept",this.func_cmd_decline);
         this.cmd_restore = new Cmd("survival_pitch_restore",this.func_cmd_restore);
         super();
         super.visible = false;
         this._button$accept = requireGuiChild("button$accept") as ButtonWithIndex;
         this._button$decline = requireGuiChild("button$decline") as ButtonWithIndex;
         this._button$restore = requireGuiChild("button$restore") as ButtonWithIndex;
         this._button$restore.enabled = GuiSagaOptionsConfig.ENABLE_DLC_RESTORE;
         this._button$restore.visible = GuiSagaOptionsConfig.ENABLE_DLC_RESTORE;
         this._text$ss_dlc_pitch = requireGuiChild("text$ss_dlc_pitch") as TextField;
         this._text_price = requireGuiChild("text_price") as TextField;
         this._text_price.htmlText = "";
      }
      
      public function init(param1:IGuiContext) : void
      {
         super.initGuiBase(param1);
         registerScalableTextfield2d(this._text$ss_dlc_pitch,false);
         this._button$accept.guiButtonContext = _context;
         this._button$decline.guiButtonContext = _context;
         this._button$restore.guiButtonContext = _context;
         this._button$accept.setDownFunction(this.buttonAcceptHandler);
         this._button$decline.setDownFunction(this.buttonDeclineHandler);
         this._button$restore.setDownFunction(this.buttonRestoreHandler);
         _context.addEventListener(GuiContextEvent.LOCALE,this.localeHandler);
         this.localeHandler(null);
      }
      
      private function localeHandler(param1:GuiContextEvent) : void
      {
         var _loc2_:Locale = _context.locale;
         _loc2_.translateDisplayObjects(LocaleCategory.GUI,this,_context.logger);
         super.scaleTextfields();
      }
      
      override public function set visible(param1:Boolean) : void
      {
         if(super.visible == param1)
         {
            return;
         }
         super.visible = param1;
         if(param1)
         {
            this.gplayer = GpBinder.gpbinder.createLayer("GuiSurvivalPitchPopup");
            KeyBinder.keybinder.bind(false,false,false,Keyboard.ENTER,this.cmd_accept,"");
            KeyBinder.keybinder.bind(false,false,false,Keyboard.SPACE,this.cmd_accept,"");
            KeyBinder.keybinder.bind(false,false,false,Keyboard.ESCAPE,this.cmd_decline,"");
            GpBinder.gpbinder.bindPress(GpControlButton.A,this.cmd_accept);
            GpBinder.gpbinder.bindPress(GpControlButton.B,this.cmd_decline);
         }
         else
         {
            GpBinder.gpbinder.removeLayer(this.gplayer);
            KeyBinder.keybinder.unbind(this.cmd_accept);
            KeyBinder.keybinder.unbind(this.cmd_decline);
            GpBinder.gpbinder.unbind(this.cmd_accept);
            GpBinder.gpbinder.unbind(this.cmd_decline);
         }
      }
      
      public function cleanup() : void
      {
         GpBinder.gpbinder.removeLayer(this.gplayer);
         this._button$accept.cleanup();
         this._button$accept = null;
         this._button$decline.cleanup();
         this._button$decline = null;
         this._button$restore.cleanup();
         this._button$restore = null;
         if(_context)
         {
            _context.removeEventListener(GuiContextEvent.LOCALE,this.localeHandler);
         }
         super.cleanupGuiBase();
      }
      
      public function set priceString(param1:String) : void
      {
         this._text_price.htmlText = param1;
      }
      
      public function get isAccepted() : Boolean
      {
         return this._isAccepted;
      }
      
      public function get isRestore() : Boolean
      {
         return this._isRestore;
      }
      
      private function buttonAcceptHandler(param1:*) : void
      {
         this._isAccepted = true;
         this._isRestore = false;
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      private function buttonDeclineHandler(param1:*) : void
      {
         this._isAccepted = false;
         this._isRestore = false;
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      private function buttonRestoreHandler(param1:*) : void
      {
         this._isAccepted = false;
         this._isRestore = true;
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      private function func_cmd_accept(param1:CmdExec) : void
      {
         this._button$accept.press();
      }
      
      private function func_cmd_decline(param1:CmdExec) : void
      {
         this._button$decline.press();
      }
      
      private function func_cmd_restore(param1:CmdExec) : void
      {
         this._button$restore.press();
      }
   }
}
