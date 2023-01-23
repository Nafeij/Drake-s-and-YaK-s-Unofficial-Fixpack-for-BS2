package engine.core.util
{
   public interface IRefcount
   {
       
      
      function addReference() : void;
      
      function releaseReference() : void;
      
      function get refcount() : uint;
   }
}
