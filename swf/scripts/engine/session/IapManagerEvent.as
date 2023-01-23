package engine.session
{
   import flash.events.Event;
   
   public class IapManagerEvent extends Event
   {
      
      public static const STARTED:String = "IapManagerEvent.STARTED";
      
      public static const NO_OVERLAY:String = "IapManagerEvent.NO_OVERLAY";
       
      
      public var iap:Iap;
      
      public function IapManagerEvent(param1:String, param2:Iap)
      {
         super(param1);
         this.iap = param2;
      }
   }
}
