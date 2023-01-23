package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.model.EffectTag;
   import engine.battle.ability.effect.model.IEffect;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.BattleAbilityManager;
   import engine.battle.ability.model.BattleAbilityRetargetInfo;
   import engine.battle.ability.model.IBattleAbility;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.logging.ILogger;
   import engine.entity.def.IEntityDef;
   import engine.math.Rng;
   import engine.saga.ISaga;
   import engine.saga.SagaInstance;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   import engine.stat.model.Stats;
   import engine.talent.BonusedTalents;
   import engine.talent.TalentRankDef;
   import engine.talent.Talents;
   import engine.tile.Tile;
   import flash.errors.IllegalOperationError;
   
   public class Op implements IOp
   {
      
      public static var talentResults:Vector.<TalentRankDef> = new Vector.<TalentRankDef>();
       
      
      public var ability:BattleAbility;
      
      public var effect:Effect;
      
      public var result:EffectResult;
      
      public var def:EffectDefOp;
      
      public var logger:ILogger;
      
      public var target:IBattleEntity;
      
      public var caster:IBattleEntity;
      
      public var tile:Tile;
      
      public var board:IBattleBoard;
      
      public var manager:BattleAbilityManager;
      
      public var consumedStats:Vector.<Stat>;
      
      private var _consumingStats:Boolean;
      
      public function Op(param1:EffectDefOp, param2:Effect)
      {
         super();
         this.def = param1;
         this.effect = param2;
         this.ability = param2.ability as BattleAbility;
         this.manager = this.ability.manager as BattleAbilityManager;
         this.logger = this.manager.getLogger;
         this.target = param2.target;
         this.caster = param2.ability.caster;
         this.tile = param2.tile;
         if(!this.tile)
         {
            if(this.target)
            {
               this.tile = this.target.tile;
            }
            else if(this.caster)
            {
               this.tile = this.caster.tile;
            }
         }
         this.board = this.caster.board;
      }
      
      protected function queueConsumeStat(param1:Stat) : int
      {
         if(this._consumingStats)
         {
            throw new IllegalOperationError("Cannot queue consume stat while consuming them");
         }
         if(param1)
         {
            if(!this.consumedStats)
            {
               this.consumedStats = new Vector.<Stat>();
            }
            this.consumedStats.push(param1);
            return param1.value;
         }
         return 0;
      }
      
      public function performQueuedConsumeStats() : void
      {
         var _loc1_:Stat = null;
         if(this.consumedStats)
         {
            for each(_loc1_ in this.consumedStats)
            {
               _loc1_.doConsume();
            }
            this.consumedStats = null;
         }
      }
      
      public function toString() : String
      {
         return "Op [" + this.ability + " " + this.def + " " + this.result + " " + this.effect + "]";
      }
      
      public function execute() : EffectResult
      {
         return EffectResult.OK;
      }
      
      public function apply() : void
      {
      }
      
      public function remove() : void
      {
      }
      
      public function targetStartTurn() : Boolean
      {
         return false;
      }
      
      public function casterStartTurn() : Boolean
      {
         return false;
      }
      
      public function turnChanged() : Boolean
      {
         return false;
      }
      
      public function notifySagaAbilityTrigger(param1:String) : void
      {
         var _loc2_:ISaga = this.caster.board.getSaga();
         if(_loc2_)
         {
            _loc2_.triggerBattleAbilityCompleted(this.caster.def.id,param1,this.caster.isPlayer);
         }
      }
      
      public function onAbilityExecutingOnTarget(param1:IBattleAbility) : BattleAbilityRetargetInfo
      {
         return null;
      }
      
      protected function requireStat(param1:IBattleEntity, param2:StatType) : Stat
      {
         var _loc3_:Stat = param1.stats.getStat(param2);
         if(!_loc3_)
         {
            throw new ArgumentError("Op.requireStat " + param1.id + " does not have stat " + param2);
         }
         return _loc3_;
      }
      
      private function getCasterSpecificResists(param1:IBattleEntity, param2:IBattleEntity, param3:int, param4:StatType, param5:Rng) : int
      {
         var _loc8_:String = null;
         var _loc6_:int = 0;
         var _loc7_:Stats = param2.stats;
         if(param4 == StatType.STRENGTH)
         {
            _loc8_ = param1.def.entityClass.race;
            if(_loc8_ == "dredge")
            {
               _loc6_ += _loc7_.getValue(StatType.RESIST_STRENGTH_DREDGE);
            }
         }
         return _loc6_;
      }
      
      public function processResistance(param1:IBattleEntity, param2:int, param3:StatType, param4:Rng) : int
      {
         var _loc11_:TalentRankDef = null;
         if(param2 < 0)
         {
            return param2;
         }
         var _loc5_:Stats = param1.stats;
         var _loc6_:StatType = Stats.getResistanceType(param3);
         var _loc7_:int = this.getCasterSpecificResists(this.caster,param1,param2,param3,param4);
         if(!_loc6_ && !_loc7_)
         {
            return param2;
         }
         var _loc8_:int = Math.min(param2,_loc5_.getValue(_loc6_) + _loc7_);
         if(_loc8_ > 0)
         {
            switch(param3)
            {
               case StatType.ARMOR:
                  this.effect.addTag(EffectTag.RESISTING_ARMOR);
                  break;
               case StatType.STRENGTH:
                  this.effect.addTag(EffectTag.RESISTING_STRENGTH);
                  break;
               case StatType.WILLPOWER:
                  this.effect.addTag(EffectTag.RESISTING_WILLPOWER);
            }
            param2 -= _loc8_;
         }
         if(this.manager.faking || this.ability.fake)
         {
            return param2;
         }
         var _loc9_:IEntityDef = param1.def;
         var _loc10_:BonusedTalents = param1.bonusedTalents;
         param1.bonusedTalents.generateTalentResults(_loc6_,param4,talentResults);
         for each(_loc11_ in talentResults)
         {
            if(param2 <= 0)
            {
               break;
            }
            if(_loc11_.value)
            {
               param2 = Math.max(0,param2 - _loc11_.value);
               this.effect.addEntityEffectTalent(param1,_loc11_);
            }
         }
         return param2;
      }
      
      protected function rollDiceForStat(param1:IBattleEntity, param2:StatType, param3:Rng, param4:EffectTag) : Boolean
      {
         var _loc6_:int = 0;
         var _loc10_:TalentRankDef = null;
         var _loc11_:int = 0;
         var _loc5_:int = int(param1.stats.getValue(param2));
         var _loc7_:TalentRankDef = null;
         var _loc8_:Talents = param1.def.talents;
         if(_loc8_)
         {
            param1.bonusedTalents.generateTalentResults(param2,null,talentResults);
            for each(_loc10_ in talentResults)
            {
               _loc6_ += _loc10_.percent;
               _loc7_ = _loc10_;
            }
         }
         var _loc9_:int = _loc5_ + _loc6_;
         if(_loc9_)
         {
            _loc11_ = param3.nextMinMax(0,100);
            if(_loc11_ <= _loc9_)
            {
               if(param4)
               {
                  this.effect.addTag(param4);
               }
               if(_loc11_ > _loc5_)
               {
                  this.effect.addEntityEffectTalent(param1,_loc10_);
               }
               return true;
            }
         }
         return false;
      }
      
      protected function handleDivertArmor(param1:int, param2:Effect, param3:IBattleEntity) : int
      {
         if(param2.ability.fake || this.manager.isFaking)
         {
            return param1;
         }
         if(param1 < 0)
         {
            return param1;
         }
         var _loc4_:Rng = this.manager.rng;
         if(this.rollDiceForStat(param3,StatType.DIVERT_CHANCE,_loc4_,EffectTag.DIVERTING))
         {
            return 0;
         }
         return param1;
      }
      
      public function handleTransferDamage(param1:IEffect, param2:int) : void
      {
      }
      
      public function get fake() : Boolean
      {
         return this.ability.fake || this.manager.faking;
      }
      
      final protected function checkTrackAttack() : void
      {
         if(!this.fake)
         {
            if(Boolean(this.caster.effects) && Boolean(this.caster.effects.hasTag(EffectTag.TRACKING)))
            {
               this.effect.addTag(EffectTag.TRACK_ATTACK);
            }
         }
      }
      
      final protected function checkSagaTriggers() : void
      {
         var _loc1_:ISaga = SagaInstance.instance;
         if(this.effect.hasTag(EffectTag.KILL_STOP))
         {
            _loc1_ && _loc1_.triggerBattleKillStop(this.target);
         }
         if(this.effect.hasTag(EffectTag.IMMORTAL_STOPPED))
         {
            this.target.handleImmortalStopped();
            _loc1_ && _loc1_.triggerBattleImmortalStopped(this.target);
         }
         if(this.effect.hasTag(EffectTag.END_TURN_IF_NO_ENEMIES_REMAIN))
         {
            this.caster.handleEndTurnIfNoEnemiesRemain();
         }
      }
   }
}
