package engine.landscape.travel.def
{
   import flash.events.Event;
   
   public class TravelDefLocationEvent extends Event
   {
      
      public static const TYPE:String = "TravelDefLocationEvent.TYPE";
       
      
      public var index:int;
      
      public function TravelDefLocationEvent(param1:int)
      {
         super(TYPE);
         this.index = param1;
      }
   }
}
