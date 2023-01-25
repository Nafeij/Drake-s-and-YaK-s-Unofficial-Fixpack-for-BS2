package game.entry
{
   import engine.core.analytic.Ga;
   import engine.core.analytic.LocMon;
   import engine.core.logging.ILogger;
   import engine.core.util.AppInfo;
   import engine.core.util.CloudSave;
   import engine.core.util.CloudSaveDefault;
   import engine.core.util.CloudSaveSynchronizer;
   import engine.core.util.StringUtil;
   import engine.gui.core.GuiApplication;
   import engine.math.Hash;
   import engine.resource.ResourceManager;
   import engine.resource.loader.SagaURLLoader;
   import flash.desktop.NativeApplication;
   import flash.display.NativeWindow;
   import flash.display.StageQuality;
   import flash.events.Event;
   import flash.events.InvokeEvent;
   import flash.events.TimerEvent;
   import flash.filesystem.File;
   import flash.system.Capabilities;
   import flash.utils.Timer;
   import game.saga.AirGameSaveSynchronizer;
   import game.save.SaveManagerAir;
   import game.session.states.VideoState;
   import game.view.GameDevSocket;
   import game.view.GameWrapper;
   import lib.engine.resource.air.FallbackVideoFinder;
   import lib.engine.resource.air.ZipFileResourceScheme;
   import lib.engine.util.air.AirAppInfo;
   import lib.engine.util.air.NativeText;
   import lib.fmodstudio.FmodStudioSoundDriver;
   
   public class GameEntryDesktopAir extends GameEntryDesktop
   {
       
      
      private var invoked:Boolean;
      
      private var readyToSetup:Boolean;
      
      private var exitTimer:Timer;
      
      private var entryHelper:IEntryHelperDesktop;
      
      public function GameEntryDesktopAir(param1:GuiApplication, param2:String, param3:String, param4:String)
      {
         this.exitTimer = new Timer(500,1);
         super(param1,new AirAppInfo(param1,param2,param3,param4,0),FmodStudioSoundDriver,File.userDirectory.url,NativeText,GameDevSocket,SaveManagerAir);
         VideoState.USE_1080_MP4 = true;
         param1.stage.quality = StageQuality.BEST;
         param1.stage.color = 0;
      }
      
      public function setEntryHelper(param1:IEntryHelperDesktop) : void
      {
         this.entryHelper = param1;
         if(param1)
         {
            param1.init(this);
         }
      }
      
      override public function set windowWidth(param1:int) : void
      {
         var _loc2_:NativeWindow = NativeApplication.nativeApplication.activeWindow;
         if(!_loc2_)
         {
            return;
         }
         _loc2_.x = Math.max(0,_loc2_.x - (param1 - _loc2_.width));
         _loc2_.width = param1;
      }
      
      override public function set windowHeight(param1:int) : void
      {
         var _loc2_:NativeWindow = NativeApplication.nativeApplication.activeWindow;
         if(!_loc2_)
         {
            return;
         }
         _loc2_.y = Math.max(0,_loc2_.y - (param1 - _loc2_.height));
         _loc2_.height = param1;
      }
      
      override public function set fmodDebug(param1:Boolean) : void
      {
         FmodStudioSoundDriver._debug = param1;
         if(param1)
         {
            this.debug = param1;
         }
      }
      
      override public function set fmodEventExpirationMs(param1:int) : void
      {
         FmodStudioSoundDriver._eventExpirationMs = param1;
      }
      
      public function invokeHandler(param1:InvokeEvent) : void
      {
         logInfo("INVOKE reason=[" + param1.reason + "] arguments=[" + param1.arguments + "]");
         if(this.invoked)
         {
            return;
         }
         if(AppInfo.terminating)
         {
            return;
         }
         root.invoked = true;
         this.invoked = true;
         logInfo("INVOKE approot=[" + appInfo.nativeAppUrlRoot + "]");
         var _loc3_:String = String(param1.currentDirectory.nativePath);
         logInfo("INVOKE CWD=[" + _loc3_ + "]");
         invokeArguments = param1.arguments;
         this.readyToSetup = true;
         var _loc4_:Boolean = doSetup();
         if(_loc4_)
         {
            this.startGa();
            if(AppInfo.terminating)
            {
               return;
            }
            logInfo("Starting game");
            this.startGame();
         }
      }
      
      override protected function initWrapper(param1:int, param2:Array) : GameWrapper
      {
         var _loc3_:* = wrappers.length == param1;
         var _loc4_:GameWrapper = super.initWrapper(param1,param2);
         if(_loc3_ && Boolean(this.entryHelper))
         {
            this.entryHelper.initWrapper(_loc4_);
         }
         return _loc4_;
      }
      
      override protected function handleDoSetup() : Boolean
      {
         var _loc1_:Boolean = super.handleDoSetup();
         if(_loc1_)
         {
            if(this.entryHelper)
            {
               this.entryHelper.setup();
            }
         }
         return _loc1_;
      }
      
      override protected function startGame() : void
      {
         var _loc1_:CloudSave = null;
         var _loc3_:GameWrapper = null;
         if(this.entryHelper)
         {
            _loc1_ = this.entryHelper.initCloudSave(wrappers[0].config,appInfo);
            betaBranch = this.entryHelper.betaBranch;
            userId = this.entryHelper.userId;
         }
         else
         {
            _loc1_ = new CloudSaveDefault("none",null);
         }
         var _loc2_:CloudSaveSynchronizer = new CloudSaveSynchronizer(appInfo.logger);
         if(_loc2_)
         {
            _loc2_.registerCloudSave(_loc1_);
            AirGameSaveSynchronizer.init(wrappers[0].config,_loc2_);
         }
         this.setupZipAssets();
         super.startGame();
         setFmodStudioDriver(FmodStudioSoundDriver);
         var _loc4_:int = 0;
         while(_loc4_ < wrappers.length)
         {
            _loc3_ = wrappers[_loc4_];
            if(this.entryHelper)
            {
               this.entryHelper.startWrapper(_loc3_,_loc4_);
            }
            _loc4_++;
         }
      }
      
      private function setupZipAssets() : void
      {
         var _loc1_:File = null;
         var _loc2_:String = null;
         var _loc3_:ZipFileResourceScheme = null;
         var _loc4_:FallbackVideoFinder = null;
         if(StringUtil.endsWith(assetsUrl,".zip"))
         {
            _loc1_ = new File(assetsUrl);
            _loc2_ = StringUtil.getFilename(assetsUrl);
            appInfo.logger.info("Zip file " + _loc1_.nativePath);
            _loc3_ = new ZipFileResourceScheme(appInfo.logger);
            _loc3_.registerZipFile(assetsUrl,_loc1_);
            SagaURLLoader.registerSchema("zip",_loc3_);
            _loc3_.setupForVideo();
            assetsUrl = "zip:/" + _loc2_;
            _loc4_ = new FallbackVideoFinder(_loc3_,assetsUrl,"video",appInfo.logger);
            ResourceManager.videoURLTransform = _loc4_;
         }
      }
      
      override protected function startGa() : void
      {
         var _loc10_:* = null;
         var _loc11_:Boolean = false;
         var _loc12_:String = null;
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
         var _loc6_:Vector.<String> = null;
         if(_loc5_)
         {
            _loc10_ = "tbs/" + master_sku;
            if(locally)
            {
               _loc10_ += "/locally";
            }
            else if(Boolean(this.entryHelper) && (Boolean(_loc6_ = this.entryHelper.getAnalyticsInfo())))
            {
               _loc10_ += _loc6_[0];
               _loc12_ = _loc6_[1];
               if(_loc12_)
               {
                  _loc2_ = Hash.DJBHash(_loc12_).toString(16);
               }
            }
            else
            {
               _loc10_ += "/unknown";
               _loc11_ = true;
            }
            if(Capabilities.isDebugger || developer || Boolean(sagaHappening))
            {
               _loc10_ += "/developer";
            }
            LocMon.init(_loc4_,_loc3_,_loc2_);
            Ga.init(appInfo,_loc4_,_loc5_,_loc10_,_loc3_,_loc2_);
            if(_loc11_)
            {
               this.startGa_reportUnknown();
            }
         }
         var _loc7_:int = Capabilities.screenResolutionX;
         var _loc8_:int = Capabilities.screenResolutionY;
         var _loc9_:String = Capabilities.language;
         Ga.trackSessionStart(_loc7_,_loc8_,_loc9_);
      }
      
      private function startGa_reportUnknown() : void
      {
         var _loc4_:String = null;
         var _loc1_:String = appInfo.macAddress;
         _loc1_ = !!_loc1_ ? _loc1_ : "nomacaddress";
         var _loc2_:uint = Hash.DJBHash(_loc1_);
         Ga.minimal("unknown","user",StringUtil.getBasename(File.userDirectory.url),_loc2_);
         var _loc3_:int = 0;
         while(_loc3_ < invokeArguments.length)
         {
            _loc4_ = String(invokeArguments[_loc3_]);
            Ga.minimal("unknown","invoke_arg",_loc4_,_loc2_);
            _loc3_++;
         }
         Ga.minimal("unknown","os",Capabilities.os,_loc2_);
         Ga.minimal("unknown","mac_address",_loc1_,_loc2_);
         Ga.minimal("unknown","build",appInfo.buildVersion,_loc2_);
         Ga.minimal("unknown","appdir",appInfo.applicationDirectoryUrl_native,_loc2_);
      }
      
      public function closingHandler(param1:Event) : void
      {
         logInfo("GameEntryDesktopAir.closingHandler");
      }
      
      public function exitingHandler(param1:Event) : void
      {
         logInfo("GameMainAir.exitingHandler autoExit=" + NativeApplication.nativeApplication.autoExit + ", event=" + param1);
         AppInfo.terminating = true;
         handleExit();
         param1.preventDefault();
         this.exitTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.exitTimerCompleteHandler);
         this.exitTimer.start();
      }
      
      private function exitTimerCompleteHandler(param1:TimerEvent) : void
      {
         logInfo("exitTimerCompleteHandler");
         NativeApplication.nativeApplication.exit(appInfo.exitCode);
      }
      
      override protected function processArgument(param1:String) : Boolean
      {
         if(this.entryHelper)
         {
            if(this.entryHelper.processArgument(param1))
            {
               return true;
            }
         }
         return super.processArgument(param1);
      }
   }
}
