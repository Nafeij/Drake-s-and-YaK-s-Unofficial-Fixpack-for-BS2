package engine.saga.action
{
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import engine.entity.def.IPartyDef;
   import engine.saga.Saga;
   
   public class Action_PartyAdd extends Action
   {
       
      
      public function Action_PartyAdd(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:IEntityListDef = saga.caravan._legend.roster;
         var _loc2_:IPartyDef = saga.caravan._legend.party;
         var _loc3_:IEntityDef = saga.getCastMember(def.id);
         var _loc4_:String = def.param;
         var _loc5_:Boolean = Boolean(_loc4_) && _loc4_.indexOf("optional") >= 0;
         var _loc6_:Boolean = Boolean(_loc4_) && _loc4_.indexOf("overfill") >= 0;
         if(!_loc3_)
         {
            throw new ArgumentError("No such cast member [" + def.id + "]");
         }
         if(!_loc1_.getEntityDefById(_loc3_.id))
         {
            if(_loc5_)
            {
               logger.info("Skipping optional missing roster member " + _loc3_.id + " for " + this);
               end();
               return;
            }
            throw new ArgumentError("Member " + _loc3_.id + " not in roster");
         }
         if(_loc2_.numMembers >= 6)
         {
            if(!_loc6_)
            {
               if(_loc5_)
               {
                  logger.info("Skipping optional full for " + _loc3_.id + " for " + this);
               }
               else
               {
                  saga.logger.error("Action_PartyAdd Party is full " + this);
               }
               end();
               return;
            }
         }
         _loc2_.addMember(_loc3_.id);
         end();
      }
   }
}
