package engine.stat.model
{
   public interface IStatModProvider
   {
       
      
      function handleStatModUsed(param1:StatMod) : void;
      
      function get isStatModProviderRemoved() : Boolean;
   }
}
