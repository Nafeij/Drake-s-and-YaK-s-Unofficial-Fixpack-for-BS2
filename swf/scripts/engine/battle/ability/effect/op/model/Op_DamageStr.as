package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.model.EffectTag;
   import engine.battle.ability.effect.model.IEffect;
   import engine.battle.ability.effect.model.IPersistedEffects;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.BoxInt;
   import engine.def.BooleanVars;
   import engine.expression.Parser;
   import engine.expression.exp.Exp;
   import engine.math.Rng;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   import engine.talent.TalentRankDef;
   
   public class Op_DamageStr extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_DamageStr",
         "properties":{
            "damage":{"type":"number"},
            "perCasterStrength":{"type":"number"},
            "perTargetArmor":{"type":"number"},
            "maxMissChance":{
               "type":"number",
               "minimum":0,
               "maximum":80
            },
            "missChancePer":{
               "type":"number",
               "defaultValue":10
            },
            "damageOnMiss":{"type":"number"},
            "applyEffectTag":{
               "type":"boolean",
               "defaultValue":true,
               "optional":true
            },
            "minDamage":{
               "type":"number",
               "defaultValue":0,
               "optional":true
            },
            "distributeToArmor":{
               "type":"boolean",
               "defaultValue":false,
               "optional":true
            },
            "distributeToWillpower":{
               "type":"boolean",
               "defaultValue":false,
               "optional":true
            },
            "punctureAllowedAlways":{
               "type":"boolean",
               "optional":true
            },
            "underdogAllowedAlways":{
               "type":"boolean",
               "optional":true
            },
            "suppressBonusDamage":{
               "type":"boolean",
               "optional":true
            },
            "attack_expression":{
               "type":"string",
               "optional":true
            },
            "defer_knockback":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      public var amount:int;
      
      public var armor_amount:int;
      
      public var willpowerAmount:int;
      
      private var miss:Number = 0;
      
      private var attackStat:StatType;
      
      private var attackBonusStat:StatType;
      
      private var attackMinStat:StatType;
      
      private var defenseStat:StatType;
      
      private var damageStat:StatType;
      
      private var punctureAllowedAlways:Boolean;
      
      private var underdogAllowedAlways:Boolean;
      
      private var suppressBonusDamage:Boolean;
      
      private var attack_expression:String;
      
      private var exp_attack:Exp;
      
      private var exp_attack_amount:int;
      
      private var defer_knockback:Boolean;
      
      public function Op_DamageStr(param1:EffectDefOp, param2:Effect)
      {
         var _loc3_:Parser = null;
         var _loc4_:EffectSymbols = null;
         super(param1,param2);
         this.attackStat = StatType.STRENGTH;
         this.attackBonusStat = StatType.STRENGTH_ATTACK;
         this.attackMinStat = StatType.MIN_STRENGTH_ATTACK;
         this.defenseStat = StatType.ARMOR;
         this.damageStat = StatType.STRENGTH;
         this.defer_knockback = param1.params.defer_knockback;
         if(param1.params.attack_expression)
         {
            _loc3_ = new Parser(param1.params.attack_expression,logger);
            this.exp_attack = _loc3_.exp;
            if(!this.exp_attack)
            {
               throw new ArgumentError("Failed to parse expression for " + this);
            }
            _loc4_ = new EffectSymbols(param2);
            this.exp_attack_amount = this.exp_attack.evaluate(_loc4_,true);
            this.exp_attack_amount = Math.ceil(this.exp_attack_amount);
            logger.info("damage_expression [" + _loc3_.raw + "] evaluates to [" + this.exp_attack_amount + "]");
         }
      }
      
      public static function computeMarkedForDeathBonus(param1:IBattleEntity, param2:IBattleEntity) : int
      {
         if(!param2 || param2 == param1)
         {
            return 0;
         }
         if(!param2.effects.hasTag(EffectTag.MARKED_FOR_DEATH))
         {
            return 0;
         }
         return param1.stats.getValue(StatType.STRENGTH_BONUS_MARKED_FOR_DEATH,0);
      }
      
      public static function computeDredgeStrengthBonus(param1:IBattleEntity, param2:IBattleEntity, param3:Boolean) : int
      {
         if(!param2 || param2 == param1)
         {
            return 0;
         }
         var _loc4_:String = String(param2.def.entityClass.race);
         if(_loc4_ != "dredge")
         {
            return 0;
         }
         return param1.stats.getValue(StatType.STRENGTH_BONUS_DREDGE,0);
      }
      
      public static function computeUnderdogBonus(param1:IBattleEntity, param2:IBattleEntity, param3:Boolean) : int
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         if(!param2 || param2 == param1)
         {
            return 0;
         }
         var _loc4_:int = int(param1.stats.getValue(StatType.UNDERDOG_BONUS));
         var _loc5_:int = int(param1.stats.getValue(StatType.STRENGTH));
         if(_loc4_ > 0)
         {
            _loc6_ = int(param2.stats.getValue(StatType.STRENGTH));
            _loc7_ = _loc6_ - _loc5_;
            if(_loc7_ > 0)
            {
               return int(_loc7_ / _loc4_);
            }
         }
         return 0;
      }
      
      public static function handleNotifyTransferDamage(param1:IEffect, param2:IBattleEntity, param3:int) : void
      {
         if(param3 <= 0)
         {
            return;
         }
         var _loc4_:int = int(param2.stats.getValue(StatType.TRANSFER_DAMAGE_COUNT));
         if(_loc4_ <= 0)
         {
            return;
         }
         param2.logger.info("Op_DamageStr.handleNotifyTransferDamage: origin=" + param1 + " target=" + param2 + " amount=" + param3 + "  count=" + _loc4_);
         param2.effects.handleTransferDamage(param1,param3);
      }
      
      public static function computeArmorAbsorb(param1:IBattleEntity, param2:Effect, param3:int, param4:BoxInt) : int
      {
         var _loc7_:int = 0;
         var _loc5_:int = int(param1.stats.getValue(StatType.ARMOR));
         _loc5_ -= param4.value;
         var _loc6_:int = int(param1.stats.getValue(StatType.ARMOR_ABSORPTION));
         if(_loc6_ > 0 && param3 > 0 && _loc5_ > 0)
         {
            _loc7_ = Math.min(param3,_loc5_);
            param4.value += _loc7_;
            param3 -= _loc7_;
            _loc5_ -= _loc7_;
            param2.addTag(EffectTag.ABSORBING);
         }
         if(param4.value > 0)
         {
            param2.addTag(EffectTag.DAMAGED_ARM);
            param2.annotateStatChange(StatType.ARMOR,-param4.value);
            if(_loc5_ <= 0)
            {
               if(Boolean(param1.effects) && Boolean(param1.effects.hasTag(EffectTag.SHIELD_SMASH_IMMUNE)))
               {
                  param2.addTag(EffectTag.ARMOR_ZEROING);
               }
            }
         }
         return param3;
      }
      
      public static function computeWillpowerAbsorb(param1:IBattleEntity, param2:Effect, param3:int, param4:BoxInt) : int
      {
         var _loc7_:int = 0;
         var _loc5_:int = int(param1.stats.getValue(StatType.WILLPOWER));
         _loc5_ -= param4.value;
         var _loc6_:int = int(param1.stats.getValue(StatType.WILLPOWER_ABSORPTION));
         if(_loc6_ > 0 && param3 > 0 && _loc5_ > 0)
         {
            _loc7_ = Math.min(param3,_loc5_);
            param4.value += _loc7_;
            param3 -= _loc7_;
            _loc5_ -= _loc7_;
            param2.addTag(EffectTag.ABSORBING);
         }
         if(param4.value > 0)
         {
            param2.addTag(EffectTag.DAMAGED_WIL);
            param2.annotateStatChange(StatType.WILLPOWER,-param4.value);
         }
         return param3;
      }
      
      public static function checkDamageAbsorbtion(param1:IBattleEntity, param2:Effect, param3:int) : int
      {
         if(param2.ability.fake)
         {
            return param3;
         }
         var _loc4_:Stat = param1.stats.getStat(StatType.DAMAGE_ABSORPTION_SHIELD,false);
         if(Boolean(_loc4_) && _loc4_.value > 0)
         {
            if(_loc4_.value < param3)
            {
               param3 = _loc4_.value;
            }
            _loc4_.base -= param3;
            param3 = 0;
         }
         return param3;
      }
      
      public static function checkKillStop(param1:IBattleEntity, param2:Effect, param3:StatType, param4:int, param5:Boolean) : int
      {
         var _loc8_:TalentRankDef = null;
         var _loc9_:Rng = null;
         var _loc10_:TalentRankDef = null;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         if(param2.ability.fake)
         {
            return param4;
         }
         var _loc6_:int = int(param1.stats.getValue(StatType.KILL_STOP));
         var _loc7_:int = param4;
         if(param5 && Boolean(param1.def.talents))
         {
            _loc9_ = param2.manager.rng;
            param1.bonusedTalents.generateTalentResults(StatType.KILL_STOP,_loc9_,talentResults);
            for each(_loc10_ in talentResults)
            {
               if(_loc10_.value > _loc6_)
               {
                  _loc6_ = _loc10_.value;
                  _loc8_ = _loc10_;
               }
            }
         }
         if(_loc6_ > 0)
         {
            _loc11_ = int(param1.stats.getValue(param3));
            _loc12_ = Math.min(_loc11_ - 1,_loc6_);
            _loc13_ = Math.max(_loc11_ - param4,_loc12_);
            _loc7_ = _loc11_ - _loc13_;
            if(_loc7_ < param4)
            {
               if(_loc7_ < _loc11_)
               {
                  if(_loc8_)
                  {
                     param2.addEntityEffectTalent(param1,_loc8_);
                  }
                  param2.addTag(EffectTag.KILL_STOP);
                  param1.logger.info("Op_DamageStr KILL_STOP engaged vs " + param1 + " cur=" + _loc11_ + " amount=" + param4 + " ks=" + _loc6_ + ", clamping to " + _loc7_);
               }
            }
         }
         _loc7_ = checkImmortalityStat(param1,param2,param3,_loc7_,StatType.TWICEBORN,EffectTag.TWICEBORN_FIRED);
         return checkImmortalityStat(param1,param2,param3,_loc7_,StatType.IMMORTAL,EffectTag.IMMORTAL_STOPPED);
      }
      
      private static function checkImmortalityStat(param1:IBattleEntity, param2:Effect, param3:StatType, param4:int, param5:StatType, param6:EffectTag) : int
      {
         if(param2.ability.fake)
         {
            return param4;
         }
         if(param4 <= 0)
         {
            return param4;
         }
         var _loc7_:int = int(param1.stats.getValue(param5));
         if(_loc7_ <= 0)
         {
            return param4;
         }
         var _loc8_:int = int(param1.stats.getValue(param3));
         var _loc9_:int = Math.max(_loc8_ - param4,_loc7_);
         var _loc10_:int = _loc8_ - _loc9_;
         if(_loc10_ < param4)
         {
            param1.logger.info("Op_DamageStr.checkImmortalityStat target=" + param1 + " cur=" + _loc8_ + " amount=" + param4 + " " + param5.abbrev + "=" + _loc7_ + " effectTag=" + param6 + ", clamping to " + _loc10_);
            if(param6 != null)
            {
               param2.addTag(param6);
            }
         }
         return _loc10_;
      }
      
      override public function execute() : EffectResult
      {
         var _loc1_:* = false;
         var _loc2_:TalentRankDef = null;
         var _loc25_:TalentRankDef = null;
         var _loc26_:int = 0;
         var _loc29_:Boolean = false;
         var _loc30_:int = 0;
         var _loc31_:int = 0;
         var _loc32_:int = 0;
         var _loc33_:int = 0;
         var _loc34_:* = false;
         var _loc35_:int = 0;
         var _loc36_:Number = NaN;
         var _loc37_:int = 0;
         var _loc38_:int = 0;
         var _loc39_:Boolean = false;
         var _loc40_:int = 0;
         var _loc41_:BoxInt = null;
         var _loc42_:int = 0;
         var _loc43_:BoxInt = null;
         var _loc44_:Boolean = false;
         var _loc45_:Stat = null;
         var _loc46_:int = 0;
         if(caster.stats.getValue(StatType.ALWAYS_MISS) > 0 || !target.attackable || !target.alive)
         {
            this.miss = 1;
            this.amount = 0;
            effect.addTag(EffectTag.DEFLECT);
            return EffectResult.MISS;
         }
         if(!effect.hasTag(EffectTag.TRANSFER_DAMAGE_IGNORE))
         {
            _loc1_ = target.stats.getValue(StatType.TRANSFER_DAMAGE_COUNT) > 0;
         }
         var _loc3_:int = int(def.params.damage);
         var _loc4_:int = int(def.params.perCasterStrength);
         var _loc5_:int = int(def.params.perTargetArmor);
         var _loc6_:Number = def.params.maxMissChance * 0.01;
         var _loc7_:int = int(def.params.missChancePer);
         var _loc8_:int = int(def.params.damageOnMiss);
         var _loc9_:Boolean = BooleanVars.parse(def.params.applyEffectTag,true);
         var _loc10_:Boolean = BooleanVars.parse(def.params.distributeToArmor,false);
         var _loc11_:Boolean = BooleanVars.parse(def.params.distributeToWillpower,false);
         this.punctureAllowedAlways = def.params.punctureAllowedAlways;
         this.underdogAllowedAlways = def.params.underdogAllowedAlways;
         this.suppressBonusDamage = def.params.suppressBonusDamage;
         var _loc12_:int = 0;
         if(def.params.hasOwnProperty("minDamage"))
         {
            _loc12_ = int(def.params.minDamage);
         }
         var _loc13_:Rng = manager.rng;
         if(!effect.ability.fake)
         {
            if(_loc12_ <= 0 && _loc6_ > 0)
            {
               _loc29_ = rollDiceForStat(target,StatType.DODGE_BONUS,_loc13_,EffectTag.DODGE);
               if(_loc29_)
               {
                  this.amount = 0;
                  return EffectResult.MISS;
               }
            }
         }
         this.amount = 0;
         this.miss = 0;
         var _loc14_:int = 0;
         var _loc15_:Stat = caster.stats.getStat(this.attackBonusStat,false);
         var _loc16_:Stat = caster.stats.getStat(this.attackMinStat,false);
         var _loc17_:Stat = caster.stats.getStat(this.attackStat);
         if(_loc15_)
         {
            _loc14_ += queueConsumeStat(_loc15_);
         }
         _loc14_ += _loc17_.value;
         var _loc18_:Boolean = effect.ability.fake || manager.faking;
         var _loc19_:Boolean = this.punctureAllowedAlways || _loc6_ > 0;
         var _loc20_:int = 0;
         if(_loc19_)
         {
            _loc20_ = Op_DamageStrHelper.computePunctureBonus(caster,target,_loc18_);
         }
         if(!_loc18_)
         {
            if(_loc19_)
            {
               _loc30_ = this.computeTalentPunctureBonus(caster,target,_loc13_);
               _loc14_ += _loc30_;
            }
         }
         _loc14_ += _loc20_;
         if(!_loc18_ && Boolean(_loc20_))
         {
            notifySagaAbilityTrigger("pas_puncture");
         }
         if(_loc16_)
         {
            _loc31_ = queueConsumeStat(_loc16_);
            _loc14_ = Math.max(_loc31_,_loc14_);
         }
         this.amount += _loc4_ * _loc14_;
         this.amount += this.exp_attack_amount;
         var _loc21_:int = this.computeTargetArmor(target);
         var _loc22_:Stat = caster.stats.getStat(StatType.ARMOR_NEGATION,false);
         if(_loc22_)
         {
            _loc32_ = queueConsumeStat(_loc22_);
            if(!_loc18_)
            {
               logger.info("Op_DamageStr ARMOR_NEGATION " + _loc32_ + " of armor " + _loc21_ + ": " + this);
            }
            _loc21_ = Math.max(_loc21_ - _loc32_,0);
         }
         this.amount += _loc5_ * _loc21_;
         var _loc23_:int = int(caster.stats.getValue(StatType.MISS_CHANCE_MINIMUM));
         var _loc24_:int = 0;
         if(caster.def.talents)
         {
            caster.bonusedTalents.generateTalentResults(StatType.HIT_CHANCE_BONUS,null,talentResults);
            for each(_loc2_ in talentResults)
            {
               _loc24_ += _loc2_.percent;
               _loc25_ = _loc2_;
            }
         }
         if(ability.fake)
         {
         }
         if(this.amount <= 0 || _loc23_ > 0)
         {
            _loc33_ = this.amount;
            this.amount = Math.max(this.amount,_loc8_);
            this.miss = caster.stats.getValue(StatType.MISS_CHANCE_OVERRIDE);
            if(this.miss > 0)
            {
               this.miss = Math.max(this.miss,_loc23_);
            }
            _loc34_ = caster.stats.getValue(StatType.NEVER_MISS) <= 0;
            if(this.miss > 0 || _loc34_ || _loc23_ > 0)
            {
               if(this.miss <= 0)
               {
                  this.miss = -_loc33_ * _loc7_;
                  this.miss = Math.max(this.miss,_loc23_);
                  if(_loc24_)
                  {
                     _loc35_ = Math.max(_loc23_,this.miss - _loc24_);
                     _loc24_ = this.miss - _loc35_;
                     if(_loc24_ <= 0)
                     {
                        _loc24_ = 0;
                        _loc25_ = null;
                     }
                     else
                     {
                        this.miss = Math.max(0,this.miss - _loc24_);
                     }
                  }
               }
               else
               {
                  _loc24_ = 0;
                  _loc25_ = null;
               }
               this.miss *= 0.01;
               this.miss = Math.min(_loc6_,this.miss);
               if(!ability.fake)
               {
                  _loc36_ = _loc13_.nextNumber();
                  if(_loc36_ < this.miss)
                  {
                     this.amount = 0;
                     effect.addTag(EffectTag.DEFLECT);
                     return EffectResult.MISS;
                  }
                  if(Boolean(_loc24_) && _loc36_ < this.miss + _loc24_ * 100)
                  {
                     if(_loc25_)
                     {
                        effect.addEntityEffectTalent(target,_loc25_);
                     }
                  }
               }
            }
         }
         this.amount += _loc3_;
         if(this.amount < _loc12_)
         {
            this.amount = _loc12_;
         }
         if(this.underdogAllowedAlways || Boolean(_loc7_) && Boolean(_loc5_))
         {
            _loc26_ = computeUnderdogBonus(caster,target,_loc18_);
            if(_loc26_)
            {
               effect.annotateStatChange(StatType.UNDERDOG_BONUS,_loc26_);
            }
         }
         this.amount += _loc26_;
         if(!this.suppressBonusDamage)
         {
            _loc37_ = computeDredgeStrengthBonus(caster,target,_loc18_);
            _loc38_ = computeMarkedForDeathBonus(caster,target);
            if(_loc37_)
            {
               effect.annotateStatChange(StatType.STRENGTH_BONUS_DREDGE,_loc37_);
            }
            if(_loc38_)
            {
               effect.annotateStatChange(StatType.STRENGTH_BONUS_MARKED_FOR_DEATH,_loc38_);
            }
            this.amount += _loc38_;
            this.amount += _loc37_;
         }
         if(!effect.ability.fake)
         {
            if(this.amount > 0)
            {
               _loc39_ = rollDiceForStat(caster,StatType.CRIT_CHANCE,_loc13_,EffectTag.CRIT);
               if(_loc39_)
               {
                  this.amount *= 2;
               }
            }
         }
         var _loc27_:int = int(target.stats.getValue(StatType.DAMAGE_REDUCTION));
         if(_loc27_ > 0 && _loc27_ <= 100)
         {
            this.amount -= Math.floor(this.amount * _loc27_ / 100);
         }
         if(!_loc18_)
         {
            this.armor_amount = 0;
            _loc40_ = int(target.stats.getValue(StatType.ARMOR));
            if(_loc10_)
            {
               this.amount = Math.max(this.amount,2);
               this.armor_amount = Math.min(_loc40_,int(Math.floor(this.amount / 2)));
               if(this.armor_amount > 0)
               {
                  this.amount -= this.armor_amount;
                  _loc40_ -= this.armor_amount;
               }
            }
            _loc41_ = new BoxInt(this.armor_amount);
            this.amount = computeArmorAbsorb(target,effect,this.amount,_loc41_);
            this.armor_amount = _loc41_.value;
            this.willpowerAmount = 0;
            _loc42_ = int(target.stats.getValue(StatType.WILLPOWER));
            if(_loc11_)
            {
               this.amount = Math.max(this.amount,2);
               this.willpowerAmount = Math.min(_loc42_,int(Math.floor(this.amount / 2)));
               if(this.willpowerAmount > 0)
               {
                  this.amount -= this.willpowerAmount;
                  _loc42_ -= this.willpowerAmount;
               }
            }
            _loc43_ = new BoxInt(this.willpowerAmount);
            this.amount = computeWillpowerAbsorb(target,effect,this.amount,_loc43_);
            this.willpowerAmount = _loc43_.value;
         }
         this.amount = processResistance(target,this.amount,this.damageStat,manager.rng);
         if(_loc9_ == true)
         {
            effect.addTag(EffectTag.DAMAGED_STR);
         }
         var _loc28_:int = int(target.stats.getValue(this.damageStat));
         if(Boolean(effect.target.effects.hasTag(EffectTag.GHOSTED)) || Boolean(effect.target.effects.hasTag(EffectTag.GHOST_IN_PROGRESS)))
         {
            this.amount = 0;
         }
         if(!_loc1_)
         {
            this.amount = checkKillStop(target,effect,this.damageStat,this.amount,true);
         }
         if(this.amount >= _loc28_)
         {
            _loc44_ = true;
            if(effect.hasTag(EffectTag.KILL_STOP) || effect.hasTag(EffectTag.IMMORTAL_STOPPED))
            {
               _loc44_ = false;
            }
            if(_loc1_)
            {
               _loc44_ = false;
            }
            _loc45_ = target.stats.getStat(StatType.DAMAGE_ABSORPTION_SHIELD,false);
            if(Boolean(_loc45_) && _loc45_.value > 0)
            {
               _loc44_ = false;
            }
            _loc46_ = -Op_DamageRecourse.processDamageRecourse(target,-this.amount,StatType.STRENGTH,effect,true);
            if(_loc46_ < _loc28_)
            {
               _loc44_ = false;
            }
            if(_loc44_)
            {
               effect.addTag(EffectTag.KILLING);
            }
         }
         effect.annotateStatChange(StatType.STRENGTH,-this.amount);
         return EffectResult.OK;
      }
      
      public function computeTalentPunctureBonus(param1:IBattleEntity, param2:IBattleEntity, param3:Rng) : int
      {
         var _loc5_:int = 0;
         var _loc6_:TalentRankDef = null;
         var _loc8_:Stat = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         if(!param2 || !param1.def.talents)
         {
            return 0;
         }
         var _loc4_:Vector.<TalentRankDef> = param1.bonusedTalents.getTalentRankDefsByAffectedStat(StatType.PUNCTURE_CHANCE);
         if(!_loc4_ || !_loc4_.length)
         {
            return 0;
         }
         for each(_loc6_ in _loc4_)
         {
            _loc5_ += _loc6_.percent;
         }
         if(_loc5_ <= 0)
         {
            return 0;
         }
         var _loc7_:int = param3.nextMinMax(1,100);
         if(_loc7_ <= _loc5_)
         {
            _loc8_ = param2.stats.getStat(StatType.ARMOR,false);
            if(_loc8_)
            {
               _loc9_ = _loc8_.original - _loc8_.value;
               _loc10_ = _loc9_ / 2;
               if(_loc10_ > 0)
               {
                  param1.effects.addTag(EffectTag.SPECIAL_PUNCTURE_BONUS);
                  effect.addEntityEffectTalent(param1,_loc6_);
                  return _loc10_;
               }
            }
         }
         return 0;
      }
      
      override public function apply() : void
      {
         var _loc2_:* = false;
         var _loc3_:Stat = null;
         var _loc4_:Stat = null;
         checkTrackAttack();
         var _loc1_:Boolean = Boolean(target.effects) && Boolean(target.effects.hasTag(EffectTag.HAS_DAMAGE_RECOURSE_TARGET));
         if(_loc1_ && target.alive && !ability.fake && !manager.faking)
         {
            this.amount = -Op_DamageRecourse.processDamageRecourse(target,-this.amount,StatType.STRENGTH,effect);
            this.armor_amount = -Op_DamageRecourse.processDamageRecourse(target,-this.armor_amount,StatType.STRENGTH,effect);
            this.willpowerAmount = -Op_DamageRecourse.processDamageRecourse(target,-this.willpowerAmount,StatType.STRENGTH,effect);
         }
         if(!effect.hasTag(EffectTag.TRANSFER_DAMAGE_IGNORE))
         {
            _loc2_ = target.stats.getValue(StatType.TRANSFER_DAMAGE_COUNT) > 0;
         }
         if(Boolean(effect.target.effects.hasTag(EffectTag.GHOSTED)) || Boolean(effect.target.effects.hasTag(EffectTag.GHOST_IN_PROGRESS)))
         {
            this.amount = 0;
         }
         if(!_loc2_)
         {
            this.amount = checkKillStop(target,effect,this.damageStat,this.amount,false);
         }
         if(Boolean(this.armor_amount) && !_loc2_)
         {
            target.record.addArmorDamageTaken(this.armor_amount);
            caster.record.addArmorDamageDone(this.armor_amount);
            _loc3_ = target.stats.getStat(StatType.ARMOR,false);
            if(_loc3_)
            {
               _loc3_.base -= this.armor_amount;
            }
         }
         if(Boolean(this.willpowerAmount) && !_loc2_)
         {
            target.record.addWillpowerDamageTaken(this.willpowerAmount);
            caster.record.addWillpowerDamageDone(this.willpowerAmount);
            _loc4_ = target.stats.getStat(StatType.WILLPOWER,false);
            if(_loc4_)
            {
               _loc4_.base -= this.willpowerAmount;
            }
         }
         if(!ability.fake && !manager.faking)
         {
            this.amount = checkDamageAbsorbtion(target,effect,this.amount);
         }
         if(this.amount)
         {
            target.record.addStrengthDamageTaken(this.amount);
            caster.record.addStrengthDamageDone(this.amount);
            if(!_loc2_ || ability.fake || manager.faking)
            {
               target.stats.getStat(this.damageStat).base = target.stats.getStat(this.damageStat).base - this.amount;
            }
         }
         if(ability.fake || manager.faking)
         {
            target.stats.addStat(StatType.FAKE_MISS_CHANCE,this.miss * 100);
         }
         if(!effect.ability.fake)
         {
            this._checkKnockback();
            if(target.alive && _loc2_)
            {
               handleNotifyTransferDamage(effect,target,this.amount);
            }
         }
         performQueuedConsumeStats();
         checkSagaTriggers();
      }
      
      private function _checkKnockback() : void
      {
         var _loc3_:int = 0;
         var _loc4_:BattleAbilityDef = null;
         var _loc5_:BattleAbility = null;
         if(!target.alive)
         {
            return;
         }
         if(effect.hasTag(EffectTag.NO_KNOCKBACK))
         {
            return;
         }
         var _loc1_:IPersistedEffects = target.effects;
         if(Boolean(_loc1_) && Boolean(_loc1_.hasTag(EffectTag.NO_KNOCKBACK)))
         {
            return;
         }
         var _loc2_:int = int(caster.stats.getValue(StatType.KNOCKBACK_STR));
         if(_loc2_)
         {
            if(this.amount >= _loc2_)
            {
               if(this.defer_knockback)
               {
                  logger.info("Op_DamageStr KNOCKBACK_STR deferred " + caster + " -> " + target);
                  _loc3_ = int(target.stats.getBase(StatType.KNOCKBACK_DEFERRED,0));
                  _loc3_ += 3;
                  target.stats.setBase(StatType.KNOCKBACK_DEFERRED,_loc3_);
               }
               else
               {
                  logger.info("Op_DamageStr KNOCKBACK_STR engaged " + caster + " -> " + target);
                  _loc4_ = manager.factory.fetch("abl_knockback") as BattleAbilityDef;
                  _loc5_ = new BattleAbility(caster,_loc4_,manager);
                  _loc5_.targetSet.setTarget(target);
                  effect.ability.addChildAbility(_loc5_);
               }
            }
         }
      }
      
      private function computeTargetArmor(param1:IBattleEntity) : int
      {
         var _loc3_:int = 0;
         var _loc2_:int = int(param1.stats.getValue(StatType.DAMAGE_ABSORPTION_SHIELD,0));
         if(_loc2_ <= 0)
         {
            return int(param1.stats.getValue(this.defenseStat,0));
         }
         return 0;
      }
   }
}
