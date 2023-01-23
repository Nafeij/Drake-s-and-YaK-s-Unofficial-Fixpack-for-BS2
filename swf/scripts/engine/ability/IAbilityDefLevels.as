package engine.ability
{
   import engine.core.logging.ILogger;
   
   public interface IAbilityDefLevels
   {
       
      
      function get numAbilities() : int;
      
      function getAbilityDef(param1:int) : IAbilityDef;
      
      function getAbilityDefLevel(param1:int) : IAbilityDefLevel;
      
      function getAbilityIndex(param1:String) : int;
      
      function getAbilityDefById(param1:String) : IAbilityDef;
      
      function getAbilityDefLevelById(param1:String) : IAbilityDefLevel;
      
      function getAbilityLevel(param1:int) : int;
      
      function hasAbility(param1:String) : Boolean;
      
      function setAbilityDefLevel(param1:IAbilityDef, param2:int, param3:int, param4:ILogger) : IAbilityDefLevel;
      
      function addAbilityDefLevel(param1:IAbilityDefLevel, param2:ILogger) : IAbilityDefLevel;
      
      function clone(param1:ILogger) : IAbilityDefLevels;
      
      function set name(param1:String) : void;
      
      function get name() : String;
      
      function addSuppression(param1:String) : void;
      
      function isSuppressed(param1:String) : Boolean;
      
      function getDebugString() : String;
      
      function removeAbility(param1:String) : void;
   }
}
