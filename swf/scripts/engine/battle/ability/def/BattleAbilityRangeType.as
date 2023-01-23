package engine.battle.ability.def
{
   import engine.core.util.Enum;
   
   public class BattleAbilityRangeType extends Enum
   {
      
      public static const NONE:BattleAbilityRangeType = new BattleAbilityRangeType("NONE",enumCtorKey,false,false);
      
      public static const MELEE:BattleAbilityRangeType = new BattleAbilityRangeType("MELEE",enumCtorKey,true,false);
      
      public static const RANGED:BattleAbilityRangeType = new BattleAbilityRangeType("RANGED",enumCtorKey,false,true);
       
      
      public var isMelee:Boolean;
      
      public var isRanged:Boolean;
      
      public function BattleAbilityRangeType(param1:String, param2:Object, param3:Boolean, param4:Boolean)
      {
         super(param1,param2);
         this.isMelee = param3;
         this.isRanged = param4;
      }
   }
}
