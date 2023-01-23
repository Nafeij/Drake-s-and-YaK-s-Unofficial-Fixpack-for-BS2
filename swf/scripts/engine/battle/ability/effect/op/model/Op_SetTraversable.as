package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   
   public class Op_SetTraversable extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_SetTraversable",
         "properties":{"traversable":{"type":"boolean"}}
      };
       
      
      private var traversable:Boolean;
      
      private var fadeMs:int;
      
      public function Op_SetTraversable(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
         this.traversable = param1.params.traversable;
      }
      
      override public function execute() : EffectResult
      {
         logger.info("Op_SetTraversable " + target + " current=" + target.traversable + " next=" + this.traversable);
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
         if(fake || !target)
         {
            return;
         }
         target.traversable = this.traversable;
      }
   }
}
