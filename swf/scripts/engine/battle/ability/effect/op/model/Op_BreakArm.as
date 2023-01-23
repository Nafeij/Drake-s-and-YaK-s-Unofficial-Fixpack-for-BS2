package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.BattleAbilityDefFactory;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.model.EffectTag;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.effect.op.def.OpDef_DamageArm;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   
   public class Op_BreakArm extends Op
   {
       
      
      public var amount:int;
      
      public var stat_baseDamage:Stat;
      
      public var stat_target:Stat;
      
      public function Op_BreakArm(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
         this.stat_baseDamage = requireStat(caster,StatType.ARMOR_BREAK);
         this.stat_target = target.stats.getStat(StatType.ARMOR,false);
      }
      
      override public function execute() : EffectResult
      {
         var _loc3_:BattleAbilityDefFactory = null;
         var _loc4_:int = 0;
         if(!target.attackable || !target.alive)
         {
            return EffectResult.FAIL;
         }
         if(!this.stat_target || !this.stat_baseDamage)
         {
            return EffectResult.FAIL;
         }
         var _loc1_:OpDef_DamageArm = def as OpDef_DamageArm;
         this.amount = _loc1_.damage + queueConsumeStat(this.stat_baseDamage);
         if(_loc1_.damage_param)
         {
            _loc3_ = manager.factory;
            _loc4_ = _loc3_.getAbilityDefParam(_loc1_.damage_param,this.amount);
            this.amount += _loc4_;
         }
         if(_loc1_.statType_casterBonus)
         {
            this.amount += caster.stats.getValue(_loc1_.statType_casterBonus);
         }
         this.amount = Math.min(this.amount,this.stat_target.value);
         if(!manager.faking)
         {
            if(logger.isDebugEnabled)
            {
               logger.debug("Op_BreakArm.execute level=" + effect.ability.def.level + " amount=" + this.amount + " " + effect.ability.caster + " -> " + effect.target);
            }
         }
         this.amount = processResistance(target,this.amount,StatType.ARMOR,manager.rng);
         var _loc2_:int = int(target.stats.getValue(StatType.DAMAGE_REDUCTION));
         if(_loc2_ > 0 && _loc2_ <= 100)
         {
            this.amount -= Math.floor(this.amount * _loc2_ / 100);
         }
         this.amount = handleDivertArmor(this.amount,effect,target);
         if(this.amount != 0)
         {
            effect.addTag(EffectTag.DAMAGED_ARM);
            checkTrackAttack();
            if(this.amount >= this.stat_target.base)
            {
               if(Boolean(target.effects) && Boolean(target.effects.hasTag(EffectTag.SHIELD_SMASH_IMMUNE)))
               {
                  effect.addTag(EffectTag.ARMOR_ZEROING);
               }
            }
         }
         effect.annotateStatChange(StatType.ARMOR,-this.amount);
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
         if(result != EffectResult.OK)
         {
            return;
         }
         this.amount = Op_DamageStr.checkDamageAbsorbtion(target,effect,this.amount);
         target.record.addArmorDamageTaken(this.amount);
         caster.record.addArmorDamageDone(this.amount);
         this.stat_target.base = Math.max(0,this.stat_target.base - this.amount);
         performQueuedConsumeStats();
      }
   }
}
