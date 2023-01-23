package game.view
{
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.KeyBinder;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.render.Screenshot;
   import engine.gui.core.GuiSprite;
   import flash.display.DisplayObject;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.ui.Keyboard;
   import game.gui.IGuiDialog;
   
   public class DialogLayer extends GuiSprite implements IDialogLayer
   {
       
      
      private var _dialog:IGuiDialog;
      
      private var cmd_gp_cancel:Cmd;
      
      private var cmd_esc:Cmd;
      
      private var cmd_ok:Cmd;
      
      public var keybinder:KeyBinder;
      
      public var gpbinder:GpBinder;
      
      private var _removingDialog:IGuiDialog;
      
      private var _addingDialog:IGuiDialog;
      
      private var gplayer:int = -1;
      
      private var wasScreenshotVisible:Boolean;
      
      public function DialogLayer()
      {
         this.cmd_gp_cancel = new Cmd("cmd_gp_cancel_dialog",this.cmdfunc_gp_cancel);
         this.cmd_esc = new Cmd("cmd_esc_dialog",this.cmdfunc_esc);
         this.cmd_ok = new Cmd("cmd_ok_dialog",this.cmdfunc_ok);
         super();
         name = "dialogs";
         debugRender = 2852126720;
         anchor.percentHeight = 100;
         anchor.percentWidth = 100;
      }
      
      public function cmdfunc_esc(param1:CmdExec) : void
      {
         var _loc2_:IGuiDialog = null;
         if(this._dialog)
         {
            _loc2_ = this._dialog;
            _loc2_.pressEscape();
         }
      }
      
      public function cmdfunc_gp_cancel(param1:CmdExec) : void
      {
         var _loc2_:IGuiDialog = null;
         if(this._dialog)
         {
            _loc2_ = this._dialog;
            _loc2_.pressCancel();
         }
      }
      
      public function cmdfunc_ok(param1:CmdExec) : void
      {
         var _loc2_:IGuiDialog = null;
         if(this._dialog)
         {
            _loc2_ = this._dialog;
            _loc2_.pressOk();
         }
      }
      
      public function get isShowingDialog() : Boolean
      {
         return this._dialog != null;
      }
      
      public function addDialog(param1:IGuiDialog) : void
      {
         var value:IGuiDialog = param1;
         if(this._removingDialog)
         {
            throw new IllegalOperationError("Cannot add a dialog (" + value + ") while another is being removed (" + this._removingDialog + ")");
         }
         if(this._addingDialog)
         {
            throw new IllegalOperationError("Cannot add a dialog (" + value + ") while another is being added (" + this._addingDialog + ")");
         }
         try
         {
            this._addingDialog = value;
            this.dialog = value;
            this._addingDialog = null;
         }
         catch(e:Error)
         {
            _addingDialog = null;
            throw e;
         }
      }
      
      public function clearDialogs() : void
      {
         this.dialog = null;
      }
      
      public function removeDialog(param1:IGuiDialog) : void
      {
         var value:IGuiDialog = param1;
         if(this._removingDialog)
         {
            throw new IllegalOperationError("Cannot remove a dialog (" + value + ") while another is being removed (" + this._removingDialog + ")");
         }
         if(this._addingDialog)
         {
            throw new IllegalOperationError("Cannot remove a dialog (" + value + ") while another is being added (" + this._addingDialog + ")");
         }
         if(this._removingDialog)
         {
            return;
         }
         if(this._dialog == value)
         {
            try
            {
               this._removingDialog = value;
               this.dialog = null;
               this._removingDialog = null;
            }
            catch(e:Error)
            {
               _removingDialog = null;
               throw e;
            }
         }
      }
      
      public function get dialog() : IGuiDialog
      {
         return this._dialog;
      }
      
      public function set dialog(param1:IGuiDialog) : void
      {
         var _loc3_:DisplayObject = null;
         if(param1 == this._dialog)
         {
            return;
         }
         this.bringToFront();
         var _loc2_:IGuiDialog = this._dialog;
         this._dialog = null;
         if(_loc2_)
         {
            _loc3_ = _loc2_ as DisplayObject;
            _loc2_.notifyClosed(null);
            if(_loc3_.parent == this)
            {
               removeChild(_loc3_);
            }
         }
         this._dialog = param1;
         if(this._dialog)
         {
            _loc3_ = this._dialog as DisplayObject;
            if(!_loc3_)
            {
               throw ArgumentError("uuuuu");
            }
            addChild(_loc3_);
            if(this.keybinder)
            {
               this.keybinder.bind(false,false,false,Keyboard.ESCAPE,this.cmd_esc,"");
               this.keybinder.bind(false,false,false,Keyboard.BACK,this.cmd_esc,"");
               this.keybinder.bind(false,false,false,Keyboard.SPACE,this.cmd_ok,"");
               this.keybinder.bind(false,false,false,Keyboard.ENTER,this.cmd_ok,"");
            }
            if(this.gpbinder)
            {
               if(this.gplayer)
               {
                  this.gpbinder.removeLayer(this.gplayer);
               }
               this.gplayer = this.gpbinder.createLayer("DialogLayer");
               this.gpbinder.bindPress(GpControlButton.B,this.cmd_gp_cancel,"dialog");
               this.gpbinder.bindPress(GpControlButton.A,this.cmd_ok,"dialog");
            }
         }
         else
         {
            if(this.keybinder)
            {
               this.keybinder.unbind(this.cmd_esc);
               this.keybinder.unbind(this.cmd_ok);
            }
            if(this.gpbinder)
            {
               this.gpbinder.removeLayer(this.gplayer);
               this.gplayer = 0;
               this.gpbinder.unbind(this.cmd_gp_cancel);
               this.gpbinder.unbind(this.cmd_ok);
            }
         }
         this.checkDialog();
      }
      
      private function screenshotStartHandler(param1:Event) : void
      {
         this.wasScreenshotVisible = visible;
         super.visible = false;
      }
      
      private function screenshotEndHandler(param1:Event) : void
      {
         if(this.wasScreenshotVisible)
         {
            super.visible = true;
         }
      }
      
      private function checkDialog() : void
      {
         var _loc1_:DisplayObject = null;
         visible = this._dialog != null;
         if(this._dialog)
         {
            _loc1_ = this._dialog as DisplayObject;
            this._dialog.scaleToScreen();
            _loc1_.x = width / 2;
            _loc1_.y = height / 2;
            Screenshot.dispatcher.addEventListener(Screenshot.EVENT_START,this.screenshotStartHandler);
            Screenshot.dispatcher.addEventListener(Screenshot.EVENT_END,this.screenshotEndHandler);
         }
         else
         {
            Screenshot.dispatcher.removeEventListener(Screenshot.EVENT_START,this.screenshotStartHandler);
            Screenshot.dispatcher.removeEventListener(Screenshot.EVENT_END,this.screenshotEndHandler);
         }
      }
      
      override protected function resizeHandler() : void
      {
         super.resizeHandler();
         this.checkDialog();
      }
   }
}
