package game.view
{
   import com.stoicstudio.platform.PlatformInput;
   import com.stoicstudio.platform.PlatformStarling;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.locale.LocaleCategory;
   import engine.core.util.AppInfo;
   import engine.core.util.StringUtil;
   import engine.gui.PagesOverlayMonitor;
   import engine.gui.page.PageManagerAdapter;
   import engine.gui.page.PageState;
   import engine.input.InputDeviceEvent;
   import engine.saga.Saga;
   import engine.saga.SagaCreditsDef;
   import engine.saga.SagaDef;
   import engine.saga.action.Action;
   import engine.saga.action.ActionType;
   import engine.saga.action.Action_TutorialPopup;
   import engine.saga.convo.Convo;
   import engine.saga.convo.ConvoEvent;
   import engine.session.NewsDef;
   import engine.user.UserEvent;
   import engine.user.UserLifecycleManager;
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.ui.Keyboard;
   import flash.utils.Timer;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   import game.gui.GuiIconSlot;
   import game.gui.IGuiContext;
   import game.gui.IGuiDialog;
   import game.gui.page.AssembleHeroesPage;
   import game.gui.page.CreditsPage;
   import game.gui.page.FlashPage;
   import game.gui.page.FriendLobbyPage;
   import game.gui.page.GameLoadingPage;
   import game.gui.page.GreatHallPage;
   import game.gui.page.HallOfValorPage;
   import game.gui.page.HeroesPage;
   import game.gui.page.LoginPage;
   import game.gui.page.LoginQueuePage;
   import game.gui.page.MainMenuPage;
   import game.gui.page.MapCampPage;
   import game.gui.page.MeadHousePage;
   import game.gui.page.NewsPage;
   import game.gui.page.PoppeningPage;
   import game.gui.page.ProvingGroundsPage;
   import game.gui.page.SagaNewGamePage;
   import game.gui.page.SagaOptionsPage;
   import game.gui.page.SagaSelectorPage;
   import game.gui.page.SagaSurvivalBattlePopupPage;
   import game.gui.page.SagaSurvivalStartPage;
   import game.gui.page.SagaSurvivalWinPage;
   import game.gui.page.SaveLoadPage;
   import game.gui.page.SaveProfilePage;
   import game.gui.page.SaveProfilePageMode;
   import game.gui.page.ScenePage;
   import game.gui.page.StartPage;
   import game.gui.page.TallyPage;
   import game.gui.page.TownPage;
   import game.gui.page.VersusPage;
   import game.gui.page.VideoPage;
   import game.gui.page.WarPage;
   import game.session.states.AssembleHeroesState;
   import game.session.states.AuthFailedState;
   import game.session.states.FlashState;
   import game.session.states.FriendLobbyState;
   import game.session.states.GreatHallState;
   import game.session.states.HallOfValorState;
   import game.session.states.HeroesState;
   import game.session.states.LoginQueueState;
   import game.session.states.MainMenuState;
   import game.session.states.MapCampState;
   import game.session.states.MeadHouseState;
   import game.session.states.PreAuthState;
   import game.session.states.ProvingGroundsState;
   import game.session.states.SagaNewGameState;
   import game.session.states.SagaSelectorState;
   import game.session.states.SagaSurvivalStartState;
   import game.session.states.SagaSurvivalWinState;
   import game.session.states.SceneState;
   import game.session.states.StartState;
   import game.session.states.StartupWarningState;
   import game.session.states.TownState;
   import game.session.states.VersusFindMatchState;
   import game.session.states.VersusMatchedState;
   import game.session.states.VideoState;
   import game.session.states.VideoTutorial1State;
   import game.session.states.VideoTutorial2State;
   import game.view.tutorial.RegisterTutorialPages;
   
   public class GamePageManagerAdapter extends PageManagerAdapter
   {
      
      public static const EVENT_POPPENING:String = "PageManagerAdapter.EVENT_POPPENING";
      
      public static var mcVideoPage:Class = VideoPage;
      
      private static var _OPTION_INTERRUPT_SAVE_LOAD:int = 0;
      
      private static var _OPTION_INTERRUPT_PROFILE_PAGE:int = 1;
       
      
      public var config:GameConfig;
      
      public var marketplace:GamePageManagerAdapterMarketplace;
      
      public var sagaMarket:GamePageManagerAdapterSagaMarket;
      
      public var sagaHeraldry:GamePageManagerAdapterSagaHeraldry;
      
      public var sagaCartPicker:GamePageManagerAdapterCartPicker;
      
      public var poppeningPage:PoppeningPage;
      
      public var warPage:WarPage;
      
      public var newsPage:NewsPage;
      
      public var saveLoadPage:SaveLoadPage;
      
      public var saveProfilePage:SaveProfilePage;
      
      public var sagaOptionsPage:SagaOptionsPage;
      
      public var creditsPage:CreditsPage;
      
      private var cmd_esc:Cmd;
      
      private var cmd_back:Cmd;
      
      private var cmd_menu:Cmd;
      
      public var tutorialLayer:TutorialLayer;
      
      public var loadingOverlayLayer:LoadingOverlayLayer;
      
      public var subtitle:GameSubtitlesAdapter;
      
      private var _optionsInterrupted:int = 0;
      
      private var gameLoadingPage:GameLoadingPage;
      
      public var LAYER_NEWS:int = 1;
      
      public var LAYER_PP:int = 2;
      
      public var LAYER_TUTORIAL:int = 3;
      
      public var LAYER_OPTIONS:int = 4;
      
      public var LAYER_SAVE_LOAD:int = 5;
      
      public var LAYER_SAVE_PROFILE:int = 6;
      
      public var LAYER_CREDITS:int = 7;
      
      public var LAYER_LOADING:int = 8;
      
      private var userLostPrompt:IGuiDialog;
      
      private var controllerLostPrompt:IGuiDialog;
      
      public var optionsPageMonitor:PagesOverlayMonitor;
      
      private var sagaSurvivalBattlePopupPage:SagaSurvivalBattlePopupPage;
      
      public function GamePageManagerAdapter(param1:GameConfig, param2:DisplayObjectContainer, param3:int)
      {
         this.cmd_esc = new Cmd("cmd_esc_pma",this.cmdfunc_esc);
         this.cmd_back = new Cmd("cmd_back_pma",this.cmdfunc_back);
         this.cmd_menu = new Cmd("cmd_menu_pma",this.cmdfunc_menu);
         this.optionsPageMonitor = new PagesOverlayMonitor();
         this.cmd_menu.global = true;
         this.gameLoadingPage = new GameLoadingPage(param1);
         super(param1.context,param1.fsm,this.gameLoadingPage,param2,param3,this.LAYER_LOADING);
         this.config = param1;
         pageCtor = this.pageCtorFunc;
         registerFsmStatePageClass(PreAuthState,LoginPage);
         registerFsmStatePageClass(AuthFailedState,LoginPage);
         registerFsmStatePageClass(StartState,StartPage);
         registerFsmStatePageClass(MainMenuState,MainMenuPage);
         registerFsmStatePageClass(TownState,TownPage);
         registerFsmStatePageClass(GreatHallState,GreatHallPage);
         registerFsmStatePageClass(VersusFindMatchState,VersusPage);
         registerFsmStatePageClass(VersusMatchedState,VersusPage);
         registerFsmStatePageClass(SceneState,ScenePage);
         registerFsmStatePageClass(MapCampState,MapCampPage);
         registerFsmStatePageClass(ProvingGroundsState,ProvingGroundsPage);
         registerFsmStatePageClass(AssembleHeroesState,AssembleHeroesPage);
         registerFsmStatePageClass(HeroesState,HeroesPage);
         registerFsmStatePageClass(SagaSelectorState,SagaSelectorPage);
         registerFsmStatePageClass(HallOfValorState,HallOfValorPage);
         registerFsmStatePageClass(LoginQueueState,LoginQueuePage);
         registerFsmStatePageClass(MeadHouseState,MeadHousePage);
         registerFsmStatePageClass(FriendLobbyState,FriendLobbyPage);
         registerFsmStatePageClass(VideoState,mcVideoPage);
         registerFsmStatePageClass(FlashState,FlashPage);
         registerFsmStatePageClass(StartupWarningState,FlashPage);
         registerFsmStatePageClass(SagaNewGameState,SagaNewGamePage);
         registerFsmStatePageClass(SagaSurvivalStartState,SagaSurvivalStartPage);
         registerFsmStatePageClass(SagaSurvivalWinState,SagaSurvivalWinPage);
         registerFsmStatePageClass(VideoTutorial1State,mcVideoPage);
         registerFsmStatePageClass(VideoTutorial2State,mcVideoPage);
         RegisterTutorialPages.register(this);
         PlatformInput.dispatcher.addEventListener(PlatformInput.EVENT_LAST_INPUT,this.handleInputDeviceChanged);
         UserLifecycleManager.Instance().addEventListener(InputDeviceEvent.CONTROLLER_LOST,this.createControllerLostPrompt);
         UserLifecycleManager.Instance().addEventListener(UserEvent.ACTIVE_USER_LOST,this.handleActiveUserLost);
      }
      
      public function handleConfigReady(param1:GameConfig) : void
      {
         handleFsmReady(param1.fsm);
         param1.keybinder.bind(false,false,false,Keyboard.ESCAPE,this.cmd_esc,"");
         param1.keybinder.bind(false,false,false,Keyboard.BACK,this.cmd_back,"");
         param1.gpbinder.bindPress(GpControlButton.START,this.cmd_menu,"");
         this.marketplace = new GamePageManagerAdapterMarketplace(this);
         this.sagaMarket = new GamePageManagerAdapterSagaMarket(this);
         this.sagaHeraldry = new GamePageManagerAdapterSagaHeraldry(this);
         this.sagaCartPicker = new GamePageManagerAdapterCartPicker(this);
         this.poppeningPage = new PoppeningPage(param1,null);
         this.poppeningPage.manager = this;
         this.poppeningPage.start();
         this.warPage = new WarPage(param1,null);
         this.warPage.manager = this;
         this.warPage.start();
         this.newsPage = new NewsPage(param1);
         this.newsPage.manager = this;
         this.newsPage.start();
         this.saveLoadPage = new SaveLoadPage(param1);
         this.saveLoadPage.manager = this;
         this.saveLoadPage.start();
         this.saveProfilePage = new SaveProfilePage(param1);
         this.saveProfilePage.manager = this;
         this.saveProfilePage.start();
         this.sagaOptionsPage = new SagaOptionsPage(param1);
         this.sagaOptionsPage.manager = this;
         this.sagaOptionsPage.start();
         this.sagaOptionsPage.visible = false;
         this.subtitle = new GameSubtitlesAdapter(param1,holder);
         this.tutorialLayer = new TutorialLayer(param1.logger,this);
         this.tutorialLayer.context = param1.gameGuiContext;
         param1.tutorialLayer = this.tutorialLayer;
         this.loadingOverlayLayer = new LoadingOverlayLayer(param1.logger,this);
         this.setRect(rect.x,rect.y,rect.width,rect.height);
         this.gameLoadingPage.doTranslation();
      }
      
      override public function update(param1:int) : void
      {
         super.update(param1);
         if(this.tutorialLayer && this.tutorialLayer.parent && this.tutorialLayer.visible)
         {
            this.tutorialLayer.update(param1);
         }
         if(this.loadingOverlayLayer && this.loadingOverlayLayer.parent && this.loadingOverlayLayer.visible)
         {
            this.loadingOverlayLayer.update(param1);
         }
         if(this.sagaOptionsPage && this.sagaOptionsPage.parent && this.sagaOptionsPage.visible)
         {
            this.sagaOptionsPage.update(param1);
         }
         if(this.creditsPage && this.creditsPage.parent && this.creditsPage.visible)
         {
            this.creditsPage.update(param1);
         }
         if(this.sagaMarket)
         {
            this.sagaMarket.update(param1);
         }
         if(this.saveProfilePage && this.saveProfilePage.parent && this.saveProfilePage.visible)
         {
            this.saveProfilePage.update(param1);
         }
         if(this.poppeningPage && this.poppeningPage.parent && this.poppeningPage.visible)
         {
            this.poppeningPage.update(param1);
         }
      }
      
      private function isOverlayPageRendering(param1:GamePage) : Boolean
      {
         return param1 && param1.parent && param1.visible && param1.state == PageState.READY;
      }
      
      override protected function get canRenderNullCurrentPage() : Boolean
      {
         return this.isOverlayPageRendering(this.sagaOptionsPage) || this.isOverlayPageRendering(this.creditsPage) || this.isOverlayPageRendering(this.poppeningPage);
      }
      
      override public function cleanup() : void
      {
         super.cleanup();
         if(this.sagaMarket)
         {
            this.sagaMarket.cleanup();
            this.sagaMarket = null;
         }
         if(Boolean(this.config) && Boolean(this.config.keybinder))
         {
            this.config.keybinder.unbind(this.cmd_esc);
            this.config.keybinder.unbind(this.cmd_back);
         }
         GpBinder.gpbinder.unbind(this.cmd_menu);
         this.cmd_menu.cleanup();
         this.cmd_back.cleanup();
         this.cmd_esc.cleanup();
         this.cmd_back = null;
         this.cmd_esc = null;
         PlatformInput.dispatcher.removeEventListener(PlatformInput.EVENT_LAST_INPUT,this.handleInputDeviceChanged);
         UserLifecycleManager.Instance().removeEventListener(InputDeviceEvent.CONTROLLER_LOST,this.createControllerLostPrompt);
         UserLifecycleManager.Instance().removeEventListener(UserEvent.ACTIVE_USER_LOST,this.handleActiveUserLost);
      }
      
      public function cmdfunc_esc(param1:CmdExec) : void
      {
         if(this.config.dialogLayer.isShowingDialog || this.saveLoadPage.parent || this.newsPage.parent || this.saveProfilePage.parent || ScenePage.needsUserEngagementPrompt)
         {
            return;
         }
         this.showOptions();
      }
      
      public function cmdfunc_back(param1:CmdExec) : void
      {
         if(this.config.dialogLayer.isShowingDialog || this.saveLoadPage.parent || this.newsPage.parent || Boolean(this.saveProfilePage.parent))
         {
            return;
         }
         this.showOptions();
      }
      
      public function cmdfunc_menu(param1:CmdExec) : void
      {
         if(this.config.dialogLayer.isShowingDialog)
         {
            return;
         }
         var _loc2_:GamePage = currentPage as GamePage;
         if(_loc2_)
         {
            _loc2_.handleOptionsButton();
         }
         this.toggleOptions();
      }
      
      private function pageCtorFunc(param1:Class) : GamePage
      {
         return new param1(this.config) as GamePage;
      }
      
      private function controllerReestablished() : void
      {
         if(this.controllerLostPrompt)
         {
            this.controllerLostPrompt.closeDialog(null);
            this.controllerLostPrompt = null;
         }
      }
      
      private function createControllerLostPrompt() : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         logger.info("Creating controller lost prompt");
         var _loc1_:IGuiContext = this.config.gameGuiContext;
         var _loc2_:IGuiDialog = _loc1_.createDialog();
         _loc4_ = _loc1_.translateCategory("controller_lost_title",LocaleCategory.PLATFORM);
         _loc3_ = _loc1_.translateCategory("controller_lost_message",LocaleCategory.PLATFORM);
         _loc2_.openDialog(_loc4_,_loc3_,null);
         UserLifecycleManager.Instance().addEventListener(InputDeviceEvent.CONTROLLER_REESTABLISHED,this.controllerReestablished);
         this.controllerLostPrompt = _loc2_;
      }
      
      private function handleActiveUserLost() : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         logger.info("Creating active user lost prompt");
         var _loc1_:IGuiContext = this.config.gameGuiContext;
         var _loc2_:IGuiDialog = _loc1_.createDialog();
         this.userLostPrompt = _loc2_;
         _loc4_ = _loc1_.translateCategory("active_user_lost_title",LocaleCategory.PLATFORM);
         _loc3_ = _loc1_.translateCategory("active_user_lost_body",LocaleCategory.PLATFORM);
         _loc2_.openNoButtonDialog(_loc4_,_loc3_,null);
         var _loc5_:Timer = new Timer(5000,1);
         this.config.saga.pause(this);
         _loc5_.addEventListener(TimerEvent.TIMER_COMPLETE,this.handleResetTimerComplete);
         _loc5_.start();
      }
      
      private function handleResetTimerComplete(param1:Event) : void
      {
         param1.target.removeEventListener(TimerEvent.TIMER_COMPLETE,this.handleResetTimerComplete);
         this.userLostPrompt.closeDialog(null);
         this.userLostPrompt = null;
         ScenePage.needsUserEngagementPrompt = true;
         this.config.saga.unpause(this);
         this.config.saga.showStartPage(true);
      }
      
      public function escapeFromMarket() : Boolean
      {
         return this.marketplace.escapeFromMarket();
      }
      
      public function showNews(param1:NewsDef, param2:int) : void
      {
         this.newsPage.setNews(param1,param2);
         if(!this.newsPage.parent)
         {
            addHolderChild(this.newsPage,1);
            if(Boolean(this.newsPage) && Boolean(this.newsPage.stage))
            {
               this.newsPage.stage.focus = this.newsPage;
            }
         }
      }
      
      public function hideNews() : void
      {
         if(this.newsPage.parent)
         {
            this.newsPage.parent.removeChild(this.newsPage);
            if(Boolean(currentPage) && Boolean(currentPage.stage))
            {
               currentPage.stage.focus = currentPage;
            }
         }
      }
      
      public function showSaveLoad(param1:Boolean, param2:int, param3:Boolean) : void
      {
         if(Saga.PROFILE_ENABLED)
         {
            if(param2 < 0)
            {
               this.showSaveProfileLoad(false);
               return;
            }
         }
         this.hideSaveProfile();
         if(!this.saveLoadPage.parent)
         {
            addHolderChild(this.saveLoadPage,this.LAYER_SAVE_LOAD + this.poppeningIndexModifier);
            if(Boolean(this.saveLoadPage) && Boolean(this.saveLoadPage.stage))
            {
               this.saveLoadPage.stage.focus = this.saveLoadPage;
            }
            this.saveLoadPage.showSaveLoad(param1,param2,param3);
         }
         this.checkOverlayVisible();
      }
      
      public function showSaveProfileLoad(param1:Boolean) : void
      {
         if(param1)
         {
            this._showSaveProfile(SaveProfilePageMode.PROFILE_MODE_RESUME,SagaDef.START_HAPPENING,null);
         }
         else
         {
            this._showSaveProfile(SaveProfilePageMode.PROFILE_MODE_LOAD,SagaDef.START_HAPPENING,null);
         }
      }
      
      public function showSaveProfileStart(param1:String, param2:Function = null) : void
      {
         this._showSaveProfile(SaveProfilePageMode.PROFILE_MODE_NEW_GAME_WHILE_FULL,param1,null,param2);
      }
      
      public function showSaveProfileImport(param1:Function) : void
      {
         this._showSaveProfile(SaveProfilePageMode.PROFILE_MODE_IMPORT_OLD_SAGA,null,param1);
      }
      
      private function _showSaveProfile(param1:SaveProfilePageMode, param2:String, param3:Function, param4:Function = null) : void
      {
         this.hideSaveLoad();
         if(!Saga.PROFILE_ENABLED)
         {
            return;
         }
         if(!this.saveProfilePage.parent)
         {
            addHolderChild(this.saveProfilePage,this.LAYER_SAVE_PROFILE + this.poppeningIndexModifier);
            if(Boolean(this.saveProfilePage) && Boolean(this.saveProfilePage.stage))
            {
               this.saveProfilePage.stage.focus = this.saveProfilePage;
            }
            this.saveProfilePage.showSaveProfile(param1,param2,param3,param4);
         }
         this.checkOverlayVisible();
      }
      
      public function isShowingCreditsPage() : Boolean
      {
         return this.creditsPage != null;
      }
      
      public function isShowingLoadPages() : Boolean
      {
         return this.saveProfilePage && this.saveProfilePage.parent && this.saveProfilePage.visible || this.saveLoadPage && this.saveLoadPage.parent && this.saveLoadPage.visible;
      }
      
      public function isShowingOptions() : Boolean
      {
         return this.sagaOptionsPage && this.sagaOptionsPage.parent && this.sagaOptionsPage.visible || this.sagaOptionsPage.isGpConfigShowing;
      }
      
      public function hideCreditsPage() : void
      {
         if(this.creditsPage)
         {
            logger.info("GamePageManagerAdapter.hideCreditsPage");
            this.creditsPage.terminate();
            this.creditsPage.manager = null;
            this.creditsPage = null;
         }
         if(Boolean(currentPage) && Boolean(currentPage.stage))
         {
            currentPage.stage.focus = currentPage;
         }
         this.checkOverlayVisible();
      }
      
      public function showCreditsPage(param1:SagaCreditsDef, param2:Boolean, param3:Boolean) : void
      {
         if(!this.creditsPage)
         {
            logger.info("GamePageManagerAdapter.showCreditsPage");
            this.creditsPage = new CreditsPage(param1,this.config,param3);
            this.creditsPage.manager = this;
            this.creditsPage._end_titles = param2;
            addHolderChild(this.creditsPage,this.LAYER_CREDITS + this.poppeningIndexModifier);
            if(Boolean(this.creditsPage) && Boolean(this.creditsPage.stage))
            {
               this.creditsPage.stage.focus = this.creditsPage;
            }
            this.creditsPage.start();
         }
         this.checkOverlayVisible();
      }
      
      public function hideSaveProfile() : void
      {
         var _loc1_:Boolean = false;
         if(this.saveProfilePage.parent)
         {
            _loc1_ = this.saveProfilePage.visible;
            this.saveProfilePage.parent.removeChild(this.saveProfilePage);
            if(Boolean(currentPage) && Boolean(currentPage.stage))
            {
               currentPage.stage.focus = currentPage;
            }
         }
         this.saveProfilePage.hideSaveProfile(_loc1_);
         this.checkOverlayVisible();
      }
      
      public function get poppeningIndexModifier() : int
      {
         if(this.poppeningPage && this.poppeningPage.visible && Boolean(this.poppeningPage.parent))
         {
            return 1;
         }
         if(this.warPage && this.warPage.visible && Boolean(this.warPage.parent))
         {
            return 1;
         }
         return 0;
      }
      
      public function hideSaveLoad() : void
      {
         var _loc1_:Boolean = false;
         if(this.saveLoadPage.parent)
         {
            _loc1_ = this.saveLoadPage.visible;
            this.saveLoadPage.parent.removeChild(this.saveLoadPage);
            if(Boolean(currentPage) && Boolean(currentPage.stage))
            {
               currentPage.stage.focus = currentPage;
            }
         }
         this.saveLoadPage.hideSaveLoad(_loc1_);
         this.checkOverlayVisible();
      }
      
      public function showOptions() : void
      {
         if(!this.sagaOptionsPage.parent || !this.sagaOptionsPage.visible)
         {
            logger.info("GamePageManagerAdapter.showOptions");
            GuiIconSlot.cancelAllDrags();
            PlatformStarling.fullscreenIncrement("GamePageManagerAdapter.showOptions",logger);
            addHolderChild(this.sagaOptionsPage,this.LAYER_OPTIONS + this.poppeningIndexModifier);
            this.sagaOptionsPage.showOptions();
            if(Boolean(this.sagaOptionsPage) && Boolean(this.sagaOptionsPage.stage))
            {
               this.sagaOptionsPage.stage.focus = this.sagaOptionsPage;
            }
            this.notifyOptionsShowing(true);
         }
         this.checkOverlayVisible();
      }
      
      private function notifyOptionsShowing(param1:Boolean) : void
      {
         var _loc3_:* = 0;
         var _loc4_:* = 0;
         var _loc5_:ScenePage = null;
         var _loc6_:TallyPage = null;
         if(this.config.saga)
         {
            this.config.saga.triggerOptionsShowing(param1);
         }
         if(this.creditsPage)
         {
            if(this.creditsPage.skippable)
            {
               this.hideCreditsPage();
            }
            else
            {
               this.creditsPage.visible = !param1;
            }
         }
         if(this.saveProfilePage.parent)
         {
            _loc3_ = 1 << _OPTION_INTERRUPT_PROFILE_PAGE;
            this.saveProfilePage.visible = Boolean(this._optionsInterrupted & _loc3_) && !param1;
            this._optionsInterrupted = param1 ? this._optionsInterrupted | _loc3_ : this._optionsInterrupted & ~_loc3_;
         }
         if(this.saveLoadPage.parent)
         {
            _loc4_ = 1 << _OPTION_INTERRUPT_SAVE_LOAD;
            this.saveLoadPage.visible = Boolean(this._optionsInterrupted & _loc4_) && !param1;
            this._optionsInterrupted = param1 ? this._optionsInterrupted | _loc4_ : this._optionsInterrupted & ~_loc4_;
         }
         if(this.sagaHeraldry)
         {
            this.sagaHeraldry.notifyShowingOptionsChange(param1);
         }
         var _loc2_:GamePage = currentPage as GamePage;
         if(_loc2_)
         {
            _loc2_.handleOptionsShowing(param1);
         }
         if(param1 == false)
         {
            _loc5_ = currentPage as ScenePage;
            _loc6_ = !!_loc5_ ? _loc5_.tallyPage : null;
            if(Boolean(_loc6_) && _loc6_.visible)
            {
               _loc6_.stage.focus = _loc6_;
               _loc6_.handleOptionsShowing(param1);
            }
         }
         if(this.config.gameGuiContext)
         {
            this.config.gameGuiContext.notifyShowingOptionsChange();
         }
      }
      
      private function resetInterrupts() : void
      {
         this._optionsInterrupted = 0;
      }
      
      public function HideAllLayers() : void
      {
         logger.info("Hiding all layers");
         this.hideSaveLoad();
         this.hideSaveProfile();
         this.hideSagaSurvivalBattlePopup();
         this.hideOptions();
         this.hideCreditsPage();
         this.resetInterrupts();
      }
      
      public function showGpRebind(param1:Boolean, param2:String) : void
      {
         if(GameConfig.ENABLE_GP_REBINDING)
         {
            this.showOptions();
            this.sagaOptionsPage.showGpRebind(param1,"GamePageManagerAdapter.showGpRebind " + param2);
            this.checkOverlayVisible();
         }
      }
      
      public function get isGpConfigShowing() : Boolean
      {
         return Boolean(this.sagaOptionsPage) && Boolean(this.sagaOptionsPage.parent) && this.sagaOptionsPage.isGpConfigShowing;
      }
      
      public function showTutorialLayer() : void
      {
         if(!this.tutorialLayer.parent)
         {
            addHolderChild(this.tutorialLayer,this.LAYER_TUTORIAL + this.poppeningIndexModifier);
            this.tutorialLayer.visible = true;
            if(Boolean(this.tutorialLayer) && Boolean(this.tutorialLayer.stage))
            {
               this.tutorialLayer.stage.focus = this.tutorialLayer;
            }
         }
      }
      
      public function showLoadingOverlayLayer() : void
      {
         if(!this.loadingOverlayLayer)
         {
            return;
         }
         if(!this.loadingOverlayLayer.parent)
         {
            addHolderChild(this.loadingOverlayLayer,this.LAYER_LOADING + 1);
            this.loadingOverlayLayer.visible = true;
         }
      }
      
      public function toggleOptions() : void
      {
         if(this.sagaOptionsPage.parent)
         {
            this.hideOptions();
         }
         else
         {
            this.showOptions();
         }
      }
      
      public function hideOptions() : void
      {
         if(this.sagaOptionsPage.parent)
         {
            logger.info("GamePageManagerAdapter.hideOptions");
            PlatformStarling.fullscreenDecrement("GamePageManagerAdapter.hideOptions",logger);
            this.sagaOptionsPage.parent.removeChild(this.sagaOptionsPage);
            this.sagaOptionsPage.hideOptions();
            if(Boolean(currentPage) && Boolean(currentPage.stage))
            {
               currentPage.stage.focus = currentPage;
            }
            this.notifyOptionsShowing(false);
         }
         this.checkOverlayVisible();
      }
      
      public function get poppening() : Convo
      {
         return this.poppeningPage.convo;
      }
      
      public function get war() : Convo
      {
         return this.warPage.convo;
      }
      
      public function set poppening(param1:Convo) : void
      {
         if(this.poppeningPage.convo == param1)
         {
            return;
         }
         if(param1)
         {
            this.war = null;
         }
         this.updatePp(this.poppeningPage,param1);
         this.config.soundSystem.ducking = Boolean(this.poppening) || Boolean(this.war);
      }
      
      public function set war(param1:Convo) : void
      {
         if(this.warPage.convo == param1)
         {
            return;
         }
         if(param1)
         {
            this.poppening = null;
         }
         this.updatePp(this.warPage,param1);
         this.config.soundSystem.ducking = Boolean(this.poppening) || Boolean(this.war);
      }
      
      private function updatePp(param1:PoppeningPage, param2:Convo) : void
      {
         if(param1.convo == param2)
         {
            return;
         }
         if(param1.convo)
         {
            param1.convo.removeEventListener(ConvoEvent.FINISHED,this.poppeningFinishedHandler);
            param1.convo.finish();
         }
         param1.convo = param2;
         if(param1.convo)
         {
            if(param1.convo.finished)
            {
               param2 = null;
               param1.convo = null;
            }
            else
            {
               param1.convo.addEventListener(ConvoEvent.FINISHED,this.poppeningFinishedHandler,false,255);
            }
         }
         if(!param2)
         {
            if(param1.parent)
            {
               param1.parent.removeChild(param1);
               if(Boolean(currentPage) && Boolean(currentPage.stage))
               {
                  currentPage.stage.focus = currentPage;
               }
            }
         }
         else
         {
            if(!param1.parent)
            {
               addHolderChild(param1,2);
               if(Boolean(param1) && Boolean(param1.stage))
               {
                  param1.stage.focus = param1;
               }
            }
            if(this.isShowingOptions())
            {
               this.sagaOptionsPage.ensureTopGp();
            }
            if(this.saveProfilePage && this.saveProfilePage.parent && this.saveProfilePage.visible)
            {
               this.saveProfilePage.ensureTopGp();
            }
            if(this.saveLoadPage && this.saveLoadPage.parent && this.saveLoadPage.visible)
            {
               this.saveLoadPage.ensureTopGp();
            }
         }
         dispatchEvent(new Event(EVENT_POPPENING));
      }
      
      private function poppeningFinishedHandler(param1:ConvoEvent) : void
      {
         if(this.poppeningPage.convo == param1.target)
         {
            this.poppening = null;
         }
         if(this.warPage.convo == param1.target)
         {
            this.war = null;
         }
      }
      
      override public function set loading(param1:Boolean) : void
      {
         super.loading = param1;
         if(this.config.flyManager)
         {
            this.config.flyManager.checkQ();
         }
      }
      
      override public function setRect(param1:Number, param2:Number, param3:Number, param4:Number) : void
      {
         super.setRect(param1,param2,param3,param4);
         if(this.subtitle)
         {
            this.subtitle.handleResize(param3,param4);
         }
         if(this.tutorialLayer)
         {
            this.tutorialLayer.setSize(param3,param4);
            this.tutorialLayer.x = param1;
            this.tutorialLayer.y = param2;
         }
         if(this.loadingOverlayLayer)
         {
            this.loadingOverlayLayer.setSize(param3,param4);
            this.loadingOverlayLayer.x = param1;
            this.loadingOverlayLayer.y = param2;
         }
      }
      
      override protected function handleLoadingChanged() : void
      {
         if(!loading)
         {
            if(Boolean(this.saveLoadPage) && this.saveLoadPage.visible)
            {
               this.hideSaveLoad();
            }
            if(Boolean(this.saveProfilePage) && this.saveProfilePage.visible)
            {
               this.hideSaveProfile();
            }
            if(Boolean(this.sagaOptionsPage) && this.sagaOptionsPage.visible)
            {
               this.hideOptions();
               this.showOptions();
            }
            this.config.purgeAssetBundles();
            AppInfo.instance.forceSfGarbageCollectionNextFrame();
         }
      }
      
      private function handleInputDeviceChanged(param1:Event) : void
      {
         var _loc2_:Action = null;
         var _loc3_:Action_TutorialPopup = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:* = null;
         if(Boolean(this.tutorialLayer) && this.tutorialLayer.hasTooltips)
         {
            for each(_loc2_ in this.config.saga.actions)
            {
               if(_loc2_.def.type == ActionType.TUTORIAL_POPUP)
               {
                  _loc3_ = Action_TutorialPopup(_loc2_);
                  _loc4_ = _loc2_.def.msg;
                  if(StringUtil.startsWith(_loc4_,"$"))
                  {
                     _loc5_ = _loc2_.def["msg"].substr(1);
                     _loc4_ = null;
                     if(PlatformInput.lastInputGp)
                     {
                        _loc6_ = _loc5_ + "_gp";
                        _loc4_ = this.config.saga.locale.translateEncodedToken(_loc6_,true);
                     }
                     if(!_loc4_)
                     {
                        _loc4_ = this.config.saga.locale.translateEncodedToken(_loc5_,false);
                     }
                  }
                  _loc4_ = this.config.saga.performStringReplacement_SagaVar(_loc4_);
                  this.tutorialLayer.updateTutorialTooltipById(_loc3_.getTooltipId(),_loc4_);
               }
            }
         }
      }
      
      private function checkOverlayVisible() : void
      {
         OVERLAY_VISIBLE = this.isShowingLoadPages() || this.isShowingOptions() || this.isShowingCreditsPage();
         this.config.flyManager.checkQ();
      }
      
      public function showSagaSurvivalBattlePopup(param1:String, param2:Function) : void
      {
         if(this.sagaSurvivalBattlePopupPage)
         {
            this.sagaSurvivalBattlePopupPage.cleanup();
         }
         this.sagaSurvivalBattlePopupPage = new SagaSurvivalBattlePopupPage(this.config,param1,param2);
         this.sagaSurvivalBattlePopupPage.manager = this;
         addHolderChild(this.sagaSurvivalBattlePopupPage,this.LAYER_PP + this.poppeningIndexModifier);
         this.sagaSurvivalBattlePopupPage.start();
      }
      
      public function hideSagaSurvivalBattlePopup() : void
      {
         if(this.sagaSurvivalBattlePopupPage)
         {
            this.sagaSurvivalBattlePopupPage.cleanup();
            this.sagaSurvivalBattlePopupPage = null;
         }
      }
   }
}
