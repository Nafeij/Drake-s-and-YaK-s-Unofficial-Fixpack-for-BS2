package engine.saga
{
   import flash.events.Event;
   
   public class SagaLeaderboardScoreUploadedEvent extends Event
   {
      
      public static var UPLOADED:String = "SagaLeaderboardScoreUploadedEvent.UPLOADED";
       
      
      public var lbname:String;
      
      public var score:int;
      
      public var rank_prev:int;
      
      public var rank_next:int;
      
      public function SagaLeaderboardScoreUploadedEvent(param1:String, param2:String, param3:int, param4:int, param5:int)
      {
         super(param1);
         this.lbname = param2;
         this.score = param3;
         this.rank_next = param5;
         this.rank_prev = param4;
      }
   }
}
