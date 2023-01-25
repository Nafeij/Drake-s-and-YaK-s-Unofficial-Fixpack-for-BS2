package game.entry
{
   import com.greensock.TweenMax;
   import com.sociodox.theminer.TheMiner;
   import com.stoicstudio.platform.Platform;
   import com.stoicstudio.platform.PlatformInput;
   import com.stoicstudio.platform.PlatformStarling;
   import engine.anim.def.AnimClipDef;
   import engine.anim.def.AnimFrame;
   import engine.anim.view.AnimController;
   import engine.anim.view.XAnimClipSpriteBase;
   import engine.automator.EngineAutomator;
   import engine.battle.Fastall;
   import engine.battle.ability.model.BattleAbilityManager;
   import engine.battle.ability.phantasm.model.ChainPhantasms;
   import engine.battle.board.view.underlay.TileTriggerTilesUnderlay;
   import engine.battle.entity.model.BattleEntityMobility;
   import engine.battle.entity.view.EntityView;
   import engine.battle.fsm.BattleFsmConfig;
   import engine.battle.fsm.BattleMove;
   import engine.battle.fsm.aimodule.AiGlobalConfig;
   import engine.battle.fsm.state.BattleStateTurnBase;
   import engine.convo.view.ConvoView;
   import engine.core.RunMode;
   import engine.core.analytic.Ga;
   import engine.core.analytic.GaConfig;
   import engine.core.analytic.LocMon;
   import engine.core.fsm.Fsm;
   import engine.core.gp.GpControlButton;
   import engine.core.gp.GpSource;
   import engine.core.locale.LocaleId;
   import engine.core.locale.Localizer;
   import engine.core.logging.ILogger;
   import engine.core.logging.Logger;
   import engine.core.render.MatteHelper;
   import engine.core.render.ScreenAspectHelper;
   import engine.core.util.AppInfo;
   import engine.core.util.CloudSaveConfig;
   import engine.core.util.CloudSaveSynchronizer;
   import engine.core.util.Enum;
   import engine.core.util.StringUtil;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   import engine.def.EngineJsonDefImpl;
   import engine.gui.GuiGpNav;
   import engine.gui.GuiUtil;
   import engine.gui.core.GuiApplication;
   import engine.gui.core.GuiHList;
   import engine.gui.core.GuiSprite;
   import engine.landscape.model.Landscape;
   import engine.landscape.travel.view.CaravanView;
   import engine.landscape.view.ClickablePair;
   import engine.landscape.view.LandscapeViewConfig;
   import engine.landscape.view.WeatherManager;
   import engine.math.Hash;
   import engine.path.PathFloodSolver;
   import engine.resource.Resource;
   import engine.resource.ResourceCache;
   import engine.resource.ResourceCollector;
   import engine.resource.ResourceManager;
   import engine.saga.Saga;
   import engine.saga.SagaCheat;
   import engine.saga.SagaConfig;
   import engine.saga.SagaDef;
   import engine.saga.SagaLog;
   import engine.saga.SagaSurvival;
   import engine.saga.action.Action_Battle;
   import engine.saga.action.Action_Wait;
   import engine.saga.save.GameSaveSynchronizer;
   import engine.saga.save.SagaSave;
   import engine.saga.save.SaveManager;
   import engine.saga.vars.Variable;
   import engine.scene.model.Scene;
   import engine.scene.model.SceneAudioEmitterAudible;
   import engine.scene.view.SceneMouseAdapter;
   import engine.sound.NullSoundDriver;
   import engine.stat.def.StatType;
   import engine.talent.TalentRankDef;
   import engine.talent.Talents;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.system.Capabilities;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import game.cfg.GameConfig;
   import game.gui.GuiBitmapHolderHelper;
   import game.gui.GuiSagaOptionsConfig;
   import game.gui.GuiSagaStartConfig;
   import game.gui.page.MapCampPage;
   import game.gui.page.SagaSelectorPage;
   import game.gui.page.SagaStartPage;
   import game.gui.page.SaveLoadPage;
   import game.gui.page.ScenePage;
   import game.gui.page.VideoPage;
   import game.session.states.StartState;
   import game.view.GameScreenFlyTextManagerAdapter;
   import game.view.GameWrapper;
   import starling.core.Starling;
   
   public class GameEntryDesktop extends GameEntry
   {
      
      public static var force_previewbuild_default:Boolean;
      
      public static var FORCE_SSA:Boolean;
       
      
      public var hbox:GuiHList;
      
      public var hboxMasker:GuiHList;
      
      public var masks:Vector.<GuiSprite>;
      
      private var overlay:Sprite;
      
      public var gui:String;
      
      public var disableGuiLoading:Boolean = false;
      
      private var local_assets:Boolean;
      
      private var assetsOverridden:Boolean;
      
      private var serverOverridden:Boolean;
      
      private var offline:Boolean = true;
      
      private var fmod_port:int = 0;
      
      private var fmod_profile:Boolean;
      
      private var fmod_studio:Boolean = true;
      
      private var debugTxnImmediateFinalize:Boolean;
      
      private var tutorial:Boolean;
      
      private var new_music:Boolean;
      
      private var childs:Array;
      
      private var betaBuildText:TextField;
      
      protected var betaBranch:String;
      
      protected var userId:String;
      
      private var softwareMouse:Boolean = false;
      
      protected var sagaHappening:String;
      
      private var sagaSaveLoad:String;
      
      private var sagaSaveLoadProfile:int = -1;
      
      private var require_online:Boolean;
      
      private var startInVs:Boolean;
      
      private var handledExit:Boolean;
      
      protected var invokeArguments:Array;
      
      protected var sound:Boolean = true;
      
      private var parties:Vector.<Vector.<String>> = null;
      
      public var developer:Boolean;
      
      private var screen_flash_errors:Boolean = false;
      
      private var versusCountdownOverrideSecs:int = -1;
      
      private var fullscreen:Boolean = false;
      
      private var fullscreenSet:Boolean = false;
      
      public var debug:Boolean = false;
      
      private var server:String;
      
      public var mod_ids:Array;
      
      public var mod_root:String;
      
      public var cloudSaves:CloudSaveSynchronizer;
      
      public var e3demo:Boolean;
      
      public var programPath:String;
      
      public var programText:String;
      
      private var usernamesv:Array;
      
      private var under_construction:String;
      
      public var _argValue:String;
      
      public var _argBool:Boolean;
      
      private var bgColor:uint = 0;
      
      private var _pirateMark:TextField;
      
      private var _watermarked:int;
      
      public function GameEntryDesktop(param1:GuiApplication, param2:AppInfo, param3:Class, param4:String, param5:Class, param6:Class, param7:Class)
      {
         this.invokeArguments = [];
         this.mod_ids = [];
         super(param1,param2,param3,param4,param5,param6,param7);
         GpSource.GP_ENABLED = true;
         SceneMouseAdapter.ALLOW_EDGE_PAN = true;
         param1.stage.stageFocusRect = false;
         if(locally)
         {
            this.local_assets = true;
            assetsUrl = localAssetsPath;
         }
      }
      
      public function set windowWidth(param1:int) : void
      {
      }
      
      public function set windowHeight(param1:int) : void
      {
      }
      
      public function set fmodDebug(param1:Boolean) : void
      {
      }
      
      public function set fmodEventExpirationMs(param1:int) : void
      {
      }
      
      override protected function textScaleHandler(param1:Event) : void
      {
         var _loc3_:int = 0;
         var _loc4_:DisplayObject = null;
         super.textScaleHandler(param1);
         if(!this.overlay || root == this.overlay)
         {
            return;
         }
         var _loc2_:GuiSprite = this.overlay as GuiSprite;
         if(_loc2_)
         {
            if(_loc2_.parent != root)
            {
               _loc2_.performResizeEventNow();
            }
         }
         else
         {
            _loc3_ = 0;
            while(_loc3_ < this.overlay.numChildren)
            {
               _loc4_ = this.overlay.getChildAt(_loc3_);
               _loc2_ = _loc4_ as GuiSprite;
               if(_loc2_)
               {
                  _loc2_.performResizeEventNow();
               }
               _loc3_++;
            }
         }
      }
      
      public function implResizeHandler() : void
      {
         var _loc1_:int = 0;
         var _loc2_:DisplayObject = null;
         var _loc3_:GuiSprite = null;
         if(this.betaBuildText)
         {
            this.betaBuildText.width = this.betaBuildText.textWidth + 10;
            this.betaBuildText.x = root.width - this.betaBuildText.width - 20;
            this.betaBuildText.y = -5;
         }
         if(this.overlay)
         {
            if(this.overlay is GuiSprite)
            {
               this.overlay.width = root.width;
               this.overlay.height = root.height;
            }
            _loc1_ = 0;
            while(_loc1_ < this.overlay.numChildren)
            {
               _loc2_ = this.overlay.getChildAt(_loc1_);
               _loc3_ = _loc2_ as GuiSprite;
               if(_loc3_)
               {
                  _loc3_.setSize(root.width,root.height);
               }
               else
               {
                  _loc2_.width = root.width;
                  _loc2_.height = root.height;
               }
               _loc1_++;
            }
         }
      }
      
      protected function initWrapper(param1:int, param2:Array) : GameWrapper
      {
         var _loc4_:String = null;
         var _loc5_:AppInfo = null;
         var _loc3_:GameWrapper = null;
         if(wrappers.length > param1)
         {
            _loc3_ = wrappers[param1];
         }
         else
         {
            if(wrappers.length != param1)
            {
               throw new ArgumentError("bad ordinal");
            }
            _loc4_ = param1 > 0 ? wrappers[0].appInfo.buildVersion : appInfo.buildVersion;
            _loc5_ = appInfo.cloneAppInfo(param1);
            _loc3_ = new GameWrapper(param1,_loc5_,NullSoundDriver,this.debug,nativeTextClazz,gameDevSocketClazz,saveManager);
            wrappers.push(_loc3_);
         }
         if(param1 < param2.length)
         {
            if(_loc3_.config)
            {
               _loc3_.config.username = param2[param1];
            }
         }
         (_loc3_.logger as Logger).isDebugEnabled = this.debug;
         return _loc3_;
      }
      
      private function initWrappers(param1:Array, param2:Boolean) : void
      {
         var _loc4_:GameWrapper = null;
         var _loc5_:GuiSprite = null;
         this.initWrapper(0,param1);
         if(param1.length == 1)
         {
            wrappers[0].setSize(root.width,root.height);
            this.overlay.addChild(wrappers[0]);
            return;
         }
         this.hbox = new GuiHList();
         this.hbox.padding = 0;
         this.hbox.margin = 0;
         this.hboxMasker = new GuiHList();
         this.hboxMasker.padding = 0;
         this.hboxMasker.margin = 0;
         this.masks = new Vector.<GuiSprite>();
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc4_ = this.initWrapper(_loc3_,param1);
            _loc5_ = new GuiSprite();
            _loc5_.debugRender = 0;
            this.hboxMasker.addChild(_loc5_);
            this.hbox.addChild(_loc4_);
            _loc4_.mask = _loc5_;
            _loc3_++;
         }
         this.hboxMasker.anchor.percentHeight = 100;
         this.hboxMasker.anchor.percentWidth = 100;
         this.overlay.addChild(this.hboxMasker);
         this.hbox.anchor.percentHeight = 100;
         this.hbox.anchor.percentWidth = 100;
         this.overlay.addChild(this.hbox);
      }
      
      public function logInfo(param1:String) : void
      {
         var _loc2_:GameWrapper = null;
         for each(_loc2_ in wrappers)
         {
            _loc2_.logger.info(param1);
         }
      }
      
      public function logDebug(param1:String) : void
      {
         var _loc2_:GameWrapper = null;
         for each(_loc2_ in wrappers)
         {
            _loc2_.logger.debug(param1);
         }
      }
      
      public function logError(param1:String) : void
      {
         var _loc2_:GameWrapper = null;
         for each(_loc2_ in wrappers)
         {
            _loc2_.logger.error(param1);
         }
      }
      
      public function checkArg(param1:String, param2:String) : Boolean
      {
         var _loc3_:int = param1.indexOf("=");
         var _loc4_:String = param1;
         this._argValue = "";
         if(_loc3_ > 0)
         {
            _loc4_ = param1.substring(0,_loc3_);
            this._argValue = param1.substring(_loc3_ + 1);
         }
         this._argBool = !this._argValue || this._argValue == "true";
         if(Boolean(_loc4_) && _loc4_.charAt(0) == "!")
         {
            this._argBool = !this._argBool;
            _loc4_ = _loc4_.substr(1);
         }
         if(_loc4_ == param2)
         {
            return true;
         }
         return false;
      }
      
      private function setUsername(param1:int, param2:String) : void
      {
         wrappers[param1].config.username = param2;
      }
      
      private function parseArguments(param1:Array) : void
      {
         var _loc3_:String = null;
         this.logInfo("parseArguments " + param1);
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            _loc3_ = String(param1[_loc2_]);
            if(_loc3_.indexOf("//") == 0)
            {
               this.logInfo("parseArguments hit comment marker, skipping");
               break;
            }
            this.processArgument(_loc3_);
            _loc2_++;
         }
      }
      
      protected function processArgument(param1:String) : Boolean
      {
         var _loc3_:GameWrapper = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:Array = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:Array = null;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:String = null;
         var _loc15_:Array = null;
         var _loc16_:int = 0;
         var _loc17_:String = null;
         var _loc18_:Array = null;
         var _loc19_:String = null;
         var _loc20_:Array = null;
         var _loc21_:int = 0;
         var _loc22_:Number = NaN;
         var _loc23_:String = null;
         var _loc2_:int = 0;
         this.logInfo("parsing arg " + param1);
         if(this.checkArg(param1,"local_assets"))
         {
            if(!localAssetsPath)
            {
               this.logError("Unable to use --local_assets because local_assets path was not set in ini file");
            }
            else if(this._argBool)
            {
               this.assetsOverridden = true;
               this.local_assets = true;
               assetsUrl = localAssetsPath;
            }
         }
         else if(this.checkArg(param1,"sagalog") || this.checkArg(param1,"slog"))
         {
            SagaLog.ENABLED = this._argBool;
         }
         else if(this.checkArg(param1,"debug") || this.checkArg(param1,"d"))
         {
            this.debug = this._argBool;
            for each(_loc3_ in wrappers)
            {
               (_loc3_.logger as Logger).isDebugEnabled = this._argBool;
            }
         }
         else if(this.checkArg(param1,"var_platform_override"))
         {
            Variable.ALLOW_PLATFORM_OVERRIDE = this._argBool;
         }
         else if(this.checkArg(param1,"tt_en"))
         {
            ClickablePair.ALLOW_TOOLTIPS_EN = this._argBool;
         }
         else if(this.checkArg(param1,"qaacv"))
         {
            Saga.QAACV = this._argBool;
         }
         else if(this.checkArg(param1,"debug_injury"))
         {
            StatType.DEBUG_INJURY = this._argBool;
         }
         else if(this.checkArg(param1,"mouse"))
         {
            this.softwareMouse = this._argBool;
         }
         else if(this.checkArg(param1,"video_enabled") || this.checkArg(param1,"vid"))
         {
            VideoPage.VIDEO_DISABLED = !this._argBool;
         }
         else if(this.checkArg(param1,"username"))
         {
            _loc4_ = this._argValue;
            this.logInfo("setting usernames " + _loc4_);
            this.usernamesv = _loc4_.split(",");
         }
         else if(this.checkArg(param1,"convo_report_narrow"))
         {
            ConvoView.REPORT_NARROW = this._argBool;
         }
         else if(this.checkArg(param1,"child"))
         {
            this.childs = this._argValue.split(",");
         }
         else if(this.checkArg(param1,"sound"))
         {
            this.sound = this._argBool;
         }
         else if(this.checkArg(param1,"server"))
         {
            this.serverOverridden = true;
            this.server = this._argValue;
         }
         else if(this.checkArg(param1,"censors"))
         {
            censors = this._argValue;
         }
         else if(this.checkArg(param1,"locale"))
         {
            locale_id = new LocaleId(this._argValue);
         }
         else if(this.checkArg(param1,"locale_report"))
         {
            Localizer.REPORT_ERRORS = this._argBool;
         }
         else if(this.checkArg(param1,"locale_add"))
         {
            appInfo.addLocales(this._argValue);
         }
         else if(this.checkArg(param1,"locale_insert"))
         {
            appInfo.insertLocales(this._argValue);
         }
         else if(this.checkArg(param1,"qa"))
         {
            this.serverOverridden = true;
            this.server = "http://tbs-dev-qa.stoicstudio.com/";
         }
         else if(this.checkArg(param1,"version"))
         {
            _loc5_ = this._argValue;
            for each(_loc3_ in wrappers)
            {
               _loc3_.appInfo.buildVersionOverride = _loc5_;
            }
         }
         else if(this.checkArg(param1,"mod_root"))
         {
            this.mod_root = this._argValue;
            this.mod_root = appInfo.pathToUrl(this.mod_root);
         }
         else if(this.checkArg(param1,"mods"))
         {
            _loc6_ = this._argValue;
            this.mod_ids = _loc6_.split(",");
            this.logInfo("Enabling mods [" + this.mod_ids.join(",") + "]");
         }
         else if(this.checkArg(param1,"assets"))
         {
            this.assetsOverridden = true;
            assetsUrl = this._argValue;
            assetsUrl = GameConfig.massageResourcePath(appInfo.nativeAppUrlRoot,wrappers[0].logger,assetsUrl);
            assetsUrl = appInfo.pathToUrl(assetsUrl);
         }
         else if(this.checkArg(param1,"abl_debug_incomplets"))
         {
            BattleAbilityManager.DEBUG_INCOMPLETES = this._argBool;
         }
         else if(this.checkArg(param1,"gui"))
         {
            this.gui = this._argValue;
         }
         else if(this.checkArg(param1,"party"))
         {
            this.parties = this.parseParties(this._argValue);
         }
         else if(this.checkArg(param1,"run_mode"))
         {
            runMode = Enum.parse(RunMode,this._argValue) as RunMode;
         }
         else if(this.checkArg(param1,"kiosk"))
         {
            runMode = RunMode.KIOSK;
         }
         else if(this.checkArg(param1,"survival"))
         {
            SagaDef.SURVIVAL_ENABLED = this._argBool;
         }
         else if(this.checkArg(param1,"survival_record"))
         {
            SagaSave.SURVIVAL_RECORD_ENABLED = this._argBool;
         }
         else if(this.checkArg(param1,"beta"))
         {
            runMode = RunMode.BETA;
         }
         else if(this.checkArg(param1,"developer") || this.checkArg(param1,"dev"))
         {
            this.developer = true;
            this.screen_flash_errors = true;
            this.logInfo("developer mode on");
         }
         else if(this.checkArg(param1,"screen_flash_errors"))
         {
            this.screen_flash_errors = this._argBool;
         }
         else if(this.checkArg(param1,"reset_prefs"))
         {
            for each(_loc3_ in wrappers)
            {
               _loc3_.config.globalPrefs.reset();
            }
         }
         else if(this.checkArg(param1,"turn"))
         {
            _loc7_ = this._argValue;
            _loc8_ = _loc7_.split(",");
            _loc2_ = 0;
            while(_loc2_ < _loc8_.length && _loc2_ < wrappers.length)
            {
               _loc3_ = wrappers[_loc2_];
               _loc3_.config.options.overrideTurnLengthSecs = _loc8_[_loc2_];
               _loc2_++;
            }
         }
         else if(this.checkArg(param1,"versus_countdown"))
         {
            this.versusCountdownOverrideSecs = int(this._argValue);
         }
         else if(this.checkArg(param1,"width") || this.checkArg(param1,"w"))
         {
            _loc9_ = int(this._argValue);
            this.windowWidth = _loc9_;
         }
         else if(this.checkArg(param1,"height") || this.checkArg(param1,"h"))
         {
            _loc10_ = int(this._argValue);
            this.windowHeight = _loc10_;
         }
         else if(this.checkArg(param1,"min_size"))
         {
            _loc11_ = this._argValue.split(",");
            _loc12_ = _loc11_.length > 0 ? int(_loc11_[0]) : 1000;
            _loc13_ = _loc11_.length > 1 ? int(_loc11_[1]) : 1000;
            appInfo.minSize = new Point(_loc12_,_loc13_);
         }
         else if(this.checkArg(param1,"versus_opponent"))
         {
            _loc14_ = this._argValue;
            _loc15_ = _loc14_.split(",");
            _loc2_ = 0;
            while(_loc2_ < _loc15_.length && _loc2_ < wrappers.length)
            {
               _loc3_ = wrappers[_loc2_];
               _loc3_.config.options.versusForceOpponentId = _loc15_[_loc2_];
               _loc2_++;
            }
         }
         else if(this.checkArg(param1,"versus_start"))
         {
            runMode = RunMode.FACTIONS;
            this.startInVs = true;
         }
         else if(this.checkArg(param1,"tourney"))
         {
            _loc16_ = int(this._argValue);
            for each(_loc3_ in wrappers)
            {
               _loc3_.config.options.versusForceTourneyId = _loc16_;
            }
         }
         else if(this.checkArg(param1,"versus_scene"))
         {
            _loc17_ = this._argValue;
            _loc18_ = _loc17_.split(",");
            _loc2_ = 0;
            while(_loc2_ < _loc18_.length && _loc2_ < wrappers.length)
            {
               _loc3_ = wrappers[_loc2_];
               _loc3_.config.options.versusForceScene = _loc18_[_loc2_];
               _loc2_++;
            }
         }
         else if(this.checkArg(param1,"combat"))
         {
            _loc19_ = this._argValue;
            this.logInfo("setting combats " + _loc19_);
            _loc20_ = _loc19_.split(",");
            _loc2_ = 0;
            while(_loc2_ < _loc20_.length && _loc2_ < wrappers.length)
            {
               _loc3_ = wrappers[_loc2_];
               _loc3_.config.options.startInCombat = _loc19_;
               _loc2_++;
            }
         }
         else if(this.checkArg(param1,"e3demo"))
         {
            this.e3demo = this._argBool;
         }
         else if(this.checkArg(param1,"under_construction"))
         {
            this.under_construction = this._argValue;
         }
         else if(this.checkArg(param1,"gdcdemo"))
         {
            if(this._argBool)
            {
               SagaDef.START_HAPPENING = "start_gdcdemo";
               this.parseForceVars("demomode_skip_newgame:1,start_news_disabled:1,gdcdemo:1");
               Saga.ALLOW_AUTOSAVE = false;
               this.developer = true;
               this.screen_flash_errors = false;
               GameWrapper.DEVELOPER_DEV_PANEL_HIDDEN = true;
               GuiSagaStartConfig.DEMO_MODE = true;
               GuiSagaOptionsConfig.DEMO_MODE = true;
            }
         }
         else if(this.checkArg(param1,"saga"))
         {
            sagaUrl = this._argValue;
            _loc21_ = sagaUrl.indexOf(":");
            if(_loc21_ > 0)
            {
               this.sagaHappening = sagaUrl.substring(_loc21_ + 1);
               sagaUrl = sagaUrl.substring(0,_loc21_);
            }
         }
         else if(this.checkArg(param1,"saga_start"))
         {
            SagaDef.START_HAPPENING = this._argValue;
         }
         else if(this.checkArg(param1,"load"))
         {
            this.sagaSaveLoad = this._argValue;
            _loc21_ = this.sagaSaveLoad.indexOf(":");
            if(_loc21_ > 0)
            {
               this.sagaSaveLoadProfile = int(this.sagaSaveLoad.substr(_loc21_ + 1));
               this.sagaSaveLoad = this.sagaSaveLoad.substr(0,_loc21_);
            }
         }
         else if(this.checkArg(param1,"happening") || this.checkArg(param1,"book") || this.checkArg(param1,"bk"))
         {
            this.sagaHappening = this._argValue;
            if(Platform.id == "xbo")
            {
               ScenePage.DEBUG_IGNORE_ALL_USER_XB_EVENTS = true;
               appInfo.establishInitialUser();
            }
         }
         else if(this.checkArg(param1,"saga_selector_disable") || this.checkArg(param1,"ssel_disable"))
         {
            this.parseSagaSelectorDisable(this._argValue);
         }
         else if(this.checkArg(param1,"vars") || this.checkArg(param1,"v"))
         {
            this.parseForceVars(this._argValue);
         }
         else if(this.checkArg(param1,"factions"))
         {
            this.offline = false;
            runMode = RunMode.FACTIONS;
         }
         else if(this.checkArg(param1,"fullscreen") || this.checkArg(param1,"fs"))
         {
            this.fullscreen = this._argBool;
            this.fullscreenSet = true;
         }
         else if(this.checkArg(param1,"log_anim_events"))
         {
            AnimController.log_anim_events = true;
         }
         else if(this.checkArg(param1,"offline"))
         {
            this.offline = this._argBool;
         }
         else if(this.checkArg(param1,"fmod_port"))
         {
            this.fmod_port = int(this._argValue);
         }
         else if(this.checkArg(param1,"fmod_debug"))
         {
            this.fmodDebug = this._argBool;
         }
         else if(this.checkArg(param1,"fmod_profile"))
         {
            this.fmod_profile = this._argBool;
         }
         else if(this.checkArg(param1,"fmod_studio"))
         {
            this.fmod_studio = this._argBool;
         }
         else if(this.checkArg(param1,"scene_audio_report_fails"))
         {
            SceneAudioEmitterAudible.REPORT_SET_FAILS = this._argBool;
         }
         else if(this.checkArg(param1,"fmod_event_expiration_ms"))
         {
            this.fmodEventExpirationMs = int(this._argValue);
         }
         else if(this.checkArg(param1,"json_validate"))
         {
            json_validate = this._argBool;
         }
         else if(this.checkArg(param1,"trigger_debug"))
         {
            TileTriggerTilesUnderlay.DEBUG_RENDER = this._argBool;
         }
         else if(this.checkArg(param1,"debug_txn_immediate_finalize"))
         {
            this.debugTxnImmediateFinalize = this._argBool;
         }
         else if(this.checkArg(param1,"debug_ready"))
         {
            GameConfig.READY_DEBUG = true;
         }
         else if(this.checkArg(param1,"tutorial"))
         {
            this.tutorial = this._argBool;
         }
         else if(this.checkArg(param1,"miner"))
         {
            root.addChild(new TheMiner());
         }
         else if(this.checkArg(param1,"spritesheet_debug_render"))
         {
            XAnimClipSpriteBase.DEBUG_RENDER_SPRITESHEET = this._argBool;
         }
         else if(this.checkArg(param1,"anim_show_total_bounds"))
         {
            XAnimClipSpriteBase.SHOW_TOTAL_BOUNDS = this._argBool;
         }
         else if(this.checkArg(param1,"new_music"))
         {
            this.new_music = this._argBool;
         }
         else if(this.checkArg(param1,"map_spline_debug"))
         {
            MapCampPage.DEBUG_SPLINE = this._argBool;
         }
         else if(this.checkArg(param1,"cloud"))
         {
            GameSaveSynchronizer.PULL_ENABLED = this._argBool;
         }
         else if(this.checkArg(param1,"cloud_purge_remote"))
         {
            CloudSaveConfig.PURGE_REMOTE = this._argBool;
         }
         else if(this.checkArg(param1,"save_screenshot_pregenerated"))
         {
            SaveManager.SAVE_SCREENSHOT_PREGENERATED = this._argBool;
         }
         else if(this.checkArg(param1,"landscape_bitmap"))
         {
            LandscapeViewConfig.ENABLE_BITMAPS = this._argBool;
         }
         else if(this.checkArg(param1,"gui_bitmap"))
         {
            GuiBitmapHolderHelper.ENABLED = this._argBool;
         }
         else if(this.checkArg(param1,"landscape_buffer"))
         {
            LandscapeViewConfig.BUFFER_RENDER_ENABLED = this._argBool;
         }
         else if(this.checkArg(param1,"landscape_debug_render_frame"))
         {
            LandscapeViewConfig.DEBUG_RENDER_FRAME = this._argBool;
         }
         else if(this.checkArg(param1,"matte_debug_render"))
         {
            MatteHelper.DEBUG_RENDER = this._argBool;
         }
         else if(this.checkArg(param1,"force_unlock_camera_pan"))
         {
            LandscapeViewConfig.FORCE_UNLOCK_CAMERA_PAN = this._argBool;
         }
         else if(this.checkArg(param1,"skip_location_triggers"))
         {
            Saga.SKIP_LOCATION_TRIGGERS = this._argBool;
         }
         else if(this.checkArg(param1,"flytext_screen"))
         {
            GameScreenFlyTextManagerAdapter.ENABLED = this._argBool;
         }
         else if(this.checkArg(param1,"quickload") || this.checkArg(param1,"ql"))
         {
            ScenePage.DISABLE_WIPEIN = this._argBool;
            Scene.DISABLE_BATTLEPAN = this._argBool;
            Action_Battle.FINISH_SAGA_DELAY = 1;
         }
         else if(this.checkArg(param1,"wipein"))
         {
            ScenePage.DISABLE_WIPEIN = !this._argBool;
         }
         else if(this.checkArg(param1,"battle_turn_wait"))
         {
            BattleStateTurnBase.INCOMPLETES_BLOCK_FINISH = this._argBool;
         }
         else if(this.checkArg(param1,"battlepan"))
         {
            Scene.DISABLE_BATTLEPAN = !this._argBool;
         }
         else if(this.checkArg(param1,"landscape_load_barrier"))
         {
            LandscapeViewConfig.LOAD_BARRIER_ENABLED = this._argBool;
         }
         else if(this.checkArg(param1,"landscape_anim"))
         {
            LandscapeViewConfig.ENABLE_ANIMS = this._argBool;
         }
         else if(this.checkArg(param1,"ai_eager"))
         {
            AiGlobalConfig.EAGER = this._argBool;
            if(AiGlobalConfig.EAGER)
            {
               SagaCheat.devCheat("args " + param1);
            }
         }
         else if(this.checkArg(param1,"ai_unwilling"))
         {
            AiGlobalConfig.UNWILLING = this._argBool;
            if(AiGlobalConfig.UNWILLING)
            {
               SagaCheat.devCheat("args " + param1);
            }
         }
         else if(this.checkArg(param1,"ai_debug"))
         {
            AiGlobalConfig.DEBUG = this._argBool;
         }
         else if(this.checkArg(param1,"ai"))
         {
            BattleFsmConfig.globalEnableAi = this._argBool;
            if(!BattleFsmConfig.globalEnableAi)
            {
               SagaCheat.devCheat("args " + param1);
            }
         }
         else if(this.checkArg(param1,"ai_player"))
         {
            BattleFsmConfig.globalPlayerAi = this._argBool;
            if(BattleFsmConfig.globalPlayerAi)
            {
               SagaCheat.devCheat("args " + param1);
            }
         }
         else if(this.checkArg(param1,"move_flood_cache"))
         {
            BattleMove.FLOOD_CACHE_DISABLE = !this._argBool;
         }
         else if(this.checkArg(param1,"landscape_opt"))
         {
            LandscapeViewConfig.DO_LLV = this._argBool;
         }
         else if(this.checkArg(param1,"weather"))
         {
            WeatherManager.ENABLED = this._argBool;
         }
         else if(this.checkArg(param1,"travel"))
         {
            Landscape.TRAVEL_ENABLED = this._argBool;
         }
         else if(this.checkArg(param1,"startgui"))
         {
            SagaStartPage.ENABLE_GUI = this._argBool;
         }
         else if(this.checkArg(param1,"fsm_nostart"))
         {
            Fsm.NO_START = this._argBool;
         }
         else if(this.checkArg(param1,"loc_keeptokens"))
         {
            Localizer.KEEP_TOKEN_LIST = this._argBool;
         }
         else if(this.checkArg(param1,"battle_assemble") || this.checkArg(param1,"bass"))
         {
            Action_Battle.ASSEMBLE_SKIP = !this._argBool;
         }
         else if(this.checkArg(param1,"talents"))
         {
            Talents.ENABLED = this._argBool;
         }
         else if(this.checkArg(param1,"talent_percent"))
         {
            TalentRankDef.PERCENT_OVERRIDE = int(this._argValue);
         }
         else if(this.checkArg(param1,"anim_compressed_frames"))
         {
            AnimFrame.COMPRESSED_FRAMES = this._argBool;
         }
         else if(this.checkArg(param1,"bigmem") || this.checkArg(param1,"bm"))
         {
            ResourceManager.BIGMEM = this._argBool;
         }
         else if(this.checkArg(param1,"quality_textures"))
         {
            _loc22_ = !!this._argValue ? Number(this._argValue) : 1;
            Platform.qualityTextures = _loc22_;
         }
         else if(this.checkArg(param1,"quality_stage"))
         {
            root.stage.quality = this._argValue;
         }
         else if(this.checkArg(param1,"resource_cache"))
         {
            ResourceCache.ENABLED = this._argBool;
         }
         else if(this.checkArg(param1,"resource_collect"))
         {
            ResourceCollector.ENABLED = this._argBool;
         }
         else if(this.checkArg(param1,"starling"))
         {
            _useStarling = this._argBool;
         }
         else if(this.checkArg(param1,"stage_color"))
         {
            PlatformStarling.STARLING_STAGE_COLOR = uint(this._argValue);
         }
         else if(this.checkArg(param1,"gp_nav_debug"))
         {
            GuiGpNav.DEBUG_RENDER = this._argBool;
         }
         else if(this.checkArg(param1,"gp_debug"))
         {
            GpSource.GP_DEBUG = this._argBool;
         }
         else if(this.checkArg(param1,"input_clicker"))
         {
            PlatformInput.hasClicker = this._argBool;
         }
         else if(this.checkArg(param1,"input_keyboard"))
         {
            PlatformInput.hasKeyboard = this._argBool;
         }
         else if(this.checkArg(param1,"gp"))
         {
            GpSource.GP_ENABLED = this._argBool;
         }
         else if(this.checkArg(param1,"gp_swap"))
         {
            GpControlButton.addSwapByNames(this._argValue.split(":"));
         }
         else if(this.checkArg(param1,"gp_config"))
         {
            GameConfig.GP_CONFIG_DISABLE = !this._argBool;
         }
         else if(this.checkArg(param1,"gp_keyboard"))
         {
            GpSource.GP_KEYBOARD = this._argBool;
         }
         else if(this.checkArg(param1,"bgcolor"))
         {
            this.bgColor = parseInt(this._argValue,16);
         }
         else if(this.checkArg(param1,"anim_png_required"))
         {
            AnimClipDef.REQUIRE_PNG = this._argBool;
         }
         else if(this.checkArg(param1,"resource_loader_framelimit_ms"))
         {
            ResourceManager.LOADER_PROCESSING_FRAMELIMIT_MS = int(this._argValue);
         }
         else if(this.checkArg(param1,"resource_loader_delay_ms"))
         {
            ResourceManager.LOADER_PROCESSING_DELAY = int(this._argValue);
         }
         else if(this.checkArg(param1,"resource_immediate"))
         {
            Resource.IMMEDIATE_PROCESS_LOAD_COMPLETION = this._argBool;
         }
         else if(this.checkArg(param1,"tweenmax_debug_ctor"))
         {
            TweenMax.DEBUG_CTOR = this._argBool;
         }
         else if(this.checkArg(param1,"resource_debug"))
         {
            Resource.DEBUG_RESOURCES = this._argBool;
         }
         else if(this.checkArg(param1,"uhd"))
         {
            ScreenAspectHelper.ENABLE_UHD = this._argBool;
         }
         else if(this.checkArg(param1,"path_flood_rejected_debug"))
         {
            PathFloodSolver.ENABLE_REJECTED_DEBUG = this._argBool;
         }
         else if(this.checkArg(param1,"fastmove"))
         {
            BattleEntityMobility.FAST_FORWARD = this._argBool;
         }
         else if(this.checkArg(param1,"fastwait"))
         {
            Action_Wait.DISABLE = this._argBool;
         }
         else if(this.checkArg(param1,"fastattack"))
         {
            ChainPhantasms.FAST_ATTACK = this._argBool;
         }
         else if(this.checkArg(param1,"fastall") || this.checkArg(param1,"fa"))
         {
            Fastall.fastall = this._argBool;
         }
         else if(this.checkArg(param1,"frametime_throttle_ms") || this.checkArg(param1,"ftt"))
         {
            GameEntry.FRAMETIME_THROTTLE_MS = int(this._argValue);
         }
         else if(this.checkArg(param1,"caravan_show_origin"))
         {
            CaravanView.SHOW_ORIGIN_MARKER = this._argBool;
         }
         else if(this.checkArg(param1,"textscale"))
         {
            Platform.textScale = Math.max(1,Number(this._argValue));
         }
         else if(this.checkArg(param1,"invis_show"))
         {
            EntityView.INVISIBLE_SHOW = this._argBool;
            if(EntityView.INVISIBLE_SHOW)
            {
               SagaCheat.devCheat("args " + param1);
            }
         }
         else if(this.checkArg(param1,"leaderboard") || this.checkArg(param1,"lb"))
         {
            SagaSurvival.ENABLED_LEADERBOARDS = this._argBool;
         }
         else if(this.checkArg(param1,"debug_hashed_saves"))
         {
            SagaSave.DEBUG_HASHED_SAVES = this._argBool;
         }
         else if(this.checkArg(param1,"localnews"))
         {
            SagaStartPage.NEWS_URL_OVERRIDE = this.computeLocalNewsUrl();
         }
         else if(this.checkArg(param1,"news"))
         {
            SagaStartPage.NEWS_URL_OVERRIDE = this._argValue;
         }
         else if(this.checkArg(param1,"gamelog"))
         {
            appInfo.addLogLocation(this._argValue);
         }
         else if(this.checkArg(param1,"ga_optstate"))
         {
            GaConfig.optStateFromString(this._argValue);
         }
         else if(this.checkArg(param1,GaConfig.PREF_GA_VERBOSITY))
         {
            GaConfig.setVerbosityFromString(this._argValue);
         }
         else if(this.checkArg(param1,"program"))
         {
            this.programPath = this._argValue;
            this.programText = appInfo.loadFileString(null,this.programPath);
            if(!this.programText)
            {
               this.logError("No such program file [" + this.programPath + "]");
            }
         }
         else if(this.checkArg(param1,"ptof"))
         {
            EngineAutomator.TERMINATE_ON_FAILURE = this._argBool;
         }
         else if(this.checkArg(param1,"preload_assets"))
         {
            preloadAssetPaths = this._argValue;
         }
         else if(this.checkArg(param1,"pairing_prompt"))
         {
            ScenePage.needsUserEngagementPrompt = this._argBool;
         }
         else if(this.checkArg(param1,"rng_seed"))
         {
            Saga.RNG_SEED_OVERRIDE = Number(this._argValue);
         }
         else
         {
            if(!this.checkArg(param1,"show_scaled_text_borders"))
            {
               _loc23_ = param1.charAt(0);
               if(_loc23_ != "#" && _loc23_ != "/")
               {
                  this.logError("Unknown Command Line Argument [" + param1 + "]");
               }
               return false;
            }
            GuiUtil.SHOW_TEXTFIELD_BORDERS = true;
         }
         return true;
      }
      
      private function computeLocalNewsUrl() : String
      {
         var _loc1_:String = master_sku.replace(/(\w+)(?=[0-9])/,"");
         var _loc2_:* = assetsUrl + "/" + master_sku + "/news/news" + _loc1_ + ".json";
         return _loc2_.replace("compile-assets","assets");
      }
      
      private function parseSagaSelectorDisable(param1:String) : void
      {
         var _loc3_:String = null;
         var _loc4_:Array = null;
         var _loc5_:String = null;
         var _loc6_:* = undefined;
         var _loc7_:Array = null;
         if(!param1)
         {
            return;
         }
         var _loc2_:Array = param1.split(",");
         for each(_loc3_ in _loc2_)
         {
            _loc4_ = _loc3_.split(":");
            if(_loc4_.length < 0)
            {
               throw new ArgumentError("Invalid saga selector disable [" + _loc3_ + "] for value [" + param1 + "]");
            }
            _loc5_ = String(_loc4_[0]);
            _loc6_ = _loc4_.length > 1 ? _loc4_[1] : true;
            if(!_loc5_)
            {
               throw new ArgumentError("Invalid saga selector disable in [" + _loc3_ + "] for value [" + param1 + "]");
            }
            _loc7_ = _loc6_.split("/");
            if(_loc7_.length != 2)
            {
               throw new ArgumentError("Invalid saga selector disable tokens in [" + _loc6_ + "] for value [" + param1 + "]");
            }
            this.logInfo("SAGA SELECTOR DISABLE: [" + _loc5_ + "] = " + _loc7_.join("/"));
            SagaSelectorPage.addDisable(_loc5_,_loc7_[0],_loc7_[1]);
         }
      }
      
      private function parseForceVars(param1:String) : void
      {
         var _loc3_:String = null;
         var _loc4_:Array = null;
         var _loc5_:String = null;
         var _loc6_:* = undefined;
         if(!param1)
         {
            return;
         }
         var _loc2_:Array = param1.split(",");
         for each(_loc3_ in _loc2_)
         {
            _loc4_ = _loc3_.split(":");
            if(_loc4_.length < 0)
            {
               throw new ArgumentError("Invalid force var [" + _loc3_ + "] for force vars [" + param1 + "]");
            }
            _loc5_ = String(_loc4_[0]);
            _loc6_ = _loc4_.length > 1 ? _loc4_[1] : true;
            if(!_loc5_)
            {
               throw new ArgumentError("Invalid force var name in [" + _loc3_ + "] for force vars [" + param1 + "]");
            }
            if(_loc5_.charAt(0) == "!")
            {
               _loc5_ = _loc5_.substring(1);
               _loc6_ = !_loc6_;
            }
            this.logInfo("FORCE VAR: [" + _loc5_ + "] = " + _loc6_);
            SagaConfig.addForceVars(_loc5_,_loc6_);
         }
      }
      
      protected function startGa() : void
      {
         var _loc6_:* = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:String = null;
         var _loc1_:String = appInfo.macAddress;
         if(!_loc1_)
         {
            Ga.stop("no mac address");
            return;
         }
         var _loc2_:String = Hash.DJBHash(_loc1_).toString(16);
         var _loc3_:String = appInfo.buildVersion;
         var _loc4_:ILogger = appInfo.logger;
         var _loc5_:String = String(appInfo.ini["google_uid"]);
         if(_loc5_)
         {
            _loc6_ = "tbs/" + master_sku;
            if(locally)
            {
               _loc6_ += "/locally";
            }
            else
            {
               _loc6_ += "/open";
            }
            LocMon.init(_loc4_,_loc3_,_loc2_);
            Ga.init(appInfo,_loc4_,_loc5_,_loc6_,_loc3_,_loc2_);
            _loc7_ = Capabilities.screenResolutionX;
            _loc8_ = Capabilities.screenResolutionY;
            _loc9_ = Capabilities.language;
            Ga.trackSessionStart(_loc7_,_loc8_,_loc9_);
         }
      }
      
      override protected function handleDoSetup() : Boolean
      {
         var _loc3_:GameWrapper = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:Array = null;
         var _loc9_:String = null;
         this.logInfo("doSetup with assetsUrl=[" + assetsUrl + "] nativeRoot=[" + appInfo.nativeAppUrlRoot + "]");
         saveManager.migrateSavesToProfile(master_sku);
         if(assetsUrl == null)
         {
            if(!locally)
            {
               if(Capabilities.os.indexOf("Windows") == 0)
               {
                  assetsUrl = GameConfig.massageResourcePath(appInfo.nativeAppUrlRoot,wrappers[0].logger,"../assets");
                  this.gui = GameConfig.massageResourcePath(appInfo.nativeAppUrlRoot,wrappers[0].logger,"../gui/");
               }
               else if(Capabilities.os.indexOf("Mac") == 0)
               {
                  _loc6_ = "../../../assets";
                  if(Platform.id == "macstore")
                  {
                     _loc6_ = "./assets";
                     this.logInfo("Using macstore special assetsUrl=" + _loc6_);
                  }
                  assetsUrl = GameConfig.massageResourcePath(appInfo.nativeAppUrlRoot,wrappers[0].logger,_loc6_);
                  this.gui = GameConfig.massageResourcePath(appInfo.nativeAppUrlRoot,wrappers[0].logger,"../../../gui");
               }
               else
               {
                  this.logInfo("UNSUPPORTED OS: " + Capabilities.os);
                  assetsUrl = "assets/";
                  this.gui = "gui/";
               }
            }
         }
         if(!this.mod_root)
         {
            assetsUrl += "/";
            _loc7_ = StringUtil.getFolder(assetsUrl);
            this.mod_root = _loc7_ + "/mod";
         }
         this.logInfo("doSetup computed assetsUrl=" + assetsUrl);
         if(this.disableGuiLoading)
         {
            this.gui = null;
         }
         this.logInfo("ARGS (" + this.invokeArguments.length + ") [" + this.invokeArguments + "]");
         var _loc1_:Array = this.invokeArguments.concat();
         var _loc2_:String = String(appInfo.ini["args"]);
         if(_loc1_.length == 0)
         {
            if(_loc2_)
            {
               this.logInfo("No command line arguments, using AppInfo args=[" + _loc2_ + "]");
               _loc8_ = _loc2_.split(" ");
               this.logInfo("iniArgsv=" + _loc8_.length + ", " + _loc8_);
               for each(_loc9_ in _loc8_)
               {
                  _loc1_.push(_loc9_);
               }
               this.logInfo("args now " + _loc1_);
            }
         }
         else if(_loc2_)
         {
            this.logInfo("Command line arguments found, ignoring AppInfo args=[" + _loc2_ + "]");
         }
         var _loc4_:int = 0;
         this.server = appInfo.ini["server"];
         this.e3demo = appInfo.ini["e3demo"] == 1;
         this.under_construction = appInfo.ini["under_construction"];
         if(appInfo.ini["restart_png"] != undefined)
         {
            SaveLoadPage.RESTART_BITMAP_URL = appInfo.ini["restart_png"];
         }
         if(this.server)
         {
            this.logInfo("serverOverridden by " + this.server);
            this.serverOverridden = true;
         }
         this.developer = BooleanVars.parse(appInfo.ini["developer"],this.developer);
         this.debug = BooleanVars.parse(appInfo.ini["debug"],this.debug);
         var _loc5_:String = String(appInfo.ini["saga_selector_disable"]);
         this.parseSagaSelectorDisable(_loc5_);
         this.parseArguments(_loc1_);
         if(this.e3demo)
         {
            this.logInfo("e3demo enabled");
            SagaDef.START_HAPPENING = null;
            SagaConfig.addForceVars("demo1",true);
            SagaStartPage.mcClazz = SagaStartPage.mcClazz_e3;
         }
         if(_useStarling)
         {
            PlatformStarling.init(appInfo.logger);
            PlatformStarling.instance.startup(root.stage);
            this.overlay = Starling.current.nativeOverlay;
            this.overlay.name = "starling_nativeOverlay";
         }
         else
         {
            this.overlay = root;
         }
         if(this.usernamesv)
         {
            this.initWrappers(this.usernamesv,this.debug);
         }
         root.stage.color = this.bgColor;
         if(json_validate)
         {
            EngineJsonDef._validate = EngineJsonDefImpl.validate;
         }
         if(wrappers[0].parent == null)
         {
            this.initWrappers([""],this.debug);
         }
         if(this.fullscreenSet)
         {
            wrappers[0].cmdFullscreen = true;
            wrappers[0].cmdFullscreenSet = this.fullscreen;
         }
         if(AppInfo.terminating)
         {
            return false;
         }
         return true;
      }
      
      protected function startGame() : void
      {
         var _loc1_:GameWrapper = null;
         var _loc4_:Boolean = false;
         this.logInfo("GameEntryDesktop.startGame");
         if(force_previewbuild_default && (this.betaBranch == "default" || !this.betaBranch))
         {
            this.logInfo("force_previewbuild_default");
            SagaDef.PREVIEW_BUILD = true;
         }
         if(FORCE_SSA)
         {
            this.logInfo("FORCE_SSA");
            StartState.SIMPLE_STEAM_AUTH_ENABLED = true;
         }
         var _loc2_:int = 0;
         while(_loc2_ < wrappers.length)
         {
            _loc1_ = wrappers[_loc2_];
            if(this.server)
            {
               _loc1_.config.gameServerUrl = this.server;
            }
            if(assetsUrl)
            {
               _loc1_.config.options.assetPath = assetsUrl;
            }
            _loc1_.config.options.under_construction = this.under_construction;
            _loc1_.config.options.consumeGlobalAssetPreloaderPaths(preloadAssetPaths);
            _loc1_.config.options.localesPath = assetsUrl;
            _loc1_.config.options.mod_ids = this.mod_ids;
            _loc1_.config.options.mod_root = this.mod_root;
            _loc1_.config.options.developer = this.developer;
            this.logInfo("wrapper.config.options.developer=" + _loc1_.config.options.developer);
            _loc1_.config.options.screenFlashErrors = this.screen_flash_errors;
            _loc1_.config.options.alwaysOffline = this.offline;
            _loc1_.config.options.softwareMouse = this.softwareMouse;
            _loc1_.config.options.startInSaga = sagaUrl;
            _loc1_.config.options.startInSagaHappening = this.sagaHappening;
            _loc1_.config.options.startInSagaSaveLoad = this.sagaSaveLoad;
            _loc1_.config.options.startInSagaSaveLoadProfile = this.sagaSaveLoadProfile;
            _loc1_.config.options.startInFactions = runMode == RunMode.FACTIONS;
            _loc1_.config.options.startInVersus = this.startInVs;
            _loc1_.config.options.debugTxnImmediateFinalize = this.debugTxnImmediateFinalize;
            _loc1_.config.options.testTutorial = this.tutorial;
            _loc1_.config.options.newMusic = this.new_music;
            _loc1_.config.options.programText = this.programText;
            if(locale_id)
            {
               _loc1_.config.options.locale_id = locale_id;
            }
            _loc1_.config.options.locale_id_system = locale_id_system;
            if(this.gui)
            {
               _loc1_.config.options.guiPath = this.gui;
            }
            if(Boolean(this.parties) && this.parties.length > _loc2_)
            {
               _loc1_.config.options.partyOverride = this.parties[_loc2_];
            }
            _loc1_.config.options.overrideVersusCountdownSecs = this.versusCountdownOverrideSecs;
            if(Boolean(this.childs) && this.childs.length > _loc2_)
            {
               _loc1_.config.options.accountChildNumber = this.childs[_loc2_];
            }
            _loc1_.config.runMode = runMode;
            _loc1_.config.options.soundEnabled = this.sound;
            _loc1_.config.options.fmodPort = this.fmod_port;
            _loc1_.config.options.fmodProfile = this.fmod_profile;
            _loc1_.config.options.fmodStudio = this.fmod_studio;
            _loc1_.startLoading();
            _loc2_++;
         }
         if(this.betaBuildText)
         {
            this.betaBuildText.name = "beta";
            this.betaBuildText.defaultTextFormat = new TextFormat("Vinque",16,16711680,true);
            this.betaBuildText.filters = [new GlowFilter(0,1,6,6,3)];
            this.betaBuildText.text = "BETA BUILD";
            this.betaBuildText.width = this.betaBuildText.textWidth + 10;
            this.betaBuildText.height = this.betaBuildText.textHeight * 2;
            this.betaBuildText.x = root.width - this.betaBuildText.width - 20;
            this.betaBuildText.y = -5;
            this.betaBuildText.mouseEnabled = false;
            root.addChild(this.betaBuildText);
         }
         var _loc3_:String = "";
         if(SagaDef.PREVIEW_BUILD)
         {
            _loc3_ += "  Steam " + this.userId + " PREVIEW " + appInfo.buildVersion;
            _loc4_ = true;
         }
         else if(this.betaBranch == "beta")
         {
            _loc3_ += "  Steam " + this.userId + " BETA " + appInfo.buildVersion;
            _loc4_ = true;
         }
         if(this.serverOverridden)
         {
            _loc3_ += "  SERVER: " + this.server;
         }
         if(this.assetsOverridden)
         {
            _loc3_ += "  ASSETS: " + assetsUrl;
         }
         if(_loc3_)
         {
            this._createWatermark(_loc3_,!_loc4_);
         }
      }
      
      override protected function update(param1:int) : void
      {
         super.update(param1);
      }
      
      private function _createPiratemark() : void
      {
         if(this._pirateMark)
         {
            return;
         }
         var _loc1_:String = "";
         _loc1_ += "  SEASICK " + this.userId + " " + this.betaBranch + " " + appInfo.buildVersion;
         this._pirateMark = this._createWatermark(_loc1_,false);
      }
      
      private function _createWatermark(param1:String, param2:Boolean) : TextField
      {
         var overrideBar:TextField = null;
         var txt:String = param1;
         var dismissable:Boolean = param2;
         overrideBar = new TextField();
         overrideBar.name = "watermark";
         overrideBar.defaultTextFormat = new TextFormat("_typewriter",16,16711680,true);
         overrideBar.filters = [new GlowFilter(0,1,6,6,3)];
         root.addChild(overrideBar);
         overrideBar.text = txt;
         overrideBar.cacheAsBitmap = true;
         overrideBar.x = 100;
         overrideBar.y = 2 + this._watermarked;
         overrideBar.width = overrideBar.textWidth + 10;
         overrideBar.height = overrideBar.textHeight * 2;
         this._watermarked += overrideBar.height;
         if(dismissable)
         {
            overrideBar.mouseEnabled = true;
            overrideBar.addEventListener(MouseEvent.CLICK,function(param1:MouseEvent):void
            {
               if(Boolean(overrideBar) && Boolean(overrideBar.parent))
               {
                  logInfo("Removing OVERRIDE BAR: " + overrideBar.text);
                  root.removeChild(overrideBar);
                  overrideBar = null;
               }
            });
         }
         else
         {
            overrideBar.mouseEnabled = false;
         }
         return overrideBar;
      }
      
      private function parseParties(param1:String) : Vector.<Vector.<String>>
      {
         var _loc4_:String = null;
         var _loc5_:Array = null;
         var _loc6_:Vector.<String> = null;
         var _loc7_:String = null;
         var _loc2_:Array = param1.split(",");
         var _loc3_:Vector.<Vector.<String>> = new Vector.<Vector.<String>>();
         for each(_loc4_ in _loc2_)
         {
            _loc5_ = _loc4_.split(":");
            _loc6_ = new Vector.<String>();
            for each(_loc7_ in _loc5_)
            {
               _loc6_.push(_loc7_);
            }
            _loc3_.push(_loc6_);
         }
         return _loc3_;
      }
      
      protected function setFmodStudioDriver(param1:Class) : void
      {
         var _loc2_:GameWrapper = null;
         var _loc3_:int = 0;
         while(_loc3_ < wrappers.length)
         {
            _loc2_ = wrappers[_loc3_];
            if(_loc2_.config.options.fmodStudio)
            {
               _loc2_.config.setSoundDriverClazz(param1);
            }
            _loc3_++;
         }
      }
      
      public function handleExit() : void
      {
         var _loc1_:GameWrapper = null;
         root.stage.color = 0;
         if(this.handledExit)
         {
            return;
         }
         Ga.trackSessionEnd();
         this.handledExit = true;
         ResourceCollector.output(appInfo,wrappers[0].config.resman);
         for each(_loc1_ in wrappers)
         {
            _loc1_.cleanup();
         }
      }
   }
}
