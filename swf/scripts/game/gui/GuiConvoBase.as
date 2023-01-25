package game.gui
{
   import com.stoicstudio.platform.PlatformInput;
   import engine.battle.Fastall;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.core.util.MovieClipUtil;
   import engine.entity.def.EntityIconType;
   import engine.entity.def.IEntityDef;
   import engine.gui.GuiContextEvent;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpAlignH;
   import engine.gui.GuiGpBitmap;
   import engine.gui.GuiGpNav;
   import engine.resource.BitmapResource;
   import engine.resource.IResource;
   import engine.saga.convo.Convo;
   import engine.saga.convo.ConvoCursor;
   import engine.saga.convo.ConvoEvent;
   import engine.saga.convo.def.ConvoOptionDef;
   import engine.saga.vars.IVariableProvider;
   import flash.display.MovieClip;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.utils.Timer;
   
   public class GuiConvoBase extends GuiBase implements IGuiConvo
   {
      
      public static var GUI_SHOW_INDEX_TEXT:Boolean = true;
       
      
      public var choices:Vector.<GuiPoppeningChoice>;
      
      public var choiceCount:int;
      
      public var _text:TextField;
      
      public var _buttonNext:ButtonWithIndex;
      
      public var _buttonEnd:ButtonWithIndex;
      
      public var _textName:TextField;
      
      public var _bannerName:MovieClip;
      
      public var _bg:MovieClip;
      
      public var options:Vector.<ConvoOptionDef>;
      
      public var _convo:Convo;
      
      private var timer:Timer;
      
      protected var maxTextHeight:Number = 0;
      
      protected var maxOptionBottom:Number = 0;
      
      protected var originalTextX:Number = 0;
      
      protected var originalTextWidth:Number = 0;
      
      protected var _speaker:IEntityDef;
      
      private var bgReadyFrame:int = 0;
      
      private var bgReady:Boolean;
      
      private var iconType:EntityIconType;
      
      private var _allowGp:Boolean = true;
      
      private var gpNav:GuiGpNav;
      
      private var gpEnd:GuiGpBitmap;
      
      private var _defaultTextSize:int;
      
      private var maxChoiceWidth:Number = 0;
      
      private var BANNER_LEFT_MARGIN:Number = 40;
      
      protected var _cursor:ConvoCursor;
      
      protected var _showConvoCursorTextVisibilityDefault:Boolean = true;
      
      private var _layoutGpNavInfo:LayoutGpNavInfo;
      
      private var iconResources:Vector.<IResource>;
      
      private var _mouseDown:Boolean;
      
      public function GuiConvoBase(param1:EntityIconType)
      {
         this.choices = new Vector.<GuiPoppeningChoice>();
         this.options = new Vector.<ConvoOptionDef>();
         this.timer = new Timer(300,1);
         this.gpEnd = GuiGp.ctorPrimaryBitmap(GpControlButton.X);
         this.iconResources = new Vector.<IResource>();
         super();
         this.iconType = param1;
         addChild(this.gpEnd);
         this.gpEnd.visible = false;
      }
      
      public function getDebugString() : String
      {
         return "GuiConvoBase";
      }
      
      public function get ready() : Boolean
      {
         return this.bgReady;
      }
      
      public function cleanup() : void
      {
         _context.removeEventListener(GuiContextEvent.OPTIONS,this.optionsHandler);
         GuiGp.releasePrimaryBitmap(this.gpEnd);
         if(this.gpNav)
         {
            this.gpNav.cleanup();
            this.gpNav = null;
         }
         context.removeEventListener(GuiContextEvent.LOCALE,this.localeChangeHandler);
         if(this._bg)
         {
            this._bg.removeEventListener(Event.ENTER_FRAME,this.bgFrameHandler);
         }
         this.speaker = null;
         this.convo = null;
         this.timer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.timerCompleteHandler);
         this.timer.stop();
         this.timer = null;
         super.cleanupGuiBase();
      }
      
      public function init(param1:IGuiContext, param2:Convo, param3:Boolean) : void
      {
         var _loc5_:GuiPoppeningChoice = null;
         initGuiBase(param1);
         this._bg = getChildByName("bg") as MovieClip;
         this._text = requireGuiChild("text") as TextField;
         this._defaultTextSize = int(this._text.defaultTextFormat.size);
         this._buttonNext = requireGuiChild("buttonNext") as ButtonWithIndex;
         this._buttonEnd = requireGuiChild("buttonEnd") as ButtonWithIndex;
         this._textName = getChildByName("textName") as TextField;
         this._bannerName = getChildByName("bannerName") as MovieClip;
         if(this._textName)
         {
            this._textName.visible = false;
         }
         if(this._bannerName)
         {
            this._bannerName.visible = false;
         }
         var _loc4_:int = 0;
         while(_loc4_ < numChildren)
         {
            _loc5_ = getChildAt(_loc4_) as GuiPoppeningChoice;
            if(_loc5_)
            {
               _loc5_.init(param1,this);
               this.choices.push(_loc5_);
               this.maxChoiceWidth = Math.max(this.maxChoiceWidth,(_loc5_ as MovieClip).width);
               this.maxOptionBottom = Math.max(this.maxOptionBottom,_loc5_.y + _loc5_.height);
            }
            _loc4_++;
         }
         this._buttonNext.setDownFunction(this.buttonNextHandler);
         this._buttonEnd.setDownFunction(this.buttonEndHandler);
         this.maxTextHeight = this._text.height;
         this.maxOptionBottom = this._buttonNext.y;
         this.originalTextX = this._text.x;
         this.originalTextWidth = this._text.width;
         this._text.mouseEnabled = false;
         this._text.selectable = false;
         if(this._textName)
         {
            this._textName.mouseEnabled = false;
            this._textName.selectable = false;
            registerScalableTextfield2d(this._textName,true);
         }
         this._buttonNext.mouseEnabled = false;
         this._buttonEnd.mouseEnabled = false;
         this._buttonNext.mouseChildren = false;
         this._buttonEnd.mouseChildren = false;
         this.timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.timerCompleteHandler);
         _context.addEventListener(GuiContextEvent.OPTIONS,this.optionsHandler);
         this.convo = param2;
      }
      
      private function optionsHandler(param1:GuiContextEvent) : void
      {
         if(!_context.isShowingOptions)
         {
            if(this._layoutGpNavInfo)
            {
               this.layoutGpNav(this._layoutGpNavInfo.recreate);
            }
         }
      }
      
      private function localeChangeHandler(param1:GuiContextEvent) : void
      {
         this.handleLocaleChange();
      }
      
      override public function handleLocaleChange() : void
      {
         super.handleLocaleChange();
         this.updateSpeakerText();
         this.showConvoCursor(this._cursor);
      }
      
      protected function start() : void
      {
         var _loc1_:GuiPoppeningChoice = null;
         var _loc2_:MovieClipUtil = null;
         this._cursor = null;
         this._text.visible = false;
         this._buttonNext.visible = false;
         this._buttonEnd.visible = false;
         this.gpEnd.visible = false;
         if(this._bg)
         {
            if(Fastall.gui)
            {
               this._bg.gotoAndStop(this._bg.framesLoaded);
               this.bgReadyFrame = 0;
               this.bgFrameHandler(null);
            }
            else
            {
               this.bgReady = false;
               this._bg.removeEventListener(Event.ENTER_FRAME,this.bgFrameHandler);
               this._bg.gotoAndStop("ready");
               this.bgReadyFrame = this._bg.currentFrame;
               _loc2_ = new MovieClipUtil(this._bg,context.logger,1);
               _loc2_.playOnce(null);
               this._bg.addEventListener(Event.ENTER_FRAME,this.bgFrameHandler);
            }
         }
         else
         {
            this.bgReady = true;
         }
         for each(_loc1_ in this.choices)
         {
            _loc1_.visible = false;
         }
         this.checkReady();
      }
      
      private function checkReady() : void
      {
         if(!this.bgReady)
         {
            return;
         }
         var _loc1_:Boolean = this._text.visible;
         this._text.visible = true;
         if(_loc1_ != this._text.visible)
         {
            Locale.updateTextFieldGuiGpTextHelper(this._text);
         }
         if(this._cursor)
         {
            this.showConvoCursor(this._cursor);
         }
      }
      
      private function bgFrameHandler(param1:Event) : void
      {
         if(this._bg.currentFrame >= this.bgReadyFrame)
         {
            this._bg.removeEventListener(Event.ENTER_FRAME,this.bgFrameHandler);
            this.bgReady = true;
            this.checkReady();
         }
      }
      
      private function buttonNextHandler(param1:ButtonWithIndex) : void
      {
         context.playSound("ui_speech_bubble");
         if(this._convo)
         {
            this._convo.next();
         }
      }
      
      private function buttonEndHandler(param1:ButtonWithIndex) : void
      {
         context.playSound("ui_generic");
         if(this._convo)
         {
            this._convo.next();
         }
      }
      
      public function get textSizeModification() : int
      {
         return 0;
      }
      
      public function appendText(param1:String, param2:String, param3:String) : void
      {
         if(!param3)
         {
            throw new ArgumentError("null t");
         }
         context.logger.info("CONVO " + param1 + ": " + param3.substr(0,40));
         if(param2)
         {
            param3 = "<a href=\'event:" + param2 + "\'>" + param3 + "</a>";
         }
         _context.locale.updateDisplayObjectTranslation(this._text,param3,null,this.textSizeModification);
         if(this._cursor && this._cursor._node && this._cursor._node.notranslate)
         {
            Locale.resetTextFieldFormat(this._text,this.textSizeModification);
         }
      }
      
      private function convoOptionHandler(param1:ConvoEvent) : void
      {
         var _loc2_:GuiPoppeningChoice = null;
         if(!this._convo)
         {
            return;
         }
         if(Boolean(this._cursor) && this._cursor.isFf)
         {
            return;
         }
         for each(_loc2_ in this.choices)
         {
            if(_loc2_.opt != this._convo.selectedOption)
            {
               _loc2_.disable();
            }
            else
            {
               _loc2_.makeSelection();
               if(this.gpNav)
               {
                  this.gpNav.blockNav = true;
               }
            }
         }
         this.timer.reset();
         this.timer.start();
         this.timer.running;
      }
      
      private function timerCompleteHandler(param1:TimerEvent) : void
      {
         var _loc2_:String = null;
         if(Boolean(this._convo) && !this._convo.finished)
         {
            if(!this._convo.selectedOption)
            {
               context.logger.error("Invalid convo, no option");
               this._convo.finish();
               return;
            }
            _loc2_ = this._convo.selectedOption.getOptionText(this._convo.def,this._convo.suffix);
            this.appendText("[selected]",null,_loc2_);
            this._convo.finishSelection();
         }
      }
      
      private function clearChoices() : void
      {
         var _loc1_:GuiPoppeningChoice = null;
         for each(_loc1_ in this.choices)
         {
            _loc1_.visible = false;
            _loc1_.callback = null;
         }
         this.choiceCount = 0;
      }
      
      private function addChoice(param1:String, param2:ConvoOptionDef, param3:String) : void
      {
         if(this.choiceCount >= this.choices.length)
         {
            context.logger.error("Cannot add more than " + this.choices.length + " choices");
            return;
         }
         context.logger.info("adding choice " + this.choiceCount + ": " + param3);
         var _loc4_:GuiPoppeningChoice = this.choices[this.choiceCount];
         _loc4_.setup(param1,param2,param3,this.choiceCallback,this.maxChoiceWidth);
         ++this.choiceCount;
      }
      
      protected function measureChoices() : Point
      {
         var _loc3_:GuiPoppeningChoice = null;
         var _loc1_:Point = new Point();
         var _loc2_:int = 0;
         while(_loc2_ < this.choiceCount)
         {
            _loc3_ = this.choices[_loc2_];
            _loc3_.updateWidth(this.maxChoiceWidth);
            _loc3_._text.width = Math.min(_loc3_._text.width,this.maxChoiceWidth);
            _loc1_.x = Math.max(_loc1_.x,_loc3_.width);
            _loc1_.y += _loc3_.height;
            _loc2_++;
         }
         return _loc1_;
      }
      
      protected function layoutChoices() : void
      {
         throw new IllegalOperationError("pure virtual");
      }
      
      private function choiceCallback(param1:GuiPoppeningChoice) : void
      {
         if(!this._convo)
         {
            return;
         }
         if(this.gpNav)
         {
            this.gpNav.cleanup();
            this.gpNav = null;
         }
         if(param1.id == "@next")
         {
            this._convo.next();
         }
         else if(param1.id == "@end")
         {
            this._convo.next();
         }
         else if(param1.id == "@opt")
         {
            this._convo.select(param1.opt);
         }
      }
      
      public function showConvoCursorButton(param1:Boolean) : void
      {
         if(param1)
         {
            if(!this._cursor.hasOptions)
            {
               if(Boolean(this._cursor.link) && Boolean(this._cursor.link.path))
               {
                  this._buttonNext.visible = true;
                  this._buttonNext.mouseEnabled = true;
               }
               else if(this.choiceCount == 0)
               {
                  this._buttonEnd.visible = true;
                  this._buttonEnd.mouseEnabled = true;
               }
            }
         }
         else
         {
            this._buttonNext.visible = false;
            this._buttonNext.mouseEnabled = false;
            this._buttonEnd.visible = false;
            this._buttonEnd.mouseEnabled = false;
         }
      }
      
      public function showConvoCursor(param1:ConvoCursor) : void
      {
         var _loc4_:IVariableProvider = null;
         var _loc5_:ILogger = null;
         var _loc6_:int = 0;
         var _loc7_:ConvoOptionDef = null;
         var _loc8_:String = null;
         this._cursor = param1;
         if(!this.ready)
         {
            return;
         }
         this._text.visible = this._showConvoCursorTextVisibilityDefault;
         this._buttonNext.visible = false;
         this._buttonNext.mouseEnabled = false;
         this._buttonEnd.visible = false;
         this.gpEnd.visible = false;
         this._buttonEnd.mouseEnabled = false;
         if(param1 == null || param1.convo.readyToFinish || param1.convo.finished)
         {
            this.clearChoices();
            this._text.htmlText = "";
            this.layoutChoices();
            this.layoutGpNav();
            return;
         }
         this.speaker = param1.speaker;
         var _loc2_:Boolean = param1.isAudioBlockingInput();
         var _loc3_:String = !!this.speaker ? String(this.speaker.id) : null;
         if(!param1.text)
         {
            this.appendText("[error]",null,"___CONVO ERROR___NO TEXT TO DISPLAY FOR\nURL=" + this.convo.def.url + "\nNODE=" + param1.nodeIds);
         }
         else if(this._speaker)
         {
            this.appendText("[line] (" + _loc3_ + ")",null,param1.text);
         }
         else
         {
            this.appendText("[story] (" + _loc3_ + ")",null,param1.text);
         }
         this.clearChoices();
         this.options.splice(0,this.options.length);
         if(param1.hasOptions)
         {
            _loc4_ = this._convo.saga;
            _loc5_ = context.logger;
            _loc6_ = 0;
            for each(_loc7_ in param1.options)
            {
               this.options.push(_loc7_);
               _loc6_++;
               _loc8_ = _loc7_.getOptionText(this._convo.def,this._convo.suffix);
               this.addChoice("@opt",_loc7_,(GUI_SHOW_INDEX_TEXT ? _loc6_ + ": " : "· ") + _loc8_);
            }
         }
         else if(param1.link && param1.link.path && !_loc2_)
         {
            this._buttonNext.visible = true;
            this._buttonNext.mouseEnabled = true;
         }
         else if(this.choiceCount == 0 && !_loc2_)
         {
            this._buttonEnd.visible = true;
            this._buttonEnd.mouseEnabled = true;
         }
         this.layoutChoices();
         this.layoutGpNav();
      }
      
      final protected function layoutGpNav(param1:Boolean = true) : void
      {
         var _loc2_:int = 0;
         var _loc3_:GuiPoppeningChoice = null;
         if(_context.isShowingOptions)
         {
            _context.logger.info("layoutGpNav blocked by options on gui context");
            this._layoutGpNavInfo = new LayoutGpNavInfo();
            this._layoutGpNavInfo.recreate = true;
            return;
         }
         this._layoutGpNavInfo = null;
         if(!this._convo)
         {
            if(this.gpNav)
            {
               this.gpNav.cleanup();
               this.gpNav = null;
            }
            this.gpEnd.visible = false;
            return;
         }
         if(param1 || !this._allowGp)
         {
            if(this.gpNav)
            {
               this.gpNav.cleanup();
               this.gpNav = null;
            }
            if(this._convo && this.choiceCount && this._allowGp)
            {
               this.gpNav = new GuiGpNav(context,"convo",this);
               this.gpNav.orientation = GuiGpNav.ORIENTATION_VERTICAL;
               this.gpNav.setAlignControlDefault(GuiGpAlignH.W_LEFT,null);
               this.gpNav.setAlignNavDefault(GuiGpAlignH.E_RIGHT,null);
               _loc2_ = 0;
               while(_loc2_ < this.choiceCount)
               {
                  _loc3_ = this.choices[_loc2_];
                  this.gpNav.add(_loc3_);
                  _loc2_++;
               }
               this.gpNav.activate();
               if(PlatformInput.lastInputGp)
               {
                  this.gpNav.autoSelect();
               }
            }
         }
         else if(this.gpNav)
         {
            this.gpNav.updateIconPlacement();
         }
         if(this._allowGp && this._buttonNext.visible)
         {
            this.gpEnd.visible = true;
            GuiGp.placeIconRight(this._buttonNext,this.gpEnd);
         }
         else if(this._allowGp && this._buttonEnd.visible)
         {
            this.gpEnd.visible = true;
            GuiGp.placeIconRight(this._buttonEnd,this.gpEnd);
         }
         else
         {
            this.gpEnd.visible = false;
         }
      }
      
      public function setConvoRect(param1:Number, param2:Number, param3:Number, param4:Number) : void
      {
      }
      
      public function get convo() : Convo
      {
         return this._convo;
      }
      
      private function checkIconCache() : void
      {
         var _loc1_:IResource = null;
         var _loc2_:String = null;
         var _loc3_:IEntityDef = null;
         var _loc4_:String = null;
         if(!this.iconType)
         {
            return;
         }
         if(this._convo)
         {
            for(_loc2_ in this._convo.def.speakers)
            {
               _loc3_ = this._convo.saga.getCastMember(_loc2_);
               if(_loc3_)
               {
                  _loc4_ = _loc3_.appearance.getIconUrl(this.iconType);
                  if(_loc4_)
                  {
                     _loc1_ = _context.resourceManager.getResource(_loc4_,BitmapResource);
                     if(_loc1_)
                     {
                        this.iconResources.push(_loc1_);
                     }
                  }
               }
            }
         }
         else if(this.iconResources.length)
         {
            for each(_loc1_ in this.iconResources)
            {
               _loc1_.release();
            }
            this.iconResources.splice(0,this.iconResources.length);
         }
      }
      
      public function set convo(param1:Convo) : void
      {
         if(this._convo == param1)
         {
            return;
         }
         this.gpEnd.gplayer = GpBinder.gpbinder.lastCmdId;
         if(this._convo)
         {
            this._convo.removeEventListener(ConvoEvent.OPTION,this.convoOptionHandler);
            this._convo = null;
         }
         this._convo = param1;
         if(this._convo)
         {
            this._convo.addEventListener(ConvoEvent.OPTION,this.convoOptionHandler);
         }
         this.checkIconCache();
         this.speaker = null;
         visible = this._convo != null;
         this.choiceCount = 0;
         if(this._convo)
         {
            this.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
            this.addEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler);
            context.addEventListener(GuiContextEvent.LOCALE,this.localeChangeHandler);
            this.start();
         }
         else
         {
            this.removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
            this.removeEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler);
            context.removeEventListener(GuiContextEvent.LOCALE,this.localeChangeHandler);
            if(this.gpNav)
            {
               this.gpNav.cleanup();
               this.gpNav = null;
            }
         }
      }
      
      private function mouseDownHandler(param1:MouseEvent) : void
      {
         this.mouseDown = true;
      }
      
      private function mouseUpHandler(param1:MouseEvent) : void
      {
         this.mouseDown = false;
      }
      
      public function get speaker() : IEntityDef
      {
         return this._speaker;
      }
      
      public function set speaker(param1:IEntityDef) : void
      {
         if(this._speaker == param1)
         {
            return;
         }
         this._speaker = param1;
         this.updateSpeakerText();
      }
      
      private function updateSpeakerText() : void
      {
         if(this._textName)
         {
            this._textName.htmlText = !!this._speaker ? String(this._speaker.name) : "";
            this._textName.visible = this._speaker != null;
            context.currentLocale.fixTextFieldFormat(this._textName);
            scaleTextfields();
         }
         if(this._bannerName)
         {
            this._bannerName.visible = this._textName.visible;
         }
      }
      
      public function get mouseDown() : Boolean
      {
         return this._mouseDown;
      }
      
      public function set mouseDown(param1:Boolean) : void
      {
         var _loc2_:GuiPoppeningChoice = null;
         if(param1 == this._mouseDown)
         {
            return;
         }
         this._mouseDown = param1;
         if(PlatformInput.isTouch)
         {
            for each(_loc2_ in this.choices)
            {
               _loc2_.canGlow = this._mouseDown;
            }
         }
      }
      
      public function get allowGp() : Boolean
      {
         return this._allowGp;
      }
      
      public function set allowGp(param1:Boolean) : void
      {
         if(this._allowGp == param1)
         {
            return;
         }
         this._allowGp = param1;
         this.layoutGpNav();
      }
   }
}

class LayoutGpNavInfo
{
    
   
   public var recreate:Boolean;
   
   public function LayoutGpNavInfo()
   {
      super();
   }
}
