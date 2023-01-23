package game.gui
{
   import com.stoicstudio.platform.PlatformInput;
   import engine.core.locale.LocaleCategory;
   import engine.core.logging.ILogger;
   import engine.core.util.StringUtil;
   import engine.gui.GuiButtonState;
   import engine.gui.GuiUtil;
   import engine.gui.IGuiButton;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.GridFitType;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.ui.Mouse;
   import flash.ui.Multitouch;
   import flash.ui.MultitouchInputMode;
   import flash.utils.Timer;
   
   public class ButtonWithIndex extends MovieClip implements IGuiButton
   {
      
      public static const EVENT_STATE:String = "ButtonWithIndex.STATE";
      
      private static const MOVED_THRESHOLD:int = 10;
       
      
      public var blockLocalization:Boolean;
      
      public var index:int;
      
      private var _buttonTextMc:MovieClip;
      
      private var downFunction:Function;
      
      private var upFunction:Function;
      
      private var rightDownFunction:Function;
      
      public var data;
      
      private var _state:GuiButtonState;
      
      public var isToggle:Boolean;
      
      private var _toggled:Boolean;
      
      private var _mouseOver:Boolean;
      
      private var _mouseDown:Boolean;
      
      private var prevState:GuiButtonState;
      
      private var stateTimer:Timer;
      
      public var noMouseEventsOnDisable:Boolean = true;
      
      protected var _textField:TextField;
      
      protected var _tooltipTextField:TextField;
      
      protected var _tt:GuiToolTip;
      
      protected var _hoverSprite:MovieClip;
      
      private var _textColor = null;
      
      private var _text:String;
      
      protected var _tooltipText:String;
      
      private var _textFieldDirty:Boolean = true;
      
      private var _tooltipTextFieldDirty:Boolean = true;
      
      private var lastFrame:int = 0;
      
      public var canToggleUp:Boolean = true;
      
      public var canToggleUpBlockerAllowsPress:Boolean;
      
      public var disableGotoOnStateChange:Boolean = false;
      
      protected var _context:IGuiContext;
      
      private var _clickSound:String = "ui_generic";
      
      private var pulseTimer:Timer;
      
      public var _toggler:MovieClip;
      
      public var isHtmlText:Boolean = true;
      
      private var _scaleTextToFit:Boolean = true;
      
      private var _centerTextVertically:Boolean;
      
      private var _textRect:Rectangle;
      
      private var _disableUnicodeFontFace:Boolean;
      
      private var _textOpaqueBackground;
      
      public var autoKillHover:Boolean;
      
      private var _tooltipTextFieldWidth:Number = 0;
      
      private var _ptDown:Point;
      
      public var disableAutoAlpha:Boolean;
      
      private var buttonTextSet:Boolean;
      
      private var buttonTooltipTextSet:Boolean;
      
      private var _autoSizeText:String;
      
      public var _forceLocale:String;
      
      private var _buttonToken:String;
      
      public function ButtonWithIndex()
      {
         var _loc2_:GuiToolTip = null;
         this.pulseTimer = new Timer(500);
         this._textRect = new Rectangle();
         this.autoKillHover = Multitouch.inputMode == MultitouchInputMode.TOUCH_POINT && !Mouse.supportsCursor;
         this._ptDown = new Point();
         super();
         mouseChildren = false;
         this.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
         this.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN,this.mouseRightDownHandler);
         this.addEventListener(MouseEvent.ROLL_OVER,this.mouseOverHandler);
         this.addEventListener(MouseEvent.ROLL_OUT,this.mouseOutHandler);
         this.addEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler);
         this.state = GuiButtonState.NORMAL;
         stop();
         this._toggler = getChildByName("toggler") as MovieClip;
         if(this._toggler)
         {
            this._toggler.visible = false;
            this._toggler.stop();
         }
         var _loc1_:int = 0;
         while(_loc1_ < numChildren)
         {
            _loc2_ = getChildAt(_loc1_) as GuiToolTip;
            if(_loc2_)
            {
               this._tt = _loc2_;
               this._tt.visible = false;
               break;
            }
            _loc1_++;
         }
         this._hoverSprite = getChildByName("hover") as MovieClip;
         if(this._hoverSprite)
         {
            this._hoverSprite.visible = false;
            this._hoverSprite.stop();
         }
      }
      
      public function set ttAlign(param1:String) : void
      {
         if(this._tt)
         {
            this._tt.ttAlign = param1;
         }
      }
      
      public function cleanup() : void
      {
         this.removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
         this.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN,this.mouseRightDownHandler);
         this.removeEventListener(MouseEvent.ROLL_OVER,this.mouseOverHandler);
         this.removeEventListener(MouseEvent.ROLL_OUT,this.mouseOutHandler);
         this.removeEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler);
         this.removeEventListener(Event.REMOVED_FROM_STAGE,this.removedFromStageHandler);
         removeEventListener(Event.FRAME_CONSTRUCTED,this.frameConstructedHandler);
         removeEventListener(Event.ENTER_FRAME,this.enterFrameHandler);
         this.cleanupStateTimer();
         this.cleanupPulseTimer();
         this._buttonTextMc = null;
         this.downFunction = null;
         this.upFunction = null;
         this.rightDownFunction = null;
         this.data = null;
         this._textField = null;
         this._tooltipTextField = null;
         this._context = null;
         while(numChildren > 0)
         {
            removeChildAt(numChildren - 1);
         }
         if(this._tt)
         {
            this._tt.cleanup();
            this._tt = null;
         }
      }
      
      public function resetListeners() : void
      {
         mouseEnabled = true;
         mouseChildren = false;
         this.removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
         this.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
      }
      
      private function checkTextField() : void
      {
         this.tf = this.findTextField();
      }
      
      protected function findTextField() : TextField
      {
         var _loc1_:DisplayObject = getChildByName("button_text");
         this._buttonTextMc = _loc1_ as MovieClip;
         var _loc2_:TextField = null;
         if(_loc1_ is MovieClip)
         {
            _loc2_ = this._buttonTextMc.text;
         }
         else if(_loc1_ is TextField)
         {
            _loc2_ = _loc1_ as TextField;
         }
         else
         {
            _loc2_ = getChildByName("text") as TextField;
         }
         if(Boolean(_loc2_) && this._textRect.isEmpty())
         {
            this._textRect.setTo(_loc2_.x,_loc2_.y,_loc2_.width,_loc2_.height);
         }
         if(Boolean(_loc2_) && !this.buttonTextSet)
         {
            this.buttonText = this.possiblyTranslateString(_loc2_.text);
         }
         return _loc2_;
      }
      
      private function possiblyTranslateString(param1:String) : String
      {
         if(this._context && param1.length > 1 && param1.charAt(0) == "$")
         {
            return this._context.translate(param1.substr(1));
         }
         return param1;
      }
      
      private function disableTextFields(param1:DisplayObjectContainer) : void
      {
         var _loc3_:DisplayObject = null;
         var _loc4_:TextField = null;
         var _loc5_:DisplayObjectContainer = null;
         var _loc2_:int = 0;
         while(_loc2_ < param1.numChildren)
         {
            _loc3_ = param1.getChildAt(_loc2_);
            _loc4_ = _loc3_ as TextField;
            if(_loc4_)
            {
               _loc4_.selectable = false;
               _loc4_.mouseEnabled = _loc4_.mouseWheelEnabled = false;
            }
            _loc5_ = _loc3_ as DisplayObjectContainer;
            if(_loc5_)
            {
               this.disableTextFields(_loc5_);
            }
            _loc2_++;
         }
      }
      
      protected function findTooltipTextField() : TextField
      {
         var _loc2_:TextField = null;
         var _loc1_:int = 0;
         while(_loc1_ < numChildren)
         {
            _loc2_ = getChildAt(_loc1_) as TextField;
            if(_loc2_)
            {
               if(StringUtil.startsWith(_loc2_.name,"text_tooltip"))
               {
                  return _loc2_;
               }
            }
            _loc1_++;
         }
         return null;
      }
      
      private function checkTooltipTextField() : void
      {
         var _loc1_:TextField = this.findTooltipTextField();
         if(_loc1_)
         {
            if(_loc1_.scaleX == 1)
            {
               this._tooltipTextFieldWidth = _loc1_.width;
            }
         }
         this.tooltipTf = _loc1_;
      }
      
      public function setDownFunction(param1:Function) : void
      {
         this.downFunction = param1;
      }
      
      public function setUpFunction(param1:Function) : void
      {
         this.upFunction = param1;
      }
      
      public function setRightDownFunction(param1:Function) : void
      {
         this.rightDownFunction = param1;
      }
      
      public function setIndex(param1:int) : void
      {
         this.index = param1;
      }
      
      public function getIndex() : int
      {
         return this.index;
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         super.enabled = param1;
         this.updateState();
      }
      
      private function mouseOutHandler(param1:MouseEvent) : void
      {
         this.mouseOver = false;
         this.setStateToNormal();
      }
      
      private function mouseOverHandler(param1:MouseEvent) : void
      {
         if(!visible || !enabled && this.noMouseEventsOnDisable)
         {
            return;
         }
         this.mouseOver = true;
      }
      
      private function mouseRightDownHandler(param1:MouseEvent) : void
      {
         var event:MouseEvent = param1;
         if(!visible || !enabled && this.noMouseEventsOnDisable)
         {
            return;
         }
         if(this.rightDownFunction != null)
         {
            try
            {
               this.rightDownFunction(this);
            }
            catch(err:Error)
            {
               if(_context)
               {
                  _context.logger.error("ButtonWithIndex " + this.name + " failed callback:\n" + err.getStackTrace());
               }
            }
         }
      }
      
      public function press() : void
      {
         this.pressNoRelease();
         this.release();
      }
      
      public function pressNoRelease() : void
      {
         if(!enabled)
         {
            if(this._context)
            {
               this._context.logger.info("ButtonWithIndex " + this.name + " cannot press while disabled");
            }
            return;
         }
         if(this.isToggle)
         {
            if(!this.toggled || this.canToggleUp)
            {
               this.toggled = !this.toggled;
            }
            else if(!this.canToggleUpBlockerAllowsPress)
            {
               return;
            }
         }
         if(Boolean(this._context) && Boolean(this._clickSound))
         {
            this._context.playSound(this._clickSound);
         }
         if(this.downFunction != null)
         {
            try
            {
               this.downFunction(this);
            }
            catch(err:Error)
            {
               if(_context)
               {
                  _context.logger.error("ButtonWithIndex " + this.name + " failed callback:\n" + err.getStackTrace());
               }
            }
         }
      }
      
      private function get downMoved() : Boolean
      {
         if(!PlatformInput.lastInputGp)
         {
            return Math.abs(this._ptDown.x - mouseX) > MOVED_THRESHOLD || Math.abs(this._ptDown.y - mouseY) > MOVED_THRESHOLD;
         }
         return false;
      }
      
      public function release() : void
      {
         if(this.upFunction != null)
         {
            if(this.downMoved)
            {
               if(this._context)
               {
                  this._context.logger.debug("skipping button up due to downMoved " + this);
               }
               return;
            }
            try
            {
               this.upFunction(this);
            }
            catch(err:Error)
            {
               if(_context)
               {
                  _context.logger.error("ButtonWithIndex " + this.name + " failed callback:\n" + err.getStackTrace());
               }
            }
         }
      }
      
      private function mouseDownHandler(param1:MouseEvent) : void
      {
         if(!visible || !enabled && this.noMouseEventsOnDisable)
         {
            return;
         }
         this.addEventListener(Event.REMOVED_FROM_STAGE,this.removedFromStageHandler);
         this.mouseDown = true;
         this.press();
         param1.preventDefault();
      }
      
      private function removedFromStageHandler(param1:Event) : void
      {
         this.removeEventListener(Event.REMOVED_FROM_STAGE,this.removedFromStageHandler);
         this.mouseDown = false;
         this.mouseOver = false;
      }
      
      private function mouseUpHandler(param1:MouseEvent) : void
      {
         if(!visible || !enabled && this.noMouseEventsOnDisable)
         {
            return;
         }
         if(this.mouseDown)
         {
            this.release();
            this.mouseDown = false;
         }
      }
      
      protected function updateState() : void
      {
         if(this.toggled)
         {
            if(this._toggler)
            {
               if(!this._toggler.isPlaying)
               {
                  this._toggler.gotoAndPlay(1);
               }
               this._toggler.visible = true;
            }
         }
         else if(this._toggler)
         {
            this._toggler.visible = false;
            this._toggler.stop();
         }
         if(!enabled)
         {
            this.state = GuiButtonState.NORMAL;
            if(this.isToggle && this.toggled)
            {
               this.state = GuiButtonState.DISABLED_TOGGLED;
            }
            else
            {
               this.state = GuiButtonState.DISABLED;
            }
            if(this._tt)
            {
               this._tt.visible = false;
            }
            return;
         }
         if(!this.disableAutoAlpha)
         {
            alpha = 1;
         }
         if(this.mouseDown)
         {
            this.cleanupPulseTimer();
            if(this.isToggle && this.toggled)
            {
               this.state = GuiButtonState.TOGGLED_DOWN;
            }
            else
            {
               this.state = GuiButtonState.DOWN;
            }
         }
         else if(this.mouseOver || this.isHovering)
         {
            if(this.isToggle && this.toggled)
            {
               this.state = GuiButtonState.TOGGLED_HOVER;
            }
            else
            {
               this.state = GuiButtonState.HOVER;
            }
         }
         else if(this.isToggle && this.toggled)
         {
            this.state = GuiButtonState.TOGGLED;
         }
         else
         {
            this.state = GuiButtonState.NORMAL;
         }
      }
      
      public function setHovering(param1:Boolean) : void
      {
         if(!enabled)
         {
            return;
         }
         if(param1)
         {
            if(this.isToggle && this.toggled)
            {
               this.state = GuiButtonState.TOGGLED_HOVER;
            }
            else
            {
               this.state = GuiButtonState.HOVER;
            }
         }
         else if(this.isToggle && this.toggled)
         {
            this.state = GuiButtonState.TOGGLED;
         }
         else
         {
            this.state = GuiButtonState.NORMAL;
         }
      }
      
      public function get movieClip() : MovieClip
      {
         return this;
      }
      
      public function setStateToNormal() : void
      {
         this.state = GuiButtonState.NORMAL;
         this.cleanupStateTimer();
         this.mouseOver = false;
         this.mouseDown = false;
      }
      
      private function onStateTimerCompleted(param1:TimerEvent) : void
      {
         if(this.stateTimer)
         {
            this.stateTimer.stop();
            this.state = this.prevState;
            this.cleanupStateTimer();
         }
      }
      
      private function cleanupStateTimer() : void
      {
         if(this.stateTimer)
         {
            this.stateTimer.removeEventListener(TimerEvent.TIMER,this.onStateTimerCompleted);
            this.stateTimer.stop();
            this.stateTimer = null;
         }
      }
      
      private function onPulseTimerCompleted(param1:TimerEvent) : void
      {
         if(this.currentFrame == 1)
         {
            this.gotoAndStop(2);
         }
         else
         {
            this.gotoAndStop(1);
         }
      }
      
      public function setStateForCertainTimeframe(param1:GuiButtonState, param2:Number) : void
      {
         if(param1 == this._state)
         {
            return;
         }
         this.state = param1;
         if(!this.stateTimer)
         {
            this.stateTimer = new Timer(param2,0);
            this.stateTimer.addEventListener(TimerEvent.TIMER,this.onStateTimerCompleted);
         }
         if(!this.stateTimer.running)
         {
            this.stateTimer.delay = param2;
            this.stateTimer.start();
         }
      }
      
      public function get state() : GuiButtonState
      {
         return this._state;
      }
      
      public function forceHovering(param1:Boolean) : void
      {
         this.state = GuiButtonState.NORMAL;
         this.setHovering(param1);
      }
      
      public function set state(param1:GuiButtonState) : void
      {
         var _loc2_:int = 0;
         if(this._state != param1)
         {
            if(this.autoKillHover)
            {
               if(param1 == GuiButtonState.HOVER)
               {
                  param1 = GuiButtonState.NORMAL;
               }
               else if(param1 == GuiButtonState.TOGGLED_HOVER)
               {
                  param1 = GuiButtonState.TOGGLED;
               }
            }
            this.cleanupStateTimer();
            this.prevState = this._state;
            this._state = param1;
            addEventListener(Event.FRAME_CONSTRUCTED,this.frameConstructedHandler);
            if(!this.disableGotoOnStateChange)
            {
               _loc2_ = this._state.getBestFrame(this.framesLoaded);
               if(this.totalFrames >= _loc2_)
               {
                  this.gotoAndStop(_loc2_);
               }
            }
            dispatchEvent(new Event(EVENT_STATE));
            if(this._tt)
            {
               this._tt.visible = this.isHovering;
            }
            if(this._hoverSprite)
            {
               this._hoverSprite.visible = this.isHovering;
            }
         }
      }
      
      private function frameConstructedHandler(param1:Event) : void
      {
         removeEventListener(Event.FRAME_CONSTRUCTED,this.frameConstructedHandler);
         if(this._context)
         {
            this._context.currentLocale.translateDisplayObjects(LocaleCategory.GUI,this,!!this._context ? this._context.logger : null);
         }
         this.disableTextFields(this);
         this.checkTextField();
         this.checkTooltipTextField();
         this.enterFrameHandler(null);
      }
      
      private function enterFrameHandler(param1:Event) : void
      {
         removeEventListener(Event.ENTER_FRAME,this.enterFrameHandler);
         this.updateTextField();
         this.updateTooltipTextField();
      }
      
      public function get toggled() : Boolean
      {
         return this._toggled;
      }
      
      public function set toggled(param1:Boolean) : void
      {
         if(this._toggled == param1)
         {
            return;
         }
         this._toggled = param1;
         this.updateState();
      }
      
      public function get mouseOver() : Boolean
      {
         return this._mouseOver;
      }
      
      public function set mouseOver(param1:Boolean) : void
      {
         if(this._mouseOver == param1)
         {
            return;
         }
         if(!this._context)
         {
         }
         this._mouseOver = param1;
         this.updateState();
      }
      
      public function get mouseDown() : Boolean
      {
         return this._mouseDown;
      }
      
      public function set mouseDown(param1:Boolean) : void
      {
         this._mouseDown = param1;
         if(param1)
         {
            this._ptDown.setTo(mouseX,mouseY);
         }
         this.updateState();
      }
      
      private function setTextFieldDirty() : void
      {
         this.updateTextField();
         this._textFieldDirty = true;
         addEventListener(Event.ENTER_FRAME,this.enterFrameHandler);
      }
      
      private function setTooltipTextFieldDirty() : void
      {
         this.updateTooltipTextField();
         this._tooltipTextFieldDirty = true;
         addEventListener(Event.ENTER_FRAME,this.enterFrameHandler);
      }
      
      public function set textColor(param1:*) : void
      {
         if(this._textColor != param1)
         {
            this._textColor = param1;
            this.setTextFieldDirty();
         }
      }
      
      public function get textColor() : *
      {
         return this._textColor;
      }
      
      public function get buttonText() : String
      {
         return this._text;
      }
      
      public function set buttonText(param1:String) : void
      {
         this._text = param1;
         this.buttonTextSet = true;
         this.setTextFieldDirty();
      }
      
      public function set buttonTooltipText(param1:String) : void
      {
         this._tooltipText = param1;
         this.buttonTooltipTextSet = true;
         this.setTooltipTextFieldDirty();
      }
      
      public function get buttonTooltipText() : String
      {
         return this._tooltipText;
      }
      
      public function set autoSizeText(param1:String) : void
      {
         this._autoSizeText = param1;
         this.setTextFieldDirty();
      }
      
      private function updateTextField() : void
      {
         if(Boolean(this._textField) && this._textFieldDirty)
         {
            this._textFieldDirty = false;
            if(this.buttonTextSet)
            {
               this._textField.scaleX = this._textField.scaleY = 1;
               this._textField.width = this._textRect.width;
               this._textField.height = this._textRect.height;
               this._textField.scaleX = this._textField.scaleY = 1;
               this._textField.x = this._textRect.x;
               this._textField.y = this._textRect.y;
               if(this.isHtmlText)
               {
                  this._textField.htmlText = !!this._text ? this._text : "";
               }
               else
               {
                  this._textField.text = !!this._text ? this._text : "";
               }
               if(this._context)
               {
                  if(!this._disableUnicodeFontFace)
                  {
                     this._context.currentLocale.fixTextFieldFormat(this._textField,this._forceLocale);
                  }
               }
               if(Boolean(this._text) && !this._textField.textWidth)
               {
                  this._textFieldDirty = true;
               }
               if(this._autoSizeText)
               {
                  this._textField.width = this._textField.textWidth + 10;
                  switch(this._autoSizeText)
                  {
                     case TextFieldAutoSize.RIGHT:
                        this._textField.x = this._textRect.x + this._textRect.width - this._textField.width;
                        break;
                     default:
                        this._textField.x = this._textRect.x;
                  }
               }
               else if(this._scaleTextToFit)
               {
                  this._textField.opaqueBackground = null;
                  GuiUtil.scaleTextToFitAlign(this._textField,"center",this._textRect);
                  this._textField.opaqueBackground = this._textOpaqueBackground;
               }
               if(this._centerTextVertically)
               {
                  this._textField.y = this.height * 0.5 - this._textRect.height * 0.5;
               }
            }
            if(this._textColor != null)
            {
               this._textField.textColor = this._textColor;
            }
            this._textField.cacheAsBitmap = true;
         }
      }
      
      private function updateTooltipTextField() : void
      {
         if(this._tooltipTextFieldDirty)
         {
            if(this._tooltipTextField)
            {
               this._tooltipTextFieldDirty = false;
               if(this.buttonTooltipTextSet)
               {
                  this._tooltipTextField.text = !!this._tooltipText ? this._tooltipText : "";
               }
               if(this._context)
               {
                  this._context.currentLocale.translateDisplayObjects(LocaleCategory.GUI,this._tooltipTextField,!!this._context ? this._context.logger : null);
                  if(!this._disableUnicodeFontFace)
                  {
                     this._context.currentLocale.fixTextFieldFormat(this._tooltipTextField,this._forceLocale);
                  }
               }
               GuiUtil.scaleTextToFit(this._tooltipTextField,this._tooltipTextFieldWidth);
            }
            if(this._tt)
            {
               this._tooltipTextFieldDirty = false;
               if(this.buttonTooltipTextSet)
               {
                  this._tt.setContent(null,this._tooltipText);
                  if(this._context)
                  {
                     this._context.currentLocale.translateDisplayObjects(LocaleCategory.GUI,this._tt,!!this._context ? this._context.logger : null);
                     if(this._disableUnicodeFontFace)
                     {
                     }
                  }
               }
               this._tt.performLayout();
            }
         }
      }
      
      private function get tf() : TextField
      {
         return this._textField;
      }
      
      private function set tf(param1:TextField) : void
      {
         if(this._textField != param1)
         {
            this._textField = param1;
            if(this._textField)
            {
               this._textField.mouseEnabled = false;
               this._textField.opaqueBackground = this._textOpaqueBackground;
               this._textField.autoSize = TextFieldAutoSize.NONE;
               this._textField.gridFitType = GridFitType.PIXEL;
            }
            this.setTextFieldDirty();
         }
      }
      
      private function set tooltipTf(param1:TextField) : void
      {
         if(this._tooltipTextField != param1)
         {
            this._tooltipTextField = param1;
            if(this._tooltipTextField)
            {
               this._tooltipTextField.mouseEnabled = false;
            }
            this.setTooltipTextFieldDirty();
         }
      }
      
      public function set clickSound(param1:String) : void
      {
         this._clickSound = param1;
      }
      
      public function get isHovering() : Boolean
      {
         return this._state == GuiButtonState.HOVER || this._state == GuiButtonState.TOGGLED_HOVER;
      }
      
      public function pulseHover(param1:int) : void
      {
         if(!this.pulseTimer)
         {
            this.pulseTimer = new Timer(param1);
            this.pulseTimer.addEventListener(TimerEvent.TIMER,this.onPulseTimerCompleted);
         }
         this.pulseTimer.delay = param1;
         this.pulseTimer.start();
      }
      
      private function cleanupPulseTimer() : void
      {
         if(this.pulseTimer)
         {
            this.pulseTimer.removeEventListener(TimerEvent.TIMER,this.onPulseTimerCompleted);
            this.pulseTimer.stop();
            this.pulseTimer = null;
         }
      }
      
      public function get centerTextVertically() : Boolean
      {
         return this._centerTextVertically;
      }
      
      public function set centerTextVertically(param1:Boolean) : void
      {
         if(this._centerTextVertically == param1)
         {
            return;
         }
         this._centerTextVertically = param1;
         this.setTextFieldDirty();
      }
      
      public function get scaleTextToFit() : Boolean
      {
         return this._scaleTextToFit;
      }
      
      public function set scaleTextToFit(param1:Boolean) : void
      {
         if(this._scaleTextToFit == param1)
         {
            return;
         }
         this._scaleTextToFit = param1;
         this.setTextFieldDirty();
      }
      
      public function set guiButtonContext(param1:*) : void
      {
         if(this._context == param1)
         {
            return;
         }
         this._context = param1 as IGuiContext;
         if(this._tt)
         {
            this._tt.init(this._context);
         }
      }
      
      public function get forceLocale() : String
      {
         return this._forceLocale;
      }
      
      public function set forceLocale(param1:String) : void
      {
         if(param1 != this._forceLocale)
         {
            this._forceLocale = param1;
            this.setTextFieldDirty();
         }
      }
      
      public function get disableUnicodeFontFace() : Boolean
      {
         return this._disableUnicodeFontFace;
      }
      
      public function set disableUnicodeFontFace(param1:Boolean) : void
      {
         if(param1 != this._disableUnicodeFontFace)
         {
            this._disableUnicodeFontFace = param1;
            this.setTextFieldDirty();
         }
      }
      
      public function get textOpaqueBackground() : *
      {
         return this._textOpaqueBackground;
      }
      
      public function set textOpaqueBackground(param1:*) : void
      {
         this._textOpaqueBackground = param1;
         if(this._textField)
         {
            this._textField.opaqueBackground = this._textOpaqueBackground;
         }
      }
      
      public function getNavRectangle(param1:DisplayObject) : Rectangle
      {
         return this.getRect(param1);
      }
      
      public function set buttonToken(param1:String) : void
      {
         this._buttonToken = param1;
      }
      
      public function get buttonToken() : String
      {
         return this._buttonToken;
      }
      
      override public function set visible(param1:Boolean) : void
      {
         if(super.visible != param1)
         {
            super.visible = param1;
         }
      }
      
      public function handleLocaleChange() : void
      {
         this.updateTextField();
         this.updateTooltipTextField();
      }
   }
}
