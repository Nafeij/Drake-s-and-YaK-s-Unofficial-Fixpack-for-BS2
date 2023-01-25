package engine.saga.convo
{
   import com.adobe.utils.DictionaryUtil;
   import com.greensock.TweenMax;
   import engine.core.logging.ILogger;
   import engine.saga.convo.def.audio.ConvoAudioCmdDef;
   import engine.saga.convo.def.audio.ConvoAudioCmdType;
   import engine.saga.convo.def.audio.ConvoAudioDef;
   import engine.saga.convo.def.audio.ConvoAudioListDef;
   import engine.saga.convo.def.audio.ConvoAudioParamDef;
   import engine.sound.ISoundEventId;
   import engine.sound.SoundDriverEvent;
   import engine.sound.config.ISoundMixer;
   import engine.sound.config.ISoundSystem;
   import engine.sound.view.ISound;
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   public class ConvoAudio
   {
      
      public static var SEMITONE_MULTIPLE:Number = 0.5;
       
      
      public var def:ConvoAudioDef;
      
      public var convo:Convo;
      
      public var preloader:ConvoAudioPreloader;
      
      public var events:Dictionary;
      
      public var musicevents:Dictionary;
      
      public var logger:ILogger;
      
      private var system:ISoundSystem;
      
      public var pitch0:Number = 0;
      
      public var pitch1:Number = 0;
      
      public var pitch:Number = 0;
      
      public var pitchIndex:int = 0;
      
      private var delayed_cmds:Dictionary;
      
      private var buttonHideEvents:Dictionary;
      
      private var _deferredAudioCmdDefs:Vector.<ConvoAudioCmdDef>;
      
      public function ConvoAudio(param1:ISoundSystem, param2:ConvoAudioListDef, param3:ConvoAudioDef, param4:Convo)
      {
         this.events = new Dictionary();
         this.musicevents = new Dictionary();
         this.delayed_cmds = new Dictionary();
         this.buttonHideEvents = new Dictionary();
         super();
         this.def = param3;
         this.convo = param4;
         this.logger = param4.logger;
         this.system = param1;
         if(Boolean(param2) && Boolean(param3))
         {
            this.preloader = new ConvoAudioPreloader(param1.driver,param2,param4,this.logger);
            this.preloader.addEventListener(Event.COMPLETE,this.preloaderCompleteHandler);
            this.preloader.preload();
         }
      }
      
      public function cleanup() : void
      {
         var _loc1_:String = null;
         var _loc2_:Array = null;
         var _loc3_:ISoundEventId = null;
         for(_loc1_ in this.events)
         {
            if(!this.musicevents[_loc1_])
            {
               _loc2_ = this.events[_loc1_];
               if(_loc2_)
               {
                  for each(_loc3_ in _loc2_)
                  {
                     if(Boolean(_loc3_) && this.system.driver.isPlaying(_loc3_))
                     {
                        if(!this.system.driver.stopEvent(_loc3_,false))
                        {
                           this.logger.error("ConvoAudio " + this + " failed to cleanup stop " + _loc1_ + "/" + _loc3_.toString());
                        }
                        if(this.system.driver.isPlaying(_loc3_))
                        {
                           this.preloader.waitForSoundToFinish(_loc3_);
                        }
                     }
                  }
               }
            }
         }
         TweenMax.killDelayedCallsTo(this,this.handleCmd_delayed);
         this.delayed_cmds = null;
         this.musicevents = null;
         this.events = null;
         this.buttonHideEvents = null;
         if(this.preloader)
         {
            this.preloader.removeEventListener(SoundDriverEvent.STOP,this.soundComplete);
            this.preloader.cleanup();
            this.preloader = null;
         }
         this.convo = null;
         this.def = null;
         this.system = null;
      }
      
      public function toString() : String
      {
         return this.convo.def.url;
      }
      
      private function preloaderCompleteHandler(param1:Event) : void
      {
         this.preloader.driver.addEventListener(SoundDriverEvent.STOP,this.soundComplete);
         this.unspoolDeferredAudioCmdDefs();
      }
      
      public function generatePitches() : void
      {
         var _loc1_:Number = 1.059463;
         _loc1_ = Math.pow(_loc1_,SEMITONE_MULTIPLE);
         this.pitch0 = 1 / _loc1_;
         this.pitch1 = _loc1_;
         this.pitch = this.pitch0;
         this.updatePitches();
      }
      
      public function switchPitches() : void
      {
         this.pitchIndex = (this.pitchIndex + 1) % 2;
         this.pitch = this.pitchIndex == 0 ? this.pitch0 : this.pitch1;
         this.updatePitches();
      }
      
      public function updatePitches() : void
      {
         var _loc1_:String = null;
         var _loc2_:Array = null;
         var _loc3_:ISoundEventId = null;
         for(_loc1_ in this.events)
         {
            if(!this.musicevents[_loc1_])
            {
               _loc2_ = this.events[_loc1_];
               if(_loc2_)
               {
                  for each(_loc3_ in _loc2_)
                  {
                     if(Boolean(_loc3_) && this.system.driver.isPlaying(_loc3_))
                     {
                        if(!this.system.driver.setEventPitchSemitones(_loc3_,this.pitch))
                        {
                           this.logger.error("ConvoAudio " + this + " failed to set pitch " + _loc1_ + "/" + _loc3_.toString());
                        }
                     }
                  }
               }
            }
         }
      }
      
      private function unspoolDeferredAudioCmdDefs() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:ConvoAudioCmdDef = null;
         if(Boolean(this.preloader) && this.preloader.complete)
         {
            if(this._deferredAudioCmdDefs)
            {
               _loc1_ = int(this._deferredAudioCmdDefs.length);
               _loc2_ = 0;
               while(_loc2_ < _loc1_)
               {
                  _loc3_ = this._deferredAudioCmdDefs[_loc2_];
                  this.logger.info("ConvoAudio.unspoolDeferredAudioCmdDefs " + _loc2_ + " " + _loc3_);
                  this.handleCmd(_loc3_,false);
                  _loc2_++;
               }
               this._deferredAudioCmdDefs = null;
            }
         }
      }
      
      public function handleCmd(param1:ConvoAudioCmdDef, param2:Boolean = true) : void
      {
         if(Boolean(this.preloader) && !this.preloader.complete)
         {
            if(!param2)
            {
               this.logger.error("Attempted to defer something inappropriately: " + param1);
               return;
            }
            if(!this._deferredAudioCmdDefs)
            {
               this._deferredAudioCmdDefs = new Vector.<ConvoAudioCmdDef>();
            }
            this.logger.info("ConvoAudio.handleCmd deferring " + this._deferredAudioCmdDefs.length + " " + param1);
            this._deferredAudioCmdDefs.push(param1);
            return;
         }
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("ConvoAudio handleCmd " + param1.labelString);
         }
         switch(param1.type)
         {
            case ConvoAudioCmdType.START:
               this.handleCmdInputBlock(param1);
               this.handleCmdStart(param1);
               this.handleCmdModify(param1);
               break;
            case ConvoAudioCmdType.MODIFY:
               this.handleCmdModify(param1);
               break;
            case ConvoAudioCmdType.END:
               this.handleCmdEnd(param1);
         }
      }
      
      public function handleCmd_delayed(param1:ConvoAudioCmdDef) : void
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("ConvoAudio handleCmd_delayed " + param1.labelString);
         }
         if(!this.delayed_cmds || !this.delayed_cmds[param1])
         {
            return;
         }
         delete this.delayed_cmds[param1];
         switch(param1.type)
         {
            case ConvoAudioCmdType.START:
               this.handleCmdInputBlock(param1);
               this.handleCmdStart_delayed(param1);
               break;
            case ConvoAudioCmdType.MODIFY:
            case ConvoAudioCmdType.END:
         }
      }
      
      private function checkCmdValidity(param1:ConvoAudioCmdDef) : Boolean
      {
         if(!param1.event)
         {
            return false;
         }
         if(!this.preloader || !this.preloader.complete)
         {
            return false;
         }
         if(!this.preloader.driver || !this.preloader.driver.system.mixer.sfxEnabled)
         {
            return false;
         }
         return true;
      }
      
      private function handleCmdStart(param1:ConvoAudioCmdDef) : void
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("ConvoAudio handleCmdStart " + param1.labelString);
         }
         if(!this.checkCmdValidity(param1))
         {
            return;
         }
         if(param1.delay)
         {
            this.delayCmd(param1);
            return;
         }
         if(param1.blockInput && Boolean(this.buttonHideEvents[param1.event]))
         {
            this.buttonHideEvents[param1.event] = param1;
         }
         this.handleCmdStart_delayed(param1);
      }
      
      private function delayCmd(param1:ConvoAudioCmdDef) : void
      {
         this.delayed_cmds[param1] = param1;
         var _loc2_:Number = param1.delay * 0.001;
         TweenMax.delayedCall(_loc2_,this.handleCmd_delayed,[param1]);
      }
      
      private function handleCmdStart_delayed(param1:ConvoAudioCmdDef) : void
      {
         var _loc3_:ISound = null;
         var _loc4_:Array = null;
         var _loc5_:ISoundMixer = null;
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("ConvoAudio handleCmdStart " + param1.labelString);
         }
         if(!this.checkCmdValidity(param1))
         {
            return;
         }
         var _loc2_:ISoundEventId = null;
         if(param1.music)
         {
            _loc3_ = this.preloader.driver.system.playMusicEvent(param1.sku,param1.event);
            _loc2_ = _loc3_.systemid;
            this.musicevents[param1.event] = param1;
         }
         else
         {
            _loc2_ = this.preloader.driver.playEvent(param1.event);
         }
         if(_loc2_)
         {
            _loc4_ = this.events[param1.event];
            if(!_loc4_)
            {
               _loc4_ = [];
               this.events[param1.event] = _loc4_;
            }
            _loc4_.push(_loc2_);
         }
         else
         {
            _loc5_ = this.preloader.driver.system.mixer;
            if(param1.music && _loc5_.musicEnabled || !param1.music && _loc5_.sfxEnabled)
            {
               this.logger.error("ConvoAudio " + this + " failed to start " + param1.event);
            }
         }
      }
      
      private function handleCmdModify(param1:ConvoAudioCmdDef) : void
      {
         var _loc3_:ISoundEventId = null;
         var _loc4_:ConvoAudioParamDef = null;
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("ConvoAudio handleCmdModify " + param1.labelString);
         }
         if(!param1.event)
         {
            return;
         }
         var _loc2_:Array = this.events[param1.event];
         if(_loc2_)
         {
            for each(_loc3_ in _loc2_)
            {
               if(Boolean(_loc3_) && this.system.driver.isPlaying(_loc3_))
               {
                  if(param1.volume != 1)
                  {
                     if(!this.preloader.driver.setEventVolume(_loc3_,param1.volume))
                     {
                        this.logger.error("ConvoAudio " + this + " failed to set volume " + param1.event + "/" + _loc3_.toString());
                     }
                  }
                  if(param1.params)
                  {
                     for each(_loc4_ in param1.params)
                     {
                        if(_loc4_.param)
                        {
                           if(!this.preloader.driver.setEventParameterValueByName(_loc3_,_loc4_.param,_loc4_.value))
                           {
                              this.logger.error("ConvoAudio " + this + " failed to set param " + param1.event + "/" + _loc3_.toString() + " [" + _loc4_.param + "]=" + _loc4_.value);
                           }
                        }
                     }
                  }
               }
            }
         }
      }
      
      private function handleCmdEnd(param1:ConvoAudioCmdDef) : void
      {
         var _loc3_:ISoundEventId = null;
         if(!param1.event)
         {
            return;
         }
         var _loc2_:Array = this.events[param1.event];
         if(_loc2_)
         {
            for each(_loc3_ in _loc2_)
            {
               if(Boolean(_loc3_) && this.system.driver.isPlaying(_loc3_))
               {
                  if(!this.preloader.driver.stopEvent(_loc3_,false))
                  {
                     this.logger.error("ConvoAudio " + this + " failed to set volume " + param1.event + "/" + _loc3_.toString());
                  }
               }
            }
         }
         delete this.events[param1.event];
         delete this.musicevents[param1.event];
      }
      
      public function isPlayingBlockingAudioEvent() : Boolean
      {
         return DictionaryUtil.getKeys(this.buttonHideEvents).length > 0;
      }
      
      private function soundComplete(param1:SoundDriverEvent) : void
      {
         if(Boolean(this.events) && Boolean(this.events[param1.eventName]))
         {
            delete this.events[param1.eventName];
         }
         else if(Boolean(this.delayed_cmds) && Boolean(this.delayed_cmds[param1.eventName]))
         {
            delete this.delayed_cmds[param1.eventName];
         }
         else if(Boolean(this.musicevents) && Boolean(this.musicevents[param1.eventName]))
         {
            delete this.musicevents[param1.eventName];
         }
         if(Boolean(this.buttonHideEvents) && Boolean(this.buttonHideEvents[param1.eventName]))
         {
            delete this.buttonHideEvents[param1.eventName];
            this.handleButtonVisibility();
         }
      }
      
      private function handleCmdInputBlock(param1:ConvoAudioCmdDef) : void
      {
         if(!this.checkCmdValidity(param1))
         {
            return;
         }
         if(param1.blockInput && !this.buttonHideEvents[param1.event])
         {
            this.buttonHideEvents[param1.event] = param1;
            this.handleButtonVisibility();
         }
      }
      
      private function handleButtonVisibility() : void
      {
         if(this.isPlayingBlockingAudioEvent())
         {
            this.convo.dispatchEvent(new Event(Convo.EVENT_AUDIO_BLOCK));
         }
         else
         {
            this.convo.dispatchEvent(new Event(Convo.EVENT_AUDIO_UNBLOCK));
         }
      }
   }
}
