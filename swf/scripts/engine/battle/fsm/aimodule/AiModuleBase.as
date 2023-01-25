package engine.battle.fsm.aimodule
{
   import engine.ability.def.AbilityDefLevel;
   import engine.battle.ability.def.AbilityExecutionEntityConditions;
   import engine.battle.ability.def.BattleAbilityAiPositionalRuleType;
   import engine.battle.ability.def.BattleAbilityDefLevels;
   import engine.battle.ability.def.BattleAbilityRangeType;
   import engine.battle.ability.def.BattleAbilityTag;
   import engine.battle.ability.def.BattleAbilityTargetRule;
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.model.BattleAbilityValidation;
   import engine.battle.board.controller.BattleBoardTargetHelper;
   import engine.battle.board.def.IBattleAttractor;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleBoardTrigger;
   import engine.battle.board.model.IBattleBoardTriggers;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.model.IBattleMove;
   import engine.battle.entity.model.BattleEntity;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleMove;
   import engine.battle.fsm.state.BattleStateTurnAi;
   import engine.core.BoxBoolean;
   import engine.core.logging.ILogger;
   import engine.entity.def.Shitlist;
   import engine.entity.def.ShitlistDef;
   import engine.path.IPath;
   import engine.path.IPathGraph;
   import engine.path.IPathGraphNode;
   import engine.path.PathFloodSolver;
   import engine.path.PathFloodSolverNode;
   import engine.stat.def.StatType;
   import engine.stat.model.Stats;
   import engine.tile.Tile;
   import engine.tile.Tiles;
   import engine.tile.def.TileRect;
   import engine.tile.def.TileRectRange;
   import flash.errors.IllegalOperationError;
   import flash.utils.getTimer;
   
   public class AiModuleBase
   {
      
      private static var gtg:BoxBoolean = new BoxBoolean();
       
      
      public var ss:BattleStateTurnAi;
      
      public var battleFsm:BattleFsm;
      
      public var caster:BattleEntity;
      
      public var enemies:Vector.<IBattleEntity>;
      
      public var friends:Vector.<IBattleEntity>;
      
      public var deads:Vector.<IBattleEntity>;
      
      public var isRanged:Boolean = false;
      
      public var atkStr:AbilityDefLevel;
      
      public var atkArm:AbilityDefLevel;
      
      public var atkStrRoot:IBattleAbilityDef;
      
      public var atkArmRoot:IBattleAbilityDef;
      
      public var moveFlood:IBattleMove;
      
      public var desperation:Number = 0;
      
      public var nextEnemy:IBattleEntity;
      
      public var attx:AiModuleDredge_Attractor;
      
      public var stopped:Boolean;
      
      public var shitlist:Shitlist;
      
      public var logger:ILogger;
      
      public var startingHazard:IBattleBoardTrigger;
      
      private var interestingTilesCalculated:Vector.<Tile>;
      
      public var cleanedup:Boolean;
      
      private var think_ms:Number;
      
      private var _consideredResting:Boolean;
      
      public function AiModuleBase(param1:BattleStateTurnAi)
      {
         this.enemies = new Vector.<IBattleEntity>();
         this.friends = new Vector.<IBattleEntity>();
         this.deads = new Vector.<IBattleEntity>();
         this.think_ms = AiGlobalConfig.minThinkTimeMs;
         super();
         this.battleFsm = param1.battleFsm;
         this.ss = param1;
         this.caster = this.battleFsm.turn.entity as BattleEntity;
         this.moveFlood = this.battleFsm.turn.move;
         var _loc2_:IBattleBoard = this.caster.board;
         var _loc3_:IBattleBoardTriggers = _loc2_.triggers;
         this.startingHazard = !!_loc3_ ? _loc3_.findEntityHazardAtRect(this.caster,null,true) : null;
         this.logger = param1.logger;
         var _loc4_:ShitlistDef = this.caster.shitlistDef;
         if(_loc4_)
         {
            this.shitlist = new Shitlist(this.caster,_loc4_,this.logger);
            this.shitlist.evaluateShitlist();
         }
         this.buildEnemyArray();
         var _loc5_:BattleAbilityDefLevels = this.battleFsm.turn.entity.def.attacks as BattleAbilityDefLevels;
         this.atkStr = _loc5_.getFirstAbilityByTag(BattleAbilityTag.ATTACK_STR);
         this.atkArm = _loc5_.getFirstAbilityByTag(BattleAbilityTag.ATTACK_ARM);
         this.atkStrRoot = !!this.atkStr ? this.atkStr.def.root as IBattleAbilityDef : null;
         this.atkArmRoot = !!this.atkArm ? this.atkArm.def.root as IBattleAbilityDef : null;
         this.isRanged = this.atkStr.id == "abl_bow_str" || this.atkArm.id == "abl_bow_arm";
         this.attx = new AiModuleDredge_Attractor(this);
         this.computeDesperation();
         this.computeNextEnemy();
      }
      
      public function toString() : String
      {
         return "caster=" + this.caster;
      }
      
      private function computeDesperation() : void
      {
         var _loc1_:Stats = this.caster.stats;
         var _loc2_:Number = _loc1_.getPercentOfOriginal(StatType.STRENGTH);
         var _loc3_:Number = 1 - this.caster.party.trauma;
         var _loc4_:Number = Math.min(_loc2_,_loc3_);
         _loc4_ *= _loc4_ * _loc4_;
         this.desperation = 1 - _loc4_;
         if(AiGlobalConfig.DEBUG)
         {
            this.ss.logger.d("AI","DEBUG_AI __computeDesperation__ " + this.caster + " desperation=" + this.desperation.toFixed(2) + " health=" + _loc2_ + ", antitrauma=" + _loc3_);
         }
      }
      
      private function computeNextEnemy() : void
      {
         this.nextEnemy = this.caster.board.fsm.order.peekNextEnemy();
      }
      
      public function performMove() : Boolean
      {
         return false;
      }
      
      public function performAction() : Boolean
      {
         return false;
      }
      
      public function cleanup() : void
      {
         if(this.cleanedup)
         {
            throw new IllegalOperationError("already cleanedup");
         }
         this.cleanedup = true;
         this.battleFsm = null;
         this.caster = null;
         this.enemies = null;
         this.atkStr = null;
         this.atkArm = null;
         this.atkStrRoot = null;
         this.atkArmRoot = null;
      }
      
      protected function buildEnemyArray() : void
      {
         var _loc1_:BattleEntity = null;
         this.enemies.splice(0,this.enemies.length);
         for each(_loc1_ in this.battleFsm.board.entities)
         {
            if(_loc1_.enabled)
            {
               if(_loc1_.alive)
               {
                  if(_loc1_.team != this.caster.team)
                  {
                     if(_loc1_.attackable)
                     {
                        this.enemies.push(_loc1_);
                     }
                  }
                  else
                  {
                     this.friends.push(_loc1_);
                  }
               }
               else
               {
                  this.deads.push(_loc1_);
               }
            }
         }
      }
      
      private function constructRestPlan() : AiPlan
      {
         var _loc1_:IBattleAbilityDef = this.ss.battleFsm.board.abilityManager.getFactory.fetch("abl_rest") as IBattleAbilityDef;
         return new AiPlan(this,null,_loc1_,null,null);
      }
      
      public function findFloodPlans(param1:IBattleAbilityDef, param2:Vector.<AiPlan>, param3:int, param4:int) : int
      {
         var _loc8_:Tile = null;
         var _loc9_:int = 0;
         if(this.caster.board.scene.camera.drift.isAnchorAnimating && !AiGlobalConfig.FAST)
         {
            this.think_ms = AiGlobalConfig.minThinkTimeMs;
            return param3;
         }
         var _loc5_:int = AiGlobalConfig.maxThinkTimeMs;
         this.think_ms = Math.min(_loc5_,this.think_ms + AiGlobalConfig.INCR_THINK_MS);
         var _loc6_:int = getTimer();
         if(param3 == 0)
         {
            this.interestingTilesCalculated = null;
            if(param1.targetRule.isTile)
            {
               this.interestingTilesCalculated = this.computeAblInterestingTargetTiles(param1);
            }
         }
         if(param3 == 0)
         {
            this.computePlansForAblFlood(param1,this.caster.tile,param2,param4,this.interestingTilesCalculated);
            param3++;
         }
         var _loc7_:int = param3;
         while(_loc7_ < this.moveFlood.flood.resultList.length + 1)
         {
            if(_loc7_ > param3)
            {
               _loc9_ = getTimer() - _loc6_;
               if(_loc9_ > this.think_ms)
               {
                  return _loc7_;
               }
            }
            _loc8_ = this.moveFlood.flood.resultList[_loc7_ - 1];
            this.computePlansForAblFlood(param1,_loc8_,param2,param4,this.interestingTilesCalculated);
            _loc7_++;
         }
         return _loc7_;
      }
      
      private function computePlansForAblFlood(param1:IBattleAbilityDef, param2:Tile, param3:Vector.<AiPlan>, param4:int, param5:Vector.<Tile>) : void
      {
         var _loc10_:TileRect = null;
         var _loc11_:Vector.<IBattleEntity> = null;
         var _loc12_:IBattleEntity = null;
         var _loc16_:BattleMove = null;
         var _loc19_:Boolean = false;
         var _loc20_:int = 0;
         var _loc21_:int = 0;
         var _loc22_:Number = NaN;
         var _loc23_:int = 0;
         var _loc24_:Tile = null;
         var _loc25_:IBattleAbilityDef = null;
         var _loc26_:int = 0;
         var _loc27_:AiPlan = null;
         var _loc28_:Vector.<Tile> = null;
         var _loc29_:Vector.<IBattleEntity> = null;
         if(this.caster.localLength == 2 && this.caster.localWidth == 1)
         {
            if(param2 != this.caster.tile)
            {
               if(this.caster.rect.contains(param2.x,param2.y))
               {
                  return;
               }
            }
         }
         var _loc6_:IPathGraphNode = this.caster.board.tiles.pathGraph.getNode(param2);
         var _loc7_:IPath = this.moveFlood.flood.reconstructPathTo(_loc6_);
         var _loc8_:int = int(this.caster.def.stats.getValue(StatType.MOVEMENT));
         var _loc9_:AbilityExecutionEntityConditions = !!param1.conditions ? param1.conditions.caster : null;
         if(Boolean(_loc9_) && Boolean(_loc9_.requireAdjacentAlliesMin))
         {
            _loc10_ = this.caster.rect.clone().setLocation(param2.location);
            if(!_loc9_.checkAdjacentAlliesMinFromRect(this.caster,_loc10_))
            {
               return;
            }
         }
         if(_loc7_.nodes.length > _loc8_ + 1)
         {
            return;
         }
         switch(param1.getAiPositionalRule())
         {
            case BattleAbilityAiPositionalRuleType.HIGHEST_ENEMY_THREAT:
               _loc10_ = this.caster.rect.clone().setLocation(param2.location);
               _loc11_ = this.caster.board.findAllAdjacentEntities(this.caster,_loc10_,null,true);
               if(_loc11_)
               {
                  for each(_loc12_ in _loc11_)
                  {
                     if(_loc12_.team != this.caster.team)
                     {
                        _loc19_ = true;
                        break;
                     }
                  }
               }
               if(!_loc19_)
               {
                  return;
               }
               break;
            case BattleAbilityAiPositionalRuleType.AOE_DAMAGE_ALL:
               _loc10_ = this.caster.rect.clone().setLocation(param2.location);
               _loc11_ = this.caster.board.findAllAdjacentEntities(this.caster,_loc10_,null,true);
               if(_loc11_)
               {
                  for each(_loc12_ in _loc11_)
                  {
                     if(_loc12_.team != this.caster.team)
                     {
                        if(_loc12_.mobile)
                        {
                           _loc20_++;
                        }
                     }
                     else
                     {
                        _loc21_--;
                     }
                  }
               }
               _loc22_ = 1.5;
               if(_loc20_ <= _loc21_ * _loc22_)
               {
                  return;
               }
               break;
         }
         var _loc13_:int = this.caster.stats.getValue(StatType.EXERTION);
         var _loc14_:int = this.caster.stats.getValue(StatType.WILLPOWER);
         var _loc15_:int = Math.min(_loc13_,_loc14_);
         if(_loc7_.nodes.length > 1)
         {
            _loc16_ = new BattleMove(this.caster,_loc15_,0);
            _loc23_ = 1;
            while(_loc23_ < _loc7_.nodes.length)
            {
               _loc24_ = _loc7_.nodes[_loc23_].key as Tile;
               _loc16_.addStep(_loc24_);
               _loc23_++;
            }
         }
         var _loc17_:TileRect = null;
         var _loc18_:int = 1;
         for(; _loc18_ <= param4; _loc18_++)
         {
            _loc25_ = param1.getBattleAbilityDefLevel(_loc18_);
            _loc26_ = int(_loc25_.getCost(StatType.WILLPOWER));
            if(_loc26_ <= _loc15_)
            {
               _loc27_ = null;
               if(_loc25_.targetRule.isTile)
               {
                  if(_loc25_.targetRule == BattleAbilityTargetRule.FORWARD_ARC)
                  {
                     if(!_loc17_)
                     {
                        _loc17_ = !!_loc16_ ? _loc16_.lastTileRect : this.caster.rect.clone();
                     }
                     _loc17_.visitAdjacentTileLocations(this._visitForwardArcPlandler,{
                        "rabldef":_loc25_,
                        "ltr":_loc17_,
                        "results":param3,
                        "move":_loc16_
                     },false,false);
                     continue;
                  }
                  _loc28_ = this.computeAblTargetTiles(_loc25_,_loc16_,param5);
                  if(Boolean(_loc28_) && _loc28_.length == _loc25_.targetCount)
                  {
                     _loc27_ = new AiPlan(this,_loc16_,_loc25_,null,_loc28_);
                  }
               }
               else if(_loc25_.targetRule == BattleAbilityTargetRule.ALL_ALLIES)
               {
                  _loc27_ = new AiPlan(this,_loc16_,_loc25_,this.friends,null);
               }
               else if(_loc25_.targetRule == BattleAbilityTargetRule.ALL_ENEMIES)
               {
                  _loc27_ = new AiPlan(this,_loc16_,_loc25_,this.enemies,null);
               }
               else
               {
                  _loc29_ = new Vector.<IBattleEntity>();
                  _loc29_.push(this.caster);
                  _loc27_ = new AiPlan(this,_loc16_,_loc25_,_loc29_,null);
               }
               if(_loc27_)
               {
                  param3.push(_loc27_);
               }
            }
         }
      }
      
      private function _visitForwardArcPlandler(param1:int, param2:int, param3:Object) : void
      {
         var _loc13_:Boolean = false;
         var _loc14_:BattleEntity = null;
         var _loc4_:Tile = this.caster.board.tiles.getTile(param1,param2);
         if(!_loc4_)
         {
            return;
         }
         var _loc5_:Vector.<AiPlan> = param3.results;
         var _loc6_:TileRect = param3.ltr;
         var _loc7_:IBattleAbilityDef = param3.rabldef;
         var _loc8_:BattleMove = param3.move;
         var _loc9_:IBattleEntity = _loc4_.anyResident as IBattleEntity;
         if(!_loc9_)
         {
            return;
         }
         if(_loc9_.party == this.caster.party)
         {
            return;
         }
         var _loc10_:Vector.<IBattleEntity> = this.getForwardArcTargets(_loc7_,_loc6_,_loc4_);
         if(!_loc10_ || !_loc10_.length)
         {
            return;
         }
         for each(_loc14_ in _loc10_)
         {
            if(_loc14_.party != this.caster.party)
            {
               _loc13_ = true;
            }
         }
         if(!_loc13_)
         {
            return;
         }
         var _loc11_:Vector.<Tile> = new Vector.<Tile>();
         var _loc12_:AiPlan = new AiPlan(this,_loc8_,_loc7_,_loc10_,_loc11_);
         _loc5_.push(_loc12_);
      }
      
      private function computeAblInterestingTargetTiles(param1:IBattleAbilityDef) : Vector.<Tile>
      {
         var _loc2_:Array = null;
         var _loc4_:Tile = null;
         var _loc5_:Vector.<Tile> = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:Object = null;
         var _loc3_:Vector.<IBattleEntity> = AiPlanUtil.enemiesWhichHaveTileWeight(this.caster,this.enemies);
         for each(_loc4_ in this.caster.board.tiles.tiles)
         {
            if(_loc4_.getWalkableFor(this.caster))
            {
               if(param1.targetRule == BattleAbilityTargetRule.TILE_EMPTY)
               {
                  if(_loc4_.numResidents)
                  {
                     continue;
                  }
               }
               if(param1.targetRule == BattleAbilityTargetRule.TILE_EMPTY_1x2_FACING_CASTER)
               {
                  if(!BattleAbilityValidation.validateTile(this.caster,param1.targetRule,_loc4_))
                  {
                     continue;
                  }
               }
               _loc6_ = AiPlanUtil.computeTileAdjacentEnemyWeight(this.caster,_loc4_,_loc3_);
               if(_loc6_ > 0)
               {
                  if(!_loc2_)
                  {
                     _loc2_ = [];
                  }
                  _loc2_.push({
                     "w":_loc6_,
                     "tile":_loc4_
                  });
               }
            }
         }
         if(Boolean(_loc2_) && _loc2_.length >= param1.targetCount)
         {
            _loc2_.sortOn("w",Array.DESCENDING | Array.NUMERIC);
            _loc5_ = new Vector.<Tile>();
            _loc7_ = 0;
            while(_loc7_ < _loc2_.length)
            {
               _loc8_ = _loc2_[_loc7_];
               _loc5_.push(_loc8_.tile);
               _loc7_++;
            }
         }
         return _loc5_;
      }
      
      private function computeAblTargetTiles(param1:IBattleAbilityDef, param2:IBattleMove, param3:Vector.<Tile>) : Vector.<Tile>
      {
         var _loc4_:Vector.<Tile> = null;
         var _loc6_:Tile = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc5_:TileRect = !!param2 ? param2.lastTileRect : this.caster.rect.clone();
         for each(_loc6_ in param3)
         {
            _loc7_ = TileRectRange.computeTileRange(_loc6_.location,_loc5_);
            _loc8_ = param1.rangeMax(this.caster);
            _loc9_ = param1.rangeMin(this.caster);
            if(!(_loc8_ > 0 && _loc7_ > _loc8_))
            {
               if(!(_loc9_ > 0 && _loc7_ < _loc9_))
               {
                  if(!_loc4_)
                  {
                     _loc4_ = new Vector.<Tile>();
                  }
                  _loc4_.push(_loc6_);
                  if(_loc4_.length == param1.targetCount)
                  {
                     return _loc4_;
                  }
               }
            }
         }
         return null;
      }
      
      private function getForwardArcTargets(param1:IBattleAbilityDef, param2:TileRect, param3:Tile) : Vector.<IBattleEntity>
      {
         var _loc6_:Vector.<IBattleEntity> = null;
         var _loc7_:IBattleEntity = null;
         var _loc4_:Vector.<IBattleEntity> = new Vector.<IBattleEntity>();
         var _loc5_:Tiles = this.caster.board.tiles;
         BattleBoardTargetHelper.forwardArc_getVictims(this.caster,param2,param3,_loc4_);
         if(_loc4_.length)
         {
            _loc6_ = new Vector.<IBattleEntity>();
            for each(_loc7_ in _loc4_)
            {
               _loc6_.push(_loc7_ as BattleEntity);
            }
            return _loc6_;
         }
         return null;
      }
      
      public function findPlans(param1:IBattleAbilityDef, param2:Vector.<IBattleEntity>, param3:Vector.<AiPlan>, param4:int, param5:int) : int
      {
         var _loc9_:IBattleEntity = null;
         var _loc10_:int = 0;
         if(this.caster.board.scene.camera.drift.isAnchorAnimating && !AiGlobalConfig.FAST)
         {
            this.think_ms = AiGlobalConfig.MIN_THINK_MS;
            return param4;
         }
         var _loc6_:int = AiGlobalConfig.maxThinkTimeMs;
         this.think_ms = Math.min(_loc6_,this.think_ms + AiGlobalConfig.INCR_THINK_MS);
         var _loc7_:int = getTimer();
         var _loc8_:int = param4;
         while(_loc8_ < param2.length)
         {
            if(_loc8_ > param4)
            {
               _loc10_ = getTimer() - _loc7_;
               if(_loc10_ > this.think_ms)
               {
                  return _loc8_;
               }
            }
            _loc9_ = param2[_loc8_];
            this.computePlansForAblTarget(param1,_loc9_,param3,param5);
            _loc8_++;
         }
         return _loc8_;
      }
      
      private function createAttackOfOpportunity(param1:IBattleAbilityDef, param2:IBattleEntity, param3:int, param4:IBattleMove) : AiPlan
      {
         if(!param1)
         {
            return null;
         }
         if(!this._checkCanUseAbility(param1,param3,param4,param2))
         {
            return null;
         }
         var _loc5_:Vector.<IBattleEntity> = new Vector.<IBattleEntity>();
         _loc5_.push(param2);
         if(AiGlobalConfig.DEBUG)
         {
            this.ss.logger.i(" AI ","DEBUG_AI creating attack of opportunity vs. " + param2 + " with " + param1);
         }
         return new AiPlan(this,param4,param1,_loc5_,null);
      }
      
      public function createAttacksOfOpportunity(param1:IBattleAbilityDef, param2:Vector.<AiPlan>, param3:IBattleMove, param4:IBattleEntity, param5:int) : void
      {
         var _loc7_:Boolean = false;
         var _loc8_:BattleEntity = null;
         var _loc6_:AiPlan = null;
         if(AiGlobalConfig.DEBUG)
         {
            if(param4)
            {
               this.ss.logger.i(" AI ","DEBUG_AI creating attacks of opportunity of too-short move " + param3 + " intended originally vs. " + param4);
            }
            else
            {
               this.ss.logger.i(" AI ","DEBUG_AI creating attacks of opportunity");
            }
         }
         if(!param1)
         {
            param1 = this.atkStrRoot;
         }
         for each(_loc8_ in this.enemies)
         {
            if(!(!_loc8_.alive || !_loc8_.mobile || !this.caster.awareOf(_loc8_) || !this.caster.canAttack(_loc8_)))
            {
               _loc6_ = this.createAttackOfOpportunity(param1,_loc8_,param5,param3);
               if(_loc6_)
               {
                  param2.push(_loc6_);
                  _loc7_ = true;
               }
               if(param1 != this.atkStrRoot && param1 != this.atkArmRoot)
               {
                  _loc6_ = this.createAttackOfOpportunity(this.atkStrRoot,_loc8_,param5,param3);
                  if(_loc6_)
                  {
                     param2.push(_loc6_);
                     _loc7_ = true;
                  }
                  _loc6_ = this.createAttackOfOpportunity(this.atkArmRoot,_loc8_,param5,param3);
                  if(_loc6_)
                  {
                     param2.push(_loc6_);
                     _loc7_ = true;
                  }
               }
            }
         }
         if(!_loc7_)
         {
            _loc6_ = new AiPlan(this,param3,null,null,null);
            param2.push(_loc6_);
         }
      }
      
      private function _verifyComputePlansForAblTarget(param1:IBattleAbilityDef, param2:IBattleEntity) : Boolean
      {
         if(!param2.mobile && param1.tag == BattleAbilityTag.SPECIAL)
         {
            return false;
         }
         if(!param1.checkTargetStatRanges(param2.stats))
         {
            return false;
         }
         if(param1.root == this.atkArmRoot)
         {
            if(!param2.stats.hasStat(StatType.ARMOR))
            {
               return false;
            }
         }
         if(!this.caster.awareOf(param2))
         {
            return false;
         }
         if(Boolean(param2.stats) && param2.stats.getValue(StatType.AI_IGNORE) > 0)
         {
            return false;
         }
         var _loc3_:IBattleAbilityDef = param1.getAiRulesAbility();
         if(Boolean(_loc3_) && !_loc3_.checkTargetStatRanges(param2.stats))
         {
            return false;
         }
         return true;
      }
      
      private function _considerResting(param1:Tile, param2:int, param3:int, param4:Vector.<AiPlan>) : Boolean
      {
         var _loc8_:AiPlan = null;
         var _loc5_:int = this.caster.stats.getValue(StatType.EXERTION);
         var _loc6_:int = AiPlan.computePositionalWeight(this,null,this.caster.tile,null);
         var _loc7_:int = AiPlan.computePositionalWeight(this,null,param1,null);
         if(_loc7_ <= _loc6_)
         {
            if(param2 < param3 && param2 < _loc5_)
            {
               if(!this._consideredResting)
               {
                  this._consideredResting = true;
                  _loc8_ = this.constructRestPlan();
                  param4.push(_loc8_);
               }
               return true;
            }
         }
         return false;
      }
      
      private function computePlansForAblTarget(param1:IBattleAbilityDef, param2:IBattleEntity, param3:Vector.<AiPlan>, param4:int) : void
      {
         var _loc13_:BattleMove = null;
         var _loc16_:TileRect = null;
         var _loc17_:Vector.<IBattleEntity> = null;
         var _loc18_:* = false;
         var _loc19_:Boolean = false;
         var _loc20_:IBattleAttractor = null;
         var _loc21_:int = 0;
         var _loc22_:int = 0;
         var _loc23_:int = 0;
         var _loc24_:BattleMove = null;
         var _loc25_:Vector.<IBattleEntity> = null;
         var _loc26_:IBattleEntity = null;
         var _loc27_:int = 0;
         var _loc28_:IBattleAbilityDef = null;
         if(!this._verifyComputePlansForAblTarget(param1,param2))
         {
            return;
         }
         var _loc5_:Boolean = Boolean(param1) && param1.tag == BattleAbilityTag.SPECIAL;
         var _loc6_:int = this.caster.stats.getValue(StatType.EXERTION);
         var _loc7_:int = this.caster.stats.getValue(StatType.WILLPOWER);
         var _loc8_:int = this.caster.stats.getValue(StatType.WILLPOWER_MOVE,1);
         var _loc9_:int = _loc5_ ? _loc7_ : int(Math.min(_loc6_,_loc7_));
         var _loc10_:int = this.caster.stats.getStat(StatType.WILLPOWER).original;
         var _loc11_:int = int(this.caster.def.stats.getValue(StatType.MOVEMENT));
         var _loc12_:AiPlan = null;
         var _loc14_:Vector.<IBattleEntity> = new Vector.<IBattleEntity>();
         _loc14_.push(param2);
         var _loc15_:BattleAbilityTargetRule = param1.targetRule;
         gtg.value = false;
         if(param1.getRangeType() == BattleAbilityRangeType.NONE || _loc11_ <= 0 && _loc9_ <= 0)
         {
            _loc13_ = new BattleMove(this.caster);
            gtg.value = true;
         }
         else
         {
            _loc18_ = this.startingHazard != null;
            _loc20_ = this.caster.attractor;
            _loc13_ = BattleMove.computeMoveToRange(param1,this.caster,param2,null,this.ss.logger,_loc9_,gtg,_loc20_,_loc18_,_loc19_);
            if(_loc13_)
            {
               if(_loc13_.pathEndBlocked)
               {
                  this.ss.logger.e(" AI ","computePlansForAblTarget generated a move with pathEndBlocked: " + _loc13_);
                  return;
               }
               _loc21_ = Math.max(0,_loc13_.numSteps - 1 - _loc11_);
               if(_loc21_ > 0)
               {
                  _loc22_ = 1 + (_loc21_ - 1) / _loc8_;
                  _loc23_ = _loc7_ - _loc22_;
                  if(AiGlobalConfig.DEBUG)
                  {
                     this.ss.logger.i(" AI ","DEBUG_AI reduce available willpower from " + _loc7_ + " to " + _loc23_ + " for move " + _loc13_);
                  }
                  _loc7_ = _loc23_;
                  _loc9_ = _loc5_ ? _loc7_ : int(Math.min(_loc6_,_loc7_));
               }
               if(!gtg.value)
               {
                  if(_loc5_)
                  {
                     return;
                  }
                  if(this._considerResting(_loc13_.last,_loc7_,_loc10_,param3))
                  {
                     return;
                  }
                  this.createAttacksOfOpportunity(param1,param3,_loc13_,param2,_loc7_);
                  return;
               }
               _loc24_ = new BattleMove(this.caster,_loc9_,0,false);
               if(_loc24_.pathTowardRect(param2.rect,true,_loc11_,false))
               {
                  if(_loc24_.pathEndBlocked)
                  {
                     this.logger.error("BattleMove.computeMoveToRange generated a move with pathEndBlocked: " + _loc13_);
                     _loc24_.cleanup();
                  }
                  else
                  {
                     this.createAttacksOfOpportunity(param1,param3,_loc24_,param2,_loc7_);
                  }
               }
            }
         }
         if(_loc15_ == BattleAbilityTargetRule.ADJACENT_BATTLEENTITY)
         {
            _loc16_ = this.caster.rect;
            if(_loc13_)
            {
               _loc16_ = _loc13_.lastTileRect;
            }
            _loc14_.splice(0,_loc14_.length);
            _loc17_ = new Vector.<IBattleEntity>();
            BattleBoardTargetHelper.selectAdjacent(this.caster,_loc16_,param1.targetRule,_loc17_);
            _loc25_ = new Vector.<IBattleEntity>();
            BattleBoardTargetHelper.sortClockwise(this.caster,param2,_loc17_,_loc25_);
            for each(_loc26_ in _loc25_)
            {
               if(_loc26_.team == this.caster.team)
               {
                  return;
               }
               _loc14_.push(_loc26_);
            }
         }
         else if(_loc15_ == BattleAbilityTargetRule.FORWARD_ARC)
         {
            this.ss.logger.error("Don\'t handle this type of target Rule " + _loc15_ + " for " + this);
         }
         if(gtg.value)
         {
            _loc27_ = 1;
            while(_loc27_ <= param4)
            {
               _loc28_ = param1.getBattleAbilityDefLevel(_loc27_);
               if(this._checkCanUseAbility(_loc28_,_loc7_,_loc13_,param2))
               {
                  _loc12_ = new AiPlan(this,_loc13_,_loc28_,_loc14_,null);
                  param3.push(_loc12_);
               }
               _loc27_++;
            }
         }
      }
      
      private function _checkCanUseAbility(param1:IBattleAbilityDef, param2:int, param3:IBattleMove, param4:IBattleEntity) : Boolean
      {
         var _loc6_:BattleAbilityTargetRule = null;
         var _loc7_:* = false;
         var _loc8_:BattleAbilityValidation = null;
         var _loc5_:int = int(param1.getCost(StatType.WILLPOWER));
         if(_loc5_ <= param2)
         {
            _loc6_ = param1.targetRule;
            if(_loc6_ == BattleAbilityTargetRule.ENEMY || _loc6_ == BattleAbilityTargetRule.FRIENDLY_OTHER || _loc6_ == BattleAbilityTargetRule.DEAD || _loc6_ == BattleAbilityTargetRule.SPECIAL_TRAMPLE || _loc6_ == BattleAbilityTargetRule.SPECIAL_BATTERING_RAM || _loc6_ == BattleAbilityTargetRule.SPECIAL_RUN_TO || _loc6_ == BattleAbilityTargetRule.SPECIAL_RUN_THROUGH)
            {
               _loc7_ = _loc6_ != BattleAbilityTargetRule.DEAD;
               _loc8_ = BattleAbilityValidation.validate(param1,this.caster,param3,param4,null,false,true,true,_loc7_);
               if(!_loc8_ || !_loc8_.ok)
               {
                  if(AiGlobalConfig.DEBUG)
                  {
                     this.ss.logger.i(" AI ","DEBUG_AI " + this.caster.id + " cannot " + param1 + " vs " + param4 + ": " + _loc8_);
                  }
                  return false;
               }
            }
            return true;
         }
         if(AiGlobalConfig.DEBUG)
         {
            this.ss.logger.i(" AI ","DEBUG_AI not enough willpower for " + param1);
         }
         return false;
      }
      
      protected function isInRangeOfEnemyForAttack() : Boolean
      {
         return false;
      }
      
      protected function getMovementTargetTiles() : Array
      {
         var _loc2_:Tile = null;
         var _loc3_:BattleEntity = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc1_:Array = new Array();
         for each(_loc3_ in this.enemies)
         {
            _loc4_ = _loc3_.pos.x;
            _loc5_ = _loc3_.pos.y;
            if(_loc3_.rect.width == 1)
            {
               this.addMovementTargetTile(_loc4_,_loc5_ - 1,_loc1_);
               this.addMovementTargetTile(_loc4_ + 1,_loc5_,_loc1_);
               this.addMovementTargetTile(_loc4_,_loc5_ + 1,_loc1_);
               this.addMovementTargetTile(_loc4_ - 1,_loc5_,_loc1_);
            }
            else if(_loc3_.rect.width == 2)
            {
               this.addMovementTargetTile(_loc4_,_loc5_ + 2,_loc1_);
               this.addMovementTargetTile(_loc4_ + 1,_loc5_ + 2,_loc1_);
               this.addMovementTargetTile(_loc4_ + 2,_loc5_ + 1,_loc1_);
               this.addMovementTargetTile(_loc4_ + 2,_loc5_,_loc1_);
               this.addMovementTargetTile(_loc4_,_loc5_ - 1,_loc1_);
               this.addMovementTargetTile(_loc4_ + 1,_loc5_ - 1,_loc1_);
               this.addMovementTargetTile(_loc4_ - 1,_loc5_ + 1,_loc1_);
               this.addMovementTargetTile(_loc4_ - 1,_loc5_,_loc1_);
            }
         }
         return _loc1_;
      }
      
      protected function addMovementTargetTile(param1:int, param2:int, param3:Array) : void
      {
         var _loc4_:Tile = this.battleFsm.board.tiles.getTile(param1,param2);
         if(_loc4_ != null && param3.indexOf(_loc4_) == -1)
         {
            if(this.battleFsm.board.tiles.isTileBlockedForEntity(this.caster,_loc4_) == false)
            {
               param3.push(_loc4_);
            }
         }
      }
      
      protected function getNearestTile(param1:Array) : Tile
      {
         var _loc4_:Tile = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc2_:Tile = null;
         var _loc3_:int = int.MAX_VALUE;
         for each(_loc4_ in param1)
         {
            _loc5_ = _loc4_.x - this.caster.x;
            _loc6_ = _loc4_.y - this.caster.y;
            _loc7_ = _loc5_ * _loc5_ + _loc6_ * _loc6_;
            if(_loc7_ < _loc3_)
            {
               _loc3_ = _loc7_;
               _loc2_ = _loc4_;
            }
         }
         return _loc2_;
      }
      
      public function runAway(param1:int) : void
      {
         var _loc3_:Tile = null;
         var _loc4_:IPathGraphNode = null;
         var _loc5_:PathFloodSolverNode = null;
         var _loc9_:Tile = null;
         var _loc10_:IPathGraphNode = null;
         var _loc11_:PathFloodSolverNode = null;
         var _loc12_:int = 0;
         var _loc13_:IPath = null;
         var _loc14_:Tile = null;
         this.ss.logger.i(" AI ","runAway " + this.caster + " on moveFlood for " + this.moveFlood.entity);
         if(this.moveFlood.cleanedup)
         {
            this.ss.logger.e(" AI ","turn move got cleanedup before runAway, shame on you.");
            this.ss.skip(false,"AiModuleBase.runAway cleanedup",false);
         }
         this.moveFlood.reset(this.caster.tile);
         var _loc2_:int = -1000000;
         var _loc6_:IPathGraph = this.caster.board.tiles.pathGraph;
         var _loc7_:PathFloodSolver = this.moveFlood.flood;
         var _loc8_:int = 1;
         while(_loc8_ < _loc7_.resultList.length + 1)
         {
            _loc9_ = _loc7_.resultList[_loc8_ - 1];
            if(_loc9_.getWalkableFor(this.caster))
            {
               _loc10_ = _loc6_.getNode(_loc9_);
               _loc11_ = _loc7_.getNode(_loc10_);
               if(_loc11_.g <= param1)
               {
                  _loc12_ = AiPlan.computePositionalWeightEnemies(this,null,_loc9_,null);
                  _loc12_ = -_loc12_;
                  if(_loc12_ > _loc2_)
                  {
                     _loc2_ = _loc12_;
                     _loc3_ = _loc9_;
                     _loc4_ = _loc10_;
                     _loc5_ = _loc11_;
                  }
               }
            }
            _loc8_++;
         }
         if(_loc3_)
         {
            _loc13_ = _loc7_.reconstructPathTo(_loc4_);
            _loc8_ = 1;
            while(_loc8_ < _loc13_.nodes.length)
            {
               _loc14_ = _loc13_.nodes[_loc8_].key as Tile;
               this.moveFlood.addStep(_loc14_);
               _loc8_++;
            }
            this.moveFlood.trimImpossibleEndpoints();
            if(this.moveFlood.numSteps > 1)
            {
               this.moveFlood.setCommitted("AiModuleDredge.runAway");
               this.battleFsm.turn.entity.mobility.executeMove(this.moveFlood);
            }
            else
            {
               this.ss.skip(false,"AiModuleBase.runAway bestTile=" + _loc3_,false);
            }
         }
         else
         {
            this.ss.skip(false,"AiModuleBase.runAway nowhere",false);
         }
      }
   }
}
