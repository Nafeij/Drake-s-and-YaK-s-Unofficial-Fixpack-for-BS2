package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.fsm.IBattleFsm;
   
   public class Op_Pillage extends Op
   {
       
      
      public function Op_Pillage(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
      }
      
      override public function execute() : EffectResult
      {
         var _loc1_:IBattleFsm = target.board.fsm;
         if(!_loc1_ || !_loc1_.order || _loc1_.order.pillage)
         {
            return EffectResult.FAIL;
         }
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
         var _loc1_:IBattleFsm = target.board.fsm;
         if(!_loc1_ || !_loc1_.order || _loc1_.order.pillage)
         {
            return;
         }
         _loc1_.order.commencePillaging(true,true);
      }
   }
}
