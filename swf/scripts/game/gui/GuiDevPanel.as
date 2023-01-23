package game.gui
{
   import com.greensock.TweenMax;
   import com.stoicstudio.platform.PlatformFlash;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class GuiDevPanel extends GuiBase implements IGuiDevPanel
   {
       
      
      private var _button_close:ButtonWithIndex;
      
      private var _button_console:ButtonWithIndex;
      
      private var _button_perf:ButtonWithIndex;
      
      private var _button_ff:ButtonWithIndex;
      
      private var _button_kill:ButtonWithIndex;
      
      private var _button_quicksave:ButtonWithIndex;
      
      private var _move:MovieClip;
      
      private var _showing:Boolean = false;
      
      private var _listener:IGuiDevPanelListener;
      
      private var rightDistance:Number = 0;
      
      private var _startDragMouse:Point;
      
      private var _startDragThis:Point;
      
      private var pwidth:Number;
      
      private var pheight:Number;
      
      public function GuiDevPanel()
      {
         this._startDragMouse = new Point();
         this._startDragThis = new Point();
         super();
         name = "devpanel";
         this._button_close = getChildByName("button_close") as ButtonWithIndex;
         this._button_console = getChildByName("button_console") as ButtonWithIndex;
         this._button_perf = getChildByName("button_perf") as ButtonWithIndex;
         this._button_ff = getChildByName("button_ff") as ButtonWithIndex;
         this._button_kill = getChildByName("button_kill") as ButtonWithIndex;
         this._button_quicksave = getChildByName("button_quicksave") as ButtonWithIndex;
         this._move = getChildByName("move") as MovieClip;
         this._button_console.buttonText = "~";
         this._button_perf.buttonText = "fps";
         this._button_ff.buttonText = ">>";
         this._button_kill.buttonText = "K";
         this._button_quicksave.buttonText = "qs";
         this._button_close.setDownFunction(this.button_close_downHandler);
         this._button_console.setDownFunction(this.button_console_downHandler);
         this._button_perf.setDownFunction(this.button_perf_downHandler);
         this._button_ff.setDownFunction(this.button_ff_downHandler);
         this._button_kill.setDownFunction(this.button_kill_downHandler);
         this._button_quicksave.setDownFunction(this.button_quicksave_downHandler);
         this._move.addEventListener(MouseEvent.MOUSE_DOWN,this.moveMouseDownHandler);
         this.updateShowing(true);
      }
      
      public function init(param1:IGuiContext, param2:IGuiDevPanelListener) : void
      {
         this._button_close.guiButtonContext = param1;
         this._button_console.guiButtonContext = param1;
         this._button_perf.guiButtonContext = param1;
         this._button_ff.guiButtonContext = param1;
         this._button_kill.guiButtonContext = param1;
         this._button_quicksave.guiButtonContext = param1;
         this._listener = param2;
      }
      
      public function cleanup() : void
      {
         this._move.removeEventListener(MouseEvent.MOUSE_DOWN,this.moveMouseDownHandler);
         this._button_close.cleanup();
         this._button_console.cleanup();
         this._button_perf.cleanup();
         this._button_ff.cleanup();
         this._button_kill.cleanup();
         this._button_quicksave.cleanup();
      }
      
      private function button_close_downHandler(param1:*) : void
      {
         this._showing = !this._showing;
         this.updateShowing(false);
      }
      
      private function updateShowing(param1:Boolean) : void
      {
         this._move.visible = this._button_console.visible = this._button_ff.visible = this._button_perf.visible = this._button_kill.visible = this._button_quicksave.visible = this._showing;
         var _loc2_:Number = 0;
         if(!this._showing)
         {
            _loc2_ = 45;
         }
         if(param1)
         {
            this._button_close.rotation = _loc2_;
         }
         else
         {
            TweenMax.to(this._button_close,0.2,{"rotation":_loc2_});
         }
      }
      
      private function button_console_downHandler(param1:*) : void
      {
         this._listener.guiDevPanelHandleConsole();
      }
      
      private function button_perf_downHandler(param1:*) : void
      {
         this._listener.guiDevPanelHandlePerf();
      }
      
      private function button_ff_downHandler(param1:*) : void
      {
         this._listener.guiDevPanelHandleFf();
      }
      
      private function button_quicksave_downHandler(param1:*) : void
      {
         this._listener.guiDevPanelHandleQuicksave();
      }
      
      private function button_kill_downHandler(param1:*) : void
      {
         this._listener.guiDevPanelHandleKill();
      }
      
      private function moveMouseDownHandler(param1:MouseEvent) : void
      {
         PlatformFlash.stage.addEventListener(MouseEvent.MOUSE_MOVE,this.stageMouseMoveHandler);
         PlatformFlash.stage.addEventListener(MouseEvent.MOUSE_UP,this.stageMouseUpHandler);
         this.addEventListener(MouseEvent.MOUSE_MOVE,this.stageMouseMoveHandler);
         this.addEventListener(MouseEvent.MOUSE_UP,this.stageMouseUpHandler);
         this._startDragMouse.setTo(param1.stageX,param1.stageY);
         this._startDragThis.setTo(x,y);
      }
      
      private function stageMouseMoveHandler(param1:MouseEvent) : void
      {
         var _loc3_:Number = NaN;
         var _loc2_:Number = param1.stageX - this._startDragMouse.x;
         _loc3_ = param1.stageY - this._startDragMouse.y;
         this.clampPosition();
         this.x = this._startDragThis.x + _loc2_;
         this.y = this._startDragThis.y + _loc3_;
         this.clampPosition();
      }
      
      private function stageMouseUpHandler(param1:MouseEvent) : void
      {
         PlatformFlash.stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.stageMouseMoveHandler);
         PlatformFlash.stage.removeEventListener(MouseEvent.MOUSE_UP,this.stageMouseUpHandler);
         this.removeEventListener(MouseEvent.MOUSE_MOVE,this.stageMouseMoveHandler);
         this.removeEventListener(MouseEvent.MOUSE_UP,this.stageMouseUpHandler);
      }
      
      private function clampPosition() : void
      {
         var _loc3_:Number = NaN;
         var _loc1_:Number = this.pwidth;
         var _loc2_:Number = width;
         _loc3_ = this.pheight - height;
         var _loc4_:Number = 0;
         this.x = Math.max(_loc2_,Math.min(_loc1_,this.x));
         this.y = Math.max(_loc4_,Math.min(_loc3_,this.y));
         this.rightDistance = this.pwidth - this.x;
      }
      
      public function resizeHandler(param1:Number, param2:Number) : void
      {
         this.pwidth = param1;
         this.pheight = param2;
         this.x = param1 - this.rightDistance;
         this.clampPosition();
      }
   }
}
