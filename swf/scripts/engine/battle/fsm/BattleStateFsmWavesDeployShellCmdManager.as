package engine.battle.fsm
{
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.fsm.state.BattleStateWaveRedeploy_Assemble;
   import engine.battle.fsm.state.BattleStateWaveRedeploy_Prepare;
   import engine.battle.wave.BattleWaves;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.ShellCmdManager;
   
   public class BattleStateFsmWavesDeployShellCmdManager extends ShellCmdManager
   {
       
      
      public var fsm:IBattleFsm;
      
      public var board:IBattleBoard;
      
      public var waves:BattleWaves;
      
      public function BattleStateFsmWavesDeployShellCmdManager(param1:IBattleFsm)
      {
         this.fsm = param1;
         this.board = param1.getBoard();
         this.waves = this.board.waves;
         super(param1.getLogger());
         this.addShellCmds();
      }
      
      override public function cleanup() : void
      {
         super.cleanup();
         this.fsm = null;
         this.board = null;
         this.waves = null;
      }
      
      public function addShellCmds() : void
      {
         if(!this.waves)
         {
            return;
         }
         this.add("add",this.shellFuncDeployAdd);
         this.add("remove",this.shellFuncDeployRemove);
         this.add("fight",this.shellFuncDeployContinue);
         this.add("flee",this.shellFuncDeployRunaway);
         this.add("ready",this.shellFuncDeployReady);
      }
      
      private function shellFuncDeployAdd(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length != 3)
         {
            logger.info("Usage: <id> <slotnum>");
            return;
         }
         var _loc3_:String = String(_loc2_[1]);
         var _loc4_:int = int(_loc2_[2]);
         this.board.redeploy.insertPartyMember(_loc3_,_loc4_);
      }
      
      private function shellFuncDeployRemove(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length != 2)
         {
            logger.info("Usage: <id>");
            return;
         }
         var _loc3_:String = String(_loc2_[1]);
         this.board.redeploy.removePartyMemberById(_loc3_);
      }
      
      private function shellFuncDeployContinue(param1:CmdExec) : void
      {
         this._deployEnd(true);
      }
      
      private function shellFuncDeployRunaway(param1:CmdExec) : void
      {
         this._deployEnd(false);
      }
      
      private function _deployEnd(param1:Boolean) : void
      {
         if(!this.waves)
         {
            return;
         }
         var _loc2_:BattleStateWaveRedeploy_Prepare = this.fsm.current as BattleStateWaveRedeploy_Prepare;
         if(!_loc2_)
         {
            logger.info(!!("Unable to " + param1) ? "fight" : "flee" + " from state " + this.fsm);
            return;
         }
         if(param1)
         {
            _loc2_.chooseToFight();
         }
         else
         {
            _loc2_.chooseToFlee();
         }
      }
      
      private function shellFuncDeployReady(param1:CmdExec) : void
      {
         var _loc2_:BattleStateWaveRedeploy_Assemble = this.fsm.current as BattleStateWaveRedeploy_Assemble;
         if(!_loc2_)
         {
            logger.info("Unable to end deployment from state " + this.fsm);
            return;
         }
         _loc2_.redeployComplete();
      }
   }
}
