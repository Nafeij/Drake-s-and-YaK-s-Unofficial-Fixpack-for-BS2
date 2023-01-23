package engine.path
{
   public interface IPathGraphLink
   {
       
      
      function get src() : IPathGraphNode;
      
      function get dst() : IPathGraphNode;
      
      function get cost() : Number;
      
      function get isDisabled() : Boolean;
      
      function set isDisabled(param1:Boolean) : void;
   }
}
