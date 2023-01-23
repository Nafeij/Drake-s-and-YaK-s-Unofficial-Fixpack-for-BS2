package game.gui.page
{
   import com.stoicstudio.platform.Platform;
   import com.stoicstudio.platform.PlatformInput;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.gp.GpControlButton;
   import engine.core.gp.GpSource;
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleCategory;
   import engine.core.render.BoundedCamera;
   import engine.core.util.MovieClipAdapter;
   import engine.entity.model.IEntity;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpAlignH;
   import engine.gui.GuiGpAlignV;
   import engine.gui.GuiGpBitmap;
   import engine.gui.IGuiBattleTooltip;
   import engine.gui.IGuiButton;
   import engine.sound.ISoundDriver;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   import game.cfg.GameConfig;
   import game.gui.battle.IGuiBattleHelp;
   import game.gui.battle.IGuiBattleHud;
   import game.gui.battle.IGuiInitiative;
   import game.gui.page.battle.GuiBattleObjectives;
   import game.session.states.SceneLoadState;
   import game.session.states.SceneState;
   
   public class BattleHudPageLoadHelper
   {
      
      public static var mcClazzBattleTooltip:Class;
      
      public static var mcClazzInitiative:Class;
      
      public static var mcClazzGoBattle:Class;
      
      public static var mcClazzGoWar:Class;
      
      public static var mcClazzPillage:Class;
      
      public static var mcClazzPillage2:Class;
      
      public static var mcClazzForgeAhead:Class;
      
      public static var mcClazzForgeAheadPillage:Class;
      
      public static var mcClazzInsult:Class;
      
      public static var mcClazzRespite:Class;
      
      public static var mcClazzReinforcements:Class;
      
      public static var mcClazzEnemyReinforcements:Class;
      
      public static var mcClazzBattleHud:Class;
      
      public static var mcClazzBattleOptionsButton:Class;
      
      public static var mcClazzBattleHelp:Class;
       
      
      public var _guiBattleTooltip:IGuiBattleTooltip;
      
      private var _guihud:IGuiBattleHud;
      
      private var _battleHelp:IGuiBattleHelp;
      
      private var _initiative:IGuiInitiative;
      
      private var _optionButton:IGuiButton;
      
      private var _iconOption:GuiGpBitmap;
      
      private var _battleObjectives:GuiBattleObjectives;
      
      private var _battleGo:MovieClipAdapter;
      
      private var battlePillage:MovieClipAdapter;
      
      private var battlePillage2:MovieClipAdapter;
      
      private var forgeAhead:MovieClipAdapter;
      
      private var forgeAheadPillage:MovieClipAdapter;
      
      private var insult:MovieClipAdapter;
      
      private var respite:MovieClipAdapter;
      
      private var reinforcements:MovieClipAdapter;
      
      private var enemyReinforcements:MovieClipAdapter;
      
      private var battleHudPage:BattleHudPage;
      
      private var config:GameConfig;
      
      private var initiativeEntities:Vector.<IBattleEntity>;
      
      private var initiativeDeployMode:Boolean;
      
      private var parentPlayPillageOnce:DisplayObjectContainer;
      
      private var parentPlayPillage2Once:DisplayObjectContainer;
      
      private var parentPlayForgeAheadOnce:DisplayObjectContainer;
      
      private var parentPlayForgeAheadPillageOnce:DisplayObjectContainer;
      
      private var parentPlayInsultOnce:DisplayObjectContainer;
      
      private var parentPlayRespiteOnce:DisplayObjectContainer;
      
      private var parentPlayReinforcementsOnce:DisplayObjectContainer;
      
      private var parentPlayEnemyReinforcementsOnce:DisplayObjectContainer;
      
      public var hud_scale:Number = 1;
      
      public function BattleHudPageLoadHelper(param1:BattleHudPage, param2:GameConfig)
      {
         this._iconOption = GuiGp.ctorPrimaryBitmap(GpControlButton.START,true);
         super();
         GpSource.dispatcher.addEventListener(GpSource.EVENT_PRIMARY_DEVICE,this.primaryDeviceHandler);
         this._iconOption.scale = 0.75;
         this.battleHudPage = param1;
         this.config = param2;
         PlatformInput.dispatcher.addEventListener(PlatformInput.EVENT_LAST_INPUT,this.onOperationModeChange);
         this.hudLoadedHandler();
         this.battleHelpHandler();
         this.initiativeCreate();
         this.battleTooltipCreate();
         this.optionButtonLoadedHandler();
         this.battleObjectivesLoadedHandler();
         this.battleGoCreate();
         this.battlePillageCreate();
         this.battlePillage2Create();
         this.forgeAheadCreate();
         this.forgeAheadPillageCreate();
         this.respiteCreate();
         this.reinforcementsCreate();
         this.enemyReinforcementsCreate();
         this.insultCreate();
      }
      
      private function primaryDeviceHandler(param1:Event) : void
      {
         this.resizeHandler(this.battleHudPage.width,this.battleHudPage.height);
      }
      
      public function cleanup() : void
      {
         GpSource.dispatcher.removeEventListener(GpSource.EVENT_PRIMARY_DEVICE,this.primaryDeviceHandler);
         PlatformInput.dispatcher.removeEventListener(PlatformInput.EVENT_LAST_INPUT,this.onOperationModeChange);
         if(this._initiative)
         {
            this._initiative.cleanup();
            this._initiative = null;
         }
         if(this._guiBattleTooltip)
         {
            this._guiBattleTooltip.cleanup();
         }
         GuiGp.releasePrimaryBitmap(this._iconOption);
         if(this._optionButton)
         {
            if(this._optionButton.movieClip.parent)
            {
               this._optionButton.movieClip.parent.removeChild(this._optionButton.movieClip);
            }
            this._optionButton.cleanup();
            this._optionButton = null;
         }
         if(this._battleObjectives)
         {
            this._battleObjectives.cleanup();
            this._battleObjectives = null;
         }
         if(this.battlePillage)
         {
            this.battlePillage.cleanup();
            this.battlePillage = null;
         }
         if(this.battlePillage2)
         {
            this.battlePillage2.cleanup();
            this.battlePillage2 = null;
         }
         if(this.forgeAhead)
         {
            this.forgeAhead.cleanup();
            this.forgeAhead = null;
         }
         if(this.forgeAheadPillage)
         {
            this.forgeAheadPillage.cleanup();
            this.forgeAheadPillage = null;
         }
         if(this.insult)
         {
            this.insult.cleanup();
            this.insult = null;
         }
         if(this.respite)
         {
            this.respite.cleanup();
            this.respite = null;
         }
         if(this.enemyReinforcements)
         {
            this.enemyReinforcements.cleanup();
            this.enemyReinforcements = null;
         }
         if(this.reinforcements)
         {
            this.reinforcements.cleanup();
            this.reinforcements = null;
         }
         this.removeElement(this.guihud as DisplayObject);
         this.battleHudPage = null;
         this.config = null;
      }
      
      public function suppressInitiativeForWaveRedeploy(param1:Boolean) : void
      {
         this._initiative.suppressVisible = param1;
      }
      
      public function handleLocaleChange() : void
      {
         if(this._battleHelp)
         {
            this._battleHelp.handleLocaleChange();
         }
      }
      
      private function removeElement(param1:DisplayObject) : void
      {
         if(param1)
         {
            if(param1.parent)
            {
               param1.parent.removeChild(param1);
            }
            if("cleanup" in param1)
            {
               param1["cleanup"]();
            }
         }
      }
      
      public function get battleHelp() : IGuiBattleHelp
      {
         return this._battleHelp;
      }
      
      public function get guihud() : IGuiBattleHud
      {
         return this._guihud;
      }
      
      public function set guihud(param1:IGuiBattleHud) : void
      {
         this._guihud = param1;
      }
      
      public function set battleGo(param1:MovieClipAdapter) : void
      {
         if(this._battleGo == param1)
         {
            return;
         }
         if(this._battleGo)
         {
            if(this._battleGo.mc.parent)
            {
               this._battleGo.mc.parent.removeChild(this._battleGo.mc);
            }
            this._battleGo.cleanup();
         }
         this._battleGo = param1;
      }
      
      public function get battleGo() : MovieClipAdapter
      {
         return this._battleGo;
      }
      
      private function battleGoCreate() : void
      {
         var _loc1_:Boolean = false;
         var _loc2_:SceneState = null;
         var _loc3_:Class = null;
         var _loc4_:SceneLoadState = null;
         var _loc5_:MovieClip = null;
         if(!this._battleGo)
         {
            _loc1_ = false;
            _loc2_ = this.config.fsm.current as SceneState;
            _loc1_ = Boolean(_loc2_) && Boolean(_loc2_.battle_info) && _loc2_.battle_info.war;
            if(!_loc2_)
            {
               _loc4_ = this.config.fsm.current as SceneLoadState;
               _loc1_ = _loc4_ && _loc4_.sceneLoader && Boolean(_loc4_.sceneLoader.battle_info) && _loc4_.sceneLoader.battle_info.war;
            }
            _loc3_ = _loc1_ ? mcClazzGoWar : mcClazzGoBattle;
            if(_loc3_)
            {
               _loc5_ = new _loc3_() as MovieClip;
               this.config.gameGuiContext.translateDisplayObjects(LocaleCategory.GUI,_loc5_);
               this._battleGo = new MovieClipAdapter(_loc5_,30,null,false,this.config.logger,null,this.battleGoCompleteHandler);
               this.battleGo.stop();
            }
         }
      }
      
      private function battleGoCompleteHandler(param1:MovieClipAdapter) : void
      {
         this.battleGo = null;
      }
      
      public function playPillageOnce(param1:DisplayObjectContainer) : void
      {
         this.parentPlayPillageOnce = param1;
         this.checkPlayPillage();
      }
      
      public function playPillage2Once(param1:DisplayObjectContainer) : void
      {
         this.parentPlayPillage2Once = param1;
         this.checkPlayPillage2();
      }
      
      public function playForgeAheadOnce(param1:DisplayObjectContainer) : void
      {
         this.parentPlayForgeAheadOnce = param1;
         this.checkForgeAhead();
      }
      
      public function playInsultOnce(param1:DisplayObjectContainer, param2:IBattleEntity) : void
      {
         this.parentPlayInsultOnce = param1;
         this.checkInsult(param2);
      }
      
      public function playForgeAheadPillageOnce(param1:DisplayObjectContainer) : void
      {
         this.parentPlayForgeAheadPillageOnce = param1;
         this.checkForgeAheadPillage();
      }
      
      public function playRespiteOnce(param1:DisplayObjectContainer) : void
      {
         this.parentPlayRespiteOnce = param1;
         this.checkPlayRespite();
      }
      
      public function playReinforcementsOnce(param1:DisplayObjectContainer) : void
      {
         this.parentPlayReinforcementsOnce = param1;
         this.checkPlayReinforcements();
      }
      
      public function playEnemyReinforcementsOnce(param1:DisplayObjectContainer) : void
      {
         this.parentPlayEnemyReinforcementsOnce = param1;
         this.checkPlayEnemyReinforcements();
      }
      
      public function checkPlayRespite() : void
      {
         if(Boolean(this.respite) && Boolean(this.parentPlayRespiteOnce))
         {
            this.parentPlayRespiteOnce.addChild(this.respite.mc);
            this.respite.mc.x = this.parentPlayRespiteOnce.width / 2;
            this.respite.mc.y = this.parentPlayRespiteOnce.height / 2;
            this.respite.visible = true;
            this.parentPlayRespiteOnce = null;
            this.respite.playOnce();
            this.config.gameGuiContext.translateDisplayObjects(LocaleCategory.GUI,this.respite.mc);
         }
      }
      
      public function checkPlayReinforcements() : void
      {
         if(Boolean(this.reinforcements) && Boolean(this.parentPlayReinforcementsOnce))
         {
            this.parentPlayReinforcementsOnce.addChild(this.reinforcements.mc);
            this.reinforcements.mc.x = this.parentPlayReinforcementsOnce.width / 2;
            this.reinforcements.mc.y = this.parentPlayReinforcementsOnce.height / 2;
            this.reinforcements.visible = true;
            this.parentPlayReinforcementsOnce = null;
            this.reinforcements.playOnce();
            this.config.gameGuiContext.translateDisplayObjects(LocaleCategory.GUI,this.reinforcements.mc);
         }
      }
      
      public function checkPlayEnemyReinforcements() : void
      {
         if(Boolean(this.enemyReinforcements) && Boolean(this.parentPlayEnemyReinforcementsOnce))
         {
            this.parentPlayEnemyReinforcementsOnce.addChild(this.enemyReinforcements.mc);
            this.enemyReinforcements.mc.x = this.parentPlayEnemyReinforcementsOnce.width / 2;
            this.enemyReinforcements.mc.y = this.parentPlayEnemyReinforcementsOnce.height / 2;
            this.enemyReinforcements.visible = true;
            this.parentPlayEnemyReinforcementsOnce = null;
            this.enemyReinforcements.playOnce();
            this.config.gameGuiContext.translateDisplayObjects(LocaleCategory.GUI,this.enemyReinforcements.mc);
         }
      }
      
      public function checkPlayPillage() : void
      {
         if(Boolean(this.battlePillage) && Boolean(this.parentPlayPillageOnce))
         {
            this.parentPlayPillageOnce.addChild(this.battlePillage.mc);
            this.battlePillage.mc.x = this.parentPlayPillageOnce.width / 2;
            this.battlePillage.mc.y = this.parentPlayPillageOnce.height / 2;
            this.parentPlayPillageOnce = null;
            this.config.gameGuiContext.translateDisplayObjects(LocaleCategory.GUI,this.battlePillage.mc);
            this.battlePillage.playOnce();
         }
      }
      
      public function checkPlayPillage2() : void
      {
         if(Boolean(this.battlePillage2) && Boolean(this.parentPlayPillage2Once))
         {
            this.parentPlayPillage2Once.addChild(this.battlePillage2.mc);
            this.battlePillage2.mc.x = 0;
            this.battlePillage2.mc.y = this.parentPlayPillage2Once.height;
            this.config.gameGuiContext.translateDisplayObjects(LocaleCategory.GUI,this.battlePillage2.mc);
            this.parentPlayPillage2Once = null;
            this.battlePillage2.playOnce();
         }
      }
      
      public function checkForgeAhead() : void
      {
         if(Boolean(this.forgeAhead) && Boolean(this.parentPlayForgeAheadOnce))
         {
            this.parentPlayForgeAheadOnce.addChild(this.forgeAhead.mc);
            this.forgeAhead.mc.x = 0;
            this.forgeAhead.mc.y = this.parentPlayForgeAheadOnce.height;
            this.config.gameGuiContext.translateDisplayObjects(LocaleCategory.GUI,this.forgeAhead.mc);
            this.parentPlayForgeAheadOnce = null;
            this.forgeAhead.playOnce();
         }
      }
      
      public function checkForgeAheadPillage() : void
      {
         if(Boolean(this.forgeAheadPillage) && Boolean(this.parentPlayForgeAheadPillageOnce))
         {
            this.parentPlayForgeAheadPillageOnce.addChild(this.forgeAheadPillage.mc);
            this.forgeAheadPillage.mc.x = 0;
            this.forgeAheadPillage.mc.y = this.parentPlayForgeAheadPillageOnce.height;
            this.config.gameGuiContext.translateDisplayObjects(LocaleCategory.GUI,this.forgeAheadPillage.mc);
            this.parentPlayForgeAheadPillageOnce = null;
            this.forgeAheadPillage.playOnce();
         }
      }
      
      public function checkInsult(param1:IBattleEntity) : void
      {
         var _loc2_:Point = null;
         if(this.insult && this.parentPlayInsultOnce && Boolean(param1))
         {
            this.parentPlayInsultOnce.addChild(this.insult.mc);
            if(this.initiative)
            {
               _loc2_ = this.initiative.getPositionForEntity(param1);
               if(_loc2_)
               {
                  _loc2_ = this.parentPlayInsultOnce.globalToLocal(_loc2_);
               }
            }
            if(_loc2_)
            {
               this.insult.mc.x = _loc2_.x - 80;
               this.insult.mc.y = _loc2_.y - 110;
            }
            this.config.gameGuiContext.translateDisplayObjects(LocaleCategory.GUI,this.insult.mc);
            this.parentPlayInsultOnce = null;
            this.insult.playOnce();
         }
      }
      
      private function respiteCompleteHandler(param1:MovieClipAdapter) : void
      {
         if(this.respite)
         {
            this.respite.stop();
            this.respite.visible = false;
         }
      }
      
      private function reinforcementsCompleteHandler(param1:MovieClipAdapter) : void
      {
         if(this.reinforcements)
         {
            this.reinforcements.stop();
            this.reinforcements.visible = false;
         }
      }
      
      private function enemyReinforcementsCompleteHandler(param1:MovieClipAdapter) : void
      {
         if(this.enemyReinforcements)
         {
            this.enemyReinforcements.stop();
            this.enemyReinforcements.visible = false;
         }
      }
      
      private function battlePillageCompleteHandler(param1:MovieClipAdapter) : void
      {
         if(this.battlePillage)
         {
            this.battlePillage.cleanup();
            this.battlePillage = null;
         }
      }
      
      private function battlePillage2CompleteHandler(param1:MovieClipAdapter) : void
      {
         if(this.battlePillage2)
         {
            this.battlePillage2.cleanup();
            this.battlePillage2 = null;
         }
      }
      
      private function forgeAheadCompleteHandler(param1:MovieClipAdapter) : void
      {
         if(this.forgeAhead)
         {
            this.forgeAhead.stop();
         }
      }
      
      private function forgeAheadPillageCompleteHandler(param1:MovieClipAdapter) : void
      {
         if(this.forgeAheadPillage)
         {
            this.forgeAheadPillage.stop();
         }
      }
      
      private function insultCompleteHandler(param1:MovieClipAdapter) : void
      {
         if(this.insult)
         {
            this.insult.stop();
         }
      }
      
      private function battlePillageCreate() : void
      {
         var _loc1_:MovieClip = null;
         if(Boolean(mcClazzPillage) && !this.battlePillage)
         {
            _loc1_ = new mcClazzPillage() as MovieClip;
            this.battlePillage = new MovieClipAdapter(_loc1_,30,null,false,this.config.logger,null,this.battlePillageCompleteHandler);
            this.battlePillage.stop();
            this.checkPlayPillage();
         }
      }
      
      private function battlePillage2Create() : void
      {
         var _loc1_:MovieClip = null;
         if(Boolean(mcClazzPillage2) && !this.battlePillage2)
         {
            _loc1_ = new mcClazzPillage2() as MovieClip;
            this.battlePillage2 = new MovieClipAdapter(_loc1_,30,null,false,this.config.logger,null,this.battlePillage2CompleteHandler);
            this.battlePillage2.stop();
            this.checkPlayPillage2();
         }
      }
      
      private function forgeAheadCreate() : void
      {
         var _loc1_:MovieClip = null;
         if(Boolean(mcClazzForgeAhead) && !this.forgeAhead)
         {
            _loc1_ = new mcClazzForgeAhead() as MovieClip;
            this.forgeAhead = new MovieClipAdapter(_loc1_,30,null,false,this.config.logger,null,this.forgeAheadCompleteHandler);
            this.forgeAhead.stop();
            this.checkForgeAhead();
         }
      }
      
      private function forgeAheadPillageCreate() : void
      {
         var _loc1_:MovieClip = null;
         if(Boolean(mcClazzForgeAheadPillage) && !this.forgeAheadPillage)
         {
            _loc1_ = new mcClazzForgeAheadPillage() as MovieClip;
            this.forgeAheadPillage = new MovieClipAdapter(_loc1_,30,null,false,this.config.logger,null,this.forgeAheadPillageCompleteHandler);
            this.forgeAheadPillage.stop();
            this.checkForgeAheadPillage();
         }
      }
      
      private function insultCreate() : void
      {
         var _loc1_:MovieClip = null;
         if(Boolean(mcClazzInsult) && !this.insult)
         {
            _loc1_ = new mcClazzInsult() as MovieClip;
            this.insult = new MovieClipAdapter(_loc1_,30,null,false,this.config.logger,null,this.insultCompleteHandler);
            this.insult.stop();
         }
      }
      
      private function respiteCreate() : void
      {
         var _loc1_:MovieClip = null;
         if(Boolean(mcClazzRespite) && !this.respite)
         {
            _loc1_ = new mcClazzRespite() as MovieClip;
            this.respite = new MovieClipAdapter(_loc1_,30,null,false,this.config.logger,null,this.respiteCompleteHandler);
            this.respite.stop();
            this.checkPlayRespite();
         }
      }
      
      private function reinforcementsCreate() : void
      {
         var _loc1_:MovieClip = null;
         if(Boolean(mcClazzReinforcements) && !this.reinforcements)
         {
            _loc1_ = new mcClazzReinforcements() as MovieClip;
            this.reinforcements = new MovieClipAdapter(_loc1_,30,null,false,this.config.logger,null,this.reinforcementsCompleteHandler);
            this.reinforcements.stop();
            this.checkPlayReinforcements();
         }
      }
      
      private function enemyReinforcementsCreate() : void
      {
         var _loc1_:MovieClip = null;
         if(Boolean(mcClazzEnemyReinforcements) && !this.enemyReinforcements)
         {
            _loc1_ = new mcClazzEnemyReinforcements() as MovieClip;
            this.enemyReinforcements = new MovieClipAdapter(_loc1_,30,null,false,this.config.logger,null,this.enemyReinforcementsCompleteHandler);
            this.enemyReinforcements.stop();
            this.checkPlayEnemyReinforcements();
         }
      }
      
      private function optionButtonLoadedHandler() : void
      {
         var _loc1_:MovieClip = new mcClazzBattleOptionsButton() as MovieClip;
         _loc1_.name = "assets.battle_options_button";
         this._optionButton = _loc1_ as IGuiButton;
         this._optionButton.guiButtonContext = this.config.gameGuiContext;
         var _loc2_:Number = BoundedCamera.computeDpiScaling(this.battleHudPage.width,this.battleHudPage.height);
         _loc1_.scaleX = _loc1_.scaleY = _loc2_;
         this.battleHudPage.addChild(_loc1_);
         this._optionButton.setDownFunction(this.optionButtonHandler);
         this._optionButton.visible = PlatformInput.hasClicker;
         this._iconOption.visible = PlatformInput.hasClicker;
         this.battleHudPage.addChild(this._iconOption);
      }
      
      private function battleObjectivesLoadedHandler() : void
      {
         this._battleObjectives = new GuiBattleObjectives(this.config.gameGuiContext);
         this.battleHudPage.addChild(this._battleObjectives);
         this._battleObjectives.x = 20;
         this._battleObjectives.y = 100;
      }
      
      private function optionButtonHandler(param1:IGuiButton) : void
      {
         this.config.pageManager.showOptions();
      }
      
      private function battleTooltipCreate() : void
      {
         if(Boolean(mcClazzBattleTooltip) && !this._guiBattleTooltip)
         {
            this._guiBattleTooltip = new mcClazzBattleTooltip() as IGuiBattleTooltip;
            this.battleHudPage.addChild(this._guiBattleTooltip.movieClip);
            this._guiBattleTooltip.init(this.config.gameGuiContext);
            this.config.context.locale.translateDisplayObjects(LocaleCategory.GUI,this._guiBattleTooltip as MovieClip,this.config.logger);
         }
      }
      
      private function battleHelpHandler() : void
      {
         var _loc1_:MovieClip = new mcClazzBattleHelp() as MovieClip;
         this._battleHelp = _loc1_ as IGuiBattleHelp;
         this._battleHelp.init(this.config.gameGuiContext);
      }
      
      private function hudLoadedHandler() : void
      {
         var _loc1_:MovieClip = new mcClazzBattleHud() as MovieClip;
         _loc1_.name = "assets.battle_hud";
         this._guihud = _loc1_ as IGuiBattleHud;
         this.battleHudPage.addChild(this._guihud.movieClip);
         this._guihud.movieClip.cacheAsBitmap = true;
         var _loc2_:IBattleBoard = this.battleHudPage.board;
         var _loc3_:Boolean = Boolean(_loc2_) && Boolean(_loc2_.waves);
         var _loc4_:ISoundDriver = this.config.soundSystem.driver;
         this._guihud.init(this.config.gameGuiContext,this.battleHudPage,this.battleHudPage,_loc4_,_loc3_);
         this._guihud.initiative = this.initiative;
      }
      
      private function initiativeCreate() : void
      {
         var _loc1_:Vector.<IEntity> = null;
         var _loc2_:IBattleBoard = null;
         var _loc3_:Locale = null;
         var _loc4_:IEntity = null;
         if(Boolean(mcClazzInitiative) && !this._initiative)
         {
            this._initiative = new mcClazzInitiative() as IGuiInitiative;
            if(this._guihud)
            {
               this._guihud.initiative = this.initiative;
            }
            _loc1_ = new Vector.<IEntity>();
            _loc2_ = this.battleHudPage.board;
            if(_loc2_)
            {
               for each(_loc4_ in _loc2_.entities)
               {
                  _loc1_.push(_loc4_);
               }
            }
            this._initiative.init(this.config.gameGuiContext,this.battleHudPage,_loc1_);
            _loc3_ = this.config.context.locale;
            _loc3_.translateDisplayObjects(LocaleCategory.GUI,this._initiative as MovieClip,this.config.logger);
            this._initiative.updateDisplayLists();
            this.checkInitiativeEntities(null);
         }
         else
         {
            this.config.logger.error("BattleHudPageLoadHelper FAILED to initiativeCreate");
         }
      }
      
      public function setInitiativeEntities(param1:Vector.<IBattleEntity>, param2:Boolean, param3:IBattleEntity) : void
      {
         this.initiativeEntities = param1;
         this.initiativeDeployMode = param2;
         this.checkInitiativeEntities(param3);
      }
      
      private function checkInitiativeEntities(param1:IBattleEntity) : void
      {
         if(this._initiative)
         {
            this._initiative.setInitiativeEntities(this.initiativeEntities,this.initiativeDeployMode,param1);
         }
      }
      
      public function get optionButton() : IGuiButton
      {
         return this._optionButton;
      }
      
      public function get initiative() : IGuiInitiative
      {
         return this._initiative;
      }
      
      public function resizeHandler(param1:Number, param2:Number) : void
      {
         this.hud_scale = Platform.textScale;
         this.hud_scale = Math.min(2,this.hud_scale);
         if(this._optionButton)
         {
            this._optionButton.movieClip.scaleX = this._optionButton.movieClip.scaleY = this.hud_scale;
            if(Platform.requiresUiSafeZoneBuffer)
            {
               this._optionButton.movieClip.x = 50;
               this._optionButton.movieClip.y = 25;
            }
         }
         if(this._battleObjectives)
         {
            this._battleObjectives.scaleX = this._battleObjectives.scaleY = this.hud_scale;
         }
         if(this.guihud)
         {
            this.guihud.setSize(param1,param2);
         }
         if(this.initiative)
         {
            this.initiative.resizehandler(param1,param2);
         }
         if(Boolean(this._optionButton) && Boolean(this._iconOption))
         {
            GuiGp.placeIcon(this._optionButton as MovieClip,null,this._iconOption,GuiGpAlignH.E,GuiGpAlignV.C,5,0);
         }
      }
      
      public function handleBoardChange() : void
      {
         if(this._battleObjectives)
         {
            this._battleObjectives.board = this.battleHudPage.board;
         }
      }
      
      public function handleOptionsButton() : void
      {
         if(this._iconOption)
         {
            this._iconOption.pulse();
         }
      }
      
      public function handleOptionsShowing(param1:Boolean) : void
      {
         if(this._initiative)
         {
            this._initiative.handleOptionsShowing(param1);
         }
      }
      
      public function update(param1:int) : void
      {
         if(this._initiative)
         {
            this._initiative.update(param1);
         }
      }
      
      private function onOperationModeChange(param1:Event) : void
      {
         var _loc2_:Boolean = PlatformInput.hasClicker || !PlatformInput.lastInputGp;
         this._optionButton.visible = _loc2_;
         this._iconOption.visible = _loc2_;
      }
   }
}
