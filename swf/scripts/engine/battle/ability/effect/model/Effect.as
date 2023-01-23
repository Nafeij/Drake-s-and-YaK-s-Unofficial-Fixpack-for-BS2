package engine.battle.ability.effect.model
{
   import com.greensock.TweenMax;
   import engine.battle.ability.def.BattleAbilityResponseTargetType;
   import engine.battle.ability.def.BattleAbilityTag;
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.effect.def.EffectDefPersistence;
   import engine.battle.ability.effect.def.EffectStackRule;
   import engine.battle.ability.effect.def.IEffectDef;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.effect.op.model.IOp;
   import engine.battle.ability.effect.op.model.Op;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.BattleAbilityEvent;
   import engine.battle.ability.model.BattleAbilityManager;
   import engine.battle.ability.model.BattleAbilityRetargetInfo;
   import engine.battle.ability.model.IBattleAbility;
   import engine.battle.ability.model.IBattleAbilityManager;
   import engine.battle.ability.phantasm.model.ChainPhantasms;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.core.locale.LocaleCategory;
   import engine.core.logging.ILogger;
   import engine.entity.def.EntityDef;
   import engine.expression.ISymbols;
   import engine.saga.ISaga;
   import engine.saga.SagaInstance;
   import engine.stat.def.StatType;
   import engine.stat.model.IStatModProvider;
   import engine.stat.model.StatMod;
   import engine.stat.model.Stats;
   import engine.talent.TalentRankDef;
   import engine.tile.Tile;
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class Effect extends EventDispatcher implements IEffect, IEffectTagProvider, IStatModProvider
   {
      
      public static var executing:Boolean = false;
      
      private static var BLOCK_TIMEOUT_SEC:int = 10;
       
      
      public var _def:IEffectDef;
      
      private var _ability:IBattleAbility;
      
      public var _result:EffectResult;
      
      public var applied:Boolean;
      
      public var useCount:int;
      
      public var casterTurnCount:int;
      
      public var targetTurnCount:int;
      
      public var turnChangeCount:int;
      
      private var _phase:EffectPhase;
      
      public var ops:Vector.<Op>;
      
      private var _tags:Dictionary;
      
      private var _target:IBattleEntity;
      
      public var tile:Tile;
      
      private var _waitForAbility:IBattleAbility;
      
      public var chain:ChainPhantasms;
      
      public var removeReason:EffectRemoveReason;
      
      private var _blockedComplete:int = 0;
      
      public var directionalFlags:int = 0;
      
      public var logger:ILogger;
      
      public var manager:BattleAbilityManager;
      
      public var cleanedup:Boolean;
      
      private var _talentsByEntity:Dictionary;
      
      private var _processedAnnotations:Boolean;
      
      private var _talentSkipTags:Dictionary;
      
      private var readyToApply:Boolean;
      
      private var annotatedStatChanges:Stats;
      
      private var _timeoutAbilityLastId:int;
      
      private var _timeoutAbilityIncompleteTicker:int;
      
      private var _timeoutBoardTileConfiguration:int;
      
      private var _tweenTimeout:TweenMax;
      
      public function Effect(param1:IBattleAbility, param2:IEffectDef, param3:IBattleEntity, param4:Tile)
      {
         var _loc5_:EffectTag = null;
         this.ops = new Vector.<Op>();
         this._tags = new Dictionary();
         this.removeReason = EffectRemoveReason.DEFAULT;
         super();
         this.target = param3;
         this.tile = param4;
         this.ability = param1;
         this.manager = param1.manager as BattleAbilityManager;
         this.logger = param1.manager.getLogger;
         this._def = param2;
         for each(_loc5_ in param2.tags)
         {
            this.tags[_loc5_] = _loc5_;
         }
      }
      
      public function tagsToString() : String
      {
         var _loc2_:EffectTag = null;
         var _loc1_:String = "[";
         for each(_loc2_ in this.tags)
         {
            _loc1_ += _loc2_.name + ",";
         }
         return _loc1_ + "]";
      }
      
      public function get target() : IBattleEntity
      {
         return this._target;
      }
      
      public function set target(param1:IBattleEntity) : void
      {
         this._target = param1;
      }
      
      public function cleanup() : void
      {
         if(this.cleanedup)
         {
            throw new IllegalOperationError("double cleanup");
         }
         this.cleanedup = true;
         if(this._tweenTimeout)
         {
            this._tweenTimeout.kill();
            this._tweenTimeout = null;
         }
         this.removeReason = EffectRemoveReason.CLEANUP;
         this.remove();
      }
      
      override public function toString() : String
      {
         var _loc1_:String = this.ability.getId + " " + this.ability.def.id + "/" + this._def.name;
         return "[" + _loc1_ + " " + this.ability.caster + " -> " + this.target + "]";
      }
      
      public function addTag(param1:EffectTag) : void
      {
         this.tags[param1] = param1;
         if(this.manager.faking)
         {
            return;
         }
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("Effect " + this + " added tag " + param1.name);
         }
         if(Boolean(this.target.effects) && this.target.effects.hasEffect(this))
         {
            this.target.effects.addTag(param1);
         }
      }
      
      public function addEntityEffectTalent(param1:IBattleEntity, param2:TalentRankDef) : void
      {
         if(!this._talentsByEntity)
         {
            this._talentsByEntity = new Dictionary();
         }
         var _loc3_:Vector.<TalentRankDef> = this._talentsByEntity[param1];
         if(!_loc3_)
         {
            _loc3_ = new Vector.<TalentRankDef>();
            this._talentsByEntity[param1] = _loc3_;
         }
         _loc3_.push(param2);
      }
      
      public function hasTag(param1:EffectTag) : Boolean
      {
         return this.tags[param1] != null;
      }
      
      public function execute() : EffectResult
      {
         var edo:EffectDefOp = null;
         if(!this.manager.faking && !this._ability.fake)
         {
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("Effect.execute EXECUTING " + this.ability.caster.id + " " + this + " target=" + this.target + " tile=" + this.tile);
               if(Boolean(this.target) && this.target.id.indexOf("fighter_archer_b") >= 0)
               {
                  this.target = this.target;
               }
            }
         }
         else if(this.hasTag(EffectTag.NO_FAKING))
         {
            this._result = EffectResult.FAIL;
            this.phase = EffectPhase.EXECUTED;
            return this._result;
         }
         if(executing)
         {
            throw new IllegalOperationError("do not re-enter effect execution");
         }
         this.phase = EffectPhase.EXECUTING;
         executing = true;
         for each(edo in this._def.ops)
         {
            try
            {
               this.executeOp(edo);
            }
            catch(e:Error)
            {
               logger.error("Effect.execute failed to executeOp " + edo + " on effect " + this + ":\n" + e.getStackTrace());
            }
         }
         if(!this.manager.faking && !this._ability.fake)
         {
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("Effect.execute EXECUTED " + this + " result=" + this._result);
            }
         }
         this.phase = EffectPhase.EXECUTED;
         executing = false;
         if(this._result == null)
         {
            this._result = EffectResult.OK;
         }
         return this._result;
      }
      
      public function executeOp(param1:EffectDefOp) : void
      {
         var _loc2_:Op = param1.construct(this) as Op;
         this.ops.push(_loc2_);
         if(!this.manager.faking && !this.ability.fake)
         {
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("Effect.executeOp " + _loc2_);
            }
         }
         var _loc3_:EffectResult = _loc2_.execute();
         _loc2_.result = _loc3_;
         if(!this.manager.faking && !this.ability.fake)
         {
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("Effect.executeOp " + _loc2_ + " result=" + _loc2_.result);
            }
         }
         this._result = _loc3_.combineUp(this._result);
      }
      
      private function checkPreStack() : Boolean
      {
         var _loc1_:Effect = null;
         if(!this._def.persistent)
         {
            return true;
         }
         if(this.target && this.target.effects && Boolean(this.target.effects.effects))
         {
            if(this._def.persistent.stack != EffectStackRule.STACK)
            {
               for each(_loc1_ in this.target.effects.effects)
               {
                  if(_loc1_.ability.def.root == this.ability.def.root && _loc1_._def.name == this._def.name)
                  {
                     if(this._def.persistent.stack == EffectStackRule.REPLACE_LOWER)
                     {
                        if(_loc1_.ability.def.level >= this.ability.def.level)
                        {
                           if(this.logger.isDebugEnabled)
                           {
                              this.logger.debug("Effect.checkPreStack persist " + this.ability.caster.id + " cannot replace");
                           }
                           return false;
                        }
                     }
                     if(this._def.persistent.stack == EffectStackRule.REPLACE_LOWER_EQUAL)
                     {
                        if(_loc1_.ability.def.level > this.ability.def.level)
                        {
                           if(this.logger.isDebugEnabled)
                           {
                              this.logger.debug("Effect.checkPreStack persist " + this.ability.caster.id + " cannot replace");
                           }
                           return false;
                        }
                     }
                     if(this._def.persistent.stack == EffectStackRule.IGNORE)
                     {
                        return false;
                     }
                  }
               }
            }
         }
         return true;
      }
      
      public function apply() : void
      {
         var canStack:Boolean;
         var op:Op = null;
         var other:Effect = null;
         var k:Object = null;
         var e:IBattleEntity = null;
         var v:Vector.<TalentRankDef> = null;
         var trd:TalentRankDef = null;
         if(!this.manager.faking && !this._ability.fake)
         {
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("Effect.apply " + this.ability.caster.id + " " + this);
            }
         }
         if(this.applied)
         {
            return;
         }
         if(this._waitForAbility)
         {
            if(!this._waitForAbility.completed)
            {
               this.readyToApply = true;
               if(this.logger.isDebugEnabled)
               {
                  this.logger.debug("Effect.apply deferring because _waitForAbility " + this._waitForAbility + " is not complete");
               }
               return;
            }
            this._waitForAbility = null;
         }
         this.applied = true;
         this.phase = EffectPhase.APPLYING;
         canStack = this.checkPreStack();
         if(!canStack)
         {
            this._result = EffectResult.FAIL;
         }
         else
         {
            for each(op in this.ops)
            {
               if(!this.manager.faking && !this.ability.fake)
               {
                  if(this.logger.isDebugEnabled)
                  {
                     this.logger.debug("Effect.apply " + this._def.name + " APPLY OP " + op);
                  }
               }
               try
               {
                  op.apply();
               }
               catch(e:Error)
               {
                  logger.error("Effect.apply " + this + " failed to apply op " + op + ":\n" + e.getStackTrace());
               }
            }
         }
         this.phase = EffectPhase.APPLIED;
         if(!this.manager.faking)
         {
            if(Boolean(this._target) && !this._target.alive)
            {
               if(this._ability.fake)
               {
                  throw new IllegalOperationError("killing effect in fake");
               }
               this._target.killingEffect = this;
            }
            if(Boolean(this._def.persistent) && this._result == EffectResult.OK)
            {
               if(this.logger.isDebugEnabled)
               {
                  this.logger.debug("Effect.apply persist " + this.ability.caster.id + " " + this);
               }
               if(this.target.effects)
               {
                  if(this._def.persistent.stack != EffectStackRule.STACK)
                  {
                     for each(other in this.target.effects.effects)
                     {
                        if(other.ability.def.root == this.ability.def.root && other._def.name == this._def.name)
                        {
                           if(this.logger.isDebugEnabled)
                           {
                              this.logger.debug("Effect.apply unstacking " + this.ability.caster.id + " " + this);
                           }
                           other.remove();
                        }
                     }
                  }
                  this._target.effects.addEffect(this);
                  this._ability.caster.addEventListener(BattleEntityEvent.ALIVE,this.handleCasterDeath);
                  this._target.addEventListener(BattleEntityEvent.ALIVE,this.handleCasterDeath);
               }
            }
         }
         if(!this.manager.faking && !this._ability.fake)
         {
            if(this._talentsByEntity)
            {
               for(k in this._talentsByEntity)
               {
                  e = k as IBattleEntity;
                  v = this._talentsByEntity[k];
                  for each(trd in v)
                  {
                     e.handleTalent(trd.talentDef);
                     if(e != this._target)
                     {
                        continue;
                     }
                     if(!this._talentSkipTags)
                     {
                        this._talentSkipTags = new Dictionary();
                     }
                     switch(trd.affectedStatType)
                     {
                        case StatType.RESIST_ARMOR:
                           this._talentSkipTags[EffectTag.RESISTING_ARMOR];
                           break;
                        case StatType.RESIST_STRENGTH:
                        case StatType.RESIST_STRENGTH_DREDGE:
                           this._talentSkipTags[EffectTag.RESISTING_STRENGTH];
                           break;
                        case StatType.KILL_STOP:
                           this._talentSkipTags[EffectTag.KILL_STOP];
                           break;
                        case StatType.DIVERT_CHANCE:
                           this._talentSkipTags[EffectTag.DIVERTING];
                           break;
                        case StatType.DODGE_BONUS:
                           this._talentSkipTags[EffectTag.DODGE];
                           break;
                     }
                  }
               }
            }
            if(this.checkTagForEmission(EffectTag.DODGE))
            {
               this._target.handleDodge(this);
            }
            else if(this._result == EffectResult.MISS)
            {
               this._target.handleMissed(this);
               this.checkSpeakMiss();
            }
            if(this.checkTagForEmission(EffectTag.KILL_STOP))
            {
               this._target.handleKillStop(this);
            }
            if(this.checkTagForEmission(EffectTag.TWICEBORN_FIRED))
            {
               this._target.handleTwiceBorn(this);
            }
            if(this.checkTagForEmission(EffectTag.RESISTING_STRENGTH))
            {
               this._target.handleResisted(this);
            }
            else if(this.checkTagForEmission(EffectTag.RESISTING_ARMOR))
            {
               this._target.handleResisted(this);
            }
            else if(this.checkTagForEmission(EffectTag.RESISTING_WILLPOWER))
            {
               this._target.handleResisted(this);
            }
            if(this.checkTagForEmission(EffectTag.DIVERTING))
            {
               this._target.handleDiverted(this);
            }
            if(this.hasTag(EffectTag.CRIT))
            {
               this._target.handleCrit(this);
            }
            if(this.checkTagForEmission(EffectTag.ABSORBING))
            {
               this._target.handleAbsorbing(this);
            }
            this._talentSkipTags = null;
         }
         this._processAnnotations();
      }
      
      private function _processAnnotations() : void
      {
         if(!this.annotatedStatChanges || this._processedAnnotations || this._ability.fake)
         {
            return;
         }
         this._processedAnnotations = true;
         var _loc1_:ISaga = SagaInstance.instance;
         if(!_loc1_ || !_loc1_.isSurvival)
         {
            return;
         }
         var _loc2_:int = this.annotatedStatChanges.getValue(StatType.STRENGTH);
         if(_loc2_ < 0)
         {
            if(this.target)
            {
               if(Boolean(this.ability.caster.isPlayer) && Boolean(this.target.isEnemy))
               {
                  _loc1_.incrementGlobalVar("survival_win_damage_done_num",-_loc2_);
               }
               else if(Boolean(this.ability.caster.isEnemy) && Boolean(this.target.isPlayer))
               {
                  _loc1_.incrementGlobalVar("survival_win_damage_taken_num",-_loc2_);
               }
            }
         }
      }
      
      private function checkSpeakMiss() : void
      {
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc1_:IBattleEntity = this.ability.caster;
         var _loc2_:IBattleEntity = this._target;
         if(!_loc1_.isPlayer || !_loc1_.active || !_loc1_.alive || !_loc1_.enabled || _loc1_.spawnedCaster != null || !EntityDef.canSpeak(_loc1_.def))
         {
            return;
         }
         if(this.ability.def.tag != BattleAbilityTag.ATTACK_STR)
         {
            return;
         }
         var _loc3_:ISaga = SagaInstance.instance;
         if(_loc3_)
         {
            _loc4_ = "tutorial_speak_miss_remaining";
            _loc5_ = int(_loc3_.getVarInt(_loc4_));
            if(_loc5_ > 0)
            {
               _loc3_.setVar(_loc4_,_loc5_ - 1);
               _loc6_ = _loc3_.locale.translate(LocaleCategory.TUTORIAL,"tut_speak_miss_" + _loc5_,true);
               if(!_loc6_)
               {
                  _loc6_ = _loc3_.locale.translate(LocaleCategory.TUTORIAL,"tut_speak_miss");
               }
               _loc3_.performSpeak(_loc1_,_loc1_.def,_loc6_,8,null,null,false);
            }
         }
      }
      
      private function checkTagForEmission(param1:EffectTag) : Boolean
      {
         if(this.hasTag(param1))
         {
            if(Boolean(this._talentSkipTags) && Boolean(this._talentSkipTags[param1]))
            {
               return false;
            }
            return true;
         }
         return false;
      }
      
      protected function handleCasterDeath(param1:BattleEntityEvent) : void
      {
         if(!param1.entity.alive)
         {
            this.checkExpiration();
         }
      }
      
      public function casterStartTurn() : Boolean
      {
         var _loc1_:Boolean = false;
         var _loc2_:Op = null;
         if(this.manager.faking)
         {
            return false;
         }
         for each(_loc2_ in this.ops)
         {
            _loc1_ = _loc2_.casterStartTurn() || _loc1_;
         }
         if(_loc1_)
         {
            ++this.useCount;
         }
         if(this._def.persistent)
         {
            if(this._def.persistent.durationOnTurnStart)
            {
               ++this.casterTurnCount;
               this.checkExpiration();
            }
         }
         return _loc1_;
      }
      
      public function casterEndTurn() : void
      {
         if(this.manager.faking)
         {
            return;
         }
         if(this._def.persistent)
         {
            if(!this._def.persistent.durationOnTurnStart)
            {
               ++this.casterTurnCount;
               this.checkExpiration();
            }
         }
      }
      
      public function targetStartTurn() : Boolean
      {
         var _loc2_:Op = null;
         if(this.manager.faking)
         {
            return false;
         }
         var _loc1_:Boolean = false;
         for each(_loc2_ in this.ops)
         {
            _loc1_ = _loc2_.targetStartTurn() || _loc1_;
         }
         if(_loc1_)
         {
            ++this.useCount;
         }
         if(this._def.persistent)
         {
            if(this._def.persistent.durationOnTurnStart)
            {
               ++this.targetTurnCount;
               this.checkExpiration();
            }
         }
         return _loc1_;
      }
      
      public function targetEndTurn() : void
      {
         if(this.manager.faking)
         {
            return;
         }
         if(this._def.persistent)
         {
            if(!this._def.persistent.durationOnTurnStart)
            {
               ++this.targetTurnCount;
               this.checkExpiration();
            }
         }
      }
      
      public function turnChanged() : Boolean
      {
         var _loc1_:Boolean = false;
         var _loc2_:Op = null;
         if(this.manager.faking)
         {
            return false;
         }
         for each(_loc2_ in this.ops)
         {
            _loc1_ = _loc2_.turnChanged() || _loc1_;
         }
         if(_loc1_)
         {
            ++this.useCount;
         }
         if(this._def.persistent)
         {
            ++this.turnChangeCount;
            this.checkExpiration();
         }
         return _loc1_;
      }
      
      public function handleTargetDeath() : void
      {
         if(this.manager.faking)
         {
            return;
         }
         if(this._def.persistent)
         {
            if(this._def.persistent.expireOnDeath || this._def.persistent.expireOnDeathTarget)
            {
               this.checkExpiration();
            }
         }
      }
      
      public function handleTransferDamage(param1:IEffect, param2:int) : void
      {
         var _loc3_:Op = null;
         for each(_loc3_ in this.ops)
         {
            _loc3_.handleTransferDamage(param1,param2);
         }
      }
      
      public function remove() : void
      {
         var _loc2_:Op = null;
         var _loc3_:Effect = null;
         if(this.manager.faking && !this._ability.fake)
         {
            return;
         }
         this.phase = EffectPhase.REMOVING;
         var _loc1_:IBattleEntity = this.ability.caster;
         _loc1_.removeEventListener(BattleEntityEvent.ALIVE,this.handleCasterDeath);
         this._target.removeEventListener(BattleEntityEvent.ALIVE,this.handleCasterDeath);
         for each(_loc2_ in this.ops)
         {
            _loc2_.remove();
         }
         if(Boolean(this._def.persistent) && this._def.persistent.linkedEffectName != null)
         {
            _loc3_ = this.ability.getEffectByName(this._def.persistent.linkedEffectName) as Effect;
            if(_loc3_ != null)
            {
               if(this.logger.isDebugEnabled)
               {
                  this.logger.debug("#### removing linked effect");
               }
               _loc3_.removeReason = EffectRemoveReason.LINKED_EFFECT;
               _loc3_.remove();
            }
         }
         this.phase = EffectPhase.REMOVED;
         this._handlePersistentRemoval();
      }
      
      private function _handlePersistentRemoval() : void
      {
         var _loc1_:EffectDefPersistence = this._def.persistent;
         if(!_loc1_)
         {
            return;
         }
         if(_loc1_.expireAbilityReasons)
         {
            if(!_loc1_.expireAbilityReasons[EffectRemoveReason.ANY])
            {
               if(!_loc1_.expireAbilityReasons[this.removeReason])
               {
                  return;
               }
            }
         }
         else if(this.removeReason != EffectRemoveReason.CASTER_DURATION && this.removeReason != EffectRemoveReason.TARGET_DURATION)
         {
            return;
         }
         this._processExpireAbility();
      }
      
      private function _processExpireAbility() : void
      {
         var _loc1_:EffectDefPersistence = this._def.persistent;
         if(!_loc1_ || !_loc1_.expireAbility)
         {
            return;
         }
         var _loc2_:IBattleEntity = this.ability.caster;
         var _loc3_:IBattleAbilityManager = this.ability.manager;
         if(!_loc3_)
         {
            return;
         }
         var _loc4_:IBattleAbilityDef = _loc2_.board.abilityManager.getFactory.fetchIBattleAbilityDef(this._def.persistent.expireAbility);
         var _loc5_:IBattleEntity = this.determinePersistentResponseEntity(_loc1_.expireAbilityResponseCaster,_loc2_,this._target);
         var _loc6_:IBattleEntity = this.determinePersistentResponseEntity(_loc1_.expireAbilityResponseTarget,_loc2_,this._target);
         if(_loc1_.expireAbilityResponseCasterRequireAlive && !_loc5_.alive)
         {
            return;
         }
         if(_loc6_)
         {
            if(_loc1_.expireAbilityResponseTargetRequireAlive && !_loc6_.alive)
            {
               return;
            }
         }
         var _loc7_:BattleAbility = new BattleAbility(_loc5_,_loc4_,_loc2_.board.abilityManager);
         if(_loc6_)
         {
            _loc7_.targetSet.addTarget(_loc6_);
         }
         _loc7_.execute(null);
      }
      
      private function determinePersistentResponseEntity(param1:BattleAbilityResponseTargetType, param2:IBattleEntity, param3:IBattleEntity) : IBattleEntity
      {
         if(!param1)
         {
            return null;
         }
         switch(param1)
         {
            case BattleAbilityResponseTargetType.CASTER:
            case BattleAbilityResponseTargetType.SELF:
               return param2;
            case BattleAbilityResponseTargetType.TARGET:
               return param3;
            case BattleAbilityResponseTargetType.NONE:
               return null;
            default:
               throw new ArgumentError("Invalid determinePersistentResponseEntity rule " + param1);
         }
      }
      
      protected function handleRemove() : void
      {
      }
      
      public function handleOpUsed(param1:IOp) : void
      {
         if(this.manager.faking && !this.ability.fake)
         {
            return;
         }
         ++this.useCount;
         this.checkExpiration();
         this.ability.manager.dispatchEvent(new BattleAbilityEvent(BattleAbilityEvent.PERSISTED_USED,this.ability,this));
      }
      
      public function handleStatModUsed(param1:StatMod) : void
      {
         if(this.manager.faking && !this.ability.fake)
         {
            return;
         }
         ++this.useCount;
         this.checkExpiration();
         this.ability.manager.dispatchEvent(new BattleAbilityEvent(BattleAbilityEvent.PERSISTED_USED,this.ability,this));
      }
      
      public function checkExpiration() : void
      {
         if(!this._def.persistent)
         {
            return;
         }
         if(this.phase == EffectPhase.REMOVED || this.phase == EffectPhase.REMOVING)
         {
            return;
         }
         if(!this.target.alive && (this._def.persistent.expireOnDeath || this._def.persistent.expireOnDeathTarget))
         {
            this.removeReason = EffectRemoveReason.TARGET_DEATH;
            this.remove();
         }
         else if(!this.ability.caster.alive && (this._def.persistent.expireOnDeath || this._def.persistent.expireOnDeathCaster))
         {
            this.removeReason = EffectRemoveReason.CASTER_DEATH;
            this.remove();
         }
         else if(this._def.persistent.numUses > 0 && this.useCount >= this._def.persistent.numUses)
         {
            this.removeReason = EffectRemoveReason.USE_COUNT;
            this.remove();
         }
         else if(this._def.persistent.casterDuration > 0 && this.casterTurnCount >= this._def.persistent.casterDuration)
         {
            this.removeReason = EffectRemoveReason.CASTER_DURATION;
            this.remove();
         }
         else if(this._def.persistent.targetDuration > 0 && this.targetTurnCount >= this._def.persistent.targetDuration)
         {
            this.removeReason = EffectRemoveReason.TARGET_DURATION;
            this.remove();
         }
         else if(this._def.persistent.turnChangedDuration > 0 && this.turnChangeCount >= this._def.persistent.turnChangedDuration)
         {
            this.removeReason = EffectRemoveReason.TURN_CHANGED_DURATION;
            this.remove();
         }
      }
      
      public function forceExpiration() : void
      {
         if(this.removed)
         {
            return;
         }
         this.removeReason = EffectRemoveReason.FORCED_EXPIRATION;
         this.remove();
      }
      
      public function get phase() : EffectPhase
      {
         return this._phase;
      }
      
      public function set phase(param1:EffectPhase) : void
      {
         if(this._phase != param1)
         {
            this._phase = param1;
            this._ability.onEffectPhaseChange(this);
            if(this._ability.caster.effects)
            {
               this._ability.caster.effects.onCasterEffectPhaseChange(this);
            }
            if(this._target.effects)
            {
               this._target.effects.onTargetEffectPhaseChange(this);
            }
            if(this._phase == EffectPhase.REMOVED)
            {
               dispatchEvent(new EffectEvent(EffectEvent.REMOVED));
            }
         }
      }
      
      public function getOpByName(param1:String) : Op
      {
         var _loc2_:Op = null;
         for each(_loc2_ in this.ops)
         {
            if(_loc2_.def.name == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function onAbilityExecutingOnTarget(param1:IBattleAbility) : BattleAbilityRetargetInfo
      {
         var _loc2_:Op = null;
         var _loc3_:BattleAbilityRetargetInfo = null;
         for each(_loc2_ in this.ops)
         {
            _loc3_ = _loc2_.onAbilityExecutingOnTarget(param1);
            if(_loc3_)
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      public function get waitForAbility() : IBattleAbility
      {
         return this._waitForAbility;
      }
      
      public function set waitForAbility(param1:IBattleAbility) : void
      {
         if(this._waitForAbility != param1)
         {
            if(this._waitForAbility)
            {
               this._waitForAbility.removeEventListener(BattleAbilityEvent.ABILITY_PRE_COMPLETE,this.waitForAbilityPreComplete);
            }
            this._waitForAbility = param1;
            if(this._waitForAbility)
            {
               this._waitForAbility.addEventListener(BattleAbilityEvent.ABILITY_PRE_COMPLETE,this.waitForAbilityPreComplete);
            }
         }
      }
      
      protected function waitForAbilityPreComplete(param1:BattleAbilityEvent) : void
      {
         if(param1.ability == this._waitForAbility)
         {
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("Effect.waitForAbilityPreComplete " + param1.ability);
            }
            this._waitForAbility = null;
            if(this.chain)
            {
               this.chain.onWaitAbilityComplete();
            }
            if(this.readyToApply)
            {
               this.apply();
            }
         }
      }
      
      public function get removed() : Boolean
      {
         return this.phase == EffectPhase.REMOVED;
      }
      
      public function get isStatModProviderRemoved() : Boolean
      {
         return this.removed;
      }
      
      public function get ability() : IBattleAbility
      {
         return this._ability;
      }
      
      public function set ability(param1:IBattleAbility) : void
      {
         this._ability = param1;
      }
      
      public function get tags() : Dictionary
      {
         return this._tags;
      }
      
      public function annotateStatChange(param1:StatType, param2:int) : void
      {
         if(!this.annotatedStatChanges)
         {
            this.annotatedStatChanges = new Stats(null,true);
         }
         this.annotatedStatChanges.addStat(param1,this.annotatedStatChanges.getBase(param1) + param2);
      }
      
      public function getAnnotatedStatChange(param1:StatType) : int
      {
         return !!this.annotatedStatChanges ? this.annotatedStatChanges.getBase(param1) : 0;
      }
      
      public function get isBlockedComplete() : Boolean
      {
         return this._blockedComplete > 0;
      }
      
      public function get blockedComplete() : int
      {
         return this._blockedComplete;
      }
      
      public function set blockedComplete(param1:int) : void
      {
         if(this._blockedComplete == param1)
         {
            return;
         }
         this._blockedComplete = param1;
         if(this._blockedComplete == 0)
         {
            if(this._tweenTimeout)
            {
               this._tweenTimeout.kill();
               this._tweenTimeout = null;
            }
            this.ability.onEffectUnblocked(this);
         }
      }
      
      public function blockComplete() : void
      {
         var _loc1_:IBattleAbilityManager = null;
         var _loc2_:IBattleBoard = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         ++this.blockedComplete;
         if(!this._tweenTimeout)
         {
            _loc1_ = this._ability.manager;
            _loc2_ = this._ability.caster.board;
            _loc3_ = _loc1_.lastId;
            _loc4_ = _loc2_.tileConfiguration;
            _loc5_ = _loc1_.lastIncompleteTicker;
            this._timeoutAbilityLastId = _loc3_;
            this._timeoutBoardTileConfiguration = _loc4_;
            this._timeoutAbilityIncompleteTicker = _loc5_;
            this._tweenTimeout = TweenMax.delayedCall(BLOCK_TIMEOUT_SEC,this.blockTimeoutHandler);
         }
      }
      
      public function unblockComplete() : void
      {
         --this.blockedComplete;
         if(!this.blockedComplete)
         {
            if(this._tweenTimeout)
            {
               this._tweenTimeout.kill();
               this._tweenTimeout = null;
            }
         }
      }
      
      private function blockTimeoutHandler() : void
      {
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         if(!this.blockedComplete)
         {
            return;
         }
         var _loc1_:IBattleAbilityManager = this._ability.manager;
         var _loc2_:IBattleBoard = this._ability.caster.board;
         var _loc3_:int = _loc1_.lastId;
         if(!_loc2_)
         {
            return;
         }
         var _loc4_:int = _loc2_.tileConfiguration;
         var _loc5_:int = _loc1_.lastIncompleteTicker;
         if(this._timeoutAbilityLastId == _loc3_ && this._timeoutBoardTileConfiguration == _loc4_ && this._timeoutAbilityIncompleteTicker == _loc5_)
         {
            this.logger.error("Effect.blockTimeoutHandler STALLED " + this);
            this._tweenTimeout = null;
            this.blockedComplete = 0;
         }
         else
         {
            _loc6_ = "" + this._timeoutBoardTileConfiguration + " -> " + _loc4_;
            _loc7_ = "" + this._timeoutAbilityLastId + " -> " + _loc3_;
            _loc8_ = "" + this._timeoutAbilityIncompleteTicker + " -> " + _loc5_;
            this.logger.info("Effect.blockTimeoutHandler CONTINUING albdiff=" + _loc6_ + " tilediff=" + _loc7_ + " incodiff=" + _loc8_ + " " + this);
            this._timeoutAbilityLastId = _loc3_;
            this._timeoutBoardTileConfiguration = _loc4_;
            this._timeoutAbilityIncompleteTicker = _loc5_;
            this._tweenTimeout = TweenMax.delayedCall(BLOCK_TIMEOUT_SEC,this.blockTimeoutHandler);
         }
      }
      
      public function hasOp(param1:Op) : Boolean
      {
         var _loc2_:Op = null;
         for each(_loc2_ in this.ops)
         {
            if(_loc2_ == param1)
            {
               return true;
            }
         }
         return false;
      }
      
      public function get result() : EffectResult
      {
         return this._result;
      }
      
      public function get def() : IEffectDef
      {
         return this._def;
      }
      
      public function get symbols() : ISymbols
      {
         return Boolean(this._ability) && Boolean(this._ability.manager) ? this._ability.manager.symbols : null;
      }
   }
}
