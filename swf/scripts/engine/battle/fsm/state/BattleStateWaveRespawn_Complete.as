package engine.battle.fsm.state
{
   import engine.battle.ability.effect.model.EffectTag;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleFsmEvent;
   import engine.battle.sim.IBattleParty;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.logging.ILogger;
   import engine.saga.Saga;
   
   public class BattleStateWaveRespawn_Complete extends BaseBattleState
   {
       
      
      private var _board:IBattleBoard = null;
      
      public function BattleStateWaveRespawn_Complete(param1:StateData, param2:BattleFsm, param3:ILogger)
      {
         super(param1,param2,param3);
         this._board = param2.board;
      }
      
      override protected function handleEnteredState() : void
      {
         var _loc4_:int = 0;
         var _loc5_:IBattleParty = null;
         var _loc6_:IBattleEntity = null;
         super.handleEnteredState();
         phase = StatePhase.COMPLETED;
         var _loc1_:Saga = Saga.instance;
         if(_loc1_)
         {
            _loc1_.triggerBattleStart();
         }
         var _loc2_:Vector.<IBattleEntity> = new Vector.<IBattleEntity>();
         var _loc3_:int = 0;
         while(_loc3_ < this._board.numParties)
         {
            _loc5_ = this._board.getParty(_loc3_);
            _loc5_.getAllMembers(_loc2_);
            _loc3_++;
         }
         while(_loc4_ < _loc2_.length)
         {
            _loc6_ = _loc2_[_loc4_];
            if(!(!_loc6_ || !_loc6_.alive || !this._board.triggers))
            {
               if(_loc6_.effects.hasTag(EffectTag.GHOSTED))
               {
                  this._board.triggers.checkTriggers(_loc6_,_loc6_.rect,true);
               }
            }
            _loc4_++;
         }
         fsm.dispatchEvent(new BattleFsmEvent(BattleFsmEvent.WAVE_RESPAWN_COMPLETED));
      }
   }
}
