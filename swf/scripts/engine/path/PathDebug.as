package engine.path
{
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class PathDebug extends EventDispatcher
   {
      
      public static const it:PathDebug = new PathDebug();
       
      
      private var _showPathGraph:Boolean = false;
      
      private var _showPaths:Boolean = false;
      
      public var paths:Dictionary;
      
      private var _pathfindingEnabled:Boolean = true;
      
      public function PathDebug()
      {
         this.paths = new Dictionary();
         super();
      }
      
      public function get pathfindingEnabled() : Boolean
      {
         return this._pathfindingEnabled;
      }
      
      public function set pathfindingEnabled(param1:Boolean) : void
      {
         if(this._pathfindingEnabled != param1)
         {
            this._pathfindingEnabled = param1;
            dispatchEvent(new PathDebugEvent(PathDebugEvent.PATHFINDING_ENABLED));
         }
      }
      
      public function get showPaths() : Boolean
      {
         return this._showPaths;
      }
      
      public function set showPaths(param1:Boolean) : void
      {
         if(this._showPaths != param1)
         {
            this._showPaths = param1;
            dispatchEvent(new PathDebugEvent(PathDebugEvent.SHOW_PATHS));
         }
      }
      
      public function get showPathGraph() : Boolean
      {
         return this._showPathGraph;
      }
      
      public function set showPathGraph(param1:Boolean) : void
      {
         if(this._showPathGraph != param1)
         {
            this._showPathGraph = param1;
            dispatchEvent(new PathDebugEvent(PathDebugEvent.SHOW_GRAPH));
         }
      }
      
      public function addPath(param1:IPath) : void
      {
         this.paths[param1] = param1;
         dispatchEvent(new PathDebugEvent(PathDebugEvent.PATH_ADDED,param1));
      }
      
      public function removePath(param1:IPath) : void
      {
         delete this.paths[param1];
         dispatchEvent(new PathDebugEvent(PathDebugEvent.PATH_REMOVED,param1));
      }
   }
}
