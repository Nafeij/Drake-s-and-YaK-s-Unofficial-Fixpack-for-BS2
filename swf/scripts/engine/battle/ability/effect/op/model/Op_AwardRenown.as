package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   
   public class Op_AwardRenown extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_AwardRenown",
         "properties":{"amount":{"type":"number"}}
      };
       
      
      private var amount:int = 0;
      
      public function Op_AwardRenown(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
         this.amount = param1.params.amount;
      }
      
      override public function apply() : void
      {
         target.bonusRenown += this.amount;
      }
   }
}
