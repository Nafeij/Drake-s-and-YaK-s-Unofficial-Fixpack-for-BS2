package engine.saga
{
   import flash.events.IEventDispatcher;
   import tbs.srv.data.LeaderboardData;
   
   public interface ISagaLeaderboards extends IEventDispatcher
   {
       
      
      function fetchLeaderboard(param1:String, param2:int) : void;
      
      function uploadLeaderboardScore(param1:String, param2:int, param3:Boolean) : void;
      
      function getLeaderboard_global(param1:String) : LeaderboardData;
      
      function getLeaderboard_friends(param1:String) : LeaderboardData;
      
      function get isSupported() : Boolean;
      
      function showPlatformLeaderboard(param1:String, param2:String, param3:Boolean) : void;
   }
}
