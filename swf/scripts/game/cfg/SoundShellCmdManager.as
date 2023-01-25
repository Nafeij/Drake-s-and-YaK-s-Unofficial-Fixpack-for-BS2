package game.cfg
{
   import engine.core.analytic.GaConfig;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.ShellCmdManager;
   import engine.sound.config.ISoundSystem;
   
   public class SoundShellCmdManager extends ShellCmdManager
   {
       
      
      private var config:GameConfig;
      
      public var mixerShell:SoundMixerShellCmdManager;
      
      public function SoundShellCmdManager(param1:GameConfig)
      {
         super(param1.logger);
         this.config = param1;
         add("info",this.shellFuncInfo);
         this.mixerShell = new SoundMixerShellCmdManager(param1);
         this.addShell("mixer",this.mixerShell);
      }
      
      private function shellFuncInfo(param1:CmdExec) : void
      {
         var _loc2_:ISoundSystem = this.config.soundSystem;
         logger.info("SoundSystem:\n" + "         enabled: " + _loc2_.enabled + "\n" + "           music: " + _loc2_.music + "\n" + "  isMusicPlaying: " + _loc2_.isMusicPlaying + "\n" + "         ducking: " + _loc2_.ducking);
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
