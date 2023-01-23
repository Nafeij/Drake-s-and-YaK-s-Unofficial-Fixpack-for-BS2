package engine.saga.action
{
   import engine.ability.IAbilityDef;
   import engine.ability.IAbilityDefLevel;
   import engine.entity.def.IEntityDef;
   import engine.saga.Saga;
   
   public class Action_UnitAbilityEnabled extends Action
   {
       
      
      public function Action_UnitAbilityEnabled(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc3_:IAbilityDefLevel = null;
         var _loc1_:IEntityDef = saga.getCastMember(def.id);
         if(!_loc1_)
         {
            throw new ArgumentError("invalid entity not in cast: " + def.id);
         }
         var _loc2_:IAbilityDef = !!_loc1_.actives ? _loc1_.actives.getAbilityDefById(def.param) : null;
         if(_loc2_)
         {
            _loc3_ = _loc1_.actives.getAbilityDefLevelById(_loc2_.id);
            _loc3_.enabled = def.varvalue != 0;
         }
         else
         {
            saga.logger.error("No such active [" + def.param + "] on unit [" + _loc1_.id + "]");
         }
         end();
      }
   }
}
