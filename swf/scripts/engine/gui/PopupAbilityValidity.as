package engine.gui
{
   import engine.ability.def.AbilityDef;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.effect.def.AbilityReason;
   import engine.battle.ability.model.BattleAbilityValidation;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.logging.ILogger;
   import engine.stat.def.StatType;
   
   public class PopupAbilityValidity
   {
      
      private static var ar:AbilityReason = new AbilityReason();
       
      
      public var bad:BattleAbilityDef;
      
      public var valid:Boolean;
      
      public var minLevel:int;
      
      public var maxLevel:int;
      
      public var reasons:Array;
      
      public var leastReason:String;
      
      public function PopupAbilityValidity()
      {
         this.reasons = [];
         super();
      }
      
      public static function isAbilityInvalid(param1:AbilityDef, param2:IBattleEntity, param3:ILogger, param4:PopupAbilityValidity) : PopupAbilityValidity
      {
         var _loc5_:int = 0;
         var _loc6_:AbilityDef = null;
         var _loc7_:String = null;
         if(!param4)
         {
            param4 = new PopupAbilityValidity();
         }
         param4.reset(param1 as BattleAbilityDef);
         if(param1)
         {
            _loc5_ = param1.level;
            while(_loc5_ > 0)
            {
               _loc6_ = param1.getAbilityDefForLevel(_loc5_) as AbilityDef;
               _loc7_ = isAbilityLevelInvalid(param2,_loc6_,param3);
               param4.setInvalidityReason(_loc5_,_loc7_);
               _loc5_--;
            }
         }
         param4.setValidityComplete();
         return param4;
      }
      
      private static function isAbilityLevelInvalid(param1:IBattleEntity, param2:AbilityDef, param3:ILogger) : String
      {
         var _loc8_:BattleAbilityValidation = null;
         var _loc4_:BattleAbilityDef = param2 as BattleAbilityDef;
         if(!param1 || !_loc4_)
         {
            return "error";
         }
         var _loc5_:Boolean = true;
         var _loc6_:Boolean = true;
         if(ar)
         {
            ar.clear();
         }
         var _loc7_:StatType = _loc4_.checkCosts(param1.stats);
         if(_loc7_)
         {
            return "insufficient_" + _loc7_.name.toLowerCase();
         }
         if(_loc4_.casterEffectTagReqs)
         {
            if(!_loc4_.casterEffectTagReqs.checkTags(param1.effects,param3,ar))
            {
               if(ar)
               {
                  return "caster_" + ar;
               }
               return "caster_tag";
            }
         }
         if(_loc4_.conditions)
         {
            if(_loc4_.conditions.caster)
            {
               if(!_loc4_.conditions.caster.checkAdjacentAlliesMin(param1))
               {
                  return "not_adjacent_ally";
               }
            }
            _loc8_ = _loc4_.conditions.checkExecutionConditions(null,_loc4_,param1,null,param3,true);
            if(Boolean(_loc8_) && !_loc8_.ok)
            {
               return _loc8_.name.toLowerCase();
            }
         }
         return null;
      }
      
      public function toString() : String
      {
         return !!this.reasons ? this.reasons.join(",") : "no-reason?";
      }
      
      public function reset(param1:BattleAbilityDef) : void
      {
         var _loc2_:int = 0;
         this.bad = param1;
         this.valid = false;
         this.minLevel = !!param1 ? param1.level + 1 : 1000000;
         this.maxLevel = 0;
         this.leastReason = null;
         if(param1)
         {
            _loc2_ = int(this.reasons.length);
            while(_loc2_ <= param1.level + 1)
            {
               this.reasons.push(null);
               _loc2_++;
            }
         }
         _loc2_ = 0;
         while(_loc2_ < this.reasons.length)
         {
            this.reasons[_loc2_] = null;
            _loc2_++;
         }
      }
      
      public function setInvalidityReason(param1:int, param2:String) : void
      {
         this.reasons[param1] = param2;
         if(!param2)
         {
            this.maxLevel = Math.max(this.maxLevel,param1);
            this.minLevel = Math.min(this.minLevel,param1);
         }
         else
         {
            this.leastReason = param2;
         }
      }
      
      public function setValidityComplete() : void
      {
         this.valid = this.minLevel <= this.maxLevel;
      }
   }
}
