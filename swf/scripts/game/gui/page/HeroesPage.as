package game.gui.page
{
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.KeyBindGroup;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import engine.entity.def.Legend;
   import engine.saga.ISaga;
   import engine.saga.Saga;
   import engine.saga.SagaVar;
   import engine.saga.vars.VariableType;
   import engine.scene.model.SceneLoader;
   import engine.sound.SoundBundleWrapper;
   import flash.errors.IllegalOperationError;
   import flash.ui.Keyboard;
   import flash.utils.Dictionary;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   import game.gui.IGuiContext;
   import game.session.states.GameStateDataEnum;
   import game.session.states.HeroesState;
   import game.session.states.SceneState;
   
   public class HeroesPage extends GamePage implements IGuiProvingGroundsListener
   {
      
      public static var mcClazz:Class;
      
      public static var mcClazzAblPop:Class;
       
      
      private var gui:IGuiProvingGrounds;
      
      private var abilityPopup:IGuiPgAbilityPopup;
      
      private var cache:HeroesPageCache;
      
      private var cmd_back:Cmd;
      
      private var cmd_random:Cmd;
      
      private var sbw:SoundBundleWrapper;
      
      private var guiConfig:GuiProvingGroundsConfig;
      
      public function HeroesPage(param1:GameConfig)
      {
         this.cmd_back = new Cmd("cmd_back_heroes",this.func_cmd_back);
         this.cmd_random = new Cmd("cmd_random_assemble",this.cmdRandomFunc);
         super(param1);
         this.cache = new HeroesPageCache(this);
         this._loadAmbienceSound();
      }
      
      public static function checkTipInjury(param1:GameConfig) : void
      {
         var _loc7_:int = 0;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc2_:Saga = param1.saga;
         var _loc3_:IEntityListDef = param1.legend.roster;
         var _loc4_:IGuiContext = param1.gameGuiContext;
         if(!_loc2_ || !_loc3_ || !_loc4_)
         {
            return;
         }
         var _loc5_:String = SagaVar.VAR_TIP_ROSTER_INJURED;
         if(_loc2_.def.survival)
         {
            _loc5_ = SagaVar.VAR_TIP_ROSTER_SURVIVAL_DEAD;
         }
         var _loc6_:Boolean = Boolean(_loc2_) && _loc2_.getVar(_loc5_,VariableType.BOOLEAN).asBoolean;
         if(!_loc6_)
         {
            _loc7_ = _loc3_.numInjuredCombatants;
            if(_loc7_)
            {
               _loc8_ = param1.gameGuiContext.translate(_loc5_ + "_title");
               _loc9_ = param1.gameGuiContext.translate(_loc5_ + "_body");
               _loc4_.showGameTip(_loc5_,_loc8_,_loc9_);
            }
         }
      }
      
      public static function checkTipItems(param1:GameConfig) : void
      {
         var _loc7_:int = 0;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc2_:Saga = param1.saga;
         var _loc3_:Legend = param1.legend;
         var _loc4_:IGuiContext = param1.gameGuiContext;
         if(!_loc2_ || !_loc3_ || !_loc4_)
         {
            return;
         }
         var _loc5_:String = SagaVar.VAR_TIP_ROSTER_ITEMS;
         var _loc6_:Boolean = Boolean(_loc2_) && _loc2_.getVar(_loc5_,VariableType.BOOLEAN).asBoolean;
         if(!_loc6_)
         {
            _loc7_ = param1.legend.getAllNumItems(null);
            if(_loc7_)
            {
               _loc8_ = param1.gameGuiContext.translate(_loc5_ + "_title");
               _loc9_ = param1.gameGuiContext.translate(_loc5_ + "_body");
               _loc4_.showGameTip(_loc5_,_loc8_,_loc9_);
            }
         }
      }
      
      private function _loadAmbienceSound() : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:String = null;
         var _loc1_:ISaga = config.saga;
         if(_loc1_)
         {
            _loc2_ = Boolean(_loc1_.getVarBool(SagaVar.GUI_HEROES_AMBIENCE_DISABLED));
            if(!_loc2_)
            {
               _loc3_ = config.saga.getVarString(SagaVar.GUI_HEROES_AMBIENCE_EVENT);
               if(_loc3_)
               {
                  this.sbw = new SoundBundleWrapper("heroes",_loc3_,config.soundSystem.driver,true,true);
               }
            }
         }
      }
      
      private function func_cmd_back(param1:CmdExec) : void
      {
         if(this.gui)
         {
            this.gui.back();
         }
         else
         {
            this.guiProvingGroundsExit();
         }
      }
      
      override public function update(param1:int) : void
      {
         super.update(param1);
         if(this.gui)
         {
            this.gui.update(param1);
         }
      }
      
      override protected function handleStart() : void
      {
         var _loc1_:Dictionary = AssembleHeroesPage.generateIgnoramus();
         setFullPageMovieClipClass(mcClazz,_loc1_);
         this.cache.init();
         GpBinder.gpbinder.bindPress(GpControlButton.B,this.cmd_back);
         config.keybinder.bind(false,false,false,Keyboard.BACK,this.cmd_back,KeyBindGroup.TOWN);
         config.keybinder.bind(false,true,true,Keyboard.PERIOD,this.cmd_random,KeyBindGroup.TOWN);
         config.keybinder.bind(true,false,true,Keyboard.PERIOD,this.cmd_random,KeyBindGroup.TOWN);
      }
      
      override public function cleanup() : void
      {
         if(this.sbw)
         {
            this.sbw.stopSound();
            this.sbw.cleanup();
         }
         config.keybinder.unbind(this.cmd_back);
         GpBinder.gpbinder.unbind(this.cmd_back);
         config.keybinder.unbind(this.cmd_random);
         this.cmd_back.cleanup();
         this.cmd_random.cleanup();
         config.tutorialLayer.removeAllTooltips();
         if(this.cache)
         {
            this.cache.cleanup();
            this.cache = null;
         }
         if(this.gui)
         {
            this.gui.cleanup();
            this.gui = null;
         }
         if(this.abilityPopup)
         {
            this.abilityPopup.cleanup();
            this.abilityPopup = null;
         }
         super.cleanup();
      }
      
      override protected function handleLoaded() : void
      {
         var _loc2_:Saga = null;
         var _loc1_:HeroesState = config.fsm.current as HeroesState;
         if(!_loc1_)
         {
            return;
         }
         if(Boolean(mcClazzAblPop) && !this.abilityPopup)
         {
            this.abilityPopup = new mcClazzAblPop() as IGuiPgAbilityPopup;
            loadGuiBitmaps(this.abilityPopup.mc);
         }
         if(fullScreenMc && !this.gui && (!mcClazzAblPop || this.abilityPopup))
         {
            _loc2_ = config.saga;
            this.gui = fullScreenMc as IGuiProvingGrounds;
            this.guiConfig = _loc1_.guiConfig;
            this.guiConfig.titleText = "heroes";
            this.guiConfig.enableRenown = false;
            this.guiConfig.isSaga = true;
            this.guiConfig.roster.allowScrolling = false;
            this.guiConfig.roster.croppedRows = true;
            this.guiConfig.roster.allowExpandBarracks = false;
            this.guiConfig.characterStats.bio.showColor = false;
            this.guiConfig.characterStats.bio.showRename = false;
            this.guiConfig.characterStats.bio.showDismiss = false;
            this.guiConfig.roster.enableItems = true;
            this.guiConfig.roster.showPower = false;
            this.guiConfig.roster.showLimits = false;
            this.guiConfig.roster.shownTutorialDetails = !_loc2_ || _loc2_.getVar(SagaVar.VAR_TUT_HEROES_DETAILS,VariableType.BOOLEAN).asBoolean;
            this.guiConfig.roster.showTutorialDetails = !this.guiConfig.roster.shownTutorialDetails;
            this.guiConfig.characterStats.bio.showServiceDays = false;
            this.guiConfig.characterStats.bio.showBattles = false;
            config.tutorialLayer.removeAllTooltips();
            if(_loc2_)
            {
               _loc2_.setVar(SagaVar.VAR_TUT_HEROES,true);
            }
            this.gui.init(config.gameGuiContext,_loc1_.guiConfig,this,this.abilityPopup);
            HeroesPage.checkTipInjury(config);
            HeroesPage.checkTipItems(config);
         }
      }
      
      public function guiProvingGroundsReady() : void
      {
         throw new IllegalOperationError("Nope");
      }
      
      public function guiProvingGroundsExit() : void
      {
         var _loc1_:Saga = null;
         var _loc2_:HeroesState = null;
         var _loc3_:SceneLoader = null;
         if(this.guiConfig)
         {
            _loc1_ = config.saga;
            if(_loc1_)
            {
               if(this.guiConfig.roster.shownTutorialDetails)
               {
                  _loc1_.setVar(SagaVar.VAR_TUT_HEROES_DETAILS,true);
               }
            }
         }
         if(config.saga)
         {
            _loc2_ = config.fsm.current as HeroesState;
            if(_loc2_)
            {
               _loc3_ = _loc2_.data.getValue(GameStateDataEnum.SCENE_LOADER);
               if(Boolean(_loc3_) && Boolean(_loc3_.scene))
               {
                  config.fsm.current.data.setValue(GameStateDataEnum.SCENE_AUTOPAN,false);
                  config.fsm.transitionTo(SceneState,_loc2_.data);
               }
               else
               {
                  config.saga.sceneStateRestore();
               }
            }
         }
      }
      
      public function guiProvingGroundsDisplayCharacterDetails(param1:IEntityDef) : void
      {
      }
      
      public function guiProvingGroundsDisplayPromotion(param1:IEntityDef) : void
      {
      }
      
      public function guiProvingGroundsHandlePromotion(param1:IEntityDef) : void
      {
      }
      
      public function guiProvingGroundsCloseQuestionPages() : void
      {
      }
      
      public function guiProvingGroundsQuestionClick() : void
      {
      }
      
      public function guiProvingGroundsNamingAccept() : void
      {
      }
      
      public function guiProvingGroundsNamingMode() : void
      {
      }
      
      public function guiProvingGroundsVariationOpened() : void
      {
      }
      
      public function guiProvingGroundsVariationSelected() : void
      {
      }
      
      private function cmdRandomFunc(param1:CmdExec) : void
      {
         if(this.gui)
         {
            this.gui.doRandomButton();
         }
      }
      
      private function cmdReadyFunc(param1:CmdExec) : void
      {
         this.guiProvingGroundsExit();
      }
   }
}
