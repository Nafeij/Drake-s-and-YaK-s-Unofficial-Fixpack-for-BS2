package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.BattleAbilityResponseTargetType;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.core.util.Enum;
   
   public class Op_EndTurn extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_EndTurn",
         "properties":{"responseTarget":{
            "type":"string",
            "optional":true
         }}
      };
       
      
      private var responseTarget:BattleAbilityResponseTargetType;
      
      public function Op_EndTurn(param1:EffectDefOp, param2:Effect)
      {
         this.responseTarget = BattleAbilityResponseTargetType.TARGET;
         super(param1,param2);
         if(param1.params.responseTarget != undefined)
         {
            this.responseTarget = Enum.parse(BattleAbilityResponseTargetType,param1.params.responseTarget) as BattleAbilityResponseTargetType;
         }
      }
      
      override public function apply() : void
      {
         switch(this.responseTarget)
         {
            case BattleAbilityResponseTargetType.CASTER:
               caster.endTurn(false,"Op_EndTurn.apply CASTER " + this,false);
               break;
            default:
               target.endTurn(false,"Op_EndTurn.apply TARGET " + this,false);
         }
      }
   }
}
