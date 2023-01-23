package engine.core.http
{
   import flash.events.Event;
   
   public class HttpTxnResponseProcessedEvent extends Event
   {
      
      public static const TYPE:String = "HttpActionResponseProcessedEvent.TYPE";
       
      
      public var txn:HttpAction;
      
      public function HttpTxnResponseProcessedEvent(param1:HttpAction)
      {
         super(TYPE);
         this.txn = param1;
      }
   }
}
