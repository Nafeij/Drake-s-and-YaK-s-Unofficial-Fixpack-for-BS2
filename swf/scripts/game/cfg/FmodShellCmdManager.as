package game.cfg
{
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.ShellCmdManager;
   import engine.core.logging.ILogger;
   import engine.def.BooleanVars;
   import engine.sound.ISoundDefBundle;
   import engine.sound.ISoundDefBundleListener;
   import engine.sound.ISoundEventId;
   import engine.sound.config.ISoundSystem;
   import engine.sound.def.ISoundDef;
   import engine.sound.def.SoundDef;
   import flash.utils.Dictionary;
   
   public class FmodShellCmdManager extends ShellCmdManager implements ISoundDefBundleListener
   {
       
      
      private var soundSystem:ISoundSystem;
      
      private var _last_fmod_shell_id:int;
      
      public function FmodShellCmdManager(param1:ILogger, param2:ISoundSystem)
      {
         super(param1);
         this.soundSystem = param2;
         add("play",this.shellFuncPlay);
         add("param",this.shellFuncParam);
         add("stop",this.shellFuncStop);
         add("volume",this.shellFuncVolume);
         add("pitch",this.shellFuncPitch);
         add("islooping",this.shellFuncIsLooping);
         add("bundles",this.shellFuncBundles);
         add("banks",this.shellFuncBanks);
         add("debug",this.shellFuncDebug);
         add("reverb",this.shellFuncReverb);
         add("playing",this.shellFuncPlaying);
         add("pause",this.shellFuncPause);
         add("loadevent",this.shellFuncLoadEvent);
         add("unloadbundle",this.shellFuncUnloadBundle);
         add("test_dropout",this.shellFuncTestDropout);
         addShell("category",new FmodCategoryShellCmdManager(param1,param2));
      }
      
      private function shellFuncPlay(param1:CmdExec) : void
      {
         var _loc5_:String = null;
         var _loc6_:Number = NaN;
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            logger.info("Usage: play <event> [<param> <value>]");
            return;
         }
         var _loc3_:String = _loc2_[1];
         logger.info("event=" + _loc3_);
         _loc3_ = this.soundSystem.driver.normalizeEventId(_loc3_);
         var _loc4_:ISoundEventId = this.soundSystem.driver.playEvent(_loc3_);
         if(_loc4_)
         {
            this.soundSystem.driver.systemUpdate();
            if(param1.param.length >= 3)
            {
               _loc5_ = _loc2_[2];
               _loc6_ = Number(_loc2_[3]);
               logger.info("param=" + _loc5_ + ", value=" + _loc6_);
               this.soundSystem.driver.setEventParameterValueByName(_loc4_,_loc5_,_loc6_);
            }
         }
         logger.info("systemid=" + _loc4_);
      }
      
      private function shellFuncUnloadBundle(param1:CmdExec) : void
      {
         var _loc5_:ISoundDefBundle = null;
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            logger.error("Usage: " + param1.param[0] + " <bundleId>");
            return;
         }
         var _loc3_:String = _loc2_[1];
         var _loc4_:Vector.<ISoundDefBundle> = this.soundSystem.driver.allSoundDefBundles;
         for each(_loc5_ in _loc4_)
         {
            if(_loc5_.id == _loc3_)
            {
               _loc5_.removeListener(this);
               return;
            }
         }
         logger.info("Unable to find bundle [" + _loc3_ + "]");
      }
      
      private function shellFuncTestDropout(param1:CmdExec) : void
      {
         new FmodTestDropout(logger,this.soundSystem);
      }
      
      private function shellFuncLoadEvent(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            logger.error("Usage: " + param1.param[0] + " <event>");
            return;
         }
         var _loc3_:String = _loc2_[1];
         var _loc4_:String = "fmod-shell-cmd-" + ++this._last_fmod_shell_id;
         logger.info("event=" + _loc3_ + " + bundle=" + _loc4_);
         _loc3_ = this.soundSystem.driver.normalizeEventId(_loc3_);
         var _loc5_:String = null;
         var _loc6_:Vector.<ISoundDef> = new Vector.<ISoundDef>();
         _loc6_.push(new SoundDef().setup(_loc5_,_loc3_,_loc3_));
         var _loc7_:ISoundDefBundle = this.soundSystem.driver.preloadSoundDefData(_loc4_,_loc6_);
         _loc7_.addListener(this);
         logger.info("Created bundle " + _loc7_);
      }
      
      public function soundDefBundleComplete(param1:ISoundDefBundle) : void
      {
         logger.info("FmodShellCmdManager: sound completed loading");
      }
      
      private function shellFuncParam(param1:CmdExec) : void
      {
         var _loc6_:int = 0;
         if(param1.param.length < 4)
         {
            logger.error("Usage: " + param1.param[0] + " <event/systemid> <param> <value>");
            return;
         }
         var _loc2_:String = param1.param[1];
         var _loc3_:ISoundEventId = this.findPlayingEventIdFromDesc(_loc2_,false);
         logger.info("event=" + _loc2_);
         _loc2_ = this.soundSystem.driver.normalizeEventId(_loc2_);
         var _loc4_:String = param1.param[2];
         var _loc5_:Number = Number(param1.param[3]);
         logger.info("param=" + _loc4_ + ", value=" + _loc5_);
         if(_loc3_ != null)
         {
            _loc6_ = int(_loc4_);
            if(_loc6_ > 0 || _loc4_ == "0")
            {
               logger.info("setting by systemid/paramindex");
               this.soundSystem.driver.setEventParameterValue(_loc3_,_loc6_,_loc5_);
            }
            else
            {
               logger.info("setting by systemid/paramname");
               this.soundSystem.driver.setEventParameterValueByName(_loc3_,_loc4_,_loc5_);
            }
         }
         else
         {
            logger.info("setting by name/name");
            this.soundSystem.driver.setEventParameter(_loc2_,_loc4_,_loc5_);
         }
      }
      
      private function shellFuncStop(param1:CmdExec) : void
      {
         if(param1.param.length < 2)
         {
            logger.error("Usage: " + param1.param[0] + " <systemid> [immediate]");
            return;
         }
         var _loc2_:ISoundEventId = this.findPlayingEventIdFromDesc(param1.param[1],true);
         var _loc3_:Boolean = param1.param > 2 ? Boolean(param1.param[2]) : false;
         this.soundSystem.driver.stopEvent(_loc2_,_loc3_);
      }
      
      private function shellFuncVolume(param1:CmdExec) : void
      {
         var _loc4_:Number = NaN;
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            logger.error("Usage: " + _loc2_[0] + " <systemid> [volume]");
            return;
         }
         var _loc3_:ISoundEventId = this.findPlayingEventIdFromDesc(param1.param[1],true);
         if(_loc2_.length > 2)
         {
            _loc4_ = Number(_loc2_[2]);
            if(!this.soundSystem.driver.setEventVolume(_loc3_,_loc4_))
            {
               logger.error("Failed to set volume");
            }
         }
         _loc4_ = this.soundSystem.driver.getEventVolume(_loc3_);
         logger.info("volume=" + _loc4_);
      }
      
      private function shellFuncPitch(param1:CmdExec) : void
      {
         var _loc4_:Number = NaN;
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            logger.error("Usage: " + _loc2_[0] + " <systemid> [pitch]");
            return;
         }
         var _loc3_:ISoundEventId = this.findPlayingEventIdFromDesc(param1.param[1],true);
         if(_loc2_.length > 2)
         {
            _loc4_ = Number(_loc2_[2]);
            if(!this.soundSystem.driver.setEventPitchSemitones(_loc3_,_loc4_))
            {
               logger.error("Failed to set pitch");
            }
         }
      }
      
      private function shellFuncIsLooping(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            logger.error("Usage: " + _loc2_[0] + " <systemid>");
            return;
         }
         var _loc3_:ISoundEventId = this.findPlayingEventIdFromDesc(param1.param[1],true);
         var _loc4_:Boolean = this.soundSystem.driver.isLooping(_loc3_);
         logger.info("looping=" + _loc4_);
      }
      
      private function shellFuncPause(param1:CmdExec) : void
      {
         if(param1.param.length < 2)
         {
            logger.error("Usage: " + param1.param[0] + " <pause>");
            return;
         }
         var _loc2_:Boolean = BooleanVars.parse(param1.param[1],false);
         if(_loc2_)
         {
            this.soundSystem.driver.pause();
         }
         else
         {
            this.soundSystem.driver.unpause();
         }
      }
      
      private function shellFuncBundles(param1:CmdExec) : void
      {
         var _loc3_:ISoundDefBundle = null;
         var _loc2_:Vector.<ISoundDefBundle> = this.soundSystem.driver.allSoundDefBundles;
         for each(_loc3_ in _loc2_)
         {
            _loc3_.debugPrint(logger);
         }
      }
      
      private function shellFuncDebug(param1:CmdExec) : void
      {
         this.soundSystem.driver.debugSoundDriver = !this.soundSystem.driver.debugSoundDriver;
         logger.info("debugSoundDriver=" + this.soundSystem.driver.debugSoundDriver);
      }
      
      private function shellFuncReverb(param1:CmdExec) : void
      {
         var _loc3_:String = null;
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            logger.error("Usage: " + _loc2_[0] + " <preset>");
            return;
         }
         if(_loc2_.length > 1)
         {
            _loc3_ = _loc2_[1];
            this.soundSystem.driver.reverbAmbientPreset(_loc3_);
         }
         logger.info("reverb=" + this.soundSystem.driver.reverb);
      }
      
      private function shellFuncBanks(param1:CmdExec) : void
      {
         var _loc4_:* = null;
         var _loc5_:Object = null;
         var _loc7_:ISoundDefBundle = null;
         var _loc8_:ISoundDef = null;
         var _loc9_:Array = null;
         var _loc10_:* = null;
         var _loc11_:* = null;
         var _loc2_:Dictionary = new Dictionary();
         var _loc3_:Vector.<ISoundDefBundle> = this.soundSystem.driver.allSoundDefBundles;
         logger.info("...computing bank info for " + _loc3_.length);
         var _loc6_:int = 0;
         while(_loc6_ < _loc3_.length)
         {
            _loc7_ = _loc3_[_loc6_];
            for each(_loc8_ in _loc7_.defs)
            {
               _loc9_ = this.soundSystem.driver.getWaveBankInfo(_loc8_.eventName);
               for each(_loc4_ in _loc9_)
               {
                  _loc5_ = _loc2_[_loc4_];
                  if(!_loc5_)
                  {
                     _loc5_ = {
                        "bundles":new Dictionary(),
                        "events":new Dictionary()
                     };
                     _loc2_[_loc4_] = _loc5_;
                  }
                  _loc5_.events[_loc8_.eventName] = true;
                  _loc5_.bundles[_loc7_.id] = _loc7_;
               }
            }
            _loc6_++;
         }
         logger.info("______BANKS INFO_______");
         for(_loc4_ in _loc2_)
         {
            _loc5_ = _loc2_[_loc4_];
            logger.info("BANK: " + _loc4_);
            logger.info("     Events:");
            for(_loc10_ in _loc5_.events)
            {
               logger.info("           " + _loc10_);
            }
            logger.info("    Bundles:");
            for(_loc11_ in _loc5_.bundles)
            {
               logger.info("           " + _loc11_);
            }
         }
      }
      
      private function shellFuncPlaying(param1:CmdExec) : void
      {
         var _loc2_:* = null;
         var _loc3_:ISoundEventId = null;
         var _loc4_:String = null;
         logger.info("Events Playing:");
         for(_loc2_ in this.soundSystem.driver.playing)
         {
            _loc3_ = _loc2_ as ISoundEventId;
            _loc4_ = this.soundSystem.driver.playing[_loc2_];
            logger.info("name: " + _loc4_ + " id: " + _loc3_.toString());
         }
      }
      
      private function findPlayingEventIdFromDesc(param1:String, param2:Boolean) : ISoundEventId
      {
         var _loc4_:* = null;
         var _loc5_:ISoundEventId = null;
         var _loc6_:String = null;
         var _loc3_:ISoundEventId = this.createEventIdFromDesc(param1);
         if(_loc3_ != null)
         {
            for(_loc4_ in this.soundSystem.driver.playing)
            {
               _loc5_ = _loc4_ as ISoundEventId;
               if(_loc3_.equals(_loc5_))
               {
                  return _loc5_;
               }
            }
         }
         else if(param2)
         {
            for(_loc4_ in this.soundSystem.driver.playing)
            {
               _loc5_ = _loc4_ as ISoundEventId;
               _loc6_ = this.soundSystem.driver.playing[_loc4_];
               if(_loc6_ == param1)
               {
                  return _loc5_;
               }
            }
         }
         return null;
      }
      
      private function createEventIdFromDesc(param1:String) : ISoundEventId
      {
         return this.soundSystem.driver.createEventIdFromDesc(param1);
      }
   }
}

