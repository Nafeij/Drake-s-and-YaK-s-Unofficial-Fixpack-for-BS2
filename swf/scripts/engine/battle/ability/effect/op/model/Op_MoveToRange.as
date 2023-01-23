package engine.battle.ability.effect.op.model
{
   import engine.ability.IAbilityDefLevels;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityResponseTargetType;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.BattleAbilityValidation;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.fsm.BattleMove;
   import engine.battle.fsm.BattleMoveEvent;
   import engine.battle.fsm.IBattleTurn;
   import engine.core.BoxBoolean;
   import engine.core.util.Enum;
   import engine.def.BooleanVars;
   import engine.stat.def.StatType;
   import engine.stat.model.Stats;
   
   public class Op_MoveToRange extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_MoveToRange",
         "properties":{
            "ability":{
               "type":"string",
               "optional":true
            },
            "interrupt":{
               "type":"string",
               "optional":true
            },
            "useStandardAttack":{
               "type":"boolean",
               "optional":true
            },
            "useAbilityForRange":{
               "type":"boolean",
               "optional":true
            },
            "useMaxStars":{
               "type":"number",
               "optional":true
            },
            "responseTarget":{
               "type":"string",
               "optional":true
            },
            "responseCaster":{
               "type":"string",
               "optional":true
            },
            "centerCamera":{
               "type":"boolean",
               "optional":true
            },
            "requireCompleteMove":{
               "type":"boolean",
               "optional":true
            },
            "confuse":{
               "type":"boolean",
               "optional":true
            }
         }
      };
      
      private static var currentOps:Vector.<Op_MoveToRange> = new Vector.<Op_MoveToRange>();
      
      private static var gtg:BoxBoolean = new BoxBoolean();
       
      
      private var _move:BattleMove;
      
      private var interrupted:Boolean;
      
      private var finished:Boolean;
      
      private var responseTarget:BattleAbilityResponseTargetType;
      
      private var responseCaster:BattleAbilityResponseTargetType;
      
      private var mvCaster:IBattleEntity;
      
      private var mvTarget:IBattleEntity;
      
      private var centerCamera:Boolean;
      
      private var useAbilityForRange:Boolean;
      
      private var useStandardAttack:Boolean;
      
      private var abldef_ability:BattleAbilityDef;
      
      private var abldef_interrupt:BattleAbilityDef;
      
      private var useMaxStars:int;
      
      private var requireCompleteMove:Boolean = false;
      
      private var confuse:Boolean;
      
      private var confused:Boolean;
      
      private var retried:Boolean;
      
      public function Op_MoveToRange(param1:EffectDefOp, param2:Effect)
      {
         this.responseTarget = BattleAbilityResponseTargetType.TARGET;
         this.responseCaster = BattleAbilityResponseTargetType.CASTER;
         super(param1,param2);
         this.requireCompleteMove = param1.params.requireCompleteMove;
         this.centerCamera = BooleanVars.parse(param1.params.centerCamera,this.centerCamera);
         if(param1.params.responseTarget)
         {
            this.responseTarget = Enum.parse(BattleAbilityResponseTargetType,param1.params.responseTarget) as BattleAbilityResponseTargetType;
         }
         if(param1.params.responseCaster)
         {
            this.responseCaster = Enum.parse(BattleAbilityResponseTargetType,param1.params.responseCaster) as BattleAbilityResponseTargetType;
         }
         if(param1.params.ability)
         {
            this.abldef_ability = manager.factory.fetch(param1.params.ability,false) as BattleAbilityDef;
            if(!this.abldef_ability)
            {
               logger.error("invalid abldef_ability [" + param1.params.ability + "] for " + this);
            }
         }
         if(param1.params.interrupt)
         {
            this.abldef_interrupt = manager.factory.fetch(param1.params.interrupt,false) as BattleAbilityDef;
            if(!this.abldef_interrupt)
            {
               logger.error("invalid abldef_interrupt [" + param1.params.interrupt + "] for " + this);
            }
         }
         this.useAbilityForRange = param1.params.useAbilityForRange;
         this.useStandardAttack = param1.params.useStandardAttack;
         this.useMaxStars = param1.params.useMaxStars;
         this.mvCaster = this.getTargetByRule(this.responseCaster);
         this.mvTarget = this.getTargetByRule(this.responseTarget);
         this.confuse = param1.params.confuse;
      }
      
      public function get move() : BattleMove
      {
         return this._move;
      }
      
      public function set move(param1:BattleMove) : void
      {
         if(this._move == param1)
         {
            return;
         }
         if(this._move)
         {
            if(!this._move.cleanedup && !this._move.executing)
            {
               this._move.cleanup();
            }
         }
         this._move = param1;
      }
      
      private function getTargetByRule(param1:BattleAbilityResponseTargetType) : IBattleEntity
      {
         switch(param1)
         {
            case BattleAbilityResponseTargetType.CASTER:
            case BattleAbilityResponseTargetType.SELF:
               return caster;
            case BattleAbilityResponseTargetType.RANDOM:
               return null;
            default:
               return target;
         }
      }
      
      private function _selectRandomTarget_legacy(param1:BattleAbilityDef) : Boolean
      {
         var _loc3_:IBattleEntity = null;
         var _loc2_:int = 0;
         for each(_loc3_ in caster.board.entities)
         {
            if(!(!_loc3_.alive || !this.mvCaster.awareOf(_loc3_)))
            {
               if(param1.checkTargetStatRanges(_loc3_.stats))
               {
                  if(BattleAbilityValidation.validate(param1,this.mvCaster,null,_loc3_,null,false,false,true,false).ok)
                  {
                     this.mvTarget = _loc3_;
                     gtg.value = false;
                     this.move = BattleMove.computeMoveToRange(param1,this.mvCaster,this.mvTarget,tile,logger,_loc2_,gtg,null,false,false);
                     if(gtg.value)
                     {
                        logger.info("Op_MoveToRange random choose GTG " + this.mvTarget.id);
                        return true;
                     }
                  }
               }
            }
         }
         logger.info(!!("Op_MoveToRange random choose NOT GTG " + this.mvTarget) ? this.mvTarget.id : "(NO MOVE TARGET AVAILABLE)");
         return false;
      }
      
      private function _selectRandomTarget_bestStandard(param1:BattleAbilityDef) : AttackConsideration
      {
         var _loc5_:IBattleEntity = null;
         var _loc6_:Boolean = false;
         var _loc7_:Boolean = false;
         var _loc8_:Boolean = false;
         var _loc9_:Boolean = false;
         var _loc10_:BattleMove = null;
         var _loc2_:int = 0;
         var _loc3_:AttackConsideration = new AttackConsideration(this.mvCaster,param1);
         var _loc4_:AttackConsideration = new AttackConsideration(this.mvCaster,param1);
         for each(_loc5_ in board.entities)
         {
            if(!(!_loc5_.alive || !this.mvCaster.awareOf(_loc5_) || !this.mvCaster.canAttack(_loc5_)))
            {
               if(!(this.confused && !_loc5_.mobile))
               {
                  if(param1.checkTargetStatRanges(_loc5_.stats))
                  {
                     _loc8_ = true;
                     if(BattleAbilityValidation.validate(param1,this.mvCaster,null,_loc5_,null,_loc6_,_loc7_,_loc8_,_loc9_).ok)
                     {
                        gtg.value = false;
                        _loc10_ = BattleMove.computeMoveToRange(param1,this.mvCaster,_loc5_,tile,logger,_loc2_,gtg,null,false,false);
                        if(gtg.value)
                        {
                           _loc3_.compare(_loc5_,_loc10_);
                        }
                        else if(this.confused)
                        {
                           _loc4_.compare(_loc5_,_loc10_);
                        }
                     }
                  }
               }
            }
         }
         return _loc3_.ok ? _loc3_ : _loc4_;
      }
      
      override public function execute() : EffectResult
      {
         var _loc1_:BattleAbilityDef = this.mvCaster.def.attacks.getAbilityDef(0) as BattleAbilityDef;
         if(_loc1_ == null)
         {
            return EffectResult.FAIL;
         }
         return EffectResult.OK;
      }
      
      private function determinePath_legacy() : void
      {
         var _loc1_:int = 0;
         var _loc2_:BattleAbilityDef = this.mvCaster.def.attacks.getAbilityDef(0) as BattleAbilityDef;
         if(_loc2_ == null)
         {
            return;
         }
         if(!this.mvTarget)
         {
            this.interrupted = !this._selectRandomTarget_legacy(_loc2_);
         }
         else
         {
            gtg.value = false;
            this.move = BattleMove.computeMoveToRange(_loc2_,this.mvCaster,this.mvTarget,tile,effect.def.logger,_loc1_,gtg,null,false,false);
            if(!gtg.value)
            {
               this.interrupted = true;
            }
         }
      }
      
      private function determinePath_bestStandard() : void
      {
         var _loc6_:BattleAbilityDef = null;
         var _loc7_:AttackConsideration = null;
         var _loc8_:BattleAbilityDef = null;
         var _loc9_:BattleAbility = null;
         var _loc10_:Stats = null;
         var _loc1_:int = 0;
         var _loc2_:IAbilityDefLevels = this.mvCaster.def.attacks;
         var _loc3_:Array = [];
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_.numAbilities)
         {
            _loc6_ = _loc2_.getAbilityDef(_loc4_) as BattleAbilityDef;
            if(_loc6_)
            {
               _loc7_ = this._selectRandomTarget_bestStandard(_loc6_);
               if(_loc7_.ok)
               {
                  _loc3_.push(_loc7_);
               }
            }
            _loc4_++;
         }
         if(!_loc3_.length)
         {
            if(this.confused)
            {
               _loc8_ = new BattleAbilityDef(null,null);
               _loc8_.init({
                  "tag":"SPECIAL_NOCOST",
                  "targetRule":"NONE",
                  "rangeType":"NONE",
                  "id":"_moveToRange.confused",
                  "targetRotationRule":"NONE",
                  "rotationRule":"NONE",
                  "effects":[{
                     "name":"_moveToRange.confuse.response",
                     "ops":[{
                        "id":"RUNAWAY",
                        "params":{"distance":10},
                        "name":"_moveToRange.confuse.runaway"
                     }],
                     "phantasms":[{
                        "applyTime":0,
                        "endTime":1000,
                        "results":["OK"]
                     }]
                  }]
               },logger);
               if(!_loc8_ || !_loc8_.checkCasterExecutionConditions(target,logger,true))
               {
                  return;
               }
               _loc9_ = new BattleAbility(target,_loc8_,manager);
               _loc9_.execute(null);
            }
            return;
         }
         _loc3_.sortOn("desirability");
         _loc7_ = _loc3_.pop();
         logger.i("OMTR","most desirable: " + _loc7_);
         var _loc5_:int = this.useMaxStars;
         if(_loc5_)
         {
            _loc10_ = this.mvCaster.stats;
            _loc5_ = Math.min(_loc5_,_loc10_.getValue(StatType.WILLPOWER));
            _loc5_ = Math.min(_loc5_,_loc10_.getValue(StatType.EXERTION));
            _loc5_ = Math.min(_loc5_,_loc7_.maxStars);
         }
         this.mvTarget = _loc7_.mvTarget;
         this.move = _loc7_.move;
         this.abldef_ability = _loc7_.abldef;
         if(_loc5_)
         {
            this.abldef_ability = this.abldef_ability.getAbilityDefForLevel(_loc5_ + 1) as BattleAbilityDef;
            logger.i("OMTR","up-starring to " + this.abldef_ability);
         }
         for each(_loc7_ in _loc3_)
         {
            _loc7_.cleanup();
         }
      }
      
      override public function apply() : void
      {
         if(ability.fake || manager.faking)
         {
            return;
         }
         logger.info("Op_MoveToRange apply " + this);
         if(!target.alive)
         {
            logger.info("Op_MoveToRange apply " + this + " target !ALIVE, SKIPPING");
            this.interrupted = true;
            this.finishMove();
            return;
         }
         if(this.confuse)
         {
            if(caster.team != target.team)
            {
               this.confused = true;
               target.setTeamOverride(caster.team);
            }
         }
         currentOps.push(this);
         effect.blockComplete();
         if(currentOps.length > 1)
         {
            logger.info("Op_MoveToRange apply DEFERRED " + this);
            return;
         }
         this.performMovement();
      }
      
      private function performMovement() : void
      {
         var _loc1_:Boolean = false;
         logger.info("Op_MoveToRange performMovement " + this);
         if(currentOps.length == 0 || currentOps[0] != this)
         {
            effect.unblockComplete();
            logger.error("No ops to move:" + this);
            return;
         }
         if(currentOps[0] != this)
         {
            effect.unblockComplete();
            logger.error("Wrong ops to move:" + this + " expected " + currentOps[0]);
            return;
         }
         if(this.useStandardAttack)
         {
            this.determinePath_bestStandard();
         }
         else
         {
            this.determinePath_legacy();
         }
         if(this.move)
         {
            _loc1_ = !this.requireCompleteMove && (currentOps.length == 1 || this.retried);
            if(!this.interrupted || _loc1_)
            {
               if(this.mvCaster)
               {
                  this.mvCaster.forceCameraCenter = this.centerCamera;
               }
               this.addListeners();
               this.move.setCommitted("Op_MoveToRange");
               this.mvCaster.mobility.executeMove(this.move);
               return;
            }
         }
         if(!this.retried)
         {
            if(currentOps.length > 1)
            {
               logger.info("Op_MoveToRange performMovement RETRYING LATER " + this);
               currentOps.shift();
               currentOps.push(this);
               this.retried = true;
               this.interrupted = false;
               if(this.move)
               {
                  this.move.cleanup();
                  this.move = null;
               }
               logger.info("Op_MoveToRange.performMovement ROLLING NEXT");
               currentOps[0].performMovement();
               return;
            }
         }
         if(this.mvCaster)
         {
            this.mvCaster.forceCameraCenter = this.centerCamera;
         }
         this.finishMove();
      }
      
      override public function remove() : void
      {
         if(this.confused)
         {
            this.confused = false;
            target.setTeamOverride(null);
         }
         if(this.mvCaster)
         {
            this.mvCaster.forceCameraCenter = false;
         }
         this.removeListeners();
         if(this.move)
         {
            this.move.cleanup();
            this.move = null;
         }
      }
      
      private function addListeners() : void
      {
         if(this.move)
         {
            this.move.addEventListener(BattleMoveEvent.EXECUTED,this.moveExecutedHandler);
            this.move.addEventListener(BattleMoveEvent.INTERRUPTED,this.moveInterruptedHandler);
         }
      }
      
      private function removeListeners() : void
      {
         if(this.move)
         {
            this.move.removeEventListener(BattleMoveEvent.EXECUTED,this.moveExecutedHandler);
            this.move.removeEventListener(BattleMoveEvent.INTERRUPTED,this.moveInterruptedHandler);
         }
      }
      
      private function finishMove() : void
      {
         var _loc1_:IBattleTurn = null;
         if(this.finished)
         {
            return;
         }
         logger.info("Op_MoveToRange.finishMove interrupted=" + this.interrupted + " move=" + this.move + " " + this);
         this.finished = true;
         if(!this.interrupted)
         {
            this.execAbility(this.abldef_ability);
         }
         else
         {
            this.execAbility(this.abldef_interrupt);
         }
         if(this.move)
         {
            _loc1_ = this.mvCaster.board.fsm.turn;
            if(_loc1_)
            {
               if(_loc1_.entity == this.mvCaster)
               {
                  if(!_loc1_.move.committed)
                  {
                     _loc1_.move.reset(this.mvCaster.tile);
                     _loc1_.committed = true;
                  }
               }
            }
            this.removeListeners();
            this.move = null;
         }
         currentOps.shift();
         effect.unblockComplete();
         if(currentOps.length)
         {
            logger.info("Op_MoveToRange.finishMove ROLLING NEXT");
            currentOps[0].performMovement();
         }
      }
      
      private function execAbility(param1:BattleAbilityDef) : void
      {
         if(!param1)
         {
            return;
         }
         var _loc2_:BattleAbility = new BattleAbility(this.mvCaster,param1,manager);
         _loc2_.targetSet.setTarget(this.mvTarget);
         _loc2_.targetSet.setTile(tile);
         effect.ability.addChildAbility(_loc2_);
      }
      
      private function moveExecutedHandler(param1:BattleMoveEvent) : void
      {
         effect.def.logger.debug("Op_MoveToRange moveExecutedHandler");
         this.finishMove();
      }
      
      private function moveInterruptedHandler(param1:BattleMoveEvent) : void
      {
         effect.def.logger.debug("Op_MoveToRange moveInterruptedHandler");
         this.interrupted = true;
         this.finishMove();
      }
   }
}

