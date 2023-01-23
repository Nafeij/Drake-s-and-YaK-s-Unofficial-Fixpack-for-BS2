package engine.saga
{
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.ShellCmdManager;
   import engine.core.logging.ILogger;
   import engine.def.BooleanVars;
   import tbs.srv.data.LeaderboardData;
   
   public class SagaLbShellCmdManager extends ShellCmdManager
   {
       
      
      public var saga:Saga;
      
      public function SagaLbShellCmdManager(param1:ILogger, param2:Saga, param3:Boolean)
      {
         super(param1);
         this.saga = param2;
         if(param3)
         {
            add("fetch",this.shellFuncLbFetch);
            add("upload",this.shellFuncLbUpload,true);
            add("peek",this.shellFuncLbPeek);
            add("view",this.shellFuncLbView);
         }
      }
      
      private function shellFuncLbFetch(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            logger.info("Usage: " + _loc2_[0] + " <board id>");
            return;
         }
         var _loc3_:String = _loc2_[1];
         SagaLeaderboards.fetchLeaderboard(_loc3_);
      }
      
      private function shellFuncLbUpload(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 3)
         {
            logger.info("Usage: " + _loc2_[0] + " <board id> <score> [force]");
            return;
         }
         var _loc3_:String = _loc2_[1];
         var _loc4_:int = int(_loc2_[2]);
         var _loc5_:Boolean = false;
         if(_loc2_.length > 3)
         {
            _loc5_ = BooleanVars.parse(_loc2_[3]);
         }
         SagaLeaderboards.uploadLeaderboardScore(_loc3_,_loc4_,_loc5_);
      }
      
      private function shellFuncLbPeek(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         var _loc3_:String = _loc2_[1];
         var _loc4_:LeaderboardData = SagaLeaderboards.getLeaderboard_friends(_loc3_);
         var _loc5_:LeaderboardData = SagaLeaderboards.getLeaderboard_global(_loc3_);
         logger.info("FRIENDS:\n" + (!!_loc4_ ? _loc4_.getDebugString() : "NULL"));
         logger.info("GLOBAL:\n" + (!!_loc5_ ? _loc5_.getDebugString() : "NULL"));
      }
      
      private function shellFuncLbView(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            logger.info("Usage: " + _loc2_[0] + " <board id> [<allTime|today|week> [<friends only>]]");
            return;
         }
         var _loc3_:String = _loc2_[1];
         var _loc4_:String = "allTime";
         if(_loc2_.length > 2)
         {
            _loc4_ = _loc2_[2];
         }
         var _loc5_:Boolean = false;
         if(_loc2_.length > 3)
         {
            _loc5_ = BooleanVars.parse(_loc2_[3]);
         }
         SagaLeaderboards.showPlatformLeaderboard(_loc3_,_loc4_,_loc5_);
      }
   }
}
