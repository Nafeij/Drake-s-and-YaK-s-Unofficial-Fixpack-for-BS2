package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.BattleAbilityDefFactory;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.model.EffectTag;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.core.BoxInt;
   import engine.core.util.Enum;
   import engine.def.BooleanVars;
   import engine.expression.Parser;
   import engine.expression.exp.Exp;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   
   public class Op_ChangeStat extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_ChangeStat",
         "properties":{
            "stat":{"type":"string"},
            "amount":{"type":"number"},
            "casterBonus":{
               "type":"string",
               "optional":true
            },
            "casterBonusAddPreMultiply":{
               "type":"number",
               "optional":true
            },
            "casterBonusMultiple":{
               "type":"number",
               "optional":true
            },
            "amount_param":{
               "type":"string",
               "optional":true
            },
            "amount_stat":{
               "type":"string",
               "optional":true
            },
            "amount_stat_factor":{
               "type":"number",
               "optional":true
            },
            "amount_stat_bonus":{
               "type":"string",
               "optional":true
            },
            "amount_expression":{
               "type":"string",
               "optional":true
            },
            "clamp_min":{
               "type":"number",
               "optional":true
            },
            "delta_max":{
               "type":"number",
               "optional":true
            },
            "delta_min":{
               "type":"number",
               "optional":true
            },
            "clamp_original_max":{
               "type":"boolean",
               "optional":true
            },
            "suppressBonusDamage":{
               "type":"boolean",
               "optional":true
            },
            "suppressDamageAbsorption":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      private var type:StatType;
      
      private var stat:Stat;
      
      private var original_max:int;
      
      private var bonus:int = 0;
      
      private var amount:int = 0;
      
      private var delta_min:int = -10000;
      
      private var delta_max:int = 10000;
      
      private var amount_expression:String;
      
      private var exp_amount:Exp;
      
      private var amount_stat_factor:Number = 1;
      
      private var clamp_min:int = -100000;
      
      public var delta:int;
      
      public var casterBonusMultiple:Number = 1;
      
      public var casterBonusAddPreMultiply:int = 0;
      
      public var clamp_original_max:Boolean = true;
      
      private var suppressBonusDamage:Boolean;
      
      private var suppressDamageAbsorption:Boolean;
      
      public function Op_ChangeStat(param1:EffectDefOp, param2:Effect)
      {
         var _loc3_:String = null;
         var _loc4_:Parser = null;
         var _loc5_:EffectSymbols = null;
         var _loc6_:String = null;
         var _loc7_:BattleAbilityDefFactory = null;
         var _loc8_:int = 0;
         var _loc9_:StatType = null;
         var _loc10_:int = 0;
         var _loc11_:StatType = null;
         var _loc12_:Array = null;
         var _loc13_:int = 0;
         var _loc14_:StatType = null;
         var _loc15_:Stat = null;
         var _loc16_:Number = NaN;
         super(param1,param2);
         this.type = Enum.parse(StatType,param1.params.stat) as StatType;
         this.stat = target.stats.getStat(this.type,false);
         if(!this.stat)
         {
            if(this.type == StatType.ARMOR)
            {
               this.type = StatType.STRENGTH;
               this.stat = target.stats.getStat(this.type,false);
            }
         }
         if(!this.stat)
         {
            this.stat = target.stats.addStat(this.type,0);
         }
         if(param1.params.delta_max != undefined)
         {
            this.delta_max = param1.params.delta_max;
         }
         if(param1.params.delta_min != undefined)
         {
            this.delta_min = param1.params.delta_min;
         }
         this.clamp_original_max = BooleanVars.parse(param1.params.clamp_original_max,this.clamp_original_max);
         this.suppressBonusDamage = param1.params.suppressBonusDamage;
         this.suppressDamageAbsorption = param1.params.suppressDamageAbsorption;
         if(param1.params.clamp_min != undefined)
         {
            this.clamp_min = param1.params.clamp_min;
         }
         this.original_max = Math.max(this.stat.base,this.stat.original);
         this.amount = param1.params.amount;
         if(param1.params.amount_expression)
         {
            _loc3_ = String(param1.params.amount_expression);
            _loc4_ = new Parser(_loc3_,logger);
            this.exp_amount = _loc4_.exp;
            if(!this.exp_amount)
            {
               throw new ArgumentError("Failed to parse expression for " + this);
            }
            _loc5_ = new EffectSymbols(param2);
            _loc5_.addSymbol("amount",this.amount);
            this.amount = this.exp_amount.evaluate(_loc5_,true);
            this.amount = Math.ceil(this.amount);
         }
         else
         {
            this.casterBonusMultiple = param1.params.casterBonusMultiple != undefined ? Number(param1.params.casterBonusMultiple) : 1;
            this.casterBonusAddPreMultiply = param1.params.casterBonusAddPreMultiply != undefined ? int(param1.params.casterBonusAddPreMultiply) : 0;
            if(param1.params.amount_param != undefined)
            {
               _loc6_ = String(param1.params.amount_param);
               if(_loc6_)
               {
                  _loc7_ = manager.factory;
                  _loc8_ = _loc7_.getAbilityDefParam(_loc6_,this.amount);
                  this.amount += _loc8_;
               }
            }
            if(param1.params.amount_stat != undefined)
            {
               _loc9_ = Enum.parse(StatType,param1.params.amount_stat) as StatType;
               if(_loc9_)
               {
                  _loc10_ = int(target.stats.getValue(_loc9_));
                  if(param1.params.amount_stat_factor != undefined)
                  {
                     this.amount_stat_factor = param1.params.amount_stat_factor;
                     this.amount += _loc10_ * this.amount_stat_factor;
                  }
               }
            }
            if(param1.params.amount_stat_bonus != undefined)
            {
               _loc11_ = Enum.parse(StatType,param1.params.amount_stat_bonus) as StatType;
               if(_loc11_)
               {
                  this.amount += target.stats.getValue(_loc11_);
               }
            }
            if(param1.params.casterBonus != undefined)
            {
               _loc12_ = param1.params.casterBonus.split(",");
               _loc13_ = 0;
               while(_loc13_ < _loc12_.length)
               {
                  _loc14_ = Enum.parse(StatType,_loc12_[_loc13_]) as StatType;
                  _loc15_ = caster.stats.getStat(_loc14_,false);
                  if(_loc15_ != null)
                  {
                     _loc16_ = Math.ceil(this.casterBonusMultiple * (_loc15_.value + this.casterBonusAddPreMultiply));
                     this.bonus += _loc16_;
                  }
                  _loc13_++;
               }
            }
         }
      }
      
      override public function execute() : EffectResult
      {
         var _loc1_:int = this.amount + this.bonus;
         _loc1_ = Math.max(this.delta_min,_loc1_);
         _loc1_ = Math.min(this.delta_max,_loc1_);
         if(!target.attackable)
         {
            if(_loc1_ < 0)
            {
               return EffectResult.FAIL;
            }
         }
         if(this.stat.type == StatType.ARMOR)
         {
            if(_loc1_ < 0)
            {
               _loc1_ = -handleDivertArmor(-_loc1_,effect,target);
            }
         }
         _loc1_ += this._calculateBonusDamage();
         var _loc2_:int = this.computeNewBase(_loc1_);
         this.delta = _loc2_ - this.stat.base;
         if(this.delta < 0)
         {
            this.delta = -processResistance(target,-this.delta,this.stat.type,manager.rng);
         }
         if(this.delta != 0)
         {
            if(this.stat.type == StatType.ARMOR)
            {
               if(this.delta < 0 && -this.delta >= this.stat.base)
               {
                  if(Boolean(target.effects) && Boolean(target.effects.hasTag(EffectTag.SHIELD_SMASH_IMMUNE)))
                  {
                     effect.addTag(EffectTag.ARMOR_ZEROING);
                  }
               }
            }
            return EffectResult.OK;
         }
         return EffectResult.FAIL;
      }
      
      private function _calculateBonusDamage() : int
      {
         if(this.suppressBonusDamage || this.stat.type != StatType.STRENGTH)
         {
            return 0;
         }
         var _loc1_:int = Op_DamageStr.computeMarkedForDeathBonus(caster,target);
         var _loc2_:int = Op_DamageStr.computeDredgeStrengthBonus(caster,target,fake);
         if(_loc1_)
         {
            effect.annotateStatChange(StatType.STRENGTH_BONUS_MARKED_FOR_DEATH,_loc1_);
         }
         if(_loc2_)
         {
            effect.annotateStatChange(StatType.STRENGTH_BONUS_DREDGE,_loc2_);
         }
         return -1 * (_loc1_ + _loc2_);
      }
      
      private function computeNewBase(param1:int) : int
      {
         var _loc2_:int = 10000;
         if(this.clamp_original_max)
         {
            _loc2_ = Math.min(_loc2_,this.original_max);
         }
         var _loc3_:int = Math.min(_loc2_,this.stat.base + param1);
         if(this.stat.type == StatType.ARMOR)
         {
            _loc3_ = Math.max(0,_loc3_);
         }
         return int(Math.max(this.clamp_min,_loc3_));
      }
      
      override public function apply() : void
      {
         var _loc1_:BoxInt = null;
         var _loc2_:BoxInt = null;
         var _loc6_:* = false;
         var _loc7_:Stat = null;
         var _loc8_:Stat = null;
         if(!this.stat || !this.delta)
         {
            return;
         }
         var _loc3_:int = this.amount + this.bonus + this._calculateBonusDamage();
         _loc3_ = Math.max(this.delta_min,_loc3_);
         _loc3_ = Math.min(this.delta_max,_loc3_);
         var _loc4_:int = this.computeNewBase(_loc3_);
         this.delta = _loc4_ - this.stat.base;
         if(this.delta < 0)
         {
            this.delta = -processResistance(target,-this.delta,this.stat.type,manager.rng);
         }
         var _loc5_:Boolean = Boolean(target.effects) && Boolean(target.effects.hasTag(EffectTag.HAS_DAMAGE_RECOURSE_TARGET));
         if(_loc5_ && target.alive && !ability.fake && !manager.faking)
         {
            this.delta = Op_DamageRecourse.processDamageRecourse(target,this.delta,this.stat.type,effect);
         }
         if(this.stat.type == StatType.STRENGTH)
         {
            if(!effect.hasTag(EffectTag.TRANSFER_DAMAGE_IGNORE))
            {
               _loc6_ = target.stats.getValue(StatType.TRANSFER_DAMAGE_COUNT) > 0;
            }
            if(this.delta < 0)
            {
               if(Boolean(effect.target.effects.hasTag(EffectTag.GHOSTED)) || Boolean(effect.target.effects.hasTag(EffectTag.GHOST_IN_PROGRESS)))
               {
                  this.delta = 0;
               }
               if(!_loc6_)
               {
                  this.delta = -Op_DamageStr.checkKillStop(effect.target,effect,StatType.STRENGTH,-this.delta,true);
               }
               checkTrackAttack();
               effect.addTag(EffectTag.DAMAGED_STR);
               if(this.stat.value + this.delta <= 0)
               {
                  if(!effect.hasTag(EffectTag.KILL_STOP) && !effect.hasTag(EffectTag.IMMORTAL_STOPPED))
                  {
                     effect.addTag(EffectTag.KILLING);
                  }
               }
               if(!this.suppressDamageAbsorption)
               {
                  _loc1_ = new BoxInt(0);
                  _loc2_ = new BoxInt(0);
                  this.delta = -Op_DamageStr.computeArmorAbsorb(target,effect,-this.delta,_loc1_);
                  this.delta = -Op_DamageStr.computeWillpowerAbsorb(target,effect,-this.delta,_loc2_);
               }
               if(Boolean(_loc1_) && Boolean(_loc1_.value))
               {
                  target.record.addArmorDamageTaken(_loc1_.value);
                  caster.record.addArmorDamageDone(_loc1_.value);
                  _loc7_ = target.stats.getStat(StatType.ARMOR,false);
                  if(_loc7_)
                  {
                     _loc7_.base -= _loc1_.value;
                  }
               }
               if(Boolean(_loc2_) && Boolean(_loc2_.value))
               {
                  target.record.addWillpowerDamageTaken(_loc2_.value);
                  caster.record.addWillpowerDamageDone(_loc2_.value);
                  _loc8_ = target.stats.getStat(StatType.WILLPOWER,false);
                  if(_loc8_)
                  {
                     _loc8_.base -= _loc2_.value;
                  }
               }
            }
         }
         _loc4_ = this.computeNewBase(this.delta);
         this.delta = _loc4_ - this.stat.base;
         if(this.stat.type == StatType.ARMOR)
         {
            if(this.delta < 0)
            {
               checkTrackAttack();
               effect.addTag(EffectTag.DAMAGED_ARM);
            }
         }
         if(!_loc6_ || ability.fake || manager.faking)
         {
            this.stat.base = _loc4_;
         }
         effect.annotateStatChange(this.stat.type,this.delta);
         if(this.stat.type == StatType.STRENGTH)
         {
            if(target.alive && _loc6_)
            {
               if(this.delta < 0)
               {
                  Op_DamageStr.handleNotifyTransferDamage(effect,target,-this.delta);
               }
            }
         }
         checkSagaTriggers();
      }
   }
}
