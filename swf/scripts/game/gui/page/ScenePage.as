package game.gui.page
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Quad;
   import com.stoicstudio.platform.Platform;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleFsmConfig;
   import engine.battle.fsm.state.BattleStateFinish;
   import engine.battle.fsm.state.BattleStateFinished;
   import engine.battle.fsm.state.BattleStateInit;
   import engine.battle.fsm.state.BattleStateWaveRespawn;
   import engine.battle.fsm.state.BattleStateWave_Base;
   import engine.core.analytic.Ga;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.KeyBinder;
   import engine.core.fsm.FsmEvent;
   import engine.core.fsm.State;
   import engine.core.gp.GpControlButton;
   import engine.core.gp.GpSource;
   import engine.core.locale.LocaleCategory;
   import engine.core.render.BoundedCamera;
   import engine.core.render.Camera;
   import engine.core.render.ScreenAspectHelper;
   import engine.core.util.StringUtil;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpAlignH;
   import engine.gui.GuiGpAlignV;
   import engine.gui.GuiGpBitmap;
   import engine.gui.IGuiButton;
   import engine.gui.page.PageState;
   import engine.landscape.def.LandscapeSplineDef;
   import engine.landscape.def.LandscapeSpriteDef;
   import engine.landscape.travel.view.TravelView;
   import engine.landscape.view.ILandscapeView;
   import engine.landscape.view.LandscapeViewBase;
   import engine.saga.Saga;
   import engine.saga.action.ActionDef;
   import engine.saga.action.ActionType;
   import engine.saga.action.Action_MusicOneshot;
   import engine.scene.model.Scene;
   import engine.scene.model.SceneEvent;
   import engine.scene.model.SceneLoader;
   import engine.scene.view.SceneViewController;
   import engine.scene.view.SceneViewSprite;
   import engine.sound.def.ISoundDef;
   import engine.sound.def.ISoundLibrary;
   import engine.sound.view.ISound;
   import engine.sound.view.SoundController;
   import engine.user.UserEvent;
   import engine.user.UserLifecycleManager;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.system.Capabilities;
   import flash.ui.Keyboard;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   import game.gui.IGuiCharacterIconSlot;
   import game.gui.IGuiContext;
   import game.gui.IGuiDialog;
   import game.session.states.GameStateDataEnum;
   import game.session.states.SceneState;
   import game.session.states.TownState;
   
   public class ScenePage extends GamePage
   {
      
      public static const EVENT_DO_INIT_READY:String = "EVENT_DO_INIT_READY";
      
      public static const EVENT_SCENE_PAGE_READY:String = "EVENT_SCENE_PAGE_READY";
      
      public static var needsUserEngagementPrompt:Boolean = false;
      
      public static var DEBUG_IGNORE_ALL_USER_XB_EVENTS:Boolean = false;
      
      public static var mcClazzCornerButtonBanner:Class;
      
      public static var mcClazzCornerButtonHelp:Class;
      
      public static var mcClazzBannerHelp:Class;
      
      public static var wipeBmpd:BitmapData = new BitmapData(1,1,false,0);
      
      public static var DISABLE_WIPEIN:Boolean = false;
       
      
      public var controller:SceneViewController;
      
      private var helpCorner:IGuiButton;
      
      private var bannerDisplayCornerButton:IGuiButton;
      
      private var helpBanner:MovieClip;
      
      private var helpBannerDisplay:BannerDisplay;
      
      protected var _enableBanner:Boolean = false;
      
      protected var soundController:SoundController;
      
      protected var loader:SceneLoader;
      
      public var battleHandler:ScenePageBattleHandler;
      
      private var wipe:Bitmap;
      
      private var sound:ISound;
      
      public var scene:Scene;
      
      public var view:SceneViewSprite;
      
      private var _sceneState:SceneState;
      
      private var initReadied:Boolean;
      
      private var postLoaded:Boolean;
      
      public var convoPage:ConvoPage;
      
      public var travelPage:TravelPage;
      
      public var tallyPage:TallyPage;
      
      public var sagaStartPage:SagaStartPage;
      
      public var sagaPairingPrompt:SagaPairingPrompt;
      
      public var speechies:ScenePageSpeechBubbles;
      
      public var battleInfoFlags:ScenePageBattleInfoFlags;
      
      public var battleDamageFlags:ScenePageBattleDamageFlags;
      
      public var battleVfx:ScenePageBattleVfx;
      
      public var animDebug:ScenePageAnimDebug;
      
      public var pathDebug:ScenePagePathDebug;
      
      private var _warResolutionPage:WarResolutionPage;
      
      private var battleFsm:BattleFsm;
      
      protected var allowTravelPage:Boolean = true;
      
      private var frameTimeMonitor:ScenePageFrameTimeMonitor;
      
      private var _hideStartPage:Boolean;
      
      public var wipeOutDuration:Number = 0.5;
      
      public var camera:BoundedCamera;
      
      private var landscapeGp:LandscapeGpOverlay;
      
      private var gp_d_u:GuiGpBitmap;
      
      private var gp_menu:GuiGpBitmap;
      
      public var cmd_hidegui:Cmd;
      
      private var _wipeInHold:Number = 0;
      
      private var _wipeInDuration:Number = 1;
      
      private var _wipedownOutStarted:Boolean;
      
      public var drift:TweenMax;
      
      public var driftZoom:TweenMax;
      
      private var _buttonsCmdDisabled:Boolean;
      
      private var _wiping:Boolean;
      
      public function ScenePage(param1:GameConfig)
      {
         this.wipe = new Bitmap(wipeBmpd);
         this.gp_d_u = GuiGp.ctorPrimaryBitmap(GpControlButton.D_U,true);
         this.gp_menu = GuiGp.ctorPrimaryBitmap(GpControlButton.REPLACE_MENU_BUTTON,true);
         this.cmd_hidegui = new Cmd("cmd_hidegui",this.cmdfunc_hidegui);
         super(param1);
         GpSource.dispatcher.addEventListener(GpSource.EVENT_PRIMARY_DEVICE,this.primaryDeviceHandler);
         this.fullscreen = false;
         this.wipe.name = "wipe";
         matteHelper.enabled = false;
         this.mouseEnabled = false;
         this.mouseChildren = true;
         this.speechies = new ScenePageSpeechBubbles(this);
         this.battleDamageFlags = new ScenePageBattleDamageFlags(this);
         this.battleInfoFlags = new ScenePageBattleInfoFlags(this);
         this.battleVfx = new ScenePageBattleVfx(this);
         this.animDebug = new ScenePageAnimDebug(this);
         this.pathDebug = new ScenePagePathDebug(this);
         param1.addEventListener(GameConfig.EVENT_LOCALE,this.configLocaleHandler);
         param1.addEventListener(GameConfig.EVENT_FF,this.configFfHandler);
         UserLifecycleManager.Instance().addEventListener(UserEvent.USER_CHANGED,this.handleActiveUserChanged);
         this.gp_menu.scale = this.gp_d_u.scale = 0.75;
         this.gp_menu.visible = this.gp_d_u.visible = false;
         BattleFsmConfig.dispatcher.addEventListener(BattleFsmConfig.EVENT_GUI_HUD_ENABLE,this.guiHudEnableHandler);
         BattleFsmConfig.dispatcher.addEventListener(BattleFsmConfig.EVENT_GUI_VISIBLE,this.guiHudEnableHandler);
      }
      
      public function getDebugString() : String
      {
         var _loc1_:String = "";
         _loc1_ += toString() + "\n";
         return _loc1_ + ("convoPage=" + this.convoPage);
      }
      
      private function primaryDeviceHandler(param1:Event) : void
      {
         this.resizeHandler();
      }
      
      override public function cleanup() : void
      {
         if(cleanedup)
         {
            throw new IllegalOperationError("double cleanup?");
         }
         KeyBinder.keybinder.unbind(this.cmd_hidegui);
         GpSource.dispatcher.removeEventListener(GpSource.EVENT_PRIMARY_DEVICE,this.primaryDeviceHandler);
         BattleFsmConfig.dispatcher.removeEventListener(BattleFsmConfig.EVENT_GUI_HUD_ENABLE,this.guiHudEnableHandler);
         BattleFsmConfig.dispatcher.removeEventListener(BattleFsmConfig.EVENT_GUI_VISIBLE,this.guiHudEnableHandler);
         GuiGp.releasePrimaryBitmap(this.gp_d_u);
         GuiGp.releasePrimaryBitmap(this.gp_menu);
         this.gp_d_u = null;
         this.gp_menu = null;
         if(this.landscapeGp)
         {
            this.landscapeGp.cleanup();
            this.landscapeGp = null;
         }
         if(this.camera)
         {
            this.camera.removeEventListener(Camera.EVENT_CAMERA_VIEW_CHANGED,this.cameraViewChangedHandler);
            this.camera = null;
         }
         if(this.frameTimeMonitor)
         {
            this.frameTimeMonitor.report(logger);
            this.frameTimeMonitor = null;
         }
         this.cleanupTally();
         config.removeEventListener(GameConfig.EVENT_LOCALE,this.configLocaleHandler);
         config.removeEventListener(GameConfig.EVENT_FF,this.configFfHandler);
         this._sceneState.removeEventListener(SceneState.EVENT_RESOURCES_READY,this.sceneStateResourcesReadyHandler);
         this._sceneState.removeEventListener(SceneState.EVENT_WAR_RESOLUTION,this.warHandler);
         this._sceneState.removeEventListener(SceneState.EVENT_BATTLE_RESOLUTION,this.battleResolutionHandler);
         this._sceneState.removeEventListener(SceneState.EVENT_CHAT_ENABLED,this.chatEnabledHandler);
         this._sceneState.removeEventListener(SceneState.EVENT_BANNER_BUTTON_ENABLED,this.bannersHandler);
         this._sceneState.removeEventListener(SceneState.EVENT_HELP_ENABLED,this.helpHandler);
         this._sceneState.removeEventListener(SceneState.EVENT_SCENE_EXITING,this.exitingHandler);
         this._sceneState.removeEventListener(SceneState.EVENT_SCENE_TRANSITIONING_OUT,this.sceneTransitioningOutHandler);
         UserLifecycleManager.Instance().removeEventListener(UserEvent.INITIAL_USER_ESTABLISHED,this.handleUserEstablished);
         UserLifecycleManager.Instance().removeEventListener(UserEvent.USER_CHANGED,this.handleActiveUserChanged);
         removeAllChildren();
         TweenMax.killDelayedCallsTo(this.startWipedownIn);
         TweenMax.killDelayedCallsTo(this._internal_startWipedownIn);
         if(this.scene)
         {
            this.scene.removeEventListener(Scene.EVENT_CLICKABLES,this.clickablesHandler);
            this.scene.removeEventListener(SceneEvent.READY,this.sceneReadyHandler);
         }
         if(this.wipe)
         {
            TweenMax.killTweensOf(this.wipe);
            this.wipe = null;
         }
         shell.removeShell("view");
         shell.removeShell("hide_start");
         shell.removeShell("buttons");
         shell.removeShell("drift");
         if(config.logger.isDebugEnabled)
         {
            config.logger.debug("ScenePage.cleanup");
         }
         if(this.sound)
         {
            this.sound.stop(false);
            this.sound = null;
         }
         if(this.controller)
         {
            this.controller.cleanup();
            this.controller = null;
         }
         if(this.battleHandler)
         {
            this.battleHandler.cleanup();
            this.battleHandler = null;
         }
         if(this.soundController)
         {
            this.soundController.cleanup();
            this.controller = null;
         }
         if(Boolean(this.loader.viewSprite) && Boolean(this.loader.viewSprite.parent))
         {
            removeChild(this.loader.viewSprite);
         }
         if(this.travelPage)
         {
            this.travelPage.cleanup();
            this.travelPage = null;
         }
         if(this.convoPage)
         {
            this.convoPage.cleanup();
            this.convoPage = null;
         }
         if(this.sagaStartPage)
         {
            this.sagaStartPage.cleanup();
            this.sagaStartPage = null;
         }
         if(this.battleInfoFlags)
         {
            this.battleInfoFlags.cleanup();
            this.battleInfoFlags = null;
         }
         if(this.battleVfx)
         {
            this.battleVfx.cleanup();
            this.battleVfx = null;
         }
         if(this.battleDamageFlags)
         {
            this.battleDamageFlags.cleanup();
            this.battleDamageFlags = null;
         }
         if(this.animDebug)
         {
            this.animDebug.cleanup();
            this.animDebug = null;
         }
         if(this.pathDebug)
         {
            this.pathDebug.cleanup();
            this.pathDebug = null;
         }
         if(this.speechies)
         {
            this.speechies.cleanup();
            this.speechies = null;
         }
         if(this.battleFsm)
         {
            this.battleFsm.removeEventListener(FsmEvent.CURRENT,this.onBattleFsmChange);
            this.battleFsm = null;
         }
         if(this.soundController)
         {
            this.soundController.cleanup();
            this.soundController = null;
         }
         this.loader = null;
         this._sceneState = null;
         this.scene = null;
         this.view = null;
         if(this.helpCorner)
         {
            this.helpCorner.cleanup();
            this.helpCorner = null;
         }
         if(this.bannerDisplayCornerButton)
         {
            this.bannerDisplayCornerButton.cleanup();
            this.bannerDisplayCornerButton = null;
         }
         if(this.helpBannerDisplay)
         {
            this.helpBannerDisplay.cleanup();
            this.helpBannerDisplay = null;
         }
         super.cleanup();
      }
      
      private function configLocaleHandler(param1:Event) : void
      {
         if(this.battleHandler)
         {
            this.battleHandler.configLocaleHandler();
         }
      }
      
      private function configFfHandler(param1:Event) : Boolean
      {
         if(this.convoPage)
         {
            if(this.convoPage.doFf())
            {
               return true;
            }
         }
         if(this.controller)
         {
            return this.controller.doFf();
         }
         return false;
      }
      
      public function get sceneState() : SceneState
      {
         return this._sceneState;
      }
      
      override public function canReusePageForState(param1:State) : Boolean
      {
         return false;
      }
      
      private function handleLoadBanner() : void
      {
         var _loc1_:Boolean = false;
         if(this.bannerDisplayCornerButton)
         {
            _loc1_ = this.sceneState.bannerButtonEnabled && BattleFsmConfig.guiHudShouldRender;
            this.gp_d_u.visible = _loc1_;
            this.bannerDisplayCornerButton.visible = _loc1_;
         }
      }
      
      private function sceneStateResourcesReadyHandler(param1:Event) : void
      {
         checkReady();
      }
      
      override protected function canBeReady() : Boolean
      {
         return this._sceneState.resourcesReady;
      }
      
      private function promptForActiveUser() : void
      {
         logger.info("Show user pairing prompt ");
         if(!this.sagaPairingPrompt)
         {
            this.sagaPairingPrompt = new SagaPairingPrompt(config,this);
            this.sagaPairingPrompt.manager = manager;
            addChild(this.sagaPairingPrompt);
            this.sagaPairingPrompt.start();
            this.sagaPairingPrompt.visible = true;
            UserLifecycleManager.Instance().addEventListener(UserEvent.INITIAL_USER_ESTABLISHED,this.handleUserEstablished);
         }
      }
      
      private function handleActiveUserChanged(param1:Event) : void
      {
         if(this.sagaStartPage != null)
         {
            logger.info("Saga start page user changed.");
            this.sagaStartPage.cleanup();
            removeChild(this.sagaStartPage);
            this.sagaStartPage = null;
         }
         this.createSagaStartPage(false);
      }
      
      private function handleUserEstablished(param1:Event) : void
      {
         var ue:UserEvent;
         var analyticsUser:String = null;
         var w:int = 0;
         var h:int = 0;
         var lang:String = null;
         var context:IGuiContext = null;
         var dialog:IGuiDialog = null;
         var e:Event = param1;
         logger.info("handleUserEstablished");
         ue = e as UserEvent;
         UserLifecycleManager.Instance().removeEventListener(UserEvent.INITIAL_USER_ESTABLISHED,this.handleUserEstablished);
         removeChild(this.sagaPairingPrompt);
         this.sagaPairingPrompt = null;
         needsUserEngagementPrompt = false;
         if(!Ga.hasTrackedStart)
         {
            analyticsUser = config.context.appInfo.getUsernameForAnalytics();
            logger.info("[analytics]: using user ID - " + analyticsUser);
            Ga.assignUsername(analyticsUser);
            w = Capabilities.screenResolutionX;
            h = Capabilities.screenResolutionY;
            lang = Capabilities.language;
            Ga.trackSessionStart(w,h,lang);
         }
         if(DEBUG_IGNORE_ALL_USER_XB_EVENTS)
         {
            return;
         }
         if(UserLifecycleManager.Instance().isUserLoggedIn())
         {
            logger.info("handleUserEstablished - user selected! initializeSaveSystem");
            UserLifecycleManager.Instance().noUserWarningDisplayed = false;
            this.createSagaStartPage(true);
         }
         else if(!UserLifecycleManager.Instance().noUserWarningDisplayed)
         {
            logger.info("No user logged in: Showing no save warning: handleUserEstablished");
            context = config.gameGuiContext;
            dialog = context.createDialog();
            UserLifecycleManager.Instance().noUserWarningDisplayed = true;
            dialog.openDialog(config.gameGuiContext.translateCategory("warning_no_save_title",LocaleCategory.PLATFORM),config.gameGuiContext.translateCategory("warning_no_save_message",LocaleCategory.PLATFORM),config.gameGuiContext.translate("ok"),function(param1:String):void
            {
               createSagaStartPage(true);
            });
         }
         else
         {
            this.createSagaStartPage(true);
         }
      }
      
      private function createSagaStartPage(param1:Boolean) : void
      {
         logger.info("Creating saga start page");
         this.sagaStartPage = new SagaStartPage(config,this,UserLifecycleManager.Instance().userName);
         logger.info("Saga start page: " + this.sagaStartPage);
         this.sagaStartPage.manager = manager;
         addChild(this.sagaStartPage);
         this.sagaStartPage.start();
         this.sagaStartPage.visible = !this._hideStartPage;
         this.allowTravelPage = false;
         this.sceneReadyHandler(null);
         if(param1)
         {
            this.restartIntroMusic();
         }
      }
      
      private function restartIntroMusic() : void
      {
         if(!Action_MusicOneshot.firstEventPlayed || !config.saga)
         {
            return;
         }
         if(config.soundSystem)
         {
            config.soundSystem.music = null;
         }
         var _loc1_:ActionDef = new ActionDef(null);
         _loc1_.type = ActionType.MUSIC_ONESHOT;
         _loc1_.id = Action_MusicOneshot.firstEventPlayed;
         config.saga.executeActionDef(_loc1_,null,null);
      }
      
      override protected function handleStart() : void
      {
         state = PageState.LOADING;
         config.context.appInfo.setSystemIdleKeepAwake(true);
         config.context.appInfo.setSystemIdleKeepAwake(false);
         this._sceneState = config.fsm.current as SceneState;
         this._sceneState.addEventListener(SceneState.EVENT_RESOURCES_READY,this.sceneStateResourcesReadyHandler);
         this._sceneState.addEventListener(SceneState.EVENT_WAR_RESOLUTION,this.warHandler);
         this._sceneState.addEventListener(SceneState.EVENT_BATTLE_RESOLUTION,this.battleResolutionHandler);
         this._sceneState.addEventListener(SceneState.EVENT_CHAT_ENABLED,this.chatEnabledHandler);
         this._sceneState.addEventListener(SceneState.EVENT_BANNER_BUTTON_ENABLED,this.bannersHandler);
         this._sceneState.addEventListener(SceneState.EVENT_HELP_ENABLED,this.helpHandler);
         this._sceneState.addEventListener(SceneState.EVENT_SCENE_EXITING,this.exitingHandler);
         this._sceneState.addEventListener(SceneState.EVENT_SCENE_TRANSITIONING_OUT,this.sceneTransitioningOutHandler);
         this.loader = this.sceneState.loader;
         this.scene = this.loader.scene;
         this.scene._context._speechBubbler = this.speechies.speechBubbler;
         this._wipeInDuration = this._sceneState.wipeInDuration;
         this._wipeInHold = this._sceneState.wipeInHold;
         this.view = this.loader.viewSprite;
         shell.addShell("view",this.view.shell);
         shell.add("hide_start",this.hideStartCmdHandler);
         shell.add("buttons",this.buttonsCmdHandler);
         shell.add("drift",this.driftCmdHandler);
         this.scene.addEventListener(Scene.EVENT_CLICKABLES,this.clickablesHandler);
         this.scene.addEventListener(SceneEvent.READY,this.sceneReadyHandler);
         if(!this.scene || !this.view)
         {
            throw new IllegalOperationError("No scene / view?");
         }
         this.handleLoadBanner();
         this.chatEnabledHandler(null);
         this.updateClickables();
         this.checkBattleChatEnabled();
         if(this.scene.convo)
         {
            this.convoPage = new ConvoPage(config,this);
            addChild(this.convoPage);
            this.convoPage.start();
         }
         var _loc1_:Boolean = Boolean(config.saga) && config.saga.camped;
         if(config.enableMemReport)
         {
            this.frameTimeMonitor = new ScenePageFrameTimeMonitor(this,config.memReport);
         }
         if(this.scene.isStartScene)
         {
            if(!needsUserEngagementPrompt)
            {
               this.createSagaStartPage(false);
            }
            return;
         }
         if(this.allowTravelPage)
         {
            if(!this.scene.boards || this.scene.boards.length == 0)
            {
               if(!this.scene.convo)
               {
                  if(Boolean(this.scene.landscape.travel) || _loc1_)
                  {
                     this.travelPage = new TravelPage(config,this);
                     addChild(this.travelPage);
                     this.travelPage.start();
                  }
               }
            }
         }
         this.sceneReadyHandler(null);
      }
      
      private function sceneReadyHandler(param1:SceneEvent) : void
      {
         if(needsUserEngagementPrompt)
         {
            this.promptForActiveUser();
         }
         if(this.sagaStartPage && this.scene && this.scene.ready)
         {
            this.sagaStartPage.doReadyToShow();
         }
         if(Boolean(this.travelPage) && this.allowTravelPage)
         {
            this.travelPage.checkHudEnables();
         }
         if(this.scene.landscape)
         {
            this.scene.landscape.enableHover = true;
         }
         if(this.controller)
         {
            this.controller.syncMouseAdapter();
         }
         this.bannersHandler(null);
         this.helpHandler(null);
         config.flyManager.checkQ();
         KeyBinder.keybinder.bind(true,false,false,Keyboard.H,this.cmd_hidegui,null);
         dispatchEvent(new Event(EVENT_SCENE_PAGE_READY));
      }
      
      private function bannersHandler(param1:Event) : void
      {
         if(Boolean(this.bannerDisplayCornerButton) && Boolean(this.sceneState))
         {
            this.gp_d_u.visible = this.bannerDisplayCornerButton.visible = this.sceneState.bannerButtonEnabled && this.scene.ready && BattleFsmConfig.guiHudShouldRender;
         }
      }
      
      private function exitingHandler(param1:Event) : void
      {
         if(this.frameTimeMonitor)
         {
            this.frameTimeMonitor.report(logger);
            this.frameTimeMonitor = null;
         }
      }
      
      private function helpHandler(param1:Event) : void
      {
         this.checkBattleButtonsVisibility();
      }
      
      private function clickablesHandler(param1:Event) : void
      {
         this.updateClickables();
      }
      
      private function checkBattleChatEnabled() : void
      {
         if(Boolean(this.sceneState) && Boolean(this.battleHandler))
         {
            this.battleHandler.battleChatEnabled = this.sceneState.chatEnabled;
         }
      }
      
      protected function chatEnabledHandler(param1:Event) : void
      {
         this.checkBattleChatEnabled();
      }
      
      override protected function handleDelayStart() : void
      {
         var _loc1_:ILandscapeView = null;
         if(!this.scene || !this.scene._def)
         {
            return;
         }
         if(config.logger.isDebugEnabled)
         {
            config.logger.debug("scenePage.handleDelayStart");
         }
         if(Boolean(this.view) && Boolean(this.view._landscapeViews))
         {
            for each(_loc1_ in this.view._landscapeViews)
            {
               (_loc1_ as LandscapeViewBase).sceneSoundController = this.soundController;
            }
         }
         this.view && this.view.boards && this.view.boards.handleDelayStart();
         state = PageState.READY;
         if(config.saga)
         {
            config.saga.triggerSceneVisible(this.scene._def.url,this.scene.uniqueId);
         }
         this.enableWipeIn();
         TweenMax.delayedCall(0.25,this.startWipedownIn);
      }
      
      private function enableWipeIn() : void
      {
         this.resizeHandler();
         state = PageState.READY;
         if(!this.wipe.parent)
         {
            addChild(this.wipe);
         }
         this.wipe.alpha = 1;
         this.drawWipe();
         bringContainerToFront();
      }
      
      private function startWipedownIn() : void
      {
         if(cleanedup)
         {
            return;
         }
         this.scene.wiped = false;
         this.wiping = true;
         if(this._wipeInHold > 0)
         {
            TweenMax.delayedCall(this._wipeInHold,this._internal_startWipedownIn);
         }
         else
         {
            this._internal_startWipedownIn();
         }
      }
      
      private function _internal_startWipedownIn() : void
      {
         var _loc4_:BattleBoardView = null;
         var _loc1_:Boolean = this._sceneState.data.getValue(GameStateDataEnum.SCENE_AUTOPAN);
         var _loc2_:Point = _loc1_ ? this.scene.checkBattleFocus() : null;
         if(_loc2_)
         {
            _loc4_ = this.view.boards.focusedBoardView;
            if(_loc4_)
            {
               _loc2_.x *= _loc4_.units;
               _loc2_.y *= _loc4_.units;
               _loc2_ = _loc4_.getScenePoint(_loc2_.x,_loc2_.y);
            }
         }
         this.scene.checkStartAnchor(_loc1_,_loc2_);
         var _loc3_:Number = DISABLE_WIPEIN ? 0 : this._wipeInDuration;
         if(_loc3_)
         {
            TweenMax.to(this.wipe,_loc3_,{
               "alpha":0,
               "onComplete":this.wipeInCompleteHandler
            });
         }
         else
         {
            this.wipeInCompleteHandler();
         }
      }
      
      public function startWipedownOut(param1:Number) : void
      {
         if(this._wipedownOutStarted)
         {
            return;
         }
         this._wipedownOutStarted = true;
         if(cleanedup)
         {
            this.wipeOutCompleteHandler();
            return;
         }
         if(!this.wipe.parent)
         {
            addChild(this.wipe);
         }
         this.drawWipe();
         this.wiping = true;
         this.wipe.alpha = 0;
         if(param1 > 0 && !DISABLE_WIPEIN)
         {
            TweenMax.to(this.wipe,param1,{
               "alpha":1,
               "onComplete":this.wipeOutCompleteHandler
            });
         }
         else
         {
            this.wipe.alpha = 1;
            this.wipeOutCompleteHandler();
         }
      }
      
      private function drawWipe() : void
      {
         this.wipe.scaleX = width;
         this.wipe.scaleY = height;
      }
      
      override protected function resizeHandler() : void
      {
         var _loc1_:Number = NaN;
         super.resizeHandler();
         if(this.helpCorner)
         {
            this.helpCorner.movieClip.x = width + 30 - this.helpCorner.movieClip.width;
            this.helpCorner.movieClip.y = height - this.helpCorner.movieClip.height / 2;
            if(this.battleFsm)
            {
               if(!(this.battleFsm.current as TownState))
               {
                  this.helpCorner.movieClip.y *= 0.86;
               }
            }
            if(Platform.requiresUiSafeZoneBuffer)
            {
               this.helpCorner.movieClip.x -= 50;
            }
            GuiGp.placeIcon(this.helpCorner.movieClip,null,this.gp_menu,GuiGpAlignH.C,GuiGpAlignV.N);
         }
         if(this.bannerDisplayCornerButton)
         {
            this.bannerDisplayCornerButton.movieClip.x = width - this.bannerDisplayCornerButton.movieClip.width;
            this.bannerDisplayCornerButton.movieClip.y = 0;
            if(Platform.requiresUiSafeZoneBuffer)
            {
               this.bannerDisplayCornerButton.movieClip.x -= 50;
               this.bannerDisplayCornerButton.movieClip.y += 25;
            }
            GuiGp.placeIcon(this.bannerDisplayCornerButton.movieClip,null,this.gp_d_u,GuiGpAlignH.W_LEFT,GuiGpAlignV.C,15,0);
         }
         if(this.helpBanner)
         {
            _loc1_ = ScreenAspectHelper.getNativeScreenScale(width,height,1920,584);
            this.helpBanner.scaleX = this.helpBanner.scaleY = _loc1_;
            this.helpBanner.x = width / 2;
            this.helpBanner.y = height / 2;
         }
         if(this.battleHandler)
         {
            this.battleHandler.onPageSizeChanaged();
         }
         if(this.convoPage)
         {
            this.convoPage.width = width;
            this.convoPage.height = height;
         }
         if(this.travelPage)
         {
            this.travelPage.width = width;
            this.travelPage.height = height;
         }
         if(this.sagaStartPage)
         {
            this.sagaStartPage.width = width;
            this.sagaStartPage.height = height;
         }
         this.drawWipe();
      }
      
      private function landscapeClickHandler(param1:LandscapeSpriteDef) : void
      {
         if(!this.scene.ready || !param1)
         {
            return;
         }
         var _loc2_:Saga = config.saga;
         if(_loc2_)
         {
            if(!_loc2_.halted && !_loc2_.camped && !_loc2_.mapCamp)
            {
               return;
            }
         }
         if(this.wiping)
         {
            logger.info("No clicks when wiping");
            return;
         }
         config.gameGuiContext.playSound("ui_generic");
         var _loc3_:String = param1.nameId;
         if(_loc2_)
         {
            if(_loc2_.triggerLandscapeClick(_loc3_))
            {
               logger.info("Landscape click handled by trigger, skipping default handler for " + _loc3_ + " in " + this.scene);
               return;
            }
         }
         var _loc4_:Boolean = this.handleLandscapeClick(_loc3_);
      }
      
      protected function handleLandscapeClick(param1:String) : Boolean
      {
         if(Boolean(this.travelPage) && this.allowTravelPage)
         {
            return this.travelPage.handleLandscapeClick(param1);
         }
         return false;
      }
      
      override protected function handleLoaded() : void
      {
         if(config.logger.isDebugEnabled)
         {
            config.logger.debug("ScenePage.handleLoaded");
         }
         if(!this.initReadied)
         {
            this.doInitReady();
            this.updateClickables();
         }
         if(!this.postLoaded)
         {
            this.doPostLoad();
         }
      }
      
      private function cameraViewChangedHandler(param1:Event) : void
      {
         if(this.battleInfoFlags)
         {
            this.battleInfoFlags.resetAllFlags();
         }
         if(this.battleDamageFlags)
         {
            this.battleDamageFlags.resetAllFlags();
         }
         if(this.battleVfx)
         {
            this.battleVfx.resetAllFlags();
         }
      }
      
      private function doInitReady() : void
      {
         var _loc1_:BattleStateInit = null;
         if(!this.sceneState)
         {
            return;
         }
         this.initReadied = true;
         if(Boolean(this.sceneState.battleHandler) && Boolean(this.sceneState.battleHandler.fsm))
         {
            _loc1_ = this.sceneState.battleHandler.fsm.current as BattleStateInit;
            this.battleFsm = this.sceneState.battleHandler.fsm;
            this.battleFsm.addEventListener(FsmEvent.CURRENT,this.onBattleFsmChange);
            if(_loc1_)
            {
               _loc1_.setReady();
               if(this.view.boards.focusedBoardView)
               {
                  this.view.boards.focusedBoardView.board.loadVfxLibrary();
                  this.view.boards.focusedBoardView.board.loadSoundLibrary();
                  this.view.boards.focusedBoardView.handlePreloadEntityDefs();
               }
            }
         }
         if(!this.camera)
         {
            this.camera = this.scene._camera;
            if(this.camera)
            {
               this.camera.addEventListener(Camera.EVENT_CAMERA_VIEW_CHANGED,this.cameraViewChangedHandler);
            }
         }
         if(this.speechies)
         {
            this.speechies.doInitReady();
         }
         if(this.battleInfoFlags)
         {
            this.battleInfoFlags.doInitReady();
         }
         if(this.battleVfx)
         {
            this.battleVfx.doInitReady();
         }
         if(this.battleDamageFlags)
         {
            this.battleDamageFlags.doInitReady();
         }
         if(this.animDebug)
         {
            this.animDebug.doInitReady();
         }
         if(this.pathDebug)
         {
            this.pathDebug.doInitReady();
         }
         dispatchEvent(new Event(EVENT_DO_INIT_READY));
      }
      
      private function get areBattleButtonsRenderable() : Boolean
      {
         if(!this.scene.ready || !BattleFsmConfig.guiHudShouldRender || this._buttonsCmdDisabled)
         {
            return false;
         }
         if(!this.battleFsm)
         {
            return false;
         }
         var _loc1_:State = this.battleFsm.current;
         if(!_loc1_)
         {
            return false;
         }
         if(_loc1_ as BattleStateWaveRespawn || _loc1_ as BattleStateWave_Base || _loc1_ as BattleStateFinish || Boolean(_loc1_ as BattleStateFinished))
         {
            return false;
         }
         return true;
      }
      
      private function checkBattleButtonsVisibility() : void
      {
         var _loc1_:Boolean = this.areBattleButtonsRenderable;
         if(this.helpCorner)
         {
            this.helpCorner.visible = _loc1_ && this.sceneState.helpEnabled;
         }
         if(this.gp_menu)
         {
            this.gp_menu.visible = _loc1_ && this.sceneState.helpEnabled;
         }
         if(this.bannerDisplayCornerButton)
         {
            this.bannerDisplayCornerButton.visible = _loc1_ && this.sceneState.bannerButtonEnabled;
         }
         if(this.gp_d_u)
         {
            this.gp_d_u.visible = _loc1_ && this.sceneState.bannerButtonEnabled;
         }
      }
      
      private function onBattleFsmChange(param1:FsmEvent) : void
      {
         this.checkBattleButtonsVisibility();
      }
      
      private function doPostLoad() : void
      {
         var _loc1_:Number = NaN;
         this.postLoaded = true;
         if(this.loader.cleanedup)
         {
            return;
         }
         this.controller = new SceneViewController(this.loader.viewSprite,config.gameGuiContext,this.gpPointerHandler,this.landscapeClickHandler,this.talkieNextPrevHandler);
         addChild(this.loader.viewSprite);
         addChild(this.battleDamageFlags);
         addChild(this.battleInfoFlags);
         addChild(this.battleVfx);
         addChild(this.animDebug);
         addChild(this.pathDebug);
         this.loader.viewSprite.anchor.top = null;
         this.loader.viewSprite.anchor.bottom = null;
         this.loader.viewSprite.setPosition(0,0);
         this.loader.viewSprite.anchor.percentHeight = 100;
         this.loader.viewSprite.anchor.percentWidth = 100;
         this.soundController = new SoundController("ScenePage",config.soundSystem.driver,this.soundControllerCompleteHandler,config.logger);
         this.soundController.library = !!this.loader.def.soundLibrary ? this.loader.def.soundLibrary : null;
         if(!this.soundController.library)
         {
            this.soundControllerCompleteHandler(null);
         }
         if(this.scene.focusedBoard)
         {
            this.battleHandler = new ScenePageBattleHandler(this);
            this.checkBattleChatEnabled();
         }
         if(Boolean(mcClazzCornerButtonHelp) && !this.helpCorner)
         {
            this.helpCorner = new mcClazzCornerButtonHelp() as IGuiButton;
            this.helpCorner.movieClip.name = "corner_button_help";
            this.helpCorner.setDownFunction(this.helpButtonClickedHandler);
            _loc1_ = Math.min(1.25,BoundedCamera.computeDpiScaling(width,height));
            this.helpCorner.movieClip.scaleX = this.helpCorner.movieClip.scaleY = 0.6 * _loc1_;
            addChild(this.helpCorner.movieClip);
            addChild(this.gp_menu);
         }
         if(!this.travelPage && !this.convoPage)
         {
            this.setupBannerDisplayCornerButton();
            if(this._enableBanner && mcClazzBannerHelp && !this.helpBanner)
            {
               this.helpBanner = new mcClazzBannerHelp() as MovieClip;
               this.helpBannerDisplay = new BannerDisplay(config.fsm,this.helpBanner);
               config.gameGuiContext.translateDisplayObjects(LocaleCategory.GUI,this.helpBanner);
            }
         }
         config.gameGuiContext.translateDisplayObjects(LocaleCategory.GUI,this);
         bringContainerToFront();
         if(this.convoPage)
         {
            bringChildToFront(this.convoPage);
         }
         if(this.travelPage)
         {
            bringChildToFront(this.travelPage);
         }
         if(this.sagaStartPage)
         {
            bringChildToFront(this.sagaStartPage);
         }
         this.landscapeGp = new LandscapeGpOverlay(this);
         addChild(this.landscapeGp);
         this.checkBattleButtonsVisibility();
         this.resizeHandler();
      }
      
      private function setupBannerDisplayCornerButton() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:Number = NaN;
         if(mcClazzCornerButtonBanner)
         {
            _loc1_ = new mcClazzCornerButtonBanner() as MovieClip;
            this.bannerDisplayCornerButton = _loc1_ as IGuiButton;
            this.bannerDisplayCornerButton.movieClip.name = "corner_button_banner";
            this.bannerDisplayCornerButton.guiButtonContext = config.gameGuiContext;
            (this.bannerDisplayCornerButton as MovieClip).visible = this.enableBanner && BattleFsmConfig.guiHudShouldRender;
            addChild(this.bannerDisplayCornerButton.movieClip);
            this.bannerDisplayCornerButton.setDownFunction(this.bannerButtonClickedHandler);
            this.bannerDisplayCornerButton.movieClip.visible = this.sceneState.bannerButtonEnabled && this.scene.ready && BattleFsmConfig.guiHudShouldRender;
            _loc2_ = Math.min(1.25,BoundedCamera.computeDpiScaling(width,height));
            _loc1_.scaleX = _loc1_.scaleY = _loc2_;
            if(config.globalPrefs.getPref(GameConfig.PREF_STRAND_TUTORIAL_PULSE))
            {
               this.bannerDisplayCornerButton.pulseHover(500);
            }
            addChild(this.gp_d_u);
         }
      }
      
      private function wipeInCompleteHandler() : void
      {
         if(this.wipe.parent)
         {
            this.wipe.parent.removeChild(this.wipe);
         }
         this.scene.wiped = true;
         this.wiping = false;
      }
      
      private function wipeOutCompleteHandler() : void
      {
         this._sceneState.isReadyForTransitionOut = true;
         this.wiping = false;
         if(Boolean(this.view) && Boolean(this.view.landscapeView))
         {
            (this.view.landscapeView as LandscapeViewBase).stopRendering();
         }
         if(Boolean(this.view) && this.view.parent == this)
         {
            removeChild(this.view);
         }
         this.visible = false;
      }
      
      public function soundControllerCompleteHandler(param1:SoundController) : void
      {
         var _loc3_:ISoundDef = null;
         if(this.scene._def.killMusic)
         {
            config.soundSystem.music = null;
         }
         var _loc2_:String = this.scene._def.xmusic;
         if(_loc2_)
         {
            _loc3_ = !!this.soundController.library ? this.soundController.library.getSoundDef(_loc2_) : null;
            if(!_loc3_ && Boolean(config.saga))
            {
               _loc3_ = config.saga.sound.music.library.getSoundDef(_loc2_);
            }
            if(!_loc3_)
            {
               _loc3_ = config.soundSystem.controller.library.getSoundDef(_loc2_);
            }
            if(_loc3_)
            {
               config.soundSystem.playMusicDef(_loc3_);
            }
         }
      }
      
      protected function helpButtonClickedHandler(param1:IGuiButton) : void
      {
         var _loc2_:SceneState = null;
         if(!param1.visible || !param1.movieClip.stage)
         {
            return;
         }
         config.gameGuiContext.playSound("ui_help");
         if(config.fsm.current as TownState)
         {
            _loc2_ = config.fsm.current as SceneState;
            if(_loc2_.helpEnabled)
            {
               this.loader.viewSprite.showHelp = !this.loader.viewSprite.showHelp;
            }
         }
         else if(Boolean(this.battleHandler) && Boolean(this.battleHandler.hud))
         {
            this.battleHandler.hud.toggleQuestionMarkHelp();
         }
      }
      
      protected function bannerButtonClickedHandler(param1:IGuiButton) : void
      {
         if(!param1.visible || !param1.movieClip.stage)
         {
            return;
         }
         config.gameGuiContext.playSound("ui_help");
         if(config.fsm.current as TownState)
         {
            config.globalPrefs.setPref(GameConfig.PREF_STRAND_TUTORIAL_PULSE,false);
            if(!this.helpBanner.parent)
            {
               addChild(this.helpBanner);
            }
            else
            {
               this.helpBanner.parent.removeChild(this.helpBanner);
            }
         }
         else
         {
            this.loader.viewSprite.showHelp = !this.loader.viewSprite.showHelp;
         }
      }
      
      override public function update(param1:int) : void
      {
         if(cleanedup || !this.scene || !this.view)
         {
            return;
         }
         if(this.frameTimeMonitor)
         {
            this.frameTimeMonitor.update(param1);
         }
         super.update(param1);
         if(this.sceneState.cleanedup)
         {
            return;
         }
         if(this.battleHandler)
         {
            this.battleHandler.updateInput(param1);
         }
         if(this.controller)
         {
            this.controller.update(param1);
         }
         if(this.scene)
         {
            this.scene.update(param1);
         }
         if(this.view)
         {
            this.view.update(param1);
         }
         if(Boolean(this.travelPage) && this.allowTravelPage)
         {
            this.travelPage.update(param1);
         }
         if(this.battleHandler)
         {
            this.battleHandler.update(param1);
         }
         if(this.speechies)
         {
            this.speechies.update();
         }
         if(this.battleInfoFlags)
         {
            this.battleInfoFlags.update(param1);
         }
         if(this.battleVfx)
         {
            this.battleVfx.update(param1);
         }
         if(this.battleDamageFlags)
         {
            this.battleDamageFlags.update();
         }
         if(this.animDebug)
         {
            this.animDebug.update(param1);
         }
         if(this.pathDebug)
         {
            this.pathDebug.update(param1);
         }
         if(this.sagaStartPage)
         {
            this.sagaStartPage.update(param1);
         }
         if(this.landscapeGp)
         {
            this.landscapeGp.update(param1);
         }
         if(this.tallyPage)
         {
            this.tallyPage.update(param1);
         }
      }
      
      public function get warResolutionPage() : WarResolutionPage
      {
         return this._warResolutionPage;
      }
      
      public function set warResolutionPage(param1:WarResolutionPage) : void
      {
         if(this._warResolutionPage == param1)
         {
            return;
         }
         if(this._warResolutionPage)
         {
            if(this._warResolutionPage.parent)
            {
               this._warResolutionPage.parent.removeChild(this._warResolutionPage);
            }
            this._warResolutionPage.cleanup();
            this._warResolutionPage = null;
         }
         this._warResolutionPage = param1;
         if(this._warResolutionPage)
         {
            addChild(this._warResolutionPage);
            this.warResolutionPage.start();
         }
      }
      
      private function warHandler(param1:Event) : void
      {
         var _loc2_:SceneState = this._sceneState;
         this.warResolutionPage = new WarResolutionPage(config,_loc2_.warFinished,_loc2_.warOutcome,this.warResolutionPageClosedHandler);
      }
      
      private function battleResolutionHandler(param1:Event) : void
      {
         var _loc2_:SceneState = this._sceneState;
         this.battleHandler.showBattleResolution(_loc2_.battleFinished,_loc2_.battleResolutionShowStats);
      }
      
      private function warResolutionPageClosedHandler(param1:WarResolutionPage) : void
      {
         if(cleanedup)
         {
            return;
         }
         if(this.warResolutionPage)
         {
            this.warResolutionPage = null;
         }
         if(Boolean(config) && Boolean(config.saga))
         {
            config.saga.triggerWarResolutionClosed();
         }
      }
      
      public function handlePostBattleChatInit() : void
      {
         if(this.battleHandler)
         {
            this.battleHandler.handlePostBattleChatInit();
         }
      }
      
      public function get enableBanner() : Boolean
      {
         return this._enableBanner;
      }
      
      public function set enableBanner(param1:Boolean) : void
      {
         this._enableBanner = param1;
         this.handleLoadBanner();
      }
      
      public function get hideStartPage() : Boolean
      {
         return this._hideStartPage;
      }
      
      public function set hideStartPage(param1:Boolean) : void
      {
         this._hideStartPage = param1;
         if(this.sagaStartPage)
         {
            this.sagaStartPage.visible = !this._hideStartPage;
         }
      }
      
      private function driftCmdHandler(param1:CmdExec) : void
      {
         var _loc8_:String = null;
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 3)
         {
            logger.info("Usage: " + param1.cmd.name + " <delta pixels> <duration seconds> [easing] [zoom] [zoomdelay seconds]");
            logger.info("Eases: linear, quad, cubic, quart, quint, strong, sine");
            return;
         }
         if(!this.camera)
         {
            logger.info("No camera in this scene...");
            return;
         }
         var _loc3_:int = int(_loc2_[1]);
         var _loc4_:Number = Number(_loc2_[2]);
         var _loc5_:Function = Quad.easeInOut;
         if(_loc2_.length > 3)
         {
            _loc8_ = _loc2_[3];
            _loc5_ = LandscapeSplineDef.computeEaseFunction(_loc8_,true,true);
         }
         var _loc6_:Number = 0;
         if(_loc2_.length > 4)
         {
            _loc6_ = Number(_loc2_[4]);
         }
         var _loc7_:Number = 0;
         if(_loc2_.length > 5)
         {
            _loc7_ = Number(_loc2_[5]);
         }
         if(this.drift)
         {
            this.drift.kill();
         }
         if(this.driftZoom)
         {
            this.driftZoom.kill();
         }
         if(this.camera.drift.anchor)
         {
            this.camera.drift.forceAnchor();
         }
         if(_loc3_)
         {
            this.camera.x -= _loc3_;
            this.drift = TweenMax.to(this.camera,_loc4_,{
               "x":this.camera.x + _loc3_ * 2,
               "repeat":-1,
               "yoyo":true,
               "ease":_loc5_
            });
         }
         this.camera.zoom = 1;
         if(_loc6_ != 1)
         {
            this.driftZoom = TweenMax.to(this.camera,_loc4_,{
               "zoom":_loc6_,
               "delay":_loc7_,
               "repeat":-1,
               "yoyo":true,
               "ease":_loc5_
            });
         }
      }
      
      private function buttonsCmdHandler(param1:CmdExec) : void
      {
         this._buttonsCmdDisabled = !this._buttonsCmdDisabled;
         this.checkBattleButtonsVisibility();
         logger.info("_buttonsCmdDisabled=" + this._buttonsCmdDisabled);
      }
      
      private function hideStartCmdHandler(param1:CmdExec) : void
      {
         this.hideStartPage = !this.hideStartPage;
      }
      
      private function sceneTransitioningOutHandler(param1:Event) : void
      {
         if(cleanedup)
         {
            return;
         }
         this.startWipedownOut(this.wipeOutDuration);
      }
      
      public function get wiping() : Boolean
      {
         return this._wiping;
      }
      
      public function set wiping(param1:Boolean) : void
      {
         if(this._wiping == param1)
         {
            return;
         }
         this._wiping = param1;
         if(logger.isDebugEnabled)
         {
            logger.debug("ScenePage.wiping " + param1);
         }
         if(this._wiping)
         {
            if(Boolean(this.scene) && Boolean(this.scene.landscape))
            {
               this.scene.landscape.enableHover = false;
            }
         }
         else if(this.scene && this.scene.landscape && this.scene.ready)
         {
            this.scene.landscape.enableHover = true;
         }
         if(Boolean(this.travelPage) && this.allowTravelPage)
         {
            this.travelPage.checkHudEnables();
         }
      }
      
      public function updateClickables() : void
      {
         if(Boolean(this.view) && Boolean(this.view.landscapeView))
         {
            this.view.landscapeView.updateClickables();
         }
      }
      
      private function gpPointerHandler() : void
      {
         if(this.travelPage)
         {
            this.travelPage.gpPointerHandler();
         }
         if(this.landscapeGp)
         {
            this.landscapeGp.pointerDirty();
         }
      }
      
      private function talkieNextPrevHandler(param1:IGuiCharacterIconSlot, param2:Point, param3:Boolean) : IGuiCharacterIconSlot
      {
         if(this.travelPage)
         {
            return this.travelPage.talkieNextPrev(param1,param2,param3);
         }
         return null;
      }
      
      private function guiHudEnableHandler(param1:Event) : void
      {
         this.handleLoadBanner();
         this.bannersHandler(null);
         this.helpHandler(null);
      }
      
      override public function handleOptionsButton() : void
      {
         if(this.battleHandler)
         {
            this.battleHandler.handleOptionsButton();
         }
         if(this.travelPage)
         {
            this.travelPage.handleOptionsButton();
         }
      }
      
      override public function handleOptionsShowing(param1:Boolean) : void
      {
         if(this.battleHandler)
         {
            this.battleHandler.handleOptionsShowing(param1);
         }
         if(this.travelPage)
         {
            this.travelPage.handleOptionsShowing(param1);
         }
      }
      
      public function handleDpadUpButton() : void
      {
         if(this.gp_d_u)
         {
            this.gp_d_u.pulse();
         }
      }
      
      public function handleMenuButton() : void
      {
         if(this.gp_menu)
         {
            this.gp_menu.pulse();
         }
      }
      
      private function cmdfunc_hidegui(param1:CmdExec) : void
      {
         this.hideStartPage = !this._hideStartPage;
         if(this.travelPage)
         {
            this.travelPage.hideTravelHud = this._hideStartPage;
         }
         if(this.tallyPage)
         {
            this.tallyPage.visible = !this._hideStartPage;
         }
      }
      
      public function performTally(param1:String, param2:Function, param3:Boolean) : void
      {
         this.tallyPage = new TallyPage(this,param3);
         var _loc4_:int = 0;
         if(this.travelPage)
         {
            _loc4_ = getChildIndex(this.travelPage);
            _loc4_ = Math.max(_loc4_,0);
            _loc4_ = Math.min(_loc4_,numChildren);
         }
         addChildAt(this.tallyPage,_loc4_);
         this.tallyPage.preloadShatterAssets(this.tallyPreloadComplete,[param1,param2]);
      }
      
      private function tallyPreloadComplete(param1:Array) : void
      {
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc2_:String = param1[0];
         var _loc3_:Function = param1[1];
         var _loc4_:Array = _loc2_.split(";");
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_.length)
         {
            _loc6_ = _loc4_[_loc5_] as String;
            if(_loc6_)
            {
               _loc6_ = StringUtil.trim(_loc6_);
               param1 = _loc6_.split(",");
               _loc7_ = 0;
               while(_loc7_ < param1.length)
               {
                  param1[_loc7_] = StringUtil.trim(param1[_loc7_]);
                  _loc7_++;
               }
               if(param1.length == 3)
               {
                  this.tallyPage.addTallyText(param1[0],param1[1],param1[2]);
               }
               else if(param1.length == 2)
               {
                  this.tallyPage.addTallyAnim(param1[0],param1[1]);
               }
               else if(param1.length == 1)
               {
                  if(param1[0] == null || param1[0] == "")
                  {
                     this.tallyPage.addSumStep();
                  }
                  else
                  {
                     this.tallyPage.addPostTotalMessage(param1[0]);
                  }
               }
               else if(param1.length == 0)
               {
                  this.tallyPage.addSumStep();
               }
            }
            _loc5_++;
         }
         this.tallyPage.setCallback(_loc3_);
         this.tallyPage.start();
      }
      
      public function cleanupTally() : void
      {
         if(this.tallyPage)
         {
            removeChild(this.tallyPage);
            this.tallyPage.cleanup();
            this.tallyPage = null;
         }
      }
      
      public function isTravelFalling() : Boolean
      {
         var _loc1_:ILandscapeView = !!this.view ? this.view.landscapeView : null;
         var _loc2_:TravelView = !!_loc1_ ? _loc1_.travelView : null;
         return Boolean(_loc2_) && _loc2_.isTravelFalling();
      }
   }
}
