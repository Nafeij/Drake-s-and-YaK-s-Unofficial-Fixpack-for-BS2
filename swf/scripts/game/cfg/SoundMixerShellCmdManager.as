package game.cfg
{
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.ShellCmdManager;
   import engine.def.BooleanVars;
   import engine.sound.config.ISoundMixer;
   import engine.sound.config.ISoundSystem;
   
   public class SoundMixerShellCmdManager extends ShellCmdManager
   {
       
      
      private var config:GameConfig;
      
      public var mixerShell:SoundMixerShellCmdManager;
      
      public function SoundMixerShellCmdManager(param1:GameConfig)
      {
         super(param1.logger);
         this.config = param1;
         add("info",this.shellFuncInfo);
         add("volume",this.shellFuncVolume);
         add("mute",this.shellFuncMute);
         add("video",this.shellFuncVideo);
      }
      
      private function shellFuncInfo(param1:CmdExec) : void
      {
         var _loc2_:ISoundSystem = this.config.soundSystem;
         var _loc3_:ISoundMixer = _loc2_.mixer;
         logger.info("\nSoundMixer:\n" + "    volume-     :\n" + "          master: " + _loc3_.volumeMaster + "\n" + "             sfx: " + _loc3_.volumeSfx + "\n" + "           music: " + _loc3_.volumeMusic + "\n" + "           video: " + _loc3_.volumeVideo + "\n" + "      mute-     :\n" + "          master: " + _loc3_.muteMaster + "\n" + "             sfx: " + _loc3_.muteSfx + "\n" + "           music: " + _loc3_.muteMusic + "\n" + "           video: " + _loc3_.muteVideo + "\n" + " \n" + "  videoMixerMode: " + _loc3_.videoMixerMode + "\n");
      }
      
      private function shellFuncVolume(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length <= 1)
         {
            logger.info("Usage: " + _loc2_[0] + " <category name> [volume]");
            return;
         }
         var _loc3_:String = _loc2_[1];
         this._manipulate("volume",_loc3_,_loc2_.length > 2 ? _loc2_[2] : undefined);
      }
      
      private function shellFuncMute(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length <= 1)
         {
            logger.info("Usage: " + _loc2_[0] + " <category name> [mute]");
            return;
         }
         var _loc3_:String = _loc2_[1];
         var _loc4_:* = _loc2_.length > 2 ? BooleanVars.parse(_loc2_[2]) : undefined;
         this._manipulate("mute",_loc3_,_loc4_);
      }
      
      private function _manipulate(param1:String, param2:String, param3:*) : void
      {
         var _loc4_:ISoundSystem = this.config.soundSystem;
         var _loc5_:ISoundMixer = _loc4_.mixer;
         var _loc6_:String = param1 + param2.charAt(0).toUpperCase() + param2.substr(1);
         if(param3 != undefined)
         {
            _loc5_[_loc6_] = param3;
         }
         logger.info(_loc6_ + "=" + _loc5_[_loc6_]);
      }
      
      private function shellFuncVideo(param1:CmdExec) : void
      {
         var _loc2_:ISoundSystem = this.config.soundSystem;
         var _loc3_:ISoundMixer = _loc2_.mixer;
         var _loc4_:Array = param1.param;
         if(_loc4_.length <= 1)
         {
            logger.info("Usage: " + _loc4_[0] + " <category name> [mute]");
            return;
         }
         var _loc5_:String = _loc4_[1];
         var _loc6_:* = _loc4_.length > 2 ? _loc4_[2] : undefined;
         if(_loc6_ != undefined)
         {
            _loc3_.videoMixerMode = _loc6_;
         }
         logger.info("videoMode = " + _loc3_.videoMixerMode);
      }
   }
}
