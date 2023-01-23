package engine.scene.model
{
   import engine.core.logging.ILogger;
   import engine.landscape.def.ILandscapeDef;
   import engine.landscape.def.LandscapeDef;
   import engine.saga.vars.IVariableBag;
   import engine.saga.vars.VariableEvent;
   import engine.scene.def.SceneAudioDef;
   import engine.scene.def.SceneAudioEmitterDef;
   import engine.scene.def.SceneAudioEmitterDefAudibility;
   import engine.sound.ISoundDefBundle;
   import engine.sound.config.ISoundSystem;
   import engine.sound.def.ISoundDef;
   import engine.sound.def.SoundDef;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   
   public class SceneAudio extends EventDispatcher implements ISceneAudio
   {
       
      
      public var scene:Scene;
      
      public var def:SceneAudioDef;
      
      private var listener:Point;
      
      public var audDefs:Vector.<SceneAudioEmitterDefAudibility> = null;
      
      public var auds:Dictionary;
      
      public var complete:Boolean = false;
      
      private var _listenerZ:Number = 0;
      
      private var bundle:ISoundDefBundle;
      
      public var extraEmitters:Vector.<SceneAudioEmitterDef>;
      
      private var extraEmitterBundles:Vector.<ISoundDefBundle>;
      
      public var soundSystem:ISoundSystem;
      
      private var landscapeDef:ILandscapeDef;
      
      private var _pitchSemitones:Number = 0;
      
      private var _enabled:Boolean = true;
      
      public var logger:ILogger;
      
      private var globals:IVariableBag;
      
      private var listenGlobals:Dictionary;
      
      private var updateNumber:int = 0;
      
      private var oldCartPoint:Point;
      
      private var dirty:Boolean;
      
      public function SceneAudio(param1:Scene)
      {
         var _loc2_:Boolean = false;
         var _loc3_:SceneAudioEmitterDef = null;
         this.listener = new Point(Number.MAX_VALUE,Number.MAX_VALUE);
         this.auds = new Dictionary();
         this.extraEmitters = new Vector.<SceneAudioEmitterDef>();
         this.extraEmitterBundles = new Vector.<ISoundDefBundle>();
         this.oldCartPoint = new Point();
         super();
         this.logger = param1.logger;
         this.scene = param1;
         this.def = param1._def.audio;
         this.soundSystem = param1._context.soundDriver.system;
         this.globals = !!param1._context.saga ? param1._context.saga.global : null;
         if(this.def)
         {
            this.def.addEventListener(SceneAudioDef.EVENT_EMITTERS,this.audioEmittersHandler);
            if(this.globals)
            {
               _loc2_ = false;
               for each(_loc3_ in this.def.emitters)
               {
                  _loc2_ = this.cacheGlobal(_loc3_.condition_if,_loc3_) || _loc2_;
                  _loc2_ = this.cacheGlobal(_loc3_.condition_not,_loc3_) || _loc2_;
               }
               if(_loc2_)
               {
                  this.globals.addEventListener(VariableEvent.TYPE,this.globalVariableHandler);
               }
            }
         }
         this.landscapeDef = param1._def.landscape;
         if(this.landscapeDef)
         {
            this.landscapeDef.addEventListener(LandscapeDef.EVENT_LAYERS,this.layersHandler);
         }
         param1._context.soundDriver.set3dListenerPosition(0,0,0,0);
      }
      
      private function cacheGlobal(param1:String, param2:SceneAudioEmitterDef) : Boolean
      {
         if(!param1)
         {
            return false;
         }
         if(!this.listenGlobals)
         {
            this.listenGlobals = new Dictionary();
         }
         this.listenGlobals[param1] = param2;
         return true;
      }
      
      private function globalVariableHandler(param1:VariableEvent) : void
      {
         var _loc2_:SceneAudioEmitterDef = this.listenGlobals[param1.value.def.name];
         if(_loc2_)
         {
            _loc2_.dirty = true;
         }
      }
      
      public function set pitchSemitones(param1:Number) : void
      {
         if(this._pitchSemitones == param1)
         {
            return;
         }
         this._pitchSemitones = param1;
         this.dirty = true;
      }
      
      public function get pitchSemitones() : Number
      {
         return this._pitchSemitones;
      }
      
      public function addExtraEmitter(param1:SceneAudioEmitterDef) : void
      {
         if(!param1)
         {
            throw new ArgumentError("fail");
         }
         this.extraEmitters.push(param1);
         this.dirty = true;
      }
      
      public function addExtraGlobalSoundDef(param1:String) : void
      {
         if(!param1)
         {
            throw new ArgumentError("invalid sound def id");
         }
         var _loc2_:ISoundDef = this.soundSystem.controller.library.getSoundDef(param1);
         if(!_loc2_)
         {
            this.logger.error("SceneAudio " + this + " no such sound [" + param1 + "]");
            return;
         }
         var _loc3_:SceneAudioEmitterDef = this.createExtraSoundDefEmitter(_loc2_);
         this.addExtraEmitter(_loc3_);
      }
      
      public function addExtraGlobalSoundEvent(param1:String, param2:String, param3:String, param4:Number, param5:ISoundDefBundle = null) : void
      {
         if(!param1)
         {
            throw new ArgumentError("invalid sound event");
         }
         var _loc6_:SceneAudioEmitterDef = this.createExtraSoundEventEmitter(param1,param2,param3,param4);
         this.addExtraEmitter(_loc6_);
         if(param5)
         {
            param5.addListener(this);
            this.extraEmitterBundles.push(param5);
         }
      }
      
      private function createExtraSoundDefEmitter(param1:ISoundDef) : SceneAudioEmitterDef
      {
         return this.createExtraSoundEventEmitter(param1.eventName,param1.sku,null,0);
      }
      
      private function createExtraSoundEventEmitter(param1:String, param2:String, param3:String, param4:Number) : SceneAudioEmitterDef
      {
         var _loc5_:SceneAudioEmitterDef = new SceneAudioEmitterDef();
         _loc5_.source = new Rectangle(-100000,-100000,200000,200000);
         _loc5_.event = param1;
         _loc5_.sku = param2;
         if(param3)
         {
            _loc5_.paramNames.push(param3);
            _loc5_.paramValues.push(param4);
         }
         return _loc5_;
      }
      
      public function preload() : void
      {
         var _loc2_:SceneAudioEmitterDef = null;
         var _loc3_:String = null;
         var _loc4_:SoundDef = null;
         var _loc1_:Vector.<ISoundDef> = new Vector.<ISoundDef>();
         if(this.def)
         {
            for each(_loc2_ in this.def.emitters)
            {
               _loc4_ = new SoundDef().setup(_loc2_.sku,_loc2_.event,_loc2_.event);
               _loc1_.push(_loc4_);
            }
         }
         for each(_loc2_ in this.extraEmitters)
         {
            _loc4_ = new SoundDef().setup(_loc2_.sku,_loc2_.event,_loc2_.event);
            _loc1_.push(_loc4_);
         }
         _loc3_ = !!this.def ? this.def.url : (!!this.scene ? "scene-auto-audio:" + this.scene._def.url : "scene-unknown-audio");
         this.bundle = this.scene._context.soundDriver.preloadSoundDefData(_loc3_,_loc1_);
         this.bundle.addListener(this);
      }
      
      public function soundDefBundleComplete(param1:ISoundDefBundle) : void
      {
         this.complete = true;
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      public function cleanup() : void
      {
         var _loc1_:SceneAudioEmitterAudible = null;
         var _loc2_:ISoundDefBundle = null;
         this.soundSystem = null;
         if(this.scene)
         {
            this.scene = null;
         }
         if(this.globals)
         {
            this.globals.removeEventListener(VariableEvent.TYPE,this.globalVariableHandler);
            this.globals = null;
         }
         if(this.landscapeDef)
         {
            this.landscapeDef.removeEventListener(LandscapeDef.EVENT_LAYERS,this.layersHandler);
            this.landscapeDef = null;
         }
         if(this.def)
         {
            this.def.removeEventListener(SceneAudioDef.EVENT_EMITTERS,this.audioEmittersHandler);
            this.def = null;
         }
         this.extraEmitters = null;
         for each(_loc1_ in this.auds)
         {
            _loc1_.cleanup();
         }
         this.auds = null;
         this.audDefs = null;
         this.logger = null;
         if(this.bundle)
         {
            this.bundle.removeListener(this);
            this.bundle = null;
         }
         if(Boolean(this.extraEmitterBundles) && Boolean(this.extraEmitterBundles.length))
         {
            for each(_loc2_ in this.extraEmitterBundles)
            {
               _loc2_.removeListener(this);
            }
            this.extraEmitterBundles.length = 0;
         }
         this.extraEmitterBundles = null;
      }
      
      private function audioEmittersHandler(param1:Event) : void
      {
         this.audDefs = null;
      }
      
      private function layersHandler(param1:Event) : void
      {
         this.audDefs = null;
      }
      
      public function makeDirty() : void
      {
         this.dirty = true;
      }
      
      public function update() : void
      {
         var _loc3_:SceneAudioEmitterAudible = null;
         var _loc4_:SceneAudioEmitterDef = null;
         var _loc5_:SceneAudioEmitterDefAudibility = null;
         if(this.soundSystem && !this.soundSystem.mixer.sfxEnabled || !this.scene)
         {
            this.dirty = true;
            return;
         }
         if(!this._enabled)
         {
            this.dirty = true;
            return;
         }
         var _loc1_:Number = this.scene._camera.x;
         var _loc2_:Number = this.scene._camera.y;
         if(!this.dirty)
         {
            if(_loc1_ == this.listener.x && _loc2_ == this.listener.y)
            {
               for each(_loc4_ in this.extraEmitters)
               {
                  if(_loc4_.dirty)
                  {
                     this.dirty = true;
                     break;
                  }
               }
               if(!this.dirty)
               {
                  return;
               }
            }
         }
         this.dirty = false;
         ++this.updateNumber;
         this.listener.setTo(_loc1_,_loc2_);
         if(this.def)
         {
            this.audDefs = this.def.updateAudibilitiesForListener(this.scene._camera,this.audDefs,this.extraEmitters,this.scene.landscape,this.globals);
         }
         else
         {
            this.audDefs = SceneAudioDef._updateAudibilitiesForListener(this.scene._camera,this.audDefs,this.extraEmitters,this.scene.landscape,this.globals);
         }
         if(this.audDefs)
         {
            for each(_loc5_ in this.audDefs)
            {
               if(_loc5_.audible)
               {
                  _loc3_ = this.auds[_loc5_.emitter];
                  if(!_loc3_)
                  {
                     _loc3_ = new SceneAudioEmitterAudible(this,_loc5_.emitter);
                     this.auds[_loc5_.emitter] = _loc3_;
                  }
                  _loc3_.play(this.updateNumber,_loc5_);
               }
            }
         }
         for each(_loc3_ in this.auds)
         {
            if(_loc3_.updateNumber != this.updateNumber)
            {
               if(_loc3_.systemid)
               {
                  _loc3_.stop();
               }
            }
         }
      }
      
      public function get listenerZ() : Number
      {
         return this._listenerZ;
      }
      
      public function set listenerZ(param1:Number) : void
      {
         this._listenerZ = param1;
         if(!this.scene || !this.scene._context)
         {
            return;
         }
         this.scene._context.soundDriver.set3dListenerPosition(0,0,0,this._listenerZ);
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         var _loc2_:SceneAudioEmitterAudible = null;
         var _loc3_:SceneAudioEmitterDefAudibility = null;
         this._enabled = param1;
         if(!this._enabled)
         {
            if(this.audDefs)
            {
               for each(_loc3_ in this.audDefs)
               {
                  _loc2_ = this.auds[_loc3_.emitter];
                  if(_loc2_)
                  {
                     _loc2_.stop();
                  }
               }
               this.audDefs = null;
            }
         }
      }
   }
}
