package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.entity.model.BattleEntity;
   
   public class Op_SetAnimLayer extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_SetAnimLayer",
         "properties":{"layerId":{"type":"string"}}
      };
       
      
      public function Op_SetAnimLayer(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
      }
      
      override public function execute() : EffectResult
      {
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
         var _loc1_:BattleEntity = target as BattleEntity;
         var _loc2_:String = def.params.layerId;
         if(_loc1_.animController)
         {
            _loc1_.animController.layer = _loc2_;
         }
      }
   }
}
