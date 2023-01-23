package game.gui.battle
{
   import com.stoicstudio.platform.PlatformInput;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   
   public class GuiMovePopup extends GuiBase implements IGuiMovePopup
   {
       
      
      private var icon:ButtonWithIndex;
      
      private var listener:IGuiMovePopupListener;
      
      public var _starsContainer:GuiStarsContainer;
      
      private var _showing:Boolean;
      
      public function GuiMovePopup()
      {
         super();
         name = "assets.move_popup";
      }
      
      public function init(param1:IGuiContext, param2:IGuiMovePopupListener) : void
      {
         PlatformInput.dispatcher.addEventListener(PlatformInput.EVENT_LAST_INPUT,this.lastInputHandler);
         this.listener = param2;
         initGuiBase(param1);
         this._starsContainer = getGuiChild("starsContainer") as GuiStarsContainer;
         this._starsContainer.init(param1,null);
         stop();
         visible = false;
      }
      
      public function cleanup() : void
      {
         PlatformInput.dispatcher.removeEventListener(PlatformInput.EVENT_LAST_INPUT,this.lastInputHandler);
         this.listener = null;
         if(this._starsContainer)
         {
            this._starsContainer.cleanup();
            this._starsContainer = null;
         }
         super.cleanupGuiBase();
      }
      
      private function lastInputHandler(param1:Event) : void
      {
         visible = this._showing && !PlatformInput.lastInputGp;
      }
      
      private function mouseOverHandler(param1:MouseEvent) : void
      {
         if(visible)
         {
            if(this.listener)
            {
               this.listener.guiMovePopupOver();
            }
         }
      }
      
      private function iconButtonClicked(param1:ButtonWithIndex) : void
      {
         if(this.listener)
         {
            this.listener.guiMovePopupExecute();
         }
      }
      
      private function animationFrameChanged(param1:Event) : void
      {
         this.icon = getChildByName("move_icon") as ButtonWithIndex;
         if(this.icon)
         {
            this.icon.guiButtonContext = _context;
            this.icon.setDownFunction(this.iconButtonClicked);
            removeEventListener(Event.EXIT_FRAME,this.animationFrameChanged);
         }
      }
      
      public function show(param1:int) : void
      {
         this._showing = true;
         visible = this._showing && !PlatformInput.lastInputGp;
         play();
         this._starsContainer.showing(param1);
         addEventListener(Event.EXIT_FRAME,this.animationFrameChanged);
         addEventListener(MouseEvent.MOUSE_OVER,this.mouseOverHandler);
      }
      
      public function hide() : void
      {
         this._showing = false;
         visible = false;
         gotoAndStop(1);
         this._starsContainer.restart();
         removeEventListener(Event.EXIT_FRAME,this.animationFrameChanged);
         removeEventListener(MouseEvent.MOUSE_OVER,this.mouseOverHandler);
      }
      
      public function moveTo(param1:Number, param2:Number) : void
      {
         this.x = param1;
         this.y = param2;
      }
      
      public function handleConfirm() : Boolean
      {
         if(visible && Boolean(this.listener))
         {
            this.listener.guiMovePopupExecute();
            this.hide();
            return true;
         }
         return false;
      }
   }
}
