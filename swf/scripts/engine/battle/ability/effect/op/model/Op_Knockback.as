package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityDefFactory;
   import engine.battle.ability.def.BattleAbilityResponseTargetType;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.model.EffectTag;
   import engine.battle.ability.effect.model.IPersistedEffects;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.BattleAbilityValidation;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.battle.fsm.BattleMove;
   import engine.battle.fsm.BattleMoveEvent;
   import engine.core.util.Enum;
   import engine.stat.def.StatType;
   import engine.tile.ITileResident;
   import engine.tile.Tile;
   import engine.tile.def.TileRect;
   import flash.utils.Dictionary;
   
   public class Op_Knockback extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_Knockback",
         "properties":{
            "perTileAbility":{
               "type":"string",
               "optional":true
            },
            "intersectResponseCaster":{
               "type":"string",
               "optional":true
            },
            "intersectResponseTarget":{
               "type":"string",
               "optional":true
            },
            "intersectResponseAbility":{
               "type":"string",
               "optional":true
            },
            "stopAbility":{
               "type":"string",
               "optional":true
            },
            "knockthrough":{
               "type":"boolean",
               "optional":true
            },
            "randomDirection":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      private var destinationTile:Tile;
      
      private var move:BattleMove;
      
      private var alreadyHits:Dictionary;
      
      private var perTileAbility:BattleAbilityDef;
      
      private var intersectResponseAbility:BattleAbilityDef;
      
      private var intersectResponseCaster:BattleAbilityResponseTargetType;
      
      private var intersectResponseTarget:BattleAbilityResponseTargetType;
      
      private var knockthrough:Boolean;
      
      private var randomDirection:Boolean;
      
      private var casterRect:TileRect;
      
      private var stopAbility:BattleAbilityDef;
      
      private const LOCO_ID:String = "ability_stumble_back";
      
      private var _executionRect:TileRect;
      
      public function Op_Knockback(param1:EffectDefOp, param2:Effect)
      {
         this.alreadyHits = new Dictionary();
         this.intersectResponseCaster = BattleAbilityResponseTargetType.TARGET;
         this.intersectResponseTarget = BattleAbilityResponseTargetType.OTHER;
         super(param1,param2);
         this.perTileAbility = _parseAbilityDef(param1.params,"perTileAbility",manager.factory);
         this.stopAbility = _parseAbilityDef(param1.params,"stopAbility",manager.factory);
         this.intersectResponseAbility = _parseAbilityDef(param1.params,"intersectResponseAbility",manager.factory);
         this.knockthrough = param1.params.knockthrough;
         this.randomDirection = param1.params.randomDirection;
         this.intersectResponseCaster = _parseResponseTargetType(param1.params,"intersectResponseCaster",this.intersectResponseCaster);
         this.intersectResponseTarget = _parseResponseTargetType(param1.params,"intersectResponseTarget",this.intersectResponseTarget);
      }
      
      private static function _parseAbilityDef(param1:Object, param2:String, param3:BattleAbilityDefFactory) : BattleAbilityDef
      {
         var _loc4_:BattleAbilityDef = null;
         var _loc5_:String = param1[param2];
         if(_loc5_)
         {
            _loc4_ = param3.fetchBattleAbilityDef(_loc5_);
            if(!_loc4_)
            {
               throw "Failed to find " + param2 + " [" + _loc5_ + "]";
            }
         }
         return _loc4_;
      }
      
      private static function _parseResponseTargetType(param1:Object, param2:String, param3:BattleAbilityResponseTargetType) : BattleAbilityResponseTargetType
      {
         var _loc4_:String = param1[param2];
         if(_loc4_)
         {
            return Enum.parse(BattleAbilityResponseTargetType,_loc4_) as BattleAbilityResponseTargetType;
         }
         return param3;
      }
      
      override public function execute() : EffectResult
      {
         if(!target.alive || !target.attackable || !target.mobility)
         {
            this.destinationTile = null;
            return EffectResult.FAIL;
         }
         var _loc1_:IPersistedEffects = target.effects;
         if(!_loc1_ || Boolean(_loc1_.hasTag(EffectTag.NO_KNOCKBACK)))
         {
            this.destinationTile = null;
            return EffectResult.FAIL;
         }
         this._executionRect = target.rect;
         if(this.randomDirection)
         {
            this.casterRect = Op_KnockbackHelper.getRandomDirectionCasterRect(target,manager.rng);
         }
         if(!this.casterRect)
         {
            this.casterRect = caster.rect;
         }
         var _loc2_:Tile = Op_KnockbackHelper.getKnockbackStopTile(ability.def,caster,this.casterRect,target,this.knockthrough);
         this.destinationTile = _loc2_;
         if(this.destinationTile)
         {
            effect.addTag(EffectTag.KNOCKBACK_SOMEWHERE);
         }
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
         var _loc9_:Tile = null;
         if(ability.fake || manager.faking)
         {
            return;
         }
         if(!target.alive)
         {
            return;
         }
         var _loc1_:IPersistedEffects = target.effects;
         if(!_loc1_ || Boolean(_loc1_.hasTag(EffectTag.NO_KNOCKBACK)))
         {
            logger.info("Op_Knockback.apply knockback blocked by tag " + EffectTag.NO_KNOCKBACK + " on " + target + " : " + this);
            this.handleStop();
            return;
         }
         var _loc2_:Tile = Op_KnockbackHelper.getKnockbackStopTile(ability.def,caster,this.casterRect,target,this.knockthrough);
         this.destinationTile = _loc2_;
         if(this.destinationTile)
         {
            effect.addTag(EffectTag.KNOCKBACK_SOMEWHERE);
            target.effects.addTag(EffectTag.KNOCKBACK_SOMEWHERE);
         }
         target.stats.removeStat(StatType.KNOCKBACK_DEFERRED);
         var _loc3_:TileRect = target.rect;
         if(!this._executionRect.equals(_loc3_))
         {
            logger.error("Some idiot moved the target rectangle from " + this._executionRect + " to " + _loc3_ + " before apply(). " + this);
            return;
         }
         if(target.mobility.moving)
         {
            logger.info("Op_Knockback.apply interrupting move " + target + " : " + this);
            target.mobility.stopMoving("Op_Knockback: " + this);
         }
         var _loc4_:Tile = target.tile;
         logger.info("Op_Knockback.apply snapping " + target + " to " + _loc4_ + ": " + this);
         target.setPos(_loc4_.x,_loc4_.y);
         if(!this.destinationTile)
         {
            this.handleStop();
            return;
         }
         this.move = new BattleMove(target);
         this.move.forcedMove = true;
         this.move.reactToEntityIntersect = true;
         var _loc5_:* = target.y == this.destinationTile.y;
         var _loc6_:int = _loc5_ ? this.destinationTile.x - Number(target.x) : this.destinationTile.y - Number(target.y);
         var _loc7_:int = _loc6_ > 0 ? 1 : -1;
         var _loc8_:int = _loc7_;
         while(_loc6_ != 0)
         {
            _loc9_ = null;
            if(_loc5_)
            {
               _loc9_ = caster.board.tiles.getTile(target.x + _loc8_,target.y);
            }
            else
            {
               _loc9_ = caster.board.tiles.getTile(target.x,target.y + _loc8_);
            }
            this.move.addStep(_loc9_);
            _loc8_ += _loc7_;
            _loc6_ -= _loc7_;
         }
         this.addListeners();
         this.move.setCommitted("Op_Knockback.apply " + this);
         effect.blockComplete();
         target.mobility.executeMove(this.move);
      }
      
      private function addListeners() : void
      {
         target.locoId = this.LOCO_ID;
         target.ignoreFreezeFrame = false;
         target.ignoreFacing = true;
         if(this.move)
         {
            target.addEventListener(BattleEntityEvent.TILE_CHANGED,this.tileChangedEvent);
            target.addEventListener(BattleEntityEvent.ALIVE,this.aliveHandler);
            this.move.addEventListener(BattleMoveEvent.EXECUTED,this.moveExecutedHandler);
            this.move.addEventListener(BattleMoveEvent.INTERRUPTED,this.moveInterruptedHandler);
            if(this.intersectResponseAbility)
            {
               this.move.addEventListener(BattleMoveEvent.INTERSECT_ENTITY,this.moveIntersectEntityHandler);
            }
         }
      }
      
      private function handleStop() : void
      {
         var _loc1_:BattleAbility = null;
         if(logger.isDebugEnabled)
         {
            logger.debug("Op_Knockback.handleStop " + this);
         }
         this.removeListeners();
         if(this.destinationTile)
         {
            target.effects.removeTag(EffectTag.KNOCKBACK_SOMEWHERE);
         }
         if(this.stopAbility)
         {
            _loc1_ = new BattleAbility(caster,this.stopAbility,manager);
            _loc1_.targetSet.setTarget(target);
            _loc1_.execute(null);
         }
         effect.unblockComplete();
      }
      
      private function removeListeners() : void
      {
         if(logger.isDebugEnabled)
         {
            logger.debug("Op_Knockback.removeListeners " + this + " move=" + this.move);
         }
         if(target.locoId == this.LOCO_ID)
         {
            target.locoId = null;
         }
         target.ignoreFreezeFrame = true;
         target.ignoreFacing = false;
         if(this.move)
         {
            target.removeEventListener(BattleEntityEvent.ALIVE,this.aliveHandler);
            target.removeEventListener(BattleEntityEvent.TILE_CHANGED,this.tileChangedEvent);
            this.move.removeEventListener(BattleMoveEvent.EXECUTED,this.moveExecutedHandler);
            this.move.removeEventListener(BattleMoveEvent.INTERRUPTED,this.moveInterruptedHandler);
            this.move.removeEventListener(BattleMoveEvent.INTERSECT_ENTITY,this.moveIntersectEntityHandler);
         }
      }
      
      private function tileChangedEvent(param1:BattleEntityEvent) : void
      {
         var _loc2_:BattleAbility = null;
         if(this.perTileAbility)
         {
            _loc2_ = new BattleAbility(target,this.perTileAbility,manager);
            _loc2_.targetSet.setTarget(target);
            _loc2_.execute(null);
         }
      }
      
      private function aliveHandler(param1:BattleEntityEvent) : void
      {
         logger.info("Op_Knockback.aliveHandler " + this);
         this.removeListeners();
         effect.unblockComplete();
      }
      
      private function moveExecutedHandler(param1:BattleMoveEvent) : void
      {
         if(logger.isDebugEnabled)
         {
            logger.debug("Op_Knockback.moveExecutedHandler " + this);
         }
         this.handleStop();
      }
      
      private function moveInterruptedHandler(param1:BattleMoveEvent) : void
      {
         if(logger.isDebugEnabled)
         {
            logger.debug("Op_Knockback.moveInterruptedHandler " + this);
         }
         this.handleStop();
      }
      
      private function moveIntersectEntityHandler(param1:BattleMoveEvent) : void
      {
         if(!this.intersectResponseAbility)
         {
            return;
         }
         var _loc2_:TileRect = target.rect;
         _loc2_.visitEnclosedTileLocations(this._visitIntersectedTiles,null);
      }
      
      private function _resolveResponseTargetRule(param1:BattleAbilityResponseTargetType, param2:IBattleEntity) : IBattleEntity
      {
         switch(param1)
         {
            case BattleAbilityResponseTargetType.SELF:
            case BattleAbilityResponseTargetType.CASTER:
               return caster;
            case BattleAbilityResponseTargetType.TARGET:
               return target;
            case BattleAbilityResponseTargetType.OTHER:
               return param2;
            default:
               throw new ArgumentError("unsupported response target rule: " + param1);
         }
      }
      
      private function _visitIntersectedTiles(param1:int, param2:int, param3:*) : void
      {
         var _loc5_:ITileResident = null;
         var _loc6_:IBattleEntity = null;
         var _loc7_:IBattleEntity = null;
         var _loc8_:IBattleEntity = null;
         var _loc9_:BattleAbilityValidation = null;
         var _loc10_:BattleAbility = null;
         var _loc4_:Tile = board.tiles.getTile(param1,param2);
         for each(_loc5_ in _loc4_.residents)
         {
            if(_loc5_ is IBattleEntity)
            {
               _loc6_ = _loc5_ as IBattleEntity;
               if(_loc6_.alive == true && target != _loc6_)
               {
                  if(this.alreadyHits[_loc6_])
                  {
                     caster.logger.info("Op_Knockback.moveIntersectEntityHandler SKIPPING " + _loc6_ + ", already hit");
                  }
                  else
                  {
                     this.alreadyHits[_loc6_] = _loc6_;
                     _loc7_ = this._resolveResponseTargetRule(this.intersectResponseCaster,_loc6_);
                     _loc8_ = this._resolveResponseTargetRule(this.intersectResponseTarget,_loc6_);
                     _loc9_ = BattleAbilityValidation.validate(this.intersectResponseAbility,_loc7_,null,_loc8_,null,false,false,true,false);
                     if(!_loc9_ || !_loc9_.ok)
                     {
                        caster.logger.info("Op_Knockback.moveIntersectEntityHandler SKIPPING " + _loc6_ + ", invalid caster/target rule for " + _loc7_ + " / " + _loc8_);
                     }
                     else
                     {
                        _loc10_ = new BattleAbility(_loc7_,this.intersectResponseAbility,manager);
                        _loc10_.targetSet.setTarget(_loc8_);
                        _loc10_.execute(null);
                     }
                  }
               }
            }
         }
      }
   }
}
