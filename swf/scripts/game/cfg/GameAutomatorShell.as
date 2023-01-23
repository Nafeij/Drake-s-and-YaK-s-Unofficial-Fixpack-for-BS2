package game.cfg
{
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.ShellCmdManager;
   
   public class GameAutomatorShell extends ShellCmdManager
   {
       
      
      public var config:GameConfig;
      
      public var automator:GameAutomator;
      
      public function GameAutomatorShell(param1:GameAutomator)
      {
         super(param1.logger,true);
         this.config = param1.config;
         this.automator = param1;
         this.addShellCmds();
      }
      
      public function addShellCmds() : void
      {
         this.add("run",this.shellFuncRun);
         this.add("stop",this.shellFuncStop);
         this.add("list",this.shellFuncList);
         this.add("where",this.shellFuncWhere);
      }
      
      private function shellFuncRun(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            logger.info("Usage: " + _loc2_[0] + " <programfile>");
         }
         this.config.context.appInfo.loadFileString(null,_loc2_[1]);
      }
      
      private function shellFuncStop(param1:CmdExec) : void
      {
         this.automator.stop();
      }
      
      private function shellFuncList(param1:CmdExec) : void
      {
         this.automator.list();
      }
      
      private function shellFuncWhere(param1:CmdExec) : void
      {
         this.automator.where();
      }
   }
}
