package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityTargetRule;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.BattleAbilityRetargetInfo;
   import engine.battle.ability.model.IBattleAbility;
   import engine.core.util.Enum;
   
   public class Op_Retarget extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_Retarget",
         "properties":{
            "casterTargetRule":{"type":"string"},
            "ability":{"type":"string"}
         }
      };
       
      
      private var casterTargetRule:BattleAbilityTargetRule;
      
      public var ablDef:BattleAbilityDef;
      
      public function Op_Retarget(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
         this.casterTargetRule = Enum.parse(BattleAbilityTargetRule,param1.params.casterTargetRule) as BattleAbilityTargetRule;
         this.ablDef = manager.factory.fetchBattleAbilityDef(param1.params.ability);
      }
      
      override public function onAbilityExecutingOnTarget(param1:IBattleAbility) : BattleAbilityRetargetInfo
      {
         var _loc2_:BattleAbility = null;
         if(this.casterTargetRule.isValid(target,target.rect,param1.caster,null,true))
         {
            _loc2_ = new BattleAbility(caster,this.ablDef,manager);
            _loc2_.targetSet.setTarget(target);
            param1.addChildAbility(_loc2_);
            return new BattleAbilityRetargetInfo(caster,_loc2_);
         }
         return null;
      }
   }
}
