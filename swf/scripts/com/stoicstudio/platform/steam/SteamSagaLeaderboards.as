package com.stoicstudio.platform.steam
{
   import air.steamworks.ane.SteamworksAne;
   import air.steamworks.ane.SteamworksEvent;
   import engine.core.logging.ILogger;
   import engine.saga.NullSagaLeaderboards;
   import engine.saga.Saga;
   import tbs.srv.data.LeaderboardData;
   
   public class SteamSagaLeaderboards extends NullSagaLeaderboards
   {
       
      
      private var steamworks:SteamworksAne;
      
      private var logger:ILogger;
      
      public function SteamSagaLeaderboards(param1:SteamworksAne, param2:ILogger)
      {
         super();
         this.steamworks = param1;
         this.logger = param2;
         param1.addEventListener(SteamworksEvent.LEADERBOARD,this.steamworksLeaderboardHandler);
         param1.addEventListener(SteamworksEvent.LEADERBOARD_FETCH_ERROR,this.steamworksLeaderboardFetchErrorHandler);
         param1.addEventListener(SteamworksEvent.LEADERBOARD_SCORE_UPLOADED,this.steamworksLeaderboardScoreUploadedHandler);
      }
      
      override public function get isSupported() : Boolean
      {
         return true;
      }
      
      override public function fetchLeaderboard(param1:String, param2:int) : void
      {
         this.steamworks.FetchLeaderboardSimpleData(param1,param2);
      }
      
      override public function uploadLeaderboardScore(param1:String, param2:int, param3:Boolean) : void
      {
         var _loc4_:Saga = Saga.instance;
         if(_loc4_.isAchievementsSuppressed)
         {
            this.logger.i("LBD","SteamSagaLeaderboards.uploadLeaderboardScore suppressed for [" + param1 + "] score [" + param2 + "]");
            return;
         }
         this.steamworks.SteamUserStats_UploadLeaderboardScore(param1,param2,param3);
      }
      
      private function steamworksLeaderboardFetchErrorHandler(param1:SteamworksEvent) : void
      {
         this.logger.info("STEAM leaderboards error");
         handleUpdateLeaderboard_error(param1.json.name);
      }
      
      private function steamworksLeaderboardScoreUploadedHandler(param1:SteamworksEvent) : void
      {
         this.logger.info("STEAM leaderboards uploaded");
         var _loc2_:Object = param1.json;
         handleLeaderboardScoreUploaded(_loc2_.name,_loc2_.score,_loc2_.rank_prev,_loc2_.rank_new);
      }
      
      private function steamworksLeaderboardHandler(param1:SteamworksEvent) : void
      {
         this.logger.info("STEAM leaderboards received");
         var _loc2_:LeaderboardData = new LeaderboardData();
         var _loc3_:LeaderboardData = new LeaderboardData();
         var _loc4_:String = this.steamworks.SteamFriends_GetPersonaName();
         var _loc5_:String = this.steamworks.SteamUser_GetSteamID();
         SteamLeaderboardGenerator.generateLeaderboards(param1.json,_loc5_,_loc4_,_loc2_,_loc3_);
         handleUpdateLeaderboards(_loc2_,_loc3_);
      }
   }
}
