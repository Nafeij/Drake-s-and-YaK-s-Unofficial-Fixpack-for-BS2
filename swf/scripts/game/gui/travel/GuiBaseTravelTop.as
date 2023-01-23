package game.gui.travel
{
   import com.greensock.TweenMax;
   import com.stoicstudio.platform.PlatformInput;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.gui.GuiContextEvent;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpBitmap;
   import engine.saga.ICaravan;
   import engine.saga.ISaga;
   import engine.saga.SagaVar;
   import engine.saga.vars.IVariableBag;
   import engine.saga.vars.VariableEvent;
   import flash.display.FrameLabel;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   
   public class GuiBaseTravelTop extends GuiBase implements IGuiTravelTop
   {
      
      public static const ANIMATE_TIME:Number = 0.35;
      
      private static var DEFAULT_DAYS:int = -999999;
       
      
      protected var _sagaDispatcher:IEventDispatcher;
      
      protected var _globalVars:IVariableBag;
      
      protected var _caravanVars:IVariableBag;
      
      protected var _saga:ISaga;
      
      protected var _top_banner_black:MovieClip;
      
      protected var _top_banner_red:MovieClip;
      
      protected var _top_banner:MovieClip;
      
      protected var listener:IGuiTravelTopListener;
      
      protected var gp_start:GuiGpBitmap;
      
      public var _button$options:ButtonWithIndex;
      
      public var _banner_renown:GuiTravelBanner;
      
      public var _textDays:TextField;
      
      public var _tooltip$days:TextField;
      
      public var _timer:GuiTravelTimer;
      
      public var _button_morale:GuiTravelTopMorale;
      
      protected var _extended:Boolean = true;
      
      protected var _animating:Boolean = false;
      
      protected var _extendedBanner:Boolean = true;
      
      protected var _animatingBanner:Boolean = false;
      
      protected var _guiEnabled:Boolean;
      
      protected var _campEnabled:Boolean = true;
      
      protected var _mapEnabled:Boolean = true;
      
      private var textDaysRect:Rectangle;
      
      private var _days:int;
      
      protected var _animationCallback:Function;
      
      protected var _coinFlipClips:Vector.<MovieClip>;
      
      private var _frameLabels:Array;
      
      private var _frameLabelEnd:FrameLabel = null;
      
      private var _shatterMC:MovieClip = null;
      
      private var _shatterInProgress:Boolean = false;
      
      private var _flipsComplete:Dictionary;
      
      private var _flipsCompleteFunction:Function;
      
      private var _flipInProgress:Boolean = false;
      
      protected var _travelGuiSoundPlayer:IGuiTravelSoundPlayer;
      
      protected var _activatedGp:Boolean;
      
      public function GuiBaseTravelTop()
      {
         this.gp_start = GuiGp.ctorPrimaryBitmap(GpControlButton.START,true);
         this.textDaysRect = new Rectangle();
         this._days = DEFAULT_DAYS;
         this._coinFlipClips = new Vector.<MovieClip>();
         super();
         this._top_banner_black = getChildByName("top_banner_black") as MovieClip;
         this._top_banner_red = getChildByName("top_banner_red") as MovieClip;
         if(this._top_banner_black)
         {
            this._top_banner_black.visible = false;
         }
         if(this._top_banner_red)
         {
            this._top_banner_red.visible = false;
         }
         name = "GuiBaseTravelTop";
         this._button$options = requireGuiChild("button$options") as ButtonWithIndex;
         this._banner_renown = requireGuiChild("banner_renown") as GuiTravelBanner;
         this._textDays = requireGuiChild("textDays") as TextField;
         this._tooltip$days = requireGuiChild("tooltip$days") as TextField;
         this._timer = requireGuiDescendant("timer") as GuiTravelTimer;
         this._button_morale = requireGuiChild("button_morale") as GuiTravelTopMorale;
         this.addCoinFlipClip("dust_effects");
         this.addCoinFlipClip("coin_flip");
         addChild(this.gp_start);
         this.gp_start.scale = 0.75;
      }
      
      public function get shatterInProgress() : Boolean
      {
         return this._shatterInProgress;
      }
      
      public function set shatterInProgress(param1:Boolean) : void
      {
         this._shatterInProgress = param1;
      }
      
      protected function removeSagaDispatcherListeners() : void
      {
      }
      
      protected function addSagaDispatcherListeners() : void
      {
      }
      
      protected function handleInit() : void
      {
      }
      
      protected function handleCleanup() : void
      {
      }
      
      protected function handleUpdate() : void
      {
      }
      
      protected function caravanVarHandler(param1:VariableEvent) : void
      {
      }
      
      protected function handleActivatedGp() : void
      {
      }
      
      protected function handleResizeHandler() : void
      {
      }
      
      protected function handleLocaleHandler(param1:GuiContextEvent) : void
      {
      }
      
      public function playDarknessTransition(param1:Function) : void
      {
         if(this._flipInProgress)
         {
            return;
         }
         this._flipInProgress = true;
         this._flipsComplete = new Dictionary();
         this._flipsCompleteFunction = param1;
         var _loc2_:int = 0;
         while(_loc2_ < this._coinFlipClips.length)
         {
            this._coinFlipClips[_loc2_].addEventListener(Event.ENTER_FRAME,this.coinFlipCompleteListener);
            this._coinFlipClips[_loc2_].play();
            _loc2_++;
         }
      }
      
      public function coinFlipCompleteListener(param1:Event) : void
      {
         var _loc2_:MovieClip = param1.target as MovieClip;
         if(!_loc2_)
         {
            return;
         }
         var _loc3_:String = _loc2_.currentFrameLabel;
         if(!_loc3_ || _loc3_ != "flip_complete")
         {
            return;
         }
         this._flipsComplete[_loc2_] = true;
         _loc2_.removeEventListener(Event.ENTER_FRAME,this.coinFlipCompleteListener);
         var _loc4_:int = 0;
         while(_loc4_ < this._coinFlipClips.length)
         {
            if(!this._flipsComplete[this._coinFlipClips[_loc4_]])
            {
               return;
            }
            _loc4_++;
         }
         if(this._flipsCompleteFunction != null)
         {
            this._flipsCompleteFunction();
         }
         this._flipInProgress = false;
      }
      
      public function set travelGuiSoundPlayer(param1:IGuiTravelSoundPlayer) : void
      {
         this._travelGuiSoundPlayer = param1;
      }
      
      private function addCoinFlipClip(param1:String) : void
      {
         var _loc2_:MovieClip = getChildByName("coin_flip") as MovieClip;
         if(_loc2_)
         {
            this._coinFlipClips.push(_loc2_);
         }
      }
      
      public function init(param1:IGuiContext, param2:IGuiTravelTopListener, param3:ISaga) : void
      {
         super.initGuiBase(param1);
         this.saga = param3;
         this.sagaDispatcher = param3;
         this.globalVars = param3.global;
         var _loc4_:ICaravan = param3.icaravan;
         this.caravanVars = !!_loc4_ ? _loc4_.vars : null;
         this.listener = param2;
         if(!this._caravanVars)
         {
            param1.logger.error("Attempt to show travel hud with no caravan set!");
            return;
         }
         this._banner_renown.init(this,this._caravanVars,SagaVar.VAR_RENOWN);
         this._timer.init(param1);
         this._textDays.addEventListener(MouseEvent.ROLL_OUT,this.textDaysRollOutHandler);
         this._textDays.addEventListener(MouseEvent.ROLL_OVER,this.textDaysRollOverHandler);
         this._tooltip$days.mouseEnabled = false;
         registerScalableTextfield(this._tooltip$days,false);
         this.textDaysRollOutHandler(null);
         this.textDaysRect.setTo(this._textDays.x,this._textDays.y,this._textDays.width,this._textDays.height);
         this._button_morale.init(param1,this._saga,this.caravanVars);
         this.handleInit();
         this._button$options.setDownFunction(this.buttonOptionsHandler);
         this._button$options.visible = PlatformInput.hasClicker || !PlatformInput.lastInputGp;
         PlatformInput.dispatcher.addEventListener(PlatformInput.EVENT_LAST_INPUT,this.onOperationModeChange);
         this.gp_start.createCaption(param1,GuiGpBitmap.CAPTION_RIGHT).setToken("travel_top_options");
         _context.addEventListener(GuiContextEvent.LOCALE,this.localeHandler);
         var _loc5_:String = param3.bannerHudName;
         if(_loc5_ == "top_banner_black")
         {
            this._top_banner = this._top_banner_black;
         }
         else
         {
            this._top_banner = this._top_banner_red;
         }
         if(this._top_banner_black)
         {
            this._top_banner_black.visible = this._top_banner_black == this._top_banner;
         }
         if(this._top_banner_red)
         {
            this._top_banner_red.visible = this._top_banner_red == this._top_banner;
         }
         if(this._top_banner)
         {
            this._top_banner.y = -300;
         }
         this._extendedBanner = false;
         this.localeHandler(null);
      }
      
      public function cleanup() : void
      {
         this.handleCleanup();
         TweenMax.killTweensOf(this);
         if(this._top_banner)
         {
            TweenMax.killTweensOf(this._top_banner);
         }
         if(this._frameLabels)
         {
            this._frameLabels.length = 0;
         }
         if(this._shatterMC)
         {
            this._shatterMC.removeEventListener(Event.ENTER_FRAME,this.checkFrameLabelChanged);
            this._shatterMC = null;
         }
         PlatformInput.dispatcher.removeEventListener(PlatformInput.EVENT_LAST_INPUT,this.onOperationModeChange);
         _context.removeEventListener(GuiContextEvent.LOCALE,this.localeHandler);
         this._textDays.removeEventListener(MouseEvent.ROLL_OUT,this.textDaysRollOutHandler);
         this._textDays.removeEventListener(MouseEvent.ROLL_OVER,this.textDaysRollOverHandler);
         GuiGp.releasePrimaryBitmap(this.gp_start);
         this.gp_start = null;
         this.sagaDispatcher = null;
         this.globalVars = null;
         this.caravanVars = null;
         this._button$options.cleanup();
         this._button$options = null;
         this._banner_renown.cleanup();
         this._banner_renown = null;
         this.listener = null;
         this._saga = null;
         this._timer.cleanup();
         this._timer = null;
         this.textDaysRect = null;
         this._button_morale.cleanup();
         this._button_morale = null;
         this._travelGuiSoundPlayer = null;
         cleanupGuiBase();
      }
      
      protected function update() : void
      {
         if(!this._sagaDispatcher)
         {
            return;
         }
         this.handleUpdate();
         this.mouseEnabled = this._guiEnabled && (this._saga.camped || this._saga.halted || !this._saga.halting);
         this.mouseChildren = this._guiEnabled && (this._saga.camped || this._saga.halted || !this._saga.halting);
         this.sagaVarHandler(null);
         this.caravanVarHandler(null);
      }
      
      private function checkFrameLabelChanged(param1:Event) : void
      {
         if(this._frameLabelEnd.name == this._shatterMC.currentFrameLabel)
         {
            this._shatterMC.removeEventListener(Event.ENTER_FRAME,this.checkFrameLabelChanged);
            this.onFrameLabelEnd(this._frameLabelEnd);
         }
      }
      
      public function playRange(param1:String, param2:String, param3:Function) : void
      {
         var _loc7_:FrameLabel = null;
         var _loc4_:MovieClip = this as MovieClip;
         if(!_loc4_)
         {
            if(param3 != null)
            {
               param3();
            }
            return;
         }
         this._frameLabels = _loc4_.currentLabels;
         var _loc5_:FrameLabel = null;
         var _loc6_:int = 0;
         while(_loc6_ < this._frameLabels.length)
         {
            _loc7_ = this._frameLabels[_loc6_];
            if(_loc7_.name == param2)
            {
               _loc5_ = _loc7_;
               break;
            }
            _loc6_++;
         }
         if(!_loc5_)
         {
            if(param3 != null)
            {
               param3();
            }
            return;
         }
         _loc5_.addEventListener(Event.FRAME_LABEL,this.onFrameLabel);
         this._animationCallback = param3;
         TweenMax.delayedCall(0.5,_loc4_.gotoAndPlay,[param1]);
      }
      
      private function onFrameLabelEnd(param1:FrameLabel) : void
      {
         var _loc2_:MovieClip = this as MovieClip;
         logger.debug("onFrameLabel: " + param1.name);
         if(param1)
         {
            param1.removeEventListener(Event.FRAME_LABEL,this.onFrameLabel);
         }
         if(_loc2_)
         {
            _loc2_.stop();
         }
         if(this._animationCallback != null)
         {
            this._animationCallback();
         }
      }
      
      private function onFrameLabel(param1:Event) : void
      {
         var _loc2_:FrameLabel = param1.currentTarget as FrameLabel;
         this.onFrameLabelEnd(_loc2_);
      }
      
      protected function checkButtonsVisible() : void
      {
         this.gp_start.gplayer = GpBinder.gpbinder.lastCmdId;
         var _loc1_:Boolean = this._activatedGp && (this._extended || this._animating);
         this.gp_start.visible = _loc1_ && PlatformInput.hasClicker;
      }
      
      public function get sagaDispatcher() : IEventDispatcher
      {
         return this._sagaDispatcher;
      }
      
      public function get saga() : ISaga
      {
         return this._saga;
      }
      
      public function set saga(param1:ISaga) : void
      {
         this._saga = param1;
      }
      
      public function get globalVars() : IVariableBag
      {
         return this._globalVars;
      }
      
      public function get caravanVars() : IVariableBag
      {
         return this._caravanVars;
      }
      
      public function set guiEnabled(param1:Boolean) : void
      {
         this._guiEnabled = param1;
         this.update();
      }
      
      public function get guiEnabled() : Boolean
      {
         return this._guiEnabled;
      }
      
      public function set mapEnabled(param1:Boolean) : void
      {
         this._mapEnabled = param1;
         this.update();
      }
      
      public function set campEnabled(param1:Boolean) : void
      {
         this._campEnabled = param1;
         this.update();
      }
      
      public function set sagaDispatcher(param1:IEventDispatcher) : void
      {
         if(this._sagaDispatcher == param1)
         {
            return;
         }
         this.removeSagaDispatcherListeners();
         this._sagaDispatcher = param1;
         this.addSagaDispatcherListeners();
      }
      
      public function set caravanVars(param1:IVariableBag) : void
      {
         if(this._caravanVars == param1)
         {
            return;
         }
         if(this._caravanVars)
         {
            this._caravanVars.removeEventListener(VariableEvent.TYPE,this.caravanVarHandler);
         }
         this._caravanVars = param1;
         if(this._caravanVars)
         {
            this._caravanVars.addEventListener(VariableEvent.TYPE,this.caravanVarHandler);
         }
      }
      
      public function set globalVars(param1:IVariableBag) : void
      {
         if(this._globalVars == param1)
         {
            return;
         }
         if(this._globalVars)
         {
            this._globalVars.removeEventListener(VariableEvent.TYPE,this.sagaVarHandler);
         }
         this._globalVars = param1;
         if(this._globalVars)
         {
            this._globalVars.addEventListener(VariableEvent.TYPE,this.sagaVarHandler);
         }
      }
      
      protected function buttonOptionsHandler(param1:Object) : void
      {
         this.listener.guiTravelOptions();
      }
      
      protected function localeHandler(param1:GuiContextEvent) : void
      {
         this.handleLocaleHandler(param1);
      }
      
      public function activateGp() : void
      {
         this.deactivateGp();
         this._activatedGp = true;
         this.checkButtonsVisible();
         this._button_morale.setHovering(true);
         this._banner_renown.setHovering(true);
         this.setTextDaysHovering(true);
         this.handleActivatedGp();
         this.resizeHandler();
      }
      
      public function deactivateGp() : void
      {
         this._activatedGp = false;
         this._button_morale.setHovering(false);
         this._banner_renown.setHovering(false);
         this.setTextDaysHovering(false);
         this.handleDeactivateGp();
      }
      
      public function handleDeactivateGp() : void
      {
         this.gp_start.visible = false;
      }
      
      public function set extended(param1:Boolean) : void
      {
         this.extendedBanner = param1;
         if(this._extended == param1)
         {
            return;
         }
         this._extended = param1;
         TweenMax.killTweensOf(this);
         this._animating = true;
         if(this._extended)
         {
            TweenMax.to(this,ANIMATE_TIME,{
               "y":0,
               "onComplete":this.animatingCompleteHandler
            });
         }
         else
         {
            TweenMax.to(this,ANIMATE_TIME,{
               "y":-300 * this.scaleY,
               "onComplete":this.animatingCompleteHandler
            });
         }
         this.resizeHandler();
      }
      
      public function get extended() : Boolean
      {
         return this._extended;
      }
      
      public function get animating() : Boolean
      {
         return this._animating;
      }
      
      private function animatingCompleteHandler() : void
      {
         this._animating = false;
         this.resizeHandler();
      }
      
      public function set extendedBanner(param1:Boolean) : void
      {
         if(this._extendedBanner == param1)
         {
            return;
         }
         this._extendedBanner = param1;
         if(!this._top_banner)
         {
            this._animatingBanner = false;
            return;
         }
         TweenMax.killTweensOf(this._top_banner);
         this._animatingBanner = true;
         if(this._extendedBanner)
         {
            TweenMax.to(this._top_banner,ANIMATE_TIME * 2,{
               "y":0,
               "onComplete":this.animatingBannerCompleteHandler
            });
         }
         else
         {
            TweenMax.to(this._top_banner,ANIMATE_TIME * 2,{
               "y":-300,
               "onComplete":this.animatingBannerCompleteHandler
            });
         }
         this.resizeHandler();
      }
      
      public function get extendedBanner() : Boolean
      {
         return this._extendedBanner;
      }
      
      public function get animatingBanner() : Boolean
      {
         return this._animatingBanner;
      }
      
      private function animatingBannerCompleteHandler() : void
      {
         this._animatingBanner = false;
         this.resizeHandler();
      }
      
      public function resizeHandler() : void
      {
         this.checkButtonsVisible();
         this.handleResizeHandler();
         if(!this._activatedGp)
         {
            return;
         }
         this.gp_start.x = this._button$options.x + 60;
         this.gp_start.y = this._button$options.y + 20;
         this.gp_start.updateCaptionPlacement();
      }
      
      public function handleOptionsButton() : void
      {
         if(this.gp_start)
         {
            this.gp_start.pulse();
         }
      }
      
      private function setTextDaysHovering(param1:Boolean) : void
      {
         this._tooltip$days.visible = param1;
      }
      
      private function textDaysRollOutHandler(param1:MouseEvent) : void
      {
         this.setTextDaysHovering(false);
      }
      
      private function textDaysRollOverHandler(param1:MouseEvent) : void
      {
         this.setTextDaysHovering(true);
      }
      
      protected function sagaVarHandler(param1:VariableEvent) : void
      {
         if(!param1 || param1.value.def.name == SagaVar.VAR_DAY)
         {
            if(this.shatterInProgress)
            {
               return;
            }
            if(this._globalVars)
            {
               this.days = this._globalVars.fetch(SagaVar.VAR_DAY,null).asNumber;
            }
         }
      }
      
      public function get days() : Number
      {
         return this._days;
      }
      
      public function set days(param1:Number) : void
      {
         var _loc3_:Number = NaN;
         if(!this._timer)
         {
            return;
         }
         this._timer.day = param1;
         if(this._days == int(param1))
         {
            return;
         }
         var _loc2_:int = this._days;
         this._days = param1;
         this._textDays.text = this._days.toString();
         if(_loc2_ != DEFAULT_DAYS)
         {
            _loc3_ = 1.5;
            this._textDays.scaleX = this._textDays.scaleY = 1.5;
            this._textDays.x = this.textDaysRect.x + (this.textDaysRect.width - this.textDaysRect.width * _loc3_) / 2;
            this._textDays.y = this.textDaysRect.y + (this.textDaysRect.height - this.textDaysRect.height * _loc3_) / 2;
            TweenMax.to(this._textDays,0.25,{
               "scaleX":1,
               "scaleY":1,
               "x":this.textDaysRect.x,
               "y":this.textDaysRect.y
            });
            this.playDayChangeSound();
         }
      }
      
      public function playDayChangeSound() : void
      {
         if(!this._saga || this._saga.hudTravelHidden || this._saga.soundDaySuppressed)
         {
            return;
         }
         if(!this._saga.isSceneLoaded())
         {
            return;
         }
         if(Boolean(this._travelGuiSoundPlayer) && !this._travelGuiSoundPlayer.cleanedUp)
         {
            this._travelGuiSoundPlayer.playDayIncrementSound();
            return;
         }
         if(this.saga.getVarInt(SagaVar.VAR_TRAVEL_HUD_APPEARANCE) == SagaVar.TRAVEL_HUD_APPEARANCE_DARK_SHATTERED || this.saga.getVarInt(SagaVar.VAR_TRAVEL_HUD_APPEARANCE) == SagaVar.TRAVEL_HUD_APPEARANCE_DARKNESS)
         {
            if(this._days == 0)
            {
               context.playSound("ui_drk_cntdwn_zero");
            }
            else if(this._saga.doomsdayChoiceSoundEnabled)
            {
               context.playSound("ui_drk_cntdwn_choice");
            }
            else
            {
               context.playSound("ui_drk_cntdwn_travel");
            }
         }
         else
         {
            context.playSound("ui_day_counter");
         }
      }
      
      private function onOperationModeChange(param1:Event) : void
      {
         this._button$options.visible = PlatformInput.hasClicker || !PlatformInput.lastInputGp;
      }
   }
}
