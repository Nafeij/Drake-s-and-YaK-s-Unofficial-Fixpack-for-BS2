package engine.saga
{
   import flash.events.Event;
   
   public class SagaPresenceStateEvent extends Event
   {
      
      public static const STATE_CHANGE:String = "SagaPresenceStateEvent.STATE_CHANGE";
       
      
      public function SagaPresenceStateEvent()
      {
         super(STATE_CHANGE);
      }
   }
}
