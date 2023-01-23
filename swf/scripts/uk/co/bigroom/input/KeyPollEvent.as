package uk.co.bigroom.input
{
   import flash.events.Event;
   
   public class KeyPollEvent extends Event
   {
      
      public static const CHANGED:String = "CHANGED";
       
      
      public var keyCode:uint;
      
      public var down:Boolean;
      
      public function KeyPollEvent(param1:String, param2:uint, param3:Boolean)
      {
         super(param1);
         this.keyCode = param2;
         this.down = param3;
      }
   }
}
