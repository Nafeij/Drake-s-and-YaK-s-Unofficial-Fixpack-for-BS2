package game.saga
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityTargetRule;
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.BattleAbilityValidation;
   import engine.battle.ability.model.IBattleAbilityManager;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.BattleBoardTiles;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.entity.model.BattleEntity;
   import engine.battle.fsm.BattleFinishedData;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleMove;
   import engine.battle.fsm.state.BattleStateDeploy;
   import engine.battle.sim.IBattleParty;
   import engine.core.TutorialTooltipAlign;
   import engine.core.TutorialTooltipAnchor;
   import engine.core.analytic.SteamDataSuite;
   import engine.core.fsm.Fsm;
   import engine.core.fsm.State;
   import engine.core.fsm.StateData;
   import engine.core.logging.ILogger;
   import engine.core.render.Screenshot;
   import engine.core.util.Enum;
   import engine.entity.def.IEntityClassDef;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IPartyDef;
   import engine.entity.def.Item;
   import engine.entity.def.ItemDef;
   import engine.gui.page.PageState;
   import engine.landscape.travel.def.TravelLocator;
   import engine.landscape.travel.model.Travel_FallData;
   import engine.landscape.travel.model.Travel_WipeData;
   import engine.math.MathUtil;
   import engine.resource.ResourceManager;
   import engine.saga.Saga;
   import engine.saga.SagaCreditsDef;
   import engine.saga.SagaDef;
   import engine.saga.SagaVar;
   import engine.saga.VideoParams;
   import engine.saga.WarOutcome;
   import engine.saga.convo.Convo;
   import engine.saga.happening.Happening;
   import engine.saga.save.GameSaveSynchronizer;
   import engine.saga.save.SagaSave;
   import engine.saga.save.SaveManager;
   import engine.saga.vars.VariableType;
   import engine.scene.model.Scene;
   import engine.scene.model.SceneAudio;
   import engine.scene.model.SceneLoader;
   import engine.scene.model.SceneLoaderBattleInfo;
   import engine.sound.ISoundDefBundle;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   import engine.tile.Tile;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileRect;
   import flash.errors.IllegalOperationError;
   import flash.events.TimerEvent;
   import flash.utils.ByteArray;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   import game.gui.IGuiDialog;
   import game.gui.page.FlashPage;
   import game.gui.page.ScenePage;
   import game.gui.travel.IGuiTravelTop;
   import game.session.GameFsm;
   import game.session.states.AssembleHeroesState;
   import game.session.states.FlashState;
   import game.session.states.GameStateDataEnum;
   import game.session.states.MapCampLoadState;
   import game.session.states.SagaSelectorState;
   import game.session.states.SagaSurvivalStartState;
   import game.session.states.SagaSurvivalWinState;
   import game.session.states.SceneLoadState;
   import game.session.states.SceneLoaderConfig;
   import game.session.states.SceneState;
   import game.session.states.SceneStateBattleHandler;
   import game.session.states.VideoQueueState;
   import game.view.GamePageManagerAdapter;
   import game.view.TutorialTooltip;
   
   public class GameSaga extends Saga
   {
      
      private static var _scratchSteps:Vector.<TileLocation> = new Vector.<TileLocation>();
       
      
      public var config:GameConfig;
      
      private var saved:SavedSceneState;
      
      public var campSaved:SavedSceneState;
      
      public var timerSave:Timer;
      
      private var lastSaveTime:int = 0;
      
      public var firstTime:Boolean;
      
      private var tooltips:Vector.<TutorialTooltip>;
      
      private var tooltipsScene:Scene;
      
      private var SCREENSHOT_WIDTH:int = 480;
      
      private var SCREENSHOT_HEIGIHT:int = 360;
      
      private var endingCredits:Boolean;
      
      private var _survivalReloading:SagaSave;
      
      public function GameSaga(param1:GameConfig, param2:SagaDef, param3:ResourceManager)
      {
         this.timerSave = new Timer(10000,0);
         this.tooltips = new Vector.<TutorialTooltip>();
         super(param2,param1.soundSystem,param3,param1.logger,param1.abilityFactory,param1.context.appInfo,param1.options.developer,param1.ccs,param1.context.locale,param1.saveManager);
         this.config = param1;
         this.timerSave.addEventListener(TimerEvent.TIMER,this.timerSaveHandler);
         this.handleHudHornEnabled();
         this.getMasterSave();
         if(!getMasterSaveKeyBool("init"))
         {
            setMasterSaveKey("init",true);
            SteamDataSuite.firsttime();
         }
         survivalSetup();
      }
      
      private static function _convertWaypointsToSteps(param1:IBattleEntity, param2:Vector.<TileLocation>, param3:Vector.<TileLocation>) : Vector.<TileLocation>
      {
         var _loc10_:TileLocation = null;
         var _loc13_:TileLocation = null;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         if(!param3)
         {
            param3 = new Vector.<TileLocation>();
         }
         var _loc4_:TileRect = param1.rect;
         var _loc5_:BattleBoard = param1.board as BattleBoard;
         var _loc6_:ILogger = _loc5_.logger;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:TileLocation = _loc4_.loc;
         var _loc11_:BattleBoardTiles = _loc5_.tiles as BattleBoardTiles;
         var _loc12_:TileRect = new TileRect(_loc4_.loc,_loc4_.diameter,_loc4_.diameter);
         for each(_loc13_ in param2)
         {
            _loc7_ = _loc9_.x;
            _loc8_ = _loc9_.y;
            _loc14_ = _loc13_.x - _loc9_.x;
            _loc15_ = _loc13_.y - _loc9_.y;
            if(Boolean(_loc14_) && Boolean(_loc15_))
            {
               throw new ArgumentError("traveling from " + _loc9_ + " to " + _loc13_ + " but is expected to be along an axis");
            }
            _loc16_ = Math.max(Math.abs(_loc14_),Math.abs(_loc15_));
            _loc14_ = Math.max(-1,Math.min(1,_loc14_));
            _loc15_ = Math.max(-1,Math.min(1,_loc15_));
            _loc17_ = 1;
            while(_loc17_ <= _loc16_)
            {
               _loc7_ += _loc14_;
               _loc8_ += _loc15_;
               _loc10_ = TileLocation.fetch(_loc7_,_loc8_);
               _loc12_.setLocation(_loc10_);
               if(!_loc11_.hasTilesForRect(_loc12_))
               {
                  _loc6_.info("waypoint hit an empty patch at " + _loc10_ + " traveling from " + _loc9_ + " to " + _loc13_);
                  return null;
               }
               if(_loc5_.findAllRectIntersectionEntities(_loc12_,param1,null))
               {
                  _loc6_.info("waypoint hit an obstacle at " + _loc10_ + " traveling from " + _loc9_ + " to " + _loc13_);
                  return null;
               }
               param3.push(_loc10_);
               _loc17_++;
            }
            _loc9_ = _loc13_;
         }
         return param3;
      }
      
      private function getMasterSave() : void
      {
         saveManager.removeEventListener(SaveManager.EVENT_INITIALIZED,this.getMasterSave);
         if(saveManager.initialized)
         {
            masterSave = saveManager.getMasterSave(def.id,"GameSaga.start " + this);
            if(def.id == "saga2")
            {
               masterSaveChildren["saga2s"] = saveManager.getMasterSave("saga2s","GameSaga.start children for " + this);
            }
            hoistAchievementsFromMaster();
         }
         else
         {
            saveManager.addEventListener(SaveManager.EVENT_INITIALIZED,this.getMasterSave);
         }
      }
      
      override public function resetMasterSave() : void
      {
         super.resetMasterSave();
         this.getMasterSave();
      }
      
      override public function cleanup() : void
      {
         if(GameSaveSynchronizer.instance)
         {
            GameSaveSynchronizer.instance.cancelPull();
         }
         this.timerSave.removeEventListener(TimerEvent.TIMER,this.timerSaveHandler);
         this.timerSave.stop();
         this.timerSave = null;
         this.campSceneStateClear();
         this.saved = null;
         this.tooltips = null;
         super.cleanup();
         this.config = null;
      }
      
      override public function canSave(param1:Happening, param2:String) : Boolean
      {
         var _loc3_:SceneState = null;
         var _loc4_:GamePageManagerAdapter = null;
         if(profile_index < 0)
         {
            profile_index = Saga.PROFILE_COUNT - 1;
         }
         if(!param2)
         {
            if(isStartScene)
            {
               cannotSaveReason = "isStartScene";
               return false;
            }
            _loc3_ = this.config.fsm.current as SceneState;
            if(_loc3_)
            {
               if(Boolean(_loc3_.battleHandler) && Boolean(_loc3_.battleHandler.fsm))
               {
                  cannotSaveReason = "(ss.battleHandler && ss.battleHandler.fsm)";
                  return false;
               }
               if(Boolean(_loc3_.scene) && Boolean(_loc3_.scene.focusedBoard))
               {
                  cannotSaveReason = "(ss.scene && ss.scene.focusedBoard)";
                  return false;
               }
               if(_loc3_.scene.convo)
               {
                  cannotSaveReason = "(ss.scene.convo)";
                  return false;
               }
            }
            _loc4_ = this.config.pageManager;
            if(_loc4_)
            {
               if(_loc4_.loading)
               {
                  cannotSaveReason = "(config.pageManager.loading)";
                  return false;
               }
               if(_loc4_.poppeningPage && _loc4_.poppeningPage.visible && Boolean(_loc4_.poppeningPage.parent))
               {
                  cannotSaveReason = "(pm.poppeningPage && pm.poppeningPage.visible && pm.poppeningPage.parent)";
                  return false;
               }
               if(_loc4_.warPage && _loc4_.warPage.visible && Boolean(_loc4_.warPage.parent))
               {
                  cannotSaveReason = "(pm.warPage && pm.warPage.visible && pm.warPage.parent)";
                  return false;
               }
            }
            if(!this.gameSceneUrl)
            {
               cannotSaveReason = "(!gameSceneUrl)";
               return false;
            }
         }
         return super.canSave(param1,param2);
      }
      
      private function timerSaveHandler(param1:TimerEvent) : void
      {
         var _loc2_:int = getTimer();
         var _loc3_:int = _loc2_ - this.lastSaveTime;
         var _loc4_:int = this.timerSave.delay / 4;
         if(_loc3_ < _loc4_)
         {
            return;
         }
         if(this.canSave(null,null))
         {
            this.saveSaga(SAVE_ID_RESUME,null,null);
         }
      }
      
      override public function handleSceneDestruction(param1:*) : void
      {
         var _loc2_:Scene = param1 as Scene;
         this.clearSceneTooltips(_loc2_,"scene destruction " + _loc2_);
      }
      
      private function clearSceneTooltips(param1:Scene, param2:String) : void
      {
         var _loc3_:TutorialTooltip = null;
         if(cleanedup)
         {
            return;
         }
         if(param1 != this.tooltipsScene)
         {
            return;
         }
         if(Boolean(this.tooltips) && Boolean(this.tooltips.length))
         {
            for each(_loc3_ in this.tooltips)
            {
               if(logger.isDebugEnabled)
               {
                  logger.debug("GameSaga.clearSceneTooltips " + _loc3_ + ": " + param2);
               }
               this.config.tutorialLayer.removeTooltip(_loc3_);
            }
            this.tooltips.splice(0,this.tooltips.length);
         }
         this.tooltipsScene = null;
      }
      
      override public function isTravelFalling() : Boolean
      {
         var _loc1_:ScenePage = this.config.pageManager.currentPage as ScenePage;
         return Boolean(_loc1_) && _loc1_.isTravelFalling();
      }
      
      override public function isSceneVisible() : Boolean
      {
         var _loc1_:ScenePage = this.config.pageManager.currentPage as ScenePage;
         return Boolean(_loc1_) && _loc1_.state == PageState.READY;
      }
      
      override public function isSceneLoaded() : Boolean
      {
         var _loc1_:SceneState = this.config.fsm.current as SceneState;
         if(_loc1_)
         {
            return _loc1_.scene.ready;
         }
         var _loc2_:SceneLoadState = this.config.fsm.current as SceneLoadState;
         if(_loc2_)
         {
            return false;
         }
         var _loc3_:FlashPage = this.config.pageManager.currentPage as FlashPage;
         if(_loc3_)
         {
            if(this.config.fsm.currentClass == FlashState)
            {
               return _loc3_.state == PageState.READY;
            }
         }
         return false;
      }
      
      override public function getScene() : Scene
      {
         if(cleanedup || !this.config || !this.config.fsm)
         {
            return null;
         }
         var _loc1_:SceneState = this.config.fsm.current as SceneState;
         if(_loc1_)
         {
            return _loc1_.scene;
         }
         var _loc2_:SceneLoadState = this.config.fsm.current as SceneLoadState;
         if(_loc2_)
         {
            return _loc2_.scene;
         }
         return null;
      }
      
      override public function getBattleBoard() : BattleBoard
      {
         var _loc1_:Scene = this.getScene();
         return !!_loc1_ ? _loc1_.focusedBoard : null;
      }
      
      override public function isBattleSetup() : Boolean
      {
         var _loc1_:BattleBoard = this.getBattleBoard();
         return Boolean(_loc1_) && _loc1_.boardSetup;
      }
      
      override public function isBattleDeploymentStarted() : Boolean
      {
         var _loc1_:BattleBoard = this.getBattleBoard();
         return Boolean(_loc1_) && _loc1_.boardDeploymentStarted;
      }
      
      override public function performDarknessGuiTransition() : void
      {
         var _loc1_:GamePageManagerAdapter = this.config.pageManager;
         var _loc2_:GameFsm = this.config.fsm;
         if(!_loc1_ || !_loc2_)
         {
            return;
         }
         var _loc3_:ScenePage = _loc1_.currentPage as ScenePage;
         if(!_loc3_ || !_loc3_.travelPage)
         {
            return;
         }
         var _loc4_:IGuiTravelTop = _loc3_.travelPage.removeGuiTop();
         _loc1_.showLoadingOverlayLayer();
         _loc1_.loadingOverlayLayer.addGuiTop(_loc4_);
      }
      
      override public function performClearGuiDialog() : void
      {
         this.config.dialogLayer.clearDialogs();
      }
      
      override public function performGuiDialog(param1:String, param2:String, param3:String, param4:String, param5:Function) : void
      {
         var _loc6_:IGuiDialog = this.config.gameGuiContext.createDialog();
         if(param4)
         {
            _loc6_.openTwoBtnDialog(param1,param2,param3,param4,param5);
         }
         else
         {
            _loc6_.openDialog(param1,param2,param3,param5);
         }
         if(!param3)
         {
            _loc6_.setCloseButtonVisible(true);
         }
      }
      
      override public function performTutorialRemoveAll(param1:String) : void
      {
         this.clearSceneTooltips(this.tooltipsScene,"performTutorialRemoveAll(" + param1 + ")");
      }
      
      override public function performTutorialRemove(param1:int) : void
      {
         this.config.tutorialLayer.removeTooltipByHandle(param1);
      }
      
      override public function performTutorialPopup(param1:String, param2:String, param3:int, param4:String, param5:Boolean, param6:Boolean, param7:int, param8:Function) : int
      {
         var _loc11_:TutorialTooltipAnchor = null;
         var _loc13_:Array = null;
         var _loc9_:Scene = this.getScene();
         if(this.tooltipsScene)
         {
            this.clearSceneTooltips(this.tooltipsScene,"performTutorialPopup");
         }
         this.tooltipsScene = _loc9_;
         var _loc10_:TutorialTooltipAlign = TutorialTooltipAlign.TOP;
         if(param4)
         {
            _loc13_ = param4.split(":");
            _loc10_ = Enum.parse(TutorialTooltipAlign,_loc13_[0]) as TutorialTooltipAlign;
            if(_loc13_.length > 1)
            {
               _loc11_ = Enum.parse(TutorialTooltipAnchor,_loc13_[1]) as TutorialTooltipAnchor;
            }
         }
         if(!_loc11_)
         {
            _loc11_ = _loc10_.oppositeAnchor;
         }
         var _loc12_:TutorialTooltip = this.config.tutorialLayer.createTooltip(param1,_loc10_,_loc11_,param3,param2,param5,param6,param7,param8);
         this.tooltips.push(_loc12_);
         return _loc12_.id;
      }
      
      override public function performVideo(param1:VideoParams) : void
      {
         super.performVideo(param1);
         this.config.fsm.current.data.setValue(GameStateDataEnum.VIDEO_PARAMS,param1);
         this.config.fsm.transitionTo(VideoQueueState,this.config.fsm.current.data);
      }
      
      override public function performSoundPlayScene(param1:String) : void
      {
         var _loc2_:SceneState = this.config.fsm.current as SceneState;
         var _loc3_:Scene = Boolean(_loc2_) && !_loc2_.cleanedup ? _loc2_.scene : null;
         var _loc4_:SceneAudio = Boolean(_loc3_) && !_loc3_.cleanedup ? _loc3_.audio : null;
         if(_loc4_)
         {
            _loc4_.addExtraGlobalSoundDef(param1);
         }
      }
      
      override public function performSoundPlayEventScene(param1:String, param2:String, param3:String, param4:Number, param5:ISoundDefBundle = null) : void
      {
         var _loc6_:SceneState = this.config.fsm.current as SceneState;
         var _loc7_:Scene = Boolean(_loc6_) && !_loc6_.cleanedup ? _loc6_.scene : null;
         var _loc8_:SceneAudio = Boolean(_loc7_) && !_loc7_.cleanedup ? _loc7_.audio : null;
         if(_loc8_)
         {
            _loc8_.addExtraGlobalSoundEvent(param1,param2,param3,param4,param5);
         }
      }
      
      override public function sceneStateSave() : String
      {
         var _loc2_:SavedSceneState = null;
         if(_suppressSceneStateSave)
         {
            return null;
         }
         var _loc1_:SceneState = this.config.fsm.current as SceneState;
         if(_loc1_)
         {
            if(!_loc1_.scene.boards || _loc1_.scene.boards.length == 0)
            {
               _loc2_ = new SavedSceneState();
               _loc2_.saveScene(_loc1_);
               if(logger.isDebugEnabled)
               {
                  logger.debug("   --- SCENE SAVE " + _loc2_);
               }
               this.saved = _loc2_;
               return _loc2_.url;
            }
         }
         return null;
      }
      
      override public function sceneStateRestore() : String
      {
         var _loc1_:SavedSceneState = null;
         if(!this.saved)
         {
            return null;
         }
         if(this.saved)
         {
            _loc1_ = this.saved;
            this.saved = null;
            if(logger.isDebugEnabled)
            {
               logger.debug("   --- SCENE RESTORE " + _loc1_);
            }
            return _loc1_.restore(this);
         }
         return null;
      }
      
      override public function campSceneStateClear() : void
      {
         if(logger.isDebugEnabled)
         {
            logger.debug("GameSaga.campSceneStateClear");
         }
         this.campSaved = null;
      }
      
      private function campSceneStateSave() : String
      {
         if(_suppressSceneStateSave)
         {
            return null;
         }
         var _loc1_:SceneState = this.config.fsm.current as SceneState;
         if(_loc1_)
         {
            if(_loc1_.scene.landscape.travel)
            {
               if(!_loc1_.scene.boards || _loc1_.scene.boards.length == 0)
               {
                  if(logger.isDebugEnabled)
                  {
                     logger.debug("GameSaga.campSceneStateSave " + _loc1_.scene._def.url);
                  }
                  this.campSaved = new SavedSceneState();
                  this.campSaved.saveScene(_loc1_);
               }
            }
         }
         return !!this.campSaved ? this.campSaved.url : null;
      }
      
      override public function campSceneStateRestore() : String
      {
         var _loc1_:SavedSceneState = null;
         if(this.campSaved)
         {
            _loc1_ = this.campSaved;
            this.campSaved = null;
            logger.info("   --- CAMP SCENE RESTORE " + _loc1_.url + " pos=" + _loc1_.travel_locator);
            return _loc1_.restore(this);
         }
         return null;
      }
      
      override public function performConversationStart(param1:Convo) : void
      {
         this.campSceneStateSave();
         performStopMapCamp();
         super.performConversationStart(param1);
         if(!this.config.fsm.current)
         {
            return;
         }
         var _loc2_:StateData = !!this.config.fsm.current ? this.config.fsm.current.data : new StateData();
         _loc2_.removeValue(GameStateDataEnum.WIPEIN_HOLD);
         _loc2_.removeValue(GameStateDataEnum.WIPEIN_DURATION);
         _loc2_.removeValue(GameStateDataEnum.HAPPENING_ID);
         _loc2_.setValue(GameStateDataEnum.CONVO,param1);
         _loc2_.setValue(GameStateDataEnum.SCENE_URL,param1.sceneUrl);
         _loc2_.removeValue(GameStateDataEnum.BATTLE_INFO);
         _loc2_.removeValue(GameStateDataEnum.BATTLE_MUSIC_DEF_URL);
         _loc2_.removeValue(GameStateDataEnum.BATTLE_MUSIC_OVERRIDE);
         _loc2_.removeValue(GameStateDataEnum.BATTLE_VITALITIES);
         _loc2_.setValue(GameStateDataEnum.SCENE_AUTOPAN,false);
         this.config.fsm.transitionTo(SceneLoadState,_loc2_);
      }
      
      override public function performTravelStart(param1:String, param2:TravelLocator, param3:Travel_FallData, param4:Travel_WipeData, param5:String, param6:Boolean) : void
      {
         if(!caravan)
         {
            logger.error("performTravelStart with no caravan");
            return;
         }
         if(param6)
         {
            this.cancelAllHalting();
            this.saved = null;
            camped = false;
         }
         super.performTravelStart(param1,param2,param3,param4,param5,param6);
         performStopMapCamp();
         var _loc7_:StateData = !!this.config.fsm.current ? this.config.fsm.current.data : new StateData();
         if(Boolean(param4) && Boolean(param4.wipeHold))
         {
            _loc7_.setValue(GameStateDataEnum.WIPEIN_HOLD,param4.wipeHold);
         }
         else
         {
            _loc7_.removeValue(GameStateDataEnum.WIPEIN_HOLD);
         }
         if(Boolean(param4) && Boolean(param4.wipeIn))
         {
            _loc7_.setValue(GameStateDataEnum.WIPEIN_DURATION,param4.wipeIn);
         }
         else
         {
            _loc7_.removeValue(GameStateDataEnum.WIPEIN_DURATION);
         }
         _loc7_.setValue(GameStateDataEnum.SCENELOADER_PRESERVE,false);
         _loc7_.setValue(GameStateDataEnum.HAPPENING_ID,param5);
         _loc7_.setValue(GameStateDataEnum.CONVO,null);
         _loc7_.setValue(GameStateDataEnum.SCENE_URL,param1);
         _loc7_.setValue(GameStateDataEnum.TRAVEL_LOCATOR,param2);
         _loc7_.setValue(GameStateDataEnum.TRAVEL_FALL_DATA,param3);
         _loc7_.setValue(GameStateDataEnum.SCENE_IS_TOWN,false);
         _loc7_.removeValue(GameStateDataEnum.BATTLE_INFO);
         _loc7_.removeValue(GameStateDataEnum.BATTLE_MUSIC_DEF_URL);
         _loc7_.removeValue(GameStateDataEnum.BATTLE_MUSIC_OVERRIDE);
         _loc7_.removeValue(GameStateDataEnum.BATTLE_VITALITIES);
         _loc7_.setValue(GameStateDataEnum.SCENE_AUTOPAN,true);
         this.config.fsm.transitionTo(SceneLoadState,_loc7_);
      }
      
      override public function performShowSagaSelector() : void
      {
         this.config.fsm.transitionTo(SagaSelectorState,null);
      }
      
      override public function performSceneStart(param1:String, param2:String, param3:Boolean) : void
      {
         if(!param1)
         {
            throw new ArgumentError("null url in performSceneStart");
         }
         this.campSceneStateSave();
         performStopMapCamp();
         super.performSceneStart(param1,param2,param3);
         if(param1.indexOf("cin_start.json.z") >= 0)
         {
            if(def.survival)
            {
               logger.info("GameSaga [" + def.url + "] QUITTING SURVIVAL");
               this.config.loadSaga("saga2/saga2.json.z",null,null,difficulty,-1,null,null,null);
               return;
            }
         }
         var _loc4_:StateData = !!this.config.fsm.current ? this.config.fsm.current.data : new StateData();
         _loc4_.removeValue(GameStateDataEnum.WIPEIN_HOLD);
         _loc4_.removeValue(GameStateDataEnum.WIPEIN_DURATION);
         _loc4_.setValue(GameStateDataEnum.SCENELOADER_PRESERVE,false);
         _loc4_.setValue(GameStateDataEnum.HAPPENING_ID,param2);
         _loc4_.setValue(GameStateDataEnum.SCENE_URL,param1);
         _loc4_.removeValue(GameStateDataEnum.CONVO);
         _loc4_.removeValue(GameStateDataEnum.TRAVEL_LOCATOR);
         _loc4_.setValue(GameStateDataEnum.SCENE_IS_TOWN,false);
         _loc4_.removeValue(GameStateDataEnum.BATTLE_INFO);
         _loc4_.removeValue(GameStateDataEnum.BATTLE_MUSIC_DEF_URL);
         _loc4_.removeValue(GameStateDataEnum.BATTLE_MUSIC_OVERRIDE);
         _loc4_.removeValue(GameStateDataEnum.BATTLE_VITALITIES);
         _loc4_.setValue(GameStateDataEnum.SCENE_AUTOPAN,param3);
         this.config.fsm.transitionTo(SceneLoadState,_loc4_);
      }
      
      override public function performBattleStopMusic() : void
      {
         var _loc2_:Scene = null;
         var _loc1_:SceneState = this.config.fsm.current as SceneState;
         if(_loc1_)
         {
            _loc2_ = _loc1_.scene;
            if(_loc2_)
            {
               _loc2_.stopBattleMusic();
            }
         }
      }
      
      override public function performBattleUnitAbility(param1:String, param2:String, param3:int, param4:Vector.<String>, param5:Vector.<TileLocation>, param6:Function) : void
      {
         var _loc15_:BattleAbilityValidation = null;
         var _loc17_:String = null;
         var _loc18_:Boolean = false;
         var _loc19_:IBattleEntity = null;
         var _loc20_:TileLocation = null;
         var _loc21_:Tile = null;
         var _loc22_:int = 0;
         var _loc7_:BattleBoard = this.getBattleBoard();
         if(!_loc7_)
         {
            throw new ArgumentError("GameSaga.performBattleUnitAbility no battle board");
         }
         var _loc8_:IBattleAbilityManager = _loc7_.abilityManager;
         var _loc9_:IBattleAbilityDef = _loc8_.getFactory.fetchIBattleAbilityDef(param2);
         var _loc10_:BattleAbilityDef = _loc9_.getAbilityDefForLevel(param3) as BattleAbilityDef;
         var _loc11_:IBattleEntity = _loc7_.getEntityByIdOrByDefId(param1,null,false);
         var _loc12_:BattleAbilityTargetRule = _loc10_.targetRule;
         var _loc13_:Boolean = _loc12_.isTile;
         if(!_loc11_)
         {
            throw new ArgumentError("GameSaga.performBattleUnitAbility invalid caster [" + param1 + "]. valids=" + _loc7_.getDebugEntityList());
         }
         var _loc14_:BattleAbility = new BattleAbility(_loc11_,_loc10_,_loc8_);
         var _loc16_:TileRect = _loc11_.rect;
         if(_loc12_ == BattleAbilityTargetRule.SELF || _loc12_ == BattleAbilityTargetRule.SELF_AOE_1 || _loc12_ == BattleAbilityTargetRule.SELF_AOE_ENEMY_1)
         {
            _loc14_.targetSet.addTarget(_loc11_);
         }
         else if(param4)
         {
            for each(_loc17_ in param4)
            {
               if(_loc17_)
               {
                  _loc18_ = false;
                  if(Boolean(_loc17_) && _loc17_.charAt(0) == "?")
                  {
                     _loc18_ = true;
                     _loc17_ = _loc17_.substring(1);
                  }
                  _loc17_ = this._processRandomTarget(_loc17_,_loc14_,_loc7_);
                  if(_loc17_)
                  {
                     _loc19_ = _loc7_.getEntityByIdOrByDefId(_loc17_,_loc16_,false);
                     if(_loc19_)
                     {
                        if(_loc13_)
                        {
                           param5.push(_loc19_.tile.location);
                        }
                        else
                        {
                           _loc15_ = BattleAbilityValidation.validateRange(_loc14_.def,_loc11_,null,_loc19_,null);
                           if(_loc15_ != BattleAbilityValidation.OK)
                           {
                              throw new ArgumentError("GameSaga.performBattleUnitAbility invalid target [" + _loc19_ + "] result=" + _loc15_ + ", valids=" + _loc7_.getDebugEntityList());
                           }
                           _loc14_.targetSet.addTarget(_loc19_);
                        }
                     }
                     else if(!_loc18_)
                     {
                        throw new ArgumentError("GameSaga.performBattleUnitAbility null target [" + _loc17_ + "]. valids=" + _loc7_.getDebugEntityList());
                     }
                  }
               }
            }
         }
         if(param5)
         {
            for each(_loc20_ in param5)
            {
               _loc21_ = _loc7_.tiles.getTileByLocation(_loc20_);
               if(!_loc21_)
               {
                  throw new ArgumentError("GameSaga.performBattleUnitAbility null tile [" + _loc20_ + "]");
               }
               _loc15_ = BattleAbilityValidation.validateRange(_loc14_._def,_loc11_,null,null,_loc21_);
               if(_loc15_ != BattleAbilityValidation.OK)
               {
                  throw new ArgumentError("GameSaga.performBattleUnitAbility invalid tile [" + _loc21_ + "] result=" + _loc15_);
               }
               _loc14_.targetSet.addTile(_loc21_);
            }
         }
         if(_loc10_.targetCount)
         {
            if(_loc10_.targetRule != BattleAbilityTargetRule.TILE_EMPTY_RANDOM)
            {
               _loc22_ = _loc13_ ? _loc14_.targetSet.tiles.length : _loc14_.targetSet.targets.length;
               if(_loc22_ < _loc10_.targetCount)
               {
                  logger.info("GameSaga.performBattleUnitAbility insufficient targets found " + _loc22_ + " expected " + _loc10_.targetCount);
                  if(param6 != null)
                  {
                     param6(null);
                  }
                  return;
               }
            }
         }
         _loc14_.execute(param6);
      }
      
      private function _processRandomTarget(param1:String, param2:BattleAbility, param3:BattleBoard) : String
      {
         var _loc5_:BattleEntity = null;
         var _loc6_:BattleAbilityValidation = null;
         var _loc7_:int = 0;
         if(!param1 || param1.charAt(0) != "*")
         {
            return param1;
         }
         param1 = param1.substr(1);
         var _loc4_:Vector.<BattleEntity> = new Vector.<BattleEntity>();
         for each(_loc5_ in param3.entities)
         {
            if(_loc5_.mobile)
            {
               if(param2._def.checkTargetExecutionConditions(_loc5_,logger,true))
               {
                  _loc6_ = BattleAbilityValidation.validate(param2._def,param2.caster,null,_loc5_,null,false,false,true,true);
                  if(!(!_loc6_ || !_loc6_.ok))
                  {
                     if(!param2._targetSet.hasTarget(_loc5_))
                     {
                        _loc4_.push(_loc5_);
                     }
                  }
               }
            }
         }
         if(_loc4_.length)
         {
            _loc7_ = MathUtil.randomInt(0,_loc4_.length - 1);
            _loc5_ = _loc4_[_loc7_];
            return _loc5_.id;
         }
         return param1;
      }
      
      override public function performBattleUnitMove(param1:String, param2:Vector.<Vector.<TileLocation>>, param3:Boolean, param4:Function) : IBattleEntity
      {
         var _loc7_:BattleMove = null;
         var _loc9_:Vector.<TileLocation> = null;
         var _loc10_:Vector.<TileLocation> = null;
         var _loc11_:Vector.<TileLocation> = null;
         var _loc12_:TileLocation = null;
         var _loc13_:Tile = null;
         var _loc14_:* = null;
         var _loc5_:BattleBoard = this.getBattleBoard();
         if(!_loc5_)
         {
            throw new ArgumentError("GameSaga.performBattleUnitMove no battle board");
         }
         var _loc6_:IBattleEntity = _loc5_.getEntityByIdOrByDefId(param1,null,false);
         if(!_loc6_)
         {
            _loc6_ = _loc5_.getEntityByIdOrByDefId(param1,null,false);
            throw new ArgumentError("GameSaga.performBattleUnitMove invalid entity [" + param1 + "]");
         }
         var _loc8_:int = 0;
         while(_loc8_ < param2.length)
         {
            _loc9_ = param2[_loc8_];
            for each(_loc10_ in param2)
            {
               if(_loc7_)
               {
                  break;
               }
               _scratchSteps.splice(0,_scratchSteps.length);
               _loc11_ = _convertWaypointsToSteps(_loc6_,_loc10_,_scratchSteps);
               if(!_loc11_)
               {
                  logger.info("GameSaga.performBattleUnitMove " + param1 + " unable to process, skipping path [" + _loc10_.join(",") + "]");
               }
               else
               {
                  _loc7_ = new BattleMove(_loc6_,1000,0,param3,true,true);
                  for each(_loc12_ in _loc11_)
                  {
                     _loc13_ = _loc5_.tiles.getTileByLocation(_loc12_);
                     if(!_loc13_)
                     {
                        throw new ArgumentError("GameSaga.performBattleUnitMove " + param1 + " invalid tile " + _loc13_);
                     }
                     _loc7_.addStep(_loc13_);
                  }
               }
            }
            _loc8_++;
         }
         if(!_loc7_)
         {
            _loc14_ = "GameSaga.performBattleUnitMove " + param1 + " unable to process";
            throw new ArgumentError(_loc14_);
         }
         _loc7_.callbackExecuted = param4;
         _loc7_.setCommitted("GameSaga.performBattleUnitMove");
         _loc6_.mobility.executeMove(_loc7_);
         return _loc6_;
      }
      
      override public function performBattleUnitPathfind(param1:String, param2:Vector.<Vector.<TileLocation>>, param3:Boolean, param4:Function) : IBattleEntity
      {
         var _loc7_:Vector.<Tile> = null;
         var _loc8_:BattleMove = null;
         var _loc10_:Vector.<TileLocation> = null;
         var _loc11_:Vector.<TileLocation> = null;
         var _loc12_:TileLocation = null;
         var _loc13_:Tile = null;
         var _loc14_:* = null;
         var _loc5_:BattleBoard = this.getBattleBoard();
         if(!_loc5_)
         {
            throw new ArgumentError("GameSaga.performBattleUnitMove no battle board");
         }
         var _loc6_:IBattleEntity = _loc5_.getEntityByIdOrByDefId(param1,null,false);
         if(!_loc6_)
         {
            _loc6_ = _loc5_.getEntityByIdOrByDefId(param1,null,false);
            throw new ArgumentError("GameSaga.performBattleUnitMove invalid entity [" + param1 + "]");
         }
         var _loc9_:int = 0;
         while(_loc9_ < param2.length)
         {
            _loc10_ = param2[_loc9_];
            for each(_loc11_ in param2)
            {
               if(_loc8_)
               {
                  break;
               }
               _loc8_ = new BattleMove(_loc6_,1000,0,param3,false,true);
               for each(_loc12_ in _loc11_)
               {
                  _loc13_ = _loc5_.tiles.getTileByLocation(_loc12_);
                  if(!_loc13_)
                  {
                     throw new ArgumentError("GameSaga.performBattleUnitMove " + param1 + " invalid tile " + _loc13_);
                  }
                  if(!_loc8_.process(_loc13_,false))
                  {
                     logger.info("GameSaga.performBattleUnitMove " + param1 + " unable to process tile [" + _loc13_ + "], skipping path [" + _loc11_.join(",") + "]");
                     _loc8_.cleanup();
                     _loc8_ = null;
                     if(!_loc7_)
                     {
                        _loc7_ = new Vector.<Tile>();
                     }
                     _loc7_.push(_loc13_);
                  }
                  else
                  {
                     _loc8_.setWayPoint(_loc13_);
                  }
               }
            }
            _loc9_++;
         }
         if(!_loc8_)
         {
            _loc14_ = "GameSaga.performBattleUnitMove " + param1 + " unable to process tiles: ";
            for each(_loc13_ in _loc7_)
            {
               _loc14_ += " [" + _loc13_ + "]";
            }
            throw new ArgumentError(_loc14_);
         }
         _loc8_.callbackExecuted = param4;
         _loc8_.setCommitted("GameSaga.performBattleUnitMove");
         _loc6_.mobility.executeMove(_loc8_);
         return _loc6_;
      }
      
      override public function performBattleReady() : void
      {
         var _loc2_:Scene = null;
         var _loc3_:BattleFsm = null;
         var _loc4_:BattleStateDeploy = null;
         var _loc1_:SceneState = this.config.fsm.current as SceneState;
         if(_loc1_)
         {
            _loc2_ = _loc1_.scene;
            if(_loc2_)
            {
               _loc3_ = _loc1_.battleHandler.fsm;
               if(_loc3_)
               {
                  _loc4_ = _loc3_.current as BattleStateDeploy;
                  if(_loc4_)
                  {
                     _loc4_.autoDeployLocal();
                  }
               }
            }
         }
      }
      
      override public function performBattleHalt() : void
      {
         var _loc2_:Scene = null;
         var _loc1_:SceneState = this.config.fsm.current as SceneState;
         if(_loc1_)
         {
            _loc2_ = _loc1_.scene;
            if(_loc2_)
            {
               _loc1_.battleHandler.fsm.haltBattle();
            }
         }
      }
      
      override public function performBattleSurrender() : void
      {
         var _loc2_:Scene = null;
         var _loc1_:SceneState = this.config.fsm.current as SceneState;
         if(_loc1_)
         {
            _loc2_ = _loc1_.scene;
            if(_loc2_)
            {
               _loc1_.battleHandler.fsm.surrender();
            }
         }
      }
      
      override public function performBattleStart(param1:SceneLoaderBattleInfo, param2:String) : void
      {
         var _loc5_:Boolean = false;
         if(!caravan)
         {
            logger.error("performBattleStart with no caravan");
            return;
         }
         if(!param1.battle_board_id)
         {
            logger.error("No board_id in performBattleStart");
            return;
         }
         this.campSceneStateSave();
         performStopMapCamp();
         super.performBattleStart(param1,param2);
         var _loc3_:StateData = !!this.config.fsm.current ? this.config.fsm.current.data : new StateData();
         _loc3_.removeValue(GameStateDataEnum.WIPEIN_HOLD);
         _loc3_.removeValue(GameStateDataEnum.WIPEIN_DURATION);
         _loc3_.setValue(GameStateDataEnum.HAPPENING_ID,param1.happening);
         if(param1.snap)
         {
            _loc3_.removeValue(GameStateDataEnum.LOCAL_PARTY);
         }
         else
         {
            _loc3_.setValue(GameStateDataEnum.LOCAL_PARTY,caravan.legend.party.getEntityListDef());
         }
         _loc3_.setValue(GameStateDataEnum.SCENE_URL,param1.url);
         _loc3_.removeValue(GameStateDataEnum.CONVO);
         _loc3_.removeValue(GameStateDataEnum.TRAVEL_LOCATOR);
         _loc3_.setValue(GameStateDataEnum.SCENE_IS_TOWN,false);
         _loc3_.setValue(GameStateDataEnum.BATTLE_INFO,param1);
         var _loc4_:String = param1.music_url;
         if(_loc4_)
         {
            _loc5_ = param1.music_override;
         }
         else
         {
            _loc4_ = battleMusicDefUrl;
         }
         if(isSurvival)
         {
            this.trackPageView("survival_battle");
         }
         this._markSurvivalReloadRequired(true);
         this._checkSurvivalConstituents();
         _loc3_.setValue(GameStateDataEnum.BATTLE_MUSIC_DEF_URL,_loc4_);
         _loc3_.setValue(GameStateDataEnum.BATTLE_MUSIC_OVERRIDE,_loc5_);
         _loc3_.setValue(GameStateDataEnum.BATTLE_VITALITIES,param2);
         _loc3_.setValue(GameStateDataEnum.SCENE_AUTOPAN,true);
         this.config.fsm.transitionTo(SceneLoadState,_loc3_);
      }
      
      override protected function handlePerformMapCamp(param1:String, param2:String, param3:String, param4:Number, param5:Boolean) : void
      {
         if(cleanedup)
         {
            return;
         }
         var _loc6_:StateData = !!this.config.fsm.current ? this.config.fsm.current.data : new StateData();
         _loc6_.removeValue(GameStateDataEnum.WIPEIN_HOLD);
         _loc6_.removeValue(GameStateDataEnum.WIPEIN_DURATION);
         _loc6_.setValue(GameStateDataEnum.HAPPENING_ID,param1);
         _loc6_.removeValue(GameStateDataEnum.CONVO);
         _loc6_.setValue(GameStateDataEnum.SCENE_URL,this.def.mapSceneUrl);
         _loc6_.removeValue(GameStateDataEnum.BATTLE_INFO);
         this.config.fsm.transitionTo(MapCampLoadState,_loc6_);
      }
      
      override public function performAssembleHeroes() : void
      {
         if(cleanedup)
         {
            return;
         }
         if(!this.config || !this.config.fsm || !this.config.fsm.current)
         {
            return;
         }
         this.campSceneStateSave();
         this.sceneStateSave();
         this.config.fsm.transitionTo(AssembleHeroesState,this.config.fsm.current.data);
      }
      
      override public function performSagaSurvivalBattlePopup(param1:String, param2:Function) : void
      {
         this.config.pageManager.showSagaSurvivalBattlePopup(param1,param2);
      }
      
      override public function performFlashPage(param1:String, param2:String, param3:Number, param4:Boolean) : void
      {
         if(cleanedup)
         {
            return;
         }
         this.campSceneStateSave();
         performStopMapCamp();
         super.performFlashPage(param1,param2,param3,param4);
         var _loc5_:Fsm = !!this.config ? this.config.fsm : null;
         if(!_loc5_)
         {
            throw new IllegalOperationError("No fsm available for performFlashPage");
         }
         var _loc6_:State = _loc5_.current;
         if(!_loc6_)
         {
            logger.info("No current fsm state for performFlashPage");
         }
         var _loc7_:StateData = !!_loc6_ ? _loc6_.data : null;
         if(!_loc7_)
         {
            logger.info("No current fsm data for performFlashPage");
            _loc7_ = new StateData();
         }
         _loc7_.setValue(GameStateDataEnum.FLASH_URL,param1);
         _loc7_.setValue(GameStateDataEnum.FLASH_TIME,param3);
         _loc7_.setValue(GameStateDataEnum.FLASH_MSG,param2);
         _loc7_.setValue(GameStateDataEnum.DISABLE_PAGE_CLOSE_BUTTON,param4);
         _loc5_.transitionTo(FlashState,_loc7_);
      }
      
      override public function performPoppening(param1:Convo, param2:Boolean) : void
      {
         if(cleanedup)
         {
            return;
         }
         super.performPoppening(param1,param2);
         if(param2)
         {
            this.config.pageManager.war = param1;
         }
         else
         {
            this.config.pageManager.poppening = param1;
         }
         if(this.tooltipsScene)
         {
            this.clearSceneTooltips(this.tooltipsScene,"performPoppening");
         }
         if(Boolean(this.config) && Boolean(this.config.tutorialLayer))
         {
            this.config.tutorialLayer.removeAllTooltips();
         }
      }
      
      override public function performWarResolution(param1:WarOutcome, param2:BattleFinishedData) : void
      {
         if(cleanedup)
         {
            return;
         }
         super.performWarResolution(param1,param2);
         var _loc3_:SceneState = this.config.fsm.current as SceneState;
         if(_loc3_)
         {
            _loc3_.showWarResolution(param1,param2);
            this.performBattleFinishMusic(Boolean(param2) && param2.victoriousTeam == "0");
         }
      }
      
      override public function performTally(param1:String, param2:Function, param3:Boolean) : void
      {
         if(cleanedup || !param1)
         {
            return;
         }
         var _loc4_:ScenePage = this.config.pageManager.currentPage as ScenePage;
         if(!_loc4_ || Boolean(_loc4_.tallyPage))
         {
            return;
         }
         if(_loc4_.scene)
         {
            _loc4_.scene.setClickableEnabled("*",false,"Darkness Transition");
         }
         _loc4_.performTally(param1,param2,param3);
      }
      
      override public function performBattleFinishMusic(param1:Boolean) : void
      {
         if(cleanedup)
         {
            return;
         }
         var _loc2_:SceneState = this.config.fsm.current as SceneState;
         if(Boolean(_loc2_) && Boolean(_loc2_.scene))
         {
            _loc2_.scene.performBattleFinishMusic(param1);
         }
      }
      
      override public function performBattleResolution(param1:BattleFinishedData, param2:Boolean) : void
      {
         logger.i("SAGA","performBattleResolution " + param1 + " " + param2 + " cleanedup=" + cleanedup);
         if(cleanedup)
         {
            return;
         }
         super.performBattleResolution(param1,param2);
         var _loc3_:SceneState = this.config.fsm.current as SceneState;
         if(_loc3_)
         {
            _loc3_.showBattleResolution(param1,param2);
            this.performBattleFinishMusic(Boolean(param1) && param1.victoriousTeam == "0");
         }
      }
      
      override public function performWarRespawn(param1:int, param2:String, param3:String, param4:String) : void
      {
         if(cleanedup)
         {
            return;
         }
         super.performWarRespawn(param1,param2,param3,param4);
         var _loc5_:SceneState = this.config.fsm.current as SceneState;
         if(_loc5_)
         {
            _loc5_.respawnBattle(param1,param2,param3,param4);
         }
         this.applyBattleBoardSurvival();
         if(Boolean(survival) && Boolean(survival.record))
         {
            survival.record.handleBattleRespawn(this.getBattleBoard());
         }
      }
      
      override public function handleHudHornEnabled() : void
      {
         if(cleanedup)
         {
            return;
         }
         this.config.battleHudConfig.showHorn = hudHornEnabled;
         this.config.battleHudConfig.notify();
      }
      
      override public function triggerSceneEnterState(param1:String) : void
      {
         if(cleanedup)
         {
            return;
         }
         var _loc2_:BattleBoard = this.getBattleBoard();
         if(!_loc2_)
         {
            return;
         }
         this.applyBattleBoardBonuses();
         this.applyBattleBoardDifficulty();
         this.applyBattleBoardSurvival();
         if(Boolean(survival) && Boolean(survival.record))
         {
            survival.record.handleBattleStart(_loc2_);
         }
         super.triggerSceneEnterState(param1);
      }
      
      override public function triggerBattleBoardSetup(param1:String) : void
      {
         if(cleanedup)
         {
            return;
         }
         super.triggerBattleBoardSetup(param1);
      }
      
      override protected function handleCheckBattleAborted() : void
      {
         if(cleanedup)
         {
            return;
         }
         var _loc1_:SceneState = this.config.fsm.current as SceneState;
         var _loc2_:SceneStateBattleHandler = !!_loc1_ ? _loc1_.battleHandler : null;
         var _loc3_:BattleFsm = !!_loc2_ ? _loc2_.fsm : null;
         var _loc4_:BattleFinishedData = !!_loc3_ ? _loc3_._finishedData : null;
         if(Boolean(_loc4_) && _loc3_.battleFinished)
         {
            logger.info("GameSaga.handleCheckBattleAborted battle is already kaput,  triggering finished");
            triggerBattleFinished(_loc1_.scene._def.url);
         }
      }
      
      private function applyBattleBoardBonuses() : void
      {
         var _loc7_:IBattleEntity = null;
         var _loc8_:Stat = null;
         if(!caravan)
         {
            return;
         }
         var _loc1_:Saga = this.config.saga;
         if(_loc1_.def.survival)
         {
            return;
         }
         var _loc2_:int = getVar(SagaVar.VAR_MORALE_BONUS_WILLPOWER,VariableType.INTEGER).asInteger;
         if(!_loc2_)
         {
            return;
         }
         var _loc3_:SceneState = this.config.fsm.current as SceneState;
         if(!_loc3_ || !_loc3_.battleHandler || !_loc3_.battleHandler.fsm)
         {
            return;
         }
         if(_loc3_.scene._def.tutorial)
         {
            return;
         }
         var _loc4_:BattleBoard = _loc3_.battleHandler.fsm.board as BattleBoard;
         if(!_loc4_ || _loc4_.difficultyDisabled)
         {
            return;
         }
         var _loc5_:IBattleParty = !!_loc4_ ? _loc4_.getPartyById("0") : null;
         if(!_loc5_)
         {
            return;
         }
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_.numMembers)
         {
            _loc7_ = _loc5_.getMember(_loc6_);
            _loc8_ = _loc7_.stats.getStat(StatType.WILLPOWER);
            _loc8_.base += _loc2_;
            _loc6_++;
         }
      }
      
      private function applyBattleBoardSurvival() : void
      {
         var _loc1_:Saga = this.config.saga;
         if(!_loc1_ || !isSurvival)
         {
            return;
         }
         var _loc2_:BattleBoard = this.getBattleBoard();
         if(!_loc2_)
         {
            return;
         }
         var _loc3_:IBattleParty = _loc2_.getPartyById("npc");
         if(!_loc3_)
         {
            return;
         }
         var _loc4_:int = _loc3_.numAlive;
         if(_loc4_ <= 0)
         {
            return;
         }
         var _loc5_:ItemDef = generateRandomItemDefForPartyRanks();
         if(!_loc5_)
         {
            logger.info("SURVIVAL no item grantable?");
            return;
         }
         var _loc6_:int = MathUtil.randomInt(0,_loc4_ - 1);
         var _loc7_:IBattleEntity = _loc3_.getAliveMember(_loc6_);
         var _loc8_:Item = createItemByDefId(_loc5_.id);
         _loc7_.entityItem = _loc8_;
         logger.info("SURVIVAL Item granted [" + _loc7_ + "] [" + _loc8_ + "]");
      }
      
      private function applyBattleBoardDifficulty() : void
      {
         var _loc4_:IBattleParty = null;
         var _loc5_:int = 0;
         var _loc6_:IBattleEntity = null;
         var _loc1_:SceneState = this.config.fsm.current as SceneState;
         if(!_loc1_ || !_loc1_.battleHandler || !_loc1_.battleHandler.fsm)
         {
            return;
         }
         if(_loc1_.scene._def.tutorial)
         {
            return;
         }
         var _loc2_:BattleBoard = _loc1_.battleHandler.fsm.board as BattleBoard;
         if(_loc2_.difficultyDisabled)
         {
            return;
         }
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.numParties)
         {
            _loc4_ = _loc2_.getParty(_loc3_);
            if(_loc4_.isEnemy)
            {
               _loc5_ = 0;
               while(_loc5_ < _loc4_.numMembers)
               {
                  _loc6_ = _loc4_.getMember(_loc5_);
                  applyUnitDifficultyBonuses(_loc6_);
                  _loc5_++;
               }
            }
            _loc3_++;
         }
      }
      
      override public function saveSaga(param1:String, param2:Happening, param3:String, param4:Boolean = false) : SagaSave
      {
         if(profile_index < 0)
         {
            profile_index = Saga.PROFILE_COUNT - 1;
         }
         if(!this.canSave(param2,param3))
         {
            logger.error("Cannot save right now.  Skipping [" + param1 + "] reason [" + cannotSaveReason + "]");
            this.canSave(param2,param3);
            if(!param4)
            {
               return null;
            }
            logger.error("Allowing save anyway...");
         }
         var _loc5_:int = getTimer();
         var _loc6_:SagaSave = new SagaSave(param1).fromSaga(this,param3);
         if(!_loc6_)
         {
            logger.info("GameSaga.saveGame No save file generated");
            return null;
         }
         _loc6_.setVar(SagaVar.VAR_SURVIVAL_RELOAD_REQUIRED,false);
         saveManager.writeSave(_loc6_,profile_index,isSurvival);
         return _loc6_;
      }
      
      override public function loadSaga(param1:String, param2:String, param3:int) : void
      {
         var _loc4_:SagaSave = saveManager.getSave(def.id,param2,param3,isSurvival);
         if(!_loc4_)
         {
            return;
         }
         this.config.loadSaga(def.url,null,_loc4_,0,param3,null,null,parentSagaUrl);
      }
      
      override public function loadExistingSave(param1:SagaSave, param2:int) : void
      {
         this.config.loadSaga(def.url,null,param1,0,param2,null,null,parentSagaUrl);
      }
      
      override public function takeScreenshot(param1:Boolean) : ByteArray
      {
         if(param1)
         {
            return Screenshot.screenshotPng(this.config.pageManager.holder,this.SCREENSHOT_WIDTH,this.SCREENSHOT_HEIGIHT,appinfo,true);
         }
         return Screenshot.screenshotZipped(this.config.pageManager.holder,this.SCREENSHOT_WIDTH,this.SCREENSHOT_HEIGIHT,appinfo);
      }
      
      override public function storeMasterSave() : void
      {
         if(!masterSave)
         {
            return;
         }
         saveManager.putMasterSave(def.id,masterSave);
      }
      
      override public function loadFromSave(param1:SagaSave) : void
      {
         this.campSceneStateClear();
         this.saved = null;
         this.config.pageManager.war = null;
         this.config.pageManager.poppening = null;
         this.config.dialogLayer.clearDialogs();
         if(isSurvival)
         {
            if(param1.getVarBool(this,SagaVar.VAR_SURVIVAL_RELOAD_REQUIRED))
            {
               logger.info("GameSaga.loadFromSave SURVIVAL consuming one reload");
               param1.setVar(SagaVar.VAR_SURVIVAL_RELOAD_REQUIRED,undefined);
               param1.setVar(SagaVar.VAR_SURVIVAL_RELOAD_COUNT,param1.survivalReloadCount + 1);
               saveManager.writeSave(param1,profile_index,isSurvival);
            }
         }
         super.loadFromSave(param1);
         if(isSurvival)
         {
            if(survivalReloadCount >= survivalReloadLimit)
            {
               this._showDialogSurvivalReloadLimitWarning(survivalReloadLimit);
            }
         }
      }
      
      private function _showDialogSurvivalReloadLimitWarning(param1:int) : void
      {
         var title:String;
         var body:String;
         var ok:String;
         var d:IGuiDialog = null;
         var survival_reload_limit:int = param1;
         d = this.config.gameGuiContext.createDialog();
         pause(d);
         title = locale.translateGui("survival_reload_limit_warning_title");
         body = locale.translateGui("survival_reload_limit_warning_body");
         ok = locale.translateGui("ok");
         body = performStringReplacement_SagaVar(body);
         d.openDialog(title,body,ok,function():void
         {
            unpause(d);
         });
      }
      
      override public function get campSceneStateUrl() : String
      {
         return !!this.campSaved ? this.campSaved.url : null;
      }
      
      override public function get campSceneStateTravelLocator() : TravelLocator
      {
         return !!this.campSaved ? this.campSaved.travel_locator : null;
      }
      
      override public function campSceneStateStoreDetails(param1:String, param2:TravelLocator) : void
      {
         if(_suppressSceneStateSave)
         {
            return;
         }
         if(!param1)
         {
            return;
         }
         logger.info("GameSaga.campSceneStateSave " + param1);
         this.campSaved = new SavedSceneState();
         this.campSaved.saveDetails(param1,param2);
      }
      
      override public function get gameSceneUrl() : String
      {
         var _loc1_:SceneState = this.config.fsm.current as SceneState;
         if(_loc1_)
         {
            return _loc1_.scene._def.url;
         }
         return null;
      }
      
      override public function get gameConvoUrl() : String
      {
         var _loc1_:SceneState = this.config.fsm.current as SceneState;
         if(Boolean(_loc1_) && Boolean(_loc1_.scene.convo))
         {
            return _loc1_.scene.convo.def.url;
         }
         if(this.config.pageManager.poppening)
         {
            return this.config.pageManager.poppening.def.url;
         }
         return null;
      }
      
      override public function endAllHappenings() : void
      {
         super.endAllHappenings();
         if(this.config.tutorialLayer)
         {
            this.config.tutorialLayer.removeAllTooltips();
         }
         this.config.pageManager.poppening = null;
         this.config.pageManager.war = null;
         this.saved = null;
         this.campSaved = null;
      }
      
      override public function performEndCredits(param1:SagaCreditsDef, param2:Boolean, param3:Boolean) : void
      {
         this.endingCredits = true;
         this.pause("performEndCredits");
         this.config.pageManager.showCreditsPage(param1,param2,param3);
      }
      
      override public function handleCreditsComplete() : Boolean
      {
         if(this.endingCredits)
         {
            this.endingCredits = false;
            this.config.saga.showStartPage(false);
            return true;
         }
         return false;
      }
      
      override public function performWipeInConfig(param1:Number, param2:Number) : void
      {
         var _loc4_:StateData = null;
         var _loc3_:State = this.config.fsm.current;
         if(_loc3_)
         {
            _loc4_ = _loc3_.data;
            if(_loc4_)
            {
               _loc4_.setValue(GameStateDataEnum.WIPEIN_HOLD,param1);
               _loc4_.setValue(GameStateDataEnum.WIPEIN_DURATION,param2);
            }
         }
      }
      
      override public function showSaveLoad(param1:Boolean, param2:int, param3:Boolean) : void
      {
         this.config.pageManager.showSaveLoad(param1,param2,param3);
      }
      
      override public function showSaveProfileLoad() : void
      {
         this.config.pageManager.showSaveProfileLoad(true);
      }
      
      override public function showSaveProfileStart(param1:Function) : void
      {
         this.config.pageManager.showSaveProfileStart("start",param1);
      }
      
      override public function loadMostRecentSave(param1:Boolean, param2:int) : void
      {
         var _loc3_:SagaSave = saveManager.getMostRecentSaveInProfile(def.id,param1,param2,isSurvival);
         if(_loc3_)
         {
            this.config.loadSaga(def.url,null,_loc3_,0,param2,null,null,parentSagaUrl);
         }
      }
      
      override public function get isTravelScene() : Boolean
      {
         var _loc1_:Scene = this.getScene();
         return Boolean(_loc1_) && Boolean(_loc1_.landscape) && Boolean(_loc1_.landscape.travel);
      }
      
      override public function sceneFadeOut(param1:Number) : void
      {
         var _loc2_:ScenePage = this.config.pageManager.currentPage as ScenePage;
         if(_loc2_)
         {
            _loc2_.startWipedownOut(param1);
         }
      }
      
      override public function get currentPageName() : String
      {
         var _loc1_:GamePage = this.config.pageManager.currentPage as GamePage;
         return !!_loc1_ ? _loc1_.name : null;
      }
      
      override public function get isOptionsShowing() : Boolean
      {
         return this.config.pageManager.isShowingOptions();
      }
      
      override public function launchSagaByUrl(param1:String, param2:String, param3:int, param4:String) : void
      {
         var _loc5_:SagaSave = null;
         var _loc6_:String = null;
         this.config.loadSaga(param1,param2,null,param3,0,_loc5_,_loc6_,param4);
      }
      
      override protected function survivalHandleStart() : void
      {
         if(SagaDef.SURVIVAL_ENABLED)
         {
            logger.info("GameSaga.survivalHandleStart " + this);
            this.config.fsm.transitionTo(SagaSurvivalStartState,this.config.fsm.current.data);
         }
      }
      
      override public function showSurvivalWinPage() : void
      {
         if(SagaDef.SURVIVAL_ENABLED)
         {
            logger.info("GameSaga.survivalHandleWin " + this);
            this.config.fsm.transitionTo(SagaSurvivalWinState,this.config.fsm.current.data);
         }
      }
      
      override public function survivalReload() : void
      {
         if(!isSurvivalBattle)
         {
            logger.info("GameSaga.survivalReload not in battle");
            return;
         }
         if(profile_index < 0)
         {
            logger.info("GameSaga.survivalReload invalid profile " + profile_index);
            return;
         }
         var _loc1_:SagaSave = saveManager.getMostRecentSaveInProfile(def.id,true,profile_index,isSurvival);
         if(!_loc1_)
         {
            logger.info("GameSaga.survivalReload no reload available");
            return;
         }
         if(!_loc1_.survivalReloadRequired)
         {
            logger.info("GameSaga.survivalReload no reload required");
            this.config.loadSaga(def.url,null,_loc1_,difficulty,profile_index,null,null,parentSagaUrl);
            return;
         }
         var _loc2_:int = _loc1_.survivalReloadCount;
         var _loc3_:int = getVarInt(SagaVar.VAR_SURVIVAL_RELOAD_LIMIT);
         if(_loc2_ >= _loc3_)
         {
            this._showDialogSurvivalReloadLimitReached(_loc3_);
            return;
         }
         this._showDialogSurvivalReloadWarning(_loc2_,_loc3_,_loc1_);
      }
      
      private function _showDialogSurvivalReloadLimitReached(param1:int) : void
      {
         var _loc2_:IGuiDialog = this.config.gameGuiContext.createDialog();
         var _loc3_:String = locale.translateGui("survival_reload_limit_reached_title");
         var _loc4_:String = locale.translateGui("survival_reload_limit_reached_body");
         var _loc5_:String = locale.translateGui("ok");
         _loc4_ = performStringReplacement_SagaVar(_loc4_);
         _loc2_.openDialog(_loc3_,_loc4_,_loc5_);
      }
      
      private function _showDialogSurvivalReloadWarning(param1:int, param2:int, param3:SagaSave) : void
      {
         var _loc4_:IGuiDialog = this.config.gameGuiContext.createDialog();
         var _loc5_:String = locale.translateGui("survival_reload_warning_title");
         var _loc6_:String = locale.translateGui("survival_reload_warning_body");
         var _loc7_:String = locale.translateGui("yes");
         var _loc8_:String = locale.translateGui("no");
         _loc6_ = performStringReplacement_SagaVar(_loc6_);
         this._survivalReloading = param3;
         _loc4_.openTwoBtnDialog(_loc5_,_loc6_,_loc7_,_loc8_,this._dialogSurvivalRenownCloseHandler);
      }
      
      private function _markSurvivalReloadRequired(param1:Boolean) : void
      {
         if(!isSurvival)
         {
            return;
         }
         if(profile_index < 0)
         {
            logger.error("GameSaga._markSurvivalReloadRequired impossible without a profile_index");
            return;
         }
         var _loc2_:SagaSave = saveManager.getMostRecentSaveInProfile(def.id,true,profile_index,isSurvival);
         if(!_loc2_)
         {
            logger.info("GameSaga.survivalReload no save available");
            return;
         }
         if(param1)
         {
            _loc2_.setVar(SagaVar.VAR_SURVIVAL_RELOAD_REQUIRED,param1);
         }
         else
         {
            _loc2_.setVar(SagaVar.VAR_SURVIVAL_RELOAD_REQUIRED,undefined);
         }
         logger.info("GameSaga._markSurvivalReloadRequired re-writing save with VAR_SURVIVAL_RELOAD_REQUIRED " + param1);
         saveManager.writeSave(_loc2_,profile_index,isSurvival);
      }
      
      private function _checkSurvivalConstituents() : void
      {
         var _loc5_:IEntityDef = null;
         var _loc6_:IEntityClassDef = null;
         if(!isSurvival)
         {
            return;
         }
         var _loc1_:IPartyDef = caravan.legend.party;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_.numMembers)
         {
            _loc5_ = _loc1_.getMember(_loc2_);
            if(_loc5_)
            {
               _loc6_ = _loc5_.entityClass;
               if(_loc6_.race != "varl")
               {
                  setVar("survival_nonvarl",true);
               }
               if(_loc6_.race != "human")
               {
                  setVar("survival_nonhuman",true);
               }
               if(_loc6_.gender != "female")
               {
                  setVar("survival_nonfemale",true);
               }
            }
            _loc2_++;
         }
         var _loc3_:int = getVarInt("survival_partymin");
         var _loc4_:int = getVarInt("survival_partymax");
         _loc3_ = Math.min(_loc3_,_loc1_.numMembers);
         _loc4_ = Math.max(_loc4_,_loc1_.numMembers);
         setVar("survival_partymin",_loc3_);
         setVar("survival_partymax",_loc4_);
      }
      
      private function _dialogSurvivalRenownCloseHandler(param1:*) : void
      {
         var _loc2_:SagaSave = this._survivalReloading;
         this._survivalReloading = null;
         if(!_loc2_)
         {
            logger.error("No _survivalReloading");
            return;
         }
         var _loc3_:String = locale.translateGui("yes");
         if(param1 != _loc3_)
         {
            return;
         }
         _loc2_.setVar(SagaVar.VAR_SURVIVAL_RELOAD_COUNT,_loc2_.survivalReloadCount + 1);
         _loc2_.setVar(SagaVar.VAR_SURVIVAL_RELOAD_REQUIRED,undefined);
         logger.info("GameSaga._showDialogSurvivalReloadWarning re-writing save with count " + _loc2_.survivalReloadCount);
         saveManager.writeSave(_loc2_,profile_index,isSurvival);
         logger.info("SURVIVAL reloading save");
         this.config.loadSaga(def.url,null,_loc2_,difficulty,profile_index,null,null,parentSagaUrl);
      }
      
      override public function get isShowingTutorialTooltips() : Boolean
      {
         return Boolean(this.config) && Boolean(this.config.tutorialLayer) && this.config.tutorialLayer.hasTooltips;
      }
      
      override public function showDialogSurvivalReloadLimitError(param1:int) : void
      {
         var _loc2_:IGuiDialog = this.config.gameGuiContext.createDialog();
         var _loc3_:String = locale.translateGui("survival_reload_limit_reached_title");
         var _loc4_:String = locale.translateGui("survival_reload_limit_reached_body");
         var _loc5_:String = locale.translateGui("ok");
         _loc4_ = performStringReplacement_SagaVar(_loc4_);
         _loc2_.openDialog(_loc3_,_loc4_,_loc5_);
      }
      
      override protected function handlePausedChanged() : void
      {
         if(Boolean(this.config) && Boolean(this.config.gameGuiContext))
         {
            this.config.gameGuiContext.notifySagaPausedChange();
         }
      }
      
      override public function ctorSceneLoader(param1:String, param2:Function) : SceneLoader
      {
         var _loc3_:SceneLoaderConfig = new SceneLoaderConfig(this.config.fsm,param2,null,null,null);
         return SceneLoadState.ctorSceneLoader(param1,_loc3_);
      }
      
      override public function quitToParentSaga() : Boolean
      {
         if(parentSagaUrl)
         {
            if(isStartScene)
            {
               logger.info("GameSaga [" + this + "] QUITTING sub-saga to " + parentSagaUrl);
               this.config.loadSaga(parentSagaUrl,null,null,difficulty,-1);
               return true;
            }
         }
         return false;
      }
   }
}

