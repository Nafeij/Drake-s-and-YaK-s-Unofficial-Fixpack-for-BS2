package com.stoicstudio.platform.gog
{
   import air.gog.ane.GogAne;
   import engine.core.locale.LocaleId;
   import engine.core.util.AppInfo;
   import engine.core.util.CloudSave;
   import engine.core.util.CloudSaveDefault;
   import engine.saga.SagaAchievements;
   import engine.saga.SagaDlcEntry;
   import engine.saga.SagaLeaderboards;
   import engine.saga.SagaPresenceManager;
   import engine.saga.save.GameSaveSynchronizer;
   import flash.utils.getTimer;
   import game.cfg.GameConfig;
   import game.entry.GameEntryDesktop;
   import game.entry.IEntryHelperDesktop;
   import game.session.states.PreAuthState;
   import game.session.states.StartState;
   import game.view.GameWrapper;
   
   public class GogEntryHelper implements IEntryHelperDesktop
   {
       
      
      public var enableGog:Boolean = true;
      
      private var galaxy:GogAne;
      
      private var _appInfo:AppInfo;
      
      private var _entry:GameEntryDesktop;
      
      public function GogEntryHelper(param1:AppInfo)
      {
         super();
         param1.logger.i("GOG","initializing...");
         this._appInfo = param1;
      }
      
      public function get entry() : GameEntryDesktop
      {
         return this._entry;
      }
      
      public function get betaBranch() : String
      {
         return null;
      }
      
      public function get userId() : String
      {
         return this.galaxy.GalaxyAPI_GetUserId();
      }
      
      public function init(param1:GameEntryDesktop) : void
      {
         this._entry = param1;
         GameSaveSynchronizer.MULTIPLE_PULL = false;
      }
      
      public function setup() : void
      {
         var _loc2_:uint = 0;
         var _loc3_:String = null;
         this._appInfo.logger.i("GOG","Setting up gog");
         this.galaxy = new GogAne(this._entry.appInfo.logger);
         if(!this.galaxy.create())
         {
            throw new ArgumentError("Failed to create Gog");
         }
         var _loc1_:Boolean = this.galaxy.GalaxyAPI_Init(this._appInfo.ini["gog_id"],this._appInfo.ini["gog_secret"]);
         if(_loc1_)
         {
            this._appInfo.logger.i("GOG","Gog api init ok");
            _loc2_ = uint(3000 + getTimer());
            while(!this.galaxy.GalaxyAPI_IsLoggedIn() && getTimer() < _loc2_)
            {
            }
            this._appInfo.logger.i("GOG",_loc2_ > 0 ? "sign in successful" : "sign in timeout reached");
            SagaAchievements.impl = new GogSagaAchievements(this.galaxy);
            SagaDlcEntry.dlcCheck = new GogSagaDlc(this.galaxy);
            SagaLeaderboards.impl = new GogSagaLeaderboards(this.galaxy);
            PreAuthState.authenticator = new GogAuthentication(this.galaxy);
            StartState.authenticator = PreAuthState.authenticator;
            SagaPresenceManager.impl = new GogSagaPresenceManager(this.galaxy,this.entry.appInfo);
            _loc3_ = this.galaxy.GalaxyAPI_GetPlatformLanguageCode();
            if(_loc3_)
            {
               this.logInfo("GOG language is [" + _loc3_ + "]");
               this._appInfo.logger.i("GOG","GOG language is [" + _loc3_ + "]");
               if(!this._entry.locale_id)
               {
                  this._entry.locale_id = new LocaleId(_loc3_);
               }
            }
            return;
         }
         this.logError("Cannot continue without GOGAPI");
         this._entry.appInfo.exitGame("Gog forcing shutdown");
      }
      
      public function initWrapper(param1:GameWrapper) : void
      {
         param1.config.addUpdateFunction(this.updateGog);
      }
      
      public function startWrapper(param1:GameWrapper, param2:int) : void
      {
         param1.config.addUpdateFunction(this.updateGog);
         param1.config.addUpdateFunction(SagaPresenceManager.update);
         param1.config.addShutdownFunction(this.galaxy.GalaxyAPI_Shutdown);
      }
      
      public function getAnalyticsInfo() : Vector.<String>
      {
         var _loc1_:Vector.<String> = new Vector.<String>();
         var _loc2_:String = "/gog";
         var _loc3_:String = this.userId;
         _loc3_ = _loc3_ != "0" ? _loc3_ : "unknown_user";
         _loc1_.push(_loc2_,_loc3_);
         this._appInfo.logger.i("GOG",_loc2_ + "+" + _loc3_);
         return _loc1_;
      }
      
      public function processArgument(param1:String) : Boolean
      {
         if(this._entry.checkArg(param1,"gog"))
         {
            this.enableGog = this._entry._argBool;
            return true;
         }
         return false;
      }
      
      final public function initCloudSave(param1:GameConfig, param2:AppInfo) : CloudSave
      {
         var _loc3_:CloudSave = null;
         if(Boolean(this.galaxy) && this.enableGog)
         {
            param2.logger.info("Enabling gog cloud saves.");
            _loc3_ = new GogCloudSave(this.galaxy);
            (SagaPresenceManager.impl as GogSagaPresenceManager).config = param1;
         }
         else
         {
            param2.logger.debug("Saving using fallback: no cloud saves :(");
            _loc3_ = new CloudSaveDefault("none",null);
         }
         return _loc3_;
      }
      
      final private function updateGog(param1:int) : void
      {
         this.galaxy.GalaxyAPI_FireEvents();
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
