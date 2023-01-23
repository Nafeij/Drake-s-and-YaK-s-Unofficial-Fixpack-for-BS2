package engine.battle.ai
{
   public interface IAiEntity
   {
       
      
      function getAttackStrengthNormalDamage(param1:IAiEntity, param2:Boolean) : int;
      
      function getPunctureDamage(param1:IAiEntity) : int;
      
      function getRangeTo(param1:IAiEntity) : int;
      
      function getAttackStrengthRangeMin() : int;
      
      function getAttackStrengthRangeMax() : int;
   }
}
