package game.cfg
{
   import engine.core.analytic.Ga;
   import engine.core.analytic.GaConfig;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.ShellCmdManager;
   
   public class GaShellCmdManager extends ShellCmdManager
   {
       
      
      private var config:GameConfig;
      
      public function GaShellCmdManager(param1:GameConfig)
      {
         super(param1.logger);
         this.config = param1;
         add("info",this.shellFuncInfo);
         add("optstate",this.shellFuncOptState);
      }
      
      private function shellFuncInfo(param1:CmdExec) : void
      {
         logger.info("GaConfig:\n" + GaConfig.getDebugString());
         logger.info("Ga:\n" + Ga.getDebugString());
      }
      
      private function shellFuncOptState(param1:CmdExec) : void
      {
         var _loc2_:String = null;
         var _loc3_:Array = param1.param;
         if(_loc3_.length > 1)
         {
            _loc2_ = String(_loc3_[1]);
         }
         if(_loc2_)
         {
            GaConfig.optStateFromString(_loc2_);
         }
         logger.info("GaConfig.optState=" + GaConfig.optState);
      }
   }
}
