package engine.saga.action
{
   import engine.battle.board.model.BattlePartyType;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.fsm.BattleFsmConfig;
   import engine.battle.fsm.IBattleFsm;
   import engine.battle.fsm.state.BattleStateTurnAi;
   import engine.battle.fsm.state.BattleStateTurnLocal;
   import engine.saga.Saga;
   
   public class Action_BattleAiEnable extends Action
   {
       
      
      public function Action_BattleAiEnable(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:IBattleBoard = null;
         var _loc2_:IBattleFsm = null;
         var _loc3_:BattlePartyType = null;
         BattleFsmConfig.sceneEnableAi = def.varvalue != 0;
         if(BattleFsmConfig.sceneEnableAi)
         {
            _loc1_ = saga.getBattleBoard() as IBattleBoard;
            if(!_loc1_ || !_loc1_.fsm || !_loc1_.fsm.activeEntity || !_loc1_.fsm.activeEntity.party)
            {
               end();
               return;
            }
            _loc2_ = _loc1_.fsm;
            _loc3_ = _loc2_.activeEntity.party.type;
            if(_loc3_ == BattlePartyType.AI && _loc2_.current is BattleStateTurnLocal)
            {
               _loc2_.transitionTo(BattleStateTurnAi,_loc2_.current.data);
            }
         }
         end();
      }
   }
}
