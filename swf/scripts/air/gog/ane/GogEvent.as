package air.gog.ane
{
   import flash.events.Event;
   
   public class GogEvent extends Event
   {
      
      public static const USER_STATS:String = "GogEvent.USER_STATS";
      
      public static const SHUTDOWN:String = "GogEvent.SHUTDOWN";
      
      public static const AUTH_TICKET:String = "GogEvent.AUTH_TICKET";
      
      public static const LEADERBOARD:String = "GogEvent.LEADERBOARD";
      
      public static const LEADERBOARD_FETCH_ERROR:String = "GogEvent.LEADERBOARD_FETCH_ERROR";
      
      public static const LEADERBOARD_SCORE_UPLOADED:String = "GogEvent.LEADERBOARD_SCORE_UPLOADED";
       
      
      public var json:Object;
      
      public function GogEvent(param1:String, param2:Object = null)
      {
         super(param1);
         this.json = param2;
      }
   }
}
