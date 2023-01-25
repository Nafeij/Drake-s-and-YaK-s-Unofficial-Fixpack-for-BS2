package engine.saga.action
{
   import engine.ability.IAbilityDefLevel;
   import engine.ability.def.AbilityDefLevel;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.entity.def.IEntityDef;
   import engine.saga.Saga;
   
   public class Action_UnitAbilityAdd extends Action
   {
       
      
      public function Action_UnitAbilityAdd(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:IEntityDef = saga.getCastMember(def.id);
         if(!_loc1_)
         {
            throw new ArgumentError("invalid entity not in cast: " + def.id);
         }
         var _loc2_:BattleAbilityDef = saga.abilityFactory.fetch(def.param,false) as BattleAbilityDef;
         if(!_loc2_)
         {
            throw new ArgumentError("invalid ability [" + def.param + "]");
         }
         var _loc3_:int = def.varvalue;
         var _loc4_:IAbilityDefLevel = !!_loc1_.actives ? _loc1_.actives.getAbilityDefLevelById(_loc2_.id) : null;
         var _loc5_:int = int(def.anchor);
         if(!_loc5_)
         {
            if(_loc4_)
            {
               _loc5_ = _loc4_.rankAcquired;
            }
            else
            {
               _loc5_ = int(_loc1_.stats.rank);
            }
         }
         if(!_loc3_)
         {
            _loc3_ = 1 + (_loc1_.stats.rank - _loc5_) / 2;
         }
         _loc3_ = Math.max(1,_loc3_);
         _loc3_ = Math.min(_loc2_.maxLevel,_loc3_);
         var _loc6_:AbilityDefLevel = new AbilityDefLevel(_loc2_,_loc3_,_loc5_);
         _loc1_.addActiveAbilityDefLevel(_loc6_,logger);
         if(logger.isDebugEnabled)
         {
            logger.debug("Action_UnitAbilityAdd [" + _loc1_.id + "] actives=[" + _loc1_.actives.getDebugString() + "]");
         }
         end();
      }
   }
}
