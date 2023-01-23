package game.gui.page
{
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.KeyBindGroup;
   import engine.core.fsm.State;
   import engine.core.gp.GpControlButton;
   import engine.core.gp.GpDevBinder;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import engine.saga.ISaga;
   import engine.saga.Saga;
   import engine.saga.SagaVar;
   import engine.saga.vars.VariableType;
   import engine.sound.SoundBundleWrapper;
   import flash.ui.Keyboard;
   import flash.utils.Dictionary;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   import game.gui.IGuiContext;
   import game.session.states.AssembleHeroesState;
   
   public class AssembleHeroesPage extends GamePage implements IGuiProvingGroundsListener
   {
      
      public static var mcClazz:Class;
       
      
      private var gui:IGuiProvingGrounds;
      
      private var abilityPopup:IGuiPgAbilityPopup;
      
      private var cmd_ready:Cmd;
      
      private var cmd_random:Cmd;
      
      private var cache:HeroesPageCache;
      
      private var sbw:SoundBundleWrapper;
      
      public function AssembleHeroesPage(param1:GameConfig)
      {
         this.cmd_ready = new Cmd("cmd_ready_assemble",this.cmdReadyFunc);
         this.cmd_random = new Cmd("cmd_random_assemble",this.cmdRandomFunc);
         super(param1);
         this.cache = new HeroesPageCache(this);
         this._loadAmbienceSound();
      }
      
      public static function generateIgnoramus() : Dictionary
      {
         var _loc1_:Dictionary = new Dictionary();
         var _loc2_:Saga = Saga.instance;
         if(Boolean(_loc2_) && _loc2_.isSurvival)
         {
            _loc1_["common__gui__pages__pg_backdrop"] = true;
            _loc1_["common__gui__pages__roster_team_banner"] = true;
            _loc1_["common__gui__pages__pg_top_banner"] = true;
            _loc1_["common__gui__pages__pg_foreground_doodads"] = true;
         }
         else
         {
            _loc1_["common__gui__saga2_survival__heroes__background_right"] = true;
            _loc1_["common__gui__saga2_survival__heroes__background_left"] = true;
            _loc1_["common__gui__saga2_survival__heroes__party_background_right"] = true;
            _loc1_["common__gui__saga2_survival__heroes__party_background_left"] = true;
            _loc1_["common__gui__saga2_survival__heroes__top_banner_left"] = true;
            _loc1_["common__gui__saga2_survival__heroes__top_banner_right"] = true;
            _loc1_["common__gui__saga2_survival__heroes__foreground_left"] = true;
            _loc1_["common__gui__saga2_survival__heroes__foreground_right"] = true;
         }
         return _loc1_;
      }
      
      public static function checkTipAssembleOrder(param1:GameConfig) : void
      {
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc2_:Saga = param1.saga;
         var _loc3_:IEntityListDef = param1.legend.roster;
         var _loc4_:IGuiContext = param1.gameGuiContext;
         if(!_loc2_ || !_loc3_ || !_loc4_)
         {
            return;
         }
         if(_loc2_.isSurvival)
         {
            return;
         }
         var _loc5_:String = SagaVar.VAR_TIP_ASSEMBLE_ORDER;
         var _loc6_:Boolean = Boolean(_loc2_) && _loc2_.getVar(_loc5_,VariableType.BOOLEAN).asBoolean;
         if(!_loc6_)
         {
            _loc7_ = param1.gameGuiContext.translate(_loc5_ + "_title");
            _loc8_ = param1.gameGuiContext.translate(_loc5_ + "_body");
            _loc4_.showGameTip(_loc5_,_loc7_,_loc8_);
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
         var _loc1_:Dictionary = generateIgnoramus();
         setFullPageMovieClipClass(mcClazz,_loc1_);
         if(!config.legend)
         {
            logger.error("Got into AssembleHeroesPage with no caravan or legend");
            return;
         }
         this.cache.init();
         config.keybinder.bind(false,false,false,Keyboard.ENTER,this.cmd_ready,KeyBindGroup.TOWN);
         config.keybinder.bind(false,false,false,Keyboard.SPACE,this.cmd_ready,KeyBindGroup.TOWN);
         config.keybinder.bind(true,false,true,Keyboard.RIGHTBRACKET,this.cmd_ready,KeyBindGroup.TOWN);
         config.keybinder.bind(false,true,true,Keyboard.PERIOD,this.cmd_random,KeyBindGroup.TOWN);
         config.keybinder.bind(true,false,true,Keyboard.PERIOD,this.cmd_random,KeyBindGroup.TOWN);
         GpDevBinder.instance.bind(null,GpControlButton.A,1,this.cmdReadyFunc,[null]);
      }
      
      override public function cleanup() : void
      {
         if(this.sbw)
         {
            this.sbw.stopSound();
            this.sbw.cleanup();
         }
         GpDevBinder.instance.unbind(this.cmdReadyFunc);
         config.keybinder.unbind(this.cmd_ready);
         config.keybinder.unbind(this.cmd_random);
         this.cmd_ready.cleanup();
         this.cmd_random.cleanup();
         if(this.cache)
         {
            this.cache.cleanup();
            this.cache = null;
         }
         super.cleanup();
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
      }
      
      override protected function handleLoaded() : void
      {
         var _loc1_:AssembleHeroesState = null;
         var _loc2_:Saga = null;
         var _loc3_:GuiProvingGroundsConfig = null;
         if(Boolean(HeroesPage.mcClazzAblPop) && !this.abilityPopup)
         {
            this.abilityPopup = new HeroesPage.mcClazzAblPop() as IGuiPgAbilityPopup;
            loadGuiBitmaps(this.abilityPopup.mc);
         }
         if(fullScreenMc && !this.gui && (!HeroesPage.mcClazzAblPop || this.abilityPopup))
         {
            _loc1_ = config.fsm.current as AssembleHeroesState;
            _loc2_ = config.saga;
            if(!_loc1_)
            {
               logger.error("AssembleHeroesPage.handleLoaded null state");
               return;
            }
            this.gui = fullScreenMc as IGuiProvingGrounds;
            logger.info("AssembleHeroesPage.handleLoaded gui=" + this.gui + " current=" + _loc1_);
            logger.info("AssembleHeroesPage.handleLoaded current.guiConfig=" + _loc1_.guiConfig);
            _loc3_ = _loc1_.guiConfig;
            _loc3_.titleText = "assemble_your_heroes";
            _loc3_.isSaga = true;
            _loc3_.allowExit = false;
            _loc3_.allowRenown = true;
            _loc3_.allowDetails = true;
            _loc3_.roster.allowScrolling = _loc2_.isSurvival;
            _loc3_.roster.allowExpandBarracks = false;
            _loc3_.roster.allowReady = true;
            _loc3_.roster.enableItems = true;
            _loc3_.roster.showPower = false;
            _loc3_.roster.showLimits = false;
            _loc3_.characterStats.bio.showServiceDays = false;
            _loc3_.characterStats.bio.showBattles = false;
            _loc3_.characterStats.bio.showColor = false;
            _loc3_.characterStats.bio.showRename = false;
            _loc3_.characterStats.bio.showDismiss = false;
            this.gui.init(config.gameGuiContext,_loc1_.guiConfig,this,this.abilityPopup);
            if(config.saga)
            {
               config.saga.sound.interruptMusicBattleTransition();
               AssembleHeroesPage.checkTipAssembleOrder(config);
               HeroesPage.checkTipInjury(config);
            }
         }
         this.cache.handleLoaded();
      }
      
      public function guiProvingGroundsExit() : void
      {
         if(config.saga)
         {
            config.saga.triggerAssembleHeroesExit();
         }
      }
      
      public function guiProvingGroundsReady() : void
      {
         if(config.saga)
         {
            config.saga.triggerAssembleHeroesComplete();
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
         if(Boolean(this.gui) && this.gui.canReady)
         {
            this.gui.doReadyButton();
         }
      }
      
      override public function canReusePageForState(param1:State) : Boolean
      {
         return false;
      }
   }
}
