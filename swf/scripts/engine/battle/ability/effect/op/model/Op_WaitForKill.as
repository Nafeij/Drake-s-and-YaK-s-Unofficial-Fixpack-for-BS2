package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.AbilityExecutionEntityConditions;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityKilledFacingReponseRule;
   import engine.battle.ability.def.BattleAbilityTargetRule;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.IBattleAbility;
   import engine.battle.board.BattleBoardEvent;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.BoxString;
   import engine.core.util.Enum;
   import engine.def.BooleanVars;
   import engine.tile.Tile;
   import engine.tile.def.TileRect;
   import engine.tile.def.TileRectRange;
   import flash.errors.IllegalOperationError;
   
   public class Op_WaitForKill extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_WaitForKill",
         "properties":{
            "ability":{"type":"string"},
            "killerRule":{"type":"string"},
            "killedRule":{"type":"string"},
            "killerRangeMax":{
               "type":"number",
               "optional":true
            },
            "killedConditions":{
               "type":AbilityExecutionEntityConditions.schema,
               "optional":true
            },
            "killerConditions":{
               "type":AbilityExecutionEntityConditions.schema,
               "optional":true
            },
            "killedRotationRule":{
               "type":"string",
               "optional":true
            },
            "allowProps":{
               "type":"boolean",
               "optional":true
            },
            "execChild":{
               "type":"boolean",
               "optional":true
            },
            "abilityLevel":{
               "type":"number",
               "optional":true
            }
         }
      };
       
      
      private var killerRule:BattleAbilityTargetRule;
      
      private var killedRule:BattleAbilityTargetRule;
      
      private var ablDef:BattleAbilityDef;
      
      private var killerRangeMax:int = 0;
      
      private var execChild:Boolean = true;
      
      private var allowProps:Boolean = false;
      
      private var killedConditions:AbilityExecutionEntityConditions;
      
      private var killerConditions:AbilityExecutionEntityConditions;
      
      private var killedFacingResponse:BattleAbilityKilledFacingReponseRule;
      
      private var _level:int;
      
      private var reason:BoxString;
      
      public function Op_WaitForKill(param1:EffectDefOp, param2:Effect)
      {
         this.killedFacingResponse = BattleAbilityKilledFacingReponseRule.NONE;
         this.reason = new BoxString();
         super(param1,param2);
         this.killerRule = Enum.parse(BattleAbilityTargetRule,param1.params.killerRule) as BattleAbilityTargetRule;
         this.killedRule = Enum.parse(BattleAbilityTargetRule,param1.params.killedRule) as BattleAbilityTargetRule;
         this.killerRangeMax = param1.params.killerRangeMax;
         this.ablDef = manager.factory.fetchBattleAbilityDef(param1.params.ability);
         this.execChild = BooleanVars.parse(param1.params.execChild,this.execChild);
         this.allowProps = BooleanVars.parse(param1.params.allowProps,this.allowProps);
         this._level = param1.params.abilityLevel;
         this._level = Math.max(1,Math.min(this._level,this.ablDef.maxLevel));
         if(param1.params.killedConditions)
         {
            this.killedConditions = new AbilityExecutionEntityConditions().fromJson(param1.params.killedConditions,logger);
         }
         if(param1.params.killerConditions)
         {
            this.killerConditions = new AbilityExecutionEntityConditions().fromJson(param1.params.killerConditions,logger);
         }
         if(param1.params.killedRotationRule)
         {
            this.killedFacingResponse = Enum.parse(BattleAbilityKilledFacingReponseRule,param1.params.killedRotationRule) as BattleAbilityKilledFacingReponseRule;
         }
      }
      
      override public function apply() : void
      {
         board.addEventListener(BattleBoardEvent.BOARD_ENTITY_KILLING_EFFECT,this.killingEffectHandler);
      }
      
      override public function remove() : void
      {
         board.removeEventListener(BattleBoardEvent.BOARD_ENTITY_KILLING_EFFECT,this.killingEffectHandler);
      }
      
      private function killingEffectHandler(param1:BattleBoardEvent) : void
      {
         var _loc4_:IBattleEntity = null;
         var _loc5_:IBattleEntity = null;
         var _loc7_:BattleAbility = null;
         var _loc8_:int = 0;
         var _loc9_:Tile = null;
         var _loc10_:Vector.<IBattleEntity> = null;
         if(!caster)
         {
            return;
         }
         var _loc2_:IBattleEntity = param1.entity;
         if(!_loc2_ || !_loc2_.killingEffect)
         {
            logger.error("Op_WaitForKill.killingEffectHandler with null entity=" + _loc2_ + " or null killingEffect");
            logger.error(new IllegalOperationError().getStackTrace());
            return;
         }
         var _loc3_:IBattleAbility = _loc2_.killingEffect.ability;
         _loc4_ = !!_loc3_ ? _loc3_.caster : null;
         _loc5_ = _loc2_.killingEffect.target;
         if(Boolean(_loc5_) && !(Boolean(_loc5_.mobile) || this.allowProps))
         {
            return;
         }
         if(!this.killerRule.isValid(caster,caster.rect,_loc4_,null,true))
         {
            return;
         }
         if(!this.killedRule.isValid(caster,caster.rect,_loc5_,null,true,null,false))
         {
            return;
         }
         if(this.killedConditions)
         {
            if(!this.killedConditions.checkExecutionConditions(_loc5_,logger,true))
            {
               logger.debug("Op_WaitForKill " + this + " killed conditions not passed " + this.killedConditions + " " + this.killedConditions._reason);
               return;
            }
         }
         if(this.killerConditions)
         {
            if(!this.killerConditions.checkExecutionConditions(_loc4_,logger,true))
            {
               logger.debug("Op_WaitForKill " + this + " killer conditions not passed " + this.killerConditions + " " + this.killerConditions._reason);
               return;
            }
         }
         if(this.killerRangeMax > 0)
         {
            _loc8_ = TileRectRange.computeRange(caster.rect,_loc4_.rect);
            if(_loc8_ > this.killerRangeMax)
            {
               if(logger.isDebugEnabled)
               {
                  logger.debug("Op_WaitForKill " + this + " killer " + _loc4_ + " too far away, range=" + _loc8_);
               }
               return;
            }
         }
         var _loc6_:TileRect = _loc4_.rect;
         if(_loc5_.rect.loc == _loc6_.loc)
         {
            _loc9_ = _loc4_.mobility.previousTileInMove;
            if(_loc9_)
            {
               _loc6_ = _loc9_.rect;
            }
         }
         switch(this.killedFacingResponse)
         {
            case BattleAbilityKilledFacingReponseRule.FACE_AWAY_FROM_KILLER:
               _loc5_.turnToFace(_loc6_,true);
               _loc5_.animController.facing = _loc5_.facing;
               break;
            case BattleAbilityKilledFacingReponseRule.FACE_KILLER:
               _loc5_.turnToFace(_loc6_,false);
               _loc5_.animController.facing = _loc5_.facing;
               break;
            case BattleAbilityKilledFacingReponseRule.NONE:
         }
         _loc7_ = new BattleAbility(caster,this.ablDef.getBattleAbilityDefLevel(this._level),manager);
         switch(_loc7_.def.targetRule)
         {
            case BattleAbilityTargetRule.NEEDLE_TARGET_ENEMY_OTHER_ALL:
               _loc10_ = this.getNeedleTargets(_loc7_,_loc5_,_loc4_);
               this.setTargets(_loc7_,_loc10_);
               break;
            default:
               _loc7_.targetSet.addTarget(caster);
         }
         if(this.execChild)
         {
            _loc3_.addChildAbility(_loc7_);
         }
         else
         {
            _loc7_.execute(null);
         }
      }
      
      private function getNeedleTargets(param1:BattleAbility, param2:IBattleEntity, param3:IBattleEntity) : Vector.<IBattleEntity>
      {
         var _loc4_:IBattleEntity = param1.caster;
         if(!_loc4_)
         {
            return null;
         }
         var _loc5_:Object = {
            "x":_loc4_.tile.location.x,
            "y":_loc4_.tile.location.y
         };
         var _loc6_:int = _loc4_.facing.y;
         var _loc7_:int = _loc4_.facing.x;
         var _loc8_:int = param1.def.rangeMax(_loc4_);
         var _loc9_:IBattleEntity = null;
         var _loc10_:Vector.<IBattleEntity> = new Vector.<IBattleEntity>();
         var _loc11_:int = 0;
         while(_loc11_ < _loc8_)
         {
            _loc5_.x += _loc7_;
            _loc5_.y += _loc6_;
            _loc9_ = _loc4_.board.findEntityOnTile(_loc5_.x,_loc5_.y,true,_loc4_);
            if(_loc9_)
            {
               if(_loc10_.indexOf(_loc9_) < 0)
               {
                  _loc10_.push(_loc9_);
               }
            }
            _loc11_++;
         }
         return _loc10_;
      }
      
      private function setTargets(param1:BattleAbility, param2:Vector.<IBattleEntity>) : void
      {
         var _loc5_:IBattleEntity = null;
         if(!param2 || param2.length == 0)
         {
            return;
         }
         param1.targetSet.supressEvents = true;
         param1.targetSet.setTarget(null);
         var _loc3_:int = param1.def.targetCount;
         var _loc4_:int = 0;
         while(param1.targetSet.targets.length < _loc3_ && _loc4_ < param2.length)
         {
            _loc5_ = param2[_loc4_];
            if(!param1.targetSet.hasTarget(_loc5_))
            {
               param1.targetSet.addTarget(_loc5_);
            }
            _loc4_++;
         }
         param1.targetSet.supressEvents = false;
      }
   }
}
