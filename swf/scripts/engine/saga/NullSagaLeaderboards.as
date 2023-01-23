package engine.saga
{
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import tbs.srv.data.LeaderboardData;
   
   public class NullSagaLeaderboards extends EventDispatcher implements ISagaLeaderboards
   {
       
      
      private var _leaderbaords_global:Dictionary;
      
      private var _leaderbaords_friends:Dictionary;
      
      public function NullSagaLeaderboards()
      {
         this._leaderbaords_global = new Dictionary();
         this._leaderbaords_friends = new Dictionary();
         super();
      }
      
      public function get isSupported() : Boolean
      {
         return false;
      }
      
      public function fetchLeaderboard(param1:String, param2:int) : void
      {
      }
      
      public function uploadLeaderboardScore(param1:String, param2:int, param3:Boolean) : void
      {
      }
      
      public function handleUpdateLeaderboards(param1:LeaderboardData, param2:LeaderboardData) : void
      {
         this._leaderbaords_global[param1.leaderboard_type] = param1;
         this._leaderbaords_friends[param2.leaderboard_type] = param2;
         dispatchEvent(new SagaLeaderboardsEvent(SagaLeaderboardsEvent.FETCHED,param1.leaderboard_type));
      }
      
      public function handleUpdateLeaderboard_error(param1:String) : void
      {
         dispatchEvent(new SagaLeaderboardsEvent(SagaLeaderboardsEvent.FETCH_ERROR,param1));
      }
      
      public function handleLeaderboardScoreUploaded(param1:String, param2:int, param3:int, param4:int) : void
      {
         dispatchEvent(new SagaLeaderboardScoreUploadedEvent(SagaLeaderboardScoreUploadedEvent.UPLOADED,param1,param2,param3,param4));
      }
      
      public function getLeaderboard_global(param1:String) : LeaderboardData
      {
         return this._leaderbaords_global[param1];
      }
      
      public function getLeaderboard_friends(param1:String) : LeaderboardData
      {
         return this._leaderbaords_friends[param1];
      }
      
      public function showPlatformLeaderboard(param1:String, param2:String, param3:Boolean) : void
      {
      }
   }
}
