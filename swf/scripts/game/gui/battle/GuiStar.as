package game.gui.battle
{
   import com.stoicstudio.platform.PlatformInput;
   import engine.gui.GuiUtil;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   
   public class GuiStar extends GuiBase implements IGuiSelectable
   {
      
      private static const FRAME_UNSELECTED:int = 7;
      
      private static const FRAME_SELECTED:int = 8;
      
      private static const FRAME_END:int = 15;
       
      
      private var _showing:Boolean;
      
      private var _selected:Boolean;
      
      private var _enabled:Boolean;
      
      private var _listener:IGuiSelectableListener;
      
      private var stars:Vector.<MovieClip>;
      
      private var _clickable:Boolean;
      
      private var _star_glow:MovieClip;
      
      private var _rolledOver:Boolean;
      
      public function GuiStar()
      {
         this.stars = new Vector.<MovieClip>();
         super();
         this.visible = false;
         this.stop();
         if(PlatformInput.hasClicker)
         {
            this.scaleX = this.scaleY = 0.5;
         }
         this._star_glow = getChildByName("star_glow") as MovieClip;
         this._star_glow.mouseChildren = this._star_glow.mouseEnabled = false;
         this.rolledOver = false;
      }
      
      public function cleanup() : void
      {
         removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
         super.cleanupGuiBase();
      }
      
      public function get clickable() : Boolean
      {
         return this._clickable;
      }
      
      public function set clickable(param1:Boolean) : void
      {
         if(param1 == this._clickable)
         {
            return;
         }
         this._clickable = param1;
         if(PlatformInput.hasClicker)
         {
            if(this._clickable)
            {
               scaleX = scaleY = 1;
            }
            else
            {
               this.scaleX = this.scaleY = 0.5;
            }
         }
      }
      
      public function init(param1:IGuiContext, param2:IGuiSelectableListener) : void
      {
         initGuiBase(param1);
         this._listener = param2;
         addFrameScript(FRAME_UNSELECTED - 1,this.onFrameUnselectedHandler);
         addFrameScript(FRAME_SELECTED - 1,this.onFrameSelectedHandler);
         addFrameScript(FRAME_END - 1,this.onFrameEndHandler);
      }
      
      private function mouseDownHandler(param1:MouseEvent) : void
      {
         if(!this._enabled)
         {
            return;
         }
         this.selected = !this._selected;
      }
      
      private function onFrameSelectedHandler() : void
      {
      }
      
      private function onFrameEndHandler() : void
      {
         if(!this._selected)
         {
            gotoAndStop(FRAME_UNSELECTED);
         }
         else
         {
            gotoAndStop(FRAME_END);
         }
      }
      
      private function onFrameUnselectedHandler() : void
      {
         if(!this._selected)
         {
            gotoAndStop(FRAME_UNSELECTED);
         }
      }
      
      public function get rolledOver() : Boolean
      {
         return this._rolledOver;
      }
      
      public function set rolledOver(param1:Boolean) : void
      {
         this._rolledOver = param1;
         if(this._star_glow)
         {
            this._star_glow.visible = this._rolledOver && this._clickable;
         }
      }
      
      private function rollOverHandler(param1:MouseEvent) : void
      {
         this.rolledOver = true;
      }
      
      private function rollOutHandler(param1:MouseEvent) : void
      {
         this.rolledOver = false;
      }
      
      public function setShowing(param1:Boolean, param2:Boolean) : void
      {
         if(param1 == this._showing)
         {
            return;
         }
         this._showing = param1;
         visible = param1;
         if(!this._showing)
         {
            removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
            removeEventListener(MouseEvent.ROLL_OVER,this.rollOverHandler);
            removeEventListener(MouseEvent.ROLL_OUT,this.rollOutHandler);
            this.rollOutHandler(null);
            stop();
         }
         else
         {
            addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
            addEventListener(MouseEvent.ROLL_OVER,this.rollOverHandler);
            addEventListener(MouseEvent.ROLL_OUT,this.rollOutHandler);
            gotoAndStop(1);
            if(param2)
            {
               GuiUtil.playStopOnFrame(this,FRAME_SELECTED,null);
            }
            else
            {
               GuiUtil.playStopOnFrame(this,FRAME_UNSELECTED,null);
            }
         }
      }
      
      private function checkRenderStates() : void
      {
         if(!this._showing)
         {
            visible = false;
            stop();
            return;
         }
         visible = true;
         if(!movieClip.isPlaying)
         {
            if(!this._selected)
            {
               if(currentFrame > FRAME_UNSELECTED)
               {
                  gotoAndStop(FRAME_UNSELECTED);
               }
            }
            else if(currentFrame < FRAME_END)
            {
               GuiUtil.playStopOnLastFrame(this,null);
            }
         }
         else if(!this._selected)
         {
            if(currentFrame == FRAME_UNSELECTED)
            {
               stop();
            }
         }
         else if(currentFrame == FRAME_END)
         {
            stop();
         }
      }
      
      public function set selected(param1:Boolean) : void
      {
         if(this._selected == param1)
         {
            return;
         }
         this._selected = param1;
         this.checkRenderStates();
         if(this._listener)
         {
            this._listener.guiSelectableSelected(this);
         }
      }
      
      public function get selected() : Boolean
      {
         return this._selected;
      }
   }
}
