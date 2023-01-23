package engine.path
{
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   
   public interface IPath extends IEventDispatcher
   {
       
      
      function get status() : PathStatus;
      
      function get src() : IPathGraphNode;
      
      function get dst() : IPathGraphNode;
      
      function get links() : Vector.<IPathGraphLink>;
      
      function get dispatcher() : EventDispatcher;
      
      function get nodes() : Vector.<IPathGraphNode>;
      
      function set links(param1:Vector.<IPathGraphLink>) : void;
      
      function set status(param1:PathStatus) : void;
      
      function get elapsed() : int;
      
      function set elapsed(param1:int) : void;
      
      function toString() : String;
   }
}
