package engine.anim.def
{
   public interface IAnimFrameDef
   {
       
      
      function get number() : int;
      
      function get events() : Vector.<IAnimEventDef>;
      
      function set number(param1:int) : void;
      
      function set events(param1:Vector.<IAnimEventDef>) : void;
   }
}
