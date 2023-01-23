package engine.battle.ability.def
{
   import engine.ability.def.AbilityDefFactory;
   
   public class BattleAbilityDefFactory extends AbilityDefFactory implements IBattleAbilityDefFactory
   {
       
      
      public function BattleAbilityDefFactory()
      {
         super();
      }
      
      public function fetchBattleAbilityDef(param1:String, param2:Boolean = true) : BattleAbilityDef
      {
         return fetch(param1,param2) as BattleAbilityDef;
      }
      
      public function fetchIBattleAbilityDef(param1:String, param2:Boolean = true) : IBattleAbilityDef
      {
         return fetch(param1,param2) as IBattleAbilityDef;
      }
   }
}
