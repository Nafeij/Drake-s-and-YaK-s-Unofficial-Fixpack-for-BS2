package engine.battle.fsm.state
{
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.wave.BattleWaves;
   import engine.core.fsm.StateData;
   import engine.core.logging.ILogger;
   
   public class BattleStateWave_Base extends BaseBattleState
   {
       
      
      public var board:IBattleBoard;
      
      public var waves:BattleWaves;
      
      public function BattleStateWave_Base(param1:StateData, param2:BattleFsm, param3:ILogger)
      {
         super(param1,param2,param3);
         this.board = battleFsm.board;
         this.waves = this.board.waves;
      }
   }
}
