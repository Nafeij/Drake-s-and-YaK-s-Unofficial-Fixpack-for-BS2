package engine.battle.board.view.phantasm
{
   import engine.battle.ability.effect.model.EffectTag;
   import engine.battle.ability.phantasm.def.PhantasmDefSound;
   import engine.battle.ability.phantasm.def.PhantasmTargetMode;
   import engine.battle.ability.phantasm.def.SoundParamInfo;
   import engine.battle.ability.phantasm.model.ChainPhantasms;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.entity.model.BattleEntity;
   import engine.math.MathUtil;
   import engine.sound.ISoundDriver;
   import engine.sound.NullSoundDriver;
   import engine.sound.view.ISound;
   import engine.sound.view.ISoundController;
   import engine.stat.def.StatType;
   import flash.utils.Dictionary;
   
   public class PhantasmViewSound extends PhantasmView
   {
       
      
      private var defSound:PhantasmDefSound;
      
      private var sound:ISound;
      
      private var soundController:ISoundController;
      
      public var paramsTracking:Dictionary;
      
      public function PhantasmViewSound(param1:BattleBoardView, param2:ChainPhantasms, param3:PhantasmDefSound)
      {
         super(param1,param2,param3);
         this.defSound = param3;
      }
      
      override public function toString() : String
      {
         return "PhantasmViewSound " + super.toString();
      }
      
      override public function execute() : void
      {
         var _loc2_:BattleEntity = null;
         super.execute();
         var _loc1_:ISoundDriver = boardView.board._scene.context.soundDriver;
         if(!_loc1_ || !_loc1_.system.mixer.sfxEnabled)
         {
            return;
         }
         switch(def.targetMode)
         {
            case PhantasmTargetMode.CASTER:
               _loc2_ = chain.effect.ability.caster as BattleEntity;
               break;
            case PhantasmTargetMode.TARGET:
               if(chain.effect.target)
               {
                  _loc2_ = chain.effect.target as BattleEntity;
                  if(chain.effect.hasTag(EffectTag.KILLING))
                  {
                     if(this.defSound.isVocalizeGetHit)
                     {
                        return;
                     }
                  }
               }
               break;
            case PhantasmTargetMode.TILE:
               _loc2_ = chain.effect.ability.caster as BattleEntity;
               break;
            case PhantasmTargetMode.GUI:
               break;
            default:
               throw new ArgumentError("unsupported targetMode: " + def.targetMode);
         }
         this.sound = this._discoverSoundController(_loc2_);
         if(!this.sound)
         {
            logger.error("No sound discovered for " + this + " soundId=" + this.defSound.sound);
            this.soundController = null;
            this.sound = null;
            return;
         }
         if(!this.sound.def.eventName)
         {
            logger.info("null eventname for " + this + " sound=" + this.sound);
            this.soundController = null;
            this.sound = null;
            return;
         }
         this._playSound();
      }
      
      private function _playSound() : void
      {
         var _loc1_:String = null;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         if(!this.sound)
         {
            return;
         }
         this.sound.start();
         for(_loc1_ in this.sound.def.parameterValues)
         {
            _loc2_ = Number(this.sound.def.parameterValues[_loc1_]);
            this.sound.setParameter(_loc1_,_loc2_);
         }
         if(this.sound.def.hasParameter("intensity") && !this.sound.def.hasParameterValue("intensity"))
         {
            _loc3_ = chain.effect.ability.def.level;
            _loc4_ = Math.min(1,(_loc3_ - 1) / 3);
            this.sound.setParameter("intensity",_loc4_);
         }
         if(this.sound.def.hasParameter("damage") && !this.sound.def.hasParameterValue("damage"))
         {
            _loc5_ = chain.effect.getAnnotatedStatChange(StatType.STRENGTH);
            _loc6_ = chain.effect.getAnnotatedStatChange(StatType.ARMOR);
            _loc7_ = Math.max(0,Math.min(1,-_loc5_ / 9));
            _loc8_ = Math.max(0,Math.min(1,-_loc6_ / 5));
            _loc9_ = _loc7_ + _loc8_;
            this.sound.setParameter("damage",_loc9_);
         }
         if(!this.sound.systemid)
         {
            logger.error("PhantasmViewSound [" + def + "] failed to start sound " + this.sound);
            this.sound.start();
         }
         else if(this.sound.isLooping())
         {
            needsRemove = true;
         }
         this._gatherSoundParamInfos();
      }
      
      private function _gatherSoundParamInfos() : void
      {
         var _loc1_:SoundParamInfo = null;
         var _loc2_:SoundTrackingInfo = null;
         if(!this.defSound.params || this.defSound.params.length == 0)
         {
            return;
         }
         for each(_loc1_ in this.defSound.params)
         {
            if(_loc1_.timeMs <= 0)
            {
               this.sound.setParameter(_loc1_.id,_loc1_.value);
            }
            else
            {
               if(!this.paramsTracking)
               {
                  this.paramsTracking = new Dictionary();
               }
               _loc2_ = new SoundTrackingInfo();
               _loc2_.spi = _loc1_;
               if(_loc1_.id == "volume")
               {
                  _loc2_.startValue = 1;
               }
               else
               {
                  _loc2_.startValue = this.sound.getParameter(_loc1_.id);
               }
               this.paramsTracking[_loc1_.id] = _loc2_;
               needsUpdate = true;
            }
         }
      }
      
      private function attemptSoundController(param1:ISoundController) : ISound
      {
         var _loc2_:ISound = null;
         if(param1)
         {
            if(!(param1.soundDriver is NullSoundDriver))
            {
               _loc2_ = param1.getSound(this.defSound.sound,null,false);
               if(_loc2_)
               {
                  return _loc2_;
               }
            }
         }
         return null;
      }
      
      private function _discoverSoundController(param1:BattleEntity) : ISound
      {
         var _loc2_:ISoundController = null;
         _loc2_ = !!param1 ? param1.soundController : null;
         this.sound = this.attemptSoundController(_loc2_);
         if(this.sound)
         {
            this.soundController = _loc2_;
            return this.sound;
         }
         _loc2_ = boardView.board.soundController;
         this.sound = this.attemptSoundController(_loc2_);
         if(this.sound)
         {
            this.soundController = _loc2_;
            return this.sound;
         }
         _loc2_ = boardView.board._scene._context.staticSoundController;
         this.sound = this.attemptSoundController(_loc2_);
         if(this.sound)
         {
            this.soundController = _loc2_;
            return this.sound;
         }
         this.soundController = null;
         return null;
      }
      
      override public function remove() : void
      {
         if(this.sound && this.sound.playing && this.sound.isLooping())
         {
            this.sound.stop(false);
            this.sound = null;
         }
         needsUpdate = needsRemove = false;
      }
      
      override public function update(param1:int) : Boolean
      {
         var _loc2_:Boolean = false;
         var _loc3_:String = null;
         var _loc4_:SoundTrackingInfo = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         super.update(param1);
         if(this.paramsTracking)
         {
            if(Boolean(this.sound) && this.sound.playing)
            {
               for(_loc3_ in this.paramsTracking)
               {
                  _loc4_ = this.paramsTracking[_loc3_];
                  if(!(!_loc4_ || !_loc4_.spi))
                  {
                     _loc4_.elapsedMs += param1;
                     _loc5_ = Math.min(_loc4_.elapsedMs / _loc4_.spi.timeMs,1);
                     _loc6_ = MathUtil.lerp(_loc4_.startValue,_loc4_.spi.value,_loc5_);
                     if(_loc3_ == "volume")
                     {
                        this.sound.setVolume(_loc6_);
                     }
                     else
                     {
                        this.sound.setParameter(_loc3_,_loc6_);
                     }
                     if(_loc5_ >= 1)
                     {
                        _loc4_.spi = null;
                     }
                     else
                     {
                        _loc2_ = true;
                     }
                  }
               }
               if(!_loc2_)
               {
                  this.paramsTracking = null;
                  needsUpdate = false;
               }
            }
         }
         return needsRemove || needsUpdate;
      }
   }
}

import engine.battle.ability.phantasm.def.SoundParamInfo;

class SoundTrackingInfo
{
    
   
   public var curValue:Number;
   
   public var startValue:Number = 0;
   
   public var elapsedMs:int;
   
   public var spi:SoundParamInfo;
   
   public function SoundTrackingInfo()
   {
      super();
   }
}
