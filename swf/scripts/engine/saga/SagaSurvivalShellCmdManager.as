package engine.saga
{
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.ShellCmdManager;
   import engine.core.logging.ILogger;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   
   public class SagaSurvivalShellCmdManager extends ShellCmdManager
   {
       
      
      public var saga:Saga;
      
      public function SagaSurvivalShellCmdManager(param1:ILogger, param2:Saga, param3:Boolean)
      {
         super(param1);
         this.saga = param2;
         this.cheat = true;
         add("start",this.shellFuncStart);
         add("recruit",this.shellFuncRecruit);
         if(param3)
         {
         }
      }
      
      private function shellFuncStart(param1:CmdExec) : void
      {
         this.saga.launchSagaByUrl("saga2s/saga2s.json.z",null,this.saga.difficulty,"saga2/saga2.json.z");
      }
      
      private function shellFuncRecruit(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            logger.info("Usage: recruit <id>");
            return;
         }
         var _loc3_:String = _loc2_[1];
         var _loc4_:IEntityListDef = this.saga.caravan._legend.roster;
         if(!_loc4_)
         {
            logger.info("No such roster member: " + _loc3_);
            return;
         }
         var _loc5_:IEntityDef = _loc4_.getEntityDefById(_loc3_);
         _loc5_.isSurvivalRecruited = true;
         _loc4_.sortEntities();
      }
   }
}
