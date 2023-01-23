package air.tencent.ane
{
   import flash.events.EventDispatcher;
   import flash.events.StatusEvent;
   import flash.external.ExtensionContext;
   import flash.utils.ByteArray;
   
   public class TencentAne extends EventDispatcher
   {
      
      public static const CONTEXT_ID:String = "air.tencent.ane.TencentAneContext";
       
      
      public var logger:Object;
      
      private var context:ExtensionContext;
      
      private var _initialized:Boolean;
      
      private var _userStatsReady:Boolean;
      
      public function TencentAne(param1:Object)
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
         try
         {
            this.context = ExtensionContext.createExtensionContext(CONTEXT_ID,"");
         }
         catch(error:Error)
         {
            logger.error("Create tgpContext failed");
            return false;
         }
         this.context.addEventListener(StatusEvent.STATUS,this.onStatusEvent);
         return true;
      }
      
      private function onStatusEvent(param1:StatusEvent) : void
      {
         var ticket:String = null;
         var j:Object = null;
         var status:StatusEvent = param1;
         if(status.level == "railAuthTicket")
         {
            ticket = status.code;
         }
         else if(status.level == "callback")
         {
            try
            {
               j = JSON.parse(status.code);
               this.handleCallback(j);
            }
            catch(error:Error)
            {
               logger.error("TencentAne.onSTatusEvent FAILED: " + error);
            }
         }
      }
      
      public function TencentAPI_Init(param1:int) : Boolean
      {
         var _loc2_:Object = null;
         _loc2_ = this.context.call("TencentAne_RailAPI_Init",param1);
         this._initialized = _loc2_;
         if(!_loc2_)
         {
            this.logger.error("Could not initialize tgp");
         }
         return _loc2_ as Boolean;
      }
      
      public function TencentAPI_Shutdown() : void
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("TencentAPI_Shutdown");
         }
         this.context.call("TencentAne_RailAPI_Shutdown");
      }
      
      public function TencentAPI_FireEvents() : void
      {
         this.context.call("TencentAne_RailAPI_FireEvents");
      }
      
      public function TencentAPI_GetRailID() : String
      {
         var _loc1_:Object = this.context.call("TencentAne_RailAPI_GetRailID");
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("TGPUser_GetRailID: " + _loc1_);
         }
         return _loc1_ as String;
      }
      
      public function TencentAPI_GetRailPlayerName() : String
      {
         var _loc1_:Object = this.context.call("TencentAne_RailAPI_GetRailPlayerName");
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("TGPUser_GetRailName: " + _loc1_);
         }
         return _loc1_ as String;
      }
      
      public function TencentAPI_GetPlatformLanguageCode() : String
      {
         var _loc1_:Object = this.context.call("TencentAne_RailAPI_GetGameLanguageCode");
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("TGP_Lanuage: " + _loc1_);
         }
         return _loc1_ as String;
      }
      
      public function TencentAPI_GetAccountID(param1:String) : int
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("TencentAPI_GetAccountID " + param1);
         }
         var _loc2_:Object = this.context.call("TencentAne_RailAPI_GetAccountID",param1);
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("TGP Account ID: " + _loc2_);
         }
         return _loc2_ as int;
      }
      
      public function TencentAPI_RequestSessionTicket() : String
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("TencentAPI_RequestSessionTicket()");
         }
         return this.context.call("TencentAne_RailAPI_RequestSessionTicket") as String;
      }
      
      public function TencentAPI_SaveGame(param1:String, param2:ByteArray) : Boolean
      {
         var _loc3_:Object = this.context.call("TencentAne_RailAPI_RemoteFileWrite",param1,param2);
         return _loc3_ as Boolean;
      }
      
      public function TencentAPI_GetFileSize(param1:String) : int
      {
         var _loc2_:Object = this.context.call("TencentAne_RailAPI_GetFileSize",param1);
         return _loc2_ as int;
      }
      
      public function TencentAPI_FileRead(param1:String, param2:ByteArray, param3:int) : Boolean
      {
         var _loc4_:Object = this.context.call("TencentAne_RailAPI_ReadFile",param1,param2,param3);
         return _loc4_ as Boolean;
      }
      
      public function TencentAPI_FileDelete(param1:String) : Boolean
      {
         var _loc2_:Object = this.context.call("TencentAne_RailAPI_FileDelete",param1);
         return _loc2_ as Boolean;
      }
      
      public function TencentAPI_GetFileCount() : int
      {
         var _loc1_:Object = this.context.call("TencentAne_RailAPI_GetFileCount");
         return _loc1_ as int;
      }
      
      public function TencentAPI_GetFileName(param1:int) : String
      {
         var _loc2_:Object = this.context.call("TencentAne_RailAPI_GetFileName",param1);
         return _loc2_ as String;
      }
      
      public function TencentAPI_GetAchievement(param1:String) : Boolean
      {
         if(!this._userStatsReady)
         {
            this.logger.i("TENCENT","_userStatsReady is false for tgp");
            return false;
         }
         var _loc2_:Object = this.context.call("TencentAne_RailAPI_GetAchievement",param1);
         return _loc2_ as Boolean;
      }
      
      public function TencentAPI_SetAchievement(param1:String) : Boolean
      {
         if(!this._userStatsReady)
         {
            this.logger.i("TENCENT","_userStatsReady is false for tgp");
            return false;
         }
         var _loc2_:Object = this.context.call("TencentAne_RailAPI_SetAchivement",param1);
         return _loc2_ as Boolean;
      }
      
      public function TencentAPI_SetStatInt(param1:String, param2:int, param3:int) : Boolean
      {
         var _loc4_:Object = this.context.call("TencentAne_RailAPI_SetStatInt",param1,param2,param3);
         return _loc4_ as Boolean;
      }
      
      public function TencentAPI_GetStat(param1:String) : String
      {
         var _loc2_:Object = this.context.call("TencentAne_RailAPI_GetStat",param1);
         return _loc2_ as String;
      }
      
      public function TencentAPI_StoreStats() : Boolean
      {
         if(!this._userStatsReady)
         {
            this.logger.i("TENCENT","_userStatsReady is false for tgp");
            return false;
         }
         var _loc1_:Object = this.context.call("TencentAne_RailAPI_StoreStats");
         return _loc1_ as Boolean;
      }
      
      public function TencentAPI_AsyncRequestAchievement() : Boolean
      {
         var _loc1_:Object = this.context.call("TencentAne_RailAPI_AsyncRequestAchievement");
         return _loc1_ as Boolean;
      }
      
      public function TencentAPI_GetAllAchievementNames() : Boolean
      {
         var _loc1_:Object = this.context.call("TencentAne_RailAPI_GetAllAchievementNames");
         return _loc1_ as Boolean;
      }
      
      public function TencentAPI_GetAchievementInfo(param1:String) : Boolean
      {
         var _loc2_:Object = this.context.call("TencentAne_RailAPI_GetAllAchievementInfo",param1);
         return _loc2_ as Boolean;
      }
      
      public function TencentAPI_ClearAchievement(param1:String) : Boolean
      {
         if(!this._userStatsReady)
         {
            return false;
         }
         var _loc2_:Boolean = Boolean(this.context.call("TencentAne_RailAPI_ClearAchievement",param1));
         return _loc2_ as Boolean;
      }
      
      public function TenentAPI_FetchLeaderboard(param1:String, param2:int) : Boolean
      {
         var _loc3_:Object = this.context.call("TencentAne_RailAPI_FetchLeaderboard",param1,param2);
         return _loc3_ as Boolean;
      }
      
      public function TencentAPI_UploadLeaderboardScore(param1:String, param2:int, param3:Boolean) : Boolean
      {
         var _loc4_:Object = this.context.call("TencentAne_RailAPI_UploadLeaderboardScore",param1,param2,param3);
         this.logger.i("TENCENT","Upload result " + _loc4_);
         return _loc4_ as Boolean;
      }
      
      private function handleCallback(param1:Object) : void
      {
         if(param1.callback_type == "UserStatsReceived_t")
         {
            this._userStatsReady = param1.ok;
            dispatchEvent(new TgpEvent(TgpEvent.USER_STATS));
         }
         else if(param1.callback_type == "LeaderboardDownloaded_t")
         {
            dispatchEvent(new TgpEvent(TgpEvent.LEADERBOARD,param1));
         }
         else if(param1.callback_type == "LeaderboardScoreUploaded_t")
         {
            dispatchEvent(new TgpEvent(TgpEvent.LEADERBOARD_SCORE_UPLOADED,param1));
            return;
         }
      }
   }
}
