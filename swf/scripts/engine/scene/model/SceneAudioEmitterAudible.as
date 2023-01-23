package engine.scene.model
{
   import engine.core.logging.ILogger;
   import engine.saga.ISaga;
   import engine.saga.SagaVar;
   import engine.saga.vars.IVariable;
   import engine.saga.vars.IVariableBag;
   import engine.saga.vars.Variable;
   import engine.saga.vars.VariableEvent;
   import engine.saga.vars.VariableType;
   import engine.scene.def.SceneAudioEmitterDef;
   import engine.scene.def.SceneAudioEmitterDefAudibility;
   import engine.sound.ISoundDriver;
   import engine.sound.ISoundEventId;
   import engine.sound.NullSoundDriver;
   import flash.utils.Dictionary;
   
   public class SceneAudioEmitterAudible
   {
      
      public static var PARAM_PAN:String = "pan";
      
      public static var PARAM_VOLUME:String = "volume";
      
      public static var PARAM_MORALE:String = "morale";
      
      public static var PARAM_WIND:String = "wind";
      
      public static var PARAM_NUM_POPULATION:String = "num_population";
      
      public static var PARAM_NUM_PEASANTS:String = "num_peasants";
      
      public static var PARAM_RENOWN:String = "renown";
      
      public static var PARAM_ARB_STATE:String = "vlg_arb_state";
      
      public static var MAX_DIST_3D:Number = 10000;
      
      public static var DEFAULT_Z_3D:Number = 0;
      
      public static var MAX_PAN_3D:Number = Math.sqrt(MAX_DIST_3D * MAX_DIST_3D - DEFAULT_Z_3D * DEFAULT_Z_3D);
      
      public static var REPORT_SET_FAILS:Boolean = true;
       
      
      public var emitter:SceneAudioEmitterDef;
      
      public var systemid:ISoundEventId = null;
      
      public var updateNumber:int = 0;
      
      public var audio:SceneAudio;
      
      public var volume:Number = 1;
      
      public var panX:Number = 0;
      
      public var morale:Number = 0;
      
      public var wind:Number = 0;
      
      public var numPopulation:Number = 0;
      
      public var numPeasants:Number = 0;
      
      public var renown:Number = 0;
      
      public var hasWind:Boolean;
      
      public var hasMorale:Boolean;
      
      public var hasNumPopulation:Boolean;
      
      public var hasNumPeasants:Boolean;
      
      public var hasRenown:Boolean;
      
      public var error:Boolean;
      
      private var driver:ISoundDriver;
      
      public var logger:ILogger;
      
      private var paramIndexes:Dictionary;
      
      public var lastVolume:Number = 1;
      
      public var lastPitchSemitones:Number = 0;
      
      public var lastPan3d:Number = 0;
      
      private var saga:ISaga;
      
      private var globalVars:IVariableBag;
      
      private var caravanVars:IVariableBag;
      
      private var _lastParams:Dictionary;
      
      public function SceneAudioEmitterAudible(param1:SceneAudio, param2:SceneAudioEmitterDef)
      {
         this.paramIndexes = new Dictionary();
         super();
         this.emitter = param2;
         this.audio = param1;
         this.driver = param1.scene._context.soundDriver;
         this.logger = param1.scene._context.logger;
         this.saga = param1.scene._context.saga;
         this.caravanVars = !!this.saga ? this.saga.caravanVars : null;
         this.globalVars = !!this.saga ? this.saga.global : null;
         if(this.globalVars)
         {
            this.globalVars.addEventListener(VariableEvent.TYPE,this.globalVariableHandler);
         }
         if(this.caravanVars)
         {
            this.caravanVars.addEventListener(VariableEvent.TYPE,this.variableHandler);
         }
      }
      
      private function globalVariableHandler(param1:VariableEvent) : void
      {
         var _loc2_:Variable = param1.value;
         if(_loc2_.def.name == SagaVar.VLG_ARB_STATE)
         {
            this.emitter.dirty = true;
         }
      }
      
      private function variableHandler(param1:VariableEvent) : void
      {
         var _loc2_:Variable = param1.value;
         if(this.hasWind && _loc2_.def.name == SagaVar.VAR_WEATHER_WIND)
         {
            this.emitter.dirty = true;
         }
         else if(this.hasMorale && _loc2_.def.name == SagaVar.VAR_MORALE)
         {
            this.emitter.dirty = true;
         }
         else if(this.hasNumPopulation && _loc2_.def.name == SagaVar.VAR_NUM_POPULATION)
         {
            this.emitter.dirty = true;
         }
         else if(this.hasNumPeasants && _loc2_.def.name == SagaVar.VAR_NUM_PEASANTS)
         {
            this.emitter.dirty = true;
         }
         else if(this.hasRenown && _loc2_.def.name == SagaVar.VAR_RENOWN)
         {
            this.emitter.dirty = true;
         }
      }
      
      public function cleanup() : void
      {
         this.stop();
         if(this.caravanVars)
         {
            this.caravanVars.removeEventListener(VariableEvent.TYPE,this.variableHandler);
         }
         if(this.globalVars)
         {
            this.globalVars.removeEventListener(VariableEvent.TYPE,this.globalVariableHandler);
         }
         this.caravanVars = null;
         this.globalVars = null;
         this.saga = null;
      }
      
      public function stop() : void
      {
         if(Boolean(this.systemid) && this.driver.isPlaying(this.systemid))
         {
            if(this.logger.isDebugEnabled)
            {
            }
            this.driver.stopEvent(this.systemid,false);
         }
         this.systemid = null;
         this.updateNumber = 0;
      }
      
      public function toString() : String
      {
         return this.systemid.toString() + "/" + this.emitter.event;
      }
      
      public function play(param1:int, param2:SceneAudioEmitterDefAudibility) : void
      {
         var _loc3_:int = 0;
         var _loc5_:IVariable = null;
         if(!this.driver.system || !this.driver.system.enabled || !this.driver.system.mixer.sfxEnabled || this.driver is NullSoundDriver)
         {
            return;
         }
         this.updateNumber = param1;
         if(this.error)
         {
            return;
         }
         this.panX = param2.panX;
         this.volume = param2.volume;
         if(!this.systemid)
         {
            this.start();
         }
         if(!this.systemid)
         {
            return;
         }
         if(this.saga)
         {
            if(this.hasWind)
            {
               _loc5_ = this.saga.getVar(SagaVar.VAR_WEATHER_WIND,VariableType.DECIMAL);
               if(_loc5_)
               {
                  this.wind = Math.abs(_loc5_.asNumber);
                  this.wind = Math.min(0.3,Math.min(1,this.wind / 20));
               }
            }
            if(Boolean(this.caravanVars) && Boolean(this.caravanVars.vars))
            {
               if(this.hasMorale)
               {
                  this.morale = this.caravanVars.fetch(SagaVar.VAR_MORALE,VariableType.INTEGER).asNumber;
                  this.morale = Math.min(1,this.morale / 20);
               }
               if(this.hasNumPopulation)
               {
                  this.numPopulation = this.caravanVars.fetch(SagaVar.VAR_NUM_POPULATION,VariableType.INTEGER).asNumber;
                  this.numPopulation = Math.min(1,this.numPopulation / 6000);
               }
               if(this.hasNumPeasants)
               {
                  this.numPeasants = this.caravanVars.fetch(SagaVar.VAR_NUM_PEASANTS,VariableType.INTEGER).asNumber;
                  this.numPeasants = Math.min(1,this.numPopulation / 2000);
               }
               if(this.hasRenown)
               {
                  this.renown = this.caravanVars.fetch(SagaVar.VAR_RENOWN,VariableType.INTEGER).asNumber;
                  this.renown = Math.min(1,this.renown / 50);
               }
            }
            _loc3_ = int(this.saga.getVar(SagaVar.VLG_ARB_STATE,VariableType.INTEGER).asNumber);
         }
         this.setParam(PARAM_PAN,this.panX);
         this.setParam(PARAM_VOLUME,this.volume);
         this.setParam(PARAM_WIND,this.wind);
         this.setParam(PARAM_MORALE,this.morale);
         this.setParam(PARAM_NUM_POPULATION,this.numPopulation);
         this.setParam(PARAM_NUM_PEASANTS,this.numPeasants);
         this.setParam(PARAM_RENOWN,this.renown);
         this.setParam(PARAM_ARB_STATE,_loc3_);
         var _loc4_:Number = -this.panX * MAX_DIST_3D;
         if(Math.abs(this.lastPan3d - _loc4_) > 1)
         {
            this.lastPan3d = _loc4_;
            if(!this.driver.set3dEventPosition(this.systemid,_loc4_,0,DEFAULT_Z_3D))
            {
               if(REPORT_SET_FAILS)
               {
                  this.logger.error("SceneAudioEmitterAudible problem setting 3d position for " + this + ", pan3d=" + _loc4_ + " isPlaying=" + this.driver.isPlaying(this.systemid));
               }
               this.error = true;
            }
         }
         if(Math.abs(this.lastVolume - param2.volume) > 0.01)
         {
            this.lastVolume = param2.volume;
            if(!this.driver.setEventVolume(this.systemid,param2.volume))
            {
               if(REPORT_SET_FAILS)
               {
                  this.logger.error("SceneAudioEmitterAudible problem setting volume for " + this + " isPlaying=" + this.driver.isPlaying(this.systemid));
               }
               this.error = true;
            }
         }
         if(this.lastPitchSemitones != this.audio.pitchSemitones)
         {
            this.lastPitchSemitones = this.audio.pitchSemitones;
            if(!this.driver.setEventPitchSemitones(this.systemid,this.lastPitchSemitones))
            {
               if(REPORT_SET_FAILS)
               {
                  this.logger.error("SceneAudioEmitterAudible problem setting pitch for " + this + " isPlaying=" + this.driver.isPlaying(this.systemid));
               }
               this.error = true;
            }
         }
      }
      
      private function setParam(param1:String, param2:Number) : void
      {
         var _loc3_:* = this.paramIndexes[param1];
         if(_loc3_ == null || _loc3_ == undefined)
         {
            return;
         }
         if(!this._lastParams)
         {
            this._lastParams = new Dictionary();
         }
         var _loc4_:* = this._lastParams[param1];
         if(_loc4_ != undefined && param2 == _loc4_)
         {
            return;
         }
         this._lastParams[param1] = param2;
         var _loc5_:int = _loc3_;
         if(_loc5_ >= 0)
         {
            if(!this.driver.setEventParameterValue(this.systemid,_loc5_,param2))
            {
               if(REPORT_SET_FAILS)
               {
                  this.logger.error("SceneAudioEmitterAudible problem setting PARAM " + param1 + this + " isPlaying=" + this.driver.isPlaying(this.systemid));
               }
               this.error = true;
            }
         }
      }
      
      private function start() : void
      {
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:Number = NaN;
         this.systemid = this.driver.playEvent(this.emitter.event);
         if(!this.systemid)
         {
            this.logger.error("SceneAudioEmitterAudible emitter [" + this.emitter.labelString + "] failed to play for scene [" + this.audio.def.url + "]");
            this.error = true;
            return;
         }
         if(this.logger.isDebugEnabled)
         {
         }
         this.error = false;
         var _loc1_:int = this.driver.getNumEventParameters(this.systemid);
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            _loc3_ = this.driver.getEventParameterName(this.systemid,_loc2_);
            if(this.emitter.paramNames)
            {
               _loc4_ = this.emitter.paramNames.indexOf(_loc3_);
               if(_loc4_ >= 0)
               {
                  _loc5_ = Number(this.emitter.paramValues[_loc4_]);
                  if(!this.driver.setEventParameterValue(this.systemid,_loc2_,_loc5_))
                  {
                     this.audio.scene._context.logger.error("SceneAudioEmitterAudible emitter [" + this.emitter.labelString + "] invalid parameter [" + _loc3_ + "] index [" + _loc2_ + "]");
                  }
               }
            }
            this.paramIndexes[_loc3_] = _loc2_;
            this.hasMorale = this.hasMorale || _loc3_ == PARAM_MORALE;
            this.hasNumPopulation = this.hasNumPopulation || _loc3_ == PARAM_NUM_POPULATION;
            this.hasNumPeasants = this.hasNumPeasants || _loc3_ == PARAM_NUM_PEASANTS;
            this.hasRenown = this.hasRenown || _loc3_ == PARAM_RENOWN;
            this.hasWind = this.hasWind || _loc3_ == PARAM_WIND;
            _loc2_++;
         }
      }
   }
}
