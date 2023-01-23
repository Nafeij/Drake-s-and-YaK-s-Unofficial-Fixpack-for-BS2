package engine.saga
{
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.fsm.IBattleTurnOrder;
   
   public class NextTurnVarsHelper
   {
       
      
      public function NextTurnVarsHelper()
      {
         super();
      }
      
      public static function setNextTurnBattleVars(param1:ISaga, param2:IBattleTurnOrder) : void
      {
         if(!param1)
         {
            return;
         }
         var _loc3_:IBattleEntity = param2.activeEntity;
         if(!_loc3_)
         {
            return;
         }
         param1.setVar(SagaVar.VAR_BATTLE_UNIT_NEXT_ID,_loc3_.id);
         param1.setVar(SagaVar.VAR_BATTLE_UNIT_NEXT_ENTITY_ID,_loc3_.def.id);
         param1.setVar(SagaVar.VAR_BATTLE_UNIT_NEXT_CLASS_ID,_loc3_.def.entityClass.id);
         param1.setVar(SagaVar.VAR_BATTLE_UNIT_NEXT_RACE,_loc3_.def.entityClass.race);
         param1.setVar(SagaVar.VAR_BATTLE_UNIT_NEXT_PLAYER,_loc3_.isPlayer);
         param1.setVar(SagaVar.VAR_BATTLE_UNIT_NEXT_ENEMY,_loc3_.isEnemy);
         var _loc4_:String = !!_loc3_.attractor ? _loc3_.attractor.def.id : "";
         param1.setVar(SagaVar.VAR_BATTLE_UNIT_NEXT_ATTRACTOR,_loc4_);
         param1.setVar(SagaVar.VAR_BATTLE_UNIT_NEXT_VISIBLE,_loc3_.visibleToPlayer);
      }
      
      public static function removeNextTurnBattleVars(param1:ISaga) : void
      {
         if(!param1)
         {
            return;
         }
         param1.removeVar(SagaVar.VAR_BATTLE_UNIT_ID);
         param1.removeVar(SagaVar.VAR_BATTLE_UNIT_NEXT_ENTITY_ID);
         param1.removeVar(SagaVar.VAR_BATTLE_UNIT_NEXT_CLASS_ID);
         param1.removeVar(SagaVar.VAR_BATTLE_UNIT_NEXT_RACE);
         param1.removeVar(SagaVar.VAR_BATTLE_UNIT_NEXT_PLAYER);
         param1.removeVar(SagaVar.VAR_BATTLE_UNIT_NEXT_ENEMY);
         param1.removeVar(SagaVar.VAR_BATTLE_UNIT_NEXT_ATTRACTOR);
         param1.removeVar(SagaVar.VAR_BATTLE_UNIT_NEXT_VISIBLE);
      }
   }
}
