package engine.saga.action
{
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IPartyDef;
   import engine.saga.Saga;
   
   public class Action_RosterAdd extends Action
   {
       
      
      public function Action_RosterAdd(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc2_:String = null;
         var _loc3_:Boolean = false;
         var _loc4_:IPartyDef = null;
         if(!saga || !saga.caravan)
         {
            throw new ArgumentError("No caravan active on saga.  Caravan required.");
         }
         var _loc1_:IEntityDef = saga.getCastMember(def.id);
         if(!_loc1_)
         {
            throw new ArgumentError("invalid entity not in cast: " + def.id);
         }
         if(saga.caravan._legend.roster.getEntityDefById(_loc1_.id))
         {
            if(logger.isDebugEnabled)
            {
               logger.debug("entity already in roster: " + _loc1_.id);
            }
         }
         else
         {
            saga.caravan._legend.roster.addEntityDef(_loc1_);
            saga.caravan._legend.computeRosterRowCount();
         }
         if(def.also_party)
         {
            if(!_loc1_.combatant)
            {
               throw new ArgumentError("Non-combatant [" + def.id + "] cannot be added to party");
            }
            _loc2_ = def.param;
            _loc3_ = Boolean(_loc2_) && _loc2_.indexOf("overridePartyLimit") >= 0;
            _loc4_ = saga.caravan._legend.party;
            if(_loc4_.numMembers >= 6)
            {
               if(_loc3_)
               {
                  saga.logger.info("Action_RosterAdd Party is full, but overriding limit: " + this);
               }
               else
               {
                  saga.logger.info("Action_RosterAdd Party is full " + this);
               }
            }
            else if(!_loc4_.hasMemberId(_loc1_.id))
            {
               if(!_loc4_.addMember(_loc1_.id))
               {
                  throw new ArgumentError("Action_RosterAdd failed to add party member [" + _loc1_.id + "] for " + this);
               }
            }
         }
         end();
      }
   }
}