import engine.battle.ability.def.BattleAbilityDef;
import engine.battle.ability.def.BattleAbilityTag;
import engine.battle.board.model.IBattleEntity;
import engine.battle.fsm.BattleMove;
import engine.core.logging.ILogger;

class AttackConsideration
{
    
   
   public var abldef:BattleAbilityDef;
   
   public var mvTarget:IBattleEntity;
   
   public var mvCaster:IBattleEntity;
   
   private var _move:BattleMove;
   
   public var ok:Boolean;
   
   public var isArm:Boolean;
   
   public var isStr:Boolean;
   
   public var underkill:int;
   
   public var desirability:int = -1;
   
   public var maxStars:int;
   
   public var logger:ILogger;
   
   public function AttackConsideration(param1:IBattleEntity, param2:BattleAbilityDef)
   {
      super();
      this.mvCaster = param1;
      this.abldef = param2;
      this.isArm = param2.tag == BattleAbilityTag.ATTACK_ARM;
      this.isStr = param2.tag == BattleAbilityTag.ATTACK_STR;
      this.logger = param1.logger;
   }
   
   public function toString() : String
   {
      return " " + this.abldef + " vs. " + this.mvTarget + " move=" + this.move + " d=" + this.desirability + " mxs=" + this.maxStars;
   }
   
