package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.core.util.Enum;
   
   public class Op_SetFacing extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_SetFacing",
         "properties":{"value":{"type":"string"}}
      };
       
      
      private var value:BattleFacing;
      
      public function Op_SetFacing(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
         this.value = Enum.parse(BattleFacing,param1.params.value) as BattleFacing;
      }
      
      override public function execute() : EffectResult
      {
         logger.info("Op_SetFacing " + target + " current=" + target.traversable + " next=" + this.value);
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
         if(fake || !target)
         {
            return;
         }
         target.facing = this.value;
      }
   }
}
