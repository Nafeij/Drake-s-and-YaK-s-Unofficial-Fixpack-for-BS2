package tbs.srv.util
{
   import engine.core.logging.ILogger;
   import engine.tourney.TourneyDef;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class Tourney extends EventDispatcher
   {
       
      
      public var tourney_id:int;
      
      public var start_time:Number = 0;
      
      public var end_time:Number = 0;
      
      public var started:Boolean;
      
      public var ended:Boolean;
      
      public var parent_id:int;
      
      public var def:TourneyDef;
      
      public var clock_skew:Number = 0;
      
      public function Tourney()
      {
         super();
      }
      
      override public function toString() : String
      {
         return "Tourney " + this.tourney_id + " [" + this.def + " ] (" + this.start_time + " " + this.end_time + ") {" + this.started + " " + this.ended + "} " + this.parent_id;
      }
      
      public function parseJson(param1:Object, param2:ILogger) : void
      {
         this.tourney_id = param1.tourney_id;
         this.start_time = param1.start_time;
         this.end_time = param1.end_time;
         this.started = param1.started;
         this.ended = param1.ended;
         this.parent_id = param1.parent_id;
         if(param1.def == undefined)
         {
            throw new ArgumentError("No def");
         }
         this.def = new TourneyDef();
         this.def.fromJson(param1.def);
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function get end_minutes_remaining() : int
      {
         var _loc1_:Number = new Date().time;
         return Math.ceil((this.end_time - this.clock_skew - _loc1_) / (1000 * 60));
      }
      
      public function get start_minutes_remaining() : int
      {
         var _loc1_:Number = new Date().time;
         return Math.ceil((this.start_time - this.clock_skew - _loc1_) / (1000 * 60));
      }
      
      public function get day() : int
      {
         var _loc1_:Number = NaN;
         _loc1_ = new Date().time;
         var _loc2_:Number = _loc1_ + this.clock_skew - this.start_time;
         return Math.ceil(_loc2_ / (1000 * 60 * 60 * 24));
      }
      
      public function get active() : Boolean
      {
         return this.started && !this.ended;
      }
   }
}
