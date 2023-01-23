package engine.landscape.travel.def
{
   import flash.events.Event;
   
   public class TravelDefLocationsEvent extends Event
   {
      
      public static const TYPE:String = "TravelDefLocationsEvent.TYPE";
       
      
      public function TravelDefLocationsEvent()
      {
         super(TYPE);
      }
   }
}
