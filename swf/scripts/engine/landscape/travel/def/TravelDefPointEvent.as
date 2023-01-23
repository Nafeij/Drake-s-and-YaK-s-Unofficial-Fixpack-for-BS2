package engine.landscape.travel.def
{
   import flash.events.Event;
   
   public class TravelDefPointEvent extends Event
   {
      
      public static const TYPE:String = "TravelDefPointEvent.TYPE";
       
      
      public var index:int;
      
      public function TravelDefPointEvent(param1:int)
      {
         super(TYPE);
         this.index = param1;
      }
   }
}
