package engine.saga
{
   import flash.events.Event;
   
   public class SceneAnimPlayEvent extends Event
   {
      
      public static const TYPE:String = "SceneAnimPlayEvent.TYPE";
       
      
      public var id:String;
      
      public var frame:int;
      
      public var loops:int;
      
      public function SceneAnimPlayEvent(param1:String, param2:int, param3:int)
      {
         super(TYPE);
         this.id = param1;
         this.frame = param2;
         this.loops = param3;
      }
   }
}