import engine.landscape.travel.def.TravelLocator;
import engine.landscape.travel.model.Travel;
import engine.landscape.travel.model.Travel_FallData;
import engine.landscape.travel.model.Travel_WipeData;
import game.saga.GameSaga;
import game.session.states.SceneState;

class SavedSceneState
{
    
   
   public var url:String;
   
   public var travel_locator:TravelLocator;
   
   public function SavedSceneState()
   {
      super();
   }
   
   public function saveDetails(param1:String, param2:TravelLocator = null) : void
   {
      this.clear();
      if(!param1)
      {
         return;
      }
      this.url = param1;
      this.travel_locator = !!param2 ? param2.clone() : null;
   }
   
   public function toString() : String
   {
      return this.url + ":" + this.travel_locator;
   }
   
   public function saveScene(param1:SceneState) : void
   {
      this.clear();
      if(!param1)
      {
         return;
      }
      this.url = param1.loader.url;
      var _loc2_:Travel = !!param1 ? param1.scene.landscape.travel : null;
      if(_loc2_)
      {
         this.saveDetails(this.url,new TravelLocator().setup(_loc2_.def.id,null,_loc2_.position));
      }
      else
      {
         this.saveDetails(this.url);
      }
   }
   
   public function clear() : void
   {
      this.url = null;
      this.travel_locator = null;
   }
   
   public function restore(param1:GameSaga) : String
   {
      var _loc2_:Travel_FallData = null;
      var _loc3_:Travel_WipeData = null;
      if(!this.url)
      {
         return null;
      }
      if(this.travel_locator)
      {
         param1.performTravelStart(this.url,this.travel_locator,_loc2_,_loc3_,null,false);
      }
      else
      {
         param1.performSceneStart(this.url,null,false);
      }
      return this.url;
   }
}
