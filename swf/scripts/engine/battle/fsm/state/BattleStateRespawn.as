package engine.battle.fsm.state
{
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleStateDataEnum;
   import engine.battle.sim.IBattleParty;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.logging.ILogger;
   import engine.saga.Saga;
   
   public class BattleStateRespawn extends BaseBattleState
   {
       
      
      public function BattleStateRespawn(param1:StateData, param2:BattleFsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      override protected function handleEnteredState() : void
      {
         var _loc1_:BattleBoard = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc7_:Saga = null;
         var _loc8_:IBattleParty = null;
         var _loc9_:int = 0;
         var _loc10_:IBattleEntity = null;
         super.handleEnteredState();
         data.removeValue(BattleStateDataEnum.FINISHED);
         _loc1_ = battleFsm.board as BattleBoard;
         _loc1_.boardSetup = false;
         var _loc2_:int = data.getValue(BattleStateDataEnum.BATTLE_RESPAWN_QUOTA);
         if(!_loc2_)
         {
            _loc2_ = _loc1_._spawn._bucket_quota;
         }
         _loc2_ = Math.max(1,_loc2_);
         _loc1_._spawn._bucket_quota = _loc2_;
         var _loc5_:String = _loc1_._spawn._bucket;
         _loc3_ = data.getValue(BattleStateDataEnum.BATTLE_RESPAWN_TAG);
         _loc4_ = data.getValue(BattleStateDataEnum.BATTLE_RESPAWN_DEPLOYMENT);
         var _loc6_:String = data.getValue(BattleStateDataEnum.BATTLE_RESPAWN_BUCKET);
         if(_loc6_)
         {
            _loc5_ = _loc6_;
         }
         _loc1_._spawn._bucket = _loc5_;
         _loc1_.spawn(_loc4_,_loc3_);
         _loc7_ = Saga.instance;
         for each(_loc8_ in _loc1_.parties)
         {
            if(!(!_loc8_.isEnemy || _loc8_.team == "prop" || _loc8_.team == null))
            {
               battleFsm.order.removeParty(_loc8_);
               if(_loc8_.numAlive)
               {
                  battleFsm.order.addParty(_loc8_);
                  _loc9_ = 0;
                  while(_loc9_ < _loc8_.numMembers)
                  {
                     _loc10_ = _loc8_.getMember(_loc9_);
                     if(battleFsm.participants.indexOf(_loc10_) < 0)
                     {
                        battleFsm.participants.push(_loc10_);
                        if(_loc7_)
                        {
                           _loc7_.applyUnitDifficultyBonuses(_loc10_);
                        }
                     }
                     _loc9_++;
                  }
               }
            }
         }
         battleFsm.order.resetTurnOrder();
         phase = StatePhase.COMPLETED;
         _loc1_.boardSetup = true;
      }
   }
}
