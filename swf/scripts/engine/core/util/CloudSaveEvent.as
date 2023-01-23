package engine.core.util
{
   import flash.events.Event;
   
   public final class CloudSaveEvent extends Event
   {
      
      public static var EVENT_PULL_COMPLETE:String = "CloudSave.EVENT_PULL_COMPLETE";
      
      public static var EVENT_PUSH_COMPLETE:String = "CloudSave.EVENT_PUSH_COMPLETE";
      
      public static var EVENT_NOT_ENABLED:String = "CloudSave.EVENT_NOT_ENABLED";
      
      public static var EVENT_NOT_AUTHENTICATED:String = "CloudSave.EVENT_NOT_AUTHENTICATED";
       
      
      public function CloudSaveEvent(param1:String)
      {
         super(param1,bubbles,cancelable);
      }
   }
}
