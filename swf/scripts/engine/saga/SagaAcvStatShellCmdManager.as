package engine.saga
{
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.ShellCmdManager;
   import engine.core.logging.ILogger;
   import engine.saga.vars.VariableDef;
   
   public class SagaAcvStatShellCmdManager extends ShellCmdManager
   {
       
      
      public var saga:Saga;
      
      public function SagaAcvStatShellCmdManager(param1:ILogger, param2:Saga, param3:Boolean)
      {
         super(param1);
         this.saga = param2;
         if(param3)
         {
            add("get",this.shellFuncGet);
            add("set",this.shellFuncSet,true);
            add("list",this.shellFuncList);
            add("clear",this.shellFuncClear,true);
         }
      }
      
      private function shellFuncList(param1:CmdExec) : void
      {
         var _loc2_:VariableDef = null;
         var _loc3_:String = null;
         var _loc4_:Number = NaN;
         if(!this.saga)
         {
            return;
         }
         for each(_loc2_ in this.saga.def.variables)
         {
            if(_loc2_.achievement_stat)
            {
               _loc3_ = _loc2_.achievement_stat;
               _loc4_ = SagaAchievements.getStat(_loc3_);
               logger.info(_loc3_ + "=" + _loc4_);
            }
         }
      }
      
      private function shellFuncClear(param1:CmdExec) : void
      {
         var _loc2_:VariableDef = null;
         var _loc3_:String = null;
         if(!this.saga)
         {
            return;
         }
         if(!this.saga.appinfo.isDebugger)
         {
            logger.info("Only in debugger");
            return;
         }
         for each(_loc2_ in this.saga.def.variables)
         {
            if(_loc2_.achievement_stat)
            {
               _loc3_ = _loc2_.achievement_stat;
               this.saga.setVar(_loc2_.name,0);
               SagaAchievements.setStat(_loc3_,0);
            }
         }
      }
      
      private function shellFuncGet(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            logger.info("Usage: " + _loc2_[0] + " <id>");
            return;
         }
         var _loc3_:String = String(_loc2_[1]);
         var _loc4_:Number = SagaAchievements.getStat(_loc3_);
         logger.info(_loc3_ + "=" + _loc4_);
      }
      
      private function shellFuncSet(param1:CmdExec) : void
      {
         if(!this.saga.appinfo.isDebugger)
         {
            logger.info("Only in debugger");
            return;
         }
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 3 || !_loc2_[2])
         {
            logger.info("Usage: " + _loc2_[0] + " <id> <value>");
            return;
         }
         var _loc3_:String = String(_loc2_[1]);
         var _loc4_:Number = Number(_loc2_[2]);
         SagaAchievements.setStat(_loc3_,_loc4_);
      }
   }
}
