package game.cfg
{
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.ShellCmdManager;
   import engine.core.util.StringUtil;
   import engine.entity.def.IAbilityAssetBundleManager;
   import engine.entity.def.IAssetBundleManager;
   import engine.entity.def.IEntityAssetBundleManager;
   
   public class BundleShellCmdManager extends ShellCmdManager
   {
       
      
      private var config:GameConfig;
      
      public function BundleShellCmdManager(param1:GameConfig)
      {
         super(param1.logger);
         this.config = param1;
         add("list",this.shellFuncList);
         add("load",this.shellFuncLoad);
         add("purge",this.shellFuncPurge);
         add("addReference",this.shellFuncAddReference);
         add("releaseReference",this.shellFuncReleaseReference);
      }
      
      private function _findManager(param1:String) : IAssetBundleManager
      {
         var _loc2_:IEntityAssetBundleManager = this.config._eabm;
         var _loc3_:IAbilityAssetBundleManager = _loc2_.abilityAssetBundleManager;
         if(StringUtil.startsWith("entity",param1))
         {
            return _loc2_;
         }
         if(StringUtil.startsWith("ability",param1))
         {
            return _loc3_;
         }
         throw new ArgumentError("Type must be \'entity\' or \'ability\'");
      }
      
      private function shellFuncList(param1:CmdExec) : void
      {
         var _loc4_:String = null;
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            logger.info("Usage: " + _loc2_[0] + " <entity|ability> [id]");
            return;
         }
         var _loc3_:IAssetBundleManager = this._findManager(_loc2_[1]);
         if(_loc2_.length > 2)
         {
            _loc4_ = String(_loc2_[2]);
            logger.info(_loc3_.getDebugInfo(_loc4_));
         }
         else
         {
            logger.info(_loc3_.getDebugListing());
         }
      }
      
      private function shellFuncPurge(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            logger.info("Usage: " + _loc2_[0] + " <entity|ability> [id]");
            return;
         }
         var _loc3_:IAssetBundleManager = this._findManager(_loc2_[1]);
         _loc3_.purge();
      }
      
      private function shellFuncLoad(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
      }
      
      private function shellFuncAddReference(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
      }
      
      private function shellFuncReleaseReference(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
      }
   }
}
