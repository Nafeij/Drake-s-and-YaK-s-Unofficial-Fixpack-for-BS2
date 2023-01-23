package air.steamworks.ane
{
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   import flash.events.StatusEvent;
   import flash.external.ExtensionContext;
   import flash.filesystem.File;
   import flash.system.Capabilities;
   import flash.utils.ByteArray;
   
   public class SteamworksAne extends EventDispatcher
   {
      
      public static const CONTEXT_ID:String = "air.steamworks.ane.SteamworksAneContext";
      
      private static const steamLanguageConversion:Object = {
         "brazilian":"pt",
         "bulgarian":"bg",
         "czech":"cs",
         "danish":"da",
         "dutch":"nl",
         "english":"en",
         "finnish":"fi",
         "french":"fr",
         "german":"de",
         "hungarian":"hu",
         "italian":"it",
         "japanese":"jp",
         "koreana":"ko",
         "norwegian":"no",
         "polish":"pl",
         "portuguese":"pt",
         "romanian":"ro",
         "russian":"ru",
         "schinese":"zh",
         "spanish":"es",
         "swedish":"sv",
         "tchinese":"zh",
         "thai":"th",
         "turkish":"tr"
      };
       
      
      public var logger:Object;
      
      private var context:ExtensionContext;
      
      private var disposed:Boolean;
      
      private var _initialized:Boolean;
      
      private var _userStatsReady:Boolean;
      
      private var _appid:int;
      
      private var loggedRunCallbacks:Boolean;
      
      public function SteamworksAne(param1:Object)
      {
         super();
         this.logger = param1;
         var _loc2_:String = Capabilities.os;
         var _loc3_:int = _loc2_.indexOf("Windows");
      }
      
      public function get enabled() : Boolean
      {
         return true;
      }
      
      public function get initialized() : Boolean
      {
         return this._initialized;
      }
      
      public function get userStatsReady() : Boolean
      {
         return this._userStatsReady;
      }
      
      public function create() : Boolean
      {
         var dir:File = null;
         try
         {
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("SteamworksAne.create creating extension context " + CONTEXT_ID);
               dir = ExtensionContext.getExtensionDirectory(CONTEXT_ID);
               this.logger.debug("SteamworksAne extension dir " + dir.url);
            }
            this.context = ExtensionContext.createExtensionContext(CONTEXT_ID,"");
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("SteamworksAne.create created extension context " + this.context);
            }
         }
         catch(error:Error)
         {
            logger.error("SteamworksAne initialization failed: " + error.message);
            logger.error("Does the extension id in extension.xml match the id used in createExtensionContext?");
            return false;
         }
         if(!this.context)
         {
            this.logger.error("SteamworksAne initialization generated null context");
            return false;
         }
         this.context.addEventListener(StatusEvent.STATUS,this.onStatusEvent);
         this.logger.debug("SteamworksAne loaded");
         return true;
      }
      
      private function onStatusEvent(param1:StatusEvent) : void
      {
         var j:Object = null;
         var status:StatusEvent = param1;
         if(this.disposed)
         {
            return;
         }
         if(status.level == "error")
         {
            this.logger.error("SteamworksAne.onStatusEvent " + status.level + ": " + status.code);
         }
         else if(status.level == "debug")
         {
            if(!this.logger.isDebugEnabled)
            {
            }
         }
         else if(status.level == "callback")
         {
            this.logger.debug("SteamworksAne.onStatusEvent CALLBACK " + status.code);
            try
            {
               j = JSON.parse(status.code);
               this.handleCallback(j);
            }
            catch(err:Error)
            {
               logger.error("SteamworksAne.onStatusEvent FAILED: " + err);
            }
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("SteamworksAne.onStatusEvent CALLLED-BACK " + status.code);
            }
         }
         else if(status.level == "callback_error")
         {
            this.logger.info("SteamworksAne.onStatusEvent CALLBACK_ERROR " + status.code);
            try
            {
               j = JSON.parse(status.code);
               this.handleCallbackError(j);
            }
            catch(err:Error)
            {
               logger.error("SteamworksAne.onStatusEvent CALLBACK_ERROR FAILED: " + err);
            }
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("SteamworksAne.onStatusEvent CALLBACK_ERROR CALLLED-BACK " + status.code);
            }
         }
         else
         {
            this.logger.debug("SteamworksAne.onStatusEvent " + status.level + ": " + status.code);
         }
      }
      
      private function handleCallbackError(param1:Object) : void
      {
         if(param1.error_type == "LeaderboardFindResult_t")
         {
            if(param1.context == "CLeaderboard::OnFindLeaderboard")
            {
               dispatchEvent(new SteamworksEvent(SteamworksEvent.LEADERBOARD_FETCH_ERROR,param1));
               return;
            }
         }
      }
      
      private function handleCallback(param1:Object) : void
      {
         if(param1.callback_type == "UserStatsReceived_t")
         {
            this._userStatsReady = param1.ok;
            dispatchEvent(new SteamworksEvent(SteamworksEvent.USER_STATS));
         }
         else
         {
            if(param1.callback_type == "SteamShutdown_t")
            {
               dispatchEvent(new SteamworksEvent(SteamworksEvent.SHUTDOWN));
               return;
            }
            if(param1.callback_type == "GetAuthSessionTicketResponse_t")
            {
               dispatchEvent(new SteamworksEvent(SteamworksEvent.AUTH_TICKET));
               return;
            }
            if(param1.callback_type == "LeaderboardDownloaded_t")
            {
               dispatchEvent(new SteamworksEvent(SteamworksEvent.LEADERBOARD,param1));
               return;
            }
            if(param1.callback_type == "LeaderboardScoreUploaded_t")
            {
               dispatchEvent(new SteamworksEvent(SteamworksEvent.LEADERBOARD_SCORE_UPLOADED,param1));
               return;
            }
         }
         this.logger.info("SteamworksAne.handleCallback: " + param1.callback_type);
         dispatchEvent(new SteamworksCallbackEvent(param1));
         this.logger.info("SteamworksAne.handleCallback: DISPATCHED " + param1.callback_type);
      }
      
      public function SteamID_GetAccountId(param1:String) : int
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SteamID_GetAccountId " + param1);
         }
         var _loc2_:Object = this.context.call("SteamworksAne_SteamID_GetAccountId",param1);
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SteamID_GetAccountId RESULT " + _loc2_);
         }
         return _loc2_ as int;
      }
      
      public function get appid() : int
      {
         return this._appid;
      }
      
      public function SteamAPI_RestartAppIfNecessary(param1:int) : Boolean
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SteamAPI_RestartAppIfNecessary CALL " + param1);
         }
         this._appid = param1;
         var _loc2_:Object = this.context.call("SteamworksAne_SteamAPI_RestartAppIfNecessary",param1);
         this.logger.info("SteamAPI_RestartAppIfNecessary RESULT " + param1 + " " + _loc2_);
         return _loc2_;
      }
      
      public function SteamAPI_Init() : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SteamAPI_Init");
         }
         if(this._initialized)
         {
            throw new IllegalOperationError("Already Initialized");
         }
         var _loc1_:Boolean = Boolean(this.context.call("SteamworksAne_SteamAPI_Init"));
         this.logger.info("SteamAPI_Init RESULT " + _loc1_);
         if(_loc1_)
         {
            _loc2_ = this.getVersion();
            _loc3_ = 3;
            if(_loc2_ != _loc3_)
            {
               this.logger.error("Steamworks version expected " + _loc3_ + ", found " + _loc2_);
               this.context = null;
               return false;
            }
            this._initialized = _loc1_;
            if(this._initialized)
            {
               this.SteamUserStats_RequestCurrentStats();
            }
         }
         return _loc1_;
      }
      
      public function SteamAPI_RunCallbacks() : void
      {
         if(!this.loggedRunCallbacks)
         {
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("SteamAPI_RunCallbacks");
            }
            this.loggedRunCallbacks = true;
         }
         this.context.call("SteamworksAne_SteamAPI_RunCallbacks");
      }
      
      public function SteamAPI_Shutdown() : void
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SteamAPI_Shutdown");
         }
         this.context.call("SteamworksAne_SteamAPI_Shutdown");
      }
      
      public function SteamUser_GetSteamID() : String
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SteamUser_GetSteamID");
         }
         var _loc1_:Object = this.context.call("SteamworksAne_SteamUser_GetSteamID");
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SteamUser_GetSteamID RESULT " + _loc1_);
         }
         return _loc1_ as String;
      }
      
      public function SteamUser_GetAuthSessionTicketHandle() : int
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SteamUser_GetAuthSessionTicketHandle");
         }
         return this.context.call("SteamworksAne_SteamUser_GetAuthSessionTicketHandle") as int;
      }
      
      public function SteamUser_GetAuthSessionTicket(param1:int) : String
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SteamUser_GetAuthSessionTicket " + param1);
         }
         return this.context.call("SteamworksAne_SteamUser_GetAuthSessionTicket",param1) as String;
      }
      
      public function SteamUser_CancelAuthTicket(param1:int) : void
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SteamUser_CancelAuthTicket " + param1);
         }
         this.context.call("SteamworksAne_SteamUser_CancelAuthTicket",param1);
      }
      
      public function SteamFriends_GetFriendCount(param1:int) : int
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SteamFriends_GetFriendCount " + param1);
         }
         return this.context.call("SteamworksAne_SteamFriends_GetFriendCount",param1) as int;
      }
      
      public function SteamFriends_GetFriendByIndex(param1:int, param2:int) : String
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SteamFriends_GetFriendByIndex " + param1 + " " + param2);
         }
         return this.context.call("SteamworksAne_SteamFriends_GetFriendByIndex",param1,param2) as String;
      }
      
      public function SteamFriends_GetPersonaName() : String
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SteamFriends_GetPersonaName");
         }
         var _loc1_:Object = this.context.call("SteamworksAne_SteamFriends_GetPersonaName");
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SteamFriends_GetPersonaName RESULT " + _loc1_);
         }
         return _loc1_ as String;
      }
      
      private function getVersion() : int
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("getVersion");
         }
         var _loc1_:Object = this.context.call("SteamworksAne_GetVersion");
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("getVersion RESULT " + _loc1_);
         }
         return _loc1_ as int;
      }
      
      private function convertSteamLanguageToIso639_1(param1:String) : String
      {
         return steamLanguageConversion[param1];
      }
      
      public function SteamApps_GetCurrentGameLanguage() : String
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SteamApps_GetCurrentGameLanguage");
         }
         var _loc1_:Object = this.context.call("SteamworksAne_SteamApps_GetCurrentGameLanguage");
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SteamApps_GetCurrentGameLanguage RESULT " + _loc1_);
         }
         var _loc2_:String = _loc1_ as String;
         return this.convertSteamLanguageToIso639_1(_loc2_);
      }
      
      public function SteamUtils_BOverlayNeedsPresent() : Boolean
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SteamUtils_BOverlayNeedsPresent");
         }
         var _loc1_:Object = this.context.call("SteamworksAne_SteamUtils_BOverlayNeedsPresent");
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SteamUtils_BOverlayNeedsPresent RESULT " + _loc1_);
         }
         return _loc1_ as Boolean;
      }
      
      public function SteamUtils_IsOverlayEnabled() : Boolean
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SteamUtils_IsOverlayEnabled");
         }
         var _loc1_:Object = this.context.call("SteamworksAne_SteamUtils_IsOverlayEnabled");
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SteamUtils_IsOverlayEnabled RESULT " + _loc1_);
         }
         return _loc1_ as Boolean;
      }
      
      public function SteamFriends_ActivateGameOverlay(param1:String) : void
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SteamFriends_ActivateGameOverlay");
         }
         this.context.call("SteamworksAne_SteamFriends_ActivateGameOverlay",param1);
      }
      
      public function SteamFriends_ActivateGameOverlayToUser(param1:String, param2:String) : void
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SteamFriends_ActivateGameOverlayToUser");
         }
         this.context.call("SteamworksAne_SteamFriends_ActivateGameOverlayToUser",param1,param2);
      }
      
      public function SteamFriends_ActivateGameOverlayToWebPage(param1:String) : void
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SteamFriends_ActivateGameOverlayToWebPage");
         }
         this.context.call("SteamworksAne_SteamFriends_ActivateGameOverlayToWebPage",param1);
      }
      
      public function SteamFriends_ActivateGameOverlayToStore(param1:int, param2:int) : void
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SteamFriends_ActivateGameOverlayToStore");
         }
         this.context.call("SteamworksAne_SteamFriends_ActivateGameOverlayToStore",param1,param2);
      }
      
      public function SteamApps_BIsSubscribedApp(param1:int) : Boolean
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SteamApps_BIsSubscribedApp");
         }
         return this.context.call("SteamworksAne_SteamApps_BIsSubscribedApp",param1);
      }
      
      public function SteamApps_BIsDlcInstalled(param1:int) : Boolean
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SteamApps_BIsDlcInstalled");
         }
         return this.context.call("SteamworksAne_SteamApps_BIsDlcInstalled",param1);
      }
      
      public function SteamApps_GetCurrentBetaName() : String
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SteamApps_GetCurrentBetaName");
         }
         var _loc1_:Object = this.context.call("SteamworksAne_SteamApps_GetCurrentBetaName");
         return _loc1_ as String;
      }
      
      public function SteamUserStats_SetAchievement(param1:String) : Boolean
      {
         if(!this._userStatsReady)
         {
            return false;
         }
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SteamUserStats_SetAchievement");
         }
         var _loc2_:Object = this.context.call("SteamworksAne_SteamUserStats_SetAchievement",param1);
         return _loc2_ as Boolean;
      }
      
      public function SteamUserStats_ClearAchievement(param1:String) : Boolean
      {
         if(!this._userStatsReady)
         {
            return false;
         }
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SteamUserStats_ClearAchievement");
         }
         var _loc2_:Object = this.context.call("SteamworksAne_SteamUserStats_ClearAchievement",param1);
         return _loc2_ as Boolean;
      }
      
      public function SteamUserStats_GetAchievement(param1:String) : Boolean
      {
         if(!this._userStatsReady)
         {
            return false;
         }
         if(!this.logger.isDebugEnabled)
         {
         }
         var _loc2_:Object = this.context.call("SteamworksAne_SteamUserStats_GetAchievement",param1);
         return _loc2_ as Boolean;
      }
      
      public function SteamUserStats_RequestCurrentStats() : Boolean
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SteamUserStats_RequestCurrentStats");
         }
         var _loc1_:Object = this.context.call("SteamworksAne_SteamUserStats_RequestCurrentStats");
         return _loc1_ as Boolean;
      }
      
      public function SteamUserStats_StoreStats() : Boolean
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SteamUserStats_StoreStats");
         }
         var _loc1_:Object = this.context.call("SteamworksAne_SteamUserStats_StoreStats");
         return _loc1_ as Boolean;
      }
      
      public function SteamUserStats_GetStatInt(param1:String) : int
      {
         var _loc2_:Object = this.context.call("SteamworksAne_SteamUserStats_GetStatInt",param1);
         return _loc2_ as int;
      }
      
      public function SteamUserStats_SetStatInt(param1:String, param2:int) : Boolean
      {
         var _loc3_:Object = this.context.call("SteamworksAne_SteamUserStats_SetStatInt",param1,param2);
         return _loc3_ as Boolean;
      }
      
      public function SteamUserStats_GetStatFloat(param1:String) : Number
      {
         var _loc2_:Object = this.context.call("SteamworksAne_SteamUserStats_GetStatFloat",param1);
         return _loc2_ as Number;
      }
      
      public function SteamUserStats_SetStatFloat(param1:String, param2:Number) : Boolean
      {
         var _loc3_:Object = this.context.call("SteamworksAne_SteamUserStats_SetStatFloat",param1,param2);
         return _loc3_ as Boolean;
      }
      
      public function SteamRemoteStorage_FileWrite(param1:String, param2:ByteArray) : Boolean
      {
         var _loc3_:Object = this.context.call("SteamworksAne_SteamRemoteStorage_FileWrite",param1,param2);
         return _loc3_ as Boolean;
      }
      
      public function SteamRemoteStorage_FileRead(param1:String, param2:ByteArray, param3:int) : Boolean
      {
         var _loc4_:Object = this.context.call("SteamworksAne_SteamRemoteStorage_FileRead",param1,param2,param3);
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SteamRemoteStorage_FileRead [" + param1 + "]: " + " of size " + param3 + ": " + _loc4_);
         }
         return _loc4_ as Boolean;
      }
      
      public function SteamRemoteStorage_FileForget(param1:String) : Boolean
      {
         var _loc2_:Object = this.context.call("SteamworksAne_SteamRemoteStorage_FileForget",param1);
         return _loc2_ as Boolean;
      }
      
      public function SteamRemoteStorage_FileDelete(param1:String) : Boolean
      {
         var _loc2_:Object = this.context.call("SteamworksAne_SteamRemoteStorage_FileDelete",param1);
         return _loc2_ as Boolean;
      }
      
      public function SteamRemoteStorage_FileExists(param1:String) : Boolean
      {
         var _loc2_:Object = this.context.call("SteamworksAne_SteamRemoteStorage_FileExists",param1);
         return _loc2_ as Boolean;
      }
      
      public function SteamRemoteStorage_FilePersisted(param1:String) : Boolean
      {
         var _loc2_:Object = this.context.call("SteamworksAne_SteamRemoteStorage_FilePersisted",param1);
         return _loc2_ as Boolean;
      }
      
      public function SteamRemoteStorage_GetFileSize(param1:String) : int
      {
         var _loc2_:Object = this.context.call("SteamworksAne_SteamRemoteStorage_GetFileSize",param1);
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SteamRemoteStorage_GetFileSize [" + param1 + "]: " + _loc2_);
         }
         return _loc2_ as int;
      }
      
      public function SteamRemoteStorage_GetFileTimestamp(param1:String) : String
      {
         var _loc2_:Object = this.context.call("SteamworksAne_SteamRemoteStorage_GetFileTimestamp",param1);
         return _loc2_ as String;
      }
      
      public function SteamRemoteStorage_GetFileCount() : int
      {
         var _loc1_:Object = this.context.call("SteamworksAne_SteamRemoteStorage_GetFileCount");
         return _loc1_ as int;
      }
      
      public function SteamRemoteStorage_GetFileName(param1:int) : String
      {
         var _loc2_:Object = this.context.call("SteamworksAne_SteamRemoteStorage_GetFileName",param1);
         return _loc2_ as String;
      }
      
      public function SteamRemoteStorage_IsCloudEnabledForAccount() : Boolean
      {
         var _loc1_:Object = this.context.call("SteamworksAne_SteamRemoteStorage_IsCloudEnabledForAccount");
         return _loc1_ as Boolean;
      }
      
      public function SteamRemoteStorage_IsCloudEnabledForApp() : Boolean
      {
         var _loc1_:Object = this.context.call("SteamworksAne_SteamRemoteStorage_IsCloudEnabledForApp");
         return _loc1_ as Boolean;
      }
      
      public function SteamRemoteStorage_SetCloudEnabledForApp(param1:Boolean) : void
      {
         this.context.call("SteamworksAne_SteamRemoteStorage_SetCloudEnabledForApp",param1);
      }
      
      public function FetchLeaderboardSimpleData(param1:String, param2:int) : void
      {
         this.context.call("SteamworksAne_FetchLeaderboardSimpleData",param1,param2);
      }
      
      public function SteamUserStats_UploadLeaderboardScore(param1:String, param2:int, param3:Boolean) : void
      {
         this.context.call("SteamworksAne_SteamUserStats_UploadLeaderboardScore",param1,param2,param3);
      }
   }
}
