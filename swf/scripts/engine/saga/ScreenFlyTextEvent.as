package engine.saga
{
   import flash.events.Event;
   
   public class ScreenFlyTextEvent extends Event
   {
      
      public static const TYPE:String = "ScreenFlyTextEvent.TYPE";
       
      
      public var text:String;
      
      public var color:uint;
      
      public var soundId:String;
      
      public var linger:Number = 0;
      
      public function ScreenFlyTextEvent(param1:String, param2:Number, param3:String, param4:Number)
      {
         super(TYPE);
         this.text = param1;
         this.color = param2;
         this.soundId = param3;
         this.linger = param4;
      }
   }
}
