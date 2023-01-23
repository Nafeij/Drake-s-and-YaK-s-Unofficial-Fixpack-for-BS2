package engine.path
{
   import flash.events.Event;
   
   public class PathEvent extends Event
   {
      
      public static const EVENT_PATH_STATUS_CHANGED:String = "EVENT_PATH_STATUS_CHANGED";
       
      
      public function PathEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
      
      public function get path() : IPath
      {
         return this.target as IPath;
      }
   }
}
