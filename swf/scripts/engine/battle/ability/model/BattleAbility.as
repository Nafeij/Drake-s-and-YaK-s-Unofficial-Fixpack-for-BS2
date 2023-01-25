package engine.battle.ability.model
{
   import engine.battle.BattleUtilFunctions;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityRotationRule;
   import engine.battle.ability.def.BattleAbilityTargetRotationRule;
   import engine.battle.ability.def.BattleAbilityTargetRule;
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.effect.def.AbilityReason;
   import engine.battle.ability.effect.def.IEffectDef;
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectPhase;
   import engine.battle.ability.effect.model.EffectRemoveReason;
   import engine.battle.ability.effect.model.EffectTag;
   import engine.battle.ability.effect.model.IEffect;
   import engine.battle.ability.effect.model.IPersistedEffects;
   import engine.battle.ability.effect.op.model.Op;
   import engine.battle.ability.phantasm.model.ChainPhantasms;
   import engine.battle.ability.phantasm.model.ChainPhantasmsEvent;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.model.IBattleMove;
   import engine.core.logging.ILogger;
   import engine.saga.ISaga;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   import engine.stat.model.Stats;
   import engine.tile.Tile;
   import engine.tile.def.TileLocation;
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class BattleAbility extends EventDispatcher implements IBattleAbility
   {
       
      
      private var _parent:IBattleAbility;
      
      public var _def:BattleAbilityDef;
      
      private var callback:Function;
      
      private var _caster:IBattleEntity;
      
      public var chains:Vector.<ChainPhantasms>;
      
      public var effects:Vector.<Effect>;
      
      private var _executed:Boolean;
      
      private var _executing:Boolean;
      
      private var _completed:Boolean;
      
      private var abilityPreCompletionTriggered:Boolean;
      
      private var abilityPostCompletionTriggered:Boolean;
      
      public var children:Vector.<BattleAbility>;
      
      private var tags:Dictionary;
      
      public var _targetSet:BattleTargetSet;
      
      private var _manager:BattleAbilityManager;
      
      public var id:int;
      
      private var targetsAffected:int = 0;
      
      private var _fake:Boolean;
      
      private var _executedId:int;
      
      private var _blockedComplete:int = 0;
      
      public var logger:ILogger;
      
      public var lowestLevelAllowed:int = 1;
      
      public var cleanedup:Boolean;
      
      private var initialConditions:int = 0;
      
      private var ar:AbilityReason;
      
      public var targetDelayStart:int = 0;
      
      private var blockedCompleteSeen:Boolean;
      
      private var _checkingCompletion:Boolean;
      
      private var _finalCompleted:Boolean;
      
      private var _associatedTargets:Dictionary;
      
      public function BattleAbility(param1:IBattleEntity, param2:IBattleAbilityDef, param3:IBattleAbilityManager)
      {
         this.chains = new Vector.<ChainPhantasms>();
         this.effects = new Vector.<Effect>();
         this.children = new Vector.<BattleAbility>();
         this.tags = new Dictionary();
         this.ar = new AbilityReason();
         super();
         if(param1 == null)
         {
            this.logger.error("Must have a caster for battle ability " + param2);
            throw new IllegalOperationError("no caster");
         }
         this.caster = param1;
         this._manager = param3 as BattleAbilityManager;
         this.id = this._manager.nextId;
         this._def = param2 as BattleAbilityDef;
         this.logger = this._manager.logger;
         this._targetSet = new BattleTargetSet(this);
         if(this._manager.faking)
         {
            this._fake = true;
         }
      }
      
      public static function getStatChange(param1:IBattleAbilityDef, param2:IBattleEntity, param3:StatType, param4:StatChangeData, param5:IBattleEntity, param6:IBattleMove) : Boolean
      {
         var logger:ILogger = null;
         var oldTile:Tile = null;
         var oldFacing:BattleFacing = null;
         var val0:int = 0;
         var val0_other:int = 0;
         var testAbility:BattleAbility = null;
         var val1:int = 0;
         var val1_other:int = 0;
         var def:IBattleAbilityDef = param1;
         var caster:IBattleEntity = param2;
         var stat:StatType = param3;
         var result:StatChangeData = param4;
         var target:IBattleEntity = param5;
         var themove:IBattleMove = param6;
         var valid:BattleAbilityValidation = BattleAbilityValidation.validate(def,caster,themove,target,null,false,false,true);
         var delta:int = -1;
         var delta_other:int = 0;
         logger = caster.board.logger;
         var ostat:StatType = stat == StatType.STRENGTH ? StatType.ARMOR : null;
         var tstats:Stats = target.stats;
         if(valid == BattleAbilityValidation.OK && target.stats.getValue(stat) > 0)
         {
            oldTile = caster.tile;
            oldFacing = caster.facing;
            try
            {
               caster.suppressMoveEvents = true;
               if(themove)
               {
                  caster.setPos(themove.last.x,themove.last.y,true);
                  caster.facing = themove.lastFacing;
               }
               val0 = tstats.getValue(stat);
               val0_other = !!ostat ? tstats.getValue(ostat) : 0;
               caster.board.fake = true;
               tstats = target.stats;
               testAbility = new BattleAbility(caster,def,caster.board.abilityManager);
               testAbility.targetSet.setTarget(target);
               testAbility.execute(null);
               result.missChance = tstats.getValue(StatType.FAKE_MISS_CHANCE);
               val1 = tstats.getValue(stat);
               delta = val0 - val1;
               if(ostat)
               {
                  val1_other = tstats.getValue(ostat);
                  delta_other = val0_other - val1_other;
               }
               testAbility = null;
            }
            catch(e:Error)
            {
               logger.error("Something went wrong while faking " + stat + " with " + def + ": " + e.getStackTrace());
            }
            try
            {
               caster.board.fake = false;
               caster.setPos(oldTile.x,oldTile.y,true);
               caster.facing = oldFacing;
               caster.suppressMoveEvents = false;
            }
            catch(e:Error)
            {
               logger.error("Something went wrong while unfaking " + stat + " with " + def + ": " + e.getStackTrace());
            }
            result.amount = delta;
            result.other = delta_other;
            return true;
         }
         return false;
      }
      
      public function set targetSet(param1:BattleTargetSet) : void
      {
         this._targetSet = param1;
      }
      
      public function cleanup() : void
      {
         var _loc1_:ChainPhantasms = null;
         var _loc2_:Effect = null;
         if(this.cleanedup)
         {
            throw new IllegalOperationError("double cleanup");
         }
         this.cleanedup = true;
         for each(_loc1_ in this.chains)
         {
            _loc1_.cleanup();
         }
         this.chains = null;
         for each(_loc2_ in this.effects)
         {
            _loc2_.cleanup();
         }
         this.effects = null;
      }
      
      public function get root() : IBattleAbility
      {
         if(this.parent)
         {
            return this.parent.root;
         }
         return this;
      }
      
      private function get debugCasterId() : String
      {
         return !!this.caster ? String(this.caster.id) : "null";
      }
      
      override public function toString() : String
      {
         return "[" + this.executedId + " " + this.debugCasterId + "->" + this.targetSet.debugIds + " " + this.def.id + "/" + this.def.level + "]";
      }
      
      private function executeTiles() : void
      {
         var _loc1_:IEffectDef = null;
         var _loc2_:int = 0;
         var _loc3_:Tile = null;
         var _loc4_:IBattleEntity = null;
         for each(_loc1_ in this.def.effects)
         {
            if(_loc1_.targetCasterFirst)
            {
               this.executeTargetEffectDef(this.caster,_loc1_,_loc2_,false,false,false,null);
            }
         }
         _loc2_ = 0;
         for each(_loc3_ in this.targetSet.tiles)
         {
            this._executeOnTile(_loc3_,_loc2_);
            _loc2_ += this.def.targetDelay;
         }
         if(!this.targetSet.tiles.length)
         {
            for each(_loc4_ in this.targetSet.targets)
            {
               this._executeOnTile(_loc4_.tile,_loc2_);
               _loc2_ += this.def.targetDelay;
            }
         }
         for each(_loc1_ in this.def.effects)
         {
            if(_loc1_.targetCasterLast)
            {
               this.executeTargetEffectDef(this.caster,_loc1_,_loc2_,false,false,false,null);
            }
         }
      }
      
      private function _executeOnTile(param1:Tile, param2:int) : void
      {
         var _loc3_:Boolean = false;
         var _loc6_:IEffectDef = null;
         var _loc7_:Effect = null;
         var _loc8_:BattleAbilityValidation = null;
         if(!param1)
         {
            return;
         }
         var _loc4_:Boolean = this.shouldAllowRotation();
         var _loc5_:Boolean = this.shouldAllowTargetRotation();
         for each(_loc6_ in this.def.effects)
         {
            if(!(_loc6_.targetCasterFirst || _loc6_.targetCasterLast))
            {
               if(!_loc6_.checkEffectConditionsAbility(this,null,this.initialConditions == 0,this.ar))
               {
                  if(!this.fake && !this._manager.faking)
                  {
                     this.logger.debug("BattleAbility._executeOnTile() " + param1 + " " + _loc6_ + " SKIP CONDITION: " + this.ar);
                  }
               }
               else
               {
                  _loc8_ = BattleAbilityValidation.validate(this.def,this.caster,null,this.targetSet.baseTarget,param1,false,false,this.initialConditions == 0);
                  if(_loc8_ == BattleAbilityValidation.OK)
                  {
                     if(!_loc3_)
                     {
                        _loc3_ = true;
                        ++this.targetsAffected;
                     }
                     ++this.initialConditions;
                     _loc7_ = new Effect(this,_loc6_,this.targetSet.baseTarget,param1);
                     this.executeEffect(_loc7_,param2,_loc4_,_loc5_);
                  }
                  else if(!this.fake && !this._manager.faking)
                  {
                     BattleAbilityValidation.validate(this.def,this.caster,null,this.targetSet.baseTarget,param1,false,false,this.initialConditions == 0);
                     this.logger.debug("BattleAbility._executeOnTile() " + param1 + " " + _loc6_ + " SKIP VALIDATION: " + _loc8_);
                  }
               }
            }
         }
      }
      
      private function executeRandomTiles() : void
      {
         var delay:int = 0;
         var affectedTiles:Vector.<TileLocation> = null;
         var tile:Tile = null;
         var targetAffected:Boolean = false;
         var allowRotation:Boolean = false;
         var allowTargetRotation:Boolean = false;
         var valid:BattleAbilityValidation = null;
         var tileLoc:TileLocation = null;
         var affectedTile:Tile = null;
         var ed:IEffectDef = null;
         var effect:Effect = null;
         if(this.fake || this._manager.faking)
         {
            return;
         }
         this.logger.info("Execute effect on random tiles. Count = " + this.def.targetCount);
         for each(ed in this.def.effects)
         {
            if(ed.targetCasterFirst)
            {
               this.executeTargetEffectDef(this.caster,ed,delay,false,false,false,null);
            }
         }
         delay = 0;
         for each(tile in this.targetSet.tiles)
         {
            affectedTiles = new Vector.<TileLocation>();
            BattleUtilFunctions.selectRandomTiles(this._caster.board,tile.rect,this._def,affectedTiles,this.def.targetCount);
            this.logger.info("... affectedTiles " + affectedTiles.length + " " + affectedTiles.join(" | "));
            allowRotation = this.shouldAllowRotation();
            allowTargetRotation = this.shouldAllowTargetRotation();
            valid = BattleAbilityValidation.validate(this.def,this.caster,null,this.targetSet.baseTarget,null,true,false,this.initialConditions == 0);
            if(valid == BattleAbilityValidation.OK)
            {
               for each(tileLoc in affectedTiles)
               {
                  affectedTile = this.caster.board.tiles.getTileByLocation(tileLoc);
                  for each(ed in this.def.effects)
                  {
                     if(!(ed.targetCasterFirst || ed.targetCasterLast))
                     {
                        if(!ed.checkEffectConditionsAbility(this,null,this.initialConditions == 0,this.ar))
                        {
                           if(!this.fake && !this._manager.faking)
                           {
                              this.logger.debug("BattleAbility.executeRandomTiles() " + tile + " " + ed + " SKIP CONDITION: " + this.ar);
                           }
                        }
                        else
                        {
                           if(!targetAffected)
                           {
                              targetAffected = true;
                              ++this.targetsAffected;
                           }
                           ++this.initialConditions;
                           try
                           {
                              effect = new Effect(this,ed,this.targetSet.baseTarget,affectedTile);
                              this.executeEffect(effect,delay,allowRotation,allowTargetRotation);
                           }
                           catch(e:Error)
                           {
                              logger.error("Failed to execute effect " + ed + "\n" + e.getStackTrace());
                           }
                           delay += this.def.targetDelay;
                        }
                     }
                  }
               }
            }
         }
         for each(ed in this.def.effects)
         {
            if(ed.targetCasterLast)
            {
               this.executeTargetEffectDef(this.caster,ed,delay,false,false,false,null);
            }
         }
      }
      
      private function shouldAllowRotation() : Boolean
      {
         switch(this.def.rotationRule)
         {
            case BattleAbilityRotationRule.FIRST_TARGET:
               return this.targetsAffected == 0;
            case BattleAbilityRotationRule.ALL_TARGETS:
               return true;
            case BattleAbilityRotationRule.NONE:
               return false;
            default:
               return false;
         }
      }
      
      private function shouldAllowTargetRotation() : Boolean
      {
         switch(this.def.targetRotationRule)
         {
            case BattleAbilityTargetRotationRule.FACE_CASTER:
               return true;
            case BattleAbilityTargetRotationRule.NONE:
               return false;
            default:
               return false;
         }
      }
      
      private function executeTargetEffectDef(param1:IBattleEntity, param2:IEffectDef, param3:int, param4:Boolean, param5:Boolean, param6:Boolean, param7:BattleAbilityRetargetInfo) : Boolean
      {
         var _loc8_:Effect = null;
         var _loc11_:BattleAbilityValidation = null;
         if(!this._fake && !this._manager.faking)
         {
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("BattleAbility.executeTargetEffectDef() " + param1 + " " + param2);
            }
         }
         var _loc9_:* = this.initialConditions == 0;
         if(!param2.checkEffectConditionsAbility(this,param1,this.initialConditions == 0,this.ar))
         {
            if(!this._fake && !this._manager.faking)
            {
               if(this.logger.isDebugEnabled)
               {
                  this.logger.debug("BattleAbility.executeTargetEffectDef() " + param1 + " " + param2 + " SKIP CONDITION: " + this.ar);
               }
            }
            return false;
         }
         if(param7)
         {
            param1 = param7.target;
         }
         var _loc10_:Tile = this.targetSet.baseTile;
         if(param6)
         {
            _loc11_ = BattleAbilityValidation.validate(this._def,this._caster,null,param1,_loc10_,false,false,this.initialConditions == 0);
            ++this.initialConditions;
         }
         if(!param6 || _loc11_ == BattleAbilityValidation.OK)
         {
            ++this.initialConditions;
            _loc8_ = new Effect(this,param2,param1,_loc10_);
            _loc8_.waitForAbility = !!param7 ? param7.insert : null;
            this.executeEffect(_loc8_,param3,param4,param5);
            return true;
         }
         if(!this.fake && !this._manager.faking)
         {
            if(this.logger.isDebugEnabled)
            {
               BattleAbilityValidation.validate(this._def,this._caster,null,param1,_loc10_,false,false,this.initialConditions == 0);
               this.logger.debug("BattleAbility.executeTargetEffectDef() could not validate effect " + this.def.id + "," + param2.name + " for target " + param1.id + " validation=" + _loc11_);
               BattleAbilityValidation.validate(this._def,this._caster,null,param1,_loc10_,false,false,this.initialConditions - 1 == 0);
            }
         }
         return false;
      }
      
      private function executeTargets() : void
      {
         var _loc3_:IEffectDef = null;
         var _loc4_:IBattleEntity = null;
         var _loc5_:Boolean = false;
         var _loc6_:Boolean = false;
         var _loc7_:Boolean = false;
         var _loc8_:IPersistedEffects = null;
         var _loc9_:BattleAbilityRetargetInfo = null;
         var _loc10_:Boolean = false;
         var _loc1_:Tile = this._targetSet.baseTile;
         var _loc2_:int = this.targetDelayStart;
         for each(_loc3_ in this.def.effects)
         {
            if(_loc3_.targetCasterFirst)
            {
               this.executeTargetEffectDef(this.caster,_loc3_,_loc2_,false,false,false,null);
            }
         }
         for each(_loc4_ in this._targetSet.targets)
         {
            _loc6_ = !this.fake && !this._manager.faking && this.shouldAllowRotation();
            _loc7_ = !this.fake && !this._manager.faking && this.shouldAllowTargetRotation();
            if(_loc7_ && !_loc4_.isSquare)
            {
               _loc7_ = false;
            }
            _loc8_ = _loc4_.effects;
            _loc9_ = !!_loc8_ ? _loc8_.onAbilityExecutingOnTarget(this) : null;
            if(_loc9_)
            {
               if(!this.fake && !this._manager.faking)
               {
                  if(this.logger.isDebugEnabled)
                  {
                     this.logger.debug("BattleAbility.executeTargets() " + this + " retargeted " + _loc4_ + " to " + _loc9_);
                  }
               }
            }
            for each(_loc3_ in this.def.effects)
            {
               if(!(_loc3_.targetCasterFirst || _loc3_.targetCasterLast))
               {
                  _loc10_ = _loc9_ == null && !_loc3_.noValidateAbility;
                  if(this.executeTargetEffectDef(_loc4_,_loc3_,_loc2_,_loc6_,_loc7_,_loc10_,_loc9_))
                  {
                     if(!_loc5_)
                     {
                        _loc5_ = true;
                        ++this.targetsAffected;
                     }
                  }
               }
            }
            _loc2_ += this.def.targetDelay;
         }
         for each(_loc3_ in this.def.effects)
         {
            if(_loc3_.targetCasterLast)
            {
               this.executeTargetEffectDef(this.caster,_loc3_,_loc2_,false,false,false,null);
            }
         }
      }
      
      public function checkCosts(param1:Boolean = false) : Boolean
      {
         var _loc3_:Stats = null;
         var _loc4_:Stats = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Stat = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc2_:Boolean = true;
         if(this.def.artifactChargeCost)
         {
            if(this.caster.party.artifactChargeCount < this.def.artifactChargeCost)
            {
               if(!param1 && !this.fake && !this._manager.faking)
               {
                  this.logger.error("Not enough HORN for " + this);
               }
               _loc2_ = false;
            }
         }
         if(this.def.costs)
         {
            _loc3_ = this.caster.stats;
            _loc4_ = this.def.costs;
            _loc5_ = _loc4_.numStats;
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               _loc7_ = _loc4_.getStatByIndex(_loc6_);
               _loc8_ = _loc7_.value;
               _loc9_ = _loc3_.getValue(_loc7_.type);
               if(_loc8_ > _loc9_)
               {
                  if(!param1 && !this.fake && !this._manager.faking)
                  {
                     this.logger.error("Not enough " + _loc7_.type + " " + _loc9_ + " / " + _loc8_ + " for " + this);
                  }
                  _loc2_ = false;
               }
               _loc6_++;
            }
         }
         return _loc2_;
      }
      
      private function deductCosts() : Boolean
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:Stat = null;
         if(!this.checkCosts())
         {
            return false;
         }
         if(!this.fake && !this._manager.faking)
         {
            if(this.def.artifactChargeCost)
            {
               this.caster.party.artifactChargeCount -= this.def.artifactChargeCost;
            }
            if(this.def.costs)
            {
               _loc1_ = this.def.costs.numStats;
               _loc2_ = 0;
               while(_loc2_ < _loc1_)
               {
                  _loc3_ = this.def.costs.getStatByIndex(_loc2_);
                  this.caster.stats.getStat(_loc3_.type).base = this.caster.stats.getStat(_loc3_.type).base - _loc3_.value;
                  _loc2_++;
               }
            }
         }
         return true;
      }
      
      public function execute(param1:Function) : void
      {
         var _loc4_:ISaga = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         if(this._executed || this._executing)
         {
            throw new IllegalOperationError("no, no, no");
         }
         if(!this._manager.enabled)
         {
            return;
         }
         var _loc2_:int = this._manager.nextExecutedId;
         if(this._executedId != 0 && _loc2_ != this._executedId)
         {
            this.logger.error("DIVERGENCE Ability: " + this + ", should be id " + this._executedId);
         }
         this._executedId = _loc2_;
         this.executing = true;
         if(!this.def.checkCasterExecutionConditions(this.caster,this.logger,true))
         {
            this.logger.error("Attempt to execute ability with caster conditional failure " + this);
            if(!this._fake && !this._manager.faking)
            {
               this.executed = true;
               this.checkCompletion();
            }
            return;
         }
         if(!this.deductCosts())
         {
            this.logger.error("Attempt to execute ability without being able to pay the costs " + this);
            if(!this._fake && !this._manager.faking)
            {
               this.executed = true;
               this.checkCompletion();
            }
            return;
         }
         this.callback = param1;
         if(this._targetSet.targets.length == 0)
         {
            this._targetSet.setTarget(this._caster);
         }
         if(!this._fake && !this._manager.faking)
         {
            this.logger.i("ABL ","Execute " + this);
         }
         var _loc3_:BattleAbilityTargetRule = this._def.targetRule;
         if(_loc3_ == BattleAbilityTargetRule.TILE_EMPTY || _loc3_ == BattleAbilityTargetRule.TILE_ANY || _loc3_ == BattleAbilityTargetRule.TILE_EMPTY_1x2_FACING_CASTER)
         {
            this.executeTiles();
         }
         else if(_loc3_ == BattleAbilityTargetRule.TILE_EMPTY_RANDOM)
         {
            this.executeRandomTiles();
         }
         else if(_loc3_ == BattleAbilityTargetRule.SPECIAL_PLAYER_DRUMFIRE)
         {
            if(!this.fake && !this._manager.faking)
            {
            }
            this.executeTargets();
         }
         else
         {
            this.executeTargets();
         }
         this.executing = false;
         this.executed = true;
         if(!this.fake && !this._manager.faking)
         {
            if(Boolean(this.caster.board) && this.caster.board.boardFinishedSetup)
            {
               _loc4_ = this.caster.board.getSaga();
               if(_loc4_)
               {
                  _loc5_ = String(this.caster.def.id);
                  _loc6_ = this.def.id;
                  _loc4_.triggerBattleAbilityExecuted(_loc5_,_loc6_,this.caster.isPlayer);
               }
            }
         }
         this.checkCompletion();
      }
      
      public function addChildAbility(param1:IBattleAbility) : void
      {
         this.addChildAbilityCallback(param1,null);
      }
      
      public function addChildAbilityCallback(param1:IBattleAbility, param2:Function) : void
      {
         if(param1 == this)
         {
            throw new IllegalOperationError("epic failure of parenting");
         }
         if(!this._manager.enabled)
         {
            return;
         }
         param1.parent = this;
         this.children.push(param1);
         param1.execute(param2);
      }
      
      public function getEffectByName(param1:String) : IEffect
      {
         var _loc2_:Effect = null;
         for each(_loc2_ in this.effects)
         {
            if(_loc2_._def.name == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getEffectByDef(param1:IEffectDef) : IEffect
      {
         var _loc2_:Effect = null;
         for each(_loc2_ in this.effects)
         {
            if(_loc2_._def == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function executeEffect(param1:Effect, param2:int, param3:Boolean, param4:Boolean) : void
      {
         var chain:ChainPhantasms = null;
         var effect:Effect = param1;
         var delay:int = param2;
         var allowRotation:Boolean = param3;
         var allowTargetRotation:Boolean = param4;
         this.effects.push(effect);
         try
         {
            effect.execute();
         }
         catch(e:Error)
         {
            logger.error("BattleAbility.executeEffect failed " + effect + ":\n" + e.getStackTrace());
         }
         if(effect._def.phantasms != null)
         {
            if(!this.fake && !this._manager.faking)
            {
               chain = this.caster.createChainForEffect(effect) as ChainPhantasms;
               if(chain)
               {
                  this.chains.push(chain);
                  chain.addEventListener(ChainPhantasmsEvent.ENDED,this.phantasmsEndedHandler);
                  chain.addEventListener(ChainPhantasmsEvent.APPLIED,this.phantasmAppliedHandler);
                  chain.start(delay,allowRotation,allowTargetRotation);
               }
            }
         }
         if(!chain)
         {
            effect.apply();
            effect.phase = EffectPhase.COMPLETED;
         }
      }
      
      protected function phantasmAppliedHandler(param1:ChainPhantasmsEvent) : void
      {
         param1.chain.effect.apply();
         this.handlePhantasmsEnded(param1.chain);
      }
      
      private function handlePhantasmsEnded(param1:ChainPhantasms) : void
      {
         var _loc2_:int = 0;
         if(param1.ended)
         {
            param1.removeEventListener(ChainPhantasmsEvent.ENDED,this.phantasmsEndedHandler);
            param1.removeEventListener(ChainPhantasmsEvent.APPLIED,this.phantasmAppliedHandler);
            _loc2_ = this.chains.indexOf(param1);
            if(_loc2_ >= 0)
            {
               this.chains.splice(_loc2_,1);
            }
            param1.effect.phase = EffectPhase.COMPLETED;
            param1.effect.chain = null;
            param1.cleanup();
            param1 = null;
            this.checkCompletion();
         }
      }
      
      protected function phantasmsEndedHandler(param1:ChainPhantasmsEvent) : void
      {
         this.handlePhantasmsEnded(param1.chain);
      }
      
      private function checkChildCompletion() : Boolean
      {
         var _loc1_:BattleAbility = null;
         for each(_loc1_ in this.children)
         {
            if(!_loc1_.completed)
            {
               if(this.logger.isDebugEnabled)
               {
                  this.logger.debug("BattleAbility.checkCompletion checkChildCompletion " + this + " WAITING CHILD " + _loc1_);
               }
               return false;
            }
         }
         return true;
      }
      
      public function checkCompletion() : void
      {
         var _loc1_:Effect = null;
         var _loc2_:ChainPhantasms = null;
         if(this._checkingCompletion)
         {
            return;
         }
         if(this.completed)
         {
            if(!this.fake && !this._manager.faking)
            {
            }
            return;
         }
         if(!this.executed)
         {
            if(!this.fake && !this._manager.faking)
            {
            }
            return;
         }
         if(this.chains.length > 0)
         {
            if(!this.fake && !this._manager.faking)
            {
            }
            return;
         }
         if(this.blockedComplete)
         {
            this.blockedCompleteSeen = true;
            return;
         }
         for each(_loc1_ in this.effects)
         {
            if(_loc1_.isBlockedComplete)
            {
               if(!this.fake && !this._manager.faking)
               {
                  if(this.logger.isDebugEnabled)
                  {
                     this.logger.debug("BattleAbility.checkCompletion FALSE " + this + " EFFECT BLOCKED " + _loc1_);
                  }
               }
               return;
            }
         }
         for each(_loc2_ in this.chains)
         {
            if(!_loc2_.ended)
            {
               if(!this.fake && !this._manager.faking)
               {
               }
               return;
            }
         }
         this._checkingCompletion = true;
         if(!this.checkChildCompletion())
         {
            if(!this.fake && !this._manager.faking)
            {
            }
            this._checkingCompletion = false;
            return;
         }
         if(!this.abilityPreCompletionTriggered)
         {
            this.abilityPreCompletionTriggered = true;
            dispatchEvent(new BattleAbilityEvent(BattleAbilityEvent.ABILITY_PRE_COMPLETE,this,null));
            this._manager.onAbilityPreComplete(this);
            if(!this.checkChildCompletion())
            {
               if(!this.fake && !this._manager.faking)
               {
               }
               this._checkingCompletion = false;
               return;
            }
         }
         if(!this.fake && !this._manager.faking)
         {
            for each(_loc1_ in this.effects)
            {
               if(!_loc1_._def.persistent)
               {
                  _loc1_.remove();
               }
            }
         }
         this._checkingCompletion = false;
         this.completed = true;
         if(!this.fake && !this._manager.faking)
         {
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("BattleAbility.checkCompletion COMPLETED " + this + ", children=" + this.children.length);
            }
         }
         if(this.parent)
         {
            this.parent.checkCompletion();
         }
         if(this.completed)
         {
            this.handlePostComplete();
         }
      }
      
      private function handlePostComplete() : void
      {
         var _loc1_:BattleAbility = null;
         if(!this.completed)
         {
            return;
         }
         if(!this.abilityPostCompletionTriggered)
         {
            this.abilityPostCompletionTriggered = true;
            dispatchEvent(new BattleAbilityEvent(BattleAbilityEvent.ABILITY_POST_COMPLETE,this,null));
            this._manager.onAbilityPostComplete(this);
            if(!this.checkChildCompletion())
            {
               this.completed = false;
               return;
            }
         }
         for each(_loc1_ in this.children)
         {
            _loc1_.handlePostComplete();
            if(!_loc1_.completed)
            {
               this.completed = false;
            }
         }
         if(!this.completed)
         {
            return;
         }
         if(!this.finalCompleted)
         {
            dispatchEvent(new BattleAbilityEvent(BattleAbilityEvent.ABILITY_AND_CHILDREN_COMPLETE,this,null));
            this._manager.onAbilityAndChildrenComplete(this);
            this.setFinalCompleted();
         }
      }
      
      public function onEffectPhaseChange(param1:IEffect) : void
      {
         var _loc2_:ChainPhantasms = null;
         for each(_loc2_ in this.chains)
         {
            _loc2_.onEffectPhaseChange(param1);
         }
      }
      
      public function get executed() : Boolean
      {
         return this._executed;
      }
      
      public function set executed(param1:Boolean) : void
      {
         this._executed = param1;
      }
      
      public function get executing() : Boolean
      {
         return this._executing;
      }
      
      public function set executing(param1:Boolean) : void
      {
         if(this._executing == param1)
         {
            return;
         }
         this._executing = param1;
         dispatchEvent(new BattleAbilityEvent(BattleAbilityEvent.EXECUTING,this,null));
         this._manager.onAbilityExecuting(this);
      }
      
      public function get completed() : Boolean
      {
         return this._completed;
      }
      
      public function set completed(param1:Boolean) : void
      {
         this._completed = param1;
      }
      
      public function get finalCompleted() : Boolean
      {
         return this._finalCompleted;
      }
      
      public function setFinalCompleted() : void
      {
         var _loc1_:ISaga = null;
         var _loc2_:String = null;
         var _loc3_:String = null;
         if(this.finalCompleted)
         {
            return;
         }
         this._finalCompleted = true;
         if(this.callback != null)
         {
            this.callback(this);
            this.callback = null;
         }
         dispatchEvent(new BattleAbilityEvent(BattleAbilityEvent.FINAL_COMPLETE,this,null));
         this._manager.onAbilityFinalComplete(this);
         if(!this.fake && !this._manager.faking)
         {
            if(Boolean(this.caster.board) && this.caster.board.boardFinishedSetup)
            {
               _loc1_ = this.caster.board.getSaga();
               if(_loc1_)
               {
                  _loc2_ = String(this.caster.def.id);
                  _loc3_ = this.def.id;
                  _loc1_.triggerBattleAbilityCompleted(_loc2_,_loc3_,this.caster.isPlayer);
               }
            }
         }
      }
      
      public function get caster() : IBattleEntity
      {
         return this._caster;
      }
      
      public function set caster(param1:IBattleEntity) : void
      {
         this._caster = param1;
      }
      
      public function get def() : BattleAbilityDef
      {
         return this._def;
      }
      
      public function get targetSet() : BattleTargetSet
      {
         return this._targetSet;
      }
      
      public function get parent() : IBattleAbility
      {
         return this._parent;
      }
      
      public function set parent(param1:IBattleAbility) : void
      {
         this._parent = param1;
      }
      
      public function get manager() : IBattleAbilityManager
      {
         return this._manager;
      }
      
      public function get fake() : Boolean
      {
         return this._fake;
      }
      
      public function get executedId() : int
      {
         return this._executedId;
      }
      
      public function internalSetexecutedId(param1:int) : void
      {
         this._executedId = param1;
      }
      
      public function removeAllEffects(param1:EffectRemoveReason) : void
      {
         var _loc2_:Effect = null;
         for each(_loc2_ in this.effects)
         {
            if(_loc2_.phase != EffectPhase.REMOVED)
            {
               _loc2_.removeReason = param1;
               _loc2_.remove();
            }
         }
      }
      
      public function onEffectUnblocked(param1:IEffect) : void
      {
         this.checkCompletion();
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
            if(this.blockedCompleteSeen)
            {
               this.checkCompletion();
            }
         }
      }
      
      public function blockComplete() : void
      {
         ++this.blockedComplete;
      }
      
      public function unblockComplete() : void
      {
         --this.blockedComplete;
      }
      
      public function hasOp(param1:Op) : Boolean
      {
         var _loc2_:Effect = null;
         for each(_loc2_ in this.effects)
         {
            if(_loc2_.hasOp(param1))
            {
               return true;
            }
         }
         return false;
      }
      
      public function forceExpiration() : void
      {
         var _loc2_:Effect = null;
         var _loc1_:Vector.<Effect> = this.effects.concat();
         for each(_loc2_ in _loc1_)
         {
            _loc2_.forceExpiration();
         }
      }
      
      public function hasTag(param1:EffectTag) : Boolean
      {
         var _loc2_:Effect = null;
         for each(_loc2_ in this.effects)
         {
            if(_loc2_.hasTag(param1))
            {
               return true;
            }
         }
         return false;
      }
      
      public function setAssociatedTargets(param1:Dictionary) : void
      {
         this._associatedTargets = param1;
      }
      
      public function getAssociatedTargets() : Dictionary
      {
         return this._associatedTargets;
      }
      
      public function hasAssociatedTarget(param1:IBattleEntity) : Boolean
      {
         return Boolean(this._associatedTargets) && Boolean(this._associatedTargets[param1]);
      }
      
      public function get getId() : int
      {
         return this.id;
      }
   }
}
