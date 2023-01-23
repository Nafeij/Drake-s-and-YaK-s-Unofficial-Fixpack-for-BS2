package engine.battle.fsm.aimodule
{
   import engine.ability.IAbilityDefLevel;
   import engine.ability.IAbilityDefLevels;
   import engine.battle.ability.def.BattleAbilityAiTargetRuleType;
   import engine.battle.ability.def.BattleAbilityAiUseRuleType;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityDefLevels;
   import engine.battle.ability.def.BattleAbilityTag;
   import engine.battle.ability.def.BattleAbilityTargetRule;
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.ability.effect.op.model.Op_TileSpray;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.IBattleAbilityManager;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.BattleBoard_SpatialUtil;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.model.IBattleMove;
   import engine.battle.entity.model.BattleEntity;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.battle.fsm.IBattleTurn;
   import engine.battle.fsm.state.BattleStateTurnAi;
   import engine.battle.fsm.state.turn.cmd.BattleTurnCmdAction;
   import engine.math.Rng;
   import engine.saga.ISaga;
   import engine.stat.def.StatType;
   import engine.tile.Tile;
   import engine.tile.def.TileRectRange;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   
   public class AiModuleDredge extends AiModuleBase
   {
      
      public static var HOLD_CHOICE:Boolean;
      
      public static var RELEASE_CHOICE:Boolean;
      
      public static var _averageThinkMs:int;
      
      public static var _averageThinkCount:int;
      
      public static var _averageThinkElapsedMs:int;
      
      public static var _globalWallTotalMs:int;
      
      public static var _globalFramesTotal:int;
      
      public static var _averageWallMs:int;
      
      public static var _averageFrames:int;
      
      private static var WALL_WAIT_LIMIT:int = 15000;
       
      
      private var chosenPlan:AiPlan;
      
      private var plans:Vector.<AiPlan>;
      
      private var timer:Timer;
      
      private var stars:int = 0;
      
      private var acts:Array;
      
      private var maxStars:int = 0;
      
      private var activeRankStat:StatType;
      
      private var actIndex:int;
      
      private var brkIndex:int;
      
      private var strIndex:int;
      
      private var actsIndex:int;
      
      public var saga:ISaga;
      
      public var rng:Rng;
      
      private var _performedAction:Boolean;
      
      private var considering_ability_root:BattleAbilityDef;
      
      private var adj:Vector.<IBattleEntity>;
      
      private var considered_ability_facing:BattleFacing;
      
      private var _elapsedThinkMs:int;
      
      private var _startWallMs:int;
      
      private var _startFrame:int;
      
      private var wall_hit:Boolean;
      
      private var _gated_abilities:Boolean;
      
      private var _gated_moving:Boolean;
      
      public function AiModuleDredge(param1:BattleStateTurnAi)
      {
         this.plans = new Vector.<AiPlan>();
         this.timer = new Timer(0,0);
         this.acts = [];
         this.adj = new Vector.<IBattleEntity>();
         RELEASE_CHOICE = false;
         super(param1);
         this.saga = param1.battleFsm.board.scene.context.saga;
         this.rng = param1.battleFsm.board.scene.context.rng;
         this._startWallMs = getTimer();
         this._startFrame = ss.logger.frameNumber;
      }
      
      override public function performMove() : Boolean
      {
         var _loc1_:Array = null;
         var _loc2_:Tile = null;
         if(battleFsm.turn.suspended || ss.skipped)
         {
            return false;
         }
         this.timer.addEventListener(TimerEvent.TIMER,this.timerHandler);
         this.timer.start();
         var _loc3_:int = caster.stats.getValue(StatType.EXERTION);
         var _loc4_:int = caster.stats.getValue(StatType.WILLPOWER);
         var _loc5_:* = (caster.def.actives as BattleAbilityDefLevels).getFirstAbilityByTag(BattleAbilityTag.SPECIAL) != null;
         if(_loc5_ && _loc4_ > 0)
         {
            if(desperation < 0.25)
            {
               _loc4_--;
            }
         }
         this.stars = Math.min(_loc3_,_loc4_);
         this.computeMaxStars();
         if(AiGlobalConfig.DEBUG)
         {
            ss.logger.d("AI","DEBUG_AI __performMove__ " + caster + " maxStars=" + this.maxStars + "/" + this.stars);
         }
         caster.addEventListener(BattleEntityEvent.ALIVE,this.aliveHandler);
         return true;
      }
      
      private function computeMaxStars() : void
      {
         this.maxStars = this.stars;
      }
      
      private function terminateTheState() : void
      {
         if(cleanedup)
         {
            return;
         }
         if(this._performedAction)
         {
            return;
         }
         this.chosenPlan = this.makeNullPlan();
         this.performAction();
      }
      
      private function aliveHandler(param1:BattleEntityEvent) : void
      {
         if(caster)
         {
            caster.removeEventListener(BattleEntityEvent.ALIVE,this.aliveHandler);
         }
         if(this.timer)
         {
            this.timer.removeEventListener(TimerEvent.TIMER,this.timerHandler);
            this.timer.stop();
            this.timer = null;
         }
         this.terminateTheState();
      }
      
      private function timerHandler(param1:TimerEvent) : void
      {
         var event:TimerEvent = param1;
         if(!caster)
         {
            return;
         }
         if(stopped)
         {
            return;
         }
         if(!caster.alive)
         {
            this.terminateTheState();
            return;
         }
         try
         {
            this.tickAi();
         }
         catch(err:Error)
         {
            ss.logger.e(" AI ","Failed to tick Ai " + this + " -- ending turn");
            ss.logger.e(" AI ",err.getStackTrace());
            terminateTheState();
         }
      }
      
      override public function cleanup() : void
      {
         if(caster)
         {
            caster.removeEventListener(BattleEntityEvent.ALIVE,this.aliveHandler);
         }
         if(this.timer)
         {
            this.timer.removeEventListener(TimerEvent.TIMER,this.timerHandler);
            this.timer.stop();
            this.timer = null;
         }
         super.cleanup();
      }
      
      private function isSelfAbilityOk(param1:BattleAbilityDef) : Boolean
      {
         var _loc2_:BattleEntity = null;
         for each(_loc2_ in enemies)
         {
            if(TileRectRange.computeRange(_loc2_.rect,caster.rect) <= 1)
            {
               return true;
            }
         }
         return false;
      }
      
      private function isAiUseRuleOk(param1:BattleAbilityAiUseRuleType, param2:BattleAbilityDef) : Boolean
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         switch(param1)
         {
            case BattleAbilityAiUseRuleType.STR_LE_HALF:
               _loc3_ = caster.stats.getValue(StatType.STRENGTH);
               _loc4_ = caster.stats.getStat(StatType.STRENGTH).original;
               if(_loc3_ > _loc4_ / 2)
               {
                  return false;
               }
               break;
            case BattleAbilityAiUseRuleType.ALLIES_NEAR_ENEMIES:
               _loc5_ = this._countAlliesNearEnemies(2,param2);
               if(_loc5_ < 2)
               {
                  return false;
               }
               break;
         }
         return true;
      }
      
      private function _countAlliesNearEnemies(param1:int, param2:BattleAbilityDef) : int
      {
         var _loc3_:int = 0;
         var _loc4_:BattleEntity = null;
         var _loc5_:BattleEntity = null;
         for each(_loc4_ in friends)
         {
            if(param2)
            {
               if(!param2.checkCasterExecutionConditions(_loc4_,ss.logger,true))
               {
                  continue;
               }
            }
            for each(_loc5_ in enemies)
            {
               if(param2)
               {
                  if(!param2.checkTargetExecutionConditions(_loc5_,ss.logger,true))
                  {
                     continue;
                  }
               }
               if(TileRectRange.computeRange(_loc4_.rect,_loc5_.rect) <= 1)
               {
                  _loc3_++;
                  if(_loc3_ >= param1)
                  {
                     return _loc3_;
                  }
                  break;
               }
            }
         }
         return _loc3_;
      }
      
      private function checkConsiderAbilityRules(param1:BattleAbilityDef) : Boolean
      {
         var _loc2_:BattleEntity = null;
         var _loc3_:BattleFacing = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:BattleFacing = null;
         var _loc9_:Array = null;
         var _loc10_:int = 0;
         var _loc11_:Tile = null;
         var _loc12_:IBattleEntity = null;
         if(!param1)
         {
            return false;
         }
         this.considered_ability_facing = null;
         if(param1.aiTargetRule == BattleAbilityAiTargetRuleType.WILLPOWER_DOMINANCE)
         {
            if(caster.stats.getValue(StatType.WILLPOWER) <= 0)
            {
               return false;
            }
         }
         if(param1.targetRule == BattleAbilityTargetRule.ALL_ALLIES)
         {
            if(friends.length <= 1)
            {
               return false;
            }
            for each(_loc2_ in friends)
            {
               if(_loc2_ != caster)
               {
                  if(param1.checkTargetStatRanges(_loc2_.stats))
                  {
                     if(param1.aiTargetRule != BattleAbilityAiTargetRuleType.TILE_MAX_ADJACENT_ENEMY)
                     {
                        return true;
                     }
                     if(BattleBoard_SpatialUtil.checkAdjacentEnemies(_loc2_,this.adj,true))
                     {
                        return true;
                     }
                  }
               }
            }
            return false;
         }
         if(param1.aiTargetRule == BattleAbilityAiTargetRuleType.TILESPRAY_ENEMIES)
         {
            _loc5_ = 2;
            _loc6_ = 5;
            _loc7_ = _loc5_ * _loc6_;
            for each(_loc8_ in BattleFacing.facings)
            {
               _loc9_ = Op_TileSpray.getSprayTiles(caster,_loc8_,_loc5_,_loc6_);
               if(_loc9_.length == _loc7_)
               {
                  _loc10_ = 0;
                  for each(_loc11_ in _loc9_)
                  {
                     _loc12_ = _loc11_.findResident(caster) as IBattleEntity;
                     if(_loc12_)
                     {
                        if(!(!_loc12_.party || !_loc12_.mobile))
                        {
                           if(_loc12_.party != caster.party)
                           {
                              _loc10_ += 1;
                           }
                           else
                           {
                              _loc10_ -= 2;
                           }
                        }
                     }
                  }
                  if(_loc10_ > _loc4_)
                  {
                     _loc4_ = _loc10_;
                     _loc3_ = _loc8_;
                  }
               }
            }
            if(!_loc3_)
            {
               return false;
            }
            this.considered_ability_facing = _loc3_;
         }
         return true;
      }
      
      private function considerAbilityRoot(param1:int) : BattleAbilityDef
      {
         var _loc3_:Number = NaN;
         var _loc2_:BattleAbilityDef = !!caster._def.actives ? caster._def.actives.getAbilityDef(param1) as BattleAbilityDef : null;
         if(!_loc2_ || _loc2_.tag != BattleAbilityTag.SPECIAL)
         {
            return null;
         }
         if(!_loc2_.checkCasterExecutionConditions(caster,ss.logger,true))
         {
            return null;
         }
         if(AiGlobalConfig.UNWILLING)
         {
            return null;
         }
         if(!AiGlobalConfig.EAGER)
         {
            if(!this.isAiUseRuleOk(_loc2_.aiUseRule,_loc2_.aiRulesAbility))
            {
               return null;
            }
            if(_loc2_.aiFrequency < 1)
            {
               if(caster.aiChoseAbilityLastTurn)
               {
                  return null;
               }
               _loc3_ = this.rng.nextNumber();
               if(_loc3_ > _loc2_.aiFrequency)
               {
                  return null;
               }
            }
         }
         if(!this.checkConsiderAbilityRules(_loc2_))
         {
            return null;
         }
         if(_loc2_.aiRulesAbility)
         {
            if(!this.checkConsiderAbilityRules(_loc2_.aiRulesAbility))
            {
               return null;
            }
         }
         return _loc2_.root as BattleAbilityDef;
      }
      
      private function checkGateAi() : Boolean
      {
         var _loc1_:BattleBoard = !!battleFsm ? battleFsm.board as BattleBoard : null;
         if(_loc1_)
         {
            if(Boolean(_loc1_._abilityManager) && Boolean(_loc1_._abilityManager.numIncompleteAbilities))
            {
               if(!this._gated_abilities)
               {
                  this._gated_abilities = true;
                  ss.logger.info("AiModuleDredge GATING on incomplete abilities");
               }
               return this.gateAi();
            }
         }
         if(caster && caster.mobility && caster.mobility.moving)
         {
            if(!this._gated_moving)
            {
               this._gated_moving = true;
               ss.logger.info("AiModuleDredge GATING on moving " + caster);
            }
            return this.gateAi();
         }
         return false;
      }
      
      private function gateAi() : Boolean
      {
         var _loc1_:int = getTimer() - this._startWallMs;
         if(_loc1_ < WALL_WAIT_LIMIT)
         {
            return true;
         }
         if(!this.wall_hit)
         {
            ss.logger.error("Waited too long for external ability completion: " + this);
         }
         this.wall_hit = true;
         return false;
      }
      
      private function considerAbilityRootPlans(param1:int, param2:int) : Boolean
      {
         var _loc3_:BattleEntity = null;
         if(!this.considering_ability_root)
         {
            return false;
         }
         switch(this.considering_ability_root.targetRule)
         {
            case BattleAbilityTargetRule.SELF:
            case BattleAbilityTargetRule.SELF_AOE_1:
            case BattleAbilityTargetRule.SELF_AOE_ENEMY_1:
            case BattleAbilityTargetRule.NONE:
            case BattleAbilityTargetRule.ANY:
            case BattleAbilityTargetRule.ALL_ALLIES:
            case BattleAbilityTargetRule.ALL_ENEMIES:
               if(this.actIndex < moveFlood.flood.resultList.length + 1)
               {
                  this.actIndex = findFloodPlans(this.considering_ability_root,this.plans,this.actIndex,param2);
                  this._elapsedThinkMs += getTimer() - param1;
                  return true;
               }
               break;
            case BattleAbilityTargetRule.FRIENDLY_OTHER:
            case BattleAbilityTargetRule.FRIENDLY:
               if(this.actIndex < friends.length)
               {
                  this.actIndex = findPlans(this.considering_ability_root,friends,this.plans,this.actIndex,param2);
                  this._elapsedThinkMs += getTimer() - param1;
                  return true;
               }
               break;
            case BattleAbilityTargetRule.TILE_ANY:
            case BattleAbilityTargetRule.TILE_EMPTY:
            case BattleAbilityTargetRule.TILE_EMPTY_RANDOM:
            case BattleAbilityTargetRule.TILE_EMPTY_1x2_FACING_CASTER:
            case BattleAbilityTargetRule.FORWARD_ARC:
               if(this.actIndex < moveFlood.flood.resultList.length + 1)
               {
                  this.actIndex = findFloodPlans(this.considering_ability_root,this.plans,this.actIndex,param2);
                  this._elapsedThinkMs += getTimer() - param1;
                  return true;
               }
               break;
            case BattleAbilityTargetRule.DEAD:
               if(this.actIndex < deads.length)
               {
                  this.actIndex = findPlans(this.considering_ability_root,deads,this.plans,this.actIndex,param2);
                  this._elapsedThinkMs += getTimer() - param1;
                  return true;
               }
               break;
            default:
               if(this.actIndex < enemies.length)
               {
                  this.actIndex = findPlans(this.considering_ability_root,enemies,this.plans,this.actIndex,param2);
                  this._elapsedThinkMs += getTimer() - param1;
                  return true;
               }
               break;
         }
         if(this.plans.length > 0)
         {
            if(!this.chosenPlan)
            {
               if(HOLD_CHOICE && !RELEASE_CHOICE)
               {
                  return false;
               }
               _loc3_ = caster;
               this.chooseBestPlan();
               if(this.chosenPlan)
               {
                  if(_loc3_)
                  {
                     _loc3_.aiChoseAbilityLastTurn = true;
                  }
                  this._elapsedThinkMs += getTimer() - param1;
                  return true;
               }
            }
         }
         return false;
      }
      
      private function considerAbilities(param1:int) : Boolean
      {
         var _loc2_:IAbilityDefLevels = caster.def.actives;
         var _loc3_:int = !!_loc2_ ? _loc2_.numAbilities : 0;
         if(this.actsIndex >= _loc3_)
         {
            return false;
         }
         if(!caster.tile.getWalkableFor(caster))
         {
            return false;
         }
         if(!this.considering_ability_root)
         {
            this.considering_ability_root = this.considerAbilityRoot(this.actsIndex);
         }
         var _loc4_:IAbilityDefLevel = caster._def.actives.getAbilityDefLevel(this.actsIndex);
         var _loc5_:int = _loc4_.level;
         if(this.considerAbilityRootPlans(param1,_loc5_))
         {
            return true;
         }
         this.considering_ability_root = null;
         ++this.actsIndex;
         this.plans.splice(0,this.plans.length);
         this._elapsedThinkMs += getTimer() - param1;
         return true;
      }
      
      private function tickAi() : void
      {
         if(battleFsm.turn.suspended || ss.skipped)
         {
            return;
         }
         if(Boolean(this.chosenPlan) || !caster)
         {
            return;
         }
         var _loc1_:int = getTimer();
         if(this.checkGateAi())
         {
            return;
         }
         if(attx.checkAttractorAi(this.plans,this.stars))
         {
            if(this.plans.length)
            {
               if(!this.chosenPlan)
               {
                  this.chooseBestPlan();
                  return;
               }
            }
         }
         if(!AiGlobalConfig.UNWILLING)
         {
            if(this.considerAbilities(_loc1_))
            {
               return;
            }
         }
         caster.aiChoseAbilityLastTurn = false;
         if(caster.visible)
         {
            if(this.considerAttacks(_loc1_))
            {
               return;
            }
         }
         if(HOLD_CHOICE && !RELEASE_CHOICE)
         {
            return;
         }
         if(!this.chosenPlan)
         {
            this.chooseBestPlan();
            this._elapsedThinkMs += getTimer() - _loc1_;
         }
      }
      
      private function considerAttacks(param1:int) : Boolean
      {
         if(atkStrRoot)
         {
            if(this.strIndex < enemies.length)
            {
               this.strIndex = findPlans(atkStrRoot,enemies,this.plans,this.strIndex,this.maxStars + 1);
               this._elapsedThinkMs += getTimer() - param1;
               return true;
            }
         }
         if(atkArmRoot)
         {
            if(this.brkIndex < enemies.length)
            {
               this.brkIndex = findPlans(atkArmRoot,enemies,this.plans,this.brkIndex,this.maxStars + 1);
               this._elapsedThinkMs += getTimer() - param1;
               return true;
            }
         }
         return false;
      }
      
      private function chooseBestPlan() : void
      {
         var _loc2_:AiPlan = null;
         var _loc3_:IBattleMove = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         this.timer.removeEventListener(TimerEvent.TIMER,this.timerHandler);
         this.timer.stop();
         this.plans.sort(AiPlan.compare);
         this.chosenPlan = this.plans.length > 0 ? this.plans[0] : null;
         if(!this.chosenPlan)
         {
            if(AiGlobalConfig.DEBUG)
            {
               ss.logger.i(" AI ","DEBUG_AI Fallback null plan...");
            }
            this.chosenPlan = this.makeNullPlan();
         }
         var _loc1_:IBattleMove = battleFsm.turn.move;
         if(this.chosenPlan)
         {
            ss.logger.i(" AI ","Chose Plan " + this.chosenPlan.planId + " " + this.chosenPlan.mv + " " + this.chosenPlan.abldef);
            if(AiGlobalConfig.DEBUG)
            {
               ss.logger.i(" AI ","DEBUG_AI CHOSE PLAN    " + this.chosenPlan + " from " + this.plans.length);
            }
            for each(_loc2_ in this.plans)
            {
               if(_loc2_ != this.chosenPlan)
               {
                  if(_loc2_.weight > this.chosenPlan.weight)
                  {
                     _loc2_ = null;
                  }
               }
            }
            if(_loc1_.numSteps > 1)
            {
               ss.logger.i(" AI ","Need to reset populated ai move! " + _loc1_);
               _loc1_.reset(_loc1_.first);
            }
            _loc3_ = this.chosenPlan.mv;
            if(_loc3_)
            {
               _loc4_ = 1;
               while(_loc4_ < _loc3_.numSteps)
               {
                  _loc1_.addStep(_loc3_.getStep(_loc4_));
                  _loc4_++;
               }
            }
         }
         _averageThinkElapsedMs += this._elapsedThinkMs;
         ++_averageThinkCount;
         _averageThinkMs = _averageThinkElapsedMs / _averageThinkCount;
         if(AiGlobalConfig.DEBUG)
         {
            _loc5_ = getTimer() - this._startWallMs;
            _loc6_ = ss.logger.frameNumber - this._startFrame;
            _globalWallTotalMs += _loc5_;
            _globalFramesTotal += _loc6_;
            _averageWallMs = _globalWallTotalMs / _averageThinkCount;
            _averageFrames = _globalFramesTotal / _averageThinkCount;
            ss.logger.i(" AI ","Think ElapsedTime [" + caster + "] \t" + this._elapsedThinkMs + " \t avg \t" + _averageThinkMs);
            ss.logger.i(" AI ","Think WallClock   [" + caster + "] \t" + _loc5_ + " \t avg \t" + _averageWallMs);
            ss.logger.i(" AI ","Think Frames      [" + caster + "] \t" + _loc6_ + " \t avg \t" + _averageFrames);
         }
         if(_loc1_.numSteps > 1)
         {
            _loc1_.setCommitted("AiModuleDredge.performMove");
            battleFsm.turn.entity.mobility.executeMove(_loc1_);
         }
         else
         {
            this.performAction();
         }
      }
      
      private function makeNullPlan() : AiPlan
      {
         var _loc1_:Vector.<Tile> = null;
         var _loc2_:Vector.<IBattleEntity> = null;
         return new AiPlan(this,null,null,_loc2_,_loc1_);
      }
      
      private function _performAction_precheck() : Boolean
      {
         return this._performAction_precheck_0() && this._performAction_precheck_1() && this._performAction_precheck_2();
      }
      
      private function _performAction_precheck_0() : Boolean
      {
         var _loc1_:IBattleTurn = !!battleFsm ? battleFsm.turn : null;
         if(!_loc1_ || _loc1_.suspended || battleFsm.cleanedup || !battleFsm.board || !ss || ss.skipped || ss.cleanedup || !ss.cmdSeq)
         {
            return false;
         }
         return true;
      }
      
      private function _performAction_precheck_1() : Boolean
      {
         if(!caster || !caster.alive || !this.chosenPlan)
         {
            if(ss)
            {
               ss.skip(true,"AiModuleDredge._performAction_precheck",false);
            }
            return false;
         }
         return true;
      }
      
      private function _performAction_precheck_2() : Boolean
      {
         if(!battleFsm.board.abilityManager)
         {
            return false;
         }
         return true;
      }
      
      private function _performAction_ctorAbility() : BattleAbility
      {
         var _loc4_:AiPlanTarget = null;
         var _loc5_:Tile = null;
         var _loc1_:IBattleTurn = battleFsm.turn;
         var _loc2_:IBattleAbilityManager = battleFsm.board.abilityManager;
         if(!this.chosenPlan.abldef)
         {
            if(Boolean(_loc1_.move) && _loc1_.move.numSteps > 1)
            {
               this.chosenPlan.abldef = _loc2_.getFactory.fetch("abl_end") as BattleAbilityDef;
            }
            else
            {
               this.chosenPlan.abldef = _loc2_.getFactory.fetch("abl_rest") as BattleAbilityDef;
            }
            this.chosenPlan.targets = null;
         }
         var _loc3_:BattleAbility = new BattleAbility(caster,this.chosenPlan.abldef,_loc2_);
         if(this.chosenPlan.targets)
         {
            for each(_loc4_ in this.chosenPlan.targets)
            {
               _loc3_.targetSet.addTarget(_loc4_.target);
            }
         }
         else if(this.chosenPlan.tiles)
         {
            for each(_loc5_ in this.chosenPlan.tiles)
            {
               _loc3_.targetSet.addTile(_loc5_);
            }
         }
         return _loc3_;
      }
      
      override public function performAction() : Boolean
      {
         if(!this._performAction_precheck())
         {
            return false;
         }
         var _loc1_:BattleAbility = this._performAction_ctorAbility();
         if(this.considered_ability_facing)
         {
            caster.facing = this.considered_ability_facing;
         }
         this._performedAction = true;
         ss.cmdSeq.addCmd(new BattleTurnCmdAction(ss,0,true,_loc1_,true));
         return true;
      }
   }
}
