package engine.input
{
   import flash.events.Event;
   
   public class InputDeviceEvent extends Event
   {
      
      public static const CONTROLLER_LOST:String = "InputDeviceEvent.CONTROLLER_LOST";
      
      public static const CONTROLLER_REESTABLISHED:String = "InputDeviceEvent.CONTROLLER_REESTABLISHED";
       
      
      public function InputDeviceEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
   }
}
