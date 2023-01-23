package engine.saga
{
   import flash.events.Event;
   
   public class SceneAnimPathEvent extends Event
   {
      
      public static const START:String = "SceneAnimPathEvent.START";
       
      
      public var id:String;
      
      public function SceneAnimPathEvent(param1:String, param2:String)
      {
         super(param1);
         this.id = param2;
      }
   }
}