   public function cleanup() : void
   {
      this.move = null;
   }
   
   public function get move() : BattleMove
   {
      return this._move;
   }
   
   public function set move(param1:BattleMove) : void
   {
      if(this._move == param1)
      {
         return;
      }
      if(this._move)
      {
         this._move.cleanup();
      }
      this._move = param1;
   }
   
   public function compare(param1:IBattleEntity, param2:BattleMove) : void
   {
      var _loc3_:ConsiderDesirability = new ConsiderDesirability(this.mvCaster);
      this.logger.i("OMTR","Comparing " + this.abldef + " vs. " + param1 + " move " + param2);
      if(this.isArm)
      {
         _loc3_.compute_arm(param1,param2);
      }
      else if(this.isStr)
      {
         _loc3_.compute_str(param1,param2);
      }
      if(_loc3_.desirability > this.desirability)
      {
         this.desirability = _loc3_.desirability;
         this.maxStars = _loc3_.maxStars;
         this.mvTarget = param1;
         this.move = param2;
         this.ok = true;
         this.logger.i("OMTR","    ... selected desirability " + this.desirability);
      }
   }
}

import engine.battle.ability.BattleCalculationHelper;
import engine.battle.board.model.IBattleEntity;
import engine.battle.fsm.BattleMove;
import engine.stat.def.StatType;

