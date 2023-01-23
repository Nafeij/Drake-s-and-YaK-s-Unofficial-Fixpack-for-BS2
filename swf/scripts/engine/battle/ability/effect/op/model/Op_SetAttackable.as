package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   
   public class Op_SetAttackable extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_SetAttackable",
         "properties":{"attackable":{"type":"boolean"}}
      };
       
      
      private var attackable:Boolean;
      
      public function Op_SetAttackable(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
         this.attackable = param1.params.attackable;
      }
      
      override public function execute() : EffectResult
      {
         if(target.attackable == this.attackable)
         {
            return EffectResult.FAIL;
         }
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
         if(effect.ability.fake || manager.faking)
         {
            return;
         }
         target.attackable = this.attackable;
      }
   }
}
