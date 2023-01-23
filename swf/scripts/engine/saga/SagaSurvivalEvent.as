package engine.saga
{
   import flash.events.Event;
   import tbs.srv.data.LeaderboardData;
   
   public class SagaSurvivalEvent extends Event
   {
      
      public static var CHANGED:String = "SagaSurvivalEvent.CHANGED";
       
      
      public var leaderboard:LeaderboardData;
      
      public var category:int;
      
      public function SagaSurvivalEvent(param1:String, param2:LeaderboardData, param3:int)
      {
         super(param1);
         this.leaderboard = param2;
         this.category = param3;
      }
   }
}
