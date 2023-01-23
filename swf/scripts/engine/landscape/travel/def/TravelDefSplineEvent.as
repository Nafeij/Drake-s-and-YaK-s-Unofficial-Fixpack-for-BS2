package engine.landscape.travel.def
{
   import flash.events.Event;
   
   public class TravelDefSplineEvent extends Event
   {
      
      public static const TYPE:String = "TravelDefSplineEvent.TYPE";
       
      
      public function TravelDefSplineEvent()
      {
         super(TYPE);
      }
   }
}
