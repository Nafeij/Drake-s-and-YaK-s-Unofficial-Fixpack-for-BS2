package engine.saga
{
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.ShellCmdManager;
   import engine.core.logging.ILogger;
   import engine.saga.happening.Happening;
   
   public class SagaHappeningShellCmdManager extends ShellCmdManager
   {
       
      
      public var saga:Saga;
      
      public function SagaHappeningShellCmdManager(param1:ILogger, param2:Saga, param3:Boolean)
      {
         super(param1);
         this.saga = param2;
         this.cheat = false;
         add("list",this.shellFuncList);
         if(param3)
         {
            add("next",this.shellFuncNext,true);
            add("end",this.shellFuncEnd,true);
         }
      }
      
      private function shellFuncList(param1:CmdExec) : void
      {
         var _loc2_:Happening = null;
         for each(_loc2_ in this.saga.happenings)
         {
            _loc2_.debugPrintLog(logger);
         }
      }
      
      private function shellFuncNext(param1:CmdExec) : void
      {
         var _loc4_:Happening = null;
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            logger.info("Usage: next <happening id>");
            return;
         }
         var _loc3_:String = _loc2_[1];
         for each(_loc4_ in this.saga.happenings)
         {
            if(_loc4_.def.id == _loc3_)
            {
               if(!_loc4_.action)
               {
                  logger.info("No action current on happening?!");
               }
               else
               {
                  logger.info("FORCE-ENDING action " + _loc4_.action);
                  _loc4_.action.end(true);
               }
               return;
            }
         }
         logger.info("No such happening active [" + _loc3_ + "]");
      }
      
      private function shellFuncEnd(param1:CmdExec) : void
      {
         var _loc4_:Happening = null;
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            logger.info("Usage: end <happening id>");
            return;
         }
         var _loc3_:String = _loc2_[1];
         for each(_loc4_ in this.saga.happenings)
         {
            if(_loc4_.def.id == _loc3_)
            {
               logger.info("FORCE-ENDING happening" + _loc4_);
               _loc4_.end(true);
               return;
            }
         }
         logger.info("No such happening active [" + _loc3_ + "]");
      }
   }
}
