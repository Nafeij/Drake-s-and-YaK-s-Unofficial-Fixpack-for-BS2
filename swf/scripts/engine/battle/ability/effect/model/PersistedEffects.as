package engine.battle.ability.effect.model
{
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.model.BattleAbilityRetargetInfo;
   import engine.battle.ability.model.IBattleAbility;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.logging.ILogger;
   import engine.core.util.ArrayUtil;
   import engine.core.util.StringUtil;
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class PersistedEffects extends EventDispatcher implements IPersistedEffects
   {
       
      
      public var target:IBattleEntity;
      
      public var _effects:Vector.<IEffect>;
      
      public var casted:Vector.<IEffect>;
      
      private var _locked:Boolean;
      
      private var effectsNeedPurge:Boolean;
      
      private var castedEffectsNeedPurge:Boolean;
      
      private var logger:ILogger;
      
      private var deferredEffectAdds:Vector.<IEffect>;
      
      private var tags:Dictionary;
      
      private var addingDeferred:Boolean;
      
      private var _scratchCopyEffects:Vector.<IEffect>;
      
      public function PersistedEffects(param1:IBattleEntity, param2:ILogger)
      {
         this._effects = new Vector.<IEffect>();
         this.casted = new Vector.<IEffect>();
         this.deferredEffectAdds = new Vector.<IEffect>();
         this.tags = new Dictionary();
         this._scratchCopyEffects = new Vector.<IEffect>(1);
         super();
         this.target = param1;
         this.logger = param2;
      }
      
      private static function purgeRemovedEffectsFrom(param1:Vector.<IEffect>, param2:Boolean) : void
      {
         var _loc3_:IEffect = null;
         var _loc4_:int = int(param1.length);
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            _loc3_ = param1[_loc5_];
            if(_loc3_.phase == EffectPhase.REMOVED)
            {
               _loc4_--;
               param1[_loc5_] = param1[_loc4_];
               param1[_loc4_] = _loc3_;
            }
            else
            {
               _loc5_++;
            }
         }
         if(_loc4_ < param1.length)
         {
            param1.splice(_loc4_,param1.length - _loc4_);
         }
      }
      
      public function getDebugString() : String
      {
         var _loc1_:String = "";
         _loc1_ += "target=" + this.target + "\n";
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < this._effects.length)
         {
            _loc1_ += "Effect " + StringUtil.padLeft(_loc2_.toString()," ",2) + " " + this._effects[_loc2_] + "\n";
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < this.casted.length)
         {
            _loc1_ += "Casted " + StringUtil.padLeft(_loc2_.toString()," ",2) + " " + this.casted[_loc2_] + "\n";
            _loc2_++;
         }
         return _loc1_ + ("TAGS: " + ArrayUtil.getDictionaryKeys(this.tags).join(",") + "\n");
      }
      
      public function handleTargetDeath() : void
      {
         var _loc1_:IEffect = null;
         for each(_loc1_ in this.effects)
         {
            if(_loc1_.phase == EffectPhase.APPLIED || _loc1_.phase == EffectPhase.COMPLETED)
            {
               (_loc1_ as Effect).handleTargetDeath();
            }
         }
      }
      
      public function get effects() : Vector.<IEffect>
      {
         return this._effects;
      }
      
      public function cleanup() : void
      {
         this.locked = true;
         var _loc1_:int = 0;
         while(_loc1_ < this.effects.length)
         {
            this.effects[_loc1_].cleanup();
            _loc1_++;
         }
         this.locked = false;
      }
      
      public function addCastedEffect(param1:IEffect) : AddEffectResponse
      {
         if(this.locked)
         {
            return AddEffectResponse.DELAY;
         }
         this.casted.push(param1);
         return AddEffectResponse.SUCCESS;
      }
      
      public function findCastedChildEffects(param1:IBattleAbility, param2:IBattleEntity) : IEffect
      {
         var _loc3_:IEffect = null;
         for each(_loc3_ in this.casted)
         {
            if(_loc3_.target == param2 && _loc3_.ability.parent == param1)
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      public function addEffect(param1:IEffect) : AddEffectResponse
      {
         var _loc3_:IBattleEntity = null;
         var _loc4_:EffectTag = null;
         if(this.locked)
         {
            this.deferredEffectAdds.push(param1);
            this.logger.debug("PersistedEffect.addEffect " + param1 + " deferring because [" + _loc3_ + "] is currently locked.");
            return AddEffectResponse.DELAY;
         }
         var _loc2_:IBattleAbility = param1.ability;
         if(!_loc2_)
         {
            this.logger.error("PersistedEffect.addEffect " + param1 + " no ability");
            return AddEffectResponse.FAILED;
         }
         _loc3_ = _loc2_.caster;
         if(!_loc3_)
         {
            this.logger.error("PersistedEffect.addEffect " + param1 + " no ability caster");
            return AddEffectResponse.FAILED;
         }
         if(!_loc3_.effects)
         {
            this.logger.error("PersistedEffect.addEffect " + param1 + " no persisted effects for ability caster " + _loc3_);
            return AddEffectResponse.FAILED;
         }
         if(!_loc2_.manager)
         {
            this.logger.error("PersistedEffect.addEffect " + param1 + " no manager");
            return AddEffectResponse.FAILED;
         }
         if(_loc3_.effects.addCastedEffect(param1) == AddEffectResponse.DELAY)
         {
            this.deferredEffectAdds.push(param1);
            this.logger.debug("PersistedEffect.addEffect " + param1 + " deferring the addition of the casted effect casted by [" + _loc3_ + "] because the target [" + this.target + "] is currently locked.");
            return AddEffectResponse.DELAY;
         }
         this._effects.push(param1);
         _loc2_.manager.notifyPersistedAbilityEffectAdded(_loc2_,param1);
         for each(_loc4_ in param1.tags)
         {
            this.addTag(_loc4_);
         }
         dispatchEvent(new PersistedEffectsEvent(PersistedEffectsEvent.CHANGED));
         return AddEffectResponse.SUCCESS;
      }
      
      private function removeCastedEffect(param1:IEffect) : void
      {
         var _loc2_:int = this.casted.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.casted.splice(_loc2_,1);
         }
      }
      
      public function handleEndTurn() : void
      {
         var _loc1_:IEffect = null;
         for each(_loc1_ in this.casted)
         {
            if(_loc1_.phase == EffectPhase.APPLIED || _loc1_.phase == EffectPhase.COMPLETED)
            {
               (_loc1_ as Effect).casterEndTurn();
            }
         }
         for each(_loc1_ in this.effects)
         {
            if(_loc1_.phase == EffectPhase.APPLIED || _loc1_.phase == EffectPhase.COMPLETED)
            {
               (_loc1_ as Effect).targetEndTurn();
            }
         }
      }
      
      public function handleStartTurn() : void
      {
         if(this._locked)
         {
            throw new IllegalOperationError("not re-entrant (yet)");
         }
         this.locked = true;
         this._makeScratchCopyEffects(this.casted);
         this._notifyScratchCopyEffectsCasterStartTurn();
         this._makeScratchCopyEffects(this.effects);
         this._notifyScratchCopyEffectsTargetStartTurn();
         this.locked = false;
      }
      
      private function _makeScratchCopyEffects(param1:Vector.<IEffect>) : void
      {
         if(param1.length > this._scratchCopyEffects.length)
         {
            this._scratchCopyEffects = new Vector.<IEffect>(param1.length * 1.5);
         }
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            this._scratchCopyEffects[_loc2_] = param1[_loc2_];
            _loc2_++;
         }
         if(_loc2_ < this._scratchCopyEffects.length)
         {
            this._scratchCopyEffects[_loc2_] = null;
         }
      }
      
      private function _notifyScratchCopyEffectsCasterStartTurn() : void
      {
         var _loc2_:IEffect = null;
         var _loc1_:int = 0;
         while(_loc1_ < this._scratchCopyEffects.length)
         {
            _loc2_ = this._scratchCopyEffects[_loc1_];
            if(_loc2_ == null)
            {
               break;
            }
            if(_loc2_.phase == EffectPhase.APPLIED || _loc2_.phase == EffectPhase.COMPLETED)
            {
               _loc2_.casterStartTurn();
            }
            _loc1_++;
         }
      }
      
      private function _notifyScratchCopyEffectsTargetStartTurn() : void
      {
         var _loc2_:IEffect = null;
         var _loc1_:int = 0;
         while(_loc1_ < this._scratchCopyEffects.length)
         {
            _loc2_ = this._scratchCopyEffects[_loc1_];
            if(_loc2_ == null)
            {
               break;
            }
            if(_loc2_.phase == EffectPhase.APPLIED || _loc2_.phase == EffectPhase.COMPLETED)
            {
               _loc2_.targetStartTurn();
            }
            _loc1_++;
         }
      }
      
      private function _notifyScratchCopyEffectsTurnChanged() : void
      {
         var _loc2_:IEffect = null;
         var _loc1_:int = 0;
         while(_loc1_ < this._scratchCopyEffects.length)
         {
            _loc2_ = this._scratchCopyEffects[_loc1_];
            if(_loc2_ == null)
            {
               break;
            }
            if(_loc2_.phase == EffectPhase.APPLIED || _loc2_.phase == EffectPhase.COMPLETED)
            {
               _loc2_.turnChanged();
            }
            _loc1_++;
         }
      }
      
      public function handleTurnChanged() : void
      {
         if(this._locked)
         {
            throw new IllegalOperationError("not re-entrant (yet)");
         }
         this.locked = true;
         this._makeScratchCopyEffects(this.effects);
         this._notifyScratchCopyEffectsTurnChanged();
         this.locked = false;
      }
      
      private function purgeRemovedEffects() : void
      {
         if(this.castedEffectsNeedPurge)
         {
            this.castedEffectsNeedPurge = false;
            purgeRemovedEffectsFrom(this.casted,false);
         }
         if(this.effectsNeedPurge)
         {
            this.effectsNeedPurge = false;
            purgeRemovedEffectsFrom(this._effects,true);
            dispatchEvent(new PersistedEffectsEvent(PersistedEffectsEvent.CHANGED));
         }
      }
      
      public function onCasterEffectPhaseChange(param1:IEffect) : void
      {
         if(param1.phase == EffectPhase.REMOVED)
         {
            if(this.hasCastedEffect(param1))
            {
               this.castedEffectsNeedPurge = true;
            }
         }
      }
      
      public function onTargetEffectPhaseChange(param1:IEffect) : void
      {
         var _loc2_:IPersistedEffects = null;
         var _loc3_:EffectTag = null;
         if(param1.phase == EffectPhase.REMOVED)
         {
            if(this.hasEffect(param1))
            {
               _loc2_ = this.target.effects;
               if(_loc2_)
               {
                  for each(_loc3_ in param1.tags)
                  {
                     if(_loc2_.hasTag(_loc3_))
                     {
                        _loc2_.removeTag(_loc3_);
                     }
                  }
               }
               this.effectsNeedPurge = true;
               dispatchEvent(new PersistedEffectsEvent(PersistedEffectsEvent.CHANGED));
               param1.ability.manager.notifyPersistedAbilityEffectRemoved(param1.ability,param1);
            }
         }
      }
      
      public function onAbilityExecutingOnTarget(param1:IBattleAbility) : BattleAbilityRetargetInfo
      {
         var _loc2_:IEffect = null;
         var _loc3_:BattleAbilityRetargetInfo = null;
         this.locked = true;
         for each(_loc2_ in this.effects)
         {
            if(_loc2_.phase == EffectPhase.APPLIED || _loc2_.phase == EffectPhase.COMPLETED)
            {
               _loc3_ = _loc2_.onAbilityExecutingOnTarget(param1);
               if(_loc3_)
               {
                  this.locked = false;
                  return _loc3_;
               }
            }
         }
         this.locked = false;
         return null;
      }
      
      public function get locked() : Boolean
      {
         return this._locked;
      }
      
      public function set locked(param1:Boolean) : void
      {
         if(this._locked != param1)
         {
            this._locked = param1;
            if(this._locked)
            {
               if(this.addingDeferred)
               {
                  throw new IllegalOperationError("locked while addingDeferred");
               }
            }
            else
            {
               this.purgeRemovedEffects();
            }
         }
      }
      
      public function hasEffect(param1:IEffect) : Boolean
      {
         return this.effects.indexOf(param1) >= 0;
      }
      
      public function hasCastedEffect(param1:IEffect) : Boolean
      {
         return this.casted.indexOf(param1) >= 0;
      }
      
      private function tagCount(param1:EffectTag) : int
      {
         var _loc2_:* = this.tags[param1];
         return _loc2_ != undefined ? int(_loc2_) : 0;
      }
      
      public function hasTag(param1:EffectTag) : Boolean
      {
         return this.tagCount(param1) > 0;
      }
      
      public function removeTag(param1:EffectTag) : void
      {
         var _loc2_:int = this.tagCount(param1);
         if(_loc2_ <= 0)
         {
            throw new IllegalOperationError("fail tag count");
         }
         _loc2_--;
         this.tags[param1] = _loc2_;
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("PersistedEffects.removeTag " + this.target + " " + param1 + " " + _loc2_);
         }
      }
      
      public function addTag(param1:EffectTag) : void
      {
         var _loc2_:int = this.tagCount(param1) + 1;
         this.tags[param1] = _loc2_;
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("PersistedEffects.addTag " + this.target + " " + param1 + " " + _loc2_);
         }
      }
      
      public function clearTag(param1:EffectTag) : void
      {
         if(this.hasTag(param1))
         {
            this.tags[param1] = 0;
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("PersistedEffects.clearTag " + this.target + " " + param1);
            }
         }
      }
      
      public function getBattleAbilitiesByDef(param1:IBattleAbilityDef) : Vector.<IBattleAbility>
      {
         return this.getBattleAbilitiesById(param1.id);
      }
      
      public function hasBattleAbilitiesByDef(param1:IBattleAbilityDef) : Boolean
      {
         var _loc2_:IEffect = null;
         for each(_loc2_ in this._effects)
         {
            if(_loc2_.ability.def.id == param1.id)
            {
               return true;
            }
         }
         return false;
      }
      
      public function getBattleAbilitiesById(param1:String) : Vector.<IBattleAbility>
      {
         var _loc2_:Vector.<IBattleAbility> = null;
         var _loc3_:IEffect = null;
         for each(_loc3_ in this._effects)
         {
            if(_loc3_.ability.def.id == param1)
            {
               if(!_loc2_)
               {
                  _loc2_ = new Vector.<IBattleAbility>();
               }
               _loc2_.push(_loc3_.ability);
            }
         }
         return _loc2_;
      }
      
      public function handleTransferDamage(param1:IEffect, param2:int) : void
      {
         var _loc3_:IEffect = null;
         for each(_loc3_ in this._effects)
         {
            _loc3_.handleTransferDamage(param1,param2);
         }
      }
      
      public function update(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:IEffect = null;
         if(this.deferredEffectAdds.length)
         {
            this.addingDeferred = true;
            _loc2_ = int(this.deferredEffectAdds.length - 1);
            while(_loc2_ >= 0)
            {
               _loc3_ = ArrayUtil.removeAt(this.deferredEffectAdds,_loc2_) as IEffect;
               this.logger.debug("PersistedEffect.update - Processing an effect [" + _loc3_ + "] for caster [" + _loc3_.ability.caster + "] on [" + this + "]");
               if(this.addEffect(_loc3_) == AddEffectResponse.SUCCESS)
               {
                  this.logger.debug("PersistedEffect.update - SUCCESSFULLY processed an effect [" + _loc3_ + "] for caster [" + _loc3_.ability.caster + "] on [" + this + "]");
                  _loc3_.ability.manager.notifyPersistedAbilityEffectAdded(_loc3_.ability,_loc3_);
               }
               _loc2_--;
            }
            this.addingDeferred = false;
         }
         this.purgeRemovedEffects();
      }
      
      public function getDebugTagInfo() : String
      {
         var _loc2_:Object = null;
         var _loc3_:EffectTag = null;
         var _loc1_:String = "";
         for(_loc2_ in this.tags)
         {
            if(_loc2_ is EffectTag)
            {
               _loc3_ = _loc2_ as EffectTag;
               _loc1_ += _loc3_.name + " " + this.tagCount(_loc3_).toString() + ", ";
            }
         }
         if(_loc1_.length > 0)
         {
            _loc1_ = _loc1_.slice(0,_loc1_.length - 2);
         }
         return _loc1_;
      }
   }
}
