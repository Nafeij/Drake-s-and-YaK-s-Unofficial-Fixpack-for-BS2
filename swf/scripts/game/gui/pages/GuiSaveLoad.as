package game.gui.pages
{
   import com.stoicstudio.platform.PlatformFlash;
   import com.stoicstudio.platform.PlatformInput;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.gp.GpSource;
   import engine.core.util.ArrayUtil;
   import engine.core.util.StringUtil;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpBitmap;
   import engine.gui.GuiGpNav;
   import engine.saga.save.SagaSave;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.GuiChitsGroup;
   import game.gui.IGuiContext;
   import game.gui.page.IGuiSaveLoad;
   import game.gui.page.IGuiSaveLoadListener;
   
   public class GuiSaveLoad extends GuiBase implements IGuiSaveLoad
   {
       
      
      public var buttons:Vector.<GuiSaveLoadButton>;
      
      public var deleteButtons:Vector.<ButtonWithIndex>;
      
      public var listener:IGuiSaveLoadListener;
      
      public var _button_close:ButtonWithIndex;
      
      public var _chits:GuiChitsGroup;
      
      public var _buttonPrev:ButtonWithIndex;
      
      public var _buttonNext:ButtonWithIndex;
      
      public var nav:GuiGpNav;
      
      public var _iconClose:GuiGpBitmap;
      
      public var _iconPrev:GuiGpBitmap;
      
      public var _iconNext:GuiGpBitmap;
      
      private var cmd_next:Cmd;
      
      private var cmd_prev:Cmd;
      
      private var scroller:MovieClip;
      
      private var _yScroller:int;
      
      private var _rowHeight:int;
      
      private var _sss:Array;
      
      private var _restartBmpd:BitmapData;
      
      private var _ptDown:Point;
      
      private var isMouseDown:Boolean;
      
      public function GuiSaveLoad()
      {
         var _loc2_:DisplayObject = null;
         var _loc3_:GuiSaveLoadButton = null;
         var _loc4_:ButtonWithIndex = null;
         this.buttons = new Vector.<GuiSaveLoadButton>();
         this.deleteButtons = new Vector.<ButtonWithIndex>();
         this._iconClose = GuiGp.ctorPrimaryBitmap(GpControlButton.B);
         this._iconPrev = GuiGp.ctorPrimaryBitmap(GpControlButton.L1,true);
         this._iconNext = GuiGp.ctorPrimaryBitmap(GpControlButton.R1,true);
         this.cmd_next = new Cmd("savload_next",this.cmdGpNext);
         this.cmd_prev = new Cmd("savload_prev",this.cmdGpPrev);
         this._ptDown = new Point();
         super();
         super.visible = false;
         this.scroller = getChildByName("scroller") as MovieClip;
         this._yScroller = this.scroller.y;
         var _loc1_:int = 0;
         while(_loc1_ < this.scroller.numChildren)
         {
            _loc2_ = this.scroller.getChildAt(_loc1_);
            _loc3_ = _loc2_ as GuiSaveLoadButton;
            if(_loc3_)
            {
               this.buttons.push(_loc3_);
               if(this.buttons.length == 1)
               {
                  this._rowHeight = _loc2_.y;
               }
               else if(this.buttons.length == 2)
               {
                  this._rowHeight = _loc2_.y - this._rowHeight;
               }
            }
            else
            {
               _loc4_ = _loc2_ as ButtonWithIndex;
               if(_loc4_)
               {
                  if(StringUtil.startsWith(_loc4_.name,"delete"))
                  {
                     _loc4_.index = this.deleteButtons.length;
                     this.deleteButtons.push(_loc4_);
                  }
               }
            }
            _loc1_++;
         }
         if(this.buttons.length == 5)
         {
            ArrayUtil.removeAt(this.buttons,4).visible = false;
            ArrayUtil.removeAt(this.buttons,0).visible = false;
            ArrayUtil.removeAt(this.deleteButtons,4).visible = false;
            ArrayUtil.removeAt(this.deleteButtons,0).visible = false;
            _loc1_ = 0;
            while(_loc1_ < 3)
            {
               _loc3_ = this.buttons[_loc1_];
               _loc4_ = this.deleteButtons[_loc1_];
               _loc4_.index = _loc1_;
               _loc1_++;
            }
         }
         addChild(this._iconClose);
         addChild(this._iconNext);
         addChild(this._iconPrev);
      }
      
      public function cleanup() : void
      {
         var _loc1_:GuiSaveLoadButton = null;
         var _loc2_:ButtonWithIndex = null;
         this.visible = false;
         for each(_loc1_ in this.buttons)
         {
            _loc1_.cleanup();
         }
         for each(_loc2_ in this.deleteButtons)
         {
            _loc2_.cleanup();
         }
         this.buttons = null;
         this.deleteButtons = null;
         GuiGp.releasePrimaryBitmap(this._iconClose);
         GuiGp.releasePrimaryBitmap(this._iconNext);
         GuiGp.releasePrimaryBitmap(this._iconPrev);
         this.nav.cleanup();
      }
      
      public function clearSaves() : void
      {
         var _loc1_:GuiSaveLoadButton = null;
         _context.logger.debug("GuiSaveLoad clearSaves");
         for each(_loc1_ in this.buttons)
         {
            _loc1_.ss = null;
         }
      }
      
      public function init(param1:IGuiContext, param2:IGuiSaveLoadListener) : void
      {
         var _loc3_:GuiSaveLoadButton = null;
         var _loc4_:ButtonWithIndex = null;
         super.initGuiBase(param1);
         this.isMouseDown = false;
         this._chits = requireGuiChild("chits") as GuiChitsGroup;
         this._buttonPrev = requireGuiChild("buttonPrev") as ButtonWithIndex;
         this._buttonNext = requireGuiChild("buttonNext") as ButtonWithIndex;
         this._button_close = requireGuiChild("button_close") as ButtonWithIndex;
         this.listener = param2;
         this._chits.init(param1);
         for each(_loc3_ in this.buttons)
         {
            _loc3_.init(param1);
            _loc3_.setUpFunction(this.buttonUpHandler);
            _loc3_.setRightDownFunction(this.buttonRightDownHandler);
         }
         for each(_loc4_ in this.deleteButtons)
         {
            _loc4_.guiButtonContext = param1;
            _loc4_.setDownFunction(this.buttonDelDownHandler);
         }
         this._button_close.guiButtonContext = param1;
         this._button_close.setDownFunction(this.buttonCloseDownHandler);
         this._buttonPrev.guiButtonContext = param1;
         this._buttonNext.guiButtonContext = param1;
         this._buttonPrev.setDownFunction(this.buttonPrevHandler);
         this._buttonNext.setDownFunction(this.buttonNextHandler);
      }
      
      private function _constructNav() : void
      {
         var _loc1_:GuiSaveLoadButton = null;
         if(this.nav)
         {
            this.nav.cleanup();
            this.nav = null;
         }
         this.nav = new GuiGpNav(context,"load",this);
         this.nav.alwaysHintControls = true;
         this.nav.setCallbackNavigate(this.navHandler);
         this.nav.setAlternateButton(GpControlButton.Y,this.buttonAltHandler);
         for each(_loc1_ in this.buttons)
         {
            this.nav.add(_loc1_);
         }
      }
      
      private function navHandler(param1:int, param2:int, param3:Boolean) : Boolean
      {
         switch(param1)
         {
            case 0:
               return this.navUpHandler(param2);
            case 2:
               return this.navDownHandler(param2);
            default:
               return false;
         }
      }
      
      private function navUpHandler(param1:int) : Boolean
      {
         var _loc2_:GuiSaveLoadButton = null;
         if(param1 == 0)
         {
            this.buttonPrevHandler(null);
            if(this._chits.activeChitIndex == this._chits.numVisibleChits - 1)
            {
               if(this.buttons.length > 0)
               {
                  _loc2_ = this.buttons[this.lastSaveIndex];
                  this.nav.selected = _loc2_;
               }
            }
            else
            {
               this.nav.playSound();
            }
            return true;
         }
         return false;
      }
      
      private function navDownHandler(param1:int) : Boolean
      {
         var _loc2_:GuiSaveLoadButton = null;
         if(param1 == this.lastSaveIndex)
         {
            this.buttonNextHandler(null);
            if(this._chits.activeChitIndex == 0)
            {
               if(this.buttons.length > 0)
               {
                  _loc2_ = this.buttons[0];
                  this.nav.selected = _loc2_;
               }
            }
            else
            {
               this.nav.playSound();
            }
            return true;
         }
         return false;
      }
      
      private function buttonPrevHandler(param1:ButtonWithIndex) : void
      {
         --this._chits.activeChitIndex;
         this.renderSavesPage();
      }
      
      private function buttonNextHandler(param1:ButtonWithIndex) : void
      {
         ++this._chits.activeChitIndex;
         this.renderSavesPage();
      }
      
      private function buttonCloseDownHandler(param1:ButtonWithIndex) : void
      {
         this.listener.guiSaveLoadClose();
      }
      
      private function buttonAltHandler(param1:ButtonWithIndex) : void
      {
         this.buttonDelDownHandler(param1);
      }
      
      private function buttonDelDownHandler(param1:ButtonWithIndex) : void
      {
         var _loc2_:GuiSaveLoadButton = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:SagaSave = null;
         var _loc6_:GuiSaveLoadButton = null;
         if(param1 is GuiSaveLoadButton)
         {
            _loc2_ = param1 as GuiSaveLoadButton;
            if(Boolean(_loc2_) && Boolean(_loc2_.ss))
            {
               this.listener.guiSaveLoadDelete(_loc2_.ss,_loc2_.buttonText);
            }
         }
         else
         {
            _loc3_ = this._chits.activeChitIndex;
            _loc4_ = param1.index + _loc3_;
            _loc5_ = this._sss[_loc4_];
            _loc6_ = this.buttons[param1.index];
            if(_loc5_)
            {
               this.listener.guiSaveLoadDelete(_loc5_,_loc6_.buttonText);
            }
         }
      }
      
      private function buttonUpHandler(param1:GuiSaveLoadButton) : void
      {
         if(!visible)
         {
            return;
         }
         if(param1.ss)
         {
            this.listener.guiSaveLoadFromSave(param1.ss);
         }
         else
         {
            this.listener.guiSaveLoadFromBookmark(param1.bk);
         }
      }
      
      private function buttonRightDownHandler(param1:GuiSaveLoadButton) : void
      {
         if(!visible)
         {
            return;
         }
         if(param1.ss)
         {
            this.listener.guiSaveLoadDelete(param1.ss,param1.buttonText);
         }
      }
      
      public function setupSaves(param1:Boolean, param2:SagaSave, param3:Array, param4:BitmapData) : void
      {
         _context.logger.debug("GuiSaveLoad setupSaves");
         this._sss = param3;
         this.onOperationModeChange(null);
         this._button_close.visible = param1 && this._button_close.visible;
         this._chits.activeChitIndex = 0;
         var _loc5_:int = param3.length + 1;
         this._chits.numVisibleChits = Math.max(1,1 + _loc5_ - this.buttons.length);
         this._restartBmpd = param4;
         this.renderSavesPage();
      }
      
      private function get lastSaveIndex() : int
      {
         return this._sss.length < this.buttons.length - 1 ? this._sss.length : this.buttons.length - 1;
      }
      
      public function renderSavesPage() : void
      {
         var hasGp:Boolean;
         var offset:int;
         var oldsel:Object;
         var del:ButtonWithIndex = null;
         var i:int = 0;
         var slb:GuiSaveLoadButton = null;
         var idx:int = 0;
         var ss:SagaSave = null;
         var restartButtonIndex:int = 0;
         if(!visible)
         {
            return;
         }
         hasGp = GpSource.primaryDevice != null;
         offset = this._chits.activeChitIndex;
         oldsel = !!this.nav ? this.nav.selected : null;
         this._constructNav();
         i = 0;
         while(i < this.buttons.length)
         {
            slb = this.buttons[i];
            this.nav.setCaptionTokenControl(slb,"ctl_menu_name");
            idx = i + offset;
            del = this.deleteButtons[i];
            if(this._sss == null || idx >= this._sss.length || idx < 0)
            {
               del.visible = slb.visible = false;
            }
            else
            {
               ss = this._sss[idx];
               try
               {
                  slb.setupButton(ss);
                  del.visible = !hasGp;
                  this.nav.setShowAlt(slb,true);
                  this.nav.setCaptionTokenAlt(slb,"save_delete");
               }
               catch(e:Error)
               {
                  context.logger.error("Failed to setup save button " + i + "\n" + e.getStackTrace());
               }
            }
            i++;
         }
         if(this._chits.activeChitIndex == this._chits.numVisibleChits - 1)
         {
            if(this._sss)
            {
               restartButtonIndex = this._sss.length - offset;
               this.buttons[restartButtonIndex].setupStartButton(null,this._restartBmpd);
               del = this.deleteButtons[restartButtonIndex];
               del.visible = false;
            }
         }
         this.nav.activate();
         if(!this.nav.selected)
         {
            this.nav.selected = oldsel;
            if(!this.nav.selected)
            {
               this.nav.autoSelect();
            }
         }
         this.onOperationModeChange(null);
         this._iconClose.visible = hasGp;
         this._iconNext.visible = hasGp;
         this._iconPrev.visible = hasGp;
         GuiGp.placeIconCenter(this._button_close,this._iconClose);
         GuiGp.placeIconRight(this._buttonNext,this._iconNext);
         GuiGp.placeIconRight(this._buttonPrev,this._iconPrev);
      }
      
      override public function set visible(param1:Boolean) : void
      {
         if(super.visible != param1)
         {
            super.visible = param1;
            if(super.visible)
            {
               GpSource.dispatcher.addEventListener(GpSource.EVENT_PRIMARY_DEVICE,this.primaryDeviceHandler);
               PlatformInput.dispatcher.addEventListener(PlatformInput.EVENT_LAST_INPUT,this.onOperationModeChange);
               GpBinder.gpbinder.bindPress(GpControlButton.L1,this.cmd_prev);
               GpBinder.gpbinder.bindPress(GpControlButton.R1,this.cmd_next);
               this.addEventListener(MouseEvent.MOUSE_WHEEL,this.mouseWheelHandler);
               this.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
               PlatformFlash.stage.addEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler);
               PlatformFlash.stage.addEventListener(MouseEvent.MOUSE_MOVE,this.mouseMoveHandler2,true);
               this._iconClose.gplayer = GpBinder.gpbinder.topLayer;
               this._iconNext.gplayer = GpBinder.gpbinder.topLayer;
               this._iconPrev.gplayer = GpBinder.gpbinder.topLayer;
               this.primaryDeviceHandler(null);
               this.onOperationModeChange(null);
               this.renderSavesPage();
            }
            else
            {
               GpBinder.gpbinder.unbind(this.cmd_prev);
               GpBinder.gpbinder.unbind(this.cmd_next);
               GpSource.dispatcher.removeEventListener(GpSource.EVENT_PRIMARY_DEVICE,this.primaryDeviceHandler);
               PlatformInput.dispatcher.removeEventListener(PlatformInput.EVENT_LAST_INPUT,this.onOperationModeChange);
               this.removeEventListener(MouseEvent.MOUSE_WHEEL,this.mouseWheelHandler);
               this.removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
               PlatformFlash.stage.removeEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler);
               PlatformFlash.stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.mouseMoveHandler2,true);
               if(this.nav)
               {
                  this.nav.cleanup();
                  this.nav = null;
               }
            }
         }
      }
      
      private function mouseWheelHandler(param1:MouseEvent) : void
      {
         var _loc2_:int = param1.delta;
         if(_loc2_ > 0)
         {
            this._buttonPrev.press();
         }
         else if(_loc2_ < 0)
         {
            this._buttonNext.press();
         }
      }
      
      private function mouseDownHandler(param1:MouseEvent) : void
      {
         this._ptDown.setTo(mouseX,mouseY);
         this.isMouseDown = true;
      }
      
      private function mouseUpHandler(param1:MouseEvent) : void
      {
         this.isMouseDown = false;
      }
      
      private function mouseMoveHandler2(param1:MouseEvent) : void
      {
         if(!this.isMouseDown)
         {
            return;
         }
      }
      
      private function primaryDeviceHandler(param1:Event) : void
      {
         this.renderSavesPage();
      }
      
      public function cmdGpNext(param1:CmdExec) : void
      {
         if(!visible)
         {
            return;
         }
         this._buttonNext.press();
      }
      
      public function cmdGpPrev(param1:CmdExec) : void
      {
         if(!visible)
         {
            return;
         }
         this._buttonPrev.press();
      }
      
      private function onOperationModeChange(param1:Event) : void
      {
         this._button_close.visible = PlatformInput.hasClicker || !PlatformInput.lastInputGp;
      }
      
      public function ensureTopGp() : void
      {
         if(this.nav)
         {
            this.nav.reactivate();
         }
      }
   }
}
