package game.gui
{
   import engine.battle.board.model.BattleScenario;
   import engine.battle.board.model.IBattleScenario;
   import engine.core.analytic.Ga;
   import engine.core.analytic.GaConfig;
   import engine.core.gp.GpSource;
   import engine.core.locale.LocaleCategory;
   import engine.gui.GuiContextEvent;
   import engine.gui.GuiGpNav;
   import engine.saga.ISaga;
   import engine.saga.Saga;
   import engine.saga.SagaVar;
   import engine.user.UserEvent;
   import engine.user.UserLifecycleManager;
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.page.SagaOptionsPage;
   
   public class GuiSagaOptions extends GuiBase implements IGuiSagaOptions
   {
       
      
      public var _button$resume:ButtonWithIndex;
      
      public var _button$fullscreen:ButtonWithIndex;
      
      public var _button$credits:ButtonWithIndex;
      
      public var _button$quit:ButtonWithIndex;
      
      public var _button$news:ButtonWithIndex;
      
      public var _button$language:ButtonWithIndex;
      
      public var _button$opt_audio:ButtonWithIndex;
      
      public var _button$gp_cfg:ButtonWithIndex;
      
      public var _button$training_exit:ButtonWithIndex;
      
      public var _button$tutorial_exit:ButtonWithIndex;
      
      public var _button$survival_reload:ButtonWithIndex;
      
      public var _button$training_objectives:ButtonWithIndex;
      
      public var _button$google_sign_in:ButtonWithIndex;
      
      public var _button$google_sign_out:ButtonWithIndex;
      
      public var _google_play_holder:MovieClip;
      
      public var _button$ga_optstate:ButtonWithIndex;
      
      public var _button$load:ButtonWithIndex;
      
      public var _button$difficulty:ButtonWithIndex;
      
      private var _text_version:TextField;
      
      private var dialogYesFunction:Function;
      
      private var listener:IGuiSagaOptionsListener;
      
      private var _share:GuiSagaOptionsShare;
      
      public var nav:GuiGpNav;
      
      private var _battleScenario:BattleScenario;
      
      public var _tooltip_survival:GuiTooltipStatusSurvival;
      
      private var isGooglePlaySignedIn:Boolean = false;
      
      public function GuiSagaOptions()
      {
         super();
         name = "GuiSagaOptions";
         super.visible = false;
         this._tooltip_survival = requireGuiChild("tooltip_survival") as GuiTooltipStatusSurvival;
         this._tooltip_survival.visible = false;
      }
      
      private function enableButton(param1:ButtonWithIndex, param2:Boolean) : void
      {
         if(param1.visible != param2)
         {
            param1.visible = param2;
            if(this.nav)
            {
               this.nav.remap();
            }
         }
      }
      
      public function set enableQuitButton(param1:Boolean) : void
      {
         this.enableButton(this._button$quit,param1);
      }
      
      public function set enableTrainingExitButton(param1:Boolean) : void
      {
         this.enableButton(this._button$training_exit,param1);
      }
      
      public function set enableTutorialExitButton(param1:Boolean) : void
      {
         this.enableButton(this._button$tutorial_exit,param1);
      }
      
      public function set enableSurvivalReloadButton(param1:Boolean) : void
      {
         this.enableButton(this._button$survival_reload,param1);
      }
      
      public function set battleScenario(param1:IBattleScenario) : void
      {
         if(this._battleScenario == param1)
         {
            return;
         }
         this._battleScenario = param1 as BattleScenario;
         this.enableButton(this._button$training_objectives,this._battleScenario != null);
      }
      
      public function init(param1:IGuiContext, param2:IGuiSagaOptionsListener, param3:IGuiSagaOptionsShareListener) : void
      {
         initGuiBase(param1);
         this.listener = param2;
         this._tooltip_survival.init(param1);
         this.nav = new GuiGpNav(param1,"opt",this);
         this._share = requireGuiChild("share") as GuiSagaOptionsShare;
         this._share.init(param1,param3,this.nav);
         this._button$resume = requireGuiChild("button$resume") as ButtonWithIndex;
         this._button$fullscreen = requireGuiChild("button$fullscreen") as ButtonWithIndex;
         this._button$credits = requireGuiChild("button$credits") as ButtonWithIndex;
         this._button$quit = requireGuiChild("button$quit") as ButtonWithIndex;
         this._button$language = requireGuiChild("button$language") as ButtonWithIndex;
         this._button$opt_audio = requireGuiChild("button$opt_audio") as ButtonWithIndex;
         this._button$news = requireGuiChild("button$news") as ButtonWithIndex;
         this._button$gp_cfg = requireGuiChild("button$gp_cfg") as ButtonWithIndex;
         this._button$training_exit = requireGuiChild("button$training_exit") as ButtonWithIndex;
         this._button$tutorial_exit = requireGuiChild("button$tutorial_exit") as ButtonWithIndex;
         this._button$survival_reload = requireGuiChild("button$survival_reload") as ButtonWithIndex;
         this._button$training_objectives = requireGuiChild("button$training_objectives") as ButtonWithIndex;
         this._button$load = requireGuiChild("button$load") as ButtonWithIndex;
         this._button$difficulty = requireGuiChild("button$difficulty") as ButtonWithIndex;
         this._button$ga_optstate = requireGuiChild("button$ga_optstate") as ButtonWithIndex;
         this._google_play_holder = requireGuiChild("google_play_holder") as MovieClip;
         this._text_version = requireGuiChild("version") as TextField;
         this._button$google_sign_in = this._google_play_holder.getChildByName("button$google_play_sign_in") as ButtonWithIndex;
         this._button$google_sign_out = this._google_play_holder.getChildByName("button$google_play_sign_out") as ButtonWithIndex;
         this._button$credits.setDownFunction(this.creditsHandler);
         this._button$credits.guiButtonContext = param1;
         this._button$resume.setDownFunction(this.onResumeClicked);
         this._button$resume.guiButtonContext = param1;
         this._button$fullscreen.setDownFunction(this.onFullscreenClicked);
         this._button$fullscreen.guiButtonContext = param1;
         this._button$fullscreen.visible = GuiSagaOptionsConfig.ENABLE_FULLSCREEN;
         this._button$quit.setDownFunction(this.onQuitGameClicked);
         this._button$quit.guiButtonContext = param1;
         this._button$news.visible = false;
         this._button$news.setDownFunction(this.onNewsClicked);
         this._button$news.guiButtonContext = param1;
         this._button$language.visible = _context.numLocales > 1;
         this._button$language.setDownFunction(this.onLanguageClicked);
         this._button$language.guiButtonContext = param1;
         this._button$opt_audio.visible = true;
         this._button$opt_audio.setDownFunction(this.onAudioClicked);
         this._button$opt_audio.guiButtonContext = param1;
         this._button$gp_cfg.visible = GpSource.GP_ENABLED && SagaOptionsPage.ENABLE_GP_BUTTON;
         this._button$gp_cfg.setDownFunction(this.onGpConfigClicked);
         this._button$gp_cfg.guiButtonContext = param1;
         this._button$gp_cfg.textOpaqueBackground = 0;
         this._button$training_exit.visible = false;
         this._button$training_exit.setDownFunction(this.onTrainingExitClicked);
         this._button$training_exit.guiButtonContext = param1;
         this._button$tutorial_exit.visible = false;
         this._button$tutorial_exit.setDownFunction(this.onTutorialExitClicked);
         this._button$tutorial_exit.guiButtonContext = param1;
         this._button$survival_reload.visible = false;
         this._button$survival_reload.setDownFunction(this.onSurvivalReloadClicked);
         this._button$survival_reload.guiButtonContext = param1;
         this._button$training_objectives.visible = false;
         this._button$training_objectives.setDownFunction(this.onTrainingObjectivesClicked);
         this._button$training_objectives.guiButtonContext = param1;
         this._button$load.setDownFunction(this.onLoadClicked);
         this._button$load.guiButtonContext = param1;
         this._button$difficulty.setDownFunction(this.onDifficultyClicked);
         this._button$difficulty.guiButtonContext = param1;
         this._google_play_holder.visible = GuiSagaOptionsConfig.ENABLE_GOOGLE_PLAY;
         this.updateVersionText();
         this._button$google_sign_in.setDownFunction(this.googleSignInClickHandler);
         this._button$google_sign_in.guiButtonContext = param1;
         this._button$google_sign_out.setDownFunction(this.googleSignOutClickHandler);
         this._button$google_sign_out.guiButtonContext = param1;
         this._button$ga_optstate.setDownFunction(this.onGaOptStateClicked);
         this._button$ga_optstate.guiButtonContext = param1;
         this._button$ga_optstate.visible = !GaConfig.optState.isNa;
         this.nav.add(this._button$resume);
         if(this._button$fullscreen.visible)
         {
            this.nav.add(this._button$fullscreen);
         }
         this.nav.add(this._button$credits);
         this.nav.add(this._button$quit);
         this.nav.add(this._button$language);
         this.nav.add(this._button$opt_audio);
         this.nav.add(this._button$load);
         this.nav.add(this._button$difficulty);
         if(this._button$gp_cfg.visible)
         {
            this.nav.add(this._button$gp_cfg);
         }
         this.nav.add(this._button$training_exit);
         this.nav.add(this._button$tutorial_exit);
         this.nav.add(this._button$survival_reload);
         this.nav.add(this._button$training_objectives);
         if(this._button$ga_optstate.visible)
         {
            this.nav.add(this._button$ga_optstate);
         }
         if(!this.nav.selected)
         {
            this.nav.selected = this._button$resume;
         }
         this.mouseEnabled = true;
         this.mouseChildren = true;
         UserLifecycleManager.Instance().addEventListener(UserEvent.ACTIVE_USER_LOST,this.onUserLost);
         param1.addEventListener(GuiContextEvent.LOCALE,this.localeHandler);
         this.updateVisibleOptions();
         registerLocaleChangeChild(this._tooltip_survival);
      }
      
      private function onUserLost(param1:UserEvent) : void
      {
         this.closeOptions();
      }
      
      private function localeHandler(param1:GuiContextEvent) : void
      {
         context.translateDisplayObjects(LocaleCategory.GUI,this);
         handleLocaleChange();
      }
      
      private function updateVersionText() : void
      {
         var _loc1_:Saga = null;
         this._text_version.text = "";
         if(Boolean(Ga.an) && Boolean(Ga.av))
         {
            this._text_version.text = Ga.an + " " + Ga.av;
         }
         else
         {
            _loc1_ = !!context ? context.saga : null;
            if(Boolean(_loc1_) && Boolean(_loc1_.appinfo))
            {
               this._text_version.text = _loc1_.appinfo.buildVersion;
            }
         }
      }
      
      override public function set visible(param1:Boolean) : void
      {
         var _loc2_:Saga = null;
         if(super.visible == param1)
         {
            return;
         }
         super.visible = param1;
         if(this.nav)
         {
            if(super.visible)
            {
               this.nav.unmap();
               this.nav.activate();
            }
            else
            {
               this.nav.deactivate();
            }
         }
         super.visible = param1;
         if(param1)
         {
            _loc2_ = !!context ? context.saga : null;
            this.enableButton(this._button$load,!_loc2_ || !_loc2_.isSurvival);
            this._tooltip_survival.visible = Boolean(_loc2_) && _loc2_.isSurvival && _loc2_.isSurvivalSetup;
            this.updateVersionText();
         }
         else if(this._tooltip_survival)
         {
            this._tooltip_survival.visible = false;
         }
         if(Boolean(this.nav) && (!this.nav.selected || this.nav.selected.visible == false))
         {
            this.nav.selected = this._button$resume;
         }
         this.updateVisibleOptions();
      }
      
      private function updateVisibleOptions() : void
      {
         var _loc1_:ISaga = null;
         var _loc3_:Boolean = false;
         _loc1_ = context.iSaga;
         if(!_loc1_)
         {
            return;
         }
         var _loc2_:Boolean = SagaOptionsPage.ENABLE_SHARE_BAR;
         _loc3_ = GuiSagaOptionsConfig.DEMO_MODE;
         this._share.visible = !_loc3_ && _loc2_ && !_loc1_.getVarBool(SagaVar.VAR_HIDE_SAGA_OPTIONS_SHARE);
         this._button$difficulty.visible = !_loc3_ && !_loc1_.isSurvival && !_loc1_.getVarBool(SagaVar.VAR_HIDE_SAGA_OPTIONS_DIFFICULTY);
         this._button$credits.visible = !_loc3_ && !_loc1_.getVarBool(SagaVar.VAR_HIDE_SAGA_OPTIONS_CREDITS);
         this._button$load.visible = !_loc3_ && !_loc1_.isSurvival && !_loc1_.getVarBool(SagaVar.VAR_HIDE_SAGA_OPTIONS_LOAD);
         this._button$opt_audio.visible = true;
         if(_loc3_)
         {
            this._button$language.visible = false;
            this._button$gp_cfg.visible = false;
            this._button$fullscreen.visible = false;
         }
      }
      
      public function cleanup() : void
      {
         this._button$resume.cleanup();
         this._button$fullscreen.cleanup();
         this._button$credits.cleanup();
         this._button$quit.cleanup();
         this._button$news.cleanup();
         this._button$resume = null;
         this._button$fullscreen = null;
         this._button$credits = null;
         this._button$quit = null;
         this._button$news = null;
         this.dialogYesFunction = null;
         this.listener = null;
         UserLifecycleManager.Instance().removeEventListener(UserEvent.ACTIVE_USER_LOST,this.onUserLost);
         cleanupGuiBase();
      }
      
      private function onDialogChoiceSelected(param1:String) : void
      {
         var _loc2_:String = context.translate("yes");
         if(param1 == _loc2_)
         {
            this.dialogYesFunction();
         }
      }
      
      private function onQuitGameClicked(param1:Object) : void
      {
         var _loc3_:IGuiDialog = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc2_:Saga = _context.saga;
         if(_loc2_.quitToParentSaga())
         {
            this.closeOptions();
            return;
         }
         this.dialogYesFunction = this.listener.guiOptionsQuitGame;
         _loc3_ = context.createDialog();
         if(context.isSagaStartPage || _loc2_.isQuitToDesktop)
         {
            _loc5_ = context.translate("start_quit_confirm_title");
            _loc4_ = context.locale.translateAppTitleToken("start_quit_confirm_text");
         }
         else if(_loc2_.isQuitToStartHappening)
         {
            _loc5_ = context.translate("quit_game_title_start");
            _loc4_ = context.translate("quit_game_body_start");
         }
         else if(_loc2_.isSurvival)
         {
            if(_loc2_.isSurvivalBattle)
            {
               if(_loc2_.survivalReloadCount >= _loc2_.survivalReloadLimit)
               {
                  _loc5_ = context.translate("survival_quit_battle_limit_title");
                  _loc4_ = context.translate("survival_quit_battle_limit_body");
               }
               else
               {
                  _loc5_ = context.translate("survival_quit_battle_title");
                  _loc4_ = context.translate("survival_quit_battle_body");
               }
            }
            else
            {
               _loc5_ = context.translate("survival_quit_game_title");
               _loc4_ = context.translate("survival_quit_game_body");
            }
         }
         else
         {
            _loc5_ = context.translate("quit_game_title");
            _loc4_ = context.translate("quit_game_body_saga");
         }
         _loc4_ = _loc2_.performStringReplacement_SagaVar(_loc4_);
         var _loc6_:String = context.translate("yes");
         var _loc7_:String = context.translate("no");
         _loc3_.openTwoBtnDialog(_loc5_,_loc4_,_loc6_,_loc7_,this.onDialogChoiceSelected);
      }
      
      private function onNewsClicked(param1:*) : void
      {
         this.listener.guiOptionsNews();
      }
      
      private function onLoadClicked(param1:*) : void
      {
         this.listener.guiOptionsSaveLoad();
      }
      
      private function onDifficultyClicked(param1:*) : void
      {
         this.listener.guiOptionsDifficulty();
      }
      
      private function onAudioClicked(param1:*) : void
      {
         this.listener.guiOptionsAudio();
      }
      
      private function onLanguageClicked(param1:*) : void
      {
         this.listener.guiOptionsLang();
      }
      
      private function onGpConfigClicked(param1:*) : void
      {
         this.listener.guiOptionsGp();
      }
      
      private function onTrainingExitClicked(param1:*) : void
      {
         this.listener.guiOptionsTrainingExit();
      }
      
      private function onTutorialExitClicked(param1:*) : void
      {
         this.listener.guiOptionsTutorialExit();
      }
      
      private function onSurvivalReloadClicked(param1:*) : void
      {
         this.listener.guiOptionsSurvivalReload();
      }
      
      private function onTrainingObjectivesClicked(param1:*) : void
      {
         this.listener.guiOptionsBattleObjectives();
      }
      
      private function onFullscreenClicked(param1:ButtonWithIndex) : void
      {
         var _loc2_:Boolean = Boolean(context.getPref(GuiGamePrefs.PREF_OPTION_FULLSCREEN));
         context.setPref(GuiGamePrefs.PREF_OPTION_FULLSCREEN,!_loc2_);
         this.listener.guiOptionsToggleFullcreen();
      }
      
      private function onResumeClicked(param1:Object) : void
      {
         this.closeOptions();
      }
      
      public function closeOptions() : void
      {
         this.listener.guiOptionsHideLayers();
      }
      
      private function creditsHandler(param1:Object) : void
      {
         this.listener.guiOptionsCredits();
      }
      
      private function onGaOptStateClicked(param1:*) : void
      {
         this.listener.guiOptionsGaOptState();
      }
      
      private function googleSignInClickHandler(param1:*) : void
      {
         this._button$google_sign_in.enabled = false;
         this.listener.guiOptionsGooglePlaySignIn();
      }
      
      private function googleSignOutClickHandler(param1:*) : void
      {
         this._button$google_sign_out.enabled = false;
         this.listener.guiOptionsGooglePlaySignOut();
      }
      
      public function set googlePlaySignedIn(param1:Boolean) : void
      {
         this.isGooglePlaySignedIn = param1;
         this._google_play_holder.visible = GuiSagaOptionsConfig.ENABLE_GOOGLE_PLAY;
         this._button$google_sign_in.visible = !param1;
         this._button$google_sign_out.visible = param1;
         this._button$google_sign_in.enabled = this._button$google_sign_in.visible;
         this._button$google_sign_out.enabled = this._button$google_sign_out.visible;
         if(this.nav)
         {
            this.nav.remap();
         }
      }
      
      public function ensureTopGp() : void
      {
         if(this.nav)
         {
            this.nav.reactivate();
         }
      }
      
      public function get googlePlaySignedIn() : Boolean
      {
         return this.isGooglePlaySignedIn;
      }
   }
}
