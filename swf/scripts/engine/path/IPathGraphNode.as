package engine.path
{
   public interface IPathGraphNode
   {
       
      
      function get cost() : Number;
      
      function get key() : Object;
      
      function get links() : Vector.<IPathGraphLink>;
      
      function get islandId() : int;
      
      function get enabled() : Object;
      
      function getLink(param1:IPathGraphNode) : IPathGraphLink;
      
      function addLink(param1:IPathGraphNode, param2:Number) : IPathGraphLink;
      
      function get region() : int;
      
      function set region(param1:int) : void;
   }
}
