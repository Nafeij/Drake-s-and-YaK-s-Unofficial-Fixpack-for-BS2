package engine.core.fsm
{
   import flash.events.Event;
   
   public class FsmEvent extends Event
   {
      
      public static const CURRENT:String = "FsmEvent.CURRENT";
      
      public static const LOADING:String = "FsmEvent.LOADING";
      
      public static const STOP:String = "FsmEvent.STOP";
      
      public static const FAIL:String = "FsmEvent.FAIL";
      
      public static const COMPLETED:String = "FsmEvent.COMPLETED";
       
      
      public function FsmEvent(param1:String)
      {
         super(param1);
      }
   }
}
