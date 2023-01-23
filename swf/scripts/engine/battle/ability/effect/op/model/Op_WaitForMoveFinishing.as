package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.board.model.IBattleEntityMobility;
   import engine.battle.entity.model.BattleEntityEvent;
   
   public class Op_WaitForMoveFinishing extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_WaitForMoveFinishing",
         "properties":{"ability":{"type":"string"}}
      };
       
      
      private var abilityDef:BattleAbilityDef;
      
      public function Op_WaitForMoveFinishing(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
         var _loc3_:String = param1.params.ability;
         this.abilityDef = manager.factory.fetchBattleAbilityDef(_loc3_);
         if(!this.abilityDef)
         {
            manager.logger.error("Op_WaitForMoveFinishing " + this + " invalid ability [" + _loc3_ + "]");
         }
      }
      
      override public function execute() : EffectResult
      {
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
         board.addEventListener(BattleEntityEvent.MOVE_FINISHING,this.moveFinishingHandler);
      }
      
      override public function remove() : void
      {
         board.removeEventListener(BattleEntityEvent.MOVE_FINISHING,this.moveFinishingHandler);
      }
      
      private function moveFinishingHandler(param1:BattleEntityEvent) : void
      {
         if(!board || !board.fsm.turn)
         {
            return;
         }
         if(param1.entity != target)
         {
            return;
         }
         if(!this.abilityDef || !target.alive || effect.removed)
         {
            return;
         }
         var _loc2_:IBattleEntityMobility = target.mobility;
         if(!_loc2_ || _loc2_.forcedMove)
         {
            return;
         }
         var _loc3_:BattleAbility = new BattleAbility(target,this.abilityDef,manager);
         _loc3_.targetSet.setTarget(target);
         effect.handleOpUsed(this);
         _loc3_.execute(null);
      }
   }
}
