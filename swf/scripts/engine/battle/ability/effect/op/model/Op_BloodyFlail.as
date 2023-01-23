package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.model.EffectTag;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.entity.model.BattleEntity;
   import engine.core.BoxInt;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   import engine.stat.model.Stats;
   import engine.tile.ITileResident;
   import engine.tile.Tile;
   
   public class Op_BloodyFlail extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_BloodyFlail",
         "properties":{
            "strHitWeight":{"type":"number"},
            "armHitWeight":{"type":"number"},
            "missHitWeight":{"type":"number"}
         }
      };
       
      
      public var amount:int = 0;
      
      public var stat:Stat = null;
      
      public function Op_BloodyFlail(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
      }
      
      override public function execute() : EffectResult
      {
         var _loc8_:int = 0;
         var _loc9_:Stats = null;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc1_:int = int(def.params.strHitWeight);
         var _loc2_:int = int(def.params.armHitWeight);
         var _loc3_:int = int(def.params.missHitWeight);
         var _loc4_:int = _loc1_ + _loc2_ + _loc3_;
         var _loc5_:Number = manager.rng.nextNumber() * _loc4_;
         var _loc6_:* = target.stats.getValue(StatType.ARMOR) > 0;
         if(!_loc6_)
         {
            logger.info("Op_BloodyFlail ARMOR is not possible, doing STRENGTH");
         }
         var _loc7_:int = int(target.stats.getValue(StatType.DAMAGE_REDUCTION));
         if(!_loc6_ || _loc5_ <= _loc1_)
         {
            manager.logger.debug("doing str hit");
            this.stat = requireStat(target,StatType.STRENGTH);
            _loc8_ = 1 + this.computeDamageBonus();
            this.amount = _loc8_;
            _loc9_ = target.stats;
            this.amount = processResistance(target,this.amount,StatType.STRENGTH,manager.rng);
            if(_loc7_ > 0 && _loc7_ <= 100)
            {
               this.amount -= Math.floor(this.amount * _loc7_ / 100);
            }
            if(Boolean(effect.target.effects.hasTag(EffectTag.GHOSTED)) || Boolean(effect.target.effects.hasTag(EffectTag.GHOST_IN_PROGRESS)))
            {
               this.amount = 0;
            }
            if(this.amount > 0)
            {
               effect.annotateStatChange(StatType.STRENGTH,-this.amount);
               effect.addTag(EffectTag.DAMAGED_STR);
               _loc10_ = int(target.stats.getValue(StatType.STRENGTH));
               this.amount = Op_DamageStr.checkKillStop(target,effect,StatType.STRENGTH,this.amount,true);
               if(this.amount >= _loc10_)
               {
                  if(!effect.hasTag(EffectTag.KILL_STOP) && !effect.hasTag(EffectTag.IMMORTAL_STOPPED))
                  {
                     effect.addTag(EffectTag.KILLING);
                  }
               }
            }
            return EffectResult.OK;
         }
         if(_loc5_ <= _loc1_ + _loc2_)
         {
            manager.logger.debug("attempting arm hit");
            this.stat = requireStat(target,StatType.ARMOR);
            if(this.stat.base > 0)
            {
               _loc11_ = 1 + this.computeDamageBonus();
               this.amount = _loc11_;
               this.amount = Math.min(this.amount,this.stat.base);
               if(this.amount > 0)
               {
                  this.amount = handleDivertArmor(this.amount,effect,target);
               }
               this.amount = processResistance(target,this.amount,StatType.ARMOR,manager.rng);
               if(_loc7_ > 0 && _loc7_ <= 100)
               {
                  this.amount -= Math.floor(this.amount * _loc7_ / 100);
               }
               if(this.amount != 0)
               {
                  effect.annotateStatChange(StatType.ARMOR,-this.amount);
                  effect.addTag(EffectTag.DAMAGED_ARM);
               }
               return EffectResult.OK;
            }
            manager.logger.debug("arm hit falling through to miss");
         }
         return EffectResult.MISS;
      }
      
      override public function apply() : void
      {
         var _loc1_:BattleAbilityDef = null;
         var _loc2_:BattleAbility = null;
         var _loc3_:BoxInt = null;
         var _loc4_:BoxInt = null;
         var _loc5_:Boolean = false;
         var _loc6_:* = false;
         var _loc7_:Stat = null;
         var _loc8_:Stat = null;
         if(result == EffectResult.OK && this.stat != null)
         {
            _loc1_ = null;
            _loc2_ = null;
            _loc5_ = Boolean(target.effects) && Boolean(target.effects.hasTag(EffectTag.HAS_DAMAGE_RECOURSE_TARGET));
            if(this.stat.type == StatType.STRENGTH)
            {
               if(Boolean(effect.target.effects.hasTag(EffectTag.GHOSTED)) || Boolean(effect.target.effects.hasTag(EffectTag.GHOST_IN_PROGRESS)))
               {
                  this.amount = 0;
               }
               if(!effect.hasTag(EffectTag.TRANSFER_DAMAGE_IGNORE))
               {
                  _loc6_ = target.stats.getValue(StatType.TRANSFER_DAMAGE_COUNT) > 0;
               }
               _loc3_ = new BoxInt(0);
               _loc4_ = new BoxInt(0);
               this.amount = Op_DamageStr.computeArmorAbsorb(target,effect,this.amount,_loc3_);
               this.amount = Op_DamageStr.computeWillpowerAbsorb(target,effect,this.amount,_loc4_);
               this.amount = Op_DamageStr.checkKillStop(target,effect,this.stat.type,this.amount,false);
               this.amount = Op_DamageStr.checkDamageAbsorbtion(target,effect,this.amount);
               target.record.addStrengthDamageTaken(this.amount);
               caster.record.addStrengthDamageDone(this.amount);
               _loc1_ = manager.factory.fetchBattleAbilityDef("abl_bloodyflail_final_str_success");
               _loc2_ = new BattleAbility(caster,_loc1_,manager);
               _loc2_.targetSet.setTarget(target);
               _loc2_.execute(null);
            }
            else if(this.stat.type == StatType.ARMOR)
            {
               this.amount = Op_DamageStr.checkDamageAbsorbtion(target,effect,this.amount);
               target.record.addArmorDamageTaken(this.amount);
               caster.record.addArmorDamageDone(this.amount);
               _loc1_ = manager.factory.fetchBattleAbilityDef("abl_bloodyflail_final_arm_success");
               _loc2_ = new BattleAbility(caster,_loc1_,manager);
               _loc2_.targetSet.setTarget(target);
               _loc2_.execute(null);
            }
            if(_loc5_)
            {
               this.amount = Op_DamageRecourse.processDamageRecourse(target,this.amount,this.stat.type,effect);
            }
            if(!_loc6_)
            {
               this.stat.base -= this.amount;
            }
            else if(_loc6_)
            {
               Op_DamageStr.handleNotifyTransferDamage(effect,target,this.amount);
            }
            if(Boolean(_loc3_) && Boolean(_loc3_.value))
            {
               target.record.addArmorDamageTaken(_loc3_.value);
               caster.record.addArmorDamageDone(_loc3_.value);
               _loc7_ = target.stats.getStat(StatType.ARMOR,false);
               if(_loc7_)
               {
                  _loc7_.base -= _loc3_.value;
               }
            }
            if(Boolean(_loc4_) && Boolean(_loc4_.value))
            {
               target.record.addWillpowerDamageTaken(_loc4_.value);
               caster.record.addWillpowerDamageDone(_loc4_.value);
               _loc8_ = target.stats.getStat(StatType.WILLPOWER,false);
               if(_loc8_)
               {
                  _loc8_.base -= _loc4_.value;
               }
            }
         }
         checkSagaTriggers();
      }
      
      protected function isFriendlyUnit(param1:int, param2:int) : Boolean
      {
         var _loc4_:ITileResident = null;
         var _loc5_:BattleEntity = null;
         var _loc3_:Tile = target.board.tiles.getTile(param1,param2);
         if(_loc3_ != null)
         {
            _loc4_ = _loc3_.findResident(null);
            if(_loc4_ != null && _loc4_ is BattleEntity)
            {
               _loc5_ = _loc4_ as BattleEntity;
               if(_loc5_.alive == true && _loc5_.team == caster.team)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      protected function computeDamageBonus() : int
      {
         var _loc2_:BattleEntity = null;
         var _loc1_:int = 0;
         _loc2_ = caster as BattleEntity;
         var _loc3_:int = _loc2_.pos.x;
         var _loc4_:int = _loc2_.pos.y;
         if(caster.rect.width == 1)
         {
            if(this.isFriendlyUnit(_loc3_,_loc4_ - 1))
            {
               _loc1_++;
            }
            if(this.isFriendlyUnit(_loc3_ + 1,_loc4_))
            {
               _loc1_++;
            }
            if(this.isFriendlyUnit(_loc3_,_loc4_ + 1))
            {
               _loc1_++;
            }
            if(this.isFriendlyUnit(_loc3_ - 1,_loc4_))
            {
               _loc1_++;
            }
         }
         else if(caster.rect.width == 2)
         {
            if(this.isFriendlyUnit(_loc3_,_loc4_ + 2))
            {
               _loc1_++;
            }
            if(this.isFriendlyUnit(_loc3_ + 1,_loc4_ + 2))
            {
               _loc1_++;
            }
            if(this.isFriendlyUnit(_loc3_ + 2,_loc4_ + 1))
            {
               _loc1_++;
            }
            if(this.isFriendlyUnit(_loc3_ + 2,_loc4_))
            {
               _loc1_++;
            }
            if(this.isFriendlyUnit(_loc3_,_loc4_ - 1))
            {
               _loc1_++;
            }
            if(this.isFriendlyUnit(_loc3_ + 1,_loc4_ - 1))
            {
               _loc1_++;
            }
            if(this.isFriendlyUnit(_loc3_ - 1,_loc4_ + 1))
            {
               _loc1_++;
            }
            if(this.isFriendlyUnit(_loc3_ - 1,_loc4_))
            {
               _loc1_++;
            }
         }
         return _loc1_;
      }
   }
}
