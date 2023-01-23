package engine.battle.fsm
{
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.wave.BattleWaves;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.ShellCmdManager;
   
   public class BattleFsmWavesShellCmdManager extends ShellCmdManager
   {
       
      
      public var fsm:IBattleFsm;
      
      public var board:IBattleBoard;
      
      public var waves:BattleWaves;
      
      public var shell_deploy:BattleStateFsmWavesDeployShellCmdManager;
      
      public function BattleFsmWavesShellCmdManager(param1:IBattleFsm)
      {
         this.fsm = param1;
         this.board = param1.getBoard();
         this.waves = this.board.waves;
         super(param1.getLogger());
         this.addShellCmds();
      }
      
      override public function cleanup() : void
      {
         this.shell_deploy.cleanup();
         this.fsm = null;
         this.board = null;
         this.waves = null;
         super.cleanup();
      }
      
      public function addShellCmds() : void
      {
         if(!this.waves)
         {
            return;
         }
         this.add("status",this.shellFuncStatus);
         this.add("advance",this.shellFuncAdvanceWave);
         this.shell_deploy = new BattleStateFsmWavesDeployShellCmdManager(this.fsm);
         this.addShell("deploy",this.shell_deploy);
      }
      
      private function shellFuncStatus(param1:CmdExec) : void
      {
         if(!this.waves)
         {
            return;
         }
         logger.info(this.waves.getDebugString());
      }
      
      private function shellFuncAdvanceWave(param1:CmdExec) : void
      {
         if(!this.waves)
         {
            return;
         }
         if(!this.waves.wave)
         {
            return;
         }
         this.waves.advanceAll();
      }
   }
}
