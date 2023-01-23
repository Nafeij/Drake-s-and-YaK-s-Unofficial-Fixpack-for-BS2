package tbs.srv.util
{
   import engine.core.logging.ILogger;
   import engine.tourney.TourneyDef;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class TourneyWinnerData extends EventDispatcher
   {
       
      
      public var tourney_id:int;
      
      public var ranked_ids:Vector.<int>;
      
      public var ranked_display_names:Vector.<String>;
      
      public var def:TourneyDef;
      
      public function TourneyWinnerData()
      {
         this.ranked_ids = new Vector.<int>();
         this.ranked_display_names = new Vector.<String>();
         super();
      }
      
      override public function toString() : String
      {
         return "TourneyProgressData " + this.tourney_id + " [" + this.def + " ] " + this.ranked_ids + " " + this.ranked_display_names;
      }
      
      public function parseJson(param1:Object, param2:ILogger) : void
      {
         var _loc3_:int = 0;
         var _loc4_:String = null;
         this.tourney_id = param1.tourney_id;
         this.ranked_ids.splice(0,this.ranked_ids.length);
         for each(_loc3_ in param1.ranked_ids)
         {
            this.ranked_ids.push(_loc3_);
         }
         this.ranked_display_names.splice(0,this.ranked_display_names.length);
         for each(_loc4_ in param1.ranked_display_names)
         {
            this.ranked_display_names.push(_loc4_);
         }
         if(param1.def == undefined)
         {
            throw new ArgumentError("No def");
         }
         this.def = new TourneyDef();
         this.def.fromJson(param1.def);
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function get winnerName() : String
      {
         return this.ranked_display_names.length > 0 ? this.ranked_display_names[0] : "";
      }
      
      public function get winnerId() : int
      {
         return this.ranked_ids.length > 0 ? this.ranked_ids[0] : 0;
      }
      
      public function isAWinner(param1:int) : Boolean
      {
         var _loc2_:int = 0;
         for each(_loc2_ in this.ranked_ids)
         {
            if(_loc2_ == param1)
            {
               return true;
            }
         }
         return false;
      }
   }
}
