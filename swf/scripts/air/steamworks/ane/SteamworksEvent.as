package air.steamworks.ane
{
   import flash.events.Event;
   
   public class SteamworksEvent extends Event
   {
      
      public static const USER_STATS:String = "SteamworksEvent.USER_STATS";
      
      public static const SHUTDOWN:String = "SteamworksEvent.SHUTDOWN";
      
      public static const AUTH_TICKET:String = "SteamworksEvent.AUTH_TICKET";
      
      public static const LEADERBOARD:String = "SteamworksEvent.LEADERBOARD";
      
      public static const LEADERBOARD_FETCH_ERROR:String = "SteamworksEvent.LEADERBOARD_FETCH_ERROR";
      
      public static const LEADERBOARD_SCORE_UPLOADED:String = "SteamworksEvent.LEADERBOARD_SCORE_UPLOADED";
       
      
      public var json:Object;
      
      public function SteamworksEvent(param1:String, param2:Object = null)
      {
         super(param1);
         this.json = param2;
      }
   }
}
