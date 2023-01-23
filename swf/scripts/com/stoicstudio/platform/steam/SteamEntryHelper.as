package com.stoicstudio.platform.steam
{
   import air.steamworks.ane.SteamworksAne;
   import air.steamworks.ane.SteamworksCallbackEvent;
   import air.steamworks.ane.SteamworksEvent;
   import com.stoicstudio.platform.Platform;
   import com.stoicstudio.platform.PlatformShare;
   import com.stoicstudio.platform.PlatformSoundtrack;
   import engine.core.analytic.GaConfig;
   import engine.core.analytic.GaVerbosity;
   import engine.core.cmd.CmdExec;
   import engine.core.locale.LocaleId;
   import engine.core.util.AppInfo;
   import engine.core.util.CloudSave;
   import engine.core.util.CloudSaveDefault;
   import engine.saga.SagaAchievements;
   import engine.saga.SagaDlcEntry;
   import engine.saga.SagaLeaderboards;
   import engine.saga.save.GameSaveSynchronizer;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import game.cfg.GameConfig;
   import game.entry.GameEntryDesktop;
   import game.entry.GenericEntryHelper;
   import game.entry.IEntryHelperDesktop;
   import game.session.actions.SessionSteamOverlayTxn;
   import game.session.states.PreAuthState;
   import game.session.states.StartState;
   import game.view.GamePageManagerAdapterMarketplace;
   import game.view.GameWrapper;
   
   public final class SteamEntryHelper implements IEntryHelperDesktop
   {
       
      
      private const NUM_STEAM_RETRIES:int = 10;
      
      private var steam_ids:Array;
      
      public var steamworks:SteamworksAne;
      
      public var enableSteam:Boolean = true;
      
      private var _entry:GameEntryDesktop;
      
      private var beta:String;
      
      private var _userId:String;
      
      private var _appInfo:AppInfo;
      
      private var allowUserBypass:Boolean;
      
      private var steam_data_suite:String;
      
      private var steamPlatformRating:SteamPlatformRating;
      
      private var steamPlatformSoundtrack:SteamPlatformSoundtrack;
      
      private var steamPlatformBuyTbs2:SteamPlatformBuyApp;
      
      private var steamPlatformShare:SteamPlatformShare;
      
      private var _zeno:Boolean;
      
      public function SteamEntryHelper(param1:AppInfo)
      {
         this.steam_ids = [];
         super();
         this.allowUserBypass = param1.isDebugger;
      }
      
      public function get entry() : GameEntryDesktop
      {
         return this._entry;
      }
      
      public function get betaBranch() : String
      {
         return this.beta;
      }
      
      public function get userId() : String
      {
         return this._userId;
      }
      
      public function init(param1:GameEntryDesktop) : void
      {
         this._entry = param1;
         GameSaveSynchronizer.MULTIPLE_PULL = false;
      }
      
      public function setup() : void
      {
         var appid:int = 0;
         var ai:AppInfo = null;
         var sku:String = null;
         var soundtrack_appid:int = 0;
         var steam_tbs2_appid:int = 0;
         var created:Boolean = false;
         var i:int = 0;
         var restarted:Boolean = false;
         var lang:String = null;
         this._entry.logInfo("SteamEntryHelper.setup");
         if(this.enableSteam)
         {
            try
            {
               appid = 0;
               ai = this._entry.appInfo;
               appid = ai.getIni("steam_appid");
               sku = ai.getIni("sku","saga3");
               soundtrack_appid = sku == "saga3" ? ai.getIni("steam_soundtrack_bs3_appid") : ai.getIni("steam_soundtrack_bs2_appid");
               steam_tbs2_appid = ai.getIni("steam_tbs2_appid");
               if(appid)
               {
                  this.steamworks = new SteamworksAne(this._entry.appInfo.logger);
                  created = this.steamworks.create();
                  if(!created)
                  {
                     throw new ArgumentError("Failed to create steamworks");
                  }
                  this.steamPlatformRating = new SteamPlatformRating(this.steamworks);
                  this.steamPlatformSoundtrack = new SteamPlatformSoundtrack(this.steamworks,soundtrack_appid,appid);
                  PlatformSoundtrack._showSoundtrackFunc = this.steamPlatformSoundtrack.showSoundtrack;
                  this.steamPlatformShare = new SteamPlatformShare(this.steamworks,this._entry.appInfo.logger);
                  PlatformShare._showAppShareFunc = this.steamPlatformShare.showAppShare;
                  if(Boolean(steam_tbs2_appid) && appid != steam_tbs2_appid)
                  {
                     this.steamPlatformBuyTbs2 = new SteamPlatformBuyApp(this.steamworks,steam_tbs2_appid);
                     Platform._showBuyTbs2Func = this.steamPlatformBuyTbs2.showApp;
                  }
                  SagaAchievements.impl = new SteamSagaAchievements(this.steamworks);
                  SagaDlcEntry.dlcCheck = new SteamSagaDlc(this.steamworks);
                  SagaLeaderboards.impl = new SteamSagaLeaderboards(this.steamworks,this._entry.wrappers[0].logger);
                  IapManager.steam = this.steamworks;
                  GamePageManagerAdapterMarketplace.marketCheck = this.marketplaceOverlayCheck;
                  GaConfig.verbosity = GaVerbosity.VERBOSE;
                  StartState.authenticator = new SteamAuthentication(this.steamworks);
                  PreAuthState.authenticator = StartState.authenticator;
                  this.steamworks.addEventListener(SteamworksEvent.SHUTDOWN,this.steamworksShutdownHandler);
                  this.steamworks.addEventListener(SteamworksCallbackEvent.TYPE,this.steamworksCallbackHandler);
                  i = 0;
                  while(i < this.NUM_STEAM_RETRIES)
                  {
                     if(this.steamworks.SteamAPI_Init())
                     {
                        this.logDebug("STEAM Init OK attempt " + i);
                        break;
                     }
                     i++;
                  }
                  this.beta = this.steamworks.SteamApps_GetCurrentBetaName();
                  this._entry.logInfo("initSteam found steam_appid=[" + appid + "] on beta [" + this.beta + "]");
                  if(!this._zeno || this.beta != "development" && this.beta != "tip")
                  {
                     restarted = this.steamworks.SteamAPI_RestartAppIfNecessary(appid);
                     if(restarted)
                     {
                        this._entry.logInfo("STEAM requires that we restart...");
                        this._entry.appInfo.exitGame("Steam restart required");
                        return;
                     }
                  }
                  else
                  {
                     this.logInfo("STEAM skip restart due to zeno");
                  }
                  if(!this.steamworks.initialized)
                  {
                     this.logInfo("STEAM Init FAIL");
                  }
                  else
                  {
                     lang = this.steamworks.SteamApps_GetCurrentGameLanguage();
                     if(lang)
                     {
                        this.logInfo("STEAM language is [" + lang + "]");
                        if(!this._entry.locale_id)
                        {
                           this._entry.locale_id = new LocaleId(lang);
                        }
                     }
                     this.beta = this.steamworks.SteamApps_GetCurrentBetaName();
                     this._userId = this.steamworks.SteamUser_GetSteamID();
                     this.logInfo("STEAM beta is [" + this.beta + "] for SteamId [" + this._userId + "]");
                  }
               }
            }
            catch(error:Error)
            {
               logError("STEAM failed: " + error);
               steamworks = null;
            }
         }
         if(!this.steamworks)
         {
            if(this.enableSteam)
            {
               this.logError("Cannot continue without Steamworks");
               this._entry.appInfo.exitGame("Steam init shutdown");
               return;
            }
            this.logInfo("Enabling null steamworks");
            this.enableSteam = false;
            GenericEntryHelper.performGenericPlatformSetup(this._entry.appInfo);
         }
      }
      
      public function initWrapper(param1:GameWrapper) : void
      {
         if(this.steamworks)
         {
            param1.config.addUpdateFunction(this.updateSteam);
         }
      }
      
      public function startWrapper(param1:GameWrapper, param2:int) : void
      {
         if(this.steam_ids.length > param2)
         {
            param1.config.options.overrideSteamId = this.steam_ids[param2];
         }
         if(this.steamworks)
         {
            param1.config.addUpdateFunction(this.updateSteam);
            param1.config.addFinishReadyFunction(this.steamFinishReady);
            param1.config.addShutdownFunction(this.steamworks.SteamAPI_Shutdown);
            param1.config.shell.add("steam_check_overlay",this.shellFuncSteamCheckOverlay);
            param1.config.shell.add("steam_activate_overlay",this.shellFuncSteamActivateOverlay);
            param1.config.shell.add("steam_user_activate_overlay",this.shellFuncSteamUserActivateOverlay);
            param1.config.shell.add("steam_web_activate_overlay",this.shellFuncSteamWebActivateOverlay);
            param1.config.shell.add("steam_store_activate_overlay",this.shellFuncSteamStoreActivateOverlay);
         }
      }
      
      public function getAnalyticsInfo() : Vector.<String>
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc1_:Vector.<String> = null;
         if(this.enableSteam && this.steamworks && this.steamworks.enabled)
         {
            _loc1_ = new Vector.<String>();
            _loc2_ = "/steam";
            if(this.beta)
            {
               this.beta = this.beta.toLowerCase();
               _loc2_ += "/" + this.beta;
            }
            _loc3_ = this.steamworks.SteamUser_GetSteamID();
            _loc3_ = !!_loc3_ ? _loc3_ : "unknown_user";
            _loc1_.push(_loc2_,_loc3_);
         }
         return _loc1_;
      }
      
      public function processArgument(param1:String) : Boolean
      {
         if(this._entry.checkArg(param1,"steam"))
         {
            if(this.allowUserBypass)
            {
               this.enableSteam = this._entry._argBool;
            }
         }
         else if(this._entry.checkArg(param1,"steam_id"))
         {
            if(this.allowUserBypass)
            {
               this.steam_ids = this._entry._argValue.split(",");
            }
         }
         else
         {
            if(!this._entry.checkArg(param1,"zeno"))
            {
               return false;
            }
            this._zeno = this._entry._argBool;
         }
         return true;
      }
      
      final public function initCloudSave(param1:GameConfig, param2:AppInfo) : CloudSave
      {
         var _loc3_:CloudSave = null;
         if(Boolean(this.steamworks) && this.enableSteam)
         {
            param2.logger.info("Enabling Steam cloud saves.");
            _loc3_ = new CloudSaveSteam(this.steamworks,param2.logger);
         }
         else
         {
            param2.logger.debug("Saving using fallback: no cloud saves.");
            _loc3_ = new CloudSaveDefault("none",null);
         }
         return _loc3_;
      }
      
      final private function updateSteam(param1:int) : void
      {
         if(this.steamworks)
         {
            this.steamworks.SteamAPI_RunCallbacks();
         }
      }
      
      private function marketplaceOverlayCheck() : Boolean
      {
         return this.steamworks == null || !this.steamworks.SteamUtils_IsOverlayEnabled();
      }
      
      private function steamworksShutdownHandler(param1:SteamworksEvent) : void
      {
         this.logInfo("STEAM requires that we shutdown...");
         this._entry.appInfo.exitGame("Steam shutdown");
      }
      
      private function steamworksCallbackHandler(param1:SteamworksCallbackEvent) : void
      {
         if(param1.callback.callback_type == "GameOverlayActivated_t")
         {
            this._entry.gamePaused = param1.callback.active;
         }
      }
      
      private function steamFinishReady() : void
      {
         var _loc1_:Timer = new Timer(10000,1);
         _loc1_.addEventListener(TimerEvent.TIMER_COMPLETE,this.steamTimerReadyCompleteHandler);
         _loc1_.start();
      }
      
      private function steamTimerReadyCompleteHandler(param1:TimerEvent) : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:SessionSteamOverlayTxn = null;
         var _loc2_:GameWrapper = this._entry.wrappers[0];
         if(_loc2_.config && _loc2_.config.fsm.communicator && _loc2_.config.fsm.communicator.connected)
         {
            _loc3_ = this.steamworks.SteamUtils_IsOverlayEnabled();
            _loc2_.config.logger.info("GameConfig SteamUtils_IsOverlayEnabled = " + _loc3_);
            _loc4_ = new SessionSteamOverlayTxn(_loc2_.config.fsm.credentials,null,_loc2_.config.logger,_loc3_);
            _loc4_.send(_loc2_.config.fsm.communicator);
         }
      }
      
      private function shellFuncSteamCheckOverlay(param1:CmdExec) : void
      {
         var _loc2_:Array = null;
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = false;
         if(this.steamworks)
         {
            _loc2_ = param1.param;
            _loc3_ = this.steamworks.SteamUtils_IsOverlayEnabled();
            _loc4_ = this.steamworks.SteamUtils_BOverlayNeedsPresent();
            this._entry.wrappers[0].logger.info("Overlay enabled=" + _loc3_ + ", needsPresent=" + _loc4_);
         }
      }
      
      private function shellFuncSteamActivateOverlay(param1:CmdExec) : void
      {
         var _loc2_:Array = null;
         var _loc3_:String = null;
         if(this.steamworks)
         {
            _loc2_ = param1.param;
            _loc3_ = _loc2_[1];
            this.steamworks.SteamFriends_ActivateGameOverlay(_loc3_);
         }
      }
      
      private function shellFuncSteamUserActivateOverlay(param1:CmdExec) : void
      {
         var _loc2_:Array = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         if(this.steamworks)
         {
            _loc2_ = param1.param;
            _loc3_ = _loc2_[1];
            _loc4_ = _loc2_[2];
            this.steamworks.SteamFriends_ActivateGameOverlayToUser(_loc3_,_loc4_);
         }
      }
      
      private function shellFuncSteamWebActivateOverlay(param1:CmdExec) : void
      {
         var _loc2_:Array = null;
         var _loc3_:String = null;
         if(this.steamworks)
         {
            _loc2_ = param1.param;
            _loc3_ = _loc2_[1];
            this.steamworks.SteamFriends_ActivateGameOverlayToWebPage(_loc3_);
         }
      }
      
      private function shellFuncSteamStoreActivateOverlay(param1:CmdExec) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(this.steamworks)
         {
            _loc2_ = param1.param;
            _loc3_ = int(_loc2_[1]);
            _loc4_ = int(_loc2_[2]);
            this.steamworks.SteamFriends_ActivateGameOverlayToStore(_loc3_,_loc4_);
         }
      }
      
      final private function logDebug(param1:String) : void
      {
         if(this._entry.appInfo.logger.isDebugEnabled)
         {
            this._entry.logDebug(param1);
         }
      }
      
      final private function logInfo(param1:String) : void
      {
         this._entry.logInfo(param1);
      }
      
      final private function logError(param1:String) : void
      {
         this._entry.logError(param1);
      }
   }
}
