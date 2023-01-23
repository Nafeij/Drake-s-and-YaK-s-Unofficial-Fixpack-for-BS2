package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.fsm.IBattleFsm;
   
   public class Op_Initiative extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_Initiative",
         "properties":{
            "delta":{"type":"number"},
            "front":{"type":"boolean"},
            "back":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      public function Op_Initiative(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
      }
      
      override public function execute() : EffectResult
      {
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
         var _loc2_:int = 0;
         var _loc1_:IBattleFsm = board.fsm;
         if(def.params.front)
         {
            _loc1_.order.bumpToNext(target);
         }
         else if(def.params.back)
         {
            _loc1_.order.moveToLast(target);
         }
         else
         {
            _loc2_ = int(def.params.delta);
         }
      }
   }
}
