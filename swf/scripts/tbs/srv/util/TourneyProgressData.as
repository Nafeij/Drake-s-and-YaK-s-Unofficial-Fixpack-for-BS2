package tbs.srv.util
{
   import engine.core.logging.ILogger;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class TourneyProgressData extends EventDispatcher
   {
       
      
      public var tourney_id:int;
      
      public var tourney_name:String;
      
      public var battle_count:int;
      
      public var rank:int;
      
      public var clock_skew:Number = 0;
      
      public function TourneyProgressData()
      {
         super();
      }
      
      override public function toString() : String
      {
         return "TourneyProgressData " + this.tourney_id + " [" + this.tourney_name + " ] " + this.battle_count + " " + this.rank;
      }
      
      public function parseJson(param1:Object, param2:ILogger) : void
      {
         this.tourney_id = param1.tourney_id;
         this.tourney_name = param1.tourney_name;
         this.battle_count = param1.battle_count;
         this.rank = param1.rank;
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function get joined() : Boolean
      {
         return this.tourney_id != 0;
      }
   }
}
