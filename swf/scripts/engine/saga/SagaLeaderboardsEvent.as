package engine.saga
{
   import flash.events.Event;
   
   public class SagaLeaderboardsEvent extends Event
   {
      
      public static var FETCHED:String = "SagaLeaderboardsEvent.FETCHED";
      
      public static var FETCH_ERROR:String = "SagaLeaderboardsEvent.FETCH_ERROR";
       
      
      public var lbname:String;
      
      public function SagaLeaderboardsEvent(param1:String, param2:String)
      {
         super(param1);
         this.lbname = param2;
      }
   }
}
