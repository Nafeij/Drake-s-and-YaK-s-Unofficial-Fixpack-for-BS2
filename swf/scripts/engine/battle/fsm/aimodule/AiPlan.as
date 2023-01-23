package engine.battle.fsm.aimodule
{
   import engine.battle.ability.def.BattleAbilityAiPositionalRuleType;
   import engine.battle.ability.def.BattleAbilityAiTargetRuleType;
   import engine.battle.ability.def.BattleAbilityTag;
   import engine.battle.ability.def.BattleAbilityTargetRule;
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.model.BattleAbilityValidation;
   import engine.battle.ability.model.StatChangeData;
   import engine.battle.board.def.IBattleAttractor;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleBoardTrigger;
   import engine.battle.board.model.IBattleBoardTriggers;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.model.IBattleMove;
   import engine.battle.entity.model.BattleEntity;
   import engine.core.util.StringUtil;
   import engine.stat.def.StatType;
   import engine.stat.model.Stats;
   import engine.tile.Tile;
   import engine.tile.def.TileRect;
   import engine.tile.def.TileRectRange;
   import flash.errors.IllegalOperationError;
   import flash.utils.Dictionary;
   
   public class AiPlan
   {
      
      public static var lastPlanId:int = 0;
       
      
      public var ai:AiModuleBase;
      
      public var mv:IBattleMove;
      
      public var abldef:IBattleAbilityDef;
      
      public var targets:Vector.<AiPlanTarget>;
      
      public var tiles:Vector.<Tile>;
      
      public var statchange_str:StatChangeData;
      
      public var statchange_arm:StatChangeData;
      
      public var kills:int;
      
      public var weight:int;
      
      public var planId:int;
      
      public var theKilled:Dictionary;
      
      private var num_statchange_str:int;
      
      private var killweight:int = 0;
      
      private var starsweight:int = 0;
      
      private var sweight_str:int = 0;
      
      private var sweight_arm:int = 0;
      
      private var pweight_enemy:int = 0;
      
      private var pweight_friend:int = 0;
      
      private var mvweight:int = 0;
      
      private var backoff_weight:int = 0;
      
      private var adjacent_weight:int = 0;
      
      private var aggro_mod:Number = 1;
      
      private var whazard:int;
      
      public function AiPlan(param1:AiModuleBase, param2:IBattleMove, param3:IBattleAbilityDef, param4:Vector.<IBattleEntity>, param5:Vector.<Tile>)
      {
         var _loc6_:BattleEntity = null;
         var _loc7_:AiPlanTarget = null;
         super();
         this.planId = ++lastPlanId;
         this.ai = param1;
         this.mv = param2;
         this.abldef = param3;
         this.tiles = param5;
         if(param3)
         {
            if(!BattleAbilityValidation.validateCosts(param3,param1.caster,param2,param1.ss.logger))
            {
               throw new IllegalOperationError("should have already been checked: " + this);
            }
         }
         if(Boolean(param4) && param4.length > 0)
         {
            if(!param3)
            {
               throw new IllegalOperationError("Why have targets with no abldef? " + this);
            }
            this.targets = new Vector.<AiPlanTarget>();
            for each(_loc6_ in param4)
            {
               _loc7_ = AiPlanTarget.ctor(this,_loc6_);
               if(_loc7_)
               {
                  this.targets.push(_loc7_);
                  this.combineStatChangeStr(_loc7_.statchange_str,_loc7_.statchange_str_miss);
                  this.combineStatChangeArm(_loc7_.statchange_arm);
                  if(_loc7_.killed)
                  {
                     ++this.kills;
                     if(!this.theKilled)
                     {
                        this.theKilled = new Dictionary();
                     }
                     this.theKilled[_loc7_.target] = _loc7_;
                  }
               }
            }
            this.finalizeStatChanges();
         }
         this.computeWeight();
      }
      
      public static function computeStrengthDamageWeight(param1:AiModuleBase, param2:int, param3:int, param4:IBattleEntity) : int
      {
         var _loc6_:Stats = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc5_:int = 0;
         if(Boolean(param2) && Boolean(param4))
         {
            if(param3)
            {
               _loc5_ -= param3 * AiPlanConsts.WEIGHT_ABL_MISSCHANCE;
            }
            _loc6_ = param4.stats;
            _loc7_ = _loc6_.getValue(StatType.STRENGTH);
            _loc8_ = Math.min(param2,_loc7_);
            _loc5_ += _loc8_ * AiPlanConsts.WEIGHT_ABL_DAMAGE_STR;
         }
         return _loc5_;
      }
      
      public static function computePositionalWeightEnemies(param1:AiModuleBase, param2:IBattleAbilityDef, param3:Tile, param4:Dictionary) : int
      {
         var _loc6_:BattleEntity = null;
         var _loc5_:int = 0;
         for each(_loc6_ in param1.enemies)
         {
            if(_loc6_.alive)
            {
               if(!(Boolean(param4) && Boolean(param4[_loc6_])))
               {
                  _loc5_ += AiPlanUtil.computePositionalEnemyWeight(param1,param2,param3.location,_loc6_);
               }
            }
         }
         return _loc5_;
      }
      
      public static function computePositionalWeightFriends(param1:AiModuleBase, param2:Tile, param3:Dictionary) : int
      {
         var _loc5_:BattleEntity = null;
         var _loc7_:IBattleAttractor = null;
         var _loc8_:int = 0;
         var _loc4_:int = 0;
         var _loc6_:TileRect = new TileRect(param2.location,param1.caster.boardWidth,param1.caster.boardLength);
         for each(_loc5_ in param1.friends)
         {
            _loc4_ += computePositionalFriendWeight(param1,_loc6_,_loc5_);
         }
         _loc7_ = param1.caster.attractor;
         if(_loc7_)
         {
            _loc8_ = TileRectRange.computeTileRange(param2.location,_loc7_.core);
            _loc4_ -= _loc8_ * AiPlanConsts.WEIGHT_ATTRACTOR_DISTANCE;
         }
         return _loc4_;
      }
      
      public static function computePositionalWeight(param1:AiModuleBase, param2:IBattleAbilityDef, param3:Tile, param4:Dictionary) : int
      {
         var _loc5_:int = computePositionalWeightEnemies(param1,param2,param3,param4);
         var _loc6_:int = computePositionalWeightFriends(param1,param3,param4);
         var _loc7_:int = 0;
         if(!param3.getWalkableFor(param1.caster))
         {
            _loc7_ = -1000;
         }
         return _loc5_ + _loc6_ + _loc7_;
      }
      
      public static function computePositionalFriendWeight(param1:AiModuleBase, param2:TileRect, param3:BattleEntity) : int
      {
         if(!param3.rect)
         {
            return 0;
         }
         var _loc4_:int = 0;
         var _loc5_:int = TileRectRange.computeRange(param2,param3.rect);
         _loc4_ = -_loc5_ * AiPlanConsts.WEIGHT_FRIEND_DISTANCE;
         if(param1.isRanged)
         {
            _loc4_ *= 2;
         }
         return _loc4_;
      }
      
      public static function compare(param1:AiPlan, param2:AiPlan) : int
      {
         return param2.weight - param1.weight;
      }
      
      private function finalizeStatChanges() : void
      {
         if(Boolean(this.statchange_str) && Boolean(this.num_statchange_str))
         {
            this.statchange_str.missChance /= this.num_statchange_str;
         }
      }
      
      private function combineStatChangeStr(param1:int, param2:int) : void
      {
         if(!param1)
         {
            return;
         }
         if(!this.statchange_str)
         {
            this.statchange_str = new StatChangeData();
         }
         this.statchange_str.amount += param1;
         this.statchange_str.missChance += param2;
         ++this.num_statchange_str;
      }
      
      private function combineStatChangeArm(param1:int) : void
      {
         if(!param1)
         {
            return;
         }
         if(!this.statchange_arm)
         {
            this.statchange_arm = new StatChangeData();
         }
         this.statchange_arm.amount += param1;
      }
      
      public function toString() : String
      {
         var _loc1_:String = !!this.abldef ? this.abldef.id + "/" + this.abldef.level : "null";
         var _loc2_:String = !!this.statchange_str ? this.statchange_str.toString() : "null";
         var _loc3_:String = !!this.statchange_arm ? this.statchange_arm.toString() : "null";
         return StringUtil.padRight(this.planId.toString()," ",4) + " w=" + StringUtil.padRight(StringUtil.numberWithSign(this.weight,0)," ",5) + " " + StringUtil.padRight(this.ai.caster.id," ",24) + " mv=" + StringUtil.padRight(!!this.mv ? (this.mv.numSteps - 1).toString() + " " + this.mv.last : "0"," ",12) + " abl=" + StringUtil.padRight(_loc1_," ",24) + " trg=" + StringUtil.padRight(this.toStringTargets," ",35) + " til=" + StringUtil.padRight(this.toStringTiles," ",15) + " kw=" + StringUtil.padRight(StringUtil.numberWithSign(this.killweight,0)," ",4) + " str=" + StringUtil.padRight(_loc2_," ",6) + StringUtil.padRight(StringUtil.numberWithSign(this.sweight_str,0)," ",4) + " arm=" + StringUtil.padRight(_loc3_," ",6) + StringUtil.padRight(StringUtil.numberWithSign(this.sweight_arm,0)," ",4) + " pe=" + StringUtil.padRight(StringUtil.numberWithSign(this.pweight_enemy,0)," ",4) + " pf=" + StringUtil.padRight(StringUtil.numberWithSign(this.pweight_friend,0)," ",4) + " sws=" + StringUtil.padRight(StringUtil.numberWithSign(this.sweight_str,0)," ",5) + " swa=" + StringUtil.padRight(StringUtil.numberWithSign(this.sweight_arm,0)," ",5) + " mw=" + StringUtil.padRight(StringUtil.numberWithSign(this.mvweight,0)," ",5) + " hz=" + StringUtil.padRight(StringUtil.numberWithSign(this.whazard,0)," ",5) + " bw=" + StringUtil.padRight(StringUtil.numberWithSign(this.backoff_weight,0)," ",5) + " agg=" + StringUtil.padRight(StringUtil.numberWithSign(this.aggro_mod,1)," ",5) + " star=" + this.starsweight;
      }
      
      private function get toStringTiles() : String
      {
         var _loc2_:Tile = null;
         if(!this.tiles || this.tiles.length == 0)
         {
            return "null";
         }
         var _loc1_:* = "";
         for each(_loc2_ in this.tiles)
         {
            if(_loc1_)
            {
               _loc1_ += " ";
            }
            _loc1_ += _loc2_.toString();
         }
         return _loc1_;
      }
      
      private function get toStringTargets() : String
      {
         var _loc2_:AiPlanTarget = null;
         if(!this.targets || this.targets.length == 0)
         {
            return "null";
         }
         var _loc1_:* = "";
         for each(_loc2_ in this.targets)
         {
            if(_loc1_)
            {
               _loc1_ += " ";
            }
            _loc1_ += _loc2_.target.id + "@" + _loc2_.target.rect;
         }
         return _loc1_;
      }
      
      private function _computeMoveWeight(param1:IBattleMove) : int
      {
         var _loc6_:Dictionary = null;
         var _loc11_:IBattleBoardTrigger = null;
         var _loc2_:IBattleEntity = this.ai.caster;
         var _loc3_:IBattleBoard = _loc2_.board;
         var _loc4_:IBattleBoardTriggers = _loc3_.triggers;
         var _loc5_:IBattleBoardTrigger = this.ai.startingHazard;
         if(!_loc4_ || !_loc4_.numTriggers)
         {
            return 0;
         }
         if(!param1 || param1.numSteps == 1)
         {
            if(_loc5_)
            {
               this.whazard = AiPlanConsts.WEIGHT_HAZARD;
               return this.whazard;
            }
            return 0;
         }
         var _loc7_:TileRect = _loc2_.rect.clone();
         _loc7_.setLocation(param1.last.location);
         _loc7_.facing = param1.getStepFacing(param1.numSteps - 1);
         var _loc8_:IBattleBoardTrigger = _loc4_.findEntityHazardAtRect(_loc2_,_loc7_,true);
         if(_loc5_)
         {
            this.whazard -= AiPlanConsts.WEIGHT_HAZARD;
         }
         if(Boolean(_loc8_) && _loc8_.def.pulse)
         {
            this.whazard += AiPlanConsts.WEIGHT_HAZARD * 2;
         }
         _loc6_ = this._addTriggerDict(_loc6_,_loc5_);
         _loc6_ = this._addTriggerDict(_loc6_,_loc8_);
         var _loc9_:int = 1;
         while(_loc9_ < param1.numSteps - 1)
         {
            _loc7_.setLocation(param1.getStep(_loc9_).location);
            _loc7_.facing = param1.getStepFacing(_loc9_);
            _loc11_ = _loc4_.findEntityHazardAtRect(_loc2_,_loc7_,true);
            if(Boolean(_loc11_) && (!_loc6_ || !_loc6_[_loc11_]))
            {
               this.whazard += AiPlanConsts.WEIGHT_HAZARD;
            }
            _loc6_ = this._addTriggerDict(_loc6_,_loc11_);
            _loc9_++;
         }
         var _loc10_:int = 0;
         _loc10_ = AiPlanConsts.WEIGHT_MOVE * param1.numSteps - 1;
         return _loc10_ + this.whazard;
      }
      
      private function _addTriggerDict(param1:Dictionary, param2:IBattleBoardTrigger) : Dictionary
      {
         if(param2)
         {
            if(!param1)
            {
               param1 = new Dictionary();
            }
            param1[param2] = true;
         }
         return param1;
      }
      
      private function computeWeight() : void
      {
         var _loc1_:AiPlanTarget = null;
         var _loc2_:Tile = null;
         this.weight = 0;
         for each(_loc1_ in this.targets)
         {
            this.weight += _loc1_.weight;
            this.killweight += _loc1_.killweight;
            this.sweight_arm += _loc1_.sweight_arm;
            this.sweight_str += _loc1_.sweight_str;
         }
         this.starsweight = AiPlanUtil.computeStarsWeight(this.ai,this.abldef,this.mv);
         this.weight += this.starsweight;
         this.mvweight = this._computeMoveWeight(this.mv);
         this.weight += this.mvweight;
         _loc2_ = !!this.mv ? this.mv.last : this.ai.caster.tile;
         this.pweight_enemy = computePositionalWeightEnemies(this.ai,this.abldef,_loc2_,this.theKilled);
         this.pweight_friend = computePositionalWeightFriends(this.ai,_loc2_,this.theKilled);
         if(!this.ai.caster.tile.getWalkableFor(this.ai.caster))
         {
            if(Boolean(this.mv) && this.mv.last != this.ai.caster.tile)
            {
               if(this.mv.last.getWalkableFor(this.ai.caster))
               {
                  this.weight += 10000;
               }
            }
            else
            {
               this.weight -= 10000;
            }
         }
         this.weight += this.pweight_enemy + this.pweight_friend;
         if(this.abldef)
         {
            if(this.abldef.tag == BattleAbilityTag.SPECIAL)
            {
               this.weight += 1000;
            }
            if(this.abldef.getAiPositionalRule() == BattleAbilityAiPositionalRuleType.BACK_OFF)
            {
               this.backoff_weight = this.computeBackOffWeight();
               this.weight += this.backoff_weight;
            }
            if(this.abldef.getAiTargetRule() == BattleAbilityAiTargetRuleType.TILE_MAX_ADJACENT_ENEMY)
            {
               this.adjacent_weight = this.computeAdjacentEnemyWeight();
               this.weight += this.adjacent_weight;
            }
            if(this.abldef.targetRule == BattleAbilityTargetRule.DEAD)
            {
               this.weight += this.computeRepossessionWeight();
            }
         }
         if(AiGlobalConfig.DEBUG)
         {
            this.ai.ss.logger.i(" AI ","DEBUG_AI computeWeight " + this);
         }
      }
      
      private function computeRepossessionWeight() : int
      {
         var _loc2_:AiPlanTarget = null;
         var _loc1_:int = 0;
         if(this.targets)
         {
            for each(_loc2_ in this.targets)
            {
               if(_loc2_.target)
               {
                  _loc1_ += _loc2_.target.stats.getValue(StatType.ARMOR) * AiPlanConsts.WEIGHT_ABL_DAMAGE_ARM;
                  _loc1_ += Number(_loc2_.target.def.stats.getValue(StatType.STRENGTH)) * 0.5 * AiPlanConsts.WEIGHT_ABL_DAMAGE_STR;
               }
            }
         }
         return _loc1_;
      }
      
      private function computeAdjacentEnemyWeight() : int
      {
         var _loc2_:BattleEntity = null;
         var _loc3_:Vector.<IBattleEntity> = null;
         var _loc4_:Tile = null;
         var _loc5_:AiPlanTarget = null;
         var _loc6_:Tile = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:Tile = null;
         var _loc1_:int = 0;
         if(this.tiles)
         {
            _loc3_ = AiPlanUtil.enemiesWhichHaveTileWeight(this.ai.caster,this.ai.enemies);
            for each(_loc4_ in this.tiles)
            {
               _loc1_ += AiPlanUtil.computeTileAdjacentEnemyWeight(this.ai.caster,_loc4_,_loc3_);
            }
         }
         if(this.targets)
         {
            _loc3_ = AiPlanUtil.enemiesWhichHaveTileWeight(this.ai.caster,this.ai.enemies);
            for each(_loc5_ in this.targets)
            {
               if(!(!_loc5_.target || !_loc5_.target.tile))
               {
                  _loc6_ = _loc5_.target.tile;
                  _loc7_ = _loc6_.x;
                  _loc8_ = _loc6_.y;
                  _loc9_ = 0;
                  while(_loc9_ < _loc5_.target.boardWidth)
                  {
                     _loc10_ = 0;
                     while(_loc10_ < _loc5_.target.boardLength)
                     {
                        _loc11_ = _loc5_.target.tiles.getTile(_loc7_ + _loc9_,_loc8_ + _loc10_);
                        _loc1_ += AiPlanUtil.computeTileAdjacentEnemyWeight(this.ai.caster,_loc11_,_loc3_);
                        _loc10_++;
                     }
                     _loc9_++;
                  }
               }
            }
         }
         return _loc1_;
      }
      
      private function computeBackOffWeight() : int
      {
         var _loc3_:BattleEntity = null;
         var _loc4_:int = 0;
         var _loc1_:int = 0;
         var _loc2_:TileRect = !!this.mv ? this.ai.caster.rect.clone().setLocation(this.mv.last.location) : this.ai.caster.rect;
         for each(_loc3_ in this.ai.enemies)
         {
            if(_loc3_.rect)
            {
               _loc4_ = TileRectRange.computeRange(_loc3_.rect,_loc2_);
               _loc4_ -= 3;
               if(_loc4_ < 0)
               {
                  _loc4_ = -(_loc4_ * _loc4_);
               }
               _loc1_ += _loc4_;
            }
         }
         return _loc1_ * AiPlanConsts.WEIGHT_BACK_OFF;
      }
   }
}
