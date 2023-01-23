package engine.sound
{
   import flash.events.Event;
   
   public class SoundDriverEvent extends Event
   {
      
      public static const PLAY:String = "SoundDriverEvent.PLAY";
      
      public static const STOP:String = "SoundDriverEvent.STOP";
      
      public static const PARAM:String = "SoundDriverEvent.PARAM";
      
      public static const ERROR:String = "SoundDriverEvent.ERROR";
       
      
      public var systemid:ISoundEventId;
      
      public var eventName:String;
      
      public var param:String;
      
      public var value:Number;
      
      public var msg:String;
      
      public function SoundDriverEvent(param1:String, param2:ISoundEventId, param3:String, param4:String, param5:Number, param6:String)
      {
         super(param1);
         this.systemid = param2;
         this.eventName = param3;
         this.param = param4;
         this.value = param5;
         this.msg = param6;
      }
   }
}
