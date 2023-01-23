package com.stoicstudio.platform.tencent
{
   import air.tencent.ane.TencentAne;
   import engine.core.locale.LocaleId;
   import engine.core.util.AppInfo;
   import engine.core.util.CloudSave;
   import engine.core.util.CloudSaveDefault;
   import engine.saga.NullSagaDlc;
   import engine.saga.Saga;
   import engine.saga.SagaAchievements;
   import engine.saga.SagaDlcEntry;
   import engine.saga.SagaLeaderboards;
   import engine.saga.save.GameSaveSynchronizer;
   import game.cfg.GameConfig;
   import game.entry.GameEntryDesktop;
   import game.entry.IEntryHelperDesktop;
   import game.gui.page.SagaOptionsPage;
   import game.session.states.PreAuthState;
   import game.session.states.StartState;
   import game.view.GameWrapper;
   
   public class TencentEntryHelper implements IEntryHelperDesktop
   {
       
      
      public var enableTgp:Boolean = true;
      
      private var tencent:TencentAne;
      
      private var _appInfo:AppInfo;
      
      private var _entry:GameEntryDesktop;
      
      private var _userId:String = null;
      
      public function TencentEntryHelper(param1:AppInfo)
      {
         super();
         param1.logger.i("TENCENT","initializing...");
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
         return this._userId;
      }
      
      public function init(param1:GameEntryDesktop) : void
      {
         this._entry = param1;
         GameSaveSynchronizer.MULTIPLE_PULL = false;
         Saga.ONLY_UNLOCK_PROGRESS_ACHIEVMENT_LOCALLY = true;
      }
      
      public function setup() : void
      {
         var _loc2_:String = null;
         this.tencent = new TencentAne(this._entry.appInfo.logger);
         if(!this.tencent.create())
         {
            throw new ArgumentError("Failed to create Tencent");
         }
         var _loc1_:Boolean = this.tencent.TencentAPI_Init(this._appInfo.ini["tgp_gameid"]);
         if(_loc1_)
         {
            this._appInfo.logger.i("TENCENT","Tencent api init ok");
            SagaAchievements.impl = new TgpSagaAchievements(this.tencent);
            SagaLeaderboards.impl = new TgpSagaLeaderboards(this.tencent);
            PreAuthState.authenticator = new TgpAuthentication(this.tencent);
            StartState.authenticator = PreAuthState.authenticator;
            SagaDlcEntry.dlcCheck = new NullSagaDlc();
            SagaOptionsPage.ENABLE_SHARE_BAR = false;
            this._userId = this.tencent.TencentAPI_GetRailID();
            _loc2_ = this.tencent.TencentAPI_GetPlatformLanguageCode();
            if(_loc2_)
            {
               this.logInfo("TENCENT language is [" + _loc2_ + "]");
               this._appInfo.logger.i("TENCENT","TENCENT language is [" + _loc2_ + "]");
               if(!this._entry.locale_id)
               {
                  this._entry.locale_id = new LocaleId(_loc2_);
               }
            }
            return;
         }
         this.logError("Cannot continue without RailAPI");
         this._entry.appInfo.exitGame("Rail init shutdown");
      }
      
      public function initWrapper(param1:GameWrapper) : void
      {
         param1.config.addUpdateFunction(this.updateTgp);
      }
      
      public function startWrapper(param1:GameWrapper, param2:int) : void
      {
         param1.config.addUpdateFunction(this.updateTgp);
         param1.config.addShutdownFunction(this.tencent.TencentAPI_Shutdown);
      }
      
      public function getAnalyticsInfo() : Vector.<String>
      {
         var _loc1_:Vector.<String> = new Vector.<String>();
         var _loc2_:String = "/tgp";
         var _loc3_:String = !!this._userId ? this._userId : "unknown_user";
         _loc1_.push(_loc2_,_loc3_);
         this._appInfo.logger.i("TENCENT",_loc2_ + "+" + _loc3_);
         return _loc1_;
      }
      
      public function processArgument(param1:String) : Boolean
      {
         if(this._entry.checkArg(param1,"tencent"))
         {
            this.enableTgp = this._entry._argBool;
         }
         return true;
      }
      
      final public function initCloudSave(param1:GameConfig, param2:AppInfo) : CloudSave
      {
         var _loc3_:CloudSave = null;
         if(Boolean(this.tencent) && this.enableTgp)
         {
            param2.logger.info("Enabling tgp cloud saves.");
            _loc3_ = new CloudSaveTgp(this.tencent,param2.logger);
         }
         else
         {
            param2.logger.debug("Saving using fallback: no cloud saves :(");
            _loc3_ = new CloudSaveDefault("none",null);
         }
         return _loc3_;
      }
      
      final private function updateTgp(param1:int) : void
      {
         this.tencent.TencentAPI_FireEvents();
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