class ConsiderDesirability
{
    
   
   public var mvCaster:IBattleEntity;
   
   public var desirability:int;
   
   public var maxStars:int;
   
   public function ConsiderDesirability(param1:IBattleEntity)
   {
      super();
      this.mvCaster = param1;
   }
   
   public function compute_arm(param1:IBattleEntity, param2:BattleMove) : void
   {
      var _loc3_:int = BattleCalculationHelper.armorDamage(this.mvCaster,param1,0);
      this.maxStars = 0;
      this.desirability = _loc3_;
      var _loc4_:int = int(param1.stats.getValue(StatType.ARMOR));
      if(_loc3_ > _loc4_)
      {
         this.desirability -= _loc3_ - _loc4_;
      }
      else
      {
         this.maxStars = _loc4_ - _loc3_;
      }
   }
   
   public function compute_str(param1:IBattleEntity, param2:BattleMove) : void
   {
      var _loc6_:int = 0;
      var _loc3_:int = BattleCalculationHelper.strengthDamage(this.mvCaster,param1,0);
      var _loc4_:int = BattleCalculationHelper.strengthMiss(this.mvCaster,param1);
      if(!param2 || param2.numSteps == 1)
      {
         _loc6_ = BattleCalculationHelper.calculatePunctureBonus(this.mvCaster,param1);
         _loc3_ += _loc6_;
      }
      this.maxStars = 0;
      this.desirability = _loc3_;
      this.desirability /= 1 + _loc4_;
      var _loc5_:int = int(param1.stats.getValue(StatType.STRENGTH));
      if(_loc3_ >= _loc5_)
      {
         this.desirability /= 2;
      }
      else
      {
         this.maxStars = _loc5_ - _loc3_;
      }
   }
}
