package engine.saga
{
   import flash.events.Event;
   
   public class SceneCameraSplinePauseEvent extends Event
   {
      
      public static const TYPE:String = "SceneCameraSplinePauseEvent.TYPE";
       
      
      public var paused:Boolean;
      
      public function SceneCameraSplinePauseEvent(param1:Boolean)
      {
         super(TYPE);
         this.paused = param1;
      }
   }
}
