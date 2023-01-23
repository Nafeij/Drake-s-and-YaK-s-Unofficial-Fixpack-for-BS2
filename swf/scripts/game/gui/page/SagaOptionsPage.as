package game.gui.page
{
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleScenario;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.locale.LocaleCategory;
   import engine.core.render.BoundedCamera;
   import engine.core.render.Screenshot;
   import engine.saga.Saga;
   import engine.saga.SagaCreditsDef;
   import engine.saga.SagaDef;
   import engine.saga.SagaEvent;
   import engine.saga.SagaVar;
   import engine.saga.vars.VariableType;
   import engine.scene.model.Scene;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.ui.Keyboard;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   import game.gui.IGuiDialog;
   import game.gui.IGuiOptionsAudio;
   import game.gui.IGuiOptionsAudioListener;
   import game.gui.IGuiOptionsBattleObjectives;
   import game.gui.IGuiOptionsBattleObjectivesListener;
   import game.gui.IGuiOptionsLang;
   import game.gui.IGuiOptionsLangListener;
   import game.gui.IGuiSagaOptions;
   import game.gui.IGuiSagaOptionsDifficulty;
   import game.gui.IGuiSagaOptionsDifficultyListener;
   import game.gui.IGuiSagaOptionsListener;
   import game.gui.battle.IGuiOptionsGp;
   import game.gui.battle.IGuiOptionsGpListener;
   
   public class SagaOptionsPage extends GamePage implements IGuiSagaOptionsListener, IGuiSagaOptionsDifficultyListener, IGuiOptionsLangListener, IGuiOptionsGpListener, IGuiOptionsBattleObjectivesListener, IGuiOptionsAudioListener
   {
      
      public static var mcOptionsClazz:Class;
      
      public static var mcDifficultyClazz:Class;
      
      public static var mcAudioClazz:Class;
      
      public static var mcLangClazz:Class;
      
      public static var mcGpConfigGlazz:Class;
      
      public static var mcGpClazz:Class;
      
      public static var mcBattleObjectivesClazz:Class;
      
      public static var ENABLE_QUIT_GAME:Boolean = true;
      
      public static var ENABLE_SHARE_BAR:Boolean = true;
      
      public static var ENABLE_GP_BUTTON:Boolean = true;
      
      public static var fnGooglePlaySignIn:Function = null;
      
      public static var fnGooglePlaySignOut:Function = null;
      
      public static var IS_GOOGLE_PLAY_RECONNECT:Boolean = false;
       
      
      private var guiOptions:IGuiSagaOptions;
      
      private var guiGpConfig:IGuiGpConfig;
      
      private var guiDifficulty:IGuiSagaOptionsDifficulty;
      
      private var guiAudio:IGuiOptionsAudio;
      
      private var guiLang:IGuiOptionsLang;
      
      private var guiBattleObjectives:IGuiOptionsBattleObjectives;
      
      private var guiGp:IGuiOptionsGp;
      
      private var cmd_esc:Cmd;
      
      private var cmd_kbd_back:Cmd;
      
      private var cmd_esc_gp:Cmd;
      
      private var shareHelper:SagaOptionsPageShareHelper;
      
      private var wasScreenshotVisible:Boolean;
      
      private var gplayer:int = 0;
      
      private var saga:Saga;
      
      private var didPause:Boolean;
      
      private var gpConfigFromOptions:Boolean;
      
      public function SagaOptionsPage(param1:GameConfig)
      {
         this.cmd_esc = new Cmd("cmd_esc_options",this.cmdfunc_esc);
         this.cmd_kbd_back = new Cmd("cmd_options_back",this.cmdfunc_kbd_back);
         this.cmd_esc_gp = new Cmd("cmd_esc_options_gp",this.cmdfunc_esc_gp);
         super(param1);
         allowPageScaling = false;
         debugRender = 3422552064;
         this.visible = false;
         this.shareHelper = new SagaOptionsPageShareHelper(param1);
         this.guiOptions = new mcOptionsClazz() as IGuiSagaOptions;
         this.guiDifficulty = new mcDifficultyClazz() as IGuiSagaOptionsDifficulty;
         this.guiAudio = new mcAudioClazz() as IGuiOptionsAudio;
         this.guiGpConfig = new mcGpConfigGlazz() as IGuiGpConfig;
         this.guiLang = new mcLangClazz() as IGuiOptionsLang;
         this.guiBattleObjectives = new mcBattleObjectivesClazz() as IGuiOptionsBattleObjectives;
         this.guiGp = new mcGpClazz() as IGuiOptionsGp;
         this.guiOptions.init(param1.gameGuiContext,this,this.shareHelper);
         param1.context.locale.translateDisplayObjects(LocaleCategory.GUI,this.guiOptions as MovieClip,logger);
         addChild(this.guiOptions as MovieClip);
         this.guiDifficulty.init(param1.gameGuiContext,this);
         param1.context.locale.translateDisplayObjects(LocaleCategory.GUI,this.guiDifficulty as MovieClip,logger);
         addChild(this.guiDifficulty as MovieClip);
         this.guiAudio.init(param1.gameGuiContext,this);
         param1.context.locale.translateDisplayObjects(LocaleCategory.GUI,this.guiAudio as MovieClip,logger);
         addChild(this.guiAudio as MovieClip);
         this.guiBattleObjectives.init(param1.gameGuiContext,this);
         param1.context.locale.translateDisplayObjects(LocaleCategory.GUI,this.guiBattleObjectives as MovieClip,logger);
         addChild(this.guiBattleObjectives as MovieClip);
         this.guiLang.init(param1.gameGuiContext,this);
         param1.context.locale.translateDisplayObjects(LocaleCategory.GUI,this.guiLang as MovieClip,logger);
         addChild(this.guiLang as MovieClip);
         this.guiGp.init(param1.gameGuiContext,this);
         param1.context.locale.translateDisplayObjects(LocaleCategory.GUI,this.guiGp as MovieClip,logger);
         addChild(this.guiGp as MovieClip);
         this.guiGpConfig.init(param1.gameGuiContext);
         param1.context.locale.translateDisplayObjects(LocaleCategory.GUI,this.guiGpConfig as MovieClip,logger);
         addChild(this.guiGpConfig as MovieClip);
         this.guiGpConfig.addEventListener(Event.CLOSE,this.gpConfigCloseHandler);
         this.guiGpConfig.addEventListener(Event.COMPLETE,this.gpConfigCompleteHandler);
         this.resizeHandler();
      }
      
      private function screenshotStartHandler(param1:Event) : void
      {
         this.wasScreenshotVisible = visible;
         super.visible = false;
      }
      
      private function screenshotEndHandler(param1:Event) : void
      {
         if(this.wasScreenshotVisible)
         {
            super.visible = true;
         }
      }
      
      public function showOptions() : void
      {
         this.visible = true;
         Screenshot.dispatcher.addEventListener(Screenshot.EVENT_START,this.screenshotStartHandler);
         Screenshot.dispatcher.addEventListener(Screenshot.EVENT_END,this.screenshotEndHandler);
         this.saga.addEventListener(SagaEvent.EVENT_REFRESH_PAUSE_BINDING,this.guiOptionsGpRefreshBindingHandler);
      }
      
      public function hideOptions() : void
      {
         this.saga.removeEventListener(SagaEvent.EVENT_REFRESH_PAUSE_BINDING,this.guiOptionsGpRefreshBindingHandler);
         this.visible = false;
         Screenshot.dispatcher.removeEventListener(Screenshot.EVENT_START,this.screenshotStartHandler);
         Screenshot.dispatcher.removeEventListener(Screenshot.EVENT_END,this.screenshotEndHandler);
      }
      
      override public function cleanup() : void
      {
         if(this.guiOptions)
         {
            this.guiOptions.cleanup();
            this.guiOptions = null;
         }
         if(this.guiDifficulty)
         {
            this.guiDifficulty.cleanup();
            this.guiDifficulty = null;
         }
         if(this.guiAudio)
         {
            this.guiAudio.cleanup();
            this.guiAudio = null;
         }
         if(this.guiLang)
         {
            this.guiLang.cleanup();
            this.guiLang = null;
         }
         if(this.guiBattleObjectives)
         {
            this.guiBattleObjectives.cleanup();
            this.guiBattleObjectives = null;
         }
         if(this.guiGp)
         {
            this.guiGp.cleanup();
            this.guiGp = null;
         }
         if(this.guiGpConfig)
         {
            this.guiGpConfig.cleanup();
            this.guiGpConfig = null;
         }
         this.visible = false;
         super.cleanup();
      }
      
      override protected function resizeHandler() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:MovieClip = null;
         var _loc3_:MovieClip = null;
         var _loc7_:MovieClip = null;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         super.resizeHandler();
         _loc1_ = this.guiOptions as MovieClip;
         _loc2_ = this.guiDifficulty as MovieClip;
         _loc3_ = this.guiAudio as MovieClip;
         var _loc4_:MovieClip = this.guiLang as MovieClip;
         var _loc5_:MovieClip = this.guiGp as MovieClip;
         var _loc6_:MovieClip = this.guiGpConfig as MovieClip;
         _loc7_ = this.guiBattleObjectives as MovieClip;
         _loc8_ = BoundedCamera.computeDpiScaling(width,height);
         if(_loc1_)
         {
            _loc1_.x = width / 2;
            _loc1_.y = height / 2;
            _loc1_.scaleX = _loc1_.scaleY = _loc8_;
         }
         if(_loc2_)
         {
            _loc2_.x = width / 2;
            _loc2_.y = height / 2;
            _loc2_.scaleX = _loc2_.scaleY = _loc8_;
         }
         if(_loc3_)
         {
            _loc3_.x = width / 2;
            _loc3_.y = height / 2;
            _loc3_.scaleX = _loc3_.scaleY = _loc8_;
         }
         if(_loc4_)
         {
            _loc4_.x = width / 2;
            _loc4_.y = height / 2;
            _loc4_.scaleX = _loc4_.scaleY = _loc8_;
         }
         if(_loc7_)
         {
            _loc7_.x = width / 2;
            _loc7_.y = height / 2;
            _loc7_.scaleX = _loc7_.scaleY = _loc8_;
         }
         if(_loc5_)
         {
            _loc5_.x = width / 2;
            _loc5_.y = height / 2;
            _loc5_.scaleX = _loc5_.scaleY = _loc8_;
         }
         if(_loc6_)
         {
            _loc6_.x = width / 2;
            _loc6_.y = height / 2;
            _loc9_ = width / 2140;
            _loc9_ = Math.min(_loc9_,height / 1450);
            _loc9_ = Math.min(1,_loc9_);
            _loc6_.scaleX = _loc6_.scaleY = _loc9_;
         }
      }
      
      public function cmdfunc_esc_gp(param1:CmdExec) : void
      {
         if(Boolean(this.guiGpConfig) && this.guiGpConfig.visible)
         {
            return;
         }
         if(this.guiGp)
         {
            if(this.guiGp.closeOptionsGp())
            {
               if(this.guiOptions)
               {
                  (this.guiOptions as MovieClip).visible = true;
               }
               return;
            }
         }
         if(this.guiDifficulty)
         {
            if(this.guiDifficulty.closeOptionsDifficulty())
            {
               if(this.guiOptions)
               {
                  (this.guiOptions as MovieClip).visible = true;
               }
               return;
            }
         }
         if(this.guiAudio)
         {
            if(this.guiAudio.closeOptionsAudio())
            {
               if(this.guiOptions)
               {
                  (this.guiOptions as MovieClip).visible = true;
               }
               return;
            }
         }
         if(this.guiLang)
         {
            if(this.guiLang.closeOptionsLang())
            {
               if(this.guiOptions)
               {
                  (this.guiOptions as MovieClip).visible = true;
               }
               return;
            }
         }
         this.guiOptionsResume();
      }
      
      public function cmdfunc_kbd_back(param1:CmdExec) : void
      {
         if(Boolean(this.guiGpConfig) && this.guiGpConfig.visible)
         {
            return;
         }
         this.cmdfunc_esc_gp(param1);
      }
      
      public function cmdfunc_esc(param1:CmdExec) : void
      {
         if(this.guiGpConfig)
         {
            if(this.guiGpConfig.closeGpConfig())
            {
               if(this.guiGp)
               {
                  (this.guiGp as MovieClip).visible = true;
               }
               return;
            }
         }
         if(this.guiGp)
         {
            if(this.guiGp.closeOptionsGp())
            {
               if(this.guiOptions)
               {
                  (this.guiOptions as MovieClip).visible = true;
               }
               return;
            }
         }
         if(this.guiDifficulty)
         {
            if(this.guiDifficulty.closeOptionsDifficulty())
            {
               if(this.guiOptions)
               {
                  (this.guiOptions as MovieClip).visible = true;
               }
               return;
            }
         }
         if(this.guiAudio)
         {
            if(this.guiAudio.closeOptionsAudio())
            {
               if(this.guiOptions)
               {
                  (this.guiOptions as MovieClip).visible = true;
               }
               return;
            }
         }
         if(this.guiLang)
         {
            if(this.guiLang.closeOptionsLang())
            {
               if(this.guiOptions)
               {
                  (this.guiOptions as MovieClip).visible = true;
               }
               return;
            }
         }
         if(this.guiBattleObjectives)
         {
            if(this.guiBattleObjectives.closeOptionsBattleObjectives())
            {
               if(this.guiOptions)
               {
                  (this.guiOptions as MovieClip).visible = true;
               }
               return;
            }
         }
         this.guiOptionsResume();
      }
      
      override public function set visible(param1:Boolean) : void
      {
         var _loc2_:Scene = null;
         var _loc3_:BattleBoard = null;
         var _loc4_:Boolean = false;
         if(super.visible == param1)
         {
            return;
         }
         super.visible = param1;
         if(super.visible)
         {
            this.gplayer = GpBinder.gpbinder.createLayer("SagaOptionsPage");
            this.guiOptions.enableQuitButton = !config.saga || !config.saga.isStartScene || ENABLE_QUIT_GAME || Boolean(config.saga.parentSagaUrl);
            this.guiOptions.enableTutorialExitButton = false;
            this.guiOptions.enableSurvivalReloadButton = false;
            this.guiOptions.enableTrainingExitButton = false;
            this.saga = config.saga;
            if(this.saga)
            {
               this.saga.pause(this);
               if(this.guiOptions)
               {
                  _loc2_ = this.saga.getScene();
                  _loc3_ = this.saga.getBattleBoard();
                  if(_loc3_ && _loc2_ && Boolean(_loc2_._def))
                  {
                     _loc4_ = this.saga.inTrainingBattle || _loc2_._def.showTrainingExitButton;
                  }
                  this.guiOptions.enableTrainingExitButton = _loc4_;
                  if(!_loc4_)
                  {
                     if(_loc3_)
                     {
                        this.guiOptions.enableTutorialExitButton = this.saga.getVarBool(SagaVar.VAR_TUTORIAL_SKIPPABLE);
                        this.guiOptions.enableSurvivalReloadButton = this.saga.isSurvivalBattle;
                     }
                  }
                  this.guiOptions.battleScenario = !!_loc3_ ? _loc3_.scenario : null;
               }
            }
            (this.guiOptions as MovieClip).visible = true;
            config.gameGuiContext.playSound("ui_generic");
            this.doBind();
         }
         else
         {
            GpBinder.gpbinder.removeLayer(this.gplayer);
            if(this.saga)
            {
               this.saga.unpause(this);
               this.saga = null;
            }
            this.showOnly(null);
            config.gameGuiContext.playSound("ui_generic");
            this.doUnbind();
         }
      }
      
      private function doBind() : void
      {
         config.keybinder.disableAllBindsGroups();
         config.keybinder.bind(false,false,false,Keyboard.ESCAPE,this.cmd_esc,"");
         config.keybinder.bind(false,false,false,Keyboard.BACK,this.cmd_kbd_back,"");
         config.gpbinder.bindPress(GpControlButton.B,this.cmd_esc_gp,"");
      }
      
      private function doUnbind() : void
      {
         config.keybinder.enableAllBindsGroups();
         config.keybinder.unbind(this.cmd_esc);
         config.keybinder.unbind(this.cmd_kbd_back);
         config.gpbinder.unbind(this.cmd_esc_gp);
      }
      
      public function guiOptionsSetMusic(param1:Boolean) : void
      {
         config.soundSystem.mixer.musicEnabled = param1;
      }
      
      public function guiOptionsSetSfx(param1:Boolean) : void
      {
         config.soundSystem.mixer.sfxEnabled = param1;
      }
      
      public function guiOptionsSaveLoad() : void
      {
         var _loc1_:int = !!this.saga ? this.saga.profile_index : -1;
         if(Boolean(this.saga) && this.saga.isStartScene)
         {
            _loc1_ = -1;
         }
         config.pageManager.showSaveLoad(true,_loc1_,false);
      }
      
      public function guiOptionsToggleFullcreen() : void
      {
         config.context.appInfo.toggleFullscreen();
      }
      
      public function guiOptionsNews() : void
      {
         config.showNews();
      }
      
      public function guiOptionsHideLayers() : void
      {
         if(!config || !config.pageManager)
         {
            logger.debug("guiOptionsHideLayers called while there is no config or page manager.");
         }
         config.pageManager.HideAllLayers();
      }
      
      public function guiOptionsQuitGame() : void
      {
         config.pageManager.HideAllLayers();
         this.saga = config.saga;
         if(this.saga)
         {
            if(this.saga.inTrainingBattle)
            {
               this.guiOptions.enableTrainingExitButton = false;
               this.saga.inTrainingBattle = false;
            }
            if(this.saga.quitToParentSaga())
            {
               return;
            }
            if(this.saga.isStartScene || this.saga.isQuitToDesktop)
            {
               config.context.appInfo.exitGame("options");
            }
            else if(this.saga.isQuitToStartHappening)
            {
               this.saga.gotoBookmark(SagaDef.START_HAPPENING,false);
            }
            else
            {
               if(this.saga.isSurvival)
               {
                  if(this.saga.isSurvivalBattle && this.saga.survivalReloadCount >= this.saga.survivalReloadCount)
                  {
                  }
                  if(this.saga.isSurvivalSettingUp || this.saga.isSurvivalSetup)
                  {
                     if(this.saga.canSave(null,null))
                     {
                        this.saga.saveSaga(Saga.SAVE_ID_RESUME,null,null);
                     }
                     config.loadSaga(this.saga.def.url,null,null,this.saga.difficulty,-1,null,null,this.saga.parentSagaUrl);
                     return;
                  }
               }
               if(this.saga.canSave(null,null))
               {
                  this.saga.saveSaga(Saga.SAVE_ID_RESUME,null,null);
               }
               this.saga.showStartPage(true);
            }
         }
      }
      
      public function guiOptionsResume() : void
      {
         config.pageManager.hideOptions();
      }
      
      public function guiOptionsCredits() : void
      {
         var _loc1_:SagaCreditsDef = this.saga.def.getCreditsDef(0);
         config.pageManager.showCreditsPage(_loc1_,false,true);
      }
      
      private function showOnlyIf(param1:*, param2:*) : void
      {
         if(param2)
         {
            (param2 as MovieClip).visible = param1 == param2;
         }
      }
      
      private function showOnly(param1:*) : void
      {
         this.showOnlyIf(param1,this.guiLang);
         this.showOnlyIf(param1,this.guiBattleObjectives);
         this.showOnlyIf(param1,this.guiGp);
         this.showOnlyIf(param1,this.guiOptions);
         this.showOnlyIf(param1,this.guiDifficulty);
         this.showOnlyIf(param1,this.guiAudio);
         this.showOnlyIf(param1,this.guiGpConfig);
      }
      
      public function guiOptionsLang() : void
      {
         this.showOnly(this.guiLang);
      }
      
      public function guiOptionsBattleObjectives() : void
      {
         var _loc1_:BattleBoard = this.saga.getBattleBoard();
         var _loc2_:IBattleScenario = !!_loc1_ ? _loc1_.scenario : null;
         if(_loc2_)
         {
            this.showOnly(this.guiBattleObjectives);
            this.guiBattleObjectives.showScenario(_loc2_);
         }
         else
         {
            logger.info("No scenario, but button still around");
         }
      }
      
      public function guiOptionsBattleObjectivesClose() : void
      {
         this.showOnly(this.guiOptions);
      }
      
      public function guiOptionsDifficultyClose() : void
      {
         this.showOnly(this.guiOptions);
      }
      
      public function guiOptionsAudioClose() : void
      {
         this.showOnly(this.guiOptions);
      }
      
      public function guiOptionsDifficultySet(param1:int) : void
      {
         var _loc2_:Saga = config.saga;
         if(!_loc2_)
         {
            return;
         }
         _loc2_.setVar(SagaVar.VAR_DIFFICULTY,param1);
      }
      
      public function guiOptionsLangClose() : void
      {
         this.showOnly(this.guiOptions);
      }
      
      public function guiOptionsGpClose() : void
      {
         this.showOnly(this.guiOptions);
      }
      
      public function guiOptionsLangSet(param1:String) : void
      {
         config.changeLocale(param1,this.handleLangSetCompleteCallback);
      }
      
      public function guiOptionsDifficulty() : void
      {
         var _loc2_:int = 0;
         var _loc1_:Saga = config.saga;
         if(!_loc1_)
         {
            return;
         }
         if(this.guiDifficulty)
         {
            _loc2_ = _loc1_.getVar(SagaVar.VAR_DIFFICULTY,VariableType.INTEGER).asInteger;
            this.guiDifficulty.showSagaOptionsDifficulty(_loc2_);
         }
         this.showOnly(this.guiDifficulty);
      }
      
      public function guiOptionsAudio() : void
      {
         var _loc1_:Saga = config.saga;
         if(!_loc1_)
         {
            return;
         }
         if(this.guiAudio)
         {
            this.guiAudio.showOptionsAudio();
         }
         this.showOnly(this.guiAudio);
      }
      
      public function guiOptionsGp() : void
      {
         this.showOnly(this.guiGp);
      }
      
      public function guiOptionsGpRebind() : void
      {
         if(GameConfig.ENABLE_GP_REBINDING)
         {
            this.showGpRebind(true,"options rebind");
         }
         else
         {
            logger.info("SagaOptionsPage::guiOptionsGpRebind - Skipping GP rebinding: ENABLE_GP_REBINDING is set to " + GameConfig.ENABLE_GP_REBINDING);
         }
      }
      
      public function guiOptionsGpRefreshBindingHandler(param1:Event) : void
      {
         GpBinder.gpbinder.removeLayer(this.gplayer);
         this.gplayer = GpBinder.gpbinder.createLayer("SagaOptionsPage");
         this.ensureTopGp();
      }
      
      public function showGpRebind(param1:Boolean, param2:String) : void
      {
         this.gpConfigFromOptions = param1;
         this.visible = true;
         logger.info("**GpConfig INIT** SagaOptionsPage.showGpRebind fromOptions [" + param1 + "] [" + param2 + "]");
         this.showOnly(this.guiGpConfig);
      }
      
      public function get isGpConfigShowing() : Boolean
      {
         return this.guiGpConfig.movieClip.visible;
      }
      
      public function guiOptionsGpConfigClose() : void
      {
         if(this.guiGpConfig)
         {
            (this.guiGpConfig as MovieClip).visible = false;
         }
         if(this.gpConfigFromOptions)
         {
            if(this.guiOptions)
            {
               (this.guiOptions as MovieClip).visible = true;
            }
         }
         else
         {
            this.hideOptions();
            this.guiOptionsResume();
         }
      }
      
      private function handleLangSetCompleteCallback() : void
      {
      }
      
      private function gpConfigCloseHandler(param1:Event) : void
      {
         this.guiOptionsGpConfigClose();
      }
      
      private function gpConfigCompleteHandler(param1:Event) : void
      {
         config.saveGpJson();
      }
      
      public function guiOptionsTrainingExit() : void
      {
         var _loc1_:Scene = null;
         var _loc2_:Boolean = false;
         if(this.saga)
         {
            _loc1_ = this.saga.getScene();
            _loc2_ = this.saga.inTrainingBattle;
            if(!_loc2_ && _loc1_ && Boolean(_loc1_._def))
            {
               _loc2_ = _loc1_._def.showTrainingExitButton;
            }
            if(_loc2_)
            {
               this.saga.executeHappeningById("click_training_exit",null,"guiOptionsTrainingExit");
               this.guiOptionsResume();
            }
         }
      }
      
      public function guiOptionsTutorialExit() : void
      {
         var _loc3_:BattleBoard = null;
         if(!this.saga)
         {
            return;
         }
         var _loc1_:Scene = this.saga.getScene();
         var _loc2_:Boolean = this.saga.getVarBool(SagaVar.VAR_TUTORIAL_SKIPPABLE);
         if(_loc2_)
         {
            _loc3_ = this.saga.getBattleBoard();
            if(Boolean(_loc3_) && Boolean(_loc3_.fsm))
            {
               if(!_loc3_.fsm.halted && !_loc3_.fsm.battleFinished)
               {
                  this.saga.executeHappeningById("click_tutorial_skip",null,"guiOptionsTutorialExit");
               }
            }
            this.guiOptionsResume();
         }
      }
      
      public function guiOptionsSurvivalReload() : void
      {
         if(!this.saga)
         {
            return;
         }
         this.saga.survivalReload();
      }
      
      override public function update(param1:int) : void
      {
         if(Boolean(this.guiGpConfig) && this.guiGpConfig.movieClip.visible)
         {
            this.guiGpConfig.update(param1);
         }
      }
      
      public function guiOptionsGooglePlaySignOut() : void
      {
         if(fnGooglePlaySignOut != null)
         {
            fnGooglePlaySignOut();
         }
         else
         {
            logger.error("No sign-out function");
         }
      }
      
      public function guiOptionsGooglePlaySignIn() : void
      {
         if(fnGooglePlaySignIn != null)
         {
            fnGooglePlaySignIn();
         }
         else
         {
            logger.error("No sign-in function");
         }
      }
      
      public function guiOptionsGaOptState() : void
      {
         config.gameGuiContext.showGaOptStateDialog(null);
      }
      
      public function set isGooglePlaySignedIn(param1:Boolean) : void
      {
         var ok:String;
         var dialog:IGuiDialog = null;
         var title:String = null;
         var body:String = null;
         var val:Boolean = param1;
         var wasSignedIn:Boolean = this.guiOptions.googlePlaySignedIn;
         this.guiOptions.googlePlaySignedIn = val;
         ok = config.gameGuiContext.translate("ok");
         if(val && !wasSignedIn)
         {
            if(!IS_GOOGLE_PLAY_RECONNECT)
            {
               logger.info("Show signed-in dialog");
               dialog = config.gameGuiContext.createDialog();
               title = config.context.appInfo.getLocalizedString("str_google_play_signed_in_title",config.options.locale_id.id);
               body = config.context.appInfo.getLocalizedString("str_google_play_signed_in_body",config.options.locale_id.id);
               dialog.openDialog(title,body,ok,function(param1:String):void
               {
               });
            }
            else
            {
               IS_GOOGLE_PLAY_RECONNECT = false;
            }
         }
         else if(!val && wasSignedIn && !IS_GOOGLE_PLAY_RECONNECT)
         {
            logger.info("Show signed-out dialog");
            dialog = config.gameGuiContext.createDialog();
            title = config.context.appInfo.getLocalizedString("str_google_play_signed_out_title",config.options.locale_id.id);
            body = config.context.appInfo.getLocalizedString("str_google_play_signed_out_body",config.options.locale_id.id);
            dialog.openDialog(title,body,ok,function(param1:String):void
            {
            });
         }
      }
      
      public function ensureTopGp() : void
      {
         if(!visible)
         {
            return;
         }
         this.doUnbind();
         this.doBind();
         if(Boolean(this.guiOptions) && this.guiOptions.visible)
         {
            this.guiOptions.ensureTopGp();
         }
         if(Boolean(this.guiDifficulty) && this.guiDifficulty.visible)
         {
            this.guiDifficulty.ensureTopGp();
         }
         if(Boolean(this.guiAudio) && this.guiAudio.visible)
         {
            this.guiAudio.ensureTopGp();
         }
         if(Boolean(this.guiLang) && this.guiLang.visible)
         {
            this.guiLang.ensureTopGp();
         }
         if(Boolean(this.guiBattleObjectives) && this.guiBattleObjectives.visible)
         {
            this.guiBattleObjectives.ensureTopGp();
         }
      }
   }
}
