package engine.battle.fsm.state
{
   import engine.battle.fsm.BattleFinishedData;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleRenownAwardType;
   import engine.battle.fsm.BattleStateDataEnum;
   import engine.core.fsm.StateData;
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.saga.ISaga;
   import engine.saga.SagaVar;
   
   public class BattleStateFinished extends BaseBattleState
   {
       
      
      public var finishedData:BattleFinishedData;
      
      public function BattleStateFinished(param1:StateData, param2:BattleFsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      override protected function handleEnteredState() : void
      {
         var _loc1_:ISaga = null;
         var _loc2_:int = 0;
         var _loc3_:BattleRenownAwardType = null;
         var _loc4_:int = 0;
         this.finishedData = data.getValue(BattleStateDataEnum.FINISHED);
         if(!this.finishedData)
         {
            logger.info("BattleStateFinished finished but no finishedData!");
         }
         else
         {
            _loc1_ = battleFsm.board.getSaga();
            if(_loc1_)
            {
               if(this.finishedData.victoriousTeam == "0")
               {
                  _loc1_.setVar(SagaVar.VAR_BATTLE_VICTORY,true);
               }
               else
               {
                  _loc1_.setVar(SagaVar.VAR_BATTLE_VICTORY,false);
               }
            }
            _loc2_ = this.finishedData.getReward(battleFsm.localBattleOrder).total_renown;
            logger.info("BattleStateFinished victoriousTeam=" + this.finishedData.victoriousTeam + ", total_renown=" + _loc2_);
            for each(_loc3_ in Enum.getVector(BattleRenownAwardType))
            {
               _loc4_ = this.finishedData.getAward(battleFsm.localBattleOrder,_loc3_);
               if(_loc4_ != 0)
               {
               }
            }
         }
      }
   }
}
