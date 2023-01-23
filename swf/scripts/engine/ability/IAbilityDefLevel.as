package engine.ability
{
   public interface IAbilityDefLevel
   {
       
      
      function get id() : String;
      
      function get def() : IAbilityDef;
      
      function get level() : int;
      
      function set level(param1:int) : void;
      
      function get rankAcquired() : int;
      
      function get enabled() : Boolean;
      
      function set enabled(param1:Boolean) : void;
   }
}
