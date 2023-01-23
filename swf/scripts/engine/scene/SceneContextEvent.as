package engine.scene
{
   import flash.events.Event;
   
   public class SceneContextEvent extends Event
   {
      
      public static const LOCALE:String = "SceneContextEvent.LOCALE";
       
      
      public function SceneContextEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
   }
}
