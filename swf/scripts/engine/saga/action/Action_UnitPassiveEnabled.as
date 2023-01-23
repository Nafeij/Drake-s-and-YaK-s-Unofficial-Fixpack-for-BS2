package engine.saga.action
{
   import engine.ability.IAbilityDefLevel;
   import engine.entity.def.IEntityDef;
   import engine.saga.Saga;
   
   public class Action_UnitPassiveEnabled extends Action
   {
       
      
      public function Action_UnitPassiveEnabled(param1:ActionDef, param2:Saga)
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
         var _loc2_:IAbilityDefLevel = !!_loc1_.passives ? _loc1_.passives.getAbilityDefLevelById(def.param) : null;
         if(_loc2_)
         {
            _loc2_.level = def.varvalue;
         }
         else
         {
            saga.logger.error("No such passive [" + def.param + "] on unit [" + _loc1_.id + "]");
         }
         end();
      }
   }
}
