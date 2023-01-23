package engine.saga
{
   import flash.events.EventDispatcher;
   import tbs.srv.data.LeaderboardData;
   
   public class SagaLeaderboards
   {
      
      private static var _impl:ISagaLeaderboards;
      
      public static var dispatcher:EventDispatcher = new EventDispatcher();
      
      public static var NUM_ENTRIES:int = 20;
      
      public static var count_fetch:int;
       
      
      public function SagaLeaderboards()
      {
         super();
      }
      
      public static function get impl() : ISagaLeaderboards
      {
         if(_impl == null)
         {
            throw new Error("SagaLeaderboards impl has not been set.");
         }
         return _impl;
      }
      
      public static function set impl(param1:ISagaLeaderboards) : void
      {
         if(_impl)
         {
            _impl.removeEventListener(SagaLeaderboardsEvent.FETCHED,fetchedHandler);
            _impl.removeEventListener(SagaLeaderboardsEvent.FETCH_ERROR,errorHandler);
            _impl.removeEventListener(SagaLeaderboardScoreUploadedEvent.UPLOADED,uploadedHandler);
         }
         _impl = param1;
         if(_impl)
         {
            _impl.addEventListener(SagaLeaderboardsEvent.FETCHED,fetchedHandler);
            _impl.addEventListener(SagaLeaderboardsEvent.FETCH_ERROR,errorHandler);
            _impl.addEventListener(SagaLeaderboardScoreUploadedEvent.UPLOADED,uploadedHandler);
         }
      }
      
      private static function uploadedHandler(param1:SagaLeaderboardScoreUploadedEvent) : void
      {
         dispatcher.dispatchEvent(new SagaLeaderboardScoreUploadedEvent(param1.type,param1.lbname,param1.score,param1.rank_prev,param1.rank_next));
      }
      
      private static function fetchedHandler(param1:SagaLeaderboardsEvent) : void
      {
         count_fetch = Math.max(0,--count_fetch);
         dispatcher.dispatchEvent(new SagaLeaderboardsEvent(param1.type,param1.lbname));
      }
      
      private static function errorHandler(param1:SagaLeaderboardsEvent) : void
      {
         dispatcher.dispatchEvent(new SagaLeaderboardsEvent(param1.type,param1.lbname));
      }
      
      public static function get isSupported() : Boolean
      {
         return !!_impl ? _impl.isSupported : false;
      }
      
      public static function fetchLeaderboard(param1:String) : void
      {
         if(!_impl.isSupported)
         {
            return;
         }
         ++count_fetch;
         _impl.fetchLeaderboard(param1,NUM_ENTRIES);
      }
      
      public static function uploadLeaderboardScore(param1:String, param2:int, param3:Boolean) : void
      {
         if(!_impl.isSupported)
         {
            return;
         }
         var _loc4_:Saga = Saga.instance;
         if(_loc4_.isAchievementsSuppressed)
         {
            _loc4_.logger.i("LBD","SagaLeaderboards.uploadLeaderboardScore suppressed for [" + param1 + "] score [" + param2 + "]");
            return;
         }
         _impl.uploadLeaderboardScore(param1,param2,param3);
      }
      
      public static function getLeaderboard_global(param1:String) : LeaderboardData
      {
         if(!_impl.isSupported)
         {
            return null;
         }
         return _impl.getLeaderboard_global(param1);
      }
      
      public static function getLeaderboard_friends(param1:String) : LeaderboardData
      {
         if(!_impl.isSupported)
         {
            return null;
         }
         return _impl.getLeaderboard_friends(param1);
      }
      
      public static function showPlatformLeaderboard(param1:String, param2:String, param3:Boolean) : void
      {
         if(!_impl.isSupported)
         {
            return;
         }
         _impl.showPlatformLeaderboard(param1,param2,param3);
      }
   }
}
