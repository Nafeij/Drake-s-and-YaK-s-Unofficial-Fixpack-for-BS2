package engine.saga
{
   import com.greensock.TweenMax;
   import engine.core.logging.ILogger;
   import engine.saga.action.Action_MusicIncidental;
   import engine.saga.vars.VariableType;
   import engine.scene.model.Scene;
   import engine.sound.ISoundDefBundle;
   import engine.sound.ISoundDefBundleListener;
   import engine.sound.config.ISoundSystem;
   import engine.sound.def.ISoundDef;
   import engine.sound.def.SoundDef;
   import engine.sound.view.ISound;
   import engine.sound.view.SoundController;
   import flash.utils.Dictionary;
   
   public class SagaSound implements ISoundDefBundleListener, ISagaSound
   {
       
      
      public var defs:Dictionary;
      
      public var saga:Saga;
      
      public var sagadef:SagaDef;
      
      public var _system:ISoundSystem;
      
      public var _music:SoundController;
      
      public var _vo:SoundController;
      
      private var _currentMusicDef:ISoundDef;
      
      public var _currentMusicParams:Dictionary;
      
      public var logger:ILogger;
      
      private var _musicShouldBePlaying:Boolean;
      
      private var campMusicAction:Action_MusicIncidental;
      
      private var campMusicWaitingForWindow:Boolean;
      
      public var currentMusicBundle:ISoundDefBundle;
      
      private var _loadedCallback:Function;
      
      public var _loaded:Boolean;
      
      public function SagaSound(param1:Saga, param2:ISoundSystem)
      {
         this.defs = new Dictionary();
         this._currentMusicParams = new Dictionary();
         super();
         this.saga = param1;
         this._system = param2;
         this.sagadef = param1.def;
         this.logger = param1.logger;
      }
      
      public function cleanup() : void
      {
         TweenMax.killDelayedCallsTo(this._killMusicForBattleTransition);
         this.system.music = null;
         if(this._music)
         {
            this._music.cleanup();
            this._music = null;
         }
         if(this._vo)
         {
            this._vo.cleanup();
            this._vo = null;
         }
      }
      
      public function stopAllSounds() : void
      {
         this.setCurrentMusicDef(null);
         this.system.music = null;
      }
      
      public function pauseAllSounds() : void
      {
         this.system.pause();
      }
      
      public function unpauseAllSounds() : void
      {
         this.system.unpause();
      }
      
      public function get currentMusicId() : String
      {
         return !!this._currentMusicDef ? this._currentMusicDef.soundName : null;
      }
      
      public function get currentMusicParams() : Dictionary
      {
         return !!this._currentMusicDef ? this._currentMusicParams : null;
      }
      
      public function get currentMusicEvent() : String
      {
         return !!this._currentMusicDef ? this._currentMusicDef.eventName : null;
      }
      
      private function _setCurrentMusicParam(param1:String, param2:Number) : void
      {
         if(this._currentMusicDef)
         {
            this._currentMusicParams[param1] = param2;
         }
      }
      
      private function setCurrentMusicDef(param1:ISoundDef, param2:Boolean = true) : void
      {
         if(param1 == this._currentMusicDef)
         {
            return;
         }
         if(param2)
         {
            this.system.music = null;
         }
         if(this.currentMusicBundle)
         {
            this.currentMusicBundle.removeListener(this);
            this.currentMusicBundle = null;
         }
         this._currentMusicDef = param1;
         this._currentMusicParams = new Dictionary();
         this.checkForCurrentMusicBundle();
      }
      
      public function prepareEventBundle(param1:String, param2:String) : ISoundDefBundle
      {
         if(!param2)
         {
            return null;
         }
         if(!param1)
         {
            param1 = this.getSkuFromEvent(param2);
         }
         var _loc3_:ISoundDef = this.getSoundDef(param1,param2);
         return this.prepareDefBundle(_loc3_);
      }
      
      public function prepareDefBundle(param1:ISoundDef) : ISoundDefBundle
      {
         if(!param1)
         {
            return null;
         }
         var _loc2_:Vector.<ISoundDef> = new Vector.<ISoundDef>();
         _loc2_.push(param1);
         return this.system.driver.preloadSoundDefData("sagasound-" + param1.eventName,_loc2_);
      }
      
      public function setMusicParam(param1:String, param2:String, param3:String, param4:Number) : void
      {
         if(Boolean(param2) && param2 == this.currentMusicEvent)
         {
            this._setCurrentMusicParam(param3,param4);
         }
         var _loc5_:ISound = this.system.music;
         if(!_loc5_ || !param2)
         {
            return;
         }
         if(!param1)
         {
            param1 = this.getSkuFromEvent(param2);
         }
         if(_loc5_.def.eventName == param2 && _loc5_.def.sku == param1)
         {
            _loc5_.setParameter(param3,param4);
         }
      }
      
      public function playMusicOneShot(param1:String, param2:String, param3:String, param4:Number) : ISound
      {
         this.setCurrentMusicDef(null);
         if(!param2)
         {
            return null;
         }
         if(!param1)
         {
            param1 = this.getSkuFromEvent(param2);
         }
         var _loc5_:ISoundDef = this.getSoundDef(param1,param2);
         return this.playSoundDef(_loc5_,param3,param4);
      }
      
      public function playMusicIncidental(param1:String, param2:String, param3:String, param4:Number) : ISound
      {
         if(!param2)
         {
            return null;
         }
         if(!param1)
         {
            param1 = this.getSkuFromEvent(param2);
         }
         var _loc5_:ISoundDef = this.getSoundDef(param1,param2);
         return this.playSoundDef(_loc5_,param3,param4);
      }
      
      public function playSoundDef(param1:ISoundDef, param2:String, param3:Number) : ISound
      {
         if(!param1)
         {
            return null;
         }
         var _loc4_:ISound = this.system.playMusicDef(param1);
         if(_loc4_)
         {
            if(param2)
            {
               _loc4_.setParameter(param2,param3);
            }
         }
         return _loc4_;
      }
      
      public function setCurrentMusicById(param1:String) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:ISoundDef = null;
         if(!param1)
         {
            return;
         }
         var _loc2_:int = param1.indexOf(":");
         if(_loc2_ > 0)
         {
            _loc3_ = param1.substr(0,_loc2_);
            _loc4_ = param1.substr(_loc2_ + 1);
            _loc5_ = this.getSoundDef(_loc3_,_loc4_);
            this.setCurrentMusicDef(_loc5_);
         }
         else
         {
            this.logger.info("SagaSound.playMusicStartById cannot restore from [" + param1 + "]");
         }
      }
      
      public function playMusicStart(param1:String, param2:String, param3:String, param4:Number) : ISound
      {
         if(!param2)
         {
            return null;
         }
         if(!param1)
         {
            param1 = this.getSkuFromEvent(param2);
         }
         var _loc5_:ISoundDef = this.getSoundDef(param1,param2);
         this.setCurrentMusicDef(_loc5_);
         this.ensureCurrentMusicIdPlaying();
         var _loc6_:ISound = this.system.music;
         if(_loc6_)
         {
            if(param3)
            {
               _loc6_.setParameter(param3,param4);
               this._setCurrentMusicParam(param3,param4);
            }
         }
         return _loc6_;
      }
      
      public function stopMusic(param1:String, param2:String) : void
      {
         var _loc3_:ISound = null;
         if(!param2)
         {
            this.setCurrentMusicDef(null,true);
            this.system.music = null;
         }
         else
         {
            if(!param1)
            {
               param1 = this.getSkuFromEvent(param2);
            }
            _loc3_ = this.system.music;
            if(_loc3_ && _loc3_.def.eventName == param2 && _loc3_.def.sku == param1)
            {
               this.setCurrentMusicDef(null,true);
               this.system.music = null;
            }
         }
      }
      
      public function outroMusic(param1:String, param2:String) : void
      {
         var _loc4_:Boolean = false;
         if(!param1)
         {
            param1 = this.getSkuFromEvent(param2);
         }
         var _loc3_:ISound = this.system.music;
         if(!param2)
         {
            param2 = !!_loc3_ ? _loc3_.def.eventName : null;
            param1 = !!_loc3_ ? _loc3_.def.sku : null;
         }
         if(Boolean(_loc3_) && (_loc3_.def.eventName == param2 && _loc3_.def.sku == param1))
         {
            if(Boolean(param2) && this.system.driver.hasEventParameter(param2,"complete"))
            {
               _loc4_ = this.system.driver.setEventParameterValueByName(_loc3_.systemid,"complete",1);
               if(_loc4_)
               {
                  this.setCurrentMusicDef(null,false);
                  return;
               }
               this.saga.logger.error("outroMusic failed [" + param2 + "]");
            }
         }
         this.setCurrentMusicDef(null);
      }
      
      public function getSkuFromEvent(param1:String) : String
      {
         if(!param1)
         {
            return null;
         }
         return this.system.driver.inferSkuFromEventPath(param1);
      }
      
      public function getSoundDef(param1:String, param2:String) : ISoundDef
      {
         if(!param1)
         {
            param1 = this.getSkuFromEvent(param2);
         }
         var _loc3_:String = param1 + ":" + param2;
         var _loc4_:SoundDef = this.defs[_loc3_];
         if(!_loc4_)
         {
            _loc4_ = new SoundDef();
            _loc4_.setup(param1,_loc3_,param2);
            this.defs[_loc3_] = _loc4_;
         }
         return _loc4_;
      }
      
      public function releaseCurrentMusicBundle(param1:String) : void
      {
         if(this.currentMusicBundle)
         {
            this.logger.info("SagaSound.releaseCurrentMusicBundle [" + this.currentMusicBundle.id + "] (" + param1 + ")");
            this.currentMusicBundle.removeListener(this);
            this.currentMusicBundle = null;
         }
      }
      
      private function checkForCurrentMusicBundle() : void
      {
         if(this._currentMusicDef)
         {
            if(!this.currentMusicBundle)
            {
               this.currentMusicBundle = this.prepareDefBundle(this._currentMusicDef);
               if(this.currentMusicBundle)
               {
                  this.currentMusicBundle.addListener(this);
               }
            }
         }
         else if(this.currentMusicBundle)
         {
            this.currentMusicBundle.removeListener(this);
            this.currentMusicBundle = null;
         }
      }
      
      private function prepareCampMusicSituation() : void
      {
         var _loc2_:Number = NaN;
         var _loc1_:ISound = this.system.music;
         if(Boolean(_loc1_) && _loc1_.playing)
         {
            this.campMusicWaitingForWindow = true;
            if(!this.campMusicAction || _loc1_ != this.campMusicAction.sound)
            {
               this.logger.info("SagaSound.prepareCampMusicSituation attempt to stop music " + _loc1_);
               if(this.system.driver.hasEventParameter(_loc1_.def.eventName,"complete"))
               {
                  _loc2_ = this.system.driver.getEventParameterValueByName(_loc1_.systemid,"complete");
                  if(_loc2_ < 1)
                  {
                     this.system.driver.setEventParameterValueByName(_loc1_.systemid,"complete",1);
                  }
               }
               else if(_loc1_.def.soundName == this.currentMusicId)
               {
                  _loc1_.stop(false);
               }
            }
            return;
         }
         if(!this.campMusicAction || this.campMusicAction.ended)
         {
            if(!this.saga.convo || this.saga.convo.finished)
            {
               if(this.campMusicWaitingForWindow)
               {
                  this.saga.campMusic.resetCampMusicTimer();
                  this.campMusicWaitingForWindow = false;
               }
               else
               {
                  this.campMusicAction = this.saga.campMusic.checkCampMusic();
               }
            }
         }
      }
      
      public function checkReleaseCurrentMusicBundle() : void
      {
         var _loc1_:Scene = null;
         if(!this.saga || this.saga.cleanedup)
         {
            return;
         }
         if(!this.saga.camped)
         {
            if(!this.saga.sceneLoaded)
            {
               return;
            }
            _loc1_ = this.saga.getScene();
            if(_loc1_.landscape.travel)
            {
               return;
            }
         }
         this.releaseCurrentMusicBundle("checkRelease");
      }
      
      public function checkMusicSituation() : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:Boolean = false;
         var _loc1_:ISound = this.system.music;
         if(this.saga.camped)
         {
            _loc2_ = this.saga.getVar(SagaVar.VAR_TRAVEL_MUSIC_IN_CAMP,VariableType.BOOLEAN).asBoolean;
            if(!_loc2_)
            {
               _loc3_ = this.saga.getVar(SagaVar.VAR_CAMP_MUSIC_SUPPRESSED,VariableType.BOOLEAN).asBoolean;
               if(!_loc3_)
               {
                  if(!this.saga.isTravelScene)
                  {
                     this.prepareCampMusicSituation();
                     return;
                  }
               }
            }
         }
         if(!_loc1_ || !_loc1_.playing)
         {
            if(_loc1_)
            {
               this.system.music = null;
            }
            this.ensureCurrentMusicIdPlaying();
         }
      }
      
      public function ensureCurrentMusicIdPlaying() : void
      {
         var _loc1_:ISound = null;
         var _loc2_:* = null;
         var _loc3_:Number = NaN;
         if(!this.sagadef || !this._currentMusicDef)
         {
            return;
         }
         this._musicShouldBePlaying = true;
         this.checkForCurrentMusicBundle();
         if(this.currentMusicBundle)
         {
            if(this.currentMusicBundle.ok)
            {
               _loc1_ = this.system.playMusicDef(this._currentMusicDef);
               for(_loc2_ in this._currentMusicParams)
               {
                  _loc3_ = Number(this._currentMusicParams[_loc2_]);
                  _loc1_.setParameter(_loc2_,_loc3_);
               }
            }
         }
      }
      
      public function soundDefBundleComplete(param1:ISoundDefBundle) : void
      {
         if(this._musicShouldBePlaying)
         {
            this.ensureCurrentMusicIdPlaying();
         }
      }
      
      public function interruptMusicBattleTransition() : void
      {
         var _loc2_:Number = NaN;
         var _loc1_:ISound = this.system.music;
         if(Boolean(_loc1_) && _loc1_.playing)
         {
            this.system.controller.playSound("FX1_short",null);
            _loc2_ = 1;
            TweenMax.delayedCall(_loc2_,this._killMusicForBattleTransition,[_loc1_]);
         }
      }
      
      private function _killMusicForBattleTransition(param1:ISound) : void
      {
         if(param1 == this.system.music)
         {
            this.system.music = null;
         }
      }
      
      public function loadSagaSoundResources(param1:Function) : void
      {
         this._loadedCallback = param1;
         this._music = new SoundController(this.sagadef.id + "_music",this.system.driver,this.musicReadyHandler,this.logger);
         this._music.library = this.sagadef.music;
         this._vo = new SoundController(this.sagadef.id + "_vo",this.system.driver,this.voReadyHandler,this.logger);
         this._vo.library = this.sagadef.vo;
      }
      
      private function musicReadyHandler(param1:SoundController) : void
      {
         if(this.loaded)
         {
            return;
         }
         this.checkLoaded();
      }
      
      private function voReadyHandler(param1:SoundController) : void
      {
         if(this.loaded)
         {
            return;
         }
         this.checkLoaded();
      }
      
      private function checkLoaded() : void
      {
         var _loc1_:Function = null;
         if(this.loaded)
         {
            return;
         }
         if(!this.vo || !this.vo.complete)
         {
            return;
         }
         if(!this.sagadef)
         {
            return;
         }
         if(this.sagadef.music)
         {
            if(!this._music || !this._music.complete)
            {
               return;
            }
         }
         this._loaded = true;
         if(this._loadedCallback != null)
         {
            _loc1_ = this._loadedCallback;
            this._loadedCallback = null;
            _loc1_(this);
         }
      }
      
      public function get system() : ISoundSystem
      {
         return this._system;
      }
      
      public function get loaded() : Boolean
      {
         return this._loaded;
      }
      
      public function get vo() : SoundController
      {
         return this._vo;
      }
      
      public function get music() : SoundController
      {
         return this._music;
      }
   }
}
