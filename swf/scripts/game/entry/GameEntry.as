package game.entry
{
   import com.greensock.TweenLite;
   import com.greensock.TweenMax;
   import com.stoicstudio.platform.KeyboardMouseBlocker;
   import com.stoicstudio.platform.Platform;
   import com.stoicstudio.platform.PlatformFlash;
   import com.stoicstudio.platform.PlatformInput;
   import com.stoicstudio.platform.PlatformStarling;
   import engine.core.RunMode;
   import engine.core.analytic.GaConfig;
   import engine.core.cmd.KeyBinder;
   import engine.core.gp.GpSource;
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleId;
   import engine.core.render.BoundedCamera;
   import engine.core.util.AppInfo;
   import engine.core.util.EngineEnumInit;
   import engine.core.util.json.JsonValid;
   import engine.def.BooleanVars;
   import engine.gui.GuiMouse;
   import engine.gui.core.GuiApplication;
   import engine.heraldry.HeraldrySystem;
   import engine.resource.ResourceCache;
   import engine.resource.ResourceCensor;
   import engine.resource.ResourceCollector;
   import engine.saga.save.SaveManager;
   import engine.saga.vars.VariableDefVars;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.system.Capabilities;
   import flash.ui.Keyboard;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import game.cfg.GameEnumInit;
   import game.gui.GameDownloadingSprite;
   import game.gui.page.SagaOptionsPage;
   import game.view.GameWrapper;
   
   public class GameEntry
   {
      
      public static const DEFAULT_RUNMODE:RunMode = RunMode.BETA;
      
      public static var FRAMETIME_THROTTLE_MS:int = 0;
      
      private static var DO_TEST_DOWNLOAD_GUI:Boolean = false;
       
      
      public var wrappers:Vector.<GameWrapper>;
      
      public var use_resource_cache:Boolean;
      
      public var appInfo:AppInfo;
      
      protected var root:GuiApplication;
      
      public var nativeTextClazz:Class;
      
      public var gameDevSocketClazz:Class;
      
      protected var _useStarling:Boolean;
      
      public var assetsUrl:String;
      
      private var userDirectoryUrl:String;
      
      private var isDeactivatedPaused:Boolean = false;
      
      protected var downloadSprite:GameDownloadingSprite;
      
      protected var saveManager:SaveManager;
      
      public var locale_id_system:LocaleId;
      
      public var locale_id:LocaleId;
      
      public var censors:String;
      
      public var tilt:GameTilt;
      
      public var resetOnActivate:Boolean = false;
      
      protected var json_validate:Boolean = false;
      
      public var master_sku:String;
      
      public var sagaUrl:String;
      
      protected var localAssetsPath:String;
      
      public var runMode:RunMode;
      
      protected var locally:Boolean;
      
      public var preloadAssetPaths:String;
      
      private var activated:Boolean = true;
      
      public var pauseOnDeactivate:Boolean = false;
      
      private var _gamePaused:Boolean;
      
      private var _paused:Boolean;
      
      private var blocker:KeyboardMouseBlocker;
      
      public var backwardsUpdate:Boolean;
      
      private var lastUpdateTime:int = 0;
      
      private var timerMs:int;
      
      private var keyboardPauseAdvanceTime:int;
      
      private var keyboardPauseAdvanceTimeRepeatThresholdMs:int = 200;
      
      private var testDownloadTimer:Timer;
      
      private var testDownloadProgress:int = 0;
      
      public function GameEntry(param1:GuiApplication, param2:AppInfo, param3:Class, param4:String, param5:Class, param6:Class, param7:Class)
      {
         var wrapper:GameWrapper;
         var root:GuiApplication = param1;
         var appInfo:AppInfo = param2;
         var soundDriverClazz:Class = param3;
         var userDirectoryUrl:String = param4;
         var nativeTextClazz:Class = param5;
         var gameDevSocketClazz:Class = param6;
         var saveManagerClazz:Class = param7;
         this.wrappers = new Vector.<GameWrapper>();
         this.runMode = DEFAULT_RUNMODE;
         super();
         this.locale_id_system = new LocaleId(appInfo.getSystemLocale());
         this.locale_id = this.locale_id_system;
         PlatformInput.init();
         ResourceCollector.init();
         Platform.dispatcher.addEventListener(Platform.EVENT_TEXTSCALE,this.textScaleHandler);
         TweenLite.autoUpdate = false;
         root.allowDelayedResize();
         new EngineEnumInit();
         new GameEnumInit();
         this.userDirectoryUrl = userDirectoryUrl;
         this.root = root;
         this.appInfo = appInfo;
         JsonValid.logger = appInfo.logger;
         PlatformFlash.stage = root.stage;
         this.nativeTextClazz = nativeTextClazz;
         this.gameDevSocketClazz = gameDevSocketClazz;
         root.addEventListener(Event.ENTER_FRAME,this.enterFrameHandler,false,255);
         appInfo.addEventListener(Event.ACTIVATE,this.appActivateHandler);
         appInfo.addEventListener(Event.DEACTIVATE,this.appDeactivateHandler);
         appInfo.addEventListener(Event.SUSPEND,this.appSuspendHandler);
         this.saveManager = new saveManagerClazz(appInfo);
         wrapper = new GameWrapper(0,appInfo,soundDriverClazz,false,nativeTextClazz,gameDevSocketClazz,this.saveManager);
         this.wrappers.push(wrapper);
         BoundedCamera.computeDpiFingerScale();
         try
         {
            this.loadIni();
         }
         catch(e:Error)
         {
            appInfo.logger.error("unable to complete loading of ini");
         }
      }
      
      protected function textScaleHandler(param1:Event) : void
      {
         this.root.performResizeEventNow();
      }
      
      protected function loadIni() : void
      {
         var _loc7_:Array = null;
         var _loc8_:String = null;
         var _loc9_:Array = null;
         var _loc10_:String = null;
         var _loc11_:int = 0;
         this.appInfo.loadIni("tbs_config");
         this.master_sku = this.appInfo.master_sku;
         if(!this.master_sku)
         {
            throw new ArgumentError("FAILED TO FIND SKU IN CONFIG");
         }
         var _loc1_:String = this.appInfo.ini["locale"];
         if(_loc1_)
         {
            this.locale_id = new LocaleId(_loc1_);
         }
         Locale.APP_TITLE_TOKEN = this.appInfo.ini["app_title_token"];
         this.sagaUrl = this.appInfo.ini["saga"];
         this.localAssetsPath = this.appInfo.ini["local_assets"];
         if(this.appInfo.ini["factions"])
         {
            this.runMode = RunMode.FACTIONS;
         }
         var _loc2_:* = this.appInfo.ini["json_validate"];
         if(_loc2_ != undefined)
         {
            this.json_validate = _loc2_ != 0;
         }
         var _loc3_:* = this.appInfo.ini["starling"];
         if(_loc3_ != undefined)
         {
            this._useStarling = _loc3_ != 0;
         }
         if(Capabilities.isDebugger)
         {
            this.localAssetsPath = this.appInfo.nativeAppUrlRoot;
            this.localAssetsPath = this.localAssetsPath.replace(/\/game\/code\/.*/,"/compile-assets");
         }
         if(this.localAssetsPath)
         {
            this.localAssetsPath = this.localAssetsPath.replace("$HOME",this.userDirectoryUrl);
         }
         var _loc4_:* = this.appInfo.ini["saga_var_starts"];
         if(_loc4_ != undefined)
         {
            _loc7_ = (_loc4_ as String).split(",");
            for each(_loc8_ in _loc7_)
            {
               _loc9_ = _loc8_.split(":");
               if(_loc9_.length == 2)
               {
                  _loc10_ = _loc9_[0];
                  _loc11_ = int(_loc9_[1]);
                  VariableDefVars.setSagaVarStartOverride(_loc10_,_loc11_);
               }
            }
         }
         var _loc5_:Boolean = BooleanVars.parse(this.appInfo.ini["suppress_additional_heraldry"],false);
         if(_loc5_)
         {
            HeraldrySystem.SUPPRESS_ADDITIONAL_HERALDRY = _loc5_;
         }
         SagaOptionsPage.ENABLE_SHARE_BAR = !this.appInfo.ini["options_share_disabled"];
         var _loc6_:* = this.appInfo.ini["preload_assets"];
         if(_loc6_)
         {
            this.preloadAssetPaths = _loc6_;
         }
         if(GaConfig.optState.isNa)
         {
            GaConfig.optStateFromString(this.appInfo.ini["ga_optstate"]);
         }
         this.locally = this.appInfo.buildVersion.indexOf("locally") == 0;
      }
      
      public function set gamePaused(param1:Boolean) : void
      {
         if(this._gamePaused == param1)
         {
            return;
         }
         this._gamePaused = param1;
         this.checkPaused();
      }
      
      public function get gamePaused() : Boolean
      {
         return this._gamePaused;
      }
      
      private function checkPaused() : void
      {
         var _loc2_:GameWrapper = null;
         var _loc1_:Boolean = this._gamePaused || this.isDeactivatedPaused;
         if(_loc1_ == this._paused)
         {
            return;
         }
         this._paused = _loc1_;
         if(this._paused)
         {
            this.appInfo.logger.info("Pausing application.");
            for each(_loc2_ in this.wrappers)
            {
               if(_loc2_.config && _loc2_.config.saga && Boolean(_loc2_.config.saga.sound))
               {
                  _loc2_.config.saga.sound.pauseAllSounds();
               }
            }
            TweenMax.pauseAll(true,true);
            Platform.pause();
            if(this.blocker)
            {
               this.blocker.cleanup();
            }
            this.blocker = new KeyboardMouseBlocker();
         }
         else
         {
            this.appInfo.logger.info("Unpausing application.");
            Platform.suspended = false;
            this.lastUpdateTime = getTimer();
            TweenLite.updateTimer(this.timerMs);
            TweenMax.resumeAll(true,true);
            for each(_loc2_ in this.wrappers)
            {
               if(_loc2_.config && _loc2_.config.saga && Boolean(_loc2_.config.saga.sound))
               {
                  _loc2_.config.saga.sound.unpauseAllSounds();
               }
            }
            Platform.resume();
            if(this.blocker)
            {
               this.blocker.cleanup();
               this.blocker = null;
            }
         }
         GuiMouse.gamePaused = this._paused;
         this.checkGpInput();
      }
      
      private function checkGpInput() : void
      {
         GpSource.instance.enabled = !this._paused && this.activated;
      }
      
      protected function appActivateHandler(param1:Event) : void
      {
         if(this.resetOnActivate)
         {
            PlatformStarling.instance.reset();
            this.resetOnActivate = false;
         }
         this.activated = true;
         if(this.pauseOnDeactivate && this.isDeactivatedPaused)
         {
            this.isDeactivatedPaused = false;
            this.checkPaused();
         }
         else
         {
            this.checkGpInput();
         }
      }
      
      protected function appDeactivateHandler(param1:Event) : void
      {
         this.activated = false;
         if(this.pauseOnDeactivate && !this.isDeactivatedPaused)
         {
            this.isDeactivatedPaused = true;
            this.checkPaused();
         }
         else
         {
            this.checkGpInput();
         }
      }
      
      private function appSuspendHandler(param1:Event) : void
      {
         Platform.suspended = true;
      }
      
      private function enterFrameHandler(param1:Event) : void
      {
         var event:Event = param1;
         var updateTime:int = getTimer();
         var delta:int = Math.max(updateTime - this.lastUpdateTime,1);
         if(this.lastUpdateTime == 0)
         {
            delta = 0;
            this.lastUpdateTime = updateTime;
         }
         if(delta < FRAMETIME_THROTTLE_MS)
         {
            return;
         }
         this.lastUpdateTime = updateTime;
         if(this.pauseOnDeactivate)
         {
            if(!this.activated || Platform.suspended)
            {
               return;
            }
         }
         try
         {
            this.update(delta);
         }
         catch(e:Error)
         {
            appInfo.logger.error("Update error:\n" + e + "\n" + e.getStackTrace());
         }
      }
      
      protected function update(param1:int) : void
      {
         var wl:int;
         var i:int;
         var keyboardPauseEngaged:Boolean = false;
         var enterDown:Boolean = false;
         var w:GameWrapper = null;
         var delta:int = param1;
         var keybinder:KeyBinder = KeyBinder.keybinder;
         if(keybinder)
         {
            keyboardPauseEngaged = Boolean(keybinder.keysDown[Keyboard.SPACE]) && Boolean(keybinder.keysDown[Keyboard.CONTROL]);
            if(keyboardPauseEngaged)
            {
               enterDown = Boolean(keybinder.keysDown[Keyboard.ENTER]);
               if(!enterDown)
               {
                  this.keyboardPauseAdvanceTime = -1;
                  return;
               }
               if(this.keyboardPauseAdvanceTime < 0)
               {
                  this.keyboardPauseAdvanceTime = delta;
               }
               else if(this.keyboardPauseAdvanceTime < this.keyboardPauseAdvanceTimeRepeatThresholdMs)
               {
                  this.keyboardPauseAdvanceTime += delta;
                  return;
               }
            }
         }
         this.timerMs += delta;
         if(this.appInfo)
         {
            Platform.update(delta,this.appInfo.logger);
         }
         if(this.tilt)
         {
            this.tilt.update(delta);
         }
         if(this.backwardsUpdate && Boolean(PlatformStarling.instance))
         {
            PlatformStarling.instance.update();
         }
         try
         {
            if(TweenLite.rootTimeline)
            {
               TweenLite.updateTimer(this.timerMs);
            }
         }
         catch(e:Error)
         {
            appInfo.logger.error("Failed to update tweens\n" + e.getStackTrace());
            TweenMax.killAll();
         }
         wl = this.wrappers.length;
         i = 0;
         while(i < wl)
         {
            w = this.wrappers[i];
            w.update(delta);
            i++;
         }
         Platform.pauseDuration = 0;
         if(!this.backwardsUpdate && Boolean(PlatformStarling.instance))
         {
            PlatformStarling.instance.update();
         }
      }
      
      public function doSetup() : Boolean
      {
         if(DO_TEST_DOWNLOAD_GUI)
         {
            this.testDownloadTimer = new Timer(100,0);
            this.testDownloadTimer.addEventListener(TimerEvent.TIMER,this.testDownloadTimerHandler);
            this.createDownloadSprite();
            this.testDownloadTimer.start();
            return false;
         }
         if(this.handleDoSetup() && !AppInfo.terminating)
         {
            if(this.use_resource_cache)
            {
               this.appInfo.resourceCache = new ResourceCache(this.appInfo);
            }
            this.loadCensor();
            return true;
         }
         this.appInfo.logger.info("Exiting - not okay or terminating.");
         return false;
      }
      
      private function loadCensor() : void
      {
         var _loc1_:String = null;
         var _loc4_:String = null;
         var _loc5_:Object = null;
         if(!this.censors)
         {
            this.censors = this.appInfo.ini["censors"];
         }
         if(!this.censors)
         {
            return;
         }
         this.appInfo.logger.i("CENS","Processing censors string [" + this.censors + "]");
         var _loc2_:int = this.censors.indexOf(":");
         if(_loc2_ >= 0)
         {
            _loc1_ = this.censors.substring(0,_loc2_);
            this.censors = this.censors.substring(_loc2_ + 1);
         }
         else
         {
            this.appInfo.logger.i("CENS","No id for censors string");
         }
         var _loc3_:Array = this.censors.split(",");
         this.appInfo.resourceCensor = new ResourceCensor(_loc1_);
         for each(_loc4_ in _loc3_)
         {
            _loc5_ = this.appInfo.loadFileJsonZ(AppInfo.DIR_ABSOLUTE,this.assetsUrl + _loc4_);
            if(!_loc5_)
            {
               this.appInfo.logger.e("CENS","Failed to load censor file [" + _loc4_ + "]");
            }
            else
            {
               this.appInfo.logger.i("CENS","Loaded censor file [" + _loc4_ + "]");
               this.appInfo.resourceCensor.appendJson(_loc5_,this.appInfo.logger);
            }
         }
      }
      
      protected function handleDoSetup() : Boolean
      {
         return true;
      }
      
      final protected function createDownloadSprite() : void
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         var _loc3_:String = null;
         if(this.downloadSprite)
         {
            return;
         }
         var _loc4_:String = this.appInfo.getLocaleMapping(!!this.locale_id ? this.locale_id.id : "en");
         if(this.locale_id == null || this.locale_id.id != _loc4_)
         {
            this.locale_id = new LocaleId(_loc4_);
         }
         _loc1_ = this.appInfo.getLocalizedString("str_download_title",_loc4_);
         _loc2_ = this.appInfo.getLocalizedString("str_download_body",_loc4_);
         _loc3_ = this.appInfo.getLocalizedString("str_download_progress",_loc4_);
         this.downloadSprite = new GameDownloadingSprite(this.appInfo.logger,this.locale_id,_loc1_,_loc2_,_loc3_);
         this.root.addChild(this.downloadSprite);
      }
      
      final protected function removeDownloadSprite() : void
      {
         if(this.downloadSprite)
         {
            if(this.downloadSprite.parent)
            {
               this.downloadSprite.parent.removeChild(this.downloadSprite);
            }
            this.downloadSprite.cleanup();
            this.downloadSprite = null;
         }
      }
      
      private function testDownloadTimerHandler(param1:TimerEvent) : void
      {
         ++this.testDownloadProgress;
         this.downloadSprite.setProgressPercent(this.testDownloadProgress * 0.01);
      }
      
      public function get useStarling() : Boolean
      {
         return this._useStarling;
      }
   }
}
