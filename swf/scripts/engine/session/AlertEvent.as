package engine.session
{
   import flash.events.Event;
   
   public class AlertEvent extends Event
   {
      
      public static const ALERT_ADDED:String = "AlertEvent.ALERT_ADDED";
      
      public static const ALERT_REMOVED:String = "AlertEvent.ALERT_REMOVED";
      
      public static const ALERT_RESPONSE:String = "AlertEvent.ALERT_RESPONSE";
      
      public static const ALERTS_ENABLED:String = "AlertEvent.ALERTS_ENABLED";
      
      public static const ALERT_CHANGED:String = "AlertEvent.ALERT_CHANGED";
       
      
      public var alert:Alert;
      
      public function AlertEvent(param1:String, param2:Alert)
      {
         super(param1);
         this.alert = param2;
      }
   }
}
