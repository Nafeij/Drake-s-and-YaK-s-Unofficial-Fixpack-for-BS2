package engine.saga
{
   import flash.events.Event;
   
   public class SceneCameraPanEvent extends Event
   {
      
      public static const TYPE:String = "SceneCameraPanEvent.TYPE";
       
      
      public var anchor:String;
      
      public var speed:Number = 1000;
      
      public function SceneCameraPanEvent(param1:String, param2:Number)
      {
         super(TYPE);
         this.anchor = param1;
         this.speed = param2;
      }
   }
}
