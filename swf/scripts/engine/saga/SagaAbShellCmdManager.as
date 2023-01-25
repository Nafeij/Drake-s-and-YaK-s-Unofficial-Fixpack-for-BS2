package engine.saga
{
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.ShellCmdManager;
   import engine.core.logging.ILogger;
   
   public class SagaAbShellCmdManager extends ShellCmdManager
   {
       
      
      public var saga:Saga;
      
      public function SagaAbShellCmdManager(param1:ILogger, param2:Saga, param3:Boolean)
      {
         super(param1);
         this.saga = param2;
         if(param3)
         {
            add("list",this.shellFuncAbList);
            add("create",this.shellFuncAbCreate);
            add("remove",this.shellFuncAbRemove);
            add("manifest",this.shellFuncAbManifest);
         }
      }
      
      private function shellFuncAbList(param1:CmdExec) : void
      {
         var _loc3_:String = null;
         var _loc4_:SagaAssetBundle = null;
         var _loc2_:SagaAssetBundles = this.saga.sagaAssetBundles;
         for(_loc3_ in _loc2_.bundles)
         {
            _loc4_ = _loc2_.bundles[_loc3_];
            logger.info(" > " + _loc4_);
         }
      }
      
      private function shellFuncAbCreate(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            logger.info("Usage: " + _loc2_[0] + " <id> (. for auto id)");
            return;
         }
         var _loc3_:String = String(_loc2_[1]);
         if(_loc3_ == ".")
         {
            _loc3_ = null;
         }
         var _loc4_:SagaAssetBundles = this.saga.sagaAssetBundles;
         var _loc5_:SagaAssetBundle = _loc4_.createSagaAssetBundle(_loc3_);
         logger.info("added: \n" + _loc5_);
      }
      
      private function shellFuncAbRemove(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            logger.info("Usage: " + _loc2_[0] + " <id>");
            return;
         }
         var _loc3_:String = String(_loc2_[1]);
         var _loc4_:SagaAssetBundles = this.saga.sagaAssetBundles;
         _loc4_.removeSagaAssetBundle(_loc3_);
      }
      
      private function shellFuncAbManifest(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 3)
         {
            logger.info("Usage: " + _loc2_[0] + " <id> <url>");
            return;
         }
         var _loc3_:String = String(_loc2_[1]);
         var _loc4_:String = String(_loc2_[2]);
         var _loc5_:SagaAssetBundles = this.saga.sagaAssetBundles;
         var _loc6_:SagaAssetBundle = _loc5_.getSagaAssetBundle(_loc3_);
         if(!_loc6_)
         {
            logger.error("No such bundle [" + _loc3_ + "]");
            return;
         }
         _loc6_.loadManifest(_loc4_);
      }
   }
}
