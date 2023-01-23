package engine.saga.action
{
   import engine.battle.ability.def.BattleAbilityDefLevels;
   import engine.core.util.Enum;
   import engine.entity.def.IEntityDef;
   import engine.saga.Saga;
   import engine.stat.def.StatType;
   
   public class Action_UnitStat extends Action
   {
       
      
      public function Action_UnitStat(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc6_:BattleAbilityDefLevels = null;
         var _loc1_:String = def.id;
         var _loc2_:String = def.param;
         var _loc3_:int = def.varvalue;
         var _loc4_:StatType = Enum.parse(StatType,_loc2_) as StatType;
         if(!_loc4_.allowNegative && _loc3_ < 0)
         {
            logger.error("Cannot set stat " + _loc4_ + " below zero, clamping: " + this);
            _loc3_ = 0;
         }
         var _loc5_:IEntityDef = saga.getCastMember(_loc1_);
         if(_loc5_)
         {
            _loc5_.stats.setBase(_loc4_,_loc3_);
            if(_loc4_ == StatType.RANK)
            {
               _loc6_ = _loc5_.actives as BattleAbilityDefLevels;
               _loc6_.updateFromRank(_loc5_.stats.rank,saga.def.unitStatCosts);
            }
         }
         end();
      }
   }
}
