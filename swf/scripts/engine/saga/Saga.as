package engine.saga
{
   import com.stoicstudio.platform.Platform;
   import com.stoicstudio.platform.PlatformInput;
   import engine.achievement.AchievementDef;
   import engine.achievement.AchievementListDef;
   import engine.battle.ability.def.BattleAbilityDefFactory;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.BattleObjective;
   import engine.battle.board.model.BattleScenarioDef;
   import engine.battle.board.model.BattleSnapshot;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.fsm.BattleFinishedData;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleFsmConfig;
   import engine.battle.fsm.IBattleFsm;
   import engine.battle.fsm.aimodule.AiGlobalConfig;
   import engine.battle.sim.IBattleParty;
   import engine.core.BoxString;
   import engine.core.analytic.Ga;
   import engine.core.analytic.LocMon;
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleInfo;
   import engine.core.logging.ILogger;
   import engine.core.util.AppInfo;
   import engine.core.util.ArrayUtil;
   import engine.core.util.ColorUtil;
   import engine.core.util.StringUtil;
   import engine.entity.UnitStatCosts;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import engine.entity.def.ILegend;
   import engine.entity.def.IPartyDef;
   import engine.entity.def.ITitleDef;
   import engine.entity.def.Item;
   import engine.entity.def.ItemDef;
   import engine.entity.def.ItemListDef;
   import engine.entity.def.LegendEvent;
   import engine.landscape.def.LandscapeSplineDef;
   import engine.landscape.def.LandscapeSplinePoint;
   import engine.landscape.travel.def.CartDef;
   import engine.landscape.travel.def.TravelLocator;
   import engine.landscape.travel.model.Travel;
   import engine.landscape.travel.model.Travel_FallData;
   import engine.landscape.travel.model.Travel_WipeData;
   import engine.landscape.view.LandscapeViewConfig;
   import engine.math.MathUtil;
   import engine.math.Rng;
   import engine.math.RngSampler_SeedArray;
   import engine.resource.ResourceManager;
   import engine.saga.action.Action;
   import engine.saga.action.ActionDef;
   import engine.saga.action.ActionType;
   import engine.saga.action.Action_Battle;
   import engine.saga.action.IActionListener;
   import engine.saga.convo.Convo;
   import engine.saga.convo.ConvoEvent;
   import engine.saga.convo.def.audio.ConvoAudioListDef;
   import engine.saga.happening.Happening;
   import engine.saga.happening.HappeningDef;
   import engine.saga.happening.IHappening;
   import engine.saga.happening.IHappeningDefProvider;
   import engine.saga.happening.IHappeningProvider;
   import engine.saga.save.CaravanSave;
   import engine.saga.save.SagaSave;
   import engine.saga.save.SaveManager;
   import engine.saga.vars.IBattleEntityProvider;
   import engine.saga.vars.IVariable;
   import engine.saga.vars.IVariableBag;
   import engine.saga.vars.IVariableProvider;
   import engine.saga.vars.Variable;
   import engine.saga.vars.VariableBag;
   import engine.saga.vars.VariableDef;
   import engine.saga.vars.VariableEvent;
   import engine.saga.vars.VariableType;
   import engine.scene.def.SceneDef;
   import engine.scene.def.SceneDefVars;
   import engine.scene.model.Scene;
   import engine.scene.model.SceneLoader;
   import engine.scene.model.SceneLoaderBattleInfo;
   import engine.sound.ISoundDefBundle;
   import engine.sound.config.ISoundSystem;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   import engine.stat.model.Stats;
   import engine.subtitle.Ccs;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileRect;
   import engine.user.UserLifecycleManager;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   
   public class Saga extends EventDispatcher implements ISaga, ISagaCaravanProvider, IVariableProvider, IHappeningProvider, IVariableDefProvider, ISagaCastProvider, IBattleBoardProvider, IBattleEntityProvider
   {
      
      public static const crownIconUrl:String = "common/battle/banner/crown/crown_iron1.png";
      
      public static var PROFILE_ENABLED:Boolean = true;
      
      public static var SKIP_LOCATION_TRIGGERS:Boolean;
      
      public static const BIOME_SNOW:int = 1;
      
      public static const BIOME_FOREST:int = 2;
      
      public static const DIFFICULTY_NORMAL:int = 2;
      
      public static const DIFFICULTY_EASY:int = 1;
      
      public static const DIFFICULTY_HARD:int = 3;
      
      public static var ALLOW_SAVE:Boolean = true;
      
      public static var ALLOW_AUTOSAVE:Boolean = true;
      
      public static var ONLY_UNLOCK_PROGRESS_ACHIEVMENT_LOCALLY:Boolean = false;
      
      public static const SAVE_ID_RESUME:String = "resume";
      
      private static var VAR_PRG_BATTLES_FOUGHT:String = "prg_battles_fought";
      
      public static var VAR_PRG_BATTLES_WON:String = "prg_battles_won";
      
      public static var VAR_PRG_BATTLES_LOST:String = "prg_battles_lost";
      
      public static var VAR_PRG_WARS_LOST:String = "prg_wars_lost";
      
      private static var VAR_PRG_ITEMS_GAINED_:String = "prg_items_gained_";
      
      private static var VAR_PRG_MIN_DIFFICULTY:String = "prg_min_difficulty";
      
      private static var VAR_PRG_MIN_MORALE_CATEGORY:String = "prg_min_morale_category";
      
      private static var VAR_PREVIEWBUILD:String = "previewbuild";
      
      public static var RNG_SEED_OVERRIDE:Number = NaN;
      
      public static var instance:Saga;
      
      public static var PROFILE_COUNT:int = 5;
      
      private static const VAR_STARVING:String = "starving";
      
      private static const VAR_PRG_STARVATION_COUNT:String = "prg_starvation_count";
      
      public static var HEAL_INJURIES_REQUIRES_CAMPING:Boolean = true;
      
      public static const HAPPENING_ID_WAIT:String = "_gameDevWait";
      
      public static var QAACV:Boolean;
      
      public static var GA_CUSTOM_DIM_SCENE:int = 4;
      
      public static var GA_CUSTOM_DIM_DIFFICULTY:int = 1;
      
      private static var _difficulty_colors:Array = [16777215,8693854,6333635,11624794];
      
      public static var BUCKET_TRAINING:String = "training";
      
      public static var BUCKET_TRAINING_VARL:String = "training_varl";
      
      public static var BUCKET_TRAINING_HUMAN:String = "training_human";
      
      private static var _moraleIconUrls:Array = ["common/battle/morale/morale_button_low.png","common/battle/morale/morale_button_medlow.png","common/battle/morale/morale_button_med.png","common/battle/morale/morale_button_medhigh.png","common/battle/morale/morale_button_high.png"];
       
      
      public var survival:SagaSurvival;
      
      public var caravans:Dictionary;
      
      private var _caravan:Caravan;
      
      public var def:SagaDef;
      
      public var actions:Vector.<Action>;
      
      public var resman:ResourceManager;
      
      public var _logger:ILogger;
      
      public var started:Boolean;
      
      public var happenings:Dictionary;
      
      public var saveManager:SaveManager;
      
      private var _camped:Boolean;
      
      private var _halting:int;
      
      private var _halted:Boolean;
      
      public var haltLocation:String;
      
      private var _haltToCamp:Boolean;
      
      public var happeningDefProviders:Vector.<IHappeningDefProvider>;
      
      public var shell:SagaShellCmdManager;
      
      private var _resting:Boolean;
      
      private var _showCaravan:Boolean = true;
      
      private var _waitForHalt:int;
      
      private var _loadedCallback:Function;
      
      private var _loaded:Boolean;
      
      private var _mapCamp:Boolean;
      
      private var _hudMapEnabled:Boolean = true;
      
      private var _hudCampEnabled:Boolean = true;
      
      private var _cameraPanning:int = 0;
      
      private var _caravanCameraLock:Boolean = true;
      
      private var _suppressVariableFlytext:Boolean;
      
      private var _globalSuppressVariableFlytext:Boolean;
      
      public var market:SagaMarket;
      
      public var sceneUrl:String;
      
      public var sceneLoaded:Boolean;
      
      public var travelLocator:TravelLocator;
      
      public var travelDrivingSpeed:Number = 1;
      
      public var abilityFactory:BattleAbilityDefFactory;
      
      public var skipNextSave:Boolean;
      
      public var _rng:Rng;
      
      public var campSeed:int = 0;
      
      private var _convo:Convo;
      
      private var convoSceneUrl:String;
      
      public var appinfo:AppInfo;
      
      public var metrics:SagaMetrics;
      
      private var playTimer:Timer;
      
      private var locationTimer:Timer;
      
      public var _sound:SagaSound;
      
      public var firstBuildVersion:String;
      
      public var date_start:Date;
      
      public var last_item_id:int = 0;
      
      private var _battleMusicDefUrl:String;
      
      public var campMusic:SagaCampMusic;
      
      public var _expression:SagaExpression;
      
      private var _profile_index:int = -1;
      
      public var pageView:String;
      
      public var lastPlayMinutes:int = 0;
      
      public var lastDay:int = 0;
      
      public var _locale:Locale;
      
      public var startHappening:String;
      
      public var imported:SagaSave;
      
      public var selectedVariable:String;
      
      public var battleItemsDisabled:Boolean;
      
      public var lastChapterSaveId:String;
      
      public var lastCheckpointSaveId:String;
      
      public var masterSave:Object;
      
      public var masterSaveChildren:Dictionary;
      
      public var slog:SagaLog;
      
      public var ccs:Ccs;
      
      private var _triggerMMAAchievementOnBattleFinish:Boolean = false;
      
      public var _scenePreprocessor:SagaScenePreprocessor;
      
      public var sagaAssetBundles:SagaAssetBundles;
      
      public var parentSagaUrl:String;
      
      public var isProcessingActionTween:Boolean = false;
      
      public var _vars:SagaVariableProvider;
      
      private var flyInfos:Dictionary;
      
      private var _globalSuppressTriggerVariableResponse:Boolean;
      
      public var cleanedup:Boolean;
      
      public var startPageWithMusic:Boolean = true;
      
      private var _prereqReason:BoxString;
      
      private var _nextTurnBeginHappenings:Vector.<Happening>;
      
      public var videoReturnsToStartScene:Boolean;
      
      public var _endingAllHappenings:Boolean;
      
      private var _pauses:Array;
      
      private var campTalkies:Dictionary;
      
      private var rest_start_wallclock:int;
      
      private var rest_start_day:Number;
      
      private var rest_end_day:Number;
      
      private var rest_speed:Number = 0.001;
      
      private var restTimer:Timer;
      
      public var mapCampAnchor:String;
      
      public var mapCampSpline:String;
      
      public var mapCampSplineT:Number = 0;
      
      public var _mapCampCinema:Boolean;
      
      protected var _suppressSceneStateSave:Boolean;
      
      public var cannotSaveReason:String;
      
      private var queuedRng:Object;
      
      private var mapSplinePt:Point;
      
      private var trainingBucket:SagaBucket;
      
      public var inTrainingBattle:Boolean;
      
      private var _battleSnaps:Dictionary;
      
      public function Saga(param1:SagaDef, param2:ISoundSystem, param3:ResourceManager, param4:ILogger, param5:BattleAbilityDefFactory, param6:AppInfo, param7:Boolean, param8:Ccs, param9:Locale, param10:SaveManager)
      {
         this.rest_speed = 0.001;
         this.rest_speed = 0.001;
         this.rest_speed = 0.001;
         this.rest_speed = 0.001;
         this.rest_speed = 0.001;
         this.rest_speed = 0.001;
         this.rest_speed = 0.001;
         this.rest_speed = 0.001;
         var _loc12_:CaravanDef = null;
         var _loc13_:IEntityDef = null;
         var _loc14_:Caravan = null;
         this.caravans = new Dictionary();
         this.actions = new Vector.<Action>();
         this.happenings = new Dictionary();
         this.happeningDefProviders = new Vector.<IHappeningDefProvider>();
         this.travelLocator = new TravelLocator();
         this.playTimer = new Timer(60 * 1000,0);
         this.locationTimer = new Timer(15 * 60 * 1000,0);
         this.date_start = new Date();
         this.masterSaveChildren = new Dictionary();
         this._prereqReason = new BoxString();
         this._nextTurnBeginHappenings = new Vector.<Happening>();
         this._pauses = [];
         this.campTalkies = new Dictionary();
         this.mapSplinePt = new Point();
         this._battleSnaps = new Dictionary();
         super();
         instance = this;
         SagaInstance.setSaga(this);
         SagaCheat.instance = this;
         this._locale = param9;
         this.def = param1;
         this.resman = param3;
         this._logger = param4;
         this.slog = new SagaLog(param4);
         this.abilityFactory = param5;
         this.appinfo = param6;
         this.metrics = new SagaMetrics(this);
         this._sound = new SagaSound(this,param2);
         this.firstBuildVersion = param6.buildVersion;
         this.ccs = param8;
         param8.reset();
         this.saveManager = param10;
         this._expression = new SagaExpression(this,this.logger);
         this._scenePreprocessor = new SagaScenePreprocessor(this);
         this.sagaAssetBundles = new SagaAssetBundles(this,param3);
         this._vars = new SagaVariableProvider("saga",param1,this,this,this,this.slog,param4);
         this._checkDevCheatInit();
         this._setupRNG();
         var _loc11_:int = 0;
         while(_loc11_ < param1.cast.numEntityDefs)
         {
            _loc13_ = param1.cast.getEntityDef(_loc11_);
            if(_loc13_.talents)
            {
            }
            _loc11_++;
         }
         if(param1.minPlayerUnitRank)
         {
            SagaImportDef.doApplyMinimumRank(this,param1.minPlayerUnitRank);
         }
         this.campMusic = new SagaCampMusic(this);
         this._applyForceVars();
         for each(_loc12_ in param1.caravans)
         {
            _loc14_ = new Caravan(this,_loc12_,param5);
            this.caravans[_loc12_.name] = _loc14_;
         }
         this.shell = new SagaShellCmdManager(param4,this,param7);
         this.market = new SagaMarket(this);
         this._globalSuppressVariableFlytext = true;
         this._globalSuppressTriggerVariableResponse = true;
         this._globalSuppressVariableFlytext = true;
         this.listenToVars();
         this._globalSuppressVariableFlytext = false;
         this._globalSuppressTriggerVariableResponse = false;
         this._globalSuppressVariableFlytext = false;
         this.addHappeningDefProvider(param1.happenings);
         LandscapeViewConfig.disableClickables = false;
         LandscapeViewConfig.forceTooltips = false;
         this.playTimer.addEventListener(TimerEvent.TIMER,this.playTimerHandler);
         this.playTimer.start();
         this.locationTimer.addEventListener(TimerEvent.TIMER,this.locationTimerHandler);
         this.locationTimer.start();
         this.setVar(SagaVar.VAR_GP,PlatformInput.lastInputGp);
         SagaAchievements.setSaga(this);
         SagaIap.setSaga(this);
         UserLifecycleManager.Instance().Initialize(this);
         if(param9)
         {
            this.setVar(SagaVar.VAR_LANG,param9.id.id);
         }
         if(param1.survival)
         {
            this.survival = new SagaSurvival(param1.survival);
         }
      }
      
      public static function getDifficultyColor(param1:int) : uint
      {
         if(param1 < 0 || param1 >= _difficulty_colors.length)
         {
            return 16711935;
         }
         return _difficulty_colors[param1];
      }
      
      public static function getMapSplinePoint(param1:Saga, param2:Point, param3:SceneDef) : void
      {
         var _loc11_:LandscapeSplinePoint = null;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc4_:String = param1.caravan.map_spline_id;
         var _loc5_:LandscapeSplineDef = param3.landscape.getSplineDef(_loc4_);
         if(!_loc5_)
         {
            return;
         }
         var _loc6_:Number = 0;
         var _loc7_:Number = 1;
         var _loc8_:* = -1;
         if(param1.caravan.map_spline_key)
         {
            _loc11_ = _loc5_.getKeyPointById(param1.caravan.map_spline_key);
            if(_loc11_)
            {
               _loc12_ = _loc5_.getIndexOfPoint(_loc11_);
               _loc6_ = _loc5_.spline.getPointParameter(_loc12_);
               _loc8_ = _loc11_.keyIndex;
            }
         }
         var _loc9_:LandscapeSplinePoint = _loc5_.getAKeyPointByIndex(_loc8_ + 1);
         if(_loc9_)
         {
            _loc13_ = _loc5_.getIndexOfPoint(_loc9_);
            _loc7_ = _loc5_.spline.getPointParameter(_loc13_);
         }
         var _loc10_:Number = MathUtil.lerp(_loc6_,_loc7_,param1.caravan.map_spline_t);
         _loc5_.spline.sample(_loc10_,param2);
      }
      
      override public function toString() : String
      {
         return !!this.def ? this.def.id : "unknown";
      }
      
      private function _applyForceVars() : void
      {
         var _loc1_:* = null;
         var _loc2_:* = undefined;
         if(SagaConfig.FORCE_VARS)
         {
            for(_loc1_ in SagaConfig.FORCE_VARS)
            {
               _loc2_ = SagaConfig.FORCE_VARS[_loc1_];
               this.logger.info("Saga setting FORCE_VAR [" + _loc1_ + "] = [" + _loc2_ + "]");
               this.setVar(_loc1_,_loc2_);
            }
         }
         if(SagaDef.PREVIEW_BUILD)
         {
            this.setVar(VAR_PREVIEWBUILD,true);
         }
      }
      
      private function _checkDevCheatInit() : void
      {
         if(AiGlobalConfig.EAGER)
         {
            SagaCheat.devCheat("AiConfig.EAGER");
         }
         if(AiGlobalConfig.UNWILLING)
         {
            SagaCheat.devCheat("AiConfig.UNWILLING");
         }
         if(!BattleFsmConfig.globalEnableAi)
         {
            SagaCheat.devCheat("!BattleFsmConfig.globalEnableAi");
         }
         if(BattleFsmConfig.globalPlayerAi)
         {
            SagaCheat.devCheat("BattleFsmConfig.globalPlayerAi");
         }
      }
      
      private function _setupRNG() : void
      {
         var _loc1_:int = new Date().time;
         if(!isNaN(RNG_SEED_OVERRIDE))
         {
            _loc1_ = int(RNG_SEED_OVERRIDE);
         }
         this._rng = new Rng(new RngSampler_SeedArray(_loc1_),this.logger);
         this._logger.i("RNG","RNG seed set to: " + _loc1_);
      }
      
      private function checkLocaleVars() : void
      {
         this.setVar(SagaVar.VAR_LOCALE_EN,this._locale && this._locale.isEn);
         if(this.locale)
         {
            this.setVar(SagaVar.VAR_LANG,this.locale.id.id);
         }
      }
      
      public function changeLocale(param1:Locale) : void
      {
         this._locale = param1;
         this.flyInfos = null;
         this.def.changeLocale(param1);
         var _loc2_:BattleBoard = this.getBattleBoard();
         if(_loc2_)
         {
            _loc2_.changeLocale(param1);
         }
         this.checkLocaleVars();
         dispatchEvent(new Event(SagaEvent.EVENT_LOCALE));
      }
      
      private function playTimerHandler(param1:TimerEvent) : void
      {
         if(this.paused)
         {
            if(!this.convo || !this.convo.finished)
            {
               return;
            }
         }
         var _loc2_:IVariable = this._vars._global.fetch(SagaVar.VAR_PLAY_MINUTES,VariableType.INTEGER);
         var _loc3_:int = _loc2_.asInteger + 1;
         _loc2_.asInteger = _loc3_;
      }
      
      private function locationTimerHandler(param1:TimerEvent) : void
      {
         LocMon.notify(this.mapSplinePt.x,this.mapSplinePt.y);
      }
      
      public function get gameSceneUrl() : String
      {
         return null;
      }
      
      public function get gameConvoUrl() : String
      {
         return null;
      }
      
      public function loadSagaResources(param1:Function) : void
      {
         this._loadedCallback = param1;
         this.sound.loadSagaSoundResources(this.soundReadyHandler);
      }
      
      public function launchSagaByUrl(param1:String, param2:String, param3:int, param4:String) : void
      {
      }
      
      private function soundReadyHandler(param1:SagaSound) : void
      {
         this.logger.info("Saga.soundReadyHandler " + param1);
         this.checkLoaded();
      }
      
      private function checkLoaded() : void
      {
         var _loc1_:Function = null;
         if(this._loaded)
         {
            return;
         }
         if(!this.def)
         {
            this.logger.info("Saga.checkLoaded NOPE !def");
            return;
         }
         if(!this.sound.loaded)
         {
            this.logger.info("Saga.checkLoaded NOPE !sound.loaded");
            return;
         }
         this.logger.info("Saga.checkLoaded YEP");
         this._loaded = true;
         if(this._loadedCallback != null)
         {
            _loc1_ = this._loadedCallback;
            this._loadedCallback = null;
            _loc1_(this);
         }
      }
      
      public function performGuiDialog(param1:String, param2:String, param3:String, param4:String, param5:Function) : void
      {
      }
      
      public function performClearGuiDialog() : void
      {
      }
      
      public function performTutorialRemoveAll(param1:String) : void
      {
      }
      
      public function performTutorialRemove(param1:int) : void
      {
      }
      
      public function get isShowingTutorialTooltips() : Boolean
      {
         return false;
      }
      
      public function performTutorialPopup(param1:String, param2:String, param3:int, param4:String, param5:Boolean, param6:Boolean, param7:int, param8:Function) : int
      {
         return 0;
      }
      
      public function performPartyRequiredChanged(param1:IEntityDef) : void
      {
         var _loc2_:Caravan = null;
         if(param1.partyRequired)
         {
            for each(_loc2_ in this.caravans)
            {
               _loc2_.ensureUnitInParty(param1);
            }
         }
      }
      
      public function performSoundPlayScene(param1:String) : void
      {
      }
      
      public function performSoundPlayEventScene(param1:String, param2:String, param3:String, param4:Number, param5:ISoundDefBundle = null) : void
      {
      }
      
      public function performEndCredits(param1:SagaCreditsDef, param2:Boolean, param3:Boolean) : void
      {
      }
      
      public function handleCreditsComplete() : Boolean
      {
         return false;
      }
      
      public function performDarknessGuiTransition() : void
      {
      }
      
      public function performTalkChanged(param1:IEntityDef) : void
      {
         dispatchEvent(new Event(SagaEvent.EVENT_TALK));
      }
      
      private function listenToCastVars() : void
      {
         var _loc1_:int = 0;
         var _loc2_:IEntityDef = null;
         var _loc3_:VariableBag = null;
         if(this.def.cast)
         {
            _loc1_ = 0;
            while(_loc1_ < this.def.cast.numEntityDefs)
            {
               _loc2_ = this.def.cast.getEntityDef(_loc1_);
               if(!_loc2_.entityClass)
               {
                  this.logger.error("Saga.listenToCastVars Entity has no class: " + _loc2_);
               }
               else
               {
                  _loc3_ = _loc2_.vars as VariableBag;
                  if(_loc3_)
                  {
                     _loc3_.initMetricsVariables(this.metrics);
                     _loc3_.addEventListener(VariableEvent.TYPE,this.castTalkHandler);
                  }
               }
               _loc1_++;
            }
         }
      }
      
      private function unlistenToCastVars() : void
      {
         var _loc1_:int = 0;
         var _loc2_:IEntityDef = null;
         var _loc3_:VariableBag = null;
         if(this.def.cast)
         {
            _loc1_ = 0;
            while(_loc1_ < this.def.cast.numEntityDefs)
            {
               _loc2_ = this.def.cast.getEntityDef(_loc1_);
               _loc3_ = _loc2_.vars as VariableBag;
               if(_loc3_)
               {
                  _loc3_.removeEventListener(VariableEvent.TYPE,this.castTalkHandler);
               }
               _loc1_++;
            }
         }
      }
      
      private function castTalkHandler(param1:VariableEvent) : void
      {
         if(this._globalSuppressTriggerVariableResponse)
         {
            return;
         }
         var _loc2_:IEntityDef = param1.value.bag.owner as IEntityDef;
         if(!_loc2_)
         {
            return;
         }
         if(param1.value.def.name == SagaVar.VAR_UNIT_TALK)
         {
            this.performTalkChanged(_loc2_);
         }
         else if(param1.value.def.name == SagaVar.VAR_UNIT_PARTY_REQUIRED)
         {
            this.performPartyRequiredChanged(_loc2_);
         }
      }
      
      private function listenToVars() : void
      {
         var _loc1_:Caravan = null;
         this.listenToCastVars();
         for each(_loc1_ in this.caravans)
         {
            (_loc1_.vars as VariableBag).initMetricsVariables(this.metrics);
            _loc1_.vars.addEventListener(VariableEvent.TYPE,this.triggerVariableHandler);
         }
         this.initVars();
         this._vars.listenToVars(this.triggerGlobalVariableHandler,this.metrics,this.triggerVariableHandler);
      }
      
      private function initVars() : void
      {
         if(this.def.dlcs)
         {
            this.def.dlcs.applyDlcs(this,this.appinfo);
         }
         this.checkLocaleVars();
         this.checkCensorVars();
      }
      
      private function checkCensorVars() : void
      {
         var _loc1_:String = !!this.resman ? this.resman.censorId : null;
         if(!_loc1_)
         {
            this.logger.i("CENS","Saga null censor id, no variable possible");
            return;
         }
         this.setVar(SagaVar.PREFIX_CENSOR + _loc1_,true);
      }
      
      private function unlistenToVars() : void
      {
         var _loc1_:Caravan = null;
         this.unlistenToCastVars();
         for each(_loc1_ in this.caravans)
         {
            _loc1_.vars.removeEventListener(VariableEvent.TYPE,this.triggerVariableHandler);
         }
         this._vars.unlistenToVars();
      }
      
      public function handleHudHornEnabled() : void
      {
      }
      
      final public function handleHudMapEnabled() : void
      {
         dispatchEvent(new Event(SagaEvent.EVENT_HUD_MAP_ENABLED));
      }
      
      final public function handleHudCampEnabled() : void
      {
         dispatchEvent(new Event(SagaEvent.EVENT_HUD_CAMP_ENABLED));
      }
      
      final public function handleHudTravelEnabled() : void
      {
         dispatchEvent(new Event(SagaEvent.EVENT_HUD_TRAVEL_ENABLED));
      }
      
      final public function handleHudTravelHidden() : void
      {
         dispatchEvent(new Event(SagaEvent.EVENT_HUD_TRAVEL_HIDDEN));
      }
      
      final public function handleGameProgressUpdated() : void
      {
         var _loc1_:IVariable = this.getVar(SagaVar.VAR_GAME_PROGRESS,VariableType.INTEGER);
         SagaHeroStats.setProgress(_loc1_.asInteger);
      }
      
      final public function handleBattleWon() : void
      {
         SagaHeroStats.incrementStat("battles_won");
      }
      
      private function cacheFlyInfos() : void
      {
         if(this.flyInfos)
         {
            return;
         }
         this.flyInfos = new Dictionary();
         this.cacheFlyInfo(SagaVar.VAR_MORALE,"fly_morale_up","fly_morale_down",13546446,null,null);
         this.cacheFlyInfo(SagaVar.VAR_SUPPLIES,"fly_supplies","fly_supplies",13546336,null,null);
         this.cacheFlyInfo(SagaVar.VAR_RENOWN,"fly_renown","fly_renown",12410196,null,null);
         this.cacheFlyInfo(SagaVar.VAR_NUM_PEASANTS,"fly_clansmen","fly_clansmen",6473149,null,"ui_dying_peasants");
         this.cacheFlyInfo(SagaVar.VAR_NUM_FIGHTERS,"fly_fighters","fly_fighters",6473149,null,"ui_dying_fighters");
         this.cacheFlyInfo(SagaVar.VAR_NUM_VARL,"fly_varl","fly_varl",6473149,null,"ui_dying_fighters");
      }
      
      private function cacheFlyInfo(param1:String, param2:String, param3:String, param4:uint, param5:String, param6:String) : FlyInfo
      {
         var _loc7_:FlyInfo = new FlyInfo(this.locale,param1,param2,param3,param4,param5,param6);
         this.flyInfos[param1] = _loc7_;
         return _loc7_;
      }
      
      private function triggerGlobalVariableHandler(param1:VariableEvent) : void
      {
         if(this._globalSuppressTriggerVariableResponse)
         {
            return;
         }
         this.triggerVariableHandler(param1);
         switch(param1.value.def.name)
         {
            case SagaVar.VAR_HUD_HORN_ENABLED:
               this.handleHudHornEnabled();
               break;
            case SagaVar.VAR_HUD_MAP_ENABLED:
               this.handleHudMapEnabled();
               break;
            case SagaVar.VAR_HUD_CAMP_ENABLED:
               this.handleHudCampEnabled();
               break;
            case SagaVar.VAR_HUD_TRAVEL_ENABLED:
               this.handleHudTravelEnabled();
               break;
            case SagaVar.VAR_HUD_TRAVEL_HIDDEN:
               this.handleHudTravelHidden();
               break;
            case SagaVar.VAR_GAME_PROGRESS:
               this.handleGameProgressUpdated();
               break;
            case VAR_PRG_BATTLES_WON:
               this.handleBattleWon();
         }
      }
      
      private function emitPopulationChangedPlatformEvent() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:IVariable = this.getVar(SagaVar.VAR_NUM_PEASANTS,VariableType.INTEGER);
         if(_loc4_)
         {
            _loc1_ = int(_loc4_.asInteger);
         }
         _loc4_ = this.getVar(SagaVar.VAR_NUM_FIGHTERS,VariableType.INTEGER);
         if(_loc4_)
         {
            _loc2_ = int(_loc4_.asInteger);
         }
         _loc4_ = this.getVar(SagaVar.VAR_NUM_VARL,VariableType.INTEGER);
         if(_loc4_)
         {
            _loc3_ = int(_loc4_.asInteger);
         }
         var _loc5_:int = _loc1_ + _loc2_ + _loc3_;
         this.logger.info("    %%%% Updating caravan size stat");
         SagaHeroStats.setStat("caravan_size",_loc5_);
      }
      
      private function triggerVariableHandler(param1:VariableEvent) : void
      {
         var _loc6_:Boolean = false;
         var _loc11_:FlyInfo = null;
         var _loc12_:String = null;
         var _loc13_:String = null;
         var _loc14_:String = null;
         var _loc15_:Caravan = null;
         var _loc16_:String = null;
         var _loc17_:AchievementDef = null;
         if(this._endingAllHappenings)
         {
            return;
         }
         var _loc2_:Variable = param1.value;
         if(this._globalSuppressTriggerVariableResponse)
         {
            this.notifyVarGaCustoms(_loc2_);
            return;
         }
         var _loc3_:* = _loc2_.asInteger;
         var _loc4_:int = int(param1.oldValue);
         var _loc5_:String = _loc2_.def.name;
         if(_loc3_ != _loc4_)
         {
            if(_loc5_ == SagaVar.VAR_NUM_FIGHTERS || _loc5_ == SagaVar.VAR_NUM_VARL || _loc5_ == SagaVar.VAR_NUM_FIGHTERS)
            {
               this.emitPopulationChangedPlatformEvent();
            }
            if(!this.suppressVariableFlytext && !this._globalSuppressVariableFlytext)
            {
               if(this.isSurvival || !this.hudTravelHidden || Boolean(this.convo))
               {
                  this.cacheFlyInfos();
                  _loc11_ = this.flyInfos[_loc5_];
                  if(_loc11_)
                  {
                     if(_loc3_ < _loc4_)
                     {
                        _loc12_ = _loc11_.labelDown;
                        _loc13_ = _loc11_.soundIdDown;
                     }
                     else
                     {
                        _loc12_ = _loc11_.labelUp;
                        _loc13_ = _loc11_.soundIdUp;
                     }
                     _loc14_ = StringUtil.numberWithSign(_loc3_ - _loc4_,0).toString();
                     _loc12_ = _loc12_.replace("$NUM",_loc14_);
                     if(this.soundDaySuppressed)
                     {
                        _loc13_ = null;
                     }
                     this.showFlyText(_loc12_,_loc11_.color,_loc13_,_loc11_.linger);
                  }
               }
            }
            if(_loc5_ == SagaVar.VAR_AUDIO_FORCE_ENABLE_DISABLE)
            {
               this.sound.system.mixer.videoMixerMode = _loc3_ != 0;
            }
            if(_loc2_.def.name == SagaVar.VAR_RENOWN)
            {
               if(_loc3_ > _loc4_)
               {
                  this.incrementGlobalVar("prg_renown_gain",_loc3_ - _loc4_);
               }
               for each(_loc15_ in this.caravans)
               {
                  if(_loc15_.vars == _loc2_.bag)
                  {
                     _loc15_._legend.renown = _loc3_;
                     if(_loc3_ > _loc4_)
                     {
                        _loc15_.vars.incrementVar("tot_renown_gained",_loc3_ - _loc4_);
                     }
                     else
                     {
                        _loc15_.vars.incrementVar("tot_renown_spent",_loc4_ - _loc3_);
                     }
                     break;
                  }
               }
            }
         }
         var _loc7_:* = _loc2_._def.type == VariableType.DECIMAL;
         var _loc8_:* = _loc2_.asNumber;
         var _loc9_:Number = Number(param1.oldValue);
         if(_loc3_ > _loc4_)
         {
            if(_loc2_.def.name == SagaVar.VAR_DAY)
            {
               if(this.getVarBool(SagaVar.VAR_DAY_LOGIC_SUPPRESS))
               {
                  this.logger.info("VAR_DAY_LOGIC_SUPPRESS skipping day logic for change from " + _loc4_ + " to " + _loc3_);
                  return;
               }
               this.healInjuries(_loc3_ - _loc4_);
               this.setVar("_day_calc_count",_loc3_ - _loc4_);
            }
            this.triggerVariableIncrement(_loc2_,_loc4_);
            this.triggerVariableThresholdUp(_loc2_,_loc4_);
            if(_loc2_.def.name == SagaVar.VAR_DAY)
            {
               _loc6_ = this.getVarBool(VAR_STARVING);
               if(_loc6_)
               {
                  _loc16_ = this.mapCampSpline;
                  if(!_loc16_)
                  {
                     _loc16_ = StringUtil.getBasename(this.sceneUrl);
                  }
                  if(_loc6_)
                  {
                     Ga.normal("game","starve",_loc16_,_loc3_ - _loc4_);
                     if(this._caravan)
                     {
                        this._caravan.vars.incrementVar("tot_starvation_days",_loc3_ - _loc4_);
                     }
                  }
               }
            }
         }
         else if(!_loc7_ && _loc3_ < _loc4_ || _loc7_ && Math.ceil(_loc9_) > Math.ceil(_loc8_))
         {
            this.triggerVariableIncrement(_loc2_,!!_loc7_ ? _loc9_ : _loc4_);
            this.triggerVariableThresholdDown(_loc2_,!!_loc7_ ? _loc9_ : _loc4_);
            _loc6_ = this.getVarBool(VAR_STARVING);
            if(_loc6_ && this.caravan && this.caravan.def.saves)
            {
               if(_loc5_ == SagaVar.VAR_NUM_FIGHTERS || _loc5_ == SagaVar.VAR_NUM_PEASANTS || _loc5_ == SagaVar.VAR_NUM_VARL)
               {
                  this.incrementGlobalVar(VAR_PRG_STARVATION_COUNT,_loc4_ - _loc3_);
                  if(this._caravan)
                  {
                     this._caravan.vars.incrementVar("tot_starvation_deaths",_loc4_ - _loc3_);
                  }
               }
            }
         }
         if(_loc3_ != _loc4_)
         {
            this.notifySagaMetrics(_loc2_,_loc4_);
            this.notifyVarGaEvents(_loc2_);
            if(_loc2_.def.name == SagaVar.VAR_MORALE_CATEGORY)
            {
               this._vars.checkMinGlobal(VAR_PRG_MIN_MORALE_CATEGORY,_loc2_.fullname);
            }
         }
         var _loc10_:Vector.<AchievementDef> = this.def.achievements.getAchievementDefsForProgressVar(_loc2_.def.name);
         if(_loc10_)
         {
            for each(_loc17_ in _loc10_)
            {
               if(_loc17_.progressCount <= _loc3_)
               {
                  if(!this.getVarBool(_loc17_.id + "_unlk"))
                  {
                     this.logger.info("Local prg_class acv awarded: " + _loc17_.id);
                     if(Saga.ONLY_UNLOCK_PROGRESS_ACHIEVMENT_LOCALLY)
                     {
                        SagaAchievements.unlockAchievementLocal(_loc17_,this.minutesPlayed);
                     }
                     else
                     {
                        SagaAchievements.unlockAchievement(_loc17_,this.minutesPlayed,true);
                     }
                  }
                  else
                  {
                     this.logger.info("Local prg_class acv suppressed: " + _loc17_.id);
                  }
               }
            }
         }
      }
      
      public function showFlyText(param1:String, param2:uint, param3:String, param4:Number) : void
      {
         if(this._endingAllHappenings)
         {
            return;
         }
         dispatchEvent(new ScreenFlyTextEvent(param1,param2,param3,param4));
      }
      
      private function notifyAllGas() : void
      {
         var _loc1_:Variable = null;
         this._vars.forEachVar(this.notifyVarGaCustoms);
         if(this.caravan)
         {
            for each(_loc1_ in this.caravan.vars.vars)
            {
               this.notifyVarGaCustoms(_loc1_);
            }
         }
         this._vars.forEachVar(this.notifyVarGaEvents);
         if(Boolean(this.caravan) && !this.caravan.def.disable_metrics)
         {
            for each(_loc1_ in this.caravan.vars.vars)
            {
               this.notifyVarGaEvents(_loc1_);
            }
         }
      }
      
      private function notifyVarGaCustoms(param1:Variable) : void
      {
         if(param1.def.type == VariableType.STRING)
         {
            if(param1.def.ga_custom_dimension)
            {
               Ga.setCustomDimension(param1.def.ga_custom_dimension,param1.asString);
            }
            return;
         }
         var _loc2_:* = param1.asInteger;
         if(param1.def.ga_custom_dimension)
         {
            Ga.setCustomDimension(param1.def.ga_custom_dimension,StringUtil.padLeft(_loc2_.toString(),"0",3));
         }
         if(param1.def.ga_custom_metric)
         {
            Ga.setCustomMetric(param1.def.ga_custom_metric,_loc2_);
         }
      }
      
      private function notifyVarGaEvents(param1:Variable) : void
      {
         var _loc3_:* = 0;
         var _loc4_:String = null;
         if(param1.def.achievement_stat)
         {
            SagaAchievements.setStat(param1.def.achievement_stat,param1.asNumber);
         }
         var _loc2_:VariableBag = param1.bag as VariableBag;
         if(!_loc2_ || _loc2_.disable_metrics)
         {
            return;
         }
         if(param1.def.ga_report_event_cur)
         {
            _loc3_ = param1.asInteger;
            _loc4_ = param1.fullname;
            Ga.normal("vars","cur",_loc4_,_loc3_);
         }
      }
      
      private function notifySagaMetrics(param1:Variable, param2:int) : void
      {
         if(!param1.bag)
         {
            return;
         }
         if(!param1.def.metrics_var && !param1.def.metrics_dim)
         {
            return;
         }
         var _loc3_:VariableBag = param1.bag as VariableBag;
         if(!_loc3_ || _loc3_.disable_metrics)
         {
            return;
         }
         var _loc4_:String = param1.fullname;
         if(param1.def.metrics_var)
         {
            this.metrics.handleVariableChanged(_loc4_,param2,param1.asInteger);
         }
      }
      
      private function healInjuries(param1:int) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         var _loc4_:IEntityDef = null;
         var _loc5_:int = 0;
         if(StatType.DEBUG_INJURY)
         {
            this.logger.debug("DEBUG_INJURY: healInjuries days=" + param1);
         }
         if(this.def.survival)
         {
            return;
         }
         if(HEAL_INJURIES_REQUIRES_CAMPING)
         {
            if(!this._camped)
            {
               return;
            }
            if(this._caravan)
            {
               this._caravan.vars.incrementVar("tot_days_rested",param1);
            }
         }
         if(this.def.cast)
         {
            _loc3_ = 0;
            while(_loc3_ < this.def.cast.numCombatants)
            {
               _loc4_ = this.def.cast.getEntityDef(_loc3_);
               _loc5_ = int(_loc4_.stats.getBase(StatType.INJURY));
               if(_loc5_ > 0)
               {
                  _loc5_ = Math.max(0,_loc5_ - param1);
                  _loc4_.stats.getStat(StatType.INJURY).base = _loc5_;
                  if(_loc5_ == 0)
                  {
                     _loc2_ = true;
                  }
               }
               _loc3_++;
            }
            if(_loc2_)
            {
               dispatchEvent(new Event(SagaEvent.EVENT_INJURIES_CHANGED));
            }
         }
      }
      
      public function getCartDef() : CartDef
      {
         var _loc1_:CartDef = null;
         if(Boolean(this.def) && Boolean(this.def.cartDefs))
         {
            _loc1_ = this.def.cartDefs.getCartDefById(this.cartId);
            if(_loc1_)
            {
               return _loc1_.isValid(this) ? _loc1_ : null;
            }
         }
         return null;
      }
      
      private function decrementTalkies() : void
      {
         var _loc1_:int = 0;
         var _loc2_:IEntityDef = null;
         var _loc3_:VariableBag = null;
         var _loc4_:IVariable = null;
         var _loc5_:int = 0;
         if(this.def.cast)
         {
            _loc1_ = 0;
            while(_loc1_ < this.def.cast.numEntityDefs)
            {
               _loc2_ = this.def.cast.getEntityDef(_loc1_);
               if(!(!this.caravan || !this.caravan._legend.roster.getEntityDefById(_loc2_.id)))
               {
                  if(_loc2_.id in this.campTalkies)
                  {
                     _loc3_ = _loc2_.vars as VariableBag;
                     _loc4_ = _loc3_.fetch(SagaVar.VAR_UNIT_TALK,null);
                     if(_loc4_)
                     {
                        _loc5_ = int(_loc4_.asInteger);
                        if(_loc5_ > 0)
                        {
                           _loc4_.asAny = _loc5_ - 1;
                        }
                     }
                  }
               }
               _loc1_++;
            }
         }
      }
      
      public function cleanup() : void
      {
         var _loc1_:Caravan = null;
         if(this.cleanedup)
         {
            return;
         }
         if(this == instance)
         {
            instance = null;
         }
         this.cleanedup = true;
         if(this.survival)
         {
            this.survival.cleanup();
            this.survival = null;
         }
         this.convo = null;
         dispatchEvent(new Event(SagaEvent.EVENT_CLEANUP));
         this.sagaAssetBundles.cleanup();
         this.sagaAssetBundles = null;
         this.playTimer.removeEventListener(TimerEvent.TIMER,this.playTimerHandler);
         this.playTimer.stop();
         this.playTimer = null;
         this.locationTimer.removeEventListener(TimerEvent.TIMER,this.locationTimerHandler);
         this.locationTimer.stop();
         this.locationTimer = null;
         this.unlistenToVars();
         this.endAllHappenings();
         this.caravan = null;
         if(this.restTimer)
         {
            this.restTimer.removeEventListener(TimerEvent.TIMER,this.restTimerHandler);
            this.restTimer.stop();
            this.restTimer = null;
         }
         this._vars.cleanup();
         this._vars = null;
         this._scenePreprocessor.cleanup();
         this._scenePreprocessor = null;
         this.def = null;
         this.resman = null;
         this._logger = null;
         this._sound.cleanup();
         this._sound = null;
         this.abilityFactory = null;
         for each(_loc1_ in this.caravans)
         {
            _loc1_.cleanup();
         }
         this.caravans = null;
         this.shell.cleanup();
         this.shell = null;
         SagaAchievements.removeSaga(this);
         this.market.cleanup();
         this.market = null;
         this._rng = null;
         this.happenings = null;
         this._locale = null;
         this._expression = null;
         this.date_start = null;
         this.mapSplinePt = null;
         this.metrics = null;
         this.campMusic = null;
         this.ccs = null;
         this.happeningDefProviders = null;
         if(this.def)
         {
            this.def.cleanup();
            this.def = null;
         }
      }
      
      public function ensureSelectedVariable() : void
      {
         if(!this.selectedVariable)
         {
            if(this.getVarBool("hero_rook"))
            {
               this.selectedVariable = "hero_rook";
            }
            else
            {
               this.selectedVariable = "hero_alette";
            }
         }
      }
      
      public function start(param1:String, param2:int, param3:SagaSave, param4:String) : void
      {
         var _loc5_:int = 0;
         var _loc6_:HappeningDef = null;
         this.logger.info("Saga.start " + this + " [" + param1 + "] " + param2);
         if(this.started)
         {
            return;
         }
         if(this.isSurvival)
         {
            _loc5_ = this.getMasterSaveKeyInt("difficulty");
            this.difficulty = !!_loc5_ ? _loc5_ : 2;
         }
         this.cartId = this.getMasterSaveKey("cartId") as String;
         if(!this.cartId || this.cartId == "")
         {
            this.cartId = "default";
         }
         if(!SagaSave.REDUCE_SAVE_SIZE)
         {
            this.imported = param3;
         }
         this.selectedVariable = param4;
         this.started = true;
         this.startHappening = param1;
         if(this.profile_index < 0)
         {
            if(this.startHappening)
            {
               this.profile_index = Saga.PROFILE_COUNT - 1;
               this.logger.info("Bookmarked saga forced to profile " + this.profile_index);
            }
         }
         if(param4)
         {
            this.setVar(param4,true);
         }
         if(Boolean(param3) && Boolean(this.def.importDef))
         {
            this.unlistenToVars();
            this._globalSuppressTriggerVariableResponse = true;
            this._globalSuppressVariableFlytext = true;
            this.def.importDef.doImport(param3,this);
            this._globalSuppressTriggerVariableResponse = false;
            this._globalSuppressVariableFlytext = false;
            this.listenToVars();
            Ga.minimal("import","start","imported",1);
         }
         else
         {
            Ga.minimal("import","start","imported",0);
         }
         if(param2)
         {
            this.difficulty = param2;
         }
         this.ensureSelectedVariable();
         this.def.happenings.executeAutomatics(this);
         if(param1)
         {
            if(param1 == HAPPENING_ID_WAIT)
            {
               this.logger.info("Waiting on start happening until forther instuctions... [" + param1 + "]");
            }
            else
            {
               _loc6_ = this.def.happenings.getHappeningDef(param1);
               if(_loc6_)
               {
                  if(_loc6_.automatic)
                  {
                     this.logger.error("Don\'t start global happening: " + _loc6_);
                  }
                  else
                  {
                     this.executeHappeningDef(_loc6_,this);
                  }
               }
               else
               {
                  this.logger.error("Saga.start No such happening: " + param1);
               }
            }
         }
         else if(this.def.survival)
         {
            this.survivalHandleStart();
         }
         else
         {
            this.showStartPage(true);
         }
         if(this.market)
         {
            if(!this.isSurvival)
            {
               this.market.refresh();
            }
         }
         this.sendGaCustomMetricsDimensions();
         this.autoTrackPageView();
      }
      
      protected function survivalHandleStart() : void
      {
      }
      
      public function showSurvivalWinPage() : void
      {
      }
      
      private function sendGaCustomMetricsDimensions() : void
      {
         if(!this._vars || !this.def || this.cleanedup)
         {
            return;
         }
         this._vars.notifyVarGaCustoms(this.notifyVarGaCustoms);
      }
      
      public function sendCheckpointGa(param1:String) : void
      {
         var _loc2_:Caravan = null;
         this.autoTrackPageView();
         Ga.normal("checkpoint","play_minutes",param1,this.minutesPlayed);
         for each(_loc2_ in this.caravans)
         {
            if(_loc2_.def.ga)
            {
               this.sendCaravanCheckpointItemGa(param1,_loc2_,"tot_starvation_deaths");
               this.sendCaravanCheckpointItemGa(param1,_loc2_,"tot_renown_gained");
               this.sendCaravanCheckpointItemGa(param1,_loc2_,"tot_renown_spent");
               this.sendCaravanCheckpointItemGa(param1,_loc2_,"morale","cur_morale");
               this.sendCaravanCheckpointItemGa(param1,_loc2_,"renown","cur_renown");
               this.sendCaravanCheckpointItemGa(param1,_loc2_,"supplies","cur_supplies");
               this.sendCharacterInfoGa(param1,_loc2_);
            }
         }
      }
      
      private function sendCharacterInfoGa(param1:String, param2:Caravan) : void
      {
         var _loc6_:IEntityDef = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:String = null;
         var _loc10_:* = null;
         var _loc11_:* = null;
         var _loc3_:IVariableBag = param2.vars;
         var _loc4_:String = param2.def.shortname;
         var _loc5_:int = 0;
         while(_loc5_ < param2.roster.numEntityDefs)
         {
            _loc6_ = param2.roster.getEntityDef(_loc5_);
            if(_loc6_)
            {
               _loc7_ = int(_loc6_.stats.getStat(StatType.KILLS).value);
               _loc8_ = int(_loc6_.stats.rank);
               _loc9_ = param2.def.name + "." + _loc6_.id;
               _loc10_ = _loc9_ + ".kills";
               _loc11_ = _loc9_ + ".rank";
               Ga.normal("caravan_chk",_loc11_,param1,_loc8_);
               Ga.normal("caravan_snp",param1,_loc11_,_loc8_);
               Ga.normal("caravan_chk",_loc10_,param1,_loc7_);
               Ga.normal("caravan_snp",param1,_loc10_,_loc7_);
            }
            _loc5_++;
         }
      }
      
      public function sendCaravanCheckpointItemGa(param1:String, param2:Caravan, param3:String, param4:String = null) : void
      {
         var _loc5_:IVariableBag = param2.vars;
         var _loc6_:int = int(_loc5_.getVarInt(param3));
         var _loc7_:String = param2.def.shortname;
         if(!param4)
         {
            param4 = param3;
         }
         var _loc8_:String = _loc7_ + "." + param4;
         Ga.normal("caravan_chk",_loc8_,param1,_loc6_);
         Ga.normal("caravan_snp",param1,_loc8_,_loc6_);
      }
      
      public function showStartPage(param1:Boolean) : void
      {
         this.setVar(SagaVar.VAR_HUD_TRAVEL_HIDDEN,true);
         this.convo = null;
         this.endAllHappenings();
         this.caravan = null;
         if(this.ccs)
         {
            this.ccs.subtitle.sequence = null;
            this.ccs.supertitle.sequence = null;
         }
         this.sound.system.vo = null;
         this.setVar(SagaVar.VAR_START_PAGE_MUSIC_DISABLE,!param1);
         this.profile_index = -1;
         if(this.def._startCaravan)
         {
            this.setCaravanById(this.def._startCaravan);
         }
         if(this.def._startUrl)
         {
            this.performSceneStart(this.def._startUrl,null,true);
         }
         else
         {
            this.performShowSagaSelector();
         }
      }
      
      public function performShowSagaSelector() : void
      {
      }
      
      private function happeningCompleteHandler(param1:Event) : void
      {
         var _loc2_:Happening = param1.target as Happening;
         _loc2_.removeEventListener(Event.COMPLETE,this.happeningCompleteHandler);
         delete this.happenings[_loc2_];
         this.checkTurnBeginHappenings();
      }
      
      public function getCaravan(param1:String) : ICaravan
      {
         if(!param1 || param1 == "caravan")
         {
            return this.caravan;
         }
         return this.caravans[param1] as Caravan;
      }
      
      public function getBag(param1:String) : VariableBag
      {
         return !!this._vars ? this._vars.getBag(param1) as VariableBag : null;
      }
      
      public function getSymbolValue(param1:String, param2:Boolean) : Number
      {
         return !!this._vars ? this._vars.getSymbolValue(param1,param2) : 0;
      }
      
      public function enumerateVarsNames(param1:Vector.<String>) : Vector.<String>
      {
         return !!this._vars ? this._vars.enumerateVarsNames(param1) : param1;
      }
      
      public function getVarBool(param1:String) : Boolean
      {
         return !!this._vars ? this._vars.getVarBool(param1) : false;
      }
      
      public function getVarInt(param1:String) : int
      {
         return !!this._vars ? this._vars.getVarInt(param1) : 0;
      }
      
      public function getVarString(param1:String) : String
      {
         return !!this._vars ? this._vars.getVarString(param1) : null;
      }
      
      public function getVarNumber(param1:String) : Number
      {
         return !!this._vars ? this._vars.getVarNumber(param1) : 0;
      }
      
      public function getVar(param1:String, param2:VariableType) : IVariable
      {
         return !!this._vars ? this._vars.getVar(param1,param2) : null;
      }
      
      public function setVar(param1:String, param2:*) : IVariable
      {
         return !!this._vars ? this._vars.setVar(param1,param2) : null;
      }
      
      public function removeVar(param1:String) : void
      {
         this._vars && this._vars.removeVar(param1);
      }
      
      private function _filterTrigger(param1:HappeningDef, param2:SagaTriggerType) : Boolean
      {
         if(!param1)
         {
            this._prereqReason.value = "null happening";
            return false;
         }
         if(!param1.enabled)
         {
            this._prereqReason.value = "happening disabled";
            return false;
         }
         if(!param1.triggers || !param1.triggers.hasTriggers)
         {
            this._prereqReason.value = "no triggers";
            return false;
         }
         if(!param1.checkPrereq(this,this._prereqReason))
         {
            this._prereqReason.value = !!this._prereqReason.value ? this._prereqReason.value : "unknown";
            return false;
         }
         this._prereqReason.value = null;
         return true;
      }
      
      private function getTriggersForType(param1:SagaTriggerType, param2:Vector.<SagaTriggerDef>, param3:String = null, param4:Boolean = true) : Vector.<SagaTriggerDef>
      {
         var _loc6_:IHappeningDefProvider = null;
         var _loc7_:int = 0;
         var _loc8_:HappeningDef = null;
         var _loc9_:Boolean = false;
         var _loc10_:String = null;
         var _loc5_:IBattleBoard = this.getBattleBoard();
         if(_loc5_)
         {
            _loc5_.checkVars();
         }
         for each(_loc6_ in this.happeningDefProviders)
         {
            _loc7_ = 0;
            for(; _loc7_ < _loc6_.numHappenings; _loc7_++)
            {
               _loc8_ = _loc6_.getHappeningDefByIndex(_loc7_);
               if(_loc8_.hasTriggersForType(param1))
               {
                  _loc9_ = this._filterTrigger(_loc8_,param1);
                  _loc10_ = null;
                  if(!_loc9_)
                  {
                     if(!param4)
                     {
                        continue;
                     }
                     _loc10_ = this._prereqReason.value;
                  }
                  param2 = _loc8_.triggers.getTriggersByType(param1,param2,param3,_loc10_,this.logger);
               }
            }
         }
         return param2;
      }
      
      private function getLocationTriggers(param1:String, param2:Vector.<SagaTriggerDef>) : Vector.<SagaTriggerDef>
      {
         var _loc3_:IHappeningDefProvider = null;
         var _loc4_:int = 0;
         var _loc5_:HappeningDef = null;
         for each(_loc3_ in this.happeningDefProviders)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc3_.numHappenings)
            {
               _loc5_ = _loc3_.getHappeningDefByIndex(_loc4_);
               if(_loc5_.hasTriggersForType(SagaTriggerType.LOCATION))
               {
                  if(this._filterTrigger(_loc5_,SagaTriggerType.LOCATION))
                  {
                     param2 = _loc5_.triggers.getLocationTriggers(param1,param2);
                  }
               }
               _loc4_++;
            }
         }
         return param2;
      }
      
      public function triggerTalk(param1:String) : void
      {
         var _loc3_:SagaTriggerDef = null;
         var _loc2_:Vector.<SagaTriggerDef> = this.getTriggersForType(SagaTriggerType.TALK,null);
         for each(_loc3_ in _loc2_)
         {
            if(_loc3_.unit == param1)
            {
               this.logger.i("SAGA","   TRIGGER " + _loc3_);
               this.executeHappeningDef(_loc3_.happening,_loc3_);
            }
         }
      }
      
      public function triggerLandscapeClick(param1:String) : int
      {
         var _loc2_:int = 0;
         var _loc4_:SagaTriggerDef = null;
         var _loc5_:Vector.<Action> = null;
         var _loc6_:Action = null;
         var _loc7_:IHappening = null;
         var _loc3_:Vector.<SagaTriggerDef> = this.getTriggersForType(SagaTriggerType.CLICK,null);
         for each(_loc4_ in _loc3_)
         {
            if(_loc4_.click == param1)
            {
               this.logger.i("SAGA","   TRIGGER " + _loc4_);
               _loc7_ = this.executeHappeningDef(_loc4_.happening,_loc4_);
               if(_loc7_)
               {
                  this.logger.i("SAGA","   TRIGGERED HAPPENING " + _loc7_);
                  _loc2_++;
               }
            }
         }
         _loc5_ = this.actions.concat();
         for each(_loc6_ in _loc5_)
         {
            if(!_loc6_.ended)
            {
               if(_loc6_.triggerClick(param1))
               {
                  this.logger.i("SAGA","   TRIGGERED ACTION " + _loc6_);
                  _loc2_++;
               }
            }
         }
         return _loc2_;
      }
      
      public function triggerPageStarted(param1:String) : void
      {
         var _loc3_:Action = null;
         var _loc2_:Vector.<Action> = this.actions.concat();
         for each(_loc3_ in _loc2_)
         {
            if(!_loc3_.ended)
            {
               _loc3_.triggerPageStarted(param1);
            }
         }
      }
      
      public function triggerMapInfo(param1:String) : void
      {
         var _loc3_:Action = null;
         var _loc2_:Vector.<Action> = this.actions.concat();
         for each(_loc3_ in _loc2_)
         {
            if(!_loc3_.ended)
            {
               _loc3_.triggerMapInfo(param1);
            }
         }
      }
      
      private function triggerVariableIncrement(param1:Variable, param2:int) : void
      {
         var _loc7_:SagaTriggerDef = null;
         var _loc8_:Vector.<Action> = null;
         var _loc9_:Action = null;
         var _loc3_:String = param1.def.name;
         var _loc4_:* = _loc3_ != SagaVar.VAR_PLAY_MINUTES;
         var _loc5_:Vector.<SagaTriggerDef> = this.getTriggersForType(SagaTriggerType.VARIABLE_INCREMENT,null,_loc3_,_loc4_);
         var _loc6_:* = param1.asInteger > param2;
         for each(_loc7_ in _loc5_)
         {
            if(_loc7_.varname == param1.def.name || _loc7_.varname == param1.fullname)
            {
               if(_loc7_.varvalue == 0 || _loc7_.varvalue > 0 && _loc6_ || _loc7_.varvalue < 0 && !_loc6_)
               {
                  this.logger.i("SAGA","   TRIGGER " + _loc7_);
                  this.executeHappeningDef(_loc7_.happening,_loc7_);
               }
            }
         }
         _loc8_ = this.actions.concat();
         for each(_loc9_ in _loc8_)
         {
            if(!_loc9_.ended)
            {
               _loc9_.triggerVariableIncrement(param1,param2);
            }
         }
         if(param1.def.name == SagaVar.VAR_SURVIVAL_PROGRESS)
         {
            this.handleSurvivalProgressIncrement();
         }
      }
      
      private function triggerVariableThresholdUp(param1:Variable, param2:Number) : void
      {
         var _loc5_:SagaTriggerDef = null;
         var _loc3_:* = param1.asNumber;
         if(_loc3_ <= param2)
         {
            return;
         }
         var _loc4_:Vector.<SagaTriggerDef> = this.getTriggersForType(SagaTriggerType.VARIABLE_THRESHOLD_UP,null);
         for each(_loc5_ in _loc4_)
         {
            if(_loc5_.varname == param1.def.name || _loc5_.varname == param1.fullname)
            {
               if(param2 < _loc5_.varvalue && _loc3_ >= _loc5_.varvalue)
               {
                  this.logger.i("SAGA","   TRIGGER " + _loc5_);
                  this.executeHappeningDef(_loc5_.happening,_loc5_);
               }
            }
         }
      }
      
      private function triggerVariableThresholdDown(param1:Variable, param2:Number) : void
      {
         var _loc5_:SagaTriggerDef = null;
         var _loc3_:* = param1.asNumber;
         if(_loc3_ >= param2)
         {
            return;
         }
         var _loc4_:Vector.<SagaTriggerDef> = this.getTriggersForType(SagaTriggerType.VARIABLE_THRESHOLD_DOWN,null);
         for each(_loc5_ in _loc4_)
         {
            if(_loc5_.varname == param1.def.name || _loc5_.varname == param1.fullname)
            {
               if(param2 > _loc5_.varvalue && _loc3_ <= _loc5_.varvalue)
               {
                  this.logger.i("SAGA","   TRIGGER " + _loc5_);
                  this.executeHappeningDef(_loc5_.happening,_loc5_);
               }
            }
         }
      }
      
      public function incrementGlobalVar(param1:String, param2:int = 1) : int
      {
         return this._vars.incrementGlobalVar(param1,this.isAchievementsSuppressed,param2);
      }
      
      public function modifyGlobalVar(param1:String, param2:Number) : Number
      {
         return this._vars.modifyGlobalVar(param1,this.isAchievementsSuppressed,param2);
      }
      
      public function setMaxGlobalVar(param1:String, param2:Number) : Number
      {
         return this._vars.setMaxGlobalVar(param1,this.isAchievementsSuppressed,param2);
      }
      
      public function get isAchievementsSuppressed() : Boolean
      {
         if(!QAACV && this.isDevCheat)
         {
            return true;
         }
         return this.getVarBool(SagaVar.VAR_ACHIEVEMENTS_SUPPRESSED);
      }
      
      public function triggerItemGained(param1:Item) : void
      {
         var _loc2_:String = VAR_PRG_ITEMS_GAINED_ + param1.def.rank;
         this.incrementGlobalVar(_loc2_);
      }
      
      public function triggerBattleRemainingUnits(param1:SagaTriggerType, param2:int) : void
      {
         var _loc5_:SagaTriggerDef = null;
         var _loc6_:IHappening = null;
         var _loc3_:BattleBoard = this.getBattleBoard();
         if(!_loc3_)
         {
            return;
         }
         var _loc4_:Vector.<SagaTriggerDef> = this.getTriggersForType(param1,null);
         if(!_loc4_)
         {
            return;
         }
         for each(_loc5_ in _loc4_)
         {
            if(_loc5_.varvalue == param2)
            {
               this.logger.i("SAGA","   TRIGGER " + _loc5_);
               _loc6_ = this.executeHappeningDef(_loc5_.happening,_loc5_);
               if(!_loc6_.isEnded)
               {
                  _loc3_.fsm.nextTurnSuspend();
                  this._nextTurnBeginHappenings.push(_loc6_);
               }
            }
         }
      }
      
      public function triggerNoMoreEnemiesRemainPreVictory() : Boolean
      {
         var _loc4_:SagaTriggerDef = null;
         var _loc5_:IHappening = null;
         var _loc1_:Boolean = false;
         var _loc2_:BattleBoard = this.getBattleBoard();
         if(!_loc2_)
         {
            return false;
         }
         var _loc3_:Vector.<SagaTriggerDef> = this.getTriggersForType(SagaTriggerType.BATTLE_NO_ENEMIES_REMAIN_PRE_VICTORY,null);
         if(!_loc3_)
         {
            return false;
         }
         for each(_loc4_ in _loc3_)
         {
            _loc1_ = true;
            this.logger.i("SAGA","   TRIGGER " + _loc4_);
            if(this.isHappeningHappening(_loc4_.happening))
            {
               return false;
            }
            _loc5_ = this.executeHappeningDef(_loc4_.happening,_loc4_);
            if(!_loc5_.isEnded)
            {
               _loc2_.fsm.nextTurnSuspend();
               this._nextTurnBeginHappenings.push(_loc5_);
            }
         }
         return _loc1_;
      }
      
      private function _filterStandardUnitTrigger(param1:IBattleEntity, param2:SagaTriggerDef) : Boolean
      {
         var _loc3_:String = null;
         var _loc4_:Boolean = false;
         if(param2.player_only && !param1.isPlayer)
         {
            return false;
         }
         if(param2.enemy_only && !param1.isEnemy)
         {
            return false;
         }
         if(param2.unit)
         {
            _loc3_ = param2.unit;
            if(_loc3_.charAt(0) == "!")
            {
               _loc4_ = true;
               _loc3_ = _loc3_.substr(1);
            }
            if(_loc4_)
            {
               if(_loc3_ == param1.id || _loc3_ == param1.def.id)
               {
                  return false;
               }
            }
            else if(_loc3_ != param1.id && _loc3_ != param1.def.id)
            {
               return false;
            }
         }
         return true;
      }
      
      public function triggerBattleUnitRemoved(param1:IBattleEntity) : void
      {
         var _loc4_:SagaTriggerDef = null;
         var _loc5_:IHappening = null;
         var _loc2_:Vector.<SagaTriggerDef> = this.getTriggersForType(SagaTriggerType.BATTLE_UNIT_REMOVED,null);
         var _loc3_:BattleBoard = this.getBattleBoard();
         if(!_loc3_ || !_loc2_)
         {
            return;
         }
         for each(_loc4_ in _loc2_)
         {
            if(this._filterStandardUnitTrigger(param1,_loc4_))
            {
               this.logger.i("SAGA","   TRIGGER " + _loc4_);
               _loc5_ = this.executeHappeningDef(_loc4_.happening,_loc4_);
            }
         }
      }
      
      public function triggerBattleKillStop(param1:IBattleEntity) : void
      {
         var _loc4_:SagaTriggerDef = null;
         var _loc5_:IHappening = null;
         var _loc2_:Vector.<SagaTriggerDef> = this.getTriggersForType(SagaTriggerType.BATTLE_KILL_STOP,null);
         var _loc3_:BattleBoard = this.getBattleBoard();
         if(!_loc3_ || !_loc2_)
         {
            return;
         }
         for each(_loc4_ in _loc2_)
         {
            if(this._filterStandardUnitTrigger(param1,_loc4_))
            {
               this.logger.i("SAGA","   TRIGGER " + _loc4_);
               _loc5_ = this.executeHappeningDef(_loc4_.happening,_loc4_);
            }
         }
      }
      
      public function triggerBattleImmortalStopped(param1:IBattleEntity) : void
      {
         var _loc4_:SagaTriggerDef = null;
         var _loc5_:IHappening = null;
         var _loc2_:Vector.<SagaTriggerDef> = this.getTriggersForType(SagaTriggerType.BATTLE_IMMORTAL_STOPPED,null);
         var _loc3_:BattleBoard = this.getBattleBoard();
         if(!_loc3_ || !_loc2_)
         {
            return;
         }
         for each(_loc4_ in _loc2_)
         {
            if(this._filterStandardUnitTrigger(param1,_loc4_))
            {
               this.logger.i("SAGA","   TRIGGER " + _loc4_);
               _loc5_ = this.executeHappeningDef(_loc4_.happening,_loc4_);
            }
         }
      }
      
      public function triggerBattleNextTurnBegin(param1:IBattleEntity) : void
      {
         var _loc4_:SagaTriggerDef = null;
         var _loc5_:IHappening = null;
         var _loc2_:Vector.<SagaTriggerDef> = this.getTriggersForType(SagaTriggerType.BATTLE_NEXT_TURN_BEGIN,null);
         var _loc3_:BattleBoard = this.getBattleBoard();
         if(!_loc3_ || !_loc2_)
         {
            return;
         }
         for each(_loc4_ in _loc2_)
         {
            if(this._filterStandardUnitTrigger(param1,_loc4_))
            {
               this.logger.i("SAGA","   TRIGGER " + _loc4_);
               NextTurnVarsHelper.setNextTurnBattleVars(this,_loc3_.fsm.order);
               _loc5_ = this.executeHappeningDef(_loc4_.happening,_loc4_);
               if(!_loc5_.isEnded)
               {
                  _loc3_.fsm.nextTurnSuspend();
                  this._nextTurnBeginHappenings.push(_loc5_);
               }
            }
         }
      }
      
      private function checkTurnBeginHappenings() : void
      {
         var _loc2_:Happening = null;
         var _loc1_:BattleBoard = this.getBattleBoard();
         if(!_loc1_)
         {
            if(this._nextTurnBeginHappenings.length)
            {
               this._nextTurnBeginHappenings = new Vector.<Happening>();
            }
            return;
         }
         if(!this._nextTurnBeginHappenings.length)
         {
            return;
         }
         while(this._nextTurnBeginHappenings.length)
         {
            _loc2_ = this._nextTurnBeginHappenings[this._nextTurnBeginHappenings.length - 1];
            if(!_loc2_.ended)
            {
               break;
            }
            this._nextTurnBeginHappenings.pop();
         }
         if(!this._nextTurnBeginHappenings.length)
         {
            NextTurnVarsHelper.removeNextTurnBattleVars(this);
            _loc1_.fsm.nextTurnResume();
         }
      }
      
      public function triggerBattleUnitKilled(param1:IBattleEntity) : void
      {
         var _loc2_:Vector.<SagaTriggerDef> = null;
         var _loc4_:SagaTriggerDef = null;
         var _loc3_:SagaTriggerType = SagaTriggerType.BATTLE_OTHER_KILLED;
         if(param1.isPlayer)
         {
            _loc3_ = SagaTriggerType.BATTLE_ALLY_KILLED;
         }
         else if(param1.isEnemy)
         {
            SagaHeroStats.incrementStat("enemy_defeated");
            _loc3_ = SagaTriggerType.BATTLE_ENEMY_KILLED;
         }
         _loc2_ = this.getTriggersForType(_loc3_,null);
         for each(_loc4_ in _loc2_)
         {
            if(param1.cleanedup)
            {
               return;
            }
            if(!_loc4_.unit || _loc4_.unit == param1.def.id)
            {
               this.logger.i("SAGA","   TRIGGER " + _loc4_);
               this.executeHappeningDef(_loc4_.happening,_loc4_);
            }
         }
      }
      
      public function triggerBattleUnitAttacked(param1:IBattleEntity, param2:IBattleEntity) : void
      {
         var _loc3_:String = param2.def.entityClass.race;
         if(param1.def.id == "alette" && (_loc3_ == "human" || _loc3_ == "varl"))
         {
            if(!this.inTrainingBattle)
            {
               this.incrementGlobalVar("prg_alette_guilty");
            }
         }
      }
      
      public function triggerBattleAbilityCompleted(param1:String, param2:String, param3:Boolean) : void
      {
         var _loc5_:SagaTriggerDef = null;
         var _loc6_:Scene = null;
         var _loc4_:Vector.<SagaTriggerDef> = this.getTriggersForType(SagaTriggerType.BATTLE_ABILITY_COMPLETED,null);
         for each(_loc5_ in _loc4_)
         {
            if((!_loc5_.unit || _loc5_.unit == param1) && (!_loc5_.location || _loc5_.location == param2))
            {
               if((param3 || !_loc5_.player_only) && (!param3 || !_loc5_.enemy_only))
               {
                  this.logger.i("SAGA","   TRIGGER " + _loc5_);
                  this.executeHappeningDef(_loc5_.happening,_loc5_);
               }
            }
         }
         _loc6_ = this.getScene();
         if(_loc6_)
         {
            if(_loc6_.tips)
            {
               _loc6_.tips.triggerBattleAbilityCompleted(param1,param2,param3);
            }
         }
      }
      
      public function triggerBattleAbilityExecuted(param1:String, param2:String, param3:Boolean) : void
      {
         var _loc5_:SagaTriggerDef = null;
         var _loc4_:Vector.<SagaTriggerDef> = this.getTriggersForType(SagaTriggerType.BATTLE_ABILITY_EXECUTED,null);
         for each(_loc5_ in _loc4_)
         {
            if((!_loc5_.unit || _loc5_.unit == param1) && (!_loc5_.location || _loc5_.location == param2))
            {
               if((param3 || !_loc5_.player_only) && (!param3 || !_loc5_.enemy_only))
               {
                  this.logger.i("SAGA","   TRIGGER " + _loc5_);
                  this.executeHappeningDef(_loc5_.happening,_loc5_);
               }
            }
         }
      }
      
      public function triggerBattleTurn(param1:String, param2:Boolean) : void
      {
         var _loc4_:SagaTriggerDef = null;
         var _loc3_:Vector.<SagaTriggerDef> = this.getTriggersForType(SagaTriggerType.BATTLE_TURN,null);
         for each(_loc4_ in _loc3_)
         {
            if((!_loc4_.unit || _loc4_.unit == param1) && (param2 || !_loc4_.player_only))
            {
               this.logger.i("SAGA","   TRIGGER " + _loc4_);
               this.executeHappeningDef(_loc4_.happening,_loc4_);
            }
         }
      }
      
      public function triggerBattleWaveSpawned() : void
      {
         var _loc2_:SagaTriggerDef = null;
         var _loc1_:Vector.<SagaTriggerDef> = this.getTriggersForType(SagaTriggerType.BATTLE_WAVE_SPAWNED,null);
         for each(_loc2_ in _loc1_)
         {
            this.executeHappeningDef(_loc2_.happening,_loc2_);
         }
      }
      
      public function triggerBattleWaveLowTurnWarning() : void
      {
         var _loc2_:SagaTriggerDef = null;
         var _loc1_:Vector.<SagaTriggerDef> = this.getTriggersForType(SagaTriggerType.BATTLE_WAVE_LOW_TURN_WARNING,null);
         for each(_loc2_ in _loc1_)
         {
            this.executeHappeningDef(_loc2_.happening,_loc2_);
         }
      }
      
      public function triggerBattleFinished(param1:String) : void
      {
         var _loc2_:Vector.<SagaTriggerDef> = null;
         var _loc6_:SagaTriggerDef = null;
         var _loc7_:* = false;
         var _loc3_:BattleBoard = this.getBattleBoard();
         var _loc4_:IBattleFsm = !!_loc3_ ? _loc3_.fsm : null;
         if(!_loc4_)
         {
            return;
         }
         var _loc5_:BattleFinishedData = _loc4_.finishedData;
         this.logger.i("SAGA","triggerBattleFinished v=" + (!!_loc5_ ? _loc5_.victoriousTeam : "-") + " t=" + this.inTrainingBattle);
         if(Boolean(_loc5_) && _loc5_.victoriousTeam == "0")
         {
            _loc2_ = this.getTriggersForType(SagaTriggerType.BATTLE_WIN,null);
            if(Boolean(_loc3_) && Boolean(_loc3_.scenario))
            {
               _loc3_.scenario.handleBattleWin();
            }
            if(this._triggerMMAAchievementOnBattleFinish)
            {
               this._triggerMMAAchievementOnBattleFinish = false;
               SagaAchievements.unlockAchievementById("acv_3_49_mixed_martial_arts",this.minutesPlayed,true);
            }
         }
         else
         {
            _loc2_ = this.getTriggersForType(SagaTriggerType.BATTLE_LOSE,null);
         }
         for each(_loc6_ in _loc2_)
         {
            this.logger.i("SAGA","   TRIGGER " + _loc6_);
            this.executeHappeningDef(_loc6_.happening,_loc6_);
         }
         _loc7_ = _loc5_.victoriousTeam == "0";
         if(Boolean(_loc3_.waves) && !_loc3_.waves.hasMoreWaves)
         {
            this.incrementGlobalVar("prg_wave_battles_won");
         }
         if(!this.inTrainingBattle)
         {
            this.incrementGlobalVar(VAR_PRG_BATTLES_FOUGHT);
            if(_loc7_)
            {
               this.incrementGlobalVar(VAR_PRG_BATTLES_WON);
            }
            else
            {
               this.incrementGlobalVar(VAR_PRG_BATTLES_LOST);
            }
            if(this._caravan)
            {
               this._caravan.vars.incrementVar("tot_battles",1);
               if(_loc7_)
               {
                  this._caravan.vars.incrementVar("tot_battles_won",1);
               }
               else
               {
                  this._caravan.vars.incrementVar("tot_battles_lost",1);
               }
            }
         }
         else
         {
            if(this._caravan)
            {
               if(this.getVarBool(SagaVar.VAR_TRAINING_SCENARIO))
               {
                  this._caravan.vars.incrementVar("tot_challenges",1);
                  if(_loc7_)
                  {
                     this._caravan.vars.incrementVar("tot_challenges_complete",1);
                  }
               }
               else if(this.getVarBool(SagaVar.VAR_TRAINING_SPARRING))
               {
                  this._caravan.vars.incrementVar("tot_sparring",1);
               }
            }
            if(_loc7_)
            {
               this.attemptAchievementMasterTactician("acv_complete_master_tactician");
               this.attemptAchievementMasterTactician("acv_2_complete_master_tactician");
            }
         }
         this.inTrainingBattle = false;
         if(Boolean(_loc4_) && _loc4_.halted)
         {
         }
         this.triggerBattleFinallyFinished(param1);
      }
      
      private function attemptAchievementMasterTactician(param1:String) : void
      {
         if(this.difficulty != DIFFICULTY_HARD)
         {
            return;
         }
         if(!this.caravan)
         {
            return;
         }
         if(!this.def.achievements.fetch(param1))
         {
            return;
         }
         var _loc2_:int = int(this.caravan._legend.party.totalPower);
         var _loc3_:int = this.getVarInt(param1 + "_ranks");
         _loc3_ = !!_loc3_ ? _loc3_ : 30;
         if(_loc2_ >= _loc3_)
         {
            SagaAchievements.unlockAchievementById(param1,this.minutesPlayed,true);
         }
      }
      
      public function triggerBattleFinallyFinished(param1:String) : void
      {
         var _loc3_:Action = null;
         if(Boolean(this.survival) && Boolean(this.survival.record))
         {
            this.survival.record.handleBattleFinish(this.getBattleBoard());
         }
         var _loc2_:Vector.<Action> = this.actions.concat();
         for each(_loc3_ in _loc2_)
         {
            if(!_loc3_.ended)
            {
               _loc3_.triggerBattleFinished(param1);
            }
         }
      }
      
      public function triggerBattleFinish_begin(param1:String) : void
      {
         this.endAllHappeningsForBattleFinish_begin(param1);
      }
      
      public function triggerBattleFinishing(param1:String, param2:BattleFinishedData, param3:BattleBoard) : void
      {
         var _loc4_:Vector.<SagaTriggerDef> = null;
         var _loc6_:SagaTriggerDef = null;
         var _loc5_:BattleBoard = this.getBattleBoard();
         if(Boolean(param2) && param2.victoriousTeam == "0")
         {
            _loc4_ = this.getTriggersForType(SagaTriggerType.BATTLE_FINISHING_WIN,null);
            if(Boolean(_loc5_) && Boolean(_loc5_.scenario))
            {
               _loc5_.scenario.handleBattleWin();
            }
         }
         else
         {
            _loc4_ = this.getTriggersForType(SagaTriggerType.BATTLE_FINISHING_LOSE,null);
         }
         for each(_loc6_ in _loc4_)
         {
            this.logger.i("SAGA","   TRIGGER " + _loc6_);
            this.executeHappeningDef(_loc6_.happening,_loc6_);
         }
      }
      
      private function endAllHappeningsForBattleFinish_begin(param1:String) : void
      {
         var _loc2_:Vector.<Happening> = null;
         var _loc3_:Happening = null;
         var _loc4_:SceneDef = null;
         for each(_loc3_ in this.happenings)
         {
            _loc4_ = Boolean(_loc3_.def) && Boolean(_loc3_.def.bag) ? _loc3_.def.bag.owner as SceneDefVars : null;
            if(Boolean(_loc4_) && _loc4_.url == param1)
            {
               if(!_loc3_.def.outliveBattle)
               {
                  if(!_loc2_)
                  {
                     _loc2_ = new Vector.<Happening>();
                  }
                  _loc2_.push(_loc3_);
               }
            }
         }
         if(_loc2_)
         {
            for each(_loc3_ in _loc2_)
            {
               this.logger.i("SAGA","Saga.endAllHappeningsForBattleFinish_begin [" + _loc3_ + "]");
               _loc3_.end(true);
            }
         }
         this.performTutorialRemoveAll("endAllHappeningsForBattleFinish_begin");
      }
      
      public function triggerWarResolutionClosed() : void
      {
         var _loc2_:Action = null;
         var _loc1_:Vector.<Action> = this.actions.concat();
         for each(_loc2_ in _loc1_)
         {
            if(!_loc2_.ended)
            {
               _loc2_.triggerWarResolutionClosed();
            }
         }
      }
      
      public function triggerBattleResolutionClosed() : void
      {
         var _loc2_:Action = null;
         var _loc1_:Vector.<Action> = this.actions.concat();
         for each(_loc2_ in _loc1_)
         {
            if(!_loc2_.ended)
            {
               _loc2_.triggerBattleResolutionClosed();
            }
         }
      }
      
      public function triggerLocation(param1:Travel, param2:String) : void
      {
         var _loc4_:Dictionary = null;
         var _loc5_:SagaTriggerDef = null;
         if(Saga.SKIP_LOCATION_TRIGGERS)
         {
            return;
         }
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("Saga.triggerLocation location=" + param2);
         }
         if(Boolean(this._halting) && param2 == this.haltLocation)
         {
            this.halted = true;
         }
         var _loc3_:Vector.<SagaTriggerDef> = this.getLocationTriggers(param2,null);
         if(_loc3_)
         {
            _loc4_ = new Dictionary();
            for each(_loc5_ in _loc3_)
            {
               this.logger.i("SAGA","   TRIGGER " + _loc5_);
               if(_loc4_[_loc5_])
               {
                  this.logger.error("already triggered " + _loc5_);
               }
               else
               {
                  _loc4_[_loc5_] = _loc5_;
                  this.executeHappeningDef(_loc5_.happening,_loc5_);
               }
            }
         }
      }
      
      public function performBattleStart(param1:SceneLoaderBattleInfo, param2:String) : void
      {
         this.inTrainingBattle = false;
         this.setVar(SagaVar.VAR_TRAINING_SPARRING,false);
         this.setVar(SagaVar.VAR_TRAINING_SCENARIO,false);
         this.setVar(SagaVar.VAR_TUTORIAL_SKIPPABLE,false);
         if(param1.sparring)
         {
            this.inTrainingBattle = true;
            this.setVar(SagaVar.VAR_TRAINING_SPARRING,true);
         }
         else if(param1.scenarioDef)
         {
            this.inTrainingBattle = true;
            this.setVar(SagaVar.VAR_TRAINING_SCENARIO,true);
         }
         if(!this.inTrainingBattle)
         {
            this._vars.checkMinGlobal(VAR_PRG_MIN_DIFFICULTY,SagaVar.VAR_DIFFICULTY);
         }
      }
      
      public function performBattleUnitAbility(param1:String, param2:String, param3:int, param4:Vector.<String>, param5:Vector.<TileLocation>, param6:Function) : void
      {
      }
      
      public function performBattleUnitMove(param1:String, param2:Vector.<Vector.<TileLocation>>, param3:Boolean, param4:Function) : IBattleEntity
      {
         return null;
      }
      
      public function performBattleUnitPathfind(param1:String, param2:Vector.<Vector.<TileLocation>>, param3:Boolean, param4:Function) : IBattleEntity
      {
         return null;
      }
      
      public function performBattleReady() : void
      {
      }
      
      public function performBattleHalt() : void
      {
      }
      
      public function performBattleSurrender() : void
      {
      }
      
      public function performBattleStopMusic() : void
      {
      }
      
      public function performSceneStart(param1:String, param2:String, param3:Boolean) : void
      {
      }
      
      public function performSceneCameraPan(param1:String, param2:Number) : void
      {
         dispatchEvent(new SceneCameraPanEvent(param1,param2));
      }
      
      public function performSceneCameraSpline(param1:String, param2:Number, param3:Number) : void
      {
         dispatchEvent(new SceneCameraSplineEvent(param1,param2,param3));
      }
      
      public function performSceneCameraSplinePause(param1:Boolean) : void
      {
         dispatchEvent(new SceneCameraSplinePauseEvent(param1));
      }
      
      public function performVideo(param1:VideoParams) : void
      {
      }
      
      public function performAssembleHeroes() : void
      {
      }
      
      public function performSagaSurvivalBattlePopup(param1:String, param2:Function) : void
      {
      }
      
      public function performFlashPage(param1:String, param2:String, param3:Number, param4:Boolean) : void
      {
      }
      
      public function performTravelStart(param1:String, param2:TravelLocator, param3:Travel_FallData, param4:Travel_WipeData, param5:String, param6:Boolean) : void
      {
      }
      
      public function triggerVideoFinished(param1:String) : void
      {
         var _loc3_:Action = null;
         this.logger.i("SAGA","triggerVideoFinished");
         var _loc2_:Vector.<Action> = this.actions.concat();
         for each(_loc3_ in _loc2_)
         {
            if(!_loc3_.ended)
            {
               _loc3_.triggerVideoFinished(param1);
            }
         }
         if(this.videoReturnsToStartScene)
         {
            this.videoReturnsToStartScene = false;
            this.showStartPage(true);
         }
      }
      
      public function triggerCreditsComplete() : void
      {
         var _loc2_:Action = null;
         var _loc1_:Vector.<Action> = this.actions.concat();
         for each(_loc2_ in _loc1_)
         {
            if(!_loc2_.ended)
            {
               _loc2_.triggerCreditsComplete();
            }
         }
      }
      
      public function triggerFlashPageFinished(param1:String) : void
      {
         var _loc3_:Action = null;
         var _loc2_:Vector.<Action> = this.actions.concat();
         for each(_loc3_ in _loc2_)
         {
            if(!_loc3_.ended)
            {
               _loc3_.triggerFlashPageFinished(param1);
            }
         }
      }
      
      public function isTravelFalling() : Boolean
      {
         return false;
      }
      
      public function isSceneVisible() : Boolean
      {
         return false;
      }
      
      public function triggerSceneVisible(param1:String, param2:int) : void
      {
         var _loc4_:Action = null;
         var _loc3_:Vector.<Action> = this.actions.concat();
         for each(_loc4_ in _loc3_)
         {
            if(!_loc4_.ended)
            {
               _loc4_.handleTriggerSceneVisible(param1,param2);
            }
         }
      }
      
      public function triggerTravelFallComplete() : void
      {
         var _loc2_:Action = null;
         var _loc1_:Vector.<Action> = this.actions.concat();
         for each(_loc2_ in _loc1_)
         {
            if(!_loc2_.ended)
            {
               _loc2_.handleTriggerTravelFallComplete();
            }
         }
      }
      
      public function triggerSceneEnterState(param1:String) : void
      {
         var _loc2_:String = StringUtil.getBasename(param1);
         Ga.setCustomDimension(GA_CUSTOM_DIM_SCENE,!!_loc2_ ? _loc2_ : "");
      }
      
      public function unsuppressAchievements() : void
      {
         if(this.isAchievementsSuppressed)
         {
            this.logger.info("Saga Unsuppressing achievements");
            this.setVar(SagaVar.VAR_ACHIEVEMENTS_SUPPRESSED,false);
         }
      }
      
      public function triggerSceneExit(param1:String, param2:int) : void
      {
         var _loc4_:Action = null;
         if(this.cleanedup)
         {
            return;
         }
         this.unsuppressAchievements();
         this.travelLocator.reset();
         this.sceneUrl = null;
         Ga.setCustomDimension(GA_CUSTOM_DIM_SCENE,"");
         this.sceneLoaded = false;
         var _loc3_:Vector.<Action> = this.actions.concat();
         for each(_loc4_ in _loc3_)
         {
            if(!_loc4_.ended)
            {
               _loc4_.triggerSceneExit(param1,param2);
            }
         }
      }
      
      private function triggerMapCampExit() : void
      {
         var _loc2_:SagaTriggerDef = null;
         var _loc1_:Vector.<SagaTriggerDef> = this.getTriggersForType(SagaTriggerType.MAP_CAMP_EXIT,null);
         for each(_loc2_ in _loc1_)
         {
            this.logger.i("SAGA","   TRIGGER " + _loc2_);
            this.executeHappeningDef(_loc2_.happening,_loc2_);
         }
      }
      
      private function triggerMapCampEnter() : void
      {
         var _loc2_:SagaTriggerDef = null;
         var _loc1_:Vector.<SagaTriggerDef> = this.getTriggersForType(SagaTriggerType.MAP_CAMP_ENTER,null);
         for each(_loc2_ in _loc1_)
         {
            this.logger.i("SAGA","   TRIGGER " + _loc2_);
            this.executeHappeningDef(_loc2_.happening,_loc2_);
         }
      }
      
      public function triggerAssembleHeroesComplete() : void
      {
         var _loc2_:Action = null;
         if(this.isSurvival)
         {
            if(this.isSurvivalSettingUp)
            {
               this.incrementMasterSaveKey("num_starts");
            }
         }
         var _loc1_:Vector.<Action> = this.actions.concat();
         for each(_loc2_ in _loc1_)
         {
            if(!_loc2_.ended)
            {
               _loc2_.triggerAssembleHeroesComplete();
            }
         }
      }
      
      public function triggerAssembleHeroesExit() : void
      {
         this.survivalHandleStart();
      }
      
      public function isSceneLoaded() : Boolean
      {
         return false;
      }
      
      public function isBattleSetup() : Boolean
      {
         return false;
      }
      
      public function isBattleDeploymentStarted() : Boolean
      {
         return false;
      }
      
      protected function handleCheckBattleAborted() : void
      {
      }
      
      public function get isTravelScene() : Boolean
      {
         return false;
      }
      
      public function triggerFlashPageReady(param1:String) : void
      {
         var _loc3_:Action = null;
         var _loc2_:Vector.<Action> = this.actions.concat();
         for each(_loc3_ in _loc2_)
         {
            if(!_loc3_.ended)
            {
               _loc3_.triggerFlashPageReady(param1);
            }
         }
      }
      
      public function triggerSceneLoaded(param1:String, param2:int, param3:Boolean, param4:int) : void
      {
         var _loc6_:Action = null;
         var _loc7_:RngSampler_SeedArray = null;
         if(this.cleanedup)
         {
            return;
         }
         this.unsuppressAchievements();
         this.sceneLoaded = true;
         if(param2 >= 0)
         {
            this.sceneUrl = param1;
            this.travelLocator.travel_position = param2;
         }
         else if(!param3)
         {
            this.sceneUrl = param1;
            this.travelLocator.travel_position = -1;
         }
         if(this.sound)
         {
            this.sound.checkReleaseCurrentMusicBundle();
         }
         this.logger.i("SAGA","   LOADED " + param1);
         var _loc5_:Vector.<Action> = this.actions.concat();
         for each(_loc6_ in _loc5_)
         {
            if(!_loc6_.ended)
            {
               _loc6_.triggerSceneLoaded(param1,param4);
            }
         }
         if(!this.skipNextSave)
         {
            this.tryToAutosave();
         }
         else if(this.queuedRng)
         {
            _loc7_ = this.rng.sampler as RngSampler_SeedArray;
            _loc7_.fromJson(this.queuedRng,this.logger);
            this.queuedRng = null;
         }
         this.skipNextSave = false;
         if(param3)
         {
            this.handleCheckBattleAborted();
         }
      }
      
      public function triggerCameraAnchorReached() : void
      {
         var _loc2_:Action = null;
         var _loc1_:Vector.<Action> = this.actions.concat();
         for each(_loc2_ in _loc1_)
         {
            if(!_loc2_.ended)
            {
               _loc2_.triggerCameraAnchorReached();
            }
         }
      }
      
      public function triggerCameraSplineComplete(param1:String) : void
      {
         var _loc3_:Action = null;
         var _loc2_:Vector.<Action> = this.actions.concat();
         for each(_loc3_ in _loc2_)
         {
            if(!_loc3_.ended)
            {
               _loc3_.triggerCameraSplineComplete(param1);
            }
         }
      }
      
      public function triggerBattleDeploymentStart(param1:String) : void
      {
         var _loc3_:Action = null;
         var _loc2_:Vector.<Action> = this.actions.concat();
         for each(_loc3_ in _loc2_)
         {
            if(!_loc3_.ended)
            {
               _loc3_.triggerBattleDeploymentStart(param1);
            }
         }
      }
      
      public function triggerBattleStart() : void
      {
         var _loc4_:IBattleEntity = null;
         var _loc1_:Dictionary = new Dictionary();
         var _loc2_:BattleBoard = this.getBattleBoard();
         var _loc3_:BattleFsm = !!_loc2_ ? _loc2_.fsm as BattleFsm : null;
         for each(_loc4_ in _loc3_.participants)
         {
            if(Boolean(_loc4_.isPlayer) && _loc4_.alive && _loc1_[_loc4_.def.entityClass.race] != 1)
            {
               _loc1_[_loc4_.def.entityClass.race] = 1;
            }
         }
         if(Boolean(_loc1_["horseborn"]) && Boolean(_loc1_["dredge"]) && Boolean(_loc1_["varl"]) && Boolean(_loc1_["human"]))
         {
            this._triggerMMAAchievementOnBattleFinish = true;
         }
         this.executeHappeningById("_increment_bromance",null,null,false);
      }
      
      public function triggerBattleBoardSetup(param1:String) : void
      {
         var _loc3_:SagaTriggerDef = null;
         var _loc4_:Vector.<Action> = null;
         var _loc5_:Action = null;
         var _loc2_:Vector.<SagaTriggerDef> = this.getTriggersForType(SagaTriggerType.DEPLOYED,null);
         for each(_loc3_ in _loc2_)
         {
            if(_loc3_.location == param1)
            {
               this.logger.i("SAGA","   TRIGGER " + _loc3_);
               this.executeHappeningDef(_loc3_.happening,_loc3_);
            }
         }
         _loc4_ = this.actions.concat();
         for each(_loc5_ in _loc4_)
         {
            if(!_loc5_.ended)
            {
               _loc5_.triggerBattleSetup(param1);
            }
         }
      }
      
      public function performSpeak(param1:IBattleEntity, param2:IEntityDef, param3:String, param4:Number, param5:String, param6:String, param7:Boolean) : void
      {
         if(!param3)
         {
            throw new ArgumentError("Empty msg for performSpeak speaker=" + param1 + " anchor=" + param5);
         }
         dispatchEvent(new SpeakEvent(param1,param2,param3,param4,param5,param6,param7));
      }
      
      public function performEnableSceneWeather(param1:Boolean) : void
      {
         dispatchEvent(new EnableSceneWeatherEvent(param1));
      }
      
      public function performEnableSceneElement(param1:Boolean, param2:String, param3:Boolean, param4:Boolean, param5:Number, param6:String) : void
      {
         dispatchEvent(new EnableSceneElementEvent(param1,param2,param3,param4,param5,param6));
      }
      
      public function performWipeInConfig(param1:Number, param2:Number) : void
      {
      }
      
      public function performSceneAnimPlay(param1:String, param2:int, param3:int) : void
      {
         dispatchEvent(new SceneAnimPlayEvent(param1,param2,param3));
      }
      
      public function performSceneAnimPathStart(param1:String) : void
      {
         dispatchEvent(new SceneAnimPathEvent(SceneAnimPathEvent.START,param1));
      }
      
      public function performConversationStart(param1:Convo) : void
      {
         this.convoSceneUrl = param1.sceneUrl;
         this.convo = param1;
         dispatchEvent(new ConvoEvent(ConvoEvent.START,param1));
      }
      
      public function performPoppening(param1:Convo, param2:Boolean) : void
      {
         this.convo = param1;
      }
      
      public function performTally(param1:String, param2:Function, param3:Boolean) : void
      {
         if(param2 != null)
         {
            param2();
         }
      }
      
      public function executeActionDef(param1:ActionDef, param2:Happening, param3:IActionListener) : Action
      {
         if(!param1)
         {
            throw new ArgumentError("No actiondef");
         }
         var _loc4_:Action = Action.factory(param1,this,param2,param3);
         this.executeAction(_loc4_);
         return _loc4_;
      }
      
      public function executeAction(param1:Action) : void
      {
         this.actions.push(param1);
         param1.start();
      }
      
      public function endAllHappenings() : void
      {
         var _loc2_:* = null;
         var _loc3_:Happening = null;
         var _loc4_:Vector.<Action> = null;
         var _loc5_:Action = null;
         this._endingAllHappenings = true;
         var _loc1_:Dictionary = new Dictionary();
         for(_loc2_ in this.happenings)
         {
            _loc1_[_loc2_] = this.happenings[_loc2_];
         }
         for each(_loc3_ in _loc1_)
         {
            _loc3_.end(true);
         }
         _loc4_ = this.actions.concat();
         for each(_loc5_ in _loc4_)
         {
            if(!_loc5_.ended)
            {
               _loc5_.end(true);
            }
         }
         this.happenings = new Dictionary();
         this.actions = new Vector.<Action>();
         this._endingAllHappenings = false;
      }
      
      public function executeHappeningById(param1:String, param2:IHappeningDefProvider, param3:*, param4:Boolean = true) : IHappening
      {
         var _loc5_:HappeningDef = this.getHappeningDefById(param1,param2,param4);
         if(_loc5_)
         {
            return this.executeHappeningDef(_loc5_,param3);
         }
         return null;
      }
      
      public function getHappeningDefById(param1:String, param2:IHappeningDefProvider, param3:Boolean = true) : HappeningDef
      {
         var _loc5_:IHappeningDefProvider = null;
         var _loc6_:* = null;
         if(!param1)
         {
            return null;
         }
         var _loc4_:HappeningDef = null;
         if(param2)
         {
            _loc4_ = param2.getHappeningDef(param1);
         }
         if(!_loc4_)
         {
            for each(_loc5_ in this.happeningDefProviders)
            {
               if(_loc5_ != param2)
               {
                  _loc4_ = _loc5_.getHappeningDef(param1);
                  if(_loc4_)
                  {
                     break;
                  }
               }
            }
         }
         if(!_loc4_)
         {
            _loc6_ = "";
            if(param2)
            {
               _loc6_ += param2;
            }
            for each(_loc5_ in this.happeningDefProviders)
            {
               if(_loc5_ != param2)
               {
                  if(_loc6_)
                  {
                     _loc6_ += ",";
                  }
                  _loc6_ += _loc5_.providerName;
               }
            }
            if(param3)
            {
               this.logger.error("Unable to find happening [" + param1 + "] in providers [" + _loc6_ + "]");
            }
            return null;
         }
         return _loc4_;
      }
      
      public function executeHappeningDef(param1:HappeningDef, param2:*) : IHappening
      {
         var _loc3_:IHappening = this.preExecuteHappeningDef(param1,param2);
         _loc3_.execute();
         return _loc3_;
      }
      
      public function isHappeningHappening(param1:HappeningDef) : Boolean
      {
         var _loc2_:Happening = null;
         for each(_loc2_ in this.happenings)
         {
            if(!_loc2_.ended)
            {
               if(_loc2_.def == param1 && _loc2_.def.id == param1.id && _loc2_.def.bag == param1.bag)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function preExecuteHappeningDef(param1:HappeningDef, param2:*) : IHappening
      {
         var _loc3_:IBattleBoard = null;
         var _loc4_:Happening = null;
         for each(_loc4_ in this.happenings)
         {
            if(!_loc4_.ended)
            {
               if(_loc4_.def == param1)
               {
                  throw new IllegalOperationError("Attempt to double-execute happening " + _loc4_);
               }
               if(_loc4_.def.id == param1.id)
               {
                  if(_loc4_.def.bag == param1.bag)
                  {
                     throw new IllegalOperationError("Attempt to double-execute happening " + _loc4_);
                  }
               }
            }
         }
         _loc3_ = this.getBattleBoard();
         if(_loc3_)
         {
            _loc3_.checkVars();
         }
         _loc4_ = new Happening(this,param1,param2);
         this.happenings[_loc4_] = _loc4_;
         _loc4_.addEventListener(Event.COMPLETE,this.happeningCompleteHandler);
         return _loc4_;
      }
      
      public function handleActionEnded(param1:Action) : void
      {
         var _loc2_:int = 0;
         if(param1.ended)
         {
            _loc2_ = this.actions.indexOf(param1);
            if(_loc2_ >= 0)
            {
               this.actions.splice(_loc2_,1);
            }
         }
      }
      
      public function get paused() : Boolean
      {
         return this._pauses.length > 0;
      }
      
      protected function handlePausedChanged() : void
      {
      }
      
      public function pause(param1:Object) : void
      {
         this._pauses.push(param1);
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("   %%% SAGA PAUSE " + this._pauses.length + " [" + param1 + "]");
         }
         if(this._pauses.length == 1)
         {
            dispatchEvent(new Event(SagaEvent.EVENT_PAUSE));
            this.handlePausedChanged();
         }
      }
      
      private function get debugPauseString() : String
      {
         var _loc2_:Object = null;
         var _loc1_:String = "";
         if(this._pauses.length == 0)
         {
            return _loc1_;
         }
         for each(_loc2_ in this._pauses)
         {
            _loc1_ += _loc2_ + " ";
         }
         return _loc1_;
      }
      
      public function unpause(param1:Object) : void
      {
         if(this.cleanedup)
         {
            return;
         }
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("   %%% SAGA UNPAUSE " + this._pauses.length + " [" + param1 + "]");
         }
         var _loc2_:int = this._pauses.indexOf(param1);
         if(_loc2_ < 0)
         {
            this.logger.error("Attempt to unpause with invalid reason [" + param1 + "]");
            return;
         }
         this._pauses.splice(_loc2_,1);
         if(this._pauses.length == 0)
         {
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("   %%% SAGA UNPAUSED");
            }
            dispatchEvent(new Event(SagaEvent.EVENT_PAUSE));
            this.handlePausedChanged();
         }
      }
      
      private function forceUnpause() : void
      {
         if(this._pauses.length > 0)
         {
            this._pauses.splice(0,this._pauses.length);
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("   %%% SAGA UNPAUSED");
            }
            dispatchEvent(new Event(SagaEvent.EVENT_PAUSE));
         }
      }
      
      public function get camped() : Boolean
      {
         return this._camped;
      }
      
      public function set camped(param1:Boolean) : void
      {
         if(this.cleanedup)
         {
            return;
         }
         if(this._camped == param1)
         {
            return;
         }
         this._camped = param1;
         this.setVar(SagaVar.VAR_CAMPED,this._camped);
         if(this._camped)
         {
            this.campMusic.resetCampMusicTimer();
            this.setHalting(null,"saga camped");
         }
         else
         {
            this.decrementTalkies();
            this.cancelHalting("saga uncamped");
         }
         this.campTalkies = new Dictionary();
         this.performCamped();
         if(this._camped)
         {
            this.campSeed = this.rng.nextInt();
         }
         else
         {
            this.campSeed = 0;
         }
         dispatchEvent(new Event(SagaEvent.EVENT_CAMP));
      }
      
      protected function performCamped() : String
      {
         return null;
      }
      
      public function setHalting(param1:String, param2:String) : void
      {
         if(this.cleanedup)
         {
            return;
         }
         ++this._halting;
         this.haltLocation = param1;
         this.logger.i("SAGA","   /,/ DO-HALTING " + param2);
         if(this._halting == 1)
         {
            dispatchEvent(new Event(SagaEvent.EVENT_HALTING));
         }
         this.checkInstantHalt();
      }
      
      public function cancelHalting(param1:String) : void
      {
         if(this._halting == 0)
         {
            return;
         }
         this.logger.i("SAGA","   /,/ UN-HALTING " + param1 + " from _halting=" + this._halting);
         --this._halting;
         this.checkInstantHalt();
         if(this._halting == 0)
         {
            dispatchEvent(new Event(SagaEvent.EVENT_HALTING));
         }
      }
      
      protected function cancelAllHalting() : void
      {
         if(this._halting == 0 && !this._halted)
         {
            return;
         }
         this._halting = 0;
         this.checkInstantHalt();
         if(this._halting == 0)
         {
            dispatchEvent(new Event(SagaEvent.EVENT_HALTING));
         }
      }
      
      protected function handleHalted() : void
      {
      }
      
      public function set halted(param1:Boolean) : void
      {
         if(this.cleanedup)
         {
            return;
         }
         if(param1 == this._halted)
         {
            return;
         }
         this._halted = param1;
         this.logger.i("SAGA","   ··· HALTED " + this._halted);
         if(!this._halted)
         {
            this.caravanCameraLock = true;
            this.cancelAllHalting();
         }
         dispatchEvent(new Event(SagaEvent.EVENT_HALT));
      }
      
      public function get halted() : Boolean
      {
         return this._halted > 0;
      }
      
      public function get halting() : Boolean
      {
         return this._halting > 0;
      }
      
      public function get haltingCount() : int
      {
         return this._halting;
      }
      
      public function get haltToCamp() : Boolean
      {
         return this._haltToCamp;
      }
      
      public function setCaravanById(param1:String) : void
      {
         var _loc2_:Caravan = null;
         if(this.cleanedup)
         {
            return;
         }
         if(param1)
         {
            _loc2_ = this.getCaravan(param1) as Caravan;
            if(!_loc2_)
            {
               this.logger.error("Saga.setCaravanById [" + param1 + "] no such caravan");
            }
            this.caravan = _loc2_;
         }
         else
         {
            this.caravan = null;
         }
      }
      
      public function addHappeningDefProvider(param1:IHappeningDefProvider) : void
      {
         this.happeningDefProviders.splice(0,0,param1);
      }
      
      public function removeHappeningDefProvider(param1:IHappeningDefProvider) : void
      {
         var _loc3_:Vector.<Happening> = null;
         var _loc4_:Happening = null;
         if(!this.happeningDefProviders)
         {
            return;
         }
         var _loc2_:int = this.happeningDefProviders.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.happeningDefProviders.splice(_loc2_,1);
            _loc3_ = null;
            for each(_loc4_ in this.happenings)
            {
               if(_loc4_.def.bag == param1)
               {
                  if(!_loc4_.def.transcendent)
                  {
                     if(!_loc3_)
                     {
                        _loc3_ = new Vector.<Happening>();
                     }
                     _loc3_.push(_loc4_);
                  }
               }
            }
            for each(_loc4_ in _loc3_)
            {
               _loc4_.end(false);
            }
         }
      }
      
      public function handleCampTalkieSeen(param1:String) : void
      {
         this.campTalkies[param1] = param1;
      }
      
      public function getDay() : Number
      {
         var _loc1_:IVariable = this._vars._global.fetch(SagaVar.VAR_DAY,null);
         return !!_loc1_ ? _loc1_.asNumber : 0;
      }
      
      public function setDay(param1:Number) : void
      {
         if(this.cleanedup)
         {
            return;
         }
         var _loc2_:IVariable = this._vars._global.fetch(SagaVar.VAR_DAY,null);
         if(_loc2_)
         {
            _loc2_.asAny = param1;
         }
      }
      
      public function restOneDay() : void
      {
         if(this._resting)
         {
            return;
         }
         if(this.restTimer)
         {
            return;
         }
         this.resting = true;
         this.rest_start_wallclock = getTimer();
         this.rest_start_day = this.getDay();
         this.rest_end_day = this.rest_start_day + 1;
         this.restTimer = new Timer(10,0);
         this.restTimer.addEventListener(TimerEvent.TIMER,this.restTimerHandler);
         this.restTimer.start();
      }
      
      private function restTimerHandler(param1:TimerEvent) : void
      {
         var _loc2_:Number = this.getDay();
         var _loc3_:* = (getTimer() - this.rest_start_wallclock) * this.rest_speed;
         var _loc4_:Number = Math.min(this.rest_start_day + 1,this.rest_start_day + _loc3_);
         this.setDay(_loc4_);
         if(_loc4_ >= this.rest_end_day)
         {
            if(this.restTimer)
            {
               this.restTimer.removeEventListener(TimerEvent.TIMER,this.restTimerHandler);
               this.restTimer.stop();
            }
            this.resting = false;
         }
      }
      
      public function get resting() : Boolean
      {
         return this._resting;
      }
      
      public function set resting(param1:Boolean) : void
      {
         if(this.cleanedup)
         {
            return;
         }
         if(this._resting == param1)
         {
            return;
         }
         this._resting = param1;
         if(!this._resting)
         {
            if(this.restTimer)
            {
               this.restTimer.removeEventListener(TimerEvent.TIMER,this.restTimerHandler);
               this.restTimer.stop();
               this.restTimer = null;
            }
         }
         dispatchEvent(new Event(SagaEvent.EVENT_RESTING));
      }
      
      public function sceneStateSave() : String
      {
         return null;
      }
      
      public function sceneStateRestore() : String
      {
         return null;
      }
      
      public function campSceneStateClear() : void
      {
      }
      
      public function campSceneStateStoreDetails(param1:String, param2:TravelLocator) : void
      {
      }
      
      public function get campSceneStateUrl() : String
      {
         return null;
      }
      
      public function get campSceneStateTravelLocator() : TravelLocator
      {
         return null;
      }
      
      public function campSceneStateRestore() : String
      {
         return null;
      }
      
      public function performWarResolution(param1:WarOutcome, param2:BattleFinishedData) : void
      {
      }
      
      public function performBattleResolution(param1:BattleFinishedData, param2:Boolean) : void
      {
      }
      
      public function performBattleFinishMusic(param1:Boolean) : void
      {
      }
      
      public function performWarRespawn(param1:int, param2:String, param3:String, param4:String) : void
      {
      }
      
      public function get logger() : ILogger
      {
         return this._logger;
      }
      
      public function get showCaravan() : Boolean
      {
         return this._showCaravan;
      }
      
      public function set showCaravan(param1:Boolean) : void
      {
         if(this.cleanedup)
         {
            return;
         }
         this._showCaravan = param1;
         dispatchEvent(new Event(SagaEvent.EVENT_SHOW_CARAVAN));
      }
      
      public function set waitForHalt(param1:Boolean) : void
      {
         if(this.cleanedup)
         {
            return;
         }
         if(!param1)
         {
            if(this._waitForHalt == 0)
            {
               this.logger.error("mismatch waitForHalt");
               return;
            }
            --this._waitForHalt;
         }
         else
         {
            ++this._waitForHalt;
         }
         this.checkInstantHalt();
      }
      
      public function get waitForHalt() : Boolean
      {
         return this._waitForHalt > 0;
      }
      
      private function checkInstantHalt() : void
      {
         if(this._halting > 0)
         {
            if(this._waitForHalt == 0 || this._camped)
            {
               this.halted = true;
            }
         }
         else
         {
            this.halted = false;
         }
      }
      
      public function forceFinishHalt() : void
      {
         if(this._halting > 0)
         {
            this.halted = true;
         }
      }
      
      public function get caravan() : Caravan
      {
         return this._caravan;
      }
      
      public function get currentICaravan() : ICaravan
      {
         return this._caravan;
      }
      
      public function set caravan(param1:Caravan) : void
      {
         if(this.caravan == param1)
         {
            return;
         }
         if(this.cleanedup && Boolean(param1))
         {
            return;
         }
         this.logger.debug("Saga.caravan=[" + param1 + "]");
         if(this._caravan)
         {
            this._caravan._legend.removeEventListener(LegendEvent.RENOWN,this.caravanLegendRenownHandler);
            this._caravan.travel_locator = this.travelLocator.clone();
         }
         this.camped = false;
         this._caravan = param1;
         if(this._caravan)
         {
            this._caravan._legend.addEventListener(LegendEvent.RENOWN,this.caravanLegendRenownHandler);
         }
         if(this.cleanedup)
         {
            return;
         }
         var _loc2_:* = !this._globalSuppressVariableFlytext;
         if(_loc2_)
         {
            this._globalSuppressVariableFlytext = true;
         }
         this.caravanLegendRenownHandler(null);
         if(_loc2_)
         {
            this._globalSuppressVariableFlytext = false;
         }
         this._applyCaravanVars();
         this.travelDrivingSpeed = 1;
         this.showCaravan = true;
         this.cancelAllHalting();
         this.notifyMapSplineChanged();
         if(!this.cleanedup)
         {
            dispatchEvent(new Event(SagaEvent.EVENT_CARAVAN));
         }
      }
      
      private function _applyCaravanVars() : void
      {
         var _loc2_:String = null;
         var _loc3_:Variable = null;
         if(!this._caravan)
         {
            return;
         }
         var _loc1_:Array = ArrayUtil.getDictionaryKeys(this._caravan.vars.vars);
         _loc1_.sort();
         for each(_loc2_ in _loc1_)
         {
            _loc3_ = this._caravan.vars.vars[_loc2_];
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("Saga.caravan increment var " + _loc3_);
            }
            this.triggerVariableIncrement(_loc3_,_loc3_.def.lowerBound);
            this.triggerVariableThresholdUp(_loc3_,_loc3_.def.lowerBound);
         }
      }
      
      private function caravanLegendRenownHandler(param1:Event) : void
      {
         var _loc2_:Boolean = false;
         if(this._caravan)
         {
            _loc2_ = this._suppressVariableFlytext;
            if(!_loc2_)
            {
               this.suppressVariableFlytext = true;
            }
            this.setVar(SagaVar.VAR_RENOWN,this._caravan._legend.renown);
            if(!_loc2_)
            {
               this.suppressVariableFlytext = false;
            }
         }
      }
      
      public function get mapCamp() : Boolean
      {
         return this._mapCamp;
      }
      
      public function performMapCamp(param1:String, param2:String, param3:String, param4:Number, param5:Boolean) : void
      {
         if(this.cleanedup)
         {
            return;
         }
         this._mapCamp = true;
         this.mapCampAnchor = param2;
         this.mapCampSpline = param3;
         this.mapCampSplineT = param4;
         this._mapCampCinema = param5;
         if(param5)
         {
            LandscapeViewConfig.disableClickables = true;
            LandscapeViewConfig.forceTooltips = true;
         }
         this.handlePerformMapCamp(param1,param2,param3,param4,param5);
         dispatchEvent(new Event(SagaEvent.EVENT_MAP_CAMP));
         this.triggerMapCampEnter();
      }
      
      public function performStopMapCamp() : void
      {
         if(this.cleanedup)
         {
            return;
         }
         if(!this._mapCamp)
         {
            return;
         }
         LandscapeViewConfig.disableClickables = false;
         this._mapCamp = false;
         this._mapCampCinema = false;
         dispatchEvent(new Event(SagaEvent.EVENT_MAP_CAMP));
         this.triggerMapCampExit();
      }
      
      public function get mapCampCinema() : Boolean
      {
         return this._mapCampCinema;
      }
      
      protected function handlePerformMapCamp(param1:String, param2:String, param3:String, param4:Number, param5:Boolean) : void
      {
      }
      
      public function get hudHornEnabled() : Boolean
      {
         if(this.cleanedup)
         {
            return false;
         }
         return this.getVarBool(SagaVar.VAR_HUD_HORN_ENABLED);
      }
      
      public function get minutesPlayed() : int
      {
         if(this.cleanedup)
         {
            return 0;
         }
         return this.getVarInt(SagaVar.VAR_PLAY_MINUTES);
      }
      
      public function get caravanCameraLock() : Boolean
      {
         if(LandscapeViewConfig.FORCE_UNLOCK_CAMERA_PAN)
         {
            return false;
         }
         return this._caravanCameraLock;
      }
      
      public function set caravanCameraLock(param1:Boolean) : void
      {
         if(this.cleanedup)
         {
            return;
         }
         this._caravanCameraLock = param1;
         dispatchEvent(new Event(SagaEvent.EVENT_CARAVAN_CAMERA_LOCK));
      }
      
      public function resetAllVars() : void
      {
         var _loc1_:Caravan = null;
         var _loc2_:int = 0;
         var _loc3_:IEntityDef = null;
         var _loc4_:VariableBag = null;
         this.videoReturnsToStartScene = false;
         this._globalSuppressTriggerVariableResponse = true;
         this._globalSuppressVariableFlytext = true;
         this._globalSuppressVariableFlytext = true;
         if(this.def.cast)
         {
            _loc2_ = 0;
            while(_loc2_ < this.def.cast.numEntityDefs)
            {
               _loc3_ = this.def.cast.getEntityDef(_loc2_);
               if(_loc3_.entityClass.playerClass)
               {
                  _loc4_ = _loc3_.vars as VariableBag;
                  if(_loc4_)
                  {
                     _loc4_.resetAll();
                     _loc3_.synchronizeToVars();
                  }
               }
               _loc2_++;
            }
         }
         for each(_loc1_ in this.caravans)
         {
            _loc1_.vars.resetAll();
            _loc1_.initVars();
            _loc1_.setupStartingRoster();
         }
         this._vars.resetAll();
         this.initVars();
         this.setVar(SagaVar.VAR_GP,PlatformInput.lastInputGp);
         this._globalSuppressVariableFlytext = false;
         this._globalSuppressTriggerVariableResponse = false;
         this._globalSuppressVariableFlytext = false;
      }
      
      public function resetMasterSave() : void
      {
         this.masterSave = null;
         this.masterSaveChildren = new Dictionary();
      }
      
      public function get hudMapEnabled() : Boolean
      {
         return this.getVarBool(SagaVar.VAR_HUD_MAP_ENABLED);
      }
      
      public function get hudCampEnabled() : Boolean
      {
         return this.getVarBool(SagaVar.VAR_HUD_CAMP_ENABLED);
      }
      
      public function get hudTravelEnabled() : Boolean
      {
         return this.getVarBool(SagaVar.VAR_HUD_TRAVEL_ENABLED);
      }
      
      public function get soundDaySuppressed() : Boolean
      {
         return this.getVarBool(SagaVar.VAR_SOUND_DAY_SUPPRESSED);
      }
      
      public function get doomsdayChoiceSoundEnabled() : Boolean
      {
         return this.getVarBool(SagaVar.VAR_DOOMSDAY_CHOICE_SOUND_ENABLED);
      }
      
      public function get hudTravelHidden() : Boolean
      {
         return this.getVarBool(SagaVar.VAR_HUD_TRAVEL_HIDDEN);
      }
      
      public function get cameraPanning() : int
      {
         return this._cameraPanning;
      }
      
      public function set cameraPanning(param1:int) : void
      {
         if(this.cleanedup)
         {
            return;
         }
         this._cameraPanning = param1;
         dispatchEvent(new Event(SagaEvent.EVENT_CAMERA_PANNING));
      }
      
      public function gotoBookmark(param1:String, param2:Boolean) : void
      {
         var _loc3_:HappeningDef = null;
         if(param2)
         {
            SagaCheat.devCheat("Saga.gotoBookmark " + param1);
         }
         _loc3_ = this.def.happenings.getHappeningDef(param1);
         if(!_loc3_)
         {
            this.logger.error("No such bookmark: " + param1);
            return;
         }
         this.sound.stopAllSounds();
         this.performClearGuiDialog();
         this.endAllHappenings();
         this.resetAllVars();
         this.convo = null;
         this._haltToCamp = false;
         this.forceUnpause();
         this._halting = 0;
         this.halted = false;
         this.camped = false;
         this.resting = false;
         this._globalSuppressVariableFlytext = true;
         this._suppressSceneStateSave = true;
         SagaAchievements.setupSaga(this);
         this.devBookmarked = true;
         this.executeHappeningDef(_loc3_,"bookmark:" + param1);
         this._globalSuppressVariableFlytext = false;
         this._suppressSceneStateSave = false;
      }
      
      public function set devBookmarked(param1:Boolean) : void
      {
         this.setVar("dev_bookmarked",param1);
         if(param1)
         {
            Ga.stop("Saga.devBookmarked");
         }
      }
      
      public function get devBookmarked() : Boolean
      {
         return this.getVarBool("dev_bookmarked");
      }
      
      public function get isDevCheat() : Boolean
      {
         return this.getVarBool("dev_cheat");
      }
      
      public function get suppressVariableFlytext() : Boolean
      {
         return this._suppressVariableFlytext;
      }
      
      public function set suppressVariableFlytext(param1:Boolean) : void
      {
         if(this.cleanedup)
         {
            return;
         }
         if(this._suppressVariableFlytext == param1)
         {
            return;
         }
         this._suppressVariableFlytext = param1;
      }
      
      public function showSagaMarket() : void
      {
         dispatchEvent(new Event(SagaEvent.EVENT_SHOW_MARKET));
      }
      
      public function canSave(param1:Happening, param2:String) : Boolean
      {
         var _loc3_:Happening = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:Action = null;
         if(!ALLOW_SAVE)
         {
            this.cannotSaveReason = "!ALLOW_SAVE";
            return false;
         }
         if(!param2)
         {
            if(Boolean(this.convo) && !this.convo.finished)
            {
               this.cannotSaveReason = "(convo && !convo.finished)";
               return false;
            }
            if(!this.sceneLoaded)
            {
               this.cannotSaveReason = "!sceneLoaded";
               return false;
            }
            if(!this.sceneUrl)
            {
               this.cannotSaveReason = "!sceneUrl";
               return false;
            }
            if(Boolean(this._halting) && !this._halted)
            {
               this.cannotSaveReason = "_halting && !_halted";
               return false;
            }
            if(this._mapCamp)
            {
               this.cannotSaveReason = "_mapCamp";
               return false;
            }
         }
         for each(_loc3_ in this.happenings)
         {
            if(!(_loc3_.ended || _loc3_ == param1 || _loc3_.def.allow_saves))
            {
               _loc4_ = !!_loc3_.def ? _loc3_.def.id : "UNKNOWN";
               _loc5_ = Boolean(_loc3_.def) && Boolean(_loc3_.def.bag) ? _loc3_.def.bag.providerName : "UNKNOWN";
               _loc6_ = Boolean(_loc3_.action) && Boolean(_loc3_.action.def) ? _loc3_.action.def.labelString : "UNKNOWN";
               this.cannotSaveReason = "happening: [" + _loc4_ + "] action [ " + _loc6_ + "] in [" + _loc5_ + "] bag";
               return false;
            }
         }
         if(!param2)
         {
            if(Boolean(this.actions) && this.actions.length > 0)
            {
               for each(_loc7_ in this.actions)
               {
                  if(!(_loc7_.ended || !_loc7_.happening || _loc7_.happening.def.allow_saves))
                  {
                     if(!(Boolean(param1) && _loc7_.happening == param1))
                     {
                        this.cannotSaveReason = "action: [" + _loc7_ + "]";
                        return false;
                     }
                  }
               }
            }
            if(!this.camped && this.travelLocator.travel_position < 0)
            {
            }
            if(this.isStartScene)
            {
               this.cannotSaveReason = "isStartScene";
               return false;
            }
         }
         this.cannotSaveReason = "OK";
         return true;
      }
      
      public function get isStartScene() : Boolean
      {
         return this.sceneUrl == this.def._startUrl || this.gameSceneUrl == this.def._startUrl;
      }
      
      public function takeScreenshot(param1:Boolean) : ByteArray
      {
         return null;
      }
      
      public function saveSaga(param1:String, param2:Happening, param3:String, param4:Boolean = false) : SagaSave
      {
         return null;
      }
      
      public function loadSaga(param1:String, param2:String, param3:int) : void
      {
      }
      
      public function loadExistingSave(param1:SagaSave, param2:int) : void
      {
      }
      
      private function doubleCheckLastItemId(param1:int) : int
      {
         var _loc2_:int = 0;
         var _loc3_:Caravan = null;
         var _loc4_:IEntityDef = null;
         var _loc5_:ILegend = null;
         var _loc6_:Item = null;
         for each(_loc3_ in this.caravans)
         {
            _loc5_ = _loc3_._legend;
            for each(_loc6_ in _loc5_.items.items)
            {
               _loc2_ = Item.getNumberFromName(_loc6_.id);
               param1 = Math.max(_loc2_,param1);
            }
         }
         for each(_loc4_ in this.def.cast)
         {
            if(_loc4_.defItem)
            {
               _loc2_ = Item.getNumberFromName(_loc4_.defItem.id);
               param1 = Math.max(_loc2_,param1);
            }
         }
         return param1;
      }
      
      public function autoTrackPageView() : void
      {
         if(this.isSurvival)
         {
            if(this.isSurvivalSettingUp)
            {
               this.trackPageView("survival_setup");
            }
            else if(!this.isSurvivalSetup)
            {
               this.trackPageView("survival_start");
            }
            else
            {
               this.trackPageView("survival_" + StringUtil.padLeft(this.survivalProgress.toString(),"0",2));
            }
         }
         else
         {
            this.trackPageView("saga_" + this.lastChapterSaveId);
         }
      }
      
      public function loadFromSave(param1:SagaSave) : void
      {
         var _loc3_:CaravanSave = null;
         var _loc4_:String = null;
         var _loc7_:String = null;
         var _loc8_:Caravan = null;
         var _loc9_:Travel_FallData = null;
         var _loc10_:Travel_WipeData = null;
         if(SagaDef.PREVIEW_BUILD)
         {
            if(!param1.globalVars[VAR_PREVIEWBUILD])
            {
               this.performGuiDialog("Incompatible Save File","This save file is incompatible with the preview build:\n\n" + param1,"ok",null,null);
               return;
            }
         }
         else
         {
            delete param1.globalVars[VAR_PREVIEWBUILD];
         }
         this.trackPageView("load");
         if(param1.survival_record)
         {
            if(this.survival)
            {
               this.survival.record = param1.survival_record;
            }
         }
         this.startHappening = param1.startHappening;
         this.firstBuildVersion = param1.build_first;
         this.date_start = param1.date_start;
         this.battleMusicDefUrl = param1.battleMusicDefUrl;
         this.lastChapterSaveId = param1.last_chapter_save_id;
         this.lastCheckpointSaveId = param1.last_checkpoint_save_id;
         this.selectedVariable = param1.selectedVariable;
         if(!this.lastChapterSaveId)
         {
            if(param1.isSaveChapter)
            {
               this.lastChapterSaveId = param1.id;
               this.lastCheckpointSaveId = param1.id;
            }
         }
         if(!this.lastCheckpointSaveId)
         {
            if(param1.isSaveCheckpoint)
            {
               this.lastCheckpointSaveId = param1.id;
            }
         }
         if(SagaSave.SAVE_PLATFORM_DATA)
         {
            for each(_loc7_ in param1.achievements)
            {
               SagaAchievements.unlockAchievementById(_loc7_,0,false);
            }
         }
         this.unlistenToCastVars();
         param1.applyCastInfo(this,null);
         this.listenToCastVars();
         this._globalSuppressTriggerVariableResponse = true;
         this._globalSuppressVariableFlytext = true;
         if(param1.globalVars)
         {
            this._vars.fromDictionary(param1.globalVars,this.logger);
         }
         var _loc2_:IVariable = this.getVar("map_tutorial",null);
         if(Boolean(_loc2_) && _loc2_.asBoolean)
         {
            this.setVar(SagaVar.VAR_HUD_HORN_ENABLED,true);
         }
         for each(_loc3_ in param1.caravans)
         {
            _loc8_ = this.getCaravan(_loc3_.name) as Caravan;
            if(!_loc8_)
            {
               this.logger.info("Saga.loadFromSave failed to find saved caravan [" + _loc3_.name + "]");
            }
            else
            {
               _loc8_.loadFromSave(_loc3_);
            }
         }
         for each(_loc4_ in param1.marketItemDefIds)
         {
            if(!this.market.addItemDefById(_loc4_))
            {
               this.logger.error("Failed to restore market item " + _loc4_);
            }
         }
         this.last_item_id = this.doubleCheckLastItemId(0);
         this.setCaravanById(param1.caravanName);
         if(param1.camped)
         {
            this.camped = true;
            this.halted = true;
            this.campSeed = param1.campSeed;
         }
         this.campSceneStateStoreDetails(param1.campSceneStateStoreUrl,param1.campSceneStateStoreTravelLocator);
         param1.applyMusicToSaga(this);
         this.skipNextSave = true;
         this.queuedRng = param1.rng;
         this._globalSuppressTriggerVariableResponse = false;
         var _loc5_:String = "_save_fixup";
         var _loc6_:HappeningDef = this.def.happenings.getHappeningDef(_loc5_);
         if(_loc6_)
         {
            this.executeHappeningDef(_loc6_,param1);
         }
         if(param1.execHappening)
         {
            this.executeHappeningById(param1.execHappening,null,param1);
         }
         else if(Boolean(param1.travelLocator) && (param1.travelLocator.travel_id || param1.travelLocator.travel_position >= 0))
         {
            this.performTravelStart(param1.sceneUrl,param1.travelLocator,_loc9_,_loc10_,null,false);
         }
         else if(param1.sceneUrl)
         {
            this.performSceneStart(param1.sceneUrl,null,true);
         }
         else if(this.camped)
         {
            this.logger.error("NO SCENE FOR CAMPED SAVE");
         }
         this.locationTimerHandler(null);
         if(param1.cheat)
         {
            this.logger.info("Loading cheated save file");
            SagaCheat.devCheat("from save file");
         }
         if(this.devBookmarked)
         {
            this.logger.info("Loading bookmarked save file");
            Ga.stop("Saga.loadFromSave devBookmarked");
         }
         else
         {
            this.notifyAllGas();
         }
         this.cartId = this.getMasterSaveKey("cartId") as String;
         this._globalSuppressVariableFlytext = false;
         this.trackPageView(param1.pageView);
         this.autoTrackPageView();
         this.sendGaCustomMetricsDimensions();
      }
      
      public function notifyMapSplineChanged() : void
      {
         if(this.cleanedup)
         {
            return;
         }
         if(this.caravan)
         {
            if(this.def.mapScene)
            {
               Saga.getMapSplinePoint(this,this.mapSplinePt,this.def.mapScene);
            }
         }
         dispatchEvent(new Event(SagaEvent.EVENT_MAP_SPLINE));
      }
      
      public function get difficulty() : int
      {
         if(this.cleanedup)
         {
            return DIFFICULTY_NORMAL;
         }
         return this.getVarInt(SagaVar.VAR_DIFFICULTY);
      }
      
      public function get difficultyId() : String
      {
         var _loc1_:int = this.difficulty;
         switch(_loc1_)
         {
            case DIFFICULTY_HARD:
               return "hard";
            case DIFFICULTY_NORMAL:
               return "norm";
            case DIFFICULTY_EASY:
               return "easy";
            default:
               return "unknown:" + _loc1_;
         }
      }
      
      public function getDifficultyStringHtml(param1:int) : String
      {
         if(!param1)
         {
            param1 = 2;
         }
         var _loc2_:String = ColorUtil.colorStr(Saga.getDifficultyColor(param1));
         return "<font color=\'" + _loc2_ + "\'>" + this.getDifficultyName(param1) + "</font>";
      }
      
      public function getDifficultyName(param1:int) : String
      {
         switch(param1)
         {
            case DIFFICULTY_HARD:
               return this.locale.translateGui("hard");
            case DIFFICULTY_NORMAL:
               return this.locale.translateGui("normal");
            case DIFFICULTY_EASY:
               return this.locale.translateGui("easy");
            default:
               return "unknown!difficulty";
         }
      }
      
      public function set difficulty(param1:int) : void
      {
         if(this.cleanedup)
         {
            return;
         }
         this.getVar(SagaVar.VAR_DIFFICULTY,VariableType.INTEGER).asInteger = param1;
      }
      
      public function set cartId(param1:String) : void
      {
         if(this.cleanedup)
         {
            return;
         }
         var _loc2_:IVariable = this.getVar(SagaVar.VAR_TRAVEL_CART_APPEARANCE,VariableType.STRING);
         _loc2_.asString = param1;
         this.setMasterSaveKey("cartId",_loc2_.asString);
      }
      
      public function get cartId() : String
      {
         if(this.cleanedup)
         {
            return null;
         }
         return this.getVar(SagaVar.VAR_TRAVEL_CART_APPEARANCE,VariableType.STRING).asString;
      }
      
      public function getInjuryDays(param1:int) : int
      {
         switch(this.difficulty)
         {
            case DIFFICULTY_HARD:
               return param1 * 2;
            case DIFFICULTY_NORMAL:
               return param1;
            default:
               return 0;
         }
      }
      
      public function getDifficultyDanger() : int
      {
         var _loc1_:SagaDifficultyDef = this.def.getDifficultyDef(this.difficulty);
         return !!_loc1_ ? _loc1_.danger : 0;
      }
      
      public function getDifficultyOverseeDefeatMod() : Number
      {
         if(this.difficulty == DIFFICULTY_EASY)
         {
            return 0.5;
         }
         return 1;
      }
      
      public function getDifficultyRenownWin() : int
      {
         if(this.difficulty == DIFFICULTY_EASY)
         {
            return 4;
         }
         return 2;
      }
      
      public function getDifficultyRenownKill() : int
      {
         return 1;
      }
      
      public function getCampSceneUrl() : String
      {
         var _loc1_:IVariable = this.getVar(SagaVar.VAR_BIOME,VariableType.INTEGER);
         var _loc2_:int = int(!!_loc1_ ? _loc1_.asInteger : 1);
         if(this.caravan)
         {
            return this.caravan.def.getCampUrlForBiome(_loc2_);
         }
         return this.def.getCampUrlForBiome(_loc2_);
      }
      
      public function getBattleSceneUrl() : String
      {
         return this.def.id + "/scene/battle/btl_training/btl_training.json.z";
      }
      
      public function getBannerLengthDef(param1:Boolean) : SagaBannerLengthDef
      {
         if(!this.def)
         {
            return null;
         }
         var _loc2_:int = int(this.getVar(SagaVar.VAR_NUM_POPULATION,VariableType.INTEGER).asInteger);
         var _loc3_:int = this.getVar(SagaVar.VAR_BANNER,VariableType.INTEGER).asInteger - 1;
         return this.def.getBannerLengthDef(param1,_loc3_,_loc2_);
      }
      
      public function getBannerLengthUrl(param1:Boolean) : String
      {
         var _loc2_:SagaBannerLengthDef = this.getBannerLengthDef(param1);
         return !!_loc2_ ? _loc2_.url : null;
      }
      
      public function injure(param1:IEntityDef, param2:Boolean, param3:Stats = null) : void
      {
         var _loc4_:Boolean = false;
         var _loc6_:* = 0;
         var _loc7_:Stat = null;
         var _loc5_:BattleBoard = this.getBattleBoard();
         if(!param2 && Boolean(_loc5_))
         {
            _loc4_ = this.inTrainingBattle;
            if(!_loc4_)
            {
               _loc4_ = this.getVarBool(SagaVar.VAR_TRAINING_SPARRING);
            }
            if(!_loc4_)
            {
               _loc4_ = this.getVarBool(SagaVar.VAR_TRAINING_SCENARIO);
            }
         }
         if(StatType.DEBUG_INJURY)
         {
            this.logger.debug("DEBUG_INJURY: injure " + param1 + " force=" + param2 + " skip=" + _loc4_);
         }
         if(!_loc4_ || param2)
         {
            if(!param3)
            {
               param3 = param1.stats;
            }
            if(_loc5_)
            {
               if(this._caravan)
               {
                  if(!this._caravan._legend.roster.getEntityDefById(param1.id))
                  {
                     this.logger.info("BattleFsm.noticeInjury ignoring non-roster member " + param1.id);
                     return;
                  }
               }
            }
            _loc6_ = 2;
            if(!this.isSurvival)
            {
               _loc7_ = param3.getStat(StatType.INJURY_DAYS,false);
               if(_loc7_)
               {
                  _loc6_ = _loc7_.value;
               }
               else
               {
                  _loc6_ = 1;
               }
               _loc6_ = this.getInjuryDays(_loc6_);
            }
            if(_loc6_ <= 0)
            {
               return;
            }
            param1.stats.getStat(StatType.INJURY).base = _loc6_;
            if(this._caravan)
            {
               this._caravan.vars.incrementVar("tot_injuries",1);
            }
            if(this.isSurvival)
            {
               this.incrementGlobalVar(SagaVar.VAR_SURVIVAL_NUM_DEATHS,1);
               this.setVar("survival_win_deaths_num",this.getVarInt(SagaVar.VAR_SURVIVAL_NUM_DEATHS));
            }
            if(Boolean(_loc5_) && Boolean(_loc5_.fsm))
            {
               if(_loc6_)
               {
                  _loc5_.fsm.noticeInjury(param1.id);
               }
               if(_loc5_.waves)
               {
                  _loc5_.waves.noticeInjury(param1.id);
               }
            }
         }
      }
      
      public function injureAll() : void
      {
         var _loc2_:IEntityDef = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.def.cast.numEntityDefs)
         {
            _loc2_ = this.def.cast.getEntityDef(_loc1_);
            if(_loc2_)
            {
               this.injure(_loc2_,true);
            }
            _loc1_++;
         }
      }
      
      public function uninjure(param1:IEntityDef) : void
      {
         param1.stats.getStat(StatType.INJURY).base = 0;
      }
      
      public function uninjureAll() : void
      {
         var _loc2_:IEntityDef = null;
         var _loc3_:Stat = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.def.cast.numEntityDefs)
         {
            _loc2_ = this.def.cast.getEntityDef(_loc1_);
            if(_loc2_)
            {
               _loc3_ = _loc2_.stats.getStat(StatType.INJURY,false);
               if(_loc3_)
               {
                  _loc3_.base = 0;
               }
            }
            _loc1_++;
         }
      }
      
      public function showSaveLoad(param1:Boolean, param2:int, param3:Boolean) : void
      {
      }
      
      public function showSaveProfileLoad() : void
      {
      }
      
      public function showSaveProfileStart(param1:Function) : void
      {
      }
      
      public function loadMostRecentSave(param1:Boolean, param2:int) : void
      {
      }
      
      public function gainItemDef(param1:ItemDef) : Item
      {
         if(!this.caravan)
         {
            return null;
         }
         var _loc2_:Item = this.createItemByDefId(param1.id);
         if(this.gainItem(_loc2_))
         {
            return _loc2_;
         }
         return null;
      }
      
      public function gainItem(param1:Item, param2:Boolean = false) : Boolean
      {
         if(!this.caravan || !param1)
         {
            return false;
         }
         if(this._caravan._legend._items.getItem(param1.id))
         {
            if(!param2)
            {
               throw new ArgumentError("caravan already has item " + param1);
            }
            this.logger.info("Duplicating item " + param1);
            param1 = this.createItemByDefId(param1.def.id);
         }
         this._caravan._legend._items.addItem(param1);
         if(param1.def.rank == 5 || param1.def.rank == 10)
         {
            this.triggerItemGained(param1);
         }
         return true;
      }
      
      public function createItemByName(param1:String) : Item
      {
         var _loc2_:String = Item.getDefIdFromName(param1);
         var _loc3_:int = Item.getNumberFromName(param1);
         var _loc4_:ItemDef = this.def.itemDefs.getItemDef(_loc2_);
         if(!_loc4_)
         {
            this.logger.error("Saga.createItemByName no such item def [" + _loc2_ + "]");
            return null;
         }
         var _loc5_:Item = new Item();
         _loc5_.id = param1;
         _loc5_.def = _loc4_;
         _loc5_.defid = _loc4_.id;
         return _loc5_;
      }
      
      public function createItemByDefId(param1:String) : Item
      {
         var _loc2_:String = Item.createName(param1,++this.last_item_id);
         return this.createItemByName(_loc2_);
      }
      
      public function getSagaBucket(param1:String) : SagaBucket
      {
         if(param1 == BUCKET_TRAINING)
         {
            return this.getTrainingBucket();
         }
         return this.def.buckets.getSagaBucket(param1);
      }
      
      public function getTrainingBucket() : SagaBucket
      {
         var _loc1_:SagaBucket = this.def.buckets.getSagaBucket(BUCKET_TRAINING_HUMAN);
         var _loc2_:SagaBucket = this.def.buckets.getSagaBucket(BUCKET_TRAINING_VARL);
         if(!this.caravan)
         {
            return _loc2_;
         }
         if(!this.trainingBucket)
         {
            this.trainingBucket = new SagaBucket();
         }
         this.trainingBucket.clear();
         var _loc3_:int = int(this.getVar(SagaVar.VAR_NUM_FIGHTERS,VariableType.INTEGER).asInteger);
         var _loc4_:int = int(this.getVar(SagaVar.VAR_NUM_VARL,VariableType.INTEGER).asInteger);
         var _loc5_:int = 0;
         _loc5_ = 0;
         while(_loc5_ < _loc1_._ents.length)
         {
            this.trainingBucket.addEntity(_loc1_._ents[_loc5_],true);
            _loc5_++;
         }
         if(_loc4_ >= 6)
         {
            _loc5_ = 0;
            while(_loc5_ < _loc2_._ents.length)
            {
               this.trainingBucket.addEntity(_loc2_._ents[_loc5_],true);
               _loc5_++;
            }
         }
         return this.trainingBucket;
      }
      
      public function performTraining() : void
      {
         if(!this.caravan)
         {
            return;
         }
         var _loc1_:String = this.caravan.def.trainingPopUrl;
         if(!_loc1_)
         {
            this.performTrainingBattle();
            return;
         }
         this.setVar(SagaVar.VAR_TRAINING_SPARRING,false);
         this.setVar(SagaVar.VAR_TRAINING_SCENARIO,false);
         this.setVar(SagaVar.VAR_TUTORIAL_SKIPPABLE,false);
         var _loc2_:ActionDef = new ActionDef(null);
         _loc2_.type = ActionType.POPUP;
         _loc2_.instant = true;
         _loc2_.url = _loc1_;
         this.executeActionDef(_loc2_,null,null);
      }
      
      public function computeTrainingQuota() : int
      {
         var _loc4_:int = 0;
         if(!this._caravan || !this._caravan._legend)
         {
            return 10;
         }
         var _loc1_:IPartyDef = this._caravan._legend.party;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         while(_loc3_ < _loc1_.numMembers)
         {
            _loc4_ = _loc1_.getMember(_loc3_).stats.rank - 1;
            _loc2_ += _loc4_;
            _loc3_++;
         }
         _loc2_ = Math.min(20,_loc2_);
         _loc2_ += this.getDifficultyDanger();
         return Math.max(1,_loc2_);
      }
      
      public function performTrainingBattle() : void
      {
         if(!this.caravan)
         {
            return;
         }
         this.setVar(SagaVar.VAR_TRAINING_SPARRING,true);
         this.setVar(SagaVar.VAR_TRAINING_SCENARIO,false);
         this.setVar(SagaVar.VAR_TUTORIAL_SKIPPABLE,false);
         this.inTrainingBattle = true;
         var _loc1_:int = this.computeTrainingQuota();
         var _loc2_:ActionDef = new ActionDef(null);
         _loc2_.type = ActionType.BATTLE;
         _loc2_.instant = false;
         _loc2_.restore_scene = true;
         _loc2_.scene = this.getBattleSceneUrl();
         _loc2_.assemble_heroes = true;
         _loc2_.bucket_quota = _loc1_;
         _loc2_.board_id = "board_0,board_1,board_2,board_3,board_4,board_5,board_6";
         _loc2_.bucket = Saga.BUCKET_TRAINING;
         _loc2_.battle_sparring = true;
         var _loc3_:Action_Battle = this.executeActionDef(_loc2_,null,null) as Action_Battle;
         if(_loc3_)
         {
            _loc3_.skipResolution = true;
            _loc3_.skipRewards = true;
         }
      }
      
      public function get convo() : Convo
      {
         return this._convo;
      }
      
      public function set convo(param1:Convo) : void
      {
         if(this._convo == param1)
         {
            return;
         }
         if(this._convo)
         {
            this._convo.removeEventListener(ConvoEvent.FINISHED,this.convoFinishedHandler);
            this._convo.cleanup();
         }
         this._convo = param1;
         if(!this._convo)
         {
            this.convoSceneUrl = null;
            this.campMusic.resetCampMusicTimer();
         }
         else
         {
            this.performTutorialRemoveAll("Saga.convo " + this._convo);
            this._convo.addEventListener(ConvoEvent.FINISHED,this.convoFinishedHandler);
         }
      }
      
      private function tryToAutosave() : void
      {
         if(ALLOW_AUTOSAVE)
         {
            if(this.canSave(null,null))
            {
               this.saveSaga(SAVE_ID_RESUME,null,null,false);
            }
         }
      }
      
      private function convoFinishedHandler(param1:ConvoEvent) : void
      {
         if(param1.convo == this._convo)
         {
            this.convo = null;
            if(!this.skipNextSave)
            {
               this.tryToAutosave();
            }
         }
      }
      
      public function get global() : IVariableBag
      {
         return this._vars._global;
      }
      
      public function get icaravan() : ICaravan
      {
         return this._caravan;
      }
      
      public function get battleMusicDefUrl() : String
      {
         return !!this._battleMusicDefUrl ? this._battleMusicDefUrl : this.def.battleMusicUrl;
      }
      
      public function set battleMusicDefUrl(param1:String) : void
      {
         this._battleMusicDefUrl = param1;
      }
      
      public function trackPageView(param1:String) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         this.pageView = param1;
         if(param1 && this._vars && Boolean(this._vars._global))
         {
            Ga.trackScreen(param1);
            _loc2_ = int(this._vars._global.fetch(SagaVar.VAR_PLAY_MINUTES,VariableType.INTEGER).asInteger);
            if(_loc2_ != this.lastPlayMinutes)
            {
               this.lastPlayMinutes = _loc2_;
            }
            _loc3_ = int(this._vars._global.fetch(SagaVar.VAR_DAY,VariableType.INTEGER).asInteger);
            if(_loc3_ != this.lastDay)
            {
               this.lastDay = _loc3_;
            }
         }
      }
      
      public function get profile_index() : int
      {
         return this._profile_index;
      }
      
      public function set profile_index(param1:int) : void
      {
         if(this._profile_index == param1)
         {
            return;
         }
         this._profile_index = param1;
      }
      
      public function get caravanAnimBaseUrl() : String
      {
         return !!this.def ? this.def.caravanAnimBaseUrl : null;
      }
      
      public function get caravanClosePoleUrl() : String
      {
         return !!this.def ? this.def.caravanClosePoleUrl : null;
      }
      
      public function handleSceneDestruction(param1:*) : void
      {
      }
      
      public function getCastMember(param1:String) : IEntityDef
      {
         var id:String = param1;
         if(!this.def || !this.def.cast || !this.global || !id)
         {
            return null;
         }
         try
         {
            id = this.performStringReplacement_SagaVar(id,true);
         }
         catch(e:Error)
         {
            this.logger.error("Saga.getCastMember failed: " + e.getStackTrace());
            return null;
         }
         return this.def.cast.getEntityDefById(id);
      }
      
      public function getScene() : Scene
      {
         return null;
      }
      
      public function getSceneUniqueId() : int
      {
         var _loc1_:Scene = this.getScene();
         return !!_loc1_ ? _loc1_.uniqueId : 0;
      }
      
      public function getBattleBoard() : BattleBoard
      {
         return null;
      }
      
      final public function getIBattleBoard() : IBattleBoard
      {
         return this.getBattleBoard();
      }
      
      public function getEntityByDefId(param1:String, param2:TileRect, param3:Boolean) : IBattleEntity
      {
         var _loc4_:IBattleBoard = this.getIBattleBoard();
         if(_loc4_)
         {
            return _loc4_.getEntityByDefId(param1,param2,param3);
         }
         return null;
      }
      
      public function getEntityByIdOrByDefId(param1:String, param2:TileRect, param3:Boolean) : IBattleEntity
      {
         var _loc4_:IBattleBoard = this.getIBattleBoard();
         if(_loc4_)
         {
            return _loc4_.getEntityByIdOrByDefId(param1,param2,param3);
         }
         return null;
      }
      
      public function sceneFadeOut(param1:Number) : void
      {
      }
      
      public function getBattleScenarioDef(param1:String) : BattleScenarioDef
      {
         var _loc5_:String = null;
         var _loc6_:IVariable = null;
         if(!param1)
         {
            return null;
         }
         if(!this.def.scenarioDefs)
         {
            throw new IllegalOperationError("Saga.getBattleScenarioDef: saga has no battle scenarios");
         }
         var _loc2_:String = param1;
         var _loc3_:int = param1.indexOf("$");
         if(_loc3_ >= 0)
         {
            _loc5_ = param1.substring(_loc3_ + 1);
            _loc6_ = this.getVar(_loc5_,null);
            if(!_loc6_)
            {
               throw new ArgumentError("No such variable [" + param1 + "]");
            }
            _loc2_ = param1.substring(0,_loc3_) + _loc6_.asString;
         }
         var _loc4_:BattleScenarioDef = this.def.scenarioDefs.fetch(_loc2_);
         if(!_loc4_)
         {
            throw new ArgumentError("Invalid scenario def id [" + _loc2_ + "] interpreted from [" + param1 + "]");
         }
         return _loc4_;
      }
      
      public function terminateWaits() : void
      {
         var _loc1_:Boolean = false;
         var _loc3_:Action = null;
         var _loc4_:ActionType = null;
         this.logger.info("Saga.terminateWaits begin");
         this.forceFinishHalt();
         var _loc2_:int = 10;
         do
         {
            if(_loc2_ <= 0)
            {
               this.logger.info("Saga.terminateWaits end");
               return;
            }
            _loc1_ = false;
            _loc2_--;
            for each(_loc3_ in this.actions)
            {
               _loc4_ = _loc3_.def.type;
               if(!_loc3_.ended)
               {
                  if(_loc3_.fastForward() || _loc3_.ended)
                  {
                     this.logger.info("Saga.terminateWaits FAST-FORWARDED " + _loc3_);
                     _loc1_ = true;
                     break;
                  }
                  this.logger.info("Saga.terminateWaits UNRESPONSIVE " + _loc3_);
               }
            }
         }
         while(_loc1_);
         
         this.logger.info("Saga.terminateWaits nothing else to do");
      }
      
      public function battleSnapshotStore(param1:String) : void
      {
         var _loc2_:BattleBoard = this.getBattleBoard();
         if(!_loc2_)
         {
            throw new IllegalOperationError("Can\'t store battle snapshot with no battle");
         }
         var _loc3_:BattleSnapshot = _loc2_.makeSnapshot();
         if(_loc3_)
         {
            this._battleSnaps[param1] = _loc3_;
            SceneLoader.aboutToLoadUrl = _loc3_.url;
         }
      }
      
      public function getBattleSnap(param1:String) : BattleSnapshot
      {
         return this._battleSnaps[param1];
      }
      
      public function battleSnapshotLoad(param1:String, param2:String) : Action
      {
         var _loc3_:BattleSnapshot = this._battleSnaps[param1];
         if(!_loc3_)
         {
            throw new IllegalOperationError("Invalid snap id [" + param1 + "]");
         }
         var _loc4_:IPartyDef = null;
         var _loc5_:ActionDef = new ActionDef(null);
         _loc5_.type = ActionType.BATTLE;
         _loc5_.instant = false;
         _loc5_.restore_scene = false;
         _loc5_.scene = _loc3_.url;
         _loc5_.assemble_heroes = false;
         _loc5_.bucket_quota = 0;
         _loc5_.happeningId = param2;
         _loc5_.bucket = null;
         _loc5_.battle_snap = param1;
         var _loc6_:Action_Battle = this.executeActionDef(_loc5_,null,null) as Action_Battle;
         if(!_loc6_)
         {
         }
         return _loc6_;
      }
      
      public function getMoraleIconUrl() : String
      {
         var _loc1_:int = int(this.getVar(SagaVar.VAR_MORALE_CATEGORY,VariableType.INTEGER).asInteger);
         _loc1_--;
         if(_loc1_ >= 0 && _loc1_ < _moraleIconUrls.length)
         {
            return _moraleIconUrls[_loc1_];
         }
         return null;
      }
      
      public function get bannerHudName() : String
      {
         var _loc1_:int = this.getVarInt(SagaVar.VAR_BANNER) - 1;
         return this.def.getBannerHudName(_loc1_);
      }
      
      public function performStringReplacement_SagaVar(param1:String, param2:Boolean = false) : String
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:* = 0;
         var _loc8_:int = 0;
         var _loc9_:String = null;
         var _loc10_:int = 0;
         var _loc11_:String = null;
         var _loc12_:Boolean = false;
         var _loc13_:IVariable = null;
         var _loc14_:* = null;
         if(!param1)
         {
            return param1;
         }
         var _loc5_:int = 1;
         _loc3_ = param1.indexOf("$");
         _loc4_ = param1.indexOf("${");
         while(_loc3_ >= 0 || _loc4_ >= 0)
         {
            if(_loc3_ >= 0 && (_loc4_ < 0 || _loc3_ < _loc4_))
            {
               _loc7_ = _loc3_;
               _loc5_ = 1;
               _loc6_ = LocaleInfo.getTokenBreakPos(param1,_loc7_);
               if(_loc6_ > _loc7_)
               {
                  _loc8_ = _loc6_ - (_loc7_ + _loc5_);
                  _loc9_ = param1.substr(_loc7_ + _loc5_,_loc8_);
                  if(this._vars.getBag(_loc9_))
                  {
                     _loc6_ = LocaleInfo.getTokenBreakPos(param1,_loc6_ + 1);
                  }
               }
            }
            else
            {
               _loc7_ = _loc4_;
               _loc5_ = 2;
               _loc6_ = param1.indexOf("}",_loc7_);
            }
            if(_loc6_ > _loc7_)
            {
               _loc10_ = _loc6_ - (_loc7_ + _loc5_);
               _loc11_ = param1.substr(_loc7_ + _loc5_,_loc10_);
               _loc12_ = false;
               if(_loc11_)
               {
                  if(_loc11_.charAt(0) == "-")
                  {
                     _loc12_ = true;
                     _loc11_ = _loc11_.substring(1);
                  }
                  _loc13_ = this.getVar(_loc11_,null);
                  _loc14_ = null;
                  if(_loc13_)
                  {
                     switch(_loc13_.def.type)
                     {
                        case VariableType.INTEGER:
                           _loc14_ = (Number(_loc13_.asInteger) * (_loc12_ ? -1 : 1)).toString();
                           break;
                        case VariableType.DECIMAL:
                           _loc14_ = (Number(_loc13_.asNumber) * (_loc12_ ? -1 : 1)).toString();
                           break;
                        default:
                           _loc14_ = _loc13_.asString;
                     }
                     if(_loc14_ == null)
                     {
                        throw new ArgumentError("Managed to get a null variable out of " + _loc13_);
                     }
                  }
                  else
                  {
                     if(param2)
                     {
                        throw new ArgumentError("no such variable for token [" + _loc11_ + "] in str [" + param1 + "]");
                     }
                     _loc14_ = "!!" + _loc11_ + "!!";
                  }
                  param1 = param1.substring(0,_loc7_) + _loc14_ + param1.substring(_loc6_ + 1);
                  _loc7_ += _loc14_.length;
               }
            }
            else
            {
               _loc7_ += _loc5_;
            }
            _loc3_ = param1.indexOf("$",_loc7_);
            _loc4_ = param1.indexOf("${",_loc7_);
         }
         return param1;
      }
      
      public function triggerBattleObjectiveOpened(param1:BattleObjective) : void
      {
         var _loc3_:Action = null;
         var _loc2_:Vector.<Action> = this.actions.concat();
         for each(_loc3_ in _loc2_)
         {
            if(!_loc3_.ended)
            {
               _loc3_.triggerBattleObjectiveOpened(param1);
            }
         }
      }
      
      public function triggerOptionsShowing(param1:Boolean) : void
      {
         var _loc3_:Action = null;
         var _loc2_:Vector.<Action> = this.actions.concat();
         for each(_loc3_ in _loc2_)
         {
            if(!_loc3_.ended)
            {
               _loc3_.triggerOptionsShowing(param1);
            }
         }
      }
      
      public function get currentPageName() : String
      {
         return null;
      }
      
      public function get isOptionsShowing() : Boolean
      {
         return false;
      }
      
      protected function hoistAchievementsFromMaster() : void
      {
         var _loc1_:AchievementDef = null;
         var _loc2_:int = 0;
         if(!this.def.master_store_achievements)
         {
            return;
         }
         for each(_loc1_ in this.achievements.defs)
         {
            _loc2_ = this.getMasterSaveKeyInt("acv." + _loc1_.id);
            if(_loc2_)
            {
               SagaAchievements.unlockAchievement(_loc1_,_loc2_,false);
            }
         }
      }
      
      public function annotateAchievementInMaster(param1:String) : void
      {
         if(!this.def.master_store_achievements)
         {
            return;
         }
         var _loc2_:int = Math.max(1,this.minutesPlayed);
         this.setMasterSaveKey("acv." + param1,_loc2_);
      }
      
      public function handleAchievementUnlocked(param1:String) : void
      {
         var _loc4_:int = 0;
         var _loc2_:AchievementDef = this.def.achievements.fetch(param1);
         if(!_loc2_)
         {
            return;
         }
         this.annotateAchievementInMaster(param1);
         if(!this.caravan)
         {
            return;
         }
         if(!this.getBattleBoard())
         {
            _loc4_ = this.getVarInt(SagaVar.VAR_RENOWN) + _loc2_.renownAwardAmount;
            this._globalSuppressVariableFlytext = true;
            this.setVar(SagaVar.VAR_RENOWN,_loc4_);
            this._globalSuppressVariableFlytext = false;
         }
         if(this.getVarBool(SagaVar.ACHIEVEMENT_FLYTEXT_SUPPRESSED))
         {
            return;
         }
         if(Platform.suppressUIAchievementNotifications)
         {
            this.logger.info("Hiding achievement UI popup. Platform.suppressUIAchievementNotifications = true");
            return;
         }
         var _loc3_:* = _loc2_.name + "\n";
         if(_loc2_.renownAwardAmount)
         {
            _loc3_ += this.locale.translateGui("renown") + " +" + _loc2_.renownAwardAmount;
         }
         this.showFlyText(_loc3_,16776960,null,0.5);
      }
      
      public function applyUnitDifficultyBonuses(param1:IBattleEntity) : void
      {
         var _loc2_:BattleBoard = this.getBattleBoard();
         if(!_loc2_ || _loc2_.difficultyDisabled || !param1 || !param1.alive)
         {
            return;
         }
         var _loc3_:SagaDifficultyDef = this.def.getDifficultyDef(this.difficulty);
         if(!_loc3_)
         {
            return;
         }
         param1.suppressFlytext = true;
         _loc2_.suppressPartyVitality = true;
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("applyUnitDifficultyBonuses " + param1);
         }
         this.applyUnitDifficultyBonus(param1,StatType.STRENGTH,_loc3_.strength);
         this.applyUnitDifficultyBonus(param1,StatType.ARMOR,_loc3_.armor);
         _loc2_.suppressPartyVitality = false;
         _loc2_.recomputePartyVitality();
         param1.suppressFlytext = false;
      }
      
      private function applyUnitDifficultyBonus(param1:IBattleEntity, param2:StatType, param3:int) : void
      {
         var _loc8_:int = 0;
         if(!param3 || !param1)
         {
            return;
         }
         if(!param1.isEnemy || !param1.mobile || !param1.alive)
         {
            return;
         }
         var _loc4_:Stat = param1.stats.getStat(param2);
         var _loc5_:* = _loc4_.base;
         var _loc6_:* = _loc4_.base > 0 ? 1 : 0;
         var _loc7_:int = Math.max(_loc6_,_loc5_ + param3);
         if(_loc7_ != _loc5_)
         {
            if(param1.def.addDifficultyStatsAsMods)
            {
               _loc8_ = _loc7_ - _loc5_;
               _loc4_.addMod(null,_loc8_,0);
            }
            else
            {
               _loc4_.internalSetOriginal(_loc7_);
               _loc4_.base = _loc7_;
            }
         }
      }
      
      public function get convoNodeIdSuffix() : String
      {
         var _loc1_:IEntityDef = this.getCastMember("$hero");
         if(!_loc1_ || !this._caravan)
         {
            return null;
         }
         if(this._caravan.leader == _loc1_.id)
         {
            switch(_loc1_.entityClass.gender)
            {
               case "female":
                  return "^f";
               case "male":
            }
            return "^m";
         }
         return null;
      }
      
      public function get isSurvival() : Boolean
      {
         return Boolean(this.def) && Boolean(this.def.survival);
      }
      
      public function get isSurvivalBattle() : Boolean
      {
         return Boolean(this.def.survival) && Boolean(this.getBattleBoard());
      }
      
      public function get isSurvivalSettingUp() : Boolean
      {
         return this.isSurvival && this.getVarBool(SagaVar.VAR_SURVIVAL_SETTING_UP);
      }
      
      public function get isSurvivalSetup() : Boolean
      {
         return this.isSurvival && this.getVarBool(SagaVar.VAR_SURVIVAL_SETUP);
      }
      
      public function get survivalProgress() : int
      {
         return this.getVarInt(SagaVar.VAR_SURVIVAL_PROGRESS);
      }
      
      public function get survivalTotal() : int
      {
         return this.getVarInt(SagaVar.VAR_SURVIVAL_TOTAL);
      }
      
      public function get survivalReloadCount() : int
      {
         return this.getVarInt(SagaVar.VAR_SURVIVAL_RELOAD_COUNT);
      }
      
      public function get survivalReloadLimit() : int
      {
         return this.getVarInt(SagaVar.VAR_SURVIVAL_RELOAD_LIMIT);
      }
      
      public function get survivalElapsedSed() : int
      {
         return this.getVarInt(SagaVar.VAR_SURVIVAL_ELAPSED_SEC);
      }
      
      public function get survivalBattleTimerSec() : int
      {
         return 30;
      }
      
      public function get survivalDeploymentTimerSec() : int
      {
         return 60;
      }
      
      public function triggerSurvivalBattleComplete() : Boolean
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(!this.getVarBool(SagaVar.VAR_BATTLE_VICTORY))
         {
            this.executeHappeningById("survival_game_over",null,"triggerSurvivalBattleComplete");
            return true;
         }
         _loc1_ = this.getVarInt(SagaVar.VAR_SURVIVAL_PROGRESS);
         _loc1_++;
         this.setVar(SagaVar.VAR_SURVIVAL_PROGRESS,_loc1_);
         _loc2_ = this.getVarInt(SagaVar.VAR_SURVIVAL_TOTAL);
         if(_loc1_ >= _loc2_)
         {
         }
         return false;
      }
      
      public function storeMasterSave() : void
      {
      }
      
      private function _createMasterSave() : void
      {
         if(!this.masterSave)
         {
            this.masterSave = {
               "build_start":this.appinfo.buildVersion,
               "build_last":this.appinfo.buildVersion
            };
         }
      }
      
      public function setMasterSaveKey(param1:String, param2:*) : void
      {
         this._createMasterSave();
         this.masterSave[param1] = param2;
         this.storeMasterSave();
      }
      
      public function getMasterSaveKeyBool(param1:String) : Boolean
      {
         return Boolean(this.masterSave) && Boolean(this.masterSave[param1]);
      }
      
      public function getMasterSaveKey(param1:String) : *
      {
         return !!this.masterSave ? this.masterSave[param1] : undefined;
      }
      
      public function getMasterSaveKeyInt(param1:String) : int
      {
         return !!this.masterSave ? int(this.masterSave[param1]) : 0;
      }
      
      public function incrementMasterSaveKey(param1:String) : void
      {
         this._createMasterSave();
         var _loc2_:int = int(this.masterSave[param1]);
         _loc2_++;
         this.masterSave[param1] = _loc2_;
         this.storeMasterSave();
      }
      
      private function handleSurvivalProgressIncrement() : void
      {
         if(!this.isSurvival)
         {
            return;
         }
         var _loc1_:String = "survival_d" + this.difficulty;
         var _loc2_:int = this.getVarInt(SagaVar.VAR_SURVIVAL_PROGRESS);
         var _loc3_:int = this.getMasterSaveKeyInt(_loc1_);
         if(_loc3_ < _loc2_)
         {
            this.logger.info("SURVIVAL updating " + _loc1_);
            this.setMasterSaveKey(_loc1_,_loc2_);
         }
         this.autoTrackPageView();
      }
      
      private function _readFromMasterInt(param1:String, param2:String = null) : void
      {
         if(!param2)
         {
            param2 = param1;
         }
         this.setVar(param1,this.getMasterSaveKeyInt(param2));
      }
      
      protected function survivalSetup() : void
      {
         if(!this.isSurvival)
         {
            return;
         }
      }
      
      public function survivalReload() : void
      {
      }
      
      private function removeOwnedItems(param1:Dictionary) : int
      {
         var _loc4_:Item = null;
         var _loc5_:IEntityListDef = null;
         var _loc6_:int = 0;
         var _loc7_:IEntityDef = null;
         var _loc2_:SagaLegend = this.caravan._legend;
         var _loc3_:int = 0;
         for each(_loc4_ in _loc2_._items.items)
         {
            if(_loc4_)
            {
               if(!param1[_loc4_.def.id])
               {
                  param1[_loc4_.def.id] = _loc2_;
                  _loc3_++;
               }
            }
         }
         _loc5_ = _loc2_.roster;
         _loc6_ = 0;
         while(_loc6_ < _loc5_.numCombatants)
         {
            _loc7_ = _loc5_.getCombatantAt(_loc6_);
            _loc4_ = _loc7_.defItem;
            if(_loc4_)
            {
               if(!param1[_loc4_.def.id])
               {
                  this.logger.info("Saga.removeOwnedItem from roster " + _loc4_ + ": " + _loc7_);
                  param1[_loc4_.def.id] = _loc7_;
                  _loc3_++;
               }
            }
            _loc6_++;
         }
         this.logger.info("Saga.removeOwnedItem removed " + _loc3_);
         return _loc3_;
      }
      
      public function generateRandomItemDefForPartyRanks() : ItemDef
      {
         var _loc1_:BattleBoard = this.getBattleBoard();
         if(!_loc1_)
         {
            return null;
         }
         var _loc2_:IBattleParty = _loc1_.getPartyById("0");
         if(!_loc2_)
         {
            return null;
         }
         var _loc3_:int = int(_loc2_.rankMin);
         var _loc4_:int = int(_loc2_.rankMax);
         return this._generateRandomItem(_loc3_,_loc4_);
      }
      
      private function _generateRandomItem(param1:int, param2:int) : ItemDef
      {
         var _loc3_:int = param1 - 1;
         var _loc4_:int = param2 + 1;
         _loc3_--;
         _loc4_--;
         var _loc5_:Vector.<ItemDef> = this.generateRandomItemList(_loc3_,_loc4_);
         var _loc6_:int = _loc5_.length;
         if(_loc6_ <= 0)
         {
            return null;
         }
         var _loc7_:int = MathUtil.randomInt(0,_loc6_ - 1);
         return _loc5_[_loc7_];
      }
      
      public function generateRandomItemList(param1:int, param2:int) : Vector.<ItemDef>
      {
         var _loc8_:Vector.<ItemDef> = null;
         var _loc12_:ItemDef = null;
         var _loc13_:* = undefined;
         if(!this.caravan)
         {
            return null;
         }
         var _loc3_:Vector.<ItemDef> = this.def.itemDefs.marketitems.concat();
         var _loc4_:int = _loc3_.length;
         if(_loc4_ <= 0)
         {
            return _loc3_;
         }
         var _loc5_:SagaLegend = this.caravan._legend;
         var _loc6_:IEntityListDef = _loc5_.roster;
         var _loc7_:Dictionary = new Dictionary();
         this.removeOwnedItems(_loc7_);
         var _loc9_:Vector.<ItemDef> = new Vector.<ItemDef>();
         var _loc10_:int = _loc3_.length;
         var _loc11_:int = 0;
         while(_loc11_ < _loc10_)
         {
            _loc12_ = _loc3_[_loc11_];
            if(_loc12_)
            {
               if(!(_loc12_.rank < param1 || param2 > 0 && _loc12_.rank > param2))
               {
                  _loc13_ = _loc7_[_loc12_.id];
                  if(_loc13_)
                  {
                     if(!_loc8_)
                     {
                        _loc8_ = new Vector.<ItemDef>();
                     }
                     _loc8_.push(_loc12_);
                  }
                  else
                  {
                     _loc9_.push(_loc12_);
                  }
               }
            }
            _loc11_++;
         }
         if(!_loc9_.length)
         {
            if(_loc8_)
            {
               this.logger.info("_generateRandomItemList EMPTY, using bakups " + _loc8_.length);
               _loc9_ = _loc8_;
            }
         }
         return _loc9_;
      }
      
      public function getVariableDefByName(param1:String) : VariableDef
      {
         return this.def.getVariableDefByName(param1);
      }
      
      public function getVariables() : Vector.<VariableDef>
      {
         return this.def.getVariables();
      }
      
      public function showDialogSurvivalReloadLimitError(param1:int) : void
      {
      }
      
      public function isSurvivalReloadable(param1:SagaSave) : Boolean
      {
         var _loc2_:int = 0;
         if(!this.isSurvival)
         {
            return true;
         }
         if(param1.survivalReloadRequired)
         {
            _loc2_ = param1.getSurvivalReloadLimit(this);
            if(param1.survivalReloadCount >= _loc2_)
            {
               return false;
            }
         }
         return true;
      }
      
      public function checkSurvivalReloadable(param1:SagaSave) : Boolean
      {
         var _loc2_:int = 0;
         if(!this.isSurvival)
         {
            return true;
         }
         if(param1.survivalReloadRequired)
         {
            _loc2_ = param1.getSurvivalReloadLimit(this);
            if(param1.survivalReloadCount >= _loc2_)
            {
               this.showDialogSurvivalReloadLimitError(_loc2_);
               return false;
            }
         }
         return true;
      }
      
      public function get iSagaSound() : ISagaSound
      {
         return this.sound;
      }
      
      public function get startUrl() : String
      {
         return !!this.def ? this.def._startUrl : null;
      }
      
      public function get rng() : Rng
      {
         return this._rng;
      }
      
      public function get unitStatCosts() : UnitStatCosts
      {
         return !!this.def ? this.def.unitStatCosts : null;
      }
      
      public function get convoAudioListDef() : ConvoAudioListDef
      {
         return !!this.def ? this.def.convoAudio : null;
      }
      
      public function get sound() : ISagaSound
      {
         return this._sound;
      }
      
      public function get locale() : Locale
      {
         return this._locale;
      }
      
      public function get expression() : ISagaExpression
      {
         return this._expression;
      }
      
      public function get achievements() : AchievementListDef
      {
         return !!this.def ? this.def.achievements : null;
      }
      
      public function get isQuitToDesktop() : Boolean
      {
         return this.getVarBool(SagaVar.VAR_QUIT_TO_DESKTOP);
      }
      
      public function get isQuitToStartHappening() : Boolean
      {
         return this.getVarBool(SagaVar.VAR_QUIT_TO_START_HAPPENING);
      }
      
      public function get cast() : IEntityListDef
      {
         return this.def.cast;
      }
      
      public function get roster() : IEntityListDef
      {
         return !!this._caravan ? this._caravan.roster : null;
      }
      
      public function get isDebugger() : Boolean
      {
         return this.appinfo.isDebugger;
      }
      
      public function get caravanVars() : IVariableBag
      {
         return !!this._caravan ? this._caravan.vars : null;
      }
      
      public function get itemDefs() : ItemListDef
      {
         return !!this.def ? this.def.itemDefs : null;
      }
      
      public function get scenePreprocessor() : ISagaScenePreprocessor
      {
         return this._scenePreprocessor;
      }
      
      public function ctorSceneLoader(param1:String, param2:Function) : SceneLoader
      {
         return null;
      }
      
      public function isTitleValid(param1:IEntityDef, param2:ITitleDef) : Boolean
      {
         return this.titleIsUnlocked(param2) && this.def.isTitleValid(param1,param2);
      }
      
      public function titleIsUnlocked(param1:ITitleDef) : Boolean
      {
         if(Boolean(param1.unlockVarName) && param1.unlockVarName != "")
         {
            return this.getVarBool(param1.unlockVarName);
         }
         return true;
      }
      
      public function quitToParentSaga() : Boolean
      {
         return false;
      }
   }
}
