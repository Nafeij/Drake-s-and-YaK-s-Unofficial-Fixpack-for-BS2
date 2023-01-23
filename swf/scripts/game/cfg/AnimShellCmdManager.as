package game.cfg
{
   import engine.anim.def.AnimClipDef;
   import engine.anim.def.AnimLibrary;
   import engine.battle.def.IsoAnimLibraryResource;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.ShellCmdManager;
   import engine.resource.Resource;
   
   public class AnimShellCmdManager extends ShellCmdManager
   {
       
      
      private var config:GameConfig;
      
      private var libShell:AnimLibraryShellCmdManager;
      
      public function AnimShellCmdManager(param1:GameConfig)
      {
         super(param1.logger);
         this.config = param1;
         this.libShell = new AnimLibraryShellCmdManager(param1);
         add("playback_speed",this.shellFuncPlaybackSpeed);
         add("library",this.shellFuncLibrary);
      }
      
      private function shellFuncPlaybackSpeed(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length >= 2)
         {
            AnimClipDef.setPlaybackMod(_loc2_[1]);
         }
         logger.info("Anim playbackMod: " + AnimClipDef.playbackMod);
      }
      
      private function shellFuncLibrary(param1:CmdExec) : void
      {
         var _loc4_:IsoAnimLibraryResource = null;
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            logger.info("Usage: <library url> ...");
            logger.info("Usage: list");
            return;
         }
         var _loc3_:String = _loc2_[1];
         var _loc5_:Vector.<Resource> = this.config.resman.listResources(IsoAnimLibraryResource);
         if(_loc3_ == "list")
         {
            for each(_loc4_ in _loc5_)
            {
               logger.info("  " + _loc4_.url);
            }
            return;
         }
         _loc4_ = this.findLibrary(_loc3_,_loc5_);
         if(!_loc4_)
         {
            logger.info("No such anim library matches: " + _loc3_);
            return;
         }
         logger.info("Matched anim library " + _loc4_.url);
         var _loc6_:AnimLibrary = _loc4_.library;
         if(!_loc6_)
         {
            logger.info("Anim library unavailable: " + _loc3_);
            return;
         }
         this.libShell.library = _loc6_;
         _loc2_.shift();
         _loc2_.shift();
         this.libShell.execArgv(null,_loc2_);
      }
      
      private function findLibrary(param1:String, param2:Vector.<Resource>) : IsoAnimLibraryResource
      {
         var _loc3_:IsoAnimLibraryResource = null;
         for each(_loc3_ in param2)
         {
            if(_loc3_.url.indexOf(param1) >= 0)
            {
               return _loc3_;
            }
         }
         return null;
      }
   }
}
