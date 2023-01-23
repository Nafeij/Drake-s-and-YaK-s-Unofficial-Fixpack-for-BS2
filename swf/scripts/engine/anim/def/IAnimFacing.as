package engine.anim.def
{
   public interface IAnimFacing
   {
       
      
      function get name() : String;
      
      function clockwise() : IAnimFacing;
      
      function getLeft(param1:int, param2:int) : int;
      
      function getRight(param1:int, param2:int) : int;
      
      function getFront(param1:int, param2:int) : int;
      
      function getBack(param1:int, param2:int) : int;
      
      function get flip() : IAnimFacing;
      
      function get deltaX() : int;
      
      function get deltaY() : int;
   }
}
