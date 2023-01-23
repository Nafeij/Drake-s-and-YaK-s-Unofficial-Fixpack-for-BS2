package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   
   public class Op_SetAlive extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_SetAlive",
         "properties":{"alive":{"type":"boolean"}}
      };
       
      
      private var _alive:Boolean;
      
      public function Op_SetAlive(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
         this._alive = param1.params.alive;
      }
      
      override public function execute() : EffectResult
      {
         if(!target)
         {
            return EffectResult.FAIL;
         }
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
         if(!target)
         {
            return;
         }
         target.alive = this._alive;
      }
   }
}
