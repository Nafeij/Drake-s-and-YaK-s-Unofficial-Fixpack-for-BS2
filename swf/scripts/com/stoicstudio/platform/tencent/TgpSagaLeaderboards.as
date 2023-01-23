package com.stoicstudio.platform.tencent
{
   import air.tencent.ane.TencentAne;
   import air.tencent.ane.TgpEvent;
   import engine.saga.NullSagaLeaderboards;
   import engine.saga.Saga;
   import tbs.srv.data.LeaderboardData;
   
   public class TgpSagaLeaderboards extends NullSagaLeaderboards
   {
       
      
      private var tencent:TencentAne;
      
      public function TgpSagaLeaderboards(param1:TencentAne)
      {
         super();
         this.tencent = param1;
         param1.addEventListener(TgpEvent.LEADERBOARD,this.tgpLeaderboardHandler);
         param1.addEventListener(TgpEvent.LEADERBOARD_FETCH_ERROR,this.tgpLeaderboardFetchErrorHandler);
         param1.addEventListener(TgpEvent.LEADERBOARD_SCORE_UPLOADED,this.tgpLeaderboardScoreUploadedHandler);
      }
      
      override public function get isSupported() : Boolean
      {
         return true;
      }
      
      override public function fetchLeaderboard(param1:String, param2:int) : void
      {
         var _loc3_:Boolean = this.tencent.TenentAPI_FetchLeaderboard(param1,param2);
      }
      
      override public function uploadLeaderboardScore(param1:String, param2:int, param3:Boolean) : void
      {
         this.tencent.logger.i("TENCENT","uploading board with: " + param1 + " -- " + param2 + " -- " + param3);
         var _loc4_:Saga = Saga.instance;
         if(_loc4_.isAchievementsSuppressed)
         {
            this.tencent.logger.i("LBD","TgpSagaLeaderboards.uploadLeaderboardScore suppressed for [" + param1 + "] score [" + param2 + "]");
            return;
         }
         this.tencent.TencentAPI_UploadLeaderboardScore(param1,param2,param3);
      }
      
      private function tgpLeaderboardHandler(param1:TgpEvent) : void
      {
         var _loc2_:LeaderboardData = new LeaderboardData();
         var _loc3_:LeaderboardData = new LeaderboardData();
         var _loc4_:String = this.tencent.TencentAPI_GetRailPlayerName();
         var _loc5_:String = this.tencent.TencentAPI_GetRailID();
         TgpLeaderboardGenerator.generateLeaderboards(param1.json,_loc5_,_loc4_,_loc2_,_loc3_);
         handleUpdateLeaderboards(_loc2_,_loc3_);
      }
      
      private function tgpLeaderboardFetchErrorHandler(param1:TgpEvent) : void
      {
         handleUpdateLeaderboard_error(param1.json.name);
      }
      
      private function tgpLeaderboardScoreUploadedHandler(param1:TgpEvent) : void
      {
         handleLeaderboardScoreUploaded(param1.json.name,param1.json.score,param1.json.rank_prev,param1.json.rank_new);
      }
   }
}
