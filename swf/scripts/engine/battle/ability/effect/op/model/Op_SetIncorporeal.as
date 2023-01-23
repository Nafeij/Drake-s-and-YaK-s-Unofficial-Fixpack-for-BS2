package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   
   public class Op_SetIncorporeal extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_SetIncorporeal",
         "properties":{"value":{"type":"boolean"}}
      };
       
      
      private var value:Boolean;
      
      private var fadeMs:int;
      
      public function Op_SetIncorporeal(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
         this.value = param1.params.value;
      }
      
      override public function execute() : EffectResult
      {
         logger.info("Op_SetIncorporeal " + target + " current=" + target.traversable + " next=" + this.value);
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
         if(fake || !target)
         {
            return;
         }
         target.incorporeal = this.value;
         board.fsm.interact = null;
      }
   }
}
