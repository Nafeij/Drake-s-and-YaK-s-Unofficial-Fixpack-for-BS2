package engine.saga
{
   import flash.events.Event;
   
   public final class SagaDlcEvent extends Event
   {
      
      public static const DLC_CHECK_COMPLETE:String = "SagaDlcEvent.DLC_CHECK_COMPLETE";
       
      
      public var dlc_id:String;
      
      public var dlc_status:int;
      
      public function SagaDlcEvent(param1:String, param2:String, param3:int)
      {
         super(param1);
         this.dlc_id = param2;
         this.dlc_status = param3;
      }
   }
}
