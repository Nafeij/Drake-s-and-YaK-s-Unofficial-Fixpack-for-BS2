package engine.battle.ability.def
{
   import engine.ability.def.IAbilityDefFactory;
   
   public interface IBattleAbilityDefFactory extends IAbilityDefFactory
   {
       
      
      function fetchIBattleAbilityDef(param1:String, param2:Boolean = true) : IBattleAbilityDef;
   }
}
