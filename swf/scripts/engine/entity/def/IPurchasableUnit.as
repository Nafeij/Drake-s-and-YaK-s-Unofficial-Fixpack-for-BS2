package engine.entity.def
{
   public interface IPurchasableUnit
   {
       
      
      function get def() : IEntityDef;
      
      function get limit() : int;
      
      function get cost() : int;
      
      function get comment() : String;
   }
}
