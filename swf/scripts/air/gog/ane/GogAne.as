package air.gog.ane
{
   import flash.events.EventDispatcher;
   import flash.events.StatusEvent;
   import flash.external.ExtensionContext;
   import flash.utils.ByteArray;
   
   public class GogAne extends EventDispatcher
   {
      
      public static const CONTEXT_ID:String = "air.gog.ane.GogAneContext";
       
      
      public var logger:Object;
      
      private var context:ExtensionContext;
      
      private var _initialized:Boolean;
      
      private var _userStatsReady:Boolean;
      
      public function GogAne(param1:Object)
      {
         super();
         this.logger = param1;
         this._initialized = false;
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
         this.logger.i("GOG","Creating the extension context");
         try
         {
            this.context = ExtensionContext.createExtensionContext(CONTEXT_ID,"");
         }
         catch(error:Error)
         {
            logger.error("Create gogContext failed");
            return false;
         }
         this.context.addEventListener(StatusEvent.STATUS,this.onStatusEvent);
         return true;
      }
      
      public function GalaxyAPI_Init(param1:String, param2:String) : Boolean
      {
         this.logger.i("GOG","Initializing GOG");
         var _loc3_:Object = null;
         _loc3_ = this.context.call("GogAne_GalaxyAPI_Init",param1,param2);
         this._initialized = _loc3_;
         if(!_loc3_)
         {
            this.logger.error("Could not initialize gog");
         }
         return _loc3_ as Boolean;
      }
      
      public function GalaxyAPI_Shutdown() : void
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("GalaxyAPI_Shutdown");
         }
         this.context.call("GogAne_GalaxyAPI_Shutdown");
      }
      
      public function GalaxyAPI_FireEvents() : void
      {
         this.context.call("GogAne_GalaxyAPI_ProcessData");
      }
      
      public function GalaxyAPI_IsLoggedIn() : Boolean
      {
         var _loc1_:Object = this.context.call("GogAne_GalaxyApi_IsLoggedIn");
         return _loc1_ as Boolean;
      }
      
      public function GalaxyAPI_GetUserId() : String
      {
         var _loc1_:Object = this.context.call("GogAne_GalaxyAPI_GetUserId");
         return _loc1_ as String;
      }
      
      public function GalaxyAPI_GetPlatformLanguageCode() : String
      {
         var _loc1_:Object = this.context.call("GogAne_GalaxyAPI_GetPlatformLanguageCode");
         return _loc1_ as String;
      }
      
      public function GalaxyAPI_GetPersonaName() : String
      {
         var _loc1_:Object = this.context.call("GogAne_GalaxyAPI_GetPersonaName");
         return _loc1_ as String;
      }
      
      public function GalaxyAPI_SaveGame(param1:String, param2:ByteArray) : Boolean
      {
         var _loc3_:Object = this.context.call("GogAne_GalaxyAPI_FileWrite",param1,param2);
         return _loc3_ as Boolean;
      }
      
      public function GalaxyAPI_DeleteSavedGame(param1:String) : Boolean
      {
         var _loc2_:Object = this.context.call("GogAne_GalaxyAPI_FileDelete",param1);
         return _loc2_ as Boolean;
      }
      
      public function GalaxyAPI_GetFileSize(param1:String) : int
      {
         var _loc2_:Object = this.context.call("GogAne_GalaxyAPI_GetFileSize",param1);
         return _loc2_ as int;
      }
      
      public function GalaxyAPI_FileRead(param1:String, param2:ByteArray, param3:int) : Boolean
      {
         var _loc4_:Object = this.context.call("GogAne_GalaxyAPI_FileRead",param1,param2,param3);
         return _loc4_ as Boolean;
      }
      
      public function GalaxyAPI_GetFileCount() : int
      {
         var _loc1_:Object = this.context.call("GogAne_GalaxyAPI_GetFileCount");
         return _loc1_ as int;
      }
      
      public function GalaxyAPI_GetFileName(param1:int) : String
      {
         var _loc2_:Object = this.context.call("GogAne_GalaxyAPI_GetFileNameByIndex",param1);
         return _loc2_ as String;
      }
      
      public function GalaxyAPI_AsyncRequestAchievement() : Boolean
      {
         var _loc1_:Object = this.context.call("GogAne_GalaxyAPI_RequestAchievements");
         return _loc1_ as Boolean;
      }
      
      public function GalaxyAPI_GetAchievement(param1:String) : Boolean
      {
         if(!this._userStatsReady)
         {
            this.logger.i("GOG","User stats are not ready for GOG");
            return false;
         }
         var _loc2_:Object = this.context.call("GogAne_GalaxyAPI_GetAchievement",param1);
         return _loc2_ as Boolean;
      }
      
      public function GalaxyAPI_SetAchievement(param1:String) : Boolean
      {
         if(!this._userStatsReady)
         {
            this.logger.i("GOG","User stats are not ready for GOG");
            return false;
         }
         var _loc2_:Object = this.context.call("GogAne_GalaxyAPI_SetAchivement",param1);
         return _loc2_ as Boolean;
      }
      
      public function GalaxyAPI_StoreAchievements() : Boolean
      {
         if(!this._userStatsReady)
         {
            this.logger.i("GOG","User stats are not ready for gog");
            return false;
         }
         var _loc1_:Object = this.context.call("GogAne_GalaxyAPI_StoreAchievements");
         return _loc1_ as Boolean;
      }
      
      public function GalaxyAPI_SetStatInt(param1:String, param2:int) : Boolean
      {
         if(!this._userStatsReady)
         {
            this.logger.i("GOG","User stats are not ready for gog");
            return false;
         }
         var _loc3_:Object = this.context.call("GogAne_GalaxyAPI_SetStatInt",param1,param2);
         return _loc3_ as Boolean;
      }
      
      public function GalaxyAPI_ClearAchievement(param1:String) : Boolean
      {
         var _loc2_:Object = this.context.call("GogAne_GalaxyAPI_ClearAchievement",param1);
         return _loc2_ as Boolean;
      }
      
      public function GalaxyAPI_GetStat(param1:String) : Boolean
      {
         if(!this._userStatsReady)
         {
            this.logger.i("GOG","User stats are not ready for gog");
            return false;
         }
         var _loc2_:Object = this.context.call("GogAne_GalaxyAPI_GetStat",param1);
         return _loc2_ as Boolean;
      }
      
      public function GalaxyAPI_IsDLCInstalled(param1:int) : Boolean
      {
         var _loc2_:Object = this.context.call("GogAne_GalaxyAPI_IsDLCInstalled",param1);
         return _loc2_ as Boolean;
      }
      
      public function GalaxyAPI_SetRichPresenceState(param1:String, param2:String) : void
      {
         this.context.call("GogAne_GalaxyAPI_SetRichPresenceState",param1,param2);
      }
      
      public function GalaxyAPI_FetchLeaderboard(param1:String, param2:int) : void
      {
         this.context.call("GogAne_GalaxyAPI_FetchLeaderboard",param1,param2);
      }
      
      public function GalaxyAPI_UploadLeaderboardScore(param1:String, param2:int, param3:Boolean) : Boolean
      {
         var _loc4_:Object = this.context.call("GogAne_GalaxyAPI_UploadLeaderboardScore",param1,param2,param3);
         return _loc4_ as Boolean;
      }
      
      private function onStatusEvent(param1:StatusEvent) : void
      {
         var j:Object = null;
         var status:StatusEvent = param1;
         if(status.level == "callback")
         {
            try
            {
               j = JSON.parse(status.code);
               this.handleCallback(j);
            }
            catch(error:Error)
            {
               logger.error("GogAne.onSTatusEvent FAILED: " + error);
            }
         }
      }
      
      private function handleCallback(param1:Object) : void
      {
         if(param1.callback_type == "UserStatsReceived_t")
         {
            this._userStatsReady = param1.ok;
            dispatchEvent(new GogEvent(GogEvent.USER_STATS));
         }
         else if(param1.callback_type == "LeaderboardDownloaded_t")
         {
            dispatchEvent(new GogEvent(GogEvent.LEADERBOARD,param1));
         }
         else if(param1.callback_type == "LeaderboardScoreUploaded_t")
         {
            dispatchEvent(new GogEvent(GogEvent.LEADERBOARD_SCORE_UPLOADED,param1));
            return;
         }
      }
   }
}
