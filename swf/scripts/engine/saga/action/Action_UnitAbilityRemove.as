package engine.saga.action
{
   import engine.ability.IAbilityDefLevel;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityDefLevels;
   import engine.entity.def.IEntityDef;
   import engine.saga.Saga;
   
   public class Action_UnitAbilityRemove extends Action
   {
       
      
      public function Action_UnitAbilityRemove(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc4_:IAbilityDefLevel = null;
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
         var _loc3_:BattleAbilityDefLevels = _loc1_.actives as BattleAbilityDefLevels;
         if(_loc3_)
         {
            _loc4_ = _loc3_.getAbilityDefLevelById(_loc2_.id);
            _loc3_.removeAbility(def.param);
         }
         end();
      }
   }
}
