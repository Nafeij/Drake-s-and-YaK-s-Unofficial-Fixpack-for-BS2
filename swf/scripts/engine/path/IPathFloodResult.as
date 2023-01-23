package engine.path
{
   public interface IPathFloodResult
   {
       
      
      function get numResults() : int;
      
      function getResultKey(param1:int) : Object;
      
      function hasResultKey(param1:Object) : Boolean;
   }
}
