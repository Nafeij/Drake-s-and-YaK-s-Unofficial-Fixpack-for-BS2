package air.tencent.ane
{
   import flash.events.Event;
   
   public class TgpEvent extends Event
   {
      
      public static const USER_STATS:String = "TgpEvent.USER_STATS";
      
      public static const SHUTDOWN:String = "TgpEvent.SHUTDOWN";
      
      public static const AUTH_TICKET:String = "TgpEvent.AUTH_TICKET";
      
      public static const LEADERBOARD:String = "TgpEvent.LEADERBOARD";
      
      public static const LEADERBOARD_FETCH_ERROR:String = "TgpEvent.LEADERBOARD_FETCH_ERROR";
      
      public static const LEADERBOARD_SCORE_UPLOADED:String = "TgpEvent.LEADERBOARD_SCORE_UPLOADED";
       
      
      public var json:Object;
      
      public function TgpEvent(param1:String, param2:Object = null)
      {
         super(param1);
         this.json = param2;
      }
   }
}
