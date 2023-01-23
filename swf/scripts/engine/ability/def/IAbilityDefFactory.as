package engine.ability.def
{
   import engine.core.logging.ILogger;
   
   public interface IAbilityDefFactory
   {
       
      
      function get logger() : ILogger;
      
      function fetch(param1:String, param2:Boolean = true) : AbilityDef;
   }
}
