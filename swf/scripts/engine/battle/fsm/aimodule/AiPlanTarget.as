package engine.battle.fsm.aimodule
{
   import engine.battle.ability.BattleCalculationHelper;
   import engine.battle.ability.def.BattleAbilityAiTargetRuleType;
   import engine.battle.ability.def.BattleAbilityTag;
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.effect.model.EffectTag;
   import engine.battle.ability.effect.op.model.Op_DamageStrHelper;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.StatChangeData;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.model.IBattleMove;
   import engine.battle.entity.model.BattleEntity;
   import engine.entity.def.Shitlist;
   import engine.stat.def.StatType;
   import engine.stat.model.Stats;
   
   public class AiPlanTarget
   {
      
      private static var _tmp_statchange:StatChangeData = new StatChangeData();
       
      
      public var target:BattleEntity;
      
      public var statchange_str:int;
      
      public var statchange_str_miss:int;
      
      public var statchange_arm:int;
      
      public var killed:Boolean;
      
      public var maimed:Boolean;
      
      public var plan:AiPlan;
      
      public var weight:Number = 0;
      
      public var killweight:Number = 0;
      
      public var maimweight:Number = 0;
      
      public var sweight_str:Number = 0;
      
      public var sweight_arm:Number = 0;
      
      public var aggro_mod:Number = 1;
      
      public function AiPlanTarget(param1:AiPlan, param2:BattleEntity)
      {
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         super();
         this.target = param2;
         this.plan = param1;
         var _loc3_:AiModuleBase = param1.ai;
         var _loc4_:IBattleAbilityDef = param1.abldef;
         var _loc5_:IBattleMove = param1.mv;
         var _loc6_:IBattleEntity = _loc3_.caster;
         if(_loc4_)
         {
            _loc7_ = _loc4_.level - 1;
            switch(_loc4_.tag)
            {
               case BattleAbilityTag.ATTACK_ARM:
                  this.statchange_arm = BattleCalculationHelper.armorDamage(_loc6_,param2,_loc7_);
                  break;
               case BattleAbilityTag.ATTACK_STR:
                  this.statchange_str_miss = BattleCalculationHelper.strengthMiss(_loc6_,param2);
                  this.statchange_str = BattleCalculationHelper.strengthDamage(_loc6_,param2,_loc7_);
                  if(this.statchange_str_miss <= 0)
                  {
                     if(!_loc5_ || _loc5_.numSteps == 1)
                     {
                        _loc8_ = Op_DamageStrHelper.computePunctureBonus(_loc6_,param2,true);
                        this.statchange_str += _loc8_;
                     }
                  }
                  break;
               default:
                  if(BattleAbility.getStatChange(_loc4_,_loc6_,StatType.STRENGTH,_tmp_statchange,param2,_loc5_))
                  {
                     this.statchange_str = _tmp_statchange.amount;
                     this.statchange_str_miss = _tmp_statchange.missChance;
                     this.statchange_arm = _tmp_statchange.other;
                  }
            }
         }
         this.determineKillMaim();
         this.computeWeight();
      }
      
      public static function ctor(param1:AiPlan, param2:BattleEntity) : AiPlanTarget
      {
         var _loc4_:int = 0;
         if(param1.abldef)
         {
            if(param1.abldef.getAiTargetRule() == BattleAbilityAiTargetRuleType.WILLPOWER_DOMINANCE)
            {
               _loc4_ = AiPlanUtil.computeWillpowerDominanceWeight(param1.ai.caster,param2);
               if(_loc4_ <= 0)
               {
                  return null;
               }
            }
            if(!param1.abldef.checkTargetExecutionConditions(param2,param2.logger,true))
            {
               return null;
            }
         }
         return new AiPlanTarget(param1,param2);
      }
      
      public function toString() : String
      {
         return !!this.target ? this.target.toString() : "notarget";
      }
      
      private function determineKillMaim() : void
      {
         if(!this.target || !this.statchange_str)
         {
            return;
         }
         if(this.statchange_str_miss)
         {
            return;
         }
         var _loc1_:int = 3;
         var _loc2_:int = this.target.stats.getValue(StatType.STRENGTH);
         var _loc3_:int = Math.max(0,_loc2_ - this.statchange_str);
         if(_loc3_ <= 0)
         {
            this.killed = true;
         }
         else if(this.statchange_str >= _loc1_ && _loc3_ <= _loc1_)
         {
            this.maimed = true;
            this.maimweight = AiPlanConsts.WEIGHT_MAIM / _loc3_;
         }
      }
      
      private function computeMeatiness(param1:IBattleEntity) : int
      {
         var _loc2_:Stats = !!param1 ? param1.stats : null;
         if(!_loc2_)
         {
            return 0;
         }
         var _loc3_:int = 0;
         _loc3_ += _loc2_.getValue(StatType.WILLPOWER) / 3;
         _loc3_ += _loc2_.getValue(StatType.STRENGTH);
         _loc3_ += _loc2_.getValue(StatType.ARMOR_BREAK);
         return _loc3_ + _loc2_.getValue(StatType.ARMOR) / 2;
      }
      
      private function computeWeight() : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc1_:Boolean = !this.target.mobile && (!this.target.team || this.target.team == "prop");
         if(_loc1_)
         {
            this.weight = AiPlanConsts.WEIGHT_PROP;
            this.maimweight = 0;
            return;
         }
         if(this.killed)
         {
            this.killweight = AiPlanConsts.WEIGHT_KILL;
            _loc4_ = this.computeMeatiness(this.target);
            this.killweight += _loc4_;
            this.weight += this.killweight;
         }
         this.weight += this.maimweight;
         this.sweight_str = AiPlan.computeStrengthDamageWeight(this.plan.ai,this.statchange_str,this.statchange_str_miss,this.target);
         if(this.target == this.plan.ai.nextEnemy)
         {
            if(this.sweight_str > 0)
            {
               this.sweight_str *= 2;
            }
         }
         this.weight += this.sweight_str;
         this.sweight_arm = this.statchange_arm * AiPlanConsts.WEIGHT_ABL_DAMAGE_ARM;
         this.weight += this.sweight_arm;
         if(Boolean(this.target.effects) && Boolean(this.target.effects.hasTag(EffectTag.SOUL_BOUND)))
         {
            this.weight -= AiPlanConsts.WEIGHT_KILL;
         }
         if(this.plan.abldef)
         {
            if(this.plan.abldef.getAiTargetRule() == BattleAbilityAiTargetRuleType.WILLPOWER_DOMINANCE)
            {
               this.weight += AiPlanUtil.computeWillpowerDominanceWeight(this.plan.ai.caster,this.target);
            }
         }
         var _loc2_:int = this.target.stats.getValue(StatType.AI_AGGRO_MOD);
         if(_loc2_ > 0)
         {
            this.aggro_mod = 1 + _loc2_;
         }
         else if(_loc2_ < 0)
         {
            this.aggro_mod = 1 / (1 - _loc2_);
         }
         this.sweight_str *= this.aggro_mod;
         this.sweight_arm *= this.aggro_mod;
         this.killweight *= this.aggro_mod;
         this.weight *= this.aggro_mod;
         var _loc3_:Shitlist = this.plan.ai.shitlist;
         if(_loc3_)
         {
            _loc5_ = _loc3_.getShitlistWeight(this.target);
            this.weight *= 1 + _loc5_;
         }
      }
   }
}
