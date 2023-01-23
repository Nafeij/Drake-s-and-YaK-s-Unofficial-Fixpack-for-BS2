package game.gui.pages
{
   import com.greensock.TweenMax;
   import com.stoicstudio.platform.Platform;
   import com.stoicstudio.platform.PlatformInput;
   import engine.core.locale.LocaleCategory;
   import engine.core.logging.Log;
   import engine.core.util.StringUtil;
   import engine.gui.GuiContextEvent;
   import engine.gui.GuiGpAlignH;
   import engine.gui.GuiGpNav;
   import engine.saga.SagaDef;
   import engine.saga.SagaEvent;
   import engine.saga.SagaVar;
   import engine.user.UserEvent;
   import engine.user.UserLifecycleManager;
   import flash.events.Event;
   import flash.text.TextFieldAutoSize;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.GuiSagaStartConfig;
   import game.gui.IGuiContext;
   import game.gui.page.IGuiSagaStart;
   import game.gui.page.IGuiSagaStartListener;
   
   public class GuiSagaStart extends GuiBase implements IGuiSagaStart
   {
      
      private static const PREF_RECAP_WATCHED:String = "PREF_RECAP_WATCHED";
       
      
      public var listener:IGuiSagaStartListener;
      
      public var _button$xbox_gamertag:ButtonWithIndex;
      
      public var _button$resume:ButtonWithIndex;
      
      public var _button$start_game:ButtonWithIndex;
      
      public var _button$recap_tbs1:ButtonWithIndex;
      
      public var _button$load_game:ButtonWithIndex;
      
      public var _button$heraldry:ButtonWithIndex;
      
      public var _button$options:ButtonWithIndex;
      
      public var _button$credits:ButtonWithIndex;
      
      public var _button$quit:ButtonWithIndex;
      
      public var _button_tbs2_buynow:ButtonWithIndex;
      
      public var _button_tbs2_survival:ButtonWithIndex;
      
      public var _button$start_tutorial:ButtonWithIndex;
      
      public var _button$cart_picker_banner:ButtonWithIndex;
      
      public var nav:GuiGpNav;
      
      public var buttons:Vector.<ButtonWithIndex>;
      
      private var userName:String;
      
      private var _showRecap:Boolean;
      
      public function GuiSagaStart()
      {
         this.buttons = new Vector.<ButtonWithIndex>();
         stop();
         super();
         super.visible = false;
         UserLifecycleManager.Instance().addEventListener(UserEvent.ACCOUNT_PICKER_OPENED,this.onAccountPickerOpened);
         UserLifecycleManager.Instance().addEventListener(UserEvent.ACCOUNT_PICKER_CLOSED,this.onAccountPickerClosed);
      }
      
      public function cleanup() : void
      {
         this._button$xbox_gamertag.cleanup();
         this._button$resume.cleanup();
         this._button$start_game.cleanup();
         this._button$recap_tbs1.cleanup();
         this._button$load_game.cleanup();
         this._button$options.cleanup();
         this._button$heraldry.cleanup();
         this._button$credits.cleanup();
         this._button$quit.cleanup();
         this._button_tbs2_buynow.cleanup();
         this._button_tbs2_survival.cleanup();
         this._button$cart_picker_banner.cleanup();
         this._button$start_tutorial.cleanup();
         _context.removeEventListener(GuiContextEvent.LOCALE,this.localeHandler);
         TweenMax.killTweensOf(this._button_tbs2_buynow);
         TweenMax.killTweensOf(this._button_tbs2_survival);
         TweenMax.killTweensOf(this._button$cart_picker_banner);
         UserLifecycleManager.Instance().removeEventListener(UserEvent.ACCOUNT_PICKER_OPENED,this.onAccountPickerOpened);
         UserLifecycleManager.Instance().removeEventListener(UserEvent.ACCOUNT_PICKER_CLOSED,this.onAccountPickerClosed);
         this.nav.cleanup();
         this.nav = null;
      }
      
      public function init(param1:IGuiContext, param2:IGuiSagaStartListener, param3:Boolean, param4:Boolean, param5:Boolean, param6:Boolean, param7:String = null) : void
      {
         var _loc8_:Boolean = false;
         var _loc9_:ButtonWithIndex = null;
         var _loc10_:Boolean = false;
         super.initGuiBase(param1);
         this.listener = param2;
         this.userName = param7;
         _loc8_ = false;
         if(param7 != null && param7.length > 0)
         {
            Log.getLogger("TBS-0").info("User received GUISagaStart: " + param7);
            _loc8_ = true;
         }
         else
         {
            Log.getLogger("TBS-0").info("No user receieved GUISagaStart: " + param7);
         }
         this._button$xbox_gamertag = requireGuiChild("button$xbox_gamertag") as ButtonWithIndex;
         this._button$xbox_gamertag.blockLocalization = true;
         this._button$xbox_gamertag.isHtmlText = false;
         this._button$resume = requireGuiChild("button$resume") as ButtonWithIndex;
         this._button$start_game = requireGuiChild("button$start_game") as ButtonWithIndex;
         this._button$recap_tbs1 = requireGuiChild("button$recap_tbs1") as ButtonWithIndex;
         this._button$load_game = requireGuiChild("button$load_game") as ButtonWithIndex;
         this._button$options = requireGuiChild("button$options") as ButtonWithIndex;
         this._button$credits = requireGuiChild("button$credits") as ButtonWithIndex;
         this._button$quit = requireGuiChild("button$quit") as ButtonWithIndex;
         this._button$heraldry = requireGuiChild("button$heraldry") as ButtonWithIndex;
         this._button_tbs2_buynow = requireGuiChild("button_tbs2_buynow") as ButtonWithIndex;
         this._button_tbs2_survival = requireGuiChild("button_tbs2_survival") as ButtonWithIndex;
         this._button$cart_picker_banner = requireGuiChild("button_cart_picker_banner") as ButtonWithIndex;
         this._button$start_tutorial = requireGuiChild("button$start_tutorial") as ButtonWithIndex;
         this._button_tbs2_buynow.visible = Platform._showBuyTbs2Func != null;
         this._button_tbs2_buynow.x = this._button_tbs2_buynow.width;
         this._button_tbs2_survival.visible = param5 && SagaDef.SURVIVAL_ENABLED;
         this._button_tbs2_survival.x = -this._button_tbs2_survival.width;
         this._button$cart_picker_banner.visible = param1.saga.getVarBool(SagaVar.VAR_CART_PICKER_ENABLED);
         this._button$cart_picker_banner.x = -this._button$cart_picker_banner.width;
         this._button$start_tutorial.visible = param1.saga.getVarBool(SagaVar.VAR_START_MENU_TUTORIAL_ENABLED);
         this._showRecap = param6;
         this._button$recap_tbs1.visible = param6;
         this.buttons.push(this._button$resume);
         this.buttons.push(this._button$start_game);
         if(this._button$recap_tbs1.visible)
         {
            this.buttons.push(this._button$recap_tbs1);
         }
         this.buttons.push(this._button$load_game);
         this.buttons.push(this._button$options);
         this.buttons.push(this._button$credits);
         this.buttons.push(this._button$heraldry);
         this.buttons.push(this._button$quit);
         if(this._button_tbs2_buynow.visible)
         {
            this.buttons.push(this._button_tbs2_buynow);
         }
         if(this._button$start_tutorial.visible)
         {
            this.buttons.push(this._button$start_tutorial);
         }
         for each(_loc9_ in this.buttons)
         {
            _loc9_.autoSizeText = TextFieldAutoSize.RIGHT;
         }
         _loc10_ = Boolean(_context.saga) && Boolean(_context.saga.parentSagaUrl);
         this._button$quit.visible = GuiSagaStartConfig.ENABLE_QUIT || _loc10_;
         this._button$xbox_gamertag.y = -792;
         this._button$xbox_gamertag.visible = _loc8_;
         this._button$xbox_gamertag.guiButtonContext = param1;
         this._button$resume.guiButtonContext = param1;
         this._button$start_game.guiButtonContext = param1;
         this._button$recap_tbs1.guiButtonContext = param1;
         this._button$load_game.guiButtonContext = param1;
         this._button$options.guiButtonContext = param1;
         this._button$credits.guiButtonContext = param1;
         this._button$quit.guiButtonContext = param1;
         this._button$heraldry.guiButtonContext = param1;
         this._button_tbs2_buynow.guiButtonContext = param1;
         this._button_tbs2_survival.guiButtonContext = param1;
         this._button$cart_picker_banner.guiButtonContext = param1;
         this._button$start_tutorial.guiButtonContext = param1;
         this._button$xbox_gamertag.setDownFunction(this.buttonDownHandler);
         this._button$heraldry.setDownFunction(this.buttonDownHandler);
         this._button$resume.setDownFunction(this.buttonDownHandler);
         this._button$start_game.setDownFunction(this.buttonDownHandler);
         this._button$recap_tbs1.setDownFunction(this.buttonDownHandler);
         this._button$load_game.setDownFunction(this.buttonDownHandler);
         this._button$options.setDownFunction(this.buttonDownHandler);
         this._button$credits.setDownFunction(this.buttonDownHandler);
         this._button$quit.setDownFunction(this.buttonDownHandler);
         this._button_tbs2_buynow.setDownFunction(this.buttonDownHandler);
         this._button_tbs2_survival.setDownFunction(this.buttonDownHandler);
         this._button$cart_picker_banner.setDownFunction(this.buttonDownHandler);
         this._button$start_tutorial.setDownFunction(this.buttonDownHandler);
         this.updateState(param3,param4);
         this._button$start_game.visible = true;
         if(Platform.id != "xbo")
         {
            removeChild(this._button$xbox_gamertag);
            this._button$xbox_gamertag.visible = false;
         }
         this._checkDemoButtons();
         this.buildNav();
         _context.addEventListener(GuiContextEvent.LOCALE,this.localeHandler);
         this.localeHandler(null);
      }
      
      private function _checkDemoButtons() : void
      {
         var _loc1_:ButtonWithIndex = null;
         if(!GuiSagaStartConfig.DEMO_MODE)
         {
            return;
         }
         for each(_loc1_ in this.buttons)
         {
            _loc1_.visible = _loc1_ == this._button$start_game;
            _loc1_.enabled = _loc1_ == this._button$start_game;
         }
      }
      
      public function handleStartPageResized() : void
      {
         this._handleLeftSideButtons(this._button_tbs2_survival);
         this._handleLeftSideButtons(this._button$cart_picker_banner);
      }
      
      private function _handleLeftSideButtons(param1:ButtonWithIndex) : void
      {
         if(param1.visible)
         {
            TweenMax.killTweensOf(param1);
            param1.x = (-this.x - parent.x) / this.scaleX;
            if(!this.visible)
            {
               param1.x -= param1.width;
            }
            else
            {
               this.buildNav();
            }
         }
      }
      
      override public function set visible(param1:Boolean) : void
      {
         super.visible = param1;
         if(param1)
         {
            if(this.nav)
            {
               this.nav.activate();
            }
            if(_context.saga.paused)
            {
               _context.saga.dispatchEvent(new Event(SagaEvent.EVENT_REFRESH_PAUSE_BINDING));
            }
            if(Boolean(this._button_tbs2_buynow) && this._button_tbs2_buynow.visible)
            {
               if(this._button_tbs2_buynow.x > 0)
               {
                  TweenMax.to(this._button_tbs2_buynow,0.5,{
                     "x":0,
                     "delay":0.5,
                     "onComplete":this.buildNav
                  });
               }
            }
            this._showLeftBanner(this._button_tbs2_survival);
            this._showLeftBanner(this._button$cart_picker_banner);
         }
         else if(this.nav)
         {
            this.nav.deactivate();
         }
      }
      
      private function _showLeftBanner(param1:ButtonWithIndex) : void
      {
         var _loc2_:Number = NaN;
         if(Boolean(param1) && param1.visible)
         {
            _loc2_ = (-this.x - parent.x) / this.scaleX;
            if(param1.x != _loc2_)
            {
               TweenMax.to(param1,0.5,{
                  "x":_loc2_,
                  "delay":0.5,
                  "onComplete":this.buildNav
               });
            }
         }
      }
      
      public function buildNav() : void
      {
         var _loc1_:Object = null;
         if(this.nav)
         {
            _loc1_ = this.nav.selected;
            this.nav.cleanup();
         }
         this.nav = new GuiGpNav(context,"start",this);
         this.nav.setAlignControlDefault(GuiGpAlignH.E_RIGHT,null);
         if(this._button$xbox_gamertag.visible)
         {
            this.nav.add(this._button$xbox_gamertag);
         }
         if(this._button$recap_tbs1.visible)
         {
            this.nav.add(this._button$recap_tbs1);
         }
         if(this._button$start_tutorial.visible)
         {
            this.nav.add(this._button$start_tutorial);
         }
         this.nav.add(this._button$resume);
         this.nav.add(this._button$start_game);
         this.nav.add(this._button$load_game);
         this.nav.add(this._button$options);
         this.nav.add(this._button$credits);
         this.nav.add(this._button$quit);
         this.nav.add(this._button$heraldry);
         if(this._button_tbs2_buynow.visible)
         {
            this.nav.add(this._button_tbs2_buynow);
         }
         if(this._button_tbs2_survival.visible)
         {
            this.nav.add(this._button_tbs2_survival);
         }
         if(this._button$cart_picker_banner.visible)
         {
            this.nav.add(this._button$cart_picker_banner);
         }
         if(_loc1_)
         {
            this.nav.selected = _loc1_;
         }
         else if(PlatformInput.lastInputGp)
         {
            this.setNavSelection();
         }
         if(super.visible)
         {
            this.nav.activate();
         }
         _context.addEventListener(GuiContextEvent.LOCALE,this.localeHandler);
         this.localeHandler(null);
      }
      
      private function onAccountPickerOpened(param1:Event) : void
      {
         if(this.nav)
         {
            this.nav.blockNav = true;
         }
      }
      
      private function onAccountPickerClosed(param1:Event) : void
      {
         if(this.nav)
         {
            this.nav.blockNav = false;
         }
      }
      
      public function updateUsernameText() : void
      {
         var _loc1_:String = null;
         var _loc2_:int = 0;
         if(UserLifecycleManager.Instance().userName != null)
         {
            _loc1_ = UserLifecycleManager.Instance().userName;
            if(UserLifecycleManager.Instance().userNeedsTranslation)
            {
               _loc1_ = _context.translateCategory(_loc1_,LocaleCategory.PLATFORM);
            }
            _loc2_ = 40;
            this._button$xbox_gamertag.buttonText = StringUtil.truncate(_loc1_,_loc2_);
            this._button$xbox_gamertag.visible = true;
         }
      }
      
      public function updateState(param1:Boolean, param2:Boolean) : void
      {
         this._button$resume.enabled = param1;
         this._button$load_game.enabled = param2;
         if(this.nav && this.nav.selected && !this.nav.selected.enabled)
         {
            this.setNavSelection();
         }
      }
      
      private function setNavSelection() : void
      {
         if(this._button$resume.enabled)
         {
            this.nav.selected = this._button$resume;
         }
         else if(this._button$load_game.enabled)
         {
            this.nav.selected = this._button$load_game;
         }
         else
         {
            this.nav.selected = this._button$start_game;
         }
      }
      
      private function localeHandler(param1:GuiContextEvent) : void
      {
         this.updateUsernameText();
      }
      
      public function setupButtonSizes() : void
      {
         var pos:Number;
         var spacing:Number;
         var i:int;
         this.buttons = this.buttons.sort(function(param1:ButtonWithIndex, param2:ButtonWithIndex):int
         {
            if(param1.y > param2.y)
            {
               return -1;
            }
            if(param1.y < param2.y)
            {
               return 1;
            }
            return 0;
         });
         pos = this.buttons[0].y;
         spacing = -55.45;
         i = 1;
         while(i < this.buttons.length)
         {
            if(this.buttons[i].visible)
            {
               this.buttons[i].y = pos + spacing;
               pos += spacing;
            }
            i++;
         }
      }
      
      private function buttonDownHandler(param1:ButtonWithIndex) : void
      {
         switch(param1)
         {
            case this._button$xbox_gamertag:
               this.listener.guiSagaStartUser();
               return;
            case this._button$recap_tbs1:
               if(this._showRecap)
               {
                  _context.setPref(PREF_RECAP_WATCHED,true);
                  this.listener.guiSagaStartRecap("unused stuff");
               }
               return;
            case this._button$resume:
               this.listener.guiSagaStartResume();
               return;
            case this._button$start_game:
               this.listener.guiSagaStartStart(null);
               return;
            case this._button$load_game:
               this.listener.guiSagaStartLoad();
               return;
            case this._button$options:
               this.listener.guiSagaStartOptions();
               return;
            case this._button$heraldry:
               this.listener.guiSagaStartHeraldry();
               return;
            case this._button$credits:
               this.listener.guiSagaStartCredits();
               return;
            case this._button$quit:
               this.listener.guiSagaStartQuit();
               return;
            case this._button_tbs2_buynow:
               this.listener.guiSagaTbs2BuyNow();
               return;
            case this._button_tbs2_survival:
               this.listener.guiSagaTbs2Survival();
               return;
            case this._button$cart_picker_banner:
               this.listener.guiSagaStartCartPicker();
               return;
            case this._button$start_tutorial:
               this.listener.guiSagaStartTutorial();
         }
      }
   }
}
