package engine.saga.action
{
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import engine.entity.def.IPartyDef;
   import engine.saga.Saga;
   
   public class Action_PartyRemove extends Action
   {
       
      
      public function Action_PartyRemove(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:IEntityListDef = saga.caravan._legend.roster;
         var _loc2_:IPartyDef = saga.caravan._legend.party;
         var _loc3_:IEntityDef = saga.getCastMember(def.id);
         if(!_loc3_)
         {
            throw new ArgumentError("No such cast member [" + def.id + "]");
         }
         _loc2_.removeMember(_loc3_.id);
         end();
      }
   }
}
