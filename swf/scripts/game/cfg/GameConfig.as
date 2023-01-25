package game.cfg
{
   import com.stoicstudio.platform.PlatformFlash;
   import com.stoicstudio.platform.PlatformInput;
   import engine.achievement.AchievementListDef;
   import engine.battle.Fastall;
   import engine.battle.ability.def.BattleAbilityDefFactory;
   import engine.battle.ability.def.BattleAbilityDefFactoryVars;
   import engine.battle.ability.effect.op.def.IdEffectOpRegistry;
   import engine.battle.board.def.BattleBoardTriggerDefList;
   import engine.battle.board.def.BattleBoardTriggerDefWrangler;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.RunMode;
   import engine.core.analytic.Ga;
   import engine.core.analytic.GaConfig;
   import engine.core.gp.GpDevice;
   import engine.core.gp.GpDeviceType;
   import engine.core.gp.GpSource;
   import engine.core.locale.LocaleCategory;
   import engine.core.locale.LocaleId;
   import engine.core.locale.LocaleWrangler;
   import engine.core.locale.Localizer;
   import engine.core.logging.ILogger;
   import engine.core.pref.PrefBag;
   import engine.core.pref.SagaPrefBag;
   import engine.core.util.AppInfo;
   import engine.core.util.EngineAssetBootstrapper;
   import engine.core.util.EngineCoreContext;
   import engine.core.util.MemoryReporter;
   import engine.core.util.StableJson;
   import engine.core.util.StringUtil;
   import engine.entity.UnitStatCosts;
   import engine.entity.UnitStatCostsWrangler;
   import engine.entity.def.EntityAssetBundleManager;
   import engine.entity.def.EntityClassDefList;
   import engine.entity.def.IEntityAssetBundleManager;
   import engine.entity.def.IEntityListDef;
   import engine.entity.def.ITitleListDef;
   import engine.entity.def.ItemListDef;
   import engine.entity.def.Legend;
   import engine.fmod.FmodProjectInfo;
   import engine.gui.BattleHudConfig;
   import engine.gui.GameTextBitmapGenerator;
   import engine.gui.GuiEventEater;
   import engine.gui.GuiGpTextHelperFactory;
   import engine.gui.IGuiEventEater;
   import engine.gui.IGuiGpTextHelperFactory;
   import engine.heraldry.HeraldrySystem;
   import engine.heraldry.HeraldrySystemLoader;
   import engine.resource.AssetIndex;
   import engine.resource.ConvoDefResource;
   import engine.resource.GenerateConsoleCacheSizes;
   import engine.resource.GlobalAssetPreloader;
   import engine.resource.ResourceCache;
   import engine.resource.ResourceCensor;
   import engine.resource.ResourceManager;
   import engine.resource.ResourceTextureSizes;
   import engine.resource.def.DefWrangler;
   import engine.resource.def.DefWranglerWrangler;
   import engine.saga.IBattleBoardProvider;
   import engine.saga.Saga;
   import engine.saga.SagaCheat;
   import engine.saga.SagaDefLoader;
   import engine.saga.ScreenFlyTextEvent;
   import engine.saga.convo.def.ConvoDef;
   import engine.saga.save.SagaSave;
   import engine.saga.save.SaveManager;
   import engine.saga.vars.IBattleEntityProvider;
   import engine.scene.GlobalAmbience;
   import engine.scene.SceneControllerConfig;
   import engine.session.Alert;
   import engine.session.AlertManager;
   import engine.session.AlertOrientationType;
   import engine.session.AlertStyleType;
   import engine.session.NewsDef;
   import engine.session.NewsDefVars;
   import engine.sound.ISoundPreloader;
   import engine.sound.config.FmodSoundSystem;
   import engine.sound.config.ISoundSystem;
   import engine.subtitle.Ccs;
   import engine.tile.def.TileRect;
   import engine.user.UserLifecycleManager;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.system.Capabilities;
   import flash.text.Font;
   import flash.ui.Mouse;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import game.gui.GameGuiContext;
   import game.gui.GuiAlertManager;
   import game.gui.IGuiDialog;
   import game.saga.GameSaga;
   import game.session.GameFsm;
   import game.session.states.LoadGameState;
   import game.session.states.SagaState;
   import game.view.GamePageManagerAdapter;
   import game.view.GameScreenFlyTextManagerAdapter;
   import game.view.IDialogLayer;
   import game.view.TutorialLayer;
   import tbs.srv.data.FriendsData;
   
   public class GameConfig extends EventDispatcher implements IBattleBoardProvider, IBattleEntityProvider
   {
      
      public static const PROTOCOL_VERSION:int = 11;
      
      public static const ASSETS_VERSION:int = 8;
      
      public static const EVENT_ACCOUNT_INFO:String = "GameConfig.EVENT_ACCOUNT_INFO";
      
      public static const EVENT_FACTIONS:String = "GameConfig.EVENT_FACTIONS";
      
      public static const EVENT_SAGA:String = "GameConfig.EVENT_SAGA";
      
      public static const EVENT_SAGA_READY:String = "GameConfig.EVENT_SAGA_READY";
      
      public static const EVENT_SAGA_STARTED:String = "GameConfig.EVENT_SAGA_STARTED";
      
      public static const EVENT_TOGGLE_PERF:String = "GameConfig.EVENT_TOGGLE_PERF";
      
      public static const EVENT_TOGGLE_CONSOLE:String = "GameConfig.EVENT_TOGGLE_CONSOLE";
      
      public static const EVENT_LOCALE:String = "GameConfig.EVENT_LOCALE";
      
      public static const EVENT_FF:String = "GameConfig.EVENT_FF";
      
      public static const EVENT_BOOTSTRAPPED:String = "GameConfig.EVENT_BOOTSTRAPPED";
      
      public static const EVENT_TOGGLE_DEV_PANEL:String = "GameConfig.EVENT_TOGGLE_DEV_PANEL";
      
      public static var MEM_REPORT_ENABLED:Boolean = true;
      
      public static var MEM_REPORT_COMPLETELY_DISABLED:Boolean = false;
      
      public static var ENABLE_GP_REBINDING:Boolean = true;
      
      private static const PREFS_VERSION:int = 2;
      
      public static const PREF_NEWS_READ_DATE:String = "news_date";
      
      public static const PREF_USERNAME:String = "username";
      
      public static const PREF_BATTLE_FIRST_TIME:String = "battle_first_time";
      
      public static const PREF_STRAND_TUTORIAL_PULSE:String = "strand_tutorial_pulse";
      
      public static const PREF_PASSWORD:String = "password";
      
      public static const PREF_SERVERNAME:String = "servername";
      
      public static const PREF_SHOW_PERF:String = "show_perf";
      
      public static const PREF_GUIDEPOST_COMPLETE_:String = "guidepost_complete_";
      
      public static const PREF_LAST_DAILY_LOGIN_STREAK:String = "last_daily_login_streak";
      
      public static const PREF_OPTION_CC:String = "option_cc";
      
      public static const PREF_OPTION_CHAT:String = "option_chat";
      
      public static const PREF_OPTION_FULLSCREEN:String = "option_fullscreen";
      
      public static const PREF_LOCALE_ID_SYSTEM:String = "pref_locale_id_system";
      
      public static const PREF_LOCALE_ID_OPTION:String = "pref_locale_id_option";
      
      public static const PREF_WINDOW_WIDTH:String = "window_width";
      
      public static const PREF_WINDOW_HEIGHT:String = "window_height";
      
      public static const PREF_WINDOW_X:String = "window_x";
      
      public static const PREF_WINDOW_Y:String = "window_y";
      
      public static const EVENT_READY_TO_START:String = "GameConfig.EVENT_INITIALIZED";
      
      private static const STAT_COSTS_URL:String = "common/character/stat_costs.json.z";
      
      private static const TRIGGER_CLASS_DEFS_URL:String = "common/battle/trigger/trigger_defs.json.z";
      
      private static const STATIC_SOUND_LIBRARY_URL:String = "common/sound/sound_assets.json.z";
      
      private static const HERALDRY_URL:String = "common/heraldry/heraldry_system.json.z";
      
      private static const GLOBAL_PRELOAD_ASSET_LIST:String = "common/global_preload_assets.json.z";
      
      public static var GP_CONFIG_DISABLE:Boolean;
      
      public static var READY_DEBUG:Boolean = false;
       
      
      public var __abilityFactory:BattleAbilityDefFactoryVars;
      
      public var context:EngineCoreContext;
      
      public var animDispatcher:EventDispatcher;
      
      public var resman:ResourceManager;
      
      public var saveManager:SaveManager;
      
      public var assets:GameAssetsDef;
      
      public var fsm:GameFsm;
      
      public var runMode:RunMode;
      
      public var username:String;
      
      private var _accountInfo:AccountInfoDef;
      
      private var assetIndex:AssetIndex;
      
      public var options:GameOptions;
      
      private var readyCallback:Function;
      
      public var soundSystem:ISoundSystem;
      
      public var gameGuiContext:GameGuiContext;
      
      private var _statCosts:UnitStatCosts;
      
      private var soundDriverClazz:Class;
      
      private var __classes:EntityClassDefList;
      
      private var _triggers:BattleBoardTriggerDefList;
      
      public var dialogLayer:IDialogLayer;
      
      private var assetsConfigWrangler:DefWrangler;
      
      public var eater:IGuiEventEater;
      
      public var keybinder:GameKeyBinder;
      
      public var gpbinder:GameGpBinder;
      
      private var _buildRelease:String = "dev";
      
      public var spawnables:IEntityListDef;
      
      public var tutorialLayer:TutorialLayer;
      
      public var serverHostsQa:String;
      
      public var serverHostsLive:String;
      
      public var globalPrefs:SagaPrefBag;
      
      public var shell:GameConfigShellCmdManager;
      
      public var systemMessage:SystemMessageManager;
      
      public var purchasableUnits:PurchasableUnits;
      
      public var friends:FriendsData;
      
      public var heraldrySystem:HeraldrySystem;
      
      public var heraldryLoader:HeraldrySystemLoader;
      
      public var alerts:AlertManager;
      
      public var guiAlerts:GuiAlertManager;
      
      public var client_language:String = "en";
      
      public var battleHudConfig:BattleHudConfig;
      
      public var sceneControllerConfig:SceneControllerConfig;
      
      private var _saga:Saga;
      
      public var factions:FactionsConfig;
      
      public var globalAmbience:GlobalAmbience;
      
      public var pageManager:GamePageManagerAdapter;
      
      public var flyManager:GameScreenFlyTextManagerAdapter;
      
      public var memReport:MemoryReporter;
      
      public var enableMemReport:Boolean = false;
      
      public var textBitmapGenerator:GameTextBitmapGenerator;
      
      public var ggthFactory:IGuiGpTextHelperFactory;
      
      public var ccs:Ccs;
      
      private var bootstrapper:EngineAssetBootstrapper;
      
      private var updateFunctions:Vector.<Function>;
      
      private var finishReadyFunctions:Vector.<Function>;
      
      private var shutdownFunctions:Vector.<Function>;
      
      public var censorId:String;
      
      private var _globalAssetPreloaders:Vector.<GlobalAssetPreloader>;
      
      public var readyToStart:Boolean = false;
      
      private var _gameServerUrl:String;
      
      private var gameNumber:int = 0;
      
      public var _eabm:IEntityAssetBundleManager;
      
      private var mods:Vector.<ModDef>;
      
      private var mod_remapping:Dictionary;
      
      private var automator:GameAutomator;
      
      private var newsLoader:URLLoader;
      
      public var news:NewsDef;
      
      private var loadingSaga:SagaDefLoader;
      
      private var sagaLoadParams:SagaLoadParams;
      
      private var _sagaLoadedAndReadyToStart:Boolean;
      
      private var cleaningup:Boolean;
      
      private var changeLocaleCallback:Function;
      
      private var wranglers:DefWranglerWrangler;
      
      private var soundPreloader:ISoundPreloader;
      
      private var ready:Boolean;
      
      private var _finishedReadyForCallback:Boolean;
      
      public var stashed_account_info:AccountInfoDef;
      
      private var shownLoginStreak:Boolean;
      
      private var dialogNoGp:IGuiDialog;
      
      public function GameConfig(param1:EngineCoreContext, param2:Class, param3:Class, param4:Function, param5:IDialogLayer, param6:SaveManager, param7:int)
      {
         var _loc9_:Font = null;
         this.options = new GameOptions();
         this.battleHudConfig = new BattleHudConfig();
         this.sceneControllerConfig = new SceneControllerConfig();
         this.globalAmbience = new GlobalAmbience();
         this.ggthFactory = new GuiGpTextHelperFactory();
         this.mods = new Vector.<ModDef>();
         this.mod_remapping = new Dictionary();
         this.sagaLoadParams = new SagaLoadParams();
         super();
         param1.logger.info("Game Start: " + new Date().toString());
         param1.logger.info("Build:");
         param1.logger.info("        Version: " + param1.appInfo.buildVersion);
         param1.logger.info("             Id: " + param1.appInfo.buildId);
         param1.logger.info("Capabilities:");
         param1.logger.info("      isDebugger: " + param1.appInfo.isDebugger);
         param1.logger.info("        language: " + Capabilities.language);
         param1.logger.info("    manufacturer: " + Capabilities.manufacturer);
         param1.logger.info("              os: " + Capabilities.os);
         param1.logger.info("pixelAspectRatio: " + Capabilities.pixelAspectRatio + ", dpi: " + Capabilities.screenDPI);
         param1.logger.info("      playerType: " + Capabilities.playerType);
         param1.logger.info("      resolution: " + Capabilities.screenResolutionX + " x " + Capabilities.screenResolutionY);
         param1.logger.info(" touchscreenType: " + Capabilities.touchscreenType);
         param1.logger.info("  supportsCursor: " + Mouse.supportsCursor);
         param1.logger.info("         version: " + Capabilities.version);
         param1.logger.info("          appDir: " + param1.appInfo.applicationDirectoryUrl);
         param1.logger.info("   appStorageDir: " + param1.appInfo.applicationStorageDirectoryUrl);
         var _loc8_:Array = Font.enumerateFonts();
         param1.logger.info("AppInfo.init Embedded Fonts (" + _loc8_.length + "):");
         if(param1.logger.isDebugEnabled)
         {
            for each(_loc9_ in _loc8_)
            {
               param1.logger.debug("    Font: " + _loc9_.fontName);
               if(!_loc9_.hasGlyphs("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()_+-=.,"))
               {
                  param1.logger.error("    Font: " + _loc9_.fontName + " is INCOMPLETE");
               }
            }
         }
         this.gameNumber = param7;
         this.memReport = new MemoryReporter(param1.logger);
         this.memReport.checkMemory(0,0);
         this.ccs = new Ccs(param1.logger);
         IdEffectOpRegistry.register();
         this.context = param1;
         this.readyCallback = param4;
         this.soundDriverClazz = param3;
         this.dialogLayer = param5;
         this.eater = new GuiEventEater();
         this.alerts = new AlertManager(param1.logger);
         this.saveManager = param6;
         this.updateFunctions = new Vector.<Function>();
         this.finishReadyFunctions = new Vector.<Function>();
         this.shutdownFunctions = new Vector.<Function>();
         this.buildRelease = param1.appInfo.buildRelease;
         GpSource.dispatcher.addEventListener(GpSource.EVENT_PRIMARY_DEVICE,this.gpPrimaryDeviceHandler);
         this.accountInfo = new AccountInfoDef(this);
         PlatformInput.BLOCK_GP_DEV_MODE = param1.appInfo.checkIfDebugBlocked();
         this.globalPrefs = new SagaPrefBag("global_" + param7,PREFS_VERSION,param1.appInfo,this.logger,param6,[{
            "key":PREF_USERNAME,
            "value":""
         },{
            "key":PREF_PASSWORD,
            "value":""
         },{
            "key":PREF_SERVERNAME,
            "value":""
         },{
            "key":PREF_SHOW_PERF,
            "value":false
         },{
            "key":PREF_STRAND_TUTORIAL_PULSE,
            "value":true
         },{
            "key":"pg_help_pulse",
            "value":true
         },{
            "key":"pg_roster_first_time",
            "value":true
         },{
            "key":"pg_ability_first_time",
            "value":true
         },{
            "key":PREF_BATTLE_FIRST_TIME,
            "value":true
         },{
            "key":PREF_BATTLE_FIRST_TIME,
            "value":true
         },{
            "key":PREF_OPTION_CC,
            "value":true
         },{
            "key":PREF_OPTION_FULLSCREEN,
            "value":true
         },{
            "key":PREF_OPTION_CHAT,
            "value":true
         }]);
         if(this.globalPrefs.loaded)
         {
            this.handlePrefsLoaded();
         }
         this.globalPrefs.addEventListener(PrefBag.EVENT_LOADED,this.handlePrefsLoaded);
         GpSource.prefs = this.globalPrefs;
      }
      
      public static function getGuidepostCompletePref(param1:String) : String
      {
         return PREF_GUIDEPOST_COMPLETE_ + param1;
      }
      
      public static function massageResourcePath(param1:String, param2:ILogger, param3:String) : String
      {
         var appUrlRoot:String = param1;
         var logger:ILogger = param2;
         var path:String = param3;
         if(path == null)
         {
            path = "";
         }
         if(path)
         {
            try
            {
               path = transformUrl(appUrlRoot,path);
            }
            catch(e:Error)
            {
               logger.error("Failed to transform path " + path + ": " + e.getStackTrace());
            }
         }
         return path;
      }
      
      private static function transformUrl(param1:String, param2:String) : String
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         if(param2.indexOf("://") > 0)
         {
            return param2;
         }
         if(StringUtil.startsWith(param2,"./"))
         {
            param2 = param2.substring(1);
         }
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         while(true)
         {
            _loc9_ = param2.indexOf("../",_loc3_);
            if(_loc9_ < 0)
            {
               break;
            }
            _loc4_++;
            _loc3_ = _loc9_ + 3;
         }
         _loc5_ = param1.length - 1;
         _loc6_ = 0;
         while(_loc6_ < _loc4_)
         {
            _loc10_ = param1.lastIndexOf("/",_loc5_ - 1);
            if(_loc10_ < 0)
            {
               throw new ArgumentError("fail -- cannot descend back " + _loc6_ + "/" + _loc4_ + " folders into root [" + param1 + "]");
            }
            _loc5_ = _loc10_;
            _loc6_++;
         }
         var _loc7_:String = param1.substring(0,_loc5_ + 1);
         var _loc8_:String = param2.substring(_loc3_);
         return _loc7_ + _loc8_;
      }
      
      private function handlePrefsLoaded() : void
      {
         var _loc1_:Function = !this.readyToStart ? this.doReadyToStart : null;
         this.checkLocalePrefs();
         GaConfig.optStateFromString(this.globalPrefs.getPref(GaConfig.PREF_GA_OPTSTATE));
         this.logger.info("GA","GameConfig loaded GA state:\n" + GaConfig.getDebugString());
         if(this.resman)
         {
            this.changeLocale(this.options.locale_id.id,_loc1_,true);
         }
         else if(_loc1_ != null)
         {
            _loc1_();
         }
      }
      
      private function checkLocalePrefs() : void
      {
         var _loc1_:String = this.globalPrefs.getPref(PREF_LOCALE_ID_SYSTEM);
         var _loc2_:String = !!this.options.locale_id_system ? this.options.locale_id_system._id : null;
         this.globalPrefs.setPref(PREF_LOCALE_ID_SYSTEM,this.options.locale_id_system.id);
         if(_loc1_)
         {
            if(_loc1_ != _loc2_)
            {
               this.context.logger.info("GameConfig.checkLocalePrefs system locale changed from [" + _loc1_ + "] to [" + _loc2_ + "], resetting language option");
               this.globalPrefs.setPref(PREF_LOCALE_ID_OPTION,null);
               this.checkAutoCc();
               return;
            }
         }
         var _loc3_:String = this.globalPrefs.getPref(PREF_LOCALE_ID_OPTION);
         if(_loc3_)
         {
            this.context.logger.info("GameConfig.checkLocalePrefs restoring language option [" + _loc3_ + "]");
            this.options.locale_id = this.checkLocaleId(new LocaleId(_loc3_));
         }
      }
      
      private function doReadyToStart() : void
      {
         this.readyToStart = true;
         dispatchEvent(new Event(EVENT_READY_TO_START));
      }
      
      private function preloadMods() : void
      {
         var mod_id:String = null;
         var mod_root:String = null;
         var mod:ModDef = null;
         var ba:ByteArray = null;
         var ba_str:String = null;
         var mod_jo:Object = null;
         var f:String = null;
         var map:String = null;
         var remap:Object = null;
         var other:String = null;
         if(!StringUtil.endsWith(this.options.mod_root,"/"))
         {
            this.options.mod_root += "/";
         }
         for each(mod_id in this.options.mod_ids)
         {
            mod_root = this.options.mod_root + mod_id;
            mod = new ModDef(mod_id,mod_root);
            this.context.logger.info("GameConfig.preloadMods loading mod manifest from [" + mod_root + "]");
            ba = this.context.appInfo.loadFile(mod_root,"mod_manifest.json");
            if(!ba)
            {
               this.context.logger.error("GameConfig.preloadMods failed to load mod manifest from [" + mod_root + "]");
            }
            else
            {
               try
               {
                  ba_str = ba.readUTFBytes(ba.length);
                  mod_jo = StableJson.parse(ba_str);
                  mod.parseManifest(mod_jo,this.context.logger);
                  for each(f in mod.manifest)
                  {
                     map = mod.root + "/" + f;
                     remap = this.mod_remapping[f];
                     other = String(remap.other);
                     if(remap)
                     {
                        this.context.logger.error("GameConfig.preloadMods incompatible mod [" + mod_root + "] conflicts with [" + other + "] on file [" + f + "]");
                     }
                     else
                     {
                        remap[f] = {
                           "map":map,
                           "other":mod_id
                        };
                     }
                  }
                  this.mods.push(mod);
               }
               catch(e:Error)
               {
                  context.logger.error("GameConfig.preloadMods failed to parse mod manifest from [" + mod_root + "]\n" + e.getStackTrace());
               }
            }
         }
      }
      
      public function saveGpJson() : void
      {
         var r:Object = null;
         var js:String = null;
         var b:ByteArray = null;
         try
         {
            r = GpDeviceType.toJsonUserCfgs();
            js = StableJson.stringifyObject(r,"  ");
            b = new ByteArray();
            b.writeUTFBytes(js);
            this.context.appInfo.saveFile(null,"gp.json",b,true);
            b.clear();
         }
         catch(e:Error)
         {
            context.logger.error("GameConfig.saveGpJson FAILED\n" + e.getStackTrace());
         }
      }
      
      private function loadGpJson(param1:String, param2:String) : Object
      {
         var ba:ByteArray;
         var ba_str:String = null;
         var r:Object = null;
         var root:String = param1;
         var url:String = param2;
         this.context.logger.info("GameConfig.loadGpJson loading [" + root + "] [" + url + "]");
         ba = this.context.appInfo.loadFile(root,url);
         if(!ba)
         {
            return null;
         }
         this.context.logger.info("GameConfig.loadGpJson LOADED [" + root + "] [" + url + "]");
         try
         {
            ba_str = ba.readUTFBytes(ba.length);
            ba.clear();
            r = StableJson.parse(ba_str);
            return r;
         }
         catch(e:Error)
         {
            context.logger.error("GameConfig.loadGpJson FAILED [" + root + "] [" + url + "]\n" + e.getStackTrace());
            return null;
         }
      }
      
      private function applyModRemapping() : void
      {
         var _loc1_:ModDef = null;
         var _loc2_:String = null;
         var _loc3_:String = null;
         for each(_loc1_ in this.mods)
         {
            for each(_loc2_ in _loc1_.manifest)
            {
               _loc3_ = _loc1_.root + "/" + _loc2_;
               this.resman.addRemapping(_loc2_,_loc3_);
            }
         }
      }
      
      public function startLoading() : void
      {
         var _loc3_:URLRequest = null;
         this.censorId = !!this.context.appInfo.resourceCensor ? this.context.appInfo.resourceCensor.id : null;
         if(Fastall.fastall)
         {
            SagaCheat.devCheat("fastall");
         }
         this.preloadMods();
         this.checkLocalePrefs();
         this.gaTrackLang();
         if(this.options.developer)
         {
            this.animDispatcher = new EventDispatcher();
         }
         this.shell = new GameConfigShellCmdManager(this);
         this.keybinder = new GameKeyBinder(this,this.gameNumber);
         this.gpbinder = new GameGpBinder(this,this.gameNumber);
         if(!this.gameServerUrl)
         {
            this.gameServerUrl = this.serverHostsLive;
         }
         if(Boolean(this.gameServerUrl) && this.gameServerUrl.charAt(this.gameServerUrl.length - 1) != "/")
         {
            this.gameServerUrl += "/";
         }
         if(!this.username)
         {
            this.username = this.globalPrefs.getPref(PREF_USERNAME);
            if(!this.username)
            {
               this.username = new Date().time.toString(16);
            }
         }
         this.context.logger.info("CONFIG assets=" + this.options.assetPath);
         this.options.locale_id = this.checkLocaleId(this.options.locale_id);
         this.context.logger.info("CONFIG locale=" + this.options.locale_id.id);
         var _loc1_:ResourceCensor = this.context.appInfo.resourceCensor;
         var _loc2_:ResourceCache = this.context.appInfo.resourceCache;
         this.resman = new ResourceManager(this.assetIndex,this.options.assetPath,this.options.locale_id,this.context.logger,_loc2_,new ResourceTextureSizes(this.context.appInfo),_loc1_);
         this.applyModRemapping();
         this.textBitmapGenerator = new GameTextBitmapGenerator(this.logger,this.context);
         this.bootstrapper = new EngineAssetBootstrapper(this.resman,this.context,this.options.locale_id,!GP_CONFIG_DISABLE,this.ggthFactory);
         this.bootstrapper.addEventListener(Event.COMPLETE,this.bootstrapperHandler);
         this.bootstrapper.startLoadingAssets();
         if(this.options.startInFactions)
         {
            _loc3_ = new URLRequest("http://stoicstudio.com/deploy/dev/" + this.context.appInfo.buildVersion + "/news.json");
            this.context.logger.info("Retrieving news from [" + _loc3_.url + "]");
            this.newsLoader = new URLLoader(_loc3_);
            this.newsLoader.addEventListener(Event.COMPLETE,this.newsCompleteHandler);
            this.newsLoader.addEventListener(IOErrorEvent.IO_ERROR,this.newsErrorHandler);
            this.newsLoader.load(_loc3_);
         }
         this.automator = new GameAutomator(this,this.logger);
         if(this.options.programText)
         {
            this.automator.runScript(this.options.programText);
         }
      }
      
      private function checkLocaleId(param1:LocaleId) : LocaleId
      {
         var _loc2_:String = "en";
         var _loc3_:String = this.context.appInfo.getLocaleMapping(param1.id);
         if(!_loc3_)
         {
            this.logger.info("checkLocaleId No locale available for requested [" + param1.id + "], using default");
         }
         else
         {
            _loc2_ = _loc3_;
         }
         if(_loc2_ != param1.id)
         {
            this.logger.info("checkLocaleId Switching locale from [" + param1.id + "] to [" + _loc2_ + "]");
            param1 = new LocaleId(_loc2_);
         }
         return param1;
      }
      
      private function newsCompleteHandler(param1:Event) : void
      {
         this.logger.info("newsCompleteHandler: Received news");
         var _loc2_:Object = StableJson.parse(this.newsLoader.data);
         this.news = new NewsDefVars().fromJson(_loc2_,this.logger);
      }
      
      private function newsErrorHandler(param1:IOErrorEvent) : void
      {
         this.logger.error("newsErrorHandler: " + param1);
         this.news = new NewsDef();
      }
      
      public function loadFactions() : void
      {
         this._sagaLoadedAndReadyToStart = false;
         if(this.saga)
         {
            this.saga.cleanup();
            this.saga = null;
            dispatchEvent(new Event(EVENT_SAGA));
         }
         if(this.factions)
         {
            this.factions.cleanup();
         }
         this.factions = new FactionsConfig(this,this.factionsReadyCallback);
         this.factions.load();
      }
      
      private function factionsReadyCallback() : void
      {
         dispatchEvent(new Event(EVENT_FACTIONS));
      }
      
      public function loadSaga(param1:String, param2:String, param3:SagaSave, param4:int, param5:int, param6:SagaSave = null, param7:String = null, param8:String = null) : void
      {
         var sid:String;
         var stripHappenings:Boolean;
         var oldSaga:Saga = null;
         var os:Saga = null;
         var url:String = param1;
         var happening:String = param2;
         var save:SagaSave = param3;
         var difficulty:int = param4;
         var profile_index:int = param5;
         var imported:SagaSave = param6;
         var selectedVariable:String = param7;
         var parentSagaUrl:String = param8;
         if(this.saga)
         {
            this.saga.endAllHappenings();
         }
         if(this.fsm.currentClass != SagaState && this.fsm.currentClass != LoadGameState)
         {
            if(this.fsm.current)
            {
               this.fsm.current.forceTransitionOut = true;
            }
            this.fsm.transitionTo(LoadGameState,null);
         }
         if(this.saga)
         {
            oldSaga = this.saga;
            this.saga = null;
            oldSaga.cleanup();
         }
         this._sagaLoadedAndReadyToStart = false;
         sid = !!save ? save.id : "";
         this.logger.info("GameConfig.loadSaga [" + url + "] happening=[" + happening + "] save=[" + save + "] profile_index=[" + profile_index + "] save_id=[" + sid + "] imported=[" + imported + "] parent [" + parentSagaUrl + "]");
         this.pageManager.currentPage = null;
         this.soundSystem.music = null;
         this.sagaLoadParams.sagaDifficulty = difficulty;
         this.sagaLoadParams.sagaProfileIndex = profile_index;
         this.sagaLoadParams.parentSagaUrl = parentSagaUrl;
         this.globalAmbience.audio = null;
         this.sagaLoadParams.sagaHappening = happening;
         this.sagaLoadParams.sagaSave = save;
         this.sagaLoadParams.sagaImported = imported;
         this.sagaLoadParams.sagaSelectedVariable = selectedVariable;
         if(this.tutorialLayer)
         {
            this.tutorialLayer.removeAllTooltips();
         }
         if(this.factions)
         {
            this.factions.cleanup();
            this.factions = null;
            dispatchEvent(new Event(EVENT_FACTIONS));
         }
         this.options.newMusic = true;
         if(this.saga)
         {
            this.__classes = this.saga.def.classes.parent;
            this.shell.removeShell("saga");
            os = this.saga;
            this.saga = null;
            dispatchEvent(new Event(EVENT_SAGA));
            os.cleanup();
         }
         stripHappenings = true;
         this.loadingSaga = new SagaDefLoader(this.resman,this.context.logger,this.context.locale,this.__classes,this,this.__abilityFactory,this.soundSystem,stripHappenings);
         try
         {
            this.loadingSaga.load(url,this.sagaDefReadyCallback);
         }
         catch(e:Error)
         {
            context.appInfo.terminateError("Cannot load saga, quitting:\n" + e.getStackTrace());
         }
      }
      
      private function sagaDefReadyCallback(param1:SagaDefLoader) : void
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("GameConfig.sagaDefReadyCallback START");
         }
         if(param1 != this.loadingSaga)
         {
            return;
         }
         this.loadingSaga = null;
         if(!param1.sagaDef)
         {
            this.context.appInfo.terminateError("Failed to load saga, quitting");
            return;
         }
         this.saga = new GameSaga(this,param1.sagaDef,this.resman);
         param1.cleanup();
         this.saga.loadSagaResources(this.sagaLoadedHandler);
      }
      
      public function get sagaLoadedAndReadyToStart() : Boolean
      {
         return this._sagaLoadedAndReadyToStart;
      }
      
      private function sagaLoadedHandler(param1:Saga) : void
      {
         if(param1 != this.saga)
         {
            this.logger.info("GameConfig.sagaLoadedHandler MISMATCH");
            return;
         }
         this.logger.info("GameConfig.sagaLoadedHandler " + param1 + " [" + this.sagaLoadParams.sagaHappening + "]");
         this.spawnables = this.saga.def.cast;
         if(this.saga.def.classes)
         {
            this.saga.def.classes.parent = this.classes;
         }
         this.__classes = this.saga.def.classes;
         dispatchEvent(new Event(EVENT_SAGA));
         this.shell.addShell("saga",this.saga.shell);
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("GameConfig.sagaLoadedHandler END, STARTING");
         }
         this.saga.profile_index = this.sagaLoadParams.sagaProfileIndex;
         if(this.sagaLoadParams.sagaProfileIndex < 0)
         {
            if(Boolean(this.sagaLoadParams.sagaHappening) && this.sagaLoadParams.sagaHappening != "start_alpha")
            {
               this.saga.devBookmarked = true;
            }
         }
         this.saga.parentSagaUrl = this.sagaLoadParams.parentSagaUrl;
         this._sagaLoadedAndReadyToStart = true;
         dispatchEvent(new Event(EVENT_SAGA_READY));
      }
      
      public function cleanup() : void
      {
         var _loc1_:FactionsConfig = null;
         var _loc2_:Saga = null;
         GpSource.dispatcher.removeEventListener(GpSource.EVENT_PRIMARY_DEVICE,this.gpPrimaryDeviceHandler);
         this._finishedReadyForCallback = false;
         this._sagaLoadedAndReadyToStart = false;
         if(this.factions)
         {
            _loc1_ = this.factions;
            this.factions = null;
            _loc1_.cleanup();
         }
         if(this.saga)
         {
            this.saga.endAllHappenings();
         }
         if(Boolean(this.fsm) && Boolean(this.fsm.current))
         {
            this.fsm.stopFsm(false);
         }
         if(this.saga)
         {
            _loc2_ = this.saga;
            this.saga = null;
            _loc2_.cleanup();
         }
         if(this.soundSystem)
         {
            this.soundSystem.driver.dispose();
            this.soundSystem = null;
         }
      }
      
      public function changeLocale(param1:String, param2:Function, param3:Boolean = false) : void
      {
         if(this.changeLocaleCallback != null)
         {
            return;
         }
         var _loc4_:LocaleId = this.checkLocaleId(new LocaleId(param1));
         if(_loc4_.id == this.options.locale_id.id && !param3)
         {
            if(param2 != null)
            {
               param2();
               return;
            }
         }
         this.context.logger.info("Change locale to " + _loc4_.id);
         this.changeLocaleCallback = param2;
         this.options.locale_id = _loc4_;
         this.gaTrackLang();
         var _loc5_:String = this.options.locale_id.translateLocaleUrl(EngineAssetBootstrapper.LOCALE_URL);
         var _loc6_:LocaleWrangler = new LocaleWrangler(_loc5_,this.context.logger,this.resman,LocaleCategory,false,this.options.locale_id,this.ggthFactory);
         _loc6_.addEventListener(Event.COMPLETE,this.changeLocaleWranglerReadyHandler);
         _loc6_.load();
      }
      
      private function gaTrackLang() : void
      {
         Ga.minimal("sys","lang",this.options.locale_id.id,0);
      }
      
      private function changeLocaleWranglerReadyHandler(param1:Event) : void
      {
         var _loc3_:Localizer = null;
         var _loc2_:LocaleWrangler = param1.target as LocaleWrangler;
         _loc2_.removeEventListener(Event.COMPLETE,this.changeLocaleWranglerReadyHandler);
         if(_loc2_)
         {
            if(_loc2_.locale)
            {
               this.context.locale = _loc2_.locale;
               this.options.locale_id = this.context.locale.id;
               this.resman.localeId = this.context.locale.id;
               this.ccs.locale = this.context.locale;
               this.checkLocaleOverlay();
               this.context.locale.translateDisplayObjects(LocaleCategory.GUI,PlatformFlash.stage,this.logger);
               if(this.__classes)
               {
                  this.__classes.changeLocale(this.context.locale);
               }
               if(this.__abilityFactory)
               {
                  _loc3_ = this.context.locale.getLocalizer(LocaleCategory.ABILITY);
                  this.__abilityFactory.changeLocale(_loc3_,this.logger);
               }
               if(this.itemDefs)
               {
                  this.itemDefs.changeLocale(this.context.locale);
               }
               if(this.titleDefs)
               {
                  this.titleDefs.changeLocale(this.context.locale);
               }
               this.globalPrefs.setPref(PREF_LOCALE_ID_OPTION,this.context.locale.id.id);
               if(this._saga)
               {
                  this._saga.changeLocale(this.context.locale);
                  if(this._saga.convo)
                  {
                     ConvoDefResource.swapConvoStrings(this._saga.convo.def,this.resman,this.changeLocaleConvoCallback);
                     return;
                  }
               }
               if(UserLifecycleManager.Instance().userName == null || UserLifecycleManager.Instance().userName == "xbl_no_user")
               {
                  UserLifecycleManager.Instance().userNeedsTranslation = true;
               }
            }
         }
         this.changeLocaleConvoCallback(null);
      }
      
      private function checkAutoCc() : void
      {
         if(Boolean(this.context.locale) && Boolean(this.context.locale.id))
         {
            if(this.context.locale.id.id != "en")
            {
               if(this.globalPrefs)
               {
                  this.globalPrefs.setPref(GameConfig.PREF_OPTION_CC,true);
               }
            }
         }
      }
      
      private function changeLocaleConvoCallback(param1:ConvoDef) : void
      {
         if(Boolean(this._saga) && Boolean(this._saga.convo))
         {
            this._saga.convo.cursor.reprocess();
         }
         this.checkAutoCc();
         dispatchEvent(new Event(EVENT_LOCALE));
         this.gameGuiContext.notifyLocaleChange();
         if(this.changeLocaleCallback != null)
         {
            this.changeLocaleCallback();
         }
         this.changeLocaleCallback = null;
      }
      
      private function bootstrapperHandler(param1:Event) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         this.bootstrapper.removeEventListener(Event.COMPLETE,this.bootstrapperHandler);
         this.logger.info("GameConfig BOOTSTRAPPED");
         if(GpSource.instance)
         {
            if(GpSource.GP_ENABLED)
            {
               _loc2_ = this.bootstrapper.gpjson;
               if(!GP_CONFIG_DISABLE)
               {
                  _loc3_ = this.loadGpJson(null,"gp.json");
               }
               GpSource.instance.start(_loc2_,_loc3_);
               GpSource.instance.addBinder(this.gpbinder);
            }
         }
         this.systemMessage = new SystemMessageManager(this.context.locale);
         this.purchasableUnits = new PurchasableUnits(this);
         this.friends = new FriendsData(this.logger);
         this.__abilityFactory = this.bootstrapper.abilityFactory;
         this.__classes = this.bootstrapper.classes;
         this.checkLocaleOverlay();
         this.ccs.locale = this.context.locale;
         this.wranglers = new DefWranglerWrangler("game",this.resman,this.logger);
         this.wranglers.add(new UnitStatCostsWrangler(STAT_COSTS_URL,this.logger,this.resman,null));
         this.soundSetup();
         this.wranglers.add(new BattleBoardTriggerDefWrangler(TRIGGER_CLASS_DEFS_URL,this.logger,this.resman,null));
         this.heraldryLoader = new HeraldrySystemLoader(HERALDRY_URL,this.logger,this.resman,this.globalPrefs);
         this.heraldryLoader.addEventListener(Event.COMPLETE,this.heraldrySystemLoaderCompleteHandler);
         this.assets = new GameAssetsDef(this);
         this._initGenerateConsoleCacheSizes();
         this._initGlobalAssetPreloaders();
         this.checkReady();
         this.wranglers.addEventListener(Event.COMPLETE,this.wranglersHandler);
         this.wranglers.load();
         this.heraldryLoader.load();
         dispatchEvent(new Event(EVENT_BOOTSTRAPPED));
      }
      
      private function _initGenerateConsoleCacheSizes() : void
      {
         var _loc1_:GenerateConsoleCacheSizes = null;
         if(GenerateConsoleCacheSizes.ENABLED)
         {
            throw new Error("GenerateConsoleCacheSizes.ENABLED must be false");
         }
      }
      
      private function _initGlobalAssetPreloaders() : void
      {
         var _loc1_:String = null;
         var _loc2_:GlobalAssetPreloader = null;
         if(!this.options.globalAssetPreloaderPaths || !this.options.globalAssetPreloaderPaths.length)
         {
            return;
         }
         this._globalAssetPreloaders = new Vector.<GlobalAssetPreloader>();
         for each(_loc1_ in this.options.globalAssetPreloaderPaths)
         {
            _loc2_ = new GlobalAssetPreloader(_loc1_,this.resman,this.logger);
            _loc2_.addEventListener(Event.COMPLETE,this.globalAssetPreloaderCompleteHandler);
            _loc2_.load();
         }
      }
      
      private function heraldrySystemLoaderCompleteHandler(param1:Event) : void
      {
         this.heraldryLoader.removeEventListener(Event.COMPLETE,this.heraldrySystemLoaderCompleteHandler);
         this.heraldrySystem = this.heraldryLoader.heraldry;
         this.heraldryLoader.cleanup();
         this.heraldryLoader = null;
         if(this.heraldrySystem)
         {
            this.heraldrySystem.loadSelectedHeraldry(this.resman);
         }
         this.checkReady();
      }
      
      private function globalAssetPreloaderCompleteHandler(param1:Event) : void
      {
         var _loc2_:IEventDispatcher = param1.target as IEventDispatcher;
         if(_loc2_)
         {
            _loc2_.removeEventListener(Event.COMPLETE,this.globalAssetPreloaderCompleteHandler);
         }
         this.checkReady();
      }
      
      private function wranglersHandler(param1:Event) : void
      {
         this.checkReady();
      }
      
      public function setSoundDriverClazz(param1:Class) : void
      {
         this.soundDriverClazz = param1;
      }
      
      private function soundSetup() : void
      {
         var _loc1_:FmodSoundSystem = new FmodSoundSystem(this.resman,STATIC_SOUND_LIBRARY_URL,this.soundDriverClazz,this.soundConfigReady,this.context.appInfo,this.globalPrefs);
         _loc1_.enabled = this.options.soundEnabled;
         this.soundSystem = _loc1_;
         _loc1_.init(this.options.fmodProfile,this.options.fmodPort);
         if(this.options.developer)
         {
            this.shell.addShell("fmod",new FmodShellCmdManager(this.logger,this.soundSystem));
         }
      }
      
      private function soundConfigReady() : void
      {
         if(this.options.fmodPort)
         {
            this.soundSystem.driver.netEventSystem_Init(this.options.fmodPort);
         }
         this.soundPreloader = this.soundSystem.driver.preloader;
         this.soundPreloader.addProjectInfo(FmodProjectInfo.create("common/fmod/","tbs"));
         this.soundPreloader.load(this.soundPreloaderCompleteHandler);
         this.checkReady();
      }
      
      private function soundPreloaderCompleteHandler(param1:ISoundPreloader) : void
      {
         this.soundSystem.driver.reverbAmbientPreset("default");
         (this.soundSystem as FmodSoundSystem).createSoundController(this.soundConfigControllerReady);
         this.checkReady();
      }
      
      private function soundConfigControllerReady(param1:FmodSoundSystem) : void
      {
         this.checkReady();
      }
      
      private function guiContextHandler(param1:GameGuiContext) : void
      {
         this.checkReady();
      }
      
      private function checkGuiContextReady() : Boolean
      {
         if(this.gameGuiContext)
         {
            return true;
         }
         if(this.soundSystem && this.soundSystem.ready && Boolean(this.soundSystem.controller))
         {
            if(this.assets)
            {
               if(Boolean(this.resman) && Boolean(this.dialogLayer))
               {
                  this.gameGuiContext = new GameGuiContext(this.logger,this.resman,this.soundSystem.controller,this.accountInfo,GameAssetsDef.dialogClazz,this.dialogLayer,this);
                  return true;
               }
            }
         }
         return false;
      }
      
      private function waitingOn(param1:String, param2:Object) : Boolean
      {
         if(READY_DEBUG)
         {
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("GameConfig WAITING on " + param1 + ": " + param2);
            }
         }
         return true;
      }
      
      private function checkReady() : void
      {
         var waiting:Boolean = false;
         var gap:GlobalAssetPreloader = null;
         if(AppInfo.terminating)
         {
            return;
         }
         if(this.ready)
         {
            return;
         }
         this.checkGuiContextReady();
         if(!this.bootstrapper || !this.bootstrapper.ready)
         {
            waiting = this.waitingOn("bootstrapper",this.bootstrapper) || waiting;
         }
         if(Boolean(this.heraldryLoader) && !this.heraldrySystem)
         {
            waiting = this.waitingOn("heraldry",this.heraldryLoader) || waiting;
         }
         if(!(this.wranglers && this.wranglers.ready))
         {
            waiting = this.waitingOn("wranglers",this.wranglers) || waiting;
         }
         if(Boolean(this.factions) && !this.factions.ready)
         {
            waiting = this.waitingOn("factions",this.factions) || waiting;
         }
         if(!this.assets)
         {
            waiting = this.waitingOn("assets",this.assets) || waiting;
         }
         if(!(this.soundSystem && this.soundSystem.driver && Boolean(this.soundPreloader) && this.soundPreloader.complete))
         {
            waiting = this.waitingOn("soundConfig",this.soundSystem) || waiting;
         }
         if(!this.gameGuiContext)
         {
            waiting = this.waitingOn("gameGuiContext",this.gameGuiContext) || waiting;
         }
         if(this._globalAssetPreloaders)
         {
            for each(gap in this._globalAssetPreloaders)
            {
               waiting = this.waitingOn("globalAssetPreloader " + gap,gap) || waiting;
            }
         }
         if(GenerateConsoleCacheSizes.ENABLED)
         {
            waiting = this.waitingOn("GenerateConsoleCacheSizes","(it will wait forever)") || waiting;
         }
         if(waiting)
         {
            return;
         }
         try
         {
            this.finishReady();
         }
         catch(e:Error)
         {
            logger.error("Problem checkReady finishReady:\n" + e.getStackTrace());
         }
      }
      
      private function finishReady() : void
      {
         this._statCosts = (this.wranglers.wrangled(STAT_COSTS_URL) as UnitStatCostsWrangler).statCosts;
         this.wranglers.unwrangle(STAT_COSTS_URL);
         if(!this._statCosts)
         {
            this.logger.error("Failed to load stat costs");
            this._statCosts = new UnitStatCosts();
         }
         try
         {
            this._triggers = new BattleBoardTriggerDefList();
            this._triggers.fromJson(this.wranglers.wrangled(TRIGGER_CLASS_DEFS_URL).vars,this.logger);
            this.wranglers.unwrangle(TRIGGER_CLASS_DEFS_URL);
         }
         catch(e:Error)
         {
            logger.error("Problem finishReady triggers [" + TRIGGER_CLASS_DEFS_URL + "]:\n" + e.getStackTrace());
         }
         this.guiAlerts = new GuiAlertManager(this.alerts,this.gameGuiContext);
         this.fsm = new GameFsm(this);
         this.updateFunctions.push(this.fsm.update);
         if(this.options.developer)
         {
            this.shell.addShell("fsm",this.fsm.shell);
         }
         this.ready = true;
         this.logger.info("GameConfig READY");
         this._finishedReadyForCallback = true;
      }
      
      public function get logger() : ILogger
      {
         return this.context.logger;
      }
      
      public function get classes() : EntityClassDefList
      {
         return this.__classes;
      }
      
      public function get triggers() : BattleBoardTriggerDefList
      {
         return this._triggers;
      }
      
      public function get accountInfo() : AccountInfoDef
      {
         return this._accountInfo;
      }
      
      public function get legend() : Legend
      {
         if(Boolean(this.saga) && Boolean(this.saga.caravan))
         {
            return this.saga.caravan.legend as Legend;
         }
         if(this.factions)
         {
            return this.factions.legend;
         }
         return null;
      }
      
      public function set accountInfo(param1:AccountInfoDef) : void
      {
         this._accountInfo = param1;
         if(this.gameGuiContext)
         {
            this.gameGuiContext.accountInfo = param1;
         }
         this.checkShowNews();
         this.checkLoginStreakAlert();
         dispatchEvent(new Event(EVENT_ACCOUNT_INFO));
      }
      
      private function checkLoginStreakAlert() : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:Alert = null;
         if(!this._accountInfo || !this.globalPrefs)
         {
            return;
         }
         if(this._accountInfo.tutorial)
         {
            return;
         }
         if(this.shownLoginStreak)
         {
            return;
         }
         var _loc1_:AccountInfoDef = this._accountInfo;
         if(!_loc1_.daily_login_streak || !this.fsm || !this.fsm.session.credentials.sessionKey)
         {
            return;
         }
         this.shownLoginStreak = true;
         var _loc2_:int = this.globalPrefs.getPref(PREF_LAST_DAILY_LOGIN_STREAK);
         if(_loc1_.daily_login_streak != _loc2_ || _loc1_.daily_login_bonus > 0)
         {
            _loc3_ = this.gameGuiContext.translate("daily_login_streak");
            _loc4_ = this.gameGuiContext.translate("days_logged_in_pfx");
            _loc5_ = this.gameGuiContext.translate("bonus_renown_remaining_pfx");
            _loc6_ = _loc4_ + " " + _loc1_.daily_login_streak + "\n" + _loc5_ + " " + _loc1_.daily_login_bonus;
            _loc7_ = Alert.create(0,_loc3_,_loc6_,null,null,AlertOrientationType.LEFT,AlertStyleType.NORMAL,null);
            this.alerts.addAlert(_loc7_);
            this.globalPrefs.setPref(PREF_LAST_DAILY_LOGIN_STREAK,_loc1_.daily_login_streak);
         }
      }
      
      public function addUpdateFunction(param1:Function) : void
      {
         this.updateFunctions.push(param1);
      }
      
      public function addFinishReadyFunction(param1:Function) : void
      {
         this.finishReadyFunctions.push(param1);
      }
      
      public function addShutdownFunction(param1:Function) : void
      {
         this.shutdownFunctions.push(param1);
      }
      
      public function updateGameConfig(param1:int) : void
      {
         var _loc3_:Function = null;
         var _loc4_:int = 0;
         var _loc5_:Function = null;
         var _loc6_:GpDevice = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         if(!this.resman)
         {
            return;
         }
         if(this.shell)
         {
            this.shell.update();
         }
         this.resman.update(param1);
         if(this.enableMemReport && !MEM_REPORT_COMPLETELY_DISABLED)
         {
            _loc4_ = this.resman.modificationStamp;
            this.memReport.checkMemory(GameConfig.MEM_REPORT_ENABLED ? param1 : 0,_loc4_);
         }
         if(!this.ready)
         {
            return;
         }
         if(this._finishedReadyForCallback)
         {
            this._finishedReadyForCallback = false;
            this.readyCallback();
            for each(_loc5_ in this.finishReadyFunctions)
            {
               _loc5_();
            }
         }
         if(GpSource.GP_ENABLED && ENABLE_GP_REBINDING)
         {
            _loc6_ = GpSource.primaryDevice;
            if(PlatformInput.isGp)
            {
               if(!_loc6_ && !this.dialogNoGp)
               {
                  if(!this.dialogNoGp)
                  {
                     this.saga.pause("no gamepad");
                     this.dialogNoGp = this.gameGuiContext.createDialog();
                     _loc7_ = this.gameGuiContext.translateCategory("cfg_dialog_no_gamepad_title",LocaleCategory.GP);
                     _loc8_ = this.gameGuiContext.translateCategory("cfg_dialog_no_gamepad_body",LocaleCategory.GP);
                     this.dialogNoGp.openDialog(_loc7_,_loc8_,null,null);
                  }
               }
               else if(Boolean(_loc6_) && Boolean(this.dialogNoGp))
               {
                  this.saga.unpause("no gamepad");
                  this.dialogNoGp.closeDialog(null);
                  this.dialogNoGp = null;
               }
            }
            else if(Boolean(_loc6_) && _loc6_.type.unknown)
            {
               if(!this.pageManager.isGpConfigShowing)
               {
                  this.pageManager.showGpRebind(false,"GameConfig unknown primary device " + _loc6_);
               }
            }
         }
         if(!this.pageManager.isGpConfigShowing && !this.dialogNoGp)
         {
            if(this._sagaLoadedAndReadyToStart)
            {
               this._sagaLoadedAndReadyToStart = false;
               if(this.sagaLoadParams.sagaSave)
               {
                  this.saga.loadFromSave(this.sagaLoadParams.sagaSave);
               }
               else
               {
                  this.saga.start(this.sagaLoadParams.sagaHappening,this.sagaLoadParams.sagaDifficulty,this.sagaLoadParams.sagaImported,this.sagaLoadParams.sagaSelectedVariable);
               }
               this.sagaLoadParams.clear();
               dispatchEvent(new Event(EVENT_SAGA_STARTED));
            }
         }
         var _loc2_:Boolean = Boolean(this.soundSystem) && Boolean(this.soundSystem.driver) ? this.soundSystem.driver.systemUpdate() : false;
         for each(_loc3_ in this.updateFunctions)
         {
            _loc3_(param1);
         }
         if(this.pageManager)
         {
            this.pageManager.update(param1);
         }
         if(this.soundSystem)
         {
            this.soundSystem.updateSoundSystem(param1);
         }
         if(this.ccs)
         {
            this.ccs.update(param1);
         }
         if(this.automator)
         {
            this.automator.update();
         }
      }
      
      public function runShutdownFunctions() : void
      {
         var _loc1_:Function = null;
         for each(_loc1_ in this.shutdownFunctions)
         {
            _loc1_();
         }
      }
      
      public function get gameServerUrl() : String
      {
         return this._gameServerUrl;
      }
      
      public function set gameServerUrl(param1:String) : void
      {
         this._gameServerUrl = param1;
      }
      
      private function setupHosts() : void
      {
         this.serverHostsLive = "http://tbs-" + this._buildRelease + "-live.stoicstudio.com/";
         this.serverHostsQa = "http://tbs-" + this._buildRelease + "-qa.stoicstudio.com/";
      }
      
      public function get buildRelease() : String
      {
         return this._buildRelease;
      }
      
      public function set buildRelease(param1:String) : void
      {
         this._buildRelease = param1;
         this.setupHosts();
      }
      
      public function get kioskMode() : Boolean
      {
         return this.runMode == RunMode.KIOSK;
      }
      
      public function get betaMode() : Boolean
      {
         return this.runMode == RunMode.BETA;
      }
      
      public function checkShowNews() : void
      {
         if(!this.news)
         {
            return;
         }
         if(!this._accountInfo || !this.globalPrefs)
         {
            return;
         }
         if(this._accountInfo.tutorial || !this._accountInfo.completed_tutorial)
         {
            return;
         }
         if(this._accountInfo.login_count <= 1)
         {
            return;
         }
         if(!this.pageManager)
         {
            return;
         }
         var _loc1_:Date = this.globalPrefs.getPref(PREF_NEWS_READ_DATE);
         var _loc2_:Date = this.news.getLastDate();
         if(!_loc1_ || _loc2_ && _loc1_.date < _loc2_.date)
         {
            this.showNews();
         }
      }
      
      public function showNews() : void
      {
         var _loc1_:Date = this.globalPrefs.getPref(PREF_NEWS_READ_DATE);
         var _loc2_:Date = this.news.getLastDate();
         this.globalPrefs.setPref(PREF_NEWS_READ_DATE,_loc2_);
         var _loc3_:int = this.news.findFirstIndexAfterDate(_loc1_);
         this.pageManager.showNews(this.news,_loc3_);
      }
      
      public function get entityAssetBundleManager() : IEntityAssetBundleManager
      {
         return this._eabm;
      }
      
      public function set entityAssetBundleManager(param1:IEntityAssetBundleManager) : void
      {
         if(param1 == this._eabm)
         {
            return;
         }
         if(this._eabm)
         {
            this._eabm.cleanup();
         }
         this._eabm = param1;
      }
      
      public function purgeAssetBundles() : void
      {
         if(this._eabm)
         {
            this._eabm.purge();
            if(this._eabm.abilityAssetBundleManager)
            {
               this._eabm.abilityAssetBundleManager.purge();
            }
         }
      }
      
      public function get saga() : Saga
      {
         return this._saga;
      }
      
      public function set saga(param1:Saga) : void
      {
         if(this._saga == param1)
         {
            return;
         }
         if(this._saga)
         {
            this._saga.removeEventListener(ScreenFlyTextEvent.TYPE,this.screenFlyTextHandler);
         }
         this.logger.info("GameConfig.saga=" + param1);
         this.entityAssetBundleManager = null;
         this._saga = param1;
         this.flyManager.purgeQueue();
         if(this._saga)
         {
            this._saga.addEventListener(ScreenFlyTextEvent.TYPE,this.screenFlyTextHandler);
            this.entityAssetBundleManager = new EntityAssetBundleManager("gameConfig",this.resman,this._saga.cast,this._saga.abilityFactory,this.soundSystem.driver);
         }
      }
      
      private function screenFlyTextHandler(param1:ScreenFlyTextEvent) : void
      {
         if(this.flyManager)
         {
            this.flyManager.showScreenFlyText(param1.text,param1.color,param1.soundId,param1.linger);
         }
      }
      
      public function get statCosts() : UnitStatCosts
      {
         if(Boolean(this.saga) && Boolean(this.saga.def.unitStatCosts))
         {
            return this.saga.def.unitStatCosts;
         }
         return this._statCosts;
      }
      
      public function get itemDefs() : ItemListDef
      {
         if(this.saga)
         {
            return this.saga.def.itemDefs;
         }
         return null;
      }
      
      public function get titleDefs() : ITitleListDef
      {
         if(this.saga)
         {
            return this.saga.def.titleDefs;
         }
         return null;
      }
      
      public function get achievementListDef() : AchievementListDef
      {
         if(this.saga)
         {
            return this.saga.def.achievements;
         }
         if(this.factions)
         {
            return this.factions.achievementListDef;
         }
         return null;
      }
      
      public function get abilityFactory() : BattleAbilityDefFactory
      {
         return this.__abilityFactory;
      }
      
      private function checkLocaleOverlay() : Boolean
      {
         var _loc2_:Boolean = false;
         var _loc3_:LocaleCategory = null;
         var _loc4_:LocaleCategory = null;
         var _loc5_:LocaleCategory = null;
         var _loc1_:GpDevice = GpSource.primaryDevice;
         for each(_loc3_ in LocaleCategory.overlayable)
         {
            _loc4_ = _loc3_.overlay;
            _loc5_ = !!_loc1_ ? _loc1_.type.getLocaleOverlay(_loc3_) : null;
            if(_loc4_ != _loc5_)
            {
               if(_loc5_)
               {
                  _loc4_ = _loc5_;
               }
               _loc2_ = true;
               this.context.locale.setOverlay(_loc3_,_loc4_);
               if(this.pageManager && this.pageManager.holder && Boolean(this.pageManager.holder.stage))
               {
                  if(_loc3_ == LocaleCategory.GUI || _loc3_ == LocaleCategory.GUI_GP)
                  {
                     this.context.locale.translateDisplayObjects(LocaleCategory.GUI,this.pageManager.holder.stage,this.logger);
                  }
               }
            }
         }
         return _loc2_;
      }
      
      private function gpPrimaryDeviceHandler(param1:Event) : void
      {
         if(this.checkLocaleOverlay())
         {
            if(this.gameGuiContext)
            {
               this.gameGuiContext.notifyLocaleChange();
            }
         }
      }
      
      public function getIBattleBoard() : IBattleBoard
      {
         return !!this.saga ? this.saga.getIBattleBoard() : null;
      }
      
      public function getEntityByDefId(param1:String, param2:TileRect, param3:Boolean) : IBattleEntity
      {
         return !!this.saga ? this.saga.getEntityByDefId(param1,param2,param3) : null;
      }
      
      public function getEntityByIdOrByDefId(param1:String, param2:TileRect, param3:Boolean) : IBattleEntity
      {
         return !!this.saga ? this.saga.getEntityByIdOrByDefId(param1,param2,param3) : null;
      }
      
      public function get skuSaga() : String
      {
         if(Boolean(this.saga) && Boolean(this.saga.def))
         {
            return this.saga.def.id;
         }
         return this.context.appInfo.master_sku;
      }
   }
}

import engine.core.logging.ILogger;

class ModDef
{
    
   
   public var id:String;
   
   public var root:String;
   
   public var manifest:Array;
   
   public function ModDef(param1:String, param2:String)
   {
      this.manifest = [];
      super();
      this.id = param1;
      this.root = param2;
   }
   
   public function parseManifest(param1:Object, param2:ILogger) : void
   {
      var _loc4_:String = null;
      var _loc3_:Array = param1.files;
      if(!_loc3_)
      {
         param2.info("No files in mod [" + this.id + "]");
         return;
      }
      for each(_loc4_ in _loc3_)
      {
         this.manifest.push(_loc4_);
      }
   }
}
