package engine.entity.def
{
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import flash.events.IEventDispatcher;
   
   public interface IEntityListDef extends IEventDispatcher, IEntityListStatProvider
   {
       
      
      function getEntityDefById(param1:String) : IEntityDef;
      
      function get numEntityDefs() : int;
      
      function get numCombatants() : int;
      
      function get numSurvivalAvailable() : int;
      
      function getEntityDef(param1:int) : IEntityDef;
      
      function removeEntityDef(param1:IEntityDef) : void;
      
      function addEntityDef(param1:IEntityDef) : void;
      
      function clear() : void;
      
      function sortEntities() : void;
      
      function get trackCombatants() : Boolean;
      
      function copyFrom(param1:IEntityListDef) : void;
      
      function get classes() : EntityClassDefList;
      
      function get locale() : Locale;
      
      function get numInjuredCombatants() : int;
      
      function get hasInjuredCombatants() : Boolean;
      
      function get hasUpgradeableCombatants() : Boolean;
      
      function changeLocale(param1:Locale) : void;
      
      function get logger() : ILogger;
      
      function countCombatantAtRank(param1:int) : int;
      
      function getCombatantIndex(param1:IEntityDef) : int;
      
      function getCombatantAt(param1:int) : IEntityDef;
      
      function get combatantRankMin() : int;
      
      function get combatantRankMax() : int;
      
      function getDebugString() : String;
   }
}
