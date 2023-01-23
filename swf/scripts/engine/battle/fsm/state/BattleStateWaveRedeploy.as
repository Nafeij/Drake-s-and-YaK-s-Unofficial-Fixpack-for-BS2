package engine.battle.fsm.state
{
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.IBattleAbilityManager;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.sim.IBattleParty;
   import engine.battle.wave.BattleWaves;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.logging.ILogger;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class BattleStateWaveRedeploy extends BattleStateWave_Base
   {
       
      
      private var timer:Timer = null;
      
      public function BattleStateWaveRedeploy(param1:StateData, param2:BattleFsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      override protected function handleEnteredState() : void
      {
         var _loc7_:IBattleEntity = null;
         var _loc8_:BattleAbility = null;
         super.handleEnteredState();
         var _loc1_:IBattleBoard = battleFsm.board;
         var _loc2_:BattleWaves = _loc1_.waves;
         var _loc3_:IBattleParty = _loc1_.getPartyById("0");
         var _loc4_:IBattleAbilityManager = _loc1_.abilityManager;
         var _loc5_:IBattleAbilityDef = _loc4_.getFactory.fetchIBattleAbilityDef("abl_rest");
         var _loc6_:int = 0;
         while(_loc6_ < _loc3_.numMembers)
         {
            _loc7_ = _loc3_.getMember(_loc6_);
            _loc8_ = new BattleAbility(_loc7_,_loc5_,_loc4_);
            _loc8_.execute(null);
            _loc6_++;
         }
         this.cleanupTimer();
         this.timer = new Timer(400);
         this.timer.addEventListener(TimerEvent.TIMER,this.stateComplete);
         this.timer.start();
      }
      
      private function stateComplete(param1:TimerEvent) : void
      {
         this.cleanupTimer();
         phase = StatePhase.COMPLETED;
      }
      
      private function cleanupTimer() : void
      {
         if(this.timer)
         {
            this.timer.stop();
            this.timer.removeEventListener(TimerEvent.TIMER,this.stateComplete);
            this.timer = null;
         }
      }
   }
}
