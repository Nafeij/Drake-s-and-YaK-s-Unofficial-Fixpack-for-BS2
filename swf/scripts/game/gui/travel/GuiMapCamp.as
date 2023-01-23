package game.gui.travel
{
   import com.stoicstudio.platform.PlatformInput;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpBitmap;
   import flash.events.Event;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   
   public class GuiMapCamp extends GuiBase implements IGuiMapCamp
   {
       
      
      private var listener:IGuiMapCampListener;
      
      public var _buttonExit:ButtonWithIndex;
      
      private var cmd_close:Cmd;
      
      private var gp_y:GuiGpBitmap;
      
      private var _guiMapCampEnabled:Boolean = true;
      
      public function GuiMapCamp()
      {
         this.cmd_close = new Cmd("guimapcamp_cmd_close",this.func_cmd_close);
         this.gp_y = GuiGp.ctorPrimaryBitmap(GpControlButton.B);
         super();
         name = "GuiMapCamp";
      }
      
      private function func_cmd_close(param1:CmdExec) : void
      {
         if(this._buttonExit)
         {
            this._buttonExit.press();
         }
      }
      
      public function init(param1:IGuiContext, param2:IGuiMapCampListener) : void
      {
         super.initGuiBase(param1);
         this._buttonExit = requireGuiChild("buttonExit") as ButtonWithIndex;
         this.listener = param2;
         this._buttonExit.guiButtonContext = param1;
         this._buttonExit.setDownFunction(this.buttonExitHandler);
         this._buttonExit.addEventListener(ButtonWithIndex.EVENT_STATE,this.buttonExitRolloverHandler);
         this.checkGuiVisibility();
         GpBinder.gpbinder.bindPress(GpControlButton.B,this.cmd_close);
         addChild(this.gp_y);
         PlatformInput.dispatcher.addEventListener(PlatformInput.EVENT_LAST_INPUT,this.lastInputHandler);
         PlatformInput.dispatcher.addEventListener(PlatformInput.EVENT_CURSOR_CANCEL_PRESS,this.handleCursorCancel);
      }
      
      private function handleCursorCancel(param1:Event) : void
      {
         if(this._buttonExit)
         {
            this._buttonExit.press();
         }
      }
      
      public function cleanup() : void
      {
         PlatformInput.dispatcher.removeEventListener(PlatformInput.EVENT_CURSOR_CANCEL_PRESS,this.handleCursorCancel);
         PlatformInput.dispatcher.removeEventListener(PlatformInput.EVENT_LAST_INPUT,this.lastInputHandler);
         GuiGp.releasePrimaryBitmap(this.gp_y);
         GpBinder.gpbinder.unbind(this.cmd_close);
         this.cmd_close.cleanup();
         this.listener = null;
         this._buttonExit.setDownFunction(null);
         this._buttonExit.removeEventListener(ButtonWithIndex.EVENT_STATE,this.buttonExitRolloverHandler);
         this._buttonExit = null;
      }
      
      private function buttonExitRolloverHandler(param1:Event) : void
      {
         this.listener.guiMapCampHoverExit();
      }
      
      public function get guiMapCampHoverExit() : Boolean
      {
         return this._buttonExit.isHovering;
      }
      
      private function buttonExitHandler(param1:Object) : void
      {
         this.listener.guiMapCampExit();
      }
      
      public function set guiMapCampEnabled(param1:Boolean) : void
      {
         this._guiMapCampEnabled = param1;
         this.cmd_close.enabled = param1;
         this.checkGuiVisibility();
      }
      
      private function checkGuiVisibility() : void
      {
         if(this._buttonExit)
         {
            this._buttonExit.visible = PlatformInput.hasClicker && !PlatformInput.lastInputGp && this._guiMapCampEnabled;
            this.gp_y.visible = this._buttonExit.visible;
            if(this.gp_y.visible)
            {
               GuiGp.placeIconRight(this._buttonExit,this.gp_y);
            }
         }
      }
      
      public function get guiMapCampEnabled() : Boolean
      {
         return this._guiMapCampEnabled;
      }
      
      private function lastInputHandler(param1:Event) : void
      {
         this.checkGuiVisibility();
      }
   }
}
