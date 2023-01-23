package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.BattleAbilityAiTargetRuleType;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityResponseTargetType;
   import engine.battle.ability.def.BattleAbilityTargetRule;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.effect.op.def.OpDef_ExecAbility;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.BattleAbilityManager;
   import engine.battle.ability.model.BattleAbilityValidation;
   import engine.battle.board.model.BattleBoard_SpatialUtil;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.fsm.BattleMove;
   import engine.core.logging.ILogger;
   import engine.entity.def.IAbilityAssetBundle;
   import engine.math.MathUtil;
   import engine.tile.Tile;
   
   public class Op_ExecAbility extends Op
   {
       
      
      public function Op_ExecAbility(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
      }
      
      public static function targetRandom(param1:Op_ExecAbility, param2:BattleAbility, param3:Vector.<IBattleEntity>, param4:IBattleEntity) : Boolean
      {
         var _loc7_:Vector.<IBattleEntity> = null;
         var _loc8_:IBattleEntity = null;
         var _loc9_:BattleMove = null;
         var _loc10_:Tile = null;
         var _loc11_:Boolean = false;
         var _loc12_:Boolean = false;
         var _loc13_:Boolean = false;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc5_:IBattleEntity = param2.caster;
         var _loc6_:ILogger = param2.logger;
         if(!_loc5_ || !_loc5_.board)
         {
            return false;
         }
         for each(_loc8_ in _loc5_.board.entities)
         {
            if(!(!_loc8_.alive || !_loc5_.awareOf(_loc8_)))
            {
               if(_loc8_ != param4)
               {
                  if(param2.def.checkTargetStatRanges(_loc8_.stats))
                  {
                     if(param2._def.checkTargetExecutionConditions(_loc8_,param2.logger,true))
                     {
                        _loc13_ = true;
                        if(BattleAbilityValidation.validate(param2.def,_loc5_,_loc9_,_loc8_,_loc10_,_loc11_,_loc12_,_loc13_).ok)
                        {
                           if(!_loc7_)
                           {
                              _loc7_ = new Vector.<IBattleEntity>();
                           }
                           _loc7_.push(_loc8_);
                        }
                     }
                  }
               }
            }
         }
         if(Boolean(_loc7_) && Boolean(_loc7_.length))
         {
            _loc14_ = param2.targetSet.targets.length;
            while(_loc14_ < param2.def.targetCount && Boolean(_loc7_.length))
            {
               _loc15_ = MathUtil.randomInt(0,_loc7_.length - 1);
               _loc8_ = _loc7_[_loc15_];
               param2.targetSet.addTarget(_loc8_);
               if(_loc6_.isDebugEnabled)
               {
                  _loc6_.debug("Op_ExecAbility random picked:=====>\n" + _loc8_.getDebugInfo() + ":=====< for " + param1);
               }
               _loc7_.splice(_loc15_,1);
               _loc14_++;
            }
         }
         return true;
      }
      
      public static function preloadAssets(param1:EffectDefOp, param2:IAbilityAssetBundle) : void
      {
         var _loc3_:OpDef_ExecAbility = param1 as OpDef_ExecAbility;
         _loc3_.preloadAssets(param2);
      }
      
      private function targetAll(param1:BattleAbility, param2:IBattleEntity, param3:Vector.<IBattleEntity>) : Boolean
      {
         var _loc6_:IBattleEntity = null;
         var _loc4_:* = param1.def.targetRule == BattleAbilityTargetRule.ALL_ALLIES;
         var _loc5_:* = param1.def.targetRule == BattleAbilityTargetRule.ALL_ENEMIES;
         if(!_loc4_ && !_loc5_)
         {
            return false;
         }
         for each(_loc6_ in caster.board.entities)
         {
            if(!(_loc6_ == caster || !_loc6_.alive))
            {
               if(!(_loc4_ && _loc6_.team != caster.team))
               {
                  if(!(_loc5_ && _loc6_.team == caster.team))
                  {
                     if(param1.def.checkTargetStatRanges(_loc6_.stats))
                     {
                        if(param1.def.aiTargetRule == BattleAbilityAiTargetRuleType.TILE_MAX_ADJACENT_ENEMY)
                        {
                           if(!BattleBoard_SpatialUtil.checkAdjacentEnemies(_loc6_,param3,true))
                           {
                              continue;
                           }
                        }
                        param1.targetSet.addTarget(_loc6_);
                     }
                  }
               }
            }
         }
         return true;
      }
      
      private function casterAll() : Boolean
      {
         var _loc5_:IBattleEntity = null;
         var _loc1_:OpDef_ExecAbility = def as OpDef_ExecAbility;
         var _loc2_:BattleAbilityManager = manager;
         var _loc3_:* = _loc1_.responseCaster == BattleAbilityResponseTargetType.ALL_ALLIES;
         var _loc4_:* = _loc1_.responseCaster == BattleAbilityResponseTargetType.ALL_ENEMIES;
         if(!_loc3_ && !_loc4_)
         {
            return false;
         }
         for each(_loc5_ in caster.board.entities)
         {
            if(!(_loc5_ == caster || !_loc5_.alive))
            {
               if(!(_loc3_ && _loc5_.team != caster.team))
               {
                  if(!(_loc4_ && _loc5_.team == caster.team))
                  {
                     this.performAbility(_loc5_);
                  }
               }
            }
         }
         return true;
      }
      
      override public function apply() : void
      {
         if(ability.fake || manager.faking)
         {
            return;
         }
         var _loc1_:OpDef_ExecAbility = def as OpDef_ExecAbility;
         var _loc2_:IBattleEntity = caster;
         if(this.casterAll())
         {
            return;
         }
         if(_loc1_.responseCaster == BattleAbilityResponseTargetType.TARGET || _loc1_.responseCaster == BattleAbilityResponseTargetType.OTHER)
         {
            _loc2_ = target;
         }
         this.performAbility(_loc2_);
      }
      
      private function performAbility(param1:IBattleEntity) : void
      {
         var _loc6_:IBattleEntity = null;
         if(ability.fake || manager.faking)
         {
            return;
         }
         var _loc2_:OpDef_ExecAbility = def as OpDef_ExecAbility;
         var _loc3_:BattleAbilityDef = _loc2_.getAbility(manager,param1);
         if(!_loc3_ || !_loc3_.checkCasterExecutionConditions(param1,logger,true))
         {
            return;
         }
         var _loc4_:BattleAbility = new BattleAbility(param1,_loc3_,manager);
         var _loc5_:Vector.<IBattleEntity> = new Vector.<IBattleEntity>();
         if(_loc4_.def.targetRule == BattleAbilityTargetRule.SELF || _loc4_.def.targetRule == BattleAbilityTargetRule.SELF_AOE_1 || _loc4_.def.targetRule == BattleAbilityTargetRule.SELF_AOE_ENEMY_1)
         {
            this.addTargetIfConditionsPass(_loc4_,param1);
         }
         else if(_loc2_.responseTarget == BattleAbilityResponseTargetType.RANDOM)
         {
            if(_loc2_.excludeTargetFromRandom)
            {
               _loc6_ = target;
            }
            if(!targetRandom(this,_loc4_,_loc5_,_loc6_) || !_loc4_.targetSet.targets.length)
            {
               if(logger.isDebugEnabled)
               {
                  logger.debug("Op_ExecAbility no random targets chosen for " + _loc4_);
               }
               return;
            }
         }
         else if(_loc2_.responseTarget == BattleAbilityResponseTargetType.CASTER || _loc2_.responseTarget == BattleAbilityResponseTargetType.SELF)
         {
            if(!this.targetAll(_loc4_,caster,_loc5_))
            {
               this.addTargetIfConditionsPass(_loc4_,caster);
            }
         }
         else if(!this.targetAll(_loc4_,target,_loc5_))
         {
            this.addTargetIfConditionsPass(_loc4_,target);
         }
         _loc4_.targetSet.setTile(tile);
         if(_loc2_.mustHaveValidTargetToExecute && _loc4_.targetSet.targets.length == 0)
         {
            logger.d("ABL","Op_ExecAbility.PerformAbility mustHaveValidTargetToExecute = true and targetSet = " + _loc4_.targetSet);
            return;
         }
         if(_loc2_.execChild)
         {
            effect.ability.addChildAbility(_loc4_);
         }
         else
         {
            _loc4_.execute(null);
         }
      }
      
      private function addTargetIfConditionsPass(param1:BattleAbility, param2:IBattleEntity) : void
      {
         if(Op_WaitForActionComplete.checkTargetValidity(param2,param1._def,false,logger))
         {
            param1.targetSet.setTarget(param2);
         }
      }
      
      override public function remove() : void
      {
      }
   }
}
