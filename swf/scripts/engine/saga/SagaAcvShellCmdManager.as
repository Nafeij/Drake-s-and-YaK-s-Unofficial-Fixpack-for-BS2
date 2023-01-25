package engine.saga
{
   import engine.achievement.AchievementDef;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.ShellCmdManager;
   import engine.core.logging.ILogger;
   
   public class SagaAcvShellCmdManager extends ShellCmdManager
   {
       
      
      public var saga:Saga;
      
      public var stat:SagaAcvStatShellCmdManager;
      
      public function SagaAcvShellCmdManager(param1:ILogger, param2:Saga, param3:Boolean)
      {
         super(param1);
         this.saga = param2;
         if(param3)
         {
            add("unlocked",this.shellFuncAchievementUnlocked);
            add("locked",this.shellFuncAchievementLocked);
            add("set",this.shellFuncAchievementSet,true);
            add("clear",this.shellFuncAchievementClear,true);
            add("get",this.shellFuncAchievementGet);
            this.stat = new SagaAcvStatShellCmdManager(param1,param2,param3);
            addShell("stat",this.stat);
         }
      }
      
      private function shellFuncAchievementUnlocked(param1:CmdExec) : void
      {
         var _loc2_:String = null;
         logger.info("Unlocked:");
         for each(_loc2_ in SagaAchievements.unlocked)
         {
            logger.info("    " + _loc2_);
         }
      }
      
      private function shellFuncAchievementLocked(param1:CmdExec) : void
      {
         var _loc2_:AchievementDef = null;
         logger.info("Locked:");
         if(!this.saga.def.achievements)
         {
            return;
         }
         for each(_loc2_ in this.saga.def.achievements.defs)
         {
            if(!SagaAchievements.isUnlocked(_loc2_.id))
            {
               logger.info("    " + _loc2_.id);
            }
         }
      }
      
      private function shellFuncAchievementSet(param1:CmdExec) : void
      {
         var _loc4_:Boolean = false;
         var _loc5_:String = null;
         if(!this.saga.appinfo.isDebugger)
         {
            logger.info("Only in debugger");
            if(!Saga.QAACV)
            {
               return;
            }
            logger.info("Allowing via QAACV");
         }
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            logger.info("Usage: " + _loc2_[0] + " <id>");
            return;
         }
         var _loc3_:String = String(_loc2_[1]);
         if(_loc2_.length > 2)
         {
            _loc5_ = String(_loc2_[2]);
            _loc4_ = _loc5_ != "0" && _loc5_ != "false";
         }
         SagaAchievements.unlockAchievementById(_loc3_,0,_loc4_);
      }
      
      private function shellFuncAchievementClear(param1:CmdExec) : void
      {
         var _loc4_:AchievementDef = null;
         if(!this.saga.appinfo.isDebugger)
         {
            logger.info("Only in debugger");
            if(!Saga.QAACV)
            {
               return;
            }
            logger.info("Allowing via QAACV");
         }
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            logger.info("Usage: " + _loc2_[0] + " <id>");
            return;
         }
         var _loc3_:String = String(_loc2_[1]);
         if(_loc3_ == "*")
         {
            for each(_loc4_ in this.saga.def.achievements.defs)
            {
               SagaAchievements.clearAchievementById(_loc4_.id);
            }
         }
         else
         {
            SagaAchievements.clearAchievementById(_loc3_);
         }
      }
      
      private function shellFuncAchievementGet(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            logger.info("Usage: " + _loc2_[0] + " <id>");
            return;
         }
         var _loc3_:String = String(_loc2_[1]);
         var _loc4_:Boolean = SagaAchievements.isUnlocked(_loc3_);
         logger.info("saga=" + _loc4_);
      }
   }
}
