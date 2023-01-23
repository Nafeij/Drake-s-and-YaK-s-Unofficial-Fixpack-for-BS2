package engine.saga.action
{
   import engine.ability.IAbilityDefLevel;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityTag;
   import engine.entity.UnitStatCosts;
   import engine.entity.def.IEntityDef;
   import engine.saga.Saga;
   import engine.stat.def.StatRange;
   import engine.stat.def.StatType;
   import flash.utils.Dictionary;
   
   public class Action_UnitCopyStat extends Action
   {
       
      
      public function Action_UnitCopyStat(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc7_:StatType = null;
         var _loc1_:IEntityDef = saga.getCastMember(def.id);
         if(!_loc1_)
         {
            throw new ArgumentError("invalid entity not in cast: id=" + def.id);
         }
         var _loc2_:IEntityDef = saga.getCastMember(def.speaker);
         if(!_loc2_)
         {
            throw new ArgumentError("invalid entity not in cast: speaker=" + def.speaker);
         }
         if(!def.param)
         {
            throw new ArgumentError("def.param must be * or STAT_NAME");
         }
         var _loc3_:Dictionary = new Dictionary();
         if(Boolean(def.param) && def.param != "*")
         {
            _loc5_ = def.param.split(",");
            for each(_loc6_ in _loc5_)
            {
               _loc3_[_loc6_] = _loc6_;
            }
         }
         var _loc4_:int = 0;
         while(_loc4_ < _loc1_.stats.numStats)
         {
            _loc7_ = _loc1_.stats.getStatByIndex(_loc4_).type;
            if(def.param == "*" || _loc7_.name in _loc3_)
            {
               this.copyStat(_loc1_,_loc2_,_loc7_);
            }
            _loc4_++;
         }
         end();
      }
      
      private function copyStat(param1:IEntityDef, param2:IEntityDef, param3:StatType) : void
      {
         var _loc6_:UnitStatCosts = null;
         var _loc7_:int = 0;
         var _loc8_:IAbilityDefLevel = null;
         var _loc9_:BattleAbilityDef = null;
         var _loc10_:int = 0;
         var _loc4_:int = 0;
         _loc4_ = int(param1.stats.getBase(param3));
         var _loc5_:StatRange = param1.statRanges.getStatRange(param3);
         if(_loc5_)
         {
            _loc4_ = Math.max(_loc5_.min,Math.min(_loc5_.max,_loc4_));
            param2.stats.setBase(param3,_loc4_);
         }
         else
         {
            param2.stats.setBase(param3,_loc4_);
         }
         if(param3 == StatType.RANK)
         {
            _loc6_ = saga.def.unitStatCosts;
            if(param2.actives)
            {
               _loc7_ = 0;
               while(_loc7_ < param2.actives.numAbilities)
               {
                  _loc8_ = param2.actives.getAbilityDefLevel(_loc7_);
                  _loc9_ = _loc8_.def as BattleAbilityDef;
                  if(_loc9_.tag == BattleAbilityTag.SPECIAL)
                  {
                     _loc10_ = _loc6_.getAbilityLevel(_loc4_,_loc8_.rankAcquired);
                     _loc8_.level = _loc10_;
                  }
                  _loc7_++;
               }
            }
         }
      }
   }
}
