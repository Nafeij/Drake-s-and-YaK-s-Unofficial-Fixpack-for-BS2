package engine.path
{
   import flash.utils.Dictionary;
   
   public interface IPathGraph
   {
       
      
      function getNode(param1:Object) : IPathGraphNode;
      
      function addNode(param1:Object, param2:Number, param3:int) : IPathGraphNode;
      
      function addLink(param1:Object, param2:Object, param3:Number) : IPathGraphLink;
      
      function addLinkPair(param1:Object, param2:Object, param3:Number) : void;
      
      function getPath(param1:Object, param2:Object, param3:Function, param4:Function) : IPath;
      
      function getLinks(param1:Object) : Vector.<IPathGraphLink>;
      
      function getLink(param1:Object, param2:Object) : IPathGraphLink;
      
      function update(param1:int) : void;
      
      function cleanup() : void;
      
      function get nodes() : Dictionary;
      
      function finishGraphGeneration(param1:int, param2:Function) : void;
      
      function setNodeEnabled(param1:IPathGraphNode, param2:Boolean) : void;
   }
}
