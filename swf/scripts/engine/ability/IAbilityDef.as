package engine.ability
{
   import engine.stat.def.StatType;
   import engine.stat.model.Stats;
   
   public interface IAbilityDef
   {
       
      
      function get id() : String;
      
      function get name() : String;
      
      function get descriptionRank() : String;
      
      function get descriptionBrief() : String;
      
      function get maxLevel() : int;
      
      function get level() : int;
      
      function get root() : IAbilityDef;
      
      function get iconUrl() : String;
      
      function get iconLargeUrl() : String;
      
      function get iconBuffUrl() : String;
      
      function get costs() : Stats;
      
      function get artifactChargeCost() : int;
      
      function get displayDamageUI() : Boolean;
      
      function get optionalStars() : int;
      
      function getCost(param1:StatType) : int;
      
      function toString() : String;
      
      function getAbilityDefForLevel(param1:int) : IAbilityDef;
   }
}