import engine.core.cmd.CmdExec;
import engine.core.cmd.ShellCmdManager;
import engine.core.logging.ILogger;
import engine.core.util.StringUtil;
import engine.def.BooleanVars;
import engine.sound.ISoundDriver;
import engine.sound.config.ISoundSystem;

class FmodCategoryShellCmdManager extends ShellCmdManager
{
    
   
   private var soundSystem:ISoundSystem;
   
   private var driver:ISoundDriver;
   
   public function FmodCategoryShellCmdManager(param1:ILogger, param2:ISoundSystem)
   {
      super(param1);
      this.driver = param2.driver;
      this.soundSystem = param2;
      add("list",this.shellFuncList);
      add("mute",this.shellFuncMute);
      add("volume",this.shellFuncVolume);
   }
   
   private function shellFuncList(param1:CmdExec) : void
   {
      var _loc2_:String = null;
      var _loc6_:String = null;
      var _loc3_:Array = param1.param;
      if(_loc3_.length > 1)
      {
         _loc2_ = _loc3_[1];
      }
      var _loc4_:int = int(this.soundSystem.driver.getNumEventCategories(_loc2_));
      logger.info("Categories " + _loc4_);
      var _loc5_:int = 0;
      while(_loc5_ < _loc4_)
      {
         _loc6_ = this.driver.getEventCategoryName(_loc2_,_loc5_);
         logger.info("   " + StringUtil.padLeft(_loc5_.toString()," ",2) + " " + _loc6_);
         _loc5_++;
      }
   }
   
   private function shellFuncMute(param1:CmdExec) : void
   {
      var _loc4_:Boolean = false;
      var _loc2_:Array = param1.param;
      if(_loc2_.length <= 1)
      {
         logger.info("Usage: " + _loc2_[0] + " <category name> [mute]");
         return;
      }
      var _loc3_:String = _loc2_[1];
      if(_loc2_.length > 2)
      {
         _loc4_ = BooleanVars.parse(_loc2_[2],false);
         if(!this.driver.setEventCategoryMute(_loc3_,_loc4_))
         {
            logger.error("Failed to mute");
         }
      }
      _loc4_ = Boolean(this.driver.getEventCategoryMute(_loc3_));
      logger.info(_loc3_ + " mute=" + _loc4_);
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
      var _loc4_:Number = 0;
      if(_loc2_.length > 2)
      {
         _loc4_ = Number(_loc2_[2]);
         if(!this.driver.setEventCategoryVolume(_loc3_,_loc4_))
         {
            logger.error("Failed to mute");
         }
      }
      _loc4_ = Number(this.driver.getEventCategoryVolume(_loc3_));
      logger.info(_loc3_ + " volume=" + _loc4_);
   }
}
