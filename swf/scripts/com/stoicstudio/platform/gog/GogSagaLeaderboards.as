package com.stoicstudio.platform.gog
{
   import air.gog.ane.GogAne;
   import air.gog.ane.GogEvent;
   import engine.saga.NullSagaLeaderboards;
   import engine.saga.Saga;
   import tbs.srv.data.LeaderboardData;
   
   public class GogSagaLeaderboards extends NullSagaLeaderboards
   {
       
      
      private var galaxy:GogAne;
      
      public function GogSagaLeaderboards(param1:GogAne)
      {
         super();
         this.galaxy = param1;
         param1.addEventListener(GogEvent.LEADERBOARD,this.gogLeaderboardHandler);
         param1.addEventListener(GogEvent.LEADERBOARD_FETCH_ERROR,this.gogLeaderboardFetchErrorHandler);
         param1.addEventListener(GogEvent.LEADERBOARD_SCORE_UPLOADED,this.gogLeaderboardScoreUploadedHandler);
      }
      
      override public function get isSupported() : Boolean
      {
         return true;
      }
      
      override public function fetchLeaderboard(param1:String, param2:int) : void
      {
         this.galaxy.GalaxyAPI_FetchLeaderboard(param1,param2);
      }
      
      override public function uploadLeaderboardScore(param1:String, param2:int, param3:Boolean) : void
      {
         this.galaxy.logger.i("GOG","uploading board with: " + param1 + " -- " + param2 + " -- " + param3);
         var _loc4_:Saga = Saga.instance;
         if(_loc4_.isAchievementsSuppressed)
         {
            this.galaxy.logger.i("LBD","GogSagaLeaderboards.uploadLeaderboardScore suppressed for [" + param1 + "] score [" + param2 + "]");
            return;
         }
         this.galaxy.GalaxyAPI_UploadLeaderboardScore(param1,param2,param3);
      }
      
      private function gogLeaderboardHandler(param1:GogEvent) : void
      {
         var _loc2_:LeaderboardData = new LeaderboardData();
         var _loc3_:LeaderboardData = new LeaderboardData();
         var _loc4_:String = this.galaxy.GalaxyAPI_GetPersonaName();
         var _loc5_:String = this.galaxy.GalaxyAPI_GetUserId();
         GogLeaderboardGenerator.generateLeaderboards(param1.json,_loc5_,_loc4_,_loc2_,_loc3_);
         handleUpdateLeaderboards(_loc2_,_loc3_);
      }
      
      private function gogLeaderboardFetchErrorHandler(param1:GogEvent) : void
      {
         handleUpdateLeaderboard_error(param1.json.name);
      }
      
      private function gogLeaderboardScoreUploadedHandler(param1:GogEvent) : void
      {
         handleLeaderboardScoreUploaded(param1.json.name,param1.json.score,param1.json.rank_prev,param1.json.rank_new);
      }
   }
}
