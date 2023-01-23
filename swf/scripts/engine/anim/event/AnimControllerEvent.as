package engine.anim.event
{
   import engine.anim.view.AnimController;
   import flash.events.Event;
   
   public class AnimControllerEvent extends Event
   {
      
      public static const EVENT:String = "AnimControllerEvent.EVENT";
      
      public static const FINISHING:String = "AnimControllerEvent.FINISHING";
       
      
      public var controller:AnimController;
      
      public var animId:String;
      
      public var eventId:String;
      
      public function AnimControllerEvent(param1:String, param2:AnimController, param3:String, param4:String)
      {
         super(param1,bubbles,cancelable);
         this.controller = param2;
         this.animId = param3;
         this.eventId = param4;
      }
   }
}
