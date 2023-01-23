package game.gui.pages
{
   import com.greensock.TweenMax;
   import com.stoicstudio.platform.Platform;
   import engine.battle.Fastall;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpAlignH;
   import engine.gui.GuiGpAlignV;
   import engine.gui.GuiGpBitmap;
   import engine.gui.SagaNews;
   import engine.gui.SagaNewsEntry;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.GuiChitsGroup;
   import game.gui.IGuiContext;
   import game.gui.IGuiSagaNews;
   import game.gui.IGuiSagaNewsToggle;
   
   public class GuiSagaNews extends GuiBase implements IGuiSagaNews
   {
       
      
      public var news:SagaNews;
      
      public var entries:Vector.<GuiSagaNewsEntry>;
      
      public var _chits:GuiChitsGroup;
      
      public var _buttonPrev:ButtonWithIndex;
      
      public var _buttonNext:ButtonWithIndex;
      
      private var _hover:MovieClip;
      
      public var _activeEntry:GuiSagaNewsEntry;
      
      public var _placeholder:MovieClip;
      
      private var HIDE_Y:int = -240;
      
      public var _text:TextField;
      
      public var gp_l1:GuiGpBitmap;
      
      public var gp_r1:GuiGpBitmap;
      
      public var gp_x:GuiGpBitmap;
      
      private var cmd_r1:Cmd;
      
      private var cmd_l1:Cmd;
      
      private var cmd_x:Cmd;
      
      private var _newsToggle:GuiSagaNewsToggle;
      
      public var down:Boolean;
      
      private var over:Boolean;
      
      private var _hovering:Boolean;
      
      private var _isShowing:Boolean;
      
      private var _isAnimating:Boolean;
      
      public function GuiSagaNews()
      {
         this.entries = new Vector.<GuiSagaNewsEntry>();
         this.gp_l1 = GuiGp.ctorPrimaryBitmap(GpControlButton.L1,true);
         this.gp_r1 = GuiGp.ctorPrimaryBitmap(GpControlButton.R1,true);
         this.gp_x = GuiGp.ctorPrimaryBitmap(GpControlButton.X,true);
         this.cmd_r1 = new Cmd("cmd_news_r1",this.cmdfunc_r1);
         this.cmd_l1 = new Cmd("cmd_news_l1",this.cmdfunc_l1);
         this.cmd_x = new Cmd("cmd_news_x",this.cmdfunc_x);
         super();
         y = this.HIDE_Y;
         this._chits = requireGuiChild("chits") as GuiChitsGroup;
         this._buttonPrev = requireGuiChild("buttonPrev") as ButtonWithIndex;
         this._buttonNext = requireGuiChild("buttonNext") as ButtonWithIndex;
         this._placeholder = requireGuiChild("placeholder") as MovieClip;
         this._hover = requireGuiChild("hover") as MovieClip;
         this._text = requireGuiChild("text") as TextField;
         this._text.mouseEnabled = false;
         this._hover.mouseEnabled = this._hover.mouseChildren = false;
         this._chits.mouseEnabled = this._chits.mouseChildren = false;
         addChild(this.gp_x);
         addChild(this.gp_l1);
         addChild(this.gp_r1);
      }
      
      public function init(param1:IGuiContext) : void
      {
         super.initGuiBase(param1);
         this._chits.init(_context);
         this._buttonPrev.guiButtonContext = _context;
         this._buttonNext.guiButtonContext = _context;
         this._buttonPrev.setDownFunction(this.buttonPrevHandler);
         this._buttonNext.setDownFunction(this.buttonNextHandler);
         addEventListener(MouseEvent.ROLL_OVER,this.rollOverHandler);
         addEventListener(MouseEvent.ROLL_OUT,this.rollOutHandler);
         addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
         addEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler);
      }
      
      private function discardNews() : void
      {
         var _loc1_:GuiSagaNewsEntry = null;
         for each(_loc1_ in this.entries)
         {
            if(_loc1_.parent == this._placeholder)
            {
               this._placeholder.removeChild(_loc1_);
            }
            _loc1_.cleanup();
         }
         this.entries.splice(0,this.entries.length);
         this._chits.numVisibleChits = 0;
         this.visible = false;
         if(this._newsToggle)
         {
            this._newsToggle.handleNewsUpdated();
         }
      }
      
      public function setNews(param1:SagaNews) : void
      {
         var _loc2_:int = -1;
         if(this._chits.numVisibleChits)
         {
            _loc2_ = this._chits.activeChitIndex;
         }
         this.news = param1;
         this.discardNews();
         if(!param1 || !param1.entries.length)
         {
            return;
         }
         var _loc3_:String = Platform.id;
         if(param1.disabledPlatforms[_loc3_])
         {
            _context.logger.info("News Disabled on platform [" + _loc3_ + "]");
            return;
         }
         this.setupNews();
         if(_loc2_ >= 0)
         {
            this._chits.activeChitIndex = _loc2_;
            this.showActiveChit(0);
         }
         this._buttonNext.visible = this.entries.length > 1;
         this._buttonPrev.visible = this.entries.length > 1;
         this.setupGp();
      }
      
      private function setupGp() : void
      {
         GpBinder.gpbinder.unbind(this.cmd_l1);
         GpBinder.gpbinder.unbind(this.cmd_r1);
         GpBinder.gpbinder.unbind(this.cmd_x);
         GpBinder.gpbinder.bindPress(GpControlButton.X,this.cmd_x);
         GpBinder.gpbinder.bindPress(GpControlButton.L1,this.cmd_l1);
         GpBinder.gpbinder.bindPress(GpControlButton.R1,this.cmd_r1);
         GuiGp.placeIcon(this,null,this.gp_x,null,null,300,180);
         GuiGp.placeIconRight(this._buttonNext,this.gp_r1,GuiGpAlignV.C,GuiGpAlignH.E_RIGHT);
         GuiGp.placeIconLeft(this._buttonPrev,this.gp_l1,GuiGpAlignV.C,GuiGpAlignH.W_LEFT);
         this.gp_l1.visible = this.entries.length > 1 && this._isShowing && !this._isAnimating;
         this.gp_r1.visible = this.entries.length > 1 && this._isShowing && !this._isAnimating;
         this.gp_x.visible = this.entries.length > 0 && this._isShowing && !this._isAnimating;
      }
      
      private function checkUnseen() : void
      {
         var _loc1_:int = this.numUnseenEntries;
         this._newsToggle.setUnseen(_loc1_);
      }
      
      private function get numUnseenEntries() : int
      {
         var _loc2_:GuiSagaNewsEntry = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this.entries)
         {
            if(!_loc2_.entry.seen)
            {
               _loc1_++;
            }
         }
         return _loc1_;
      }
      
      private function setupNews() : void
      {
         var _loc1_:SagaNewsEntry = null;
         var _loc2_:GuiSagaNewsEntry = null;
         for each(_loc1_ in this.news.entries)
         {
            if(!_loc1_.isValidForPlatform)
            {
               _context.logger.info("GuiSagaNews Skipping news entry " + _loc1_ + " for platform " + Platform.id);
            }
            else
            {
               _loc2_ = new GuiSagaNewsEntry();
               _loc2_.init(_context,this,this.news,_loc1_);
               this.entries.push(_loc2_);
            }
         }
         this.checkUnseen();
         this._chits.numVisibleChits = this.entries.length;
         this._chits.activeChitIndex = this.findInitialIndex();
         this.showActiveChit(2);
      }
      
      private function findInitialIndex() : int
      {
         var _loc2_:GuiSagaNewsEntry = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.entries.length)
         {
            _loc2_ = this.entries[_loc1_];
            if(!_loc2_.entry.seen)
            {
               return _loc1_;
            }
            _loc1_++;
         }
         return 0;
      }
      
      private function showActiveChit(param1:Number) : void
      {
         if(!this._isShowing)
         {
            return;
         }
         if(this._chits.activeChitIndex < 0)
         {
            return;
         }
         var _loc2_:GuiSagaNewsEntry = this.entries[this._chits.activeChitIndex];
         if(this._activeEntry)
         {
            this._activeEntry.visible = false;
            if(this._activeEntry.parent == this._placeholder)
            {
               this._placeholder.removeChild(this._activeEntry);
            }
         }
         this._activeEntry = _loc2_;
         if(this._activeEntry)
         {
            this._activeEntry.entry.markSeen(this.news.prefs,null);
            this._activeEntry.visible = true;
            this._activeEntry.hovering = this._hovering;
            this._activeEntry.performLayout();
            this._placeholder.addChild(this._activeEntry);
            if(param1)
            {
               TweenMax.delayedCall(param1,this.checkUnseen);
            }
            else
            {
               this.checkUnseen();
            }
         }
      }
      
      public function cleanup() : void
      {
         var _loc1_:GuiSagaNewsEntry = null;
         GuiGp.releasePrimaryBitmap(this.gp_l1);
         GuiGp.releasePrimaryBitmap(this.gp_r1);
         GuiGp.releasePrimaryBitmap(this.gp_x);
         GpBinder.gpbinder.unbind(this.cmd_l1);
         GpBinder.gpbinder.unbind(this.cmd_r1);
         GpBinder.gpbinder.unbind(this.cmd_x);
         this.cmd_l1.cleanup();
         this.cmd_r1.cleanup();
         this.cmd_x.cleanup();
         removeEventListener(MouseEvent.ROLL_OVER,this.rollOverHandler);
         removeEventListener(MouseEvent.ROLL_OUT,this.rollOutHandler);
         removeEventListener(MouseEvent.MOUSE_MOVE,this.mouseMoveHandler);
         removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
         removeEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler);
         TweenMax.killTweensOf(this);
         TweenMax.killDelayedCallsTo(this.checkUnseen);
         this._chits.cleanupGuiBase();
         this._buttonPrev.cleanup();
         this._buttonNext.cleanup();
         this._isShowing = false;
         for each(_loc1_ in this.entries)
         {
            _loc1_.cleanup();
         }
         this.entries = null;
      }
      
      public function rollOverHandler(param1:MouseEvent) : void
      {
         this.over = true;
         this.checkHovering();
         addEventListener(MouseEvent.MOUSE_MOVE,this.mouseMoveHandler);
      }
      
      public function rollOutHandler(param1:MouseEvent) : void
      {
         this.over = false;
         this.hovering = false;
         removeEventListener(MouseEvent.MOUSE_MOVE,this.mouseMoveHandler);
      }
      
      public function mouseMoveHandler(param1:MouseEvent) : void
      {
         this.checkHovering();
      }
      
      private function checkHovering() : void
      {
         if(!this.over)
         {
            this.hovering = false;
            return;
         }
         var _loc1_:int = 330;
         var _loc2_:int = 210;
         if(mouseX > -_loc1_ && mouseX < _loc1_ && mouseY < _loc2_)
         {
            this.hovering = true;
         }
         else
         {
            this.hovering = false;
         }
      }
      
      public function mouseDownHandler(param1:MouseEvent) : void
      {
         this.down = true;
         if(this.hovering)
         {
            if(this._activeEntry)
            {
               this._activeEntry.performClick();
            }
         }
      }
      
      public function mouseUpHandler(param1:MouseEvent) : void
      {
         this.down = false;
      }
      
      public function get hovering() : Boolean
      {
         return this._hovering;
      }
      
      public function set hovering(param1:Boolean) : void
      {
         this._hovering = param1;
         if(this._activeEntry)
         {
            this._activeEntry.hovering = this._hovering;
         }
         this._hover.visible = param1;
      }
      
      public function buttonPrevHandler(param1:*) : void
      {
         this._chits.prevChit();
         this.showActiveChit(0);
      }
      
      public function buttonNextHandler(param1:*) : void
      {
         this._chits.nextChit();
         this.showActiveChit(0);
      }
      
      public function selectNextUnseen() : void
      {
         var _loc2_:int = 0;
         var _loc3_:GuiSagaNewsEntry = null;
         var _loc1_:int = 1;
         while(_loc1_ <= this.entries.length)
         {
            _loc2_ = (this._chits.activeChitIndex + _loc1_) % this.entries.length;
            _loc3_ = this.entries[_loc2_];
            if(!_loc3_.entry.seen)
            {
               this._chits.activeChitIndex = _loc2_;
               this.showActiveChit(0);
            }
            _loc1_++;
         }
      }
      
      public function get isShowing() : Boolean
      {
         return this._isShowing;
      }
      
      public function get isAnimating() : Boolean
      {
         return this._isAnimating;
      }
      
      public function set isShowing(param1:Boolean) : void
      {
         var _loc3_:int = 0;
         if(this._isShowing == param1)
         {
            return;
         }
         this._isShowing = param1;
         TweenMax.killTweensOf(this);
         var _loc2_:Number = 0.5;
         if(Fastall.fastall)
         {
            _loc2_ = 0;
         }
         this._isAnimating = true;
         if(this._isShowing)
         {
            _loc3_ = 2;
            this.showActiveChit(_loc3_ + _loc2_);
            TweenMax.to(this,_loc2_,{
               "y":0,
               "onComplete":this.handleTweenShowingComplete
            });
         }
         else
         {
            TweenMax.to(this,_loc2_,{
               "y":this.HIDE_Y * scaleY,
               "onComplete":this.handleTweenShowingComplete
            });
         }
         this.setupGp();
         if(Boolean(this._activeEntry) && this._isShowing)
         {
            this._activeEntry.performLayout();
         }
      }
      
      private function handleTweenShowingComplete() : void
      {
         this._isAnimating = false;
         this.setupGp();
         if(this._newsToggle)
         {
            this._newsToggle.handleNewsUpdated();
         }
      }
      
      private function cmdfunc_l1(param1:CmdExec) : void
      {
         if(!visible || !parent || !this._activeEntry || !this.entries.length || !this._isShowing || this._isAnimating)
         {
            return;
         }
         this.gp_l1.pulse();
         this._buttonPrev.press();
      }
      
      private function cmdfunc_r1(param1:CmdExec) : void
      {
         if(!visible || !parent || !this._activeEntry || !this.entries.length || !this._isShowing || this._isAnimating)
         {
            return;
         }
         this.gp_r1.pulse();
         this._buttonNext.press();
      }
      
      private function cmdfunc_x(param1:CmdExec) : void
      {
         if(!visible || !parent || !this._activeEntry || !this.entries.length || !this._isShowing || this._isAnimating)
         {
            return;
         }
         this.gp_x.pulse();
         if(this._activeEntry)
         {
            this._activeEntry.performClick();
         }
      }
      
      public function set guiToggle(param1:IGuiSagaNewsToggle) : void
      {
         this._newsToggle = param1 as GuiSagaNewsToggle;
      }
      
      public function handleResize() : void
      {
         TweenMax.killTweensOf(this);
         if(this._isShowing)
         {
            this.y = 0;
         }
         else
         {
            this.y = this.HIDE_Y * scaleY;
         }
         this.handleTweenShowingComplete();
      }
      
      public function get numVisibleNews() : int
      {
         return this.entries.length;
      }
   }
}
