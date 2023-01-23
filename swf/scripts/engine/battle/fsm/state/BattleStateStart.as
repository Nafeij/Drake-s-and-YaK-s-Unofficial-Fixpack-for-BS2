package engine.battle.fsm.state
{
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.sim.IBattleParty;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.logging.ILogger;
   import engine.saga.Saga;
   
   public class BattleStateStart extends BaseBattleState
   {
       
      
      public function BattleStateStart(param1:StateData, param2:BattleFsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      override protected function handleEnteredState() : void
      {
         var _loc1_:IBattleBoard = null;
         var _loc5_:IBattleParty = null;
         super.handleEnteredState();
         _loc1_ = battleFsm.board;
         var _loc2_:IBattleParty = _loc1_.getPartyById(battleFsm.config.startPartyId);
         if(!_loc2_)
         {
            battleFsm.addErrorMsg("Could not find start party: " + battleFsm.config.startPartyId);
            phase = StatePhase.FAILED;
            return;
         }
         battleFsm.order.addParty(_loc2_);
         var _loc3_:int = 0;
         while(_loc3_ < _loc1_.numParties)
         {
            _loc5_ = _loc1_.getParty(_loc3_);
            if(_loc5_ != _loc2_)
            {
               battleFsm.order.addParty(_loc5_);
            }
            _loc3_++;
         }
         battleFsm.order.getAllParticipants(battleFsm.participants);
         if(battleFsm.participants.length <= 0)
         {
            battleFsm.addErrorMsg("No eligible party members for battle");
            phase = StatePhase.FAILED;
            return;
         }
         phase = StatePhase.COMPLETED;
         _loc1_.boardSetup = true;
         var _loc4_:Saga = Saga.instance;
         if(_loc4_)
         {
            _loc4_.triggerBattleStart();
         }
      }
   }
}
