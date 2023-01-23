package engine.path
{
   import flash.events.Event;
   
   public class PathDebugEvent extends Event
   {
      
      public static const SHOW_PATHS:String = "SHOW_PATHS";
      
      public static const SHOW_GRAPH:String = "SHOW_GRAPH";
      
      public static const PATH_ADDED:String = "PATH_ADDED";
      
      public static const PATH_REMOVED:String = "PATH_REMOVED";
      
      public static const PATHFINDING_ENABLED:String = "PATHFINDING_ENABLED";
       
      
      public var path:IPath;
      
      public function PathDebugEvent(param1:String, param2:IPath = null)
      {
         super(param1);
         this.path = param2;
      }
   }
}
