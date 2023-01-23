package engine.saga.action
{
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import engine.entity.def.IPartyDef;
   import engine.saga.Saga;
   import engine.saga.SagaLegend;
   
   public class Action_PartyClear extends Action
   {
       
      
      public function Action_PartyClear(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:SagaLegend = null;
         var _loc2_:IPartyDef = null;
         var _loc3_:Boolean = false;
         var _loc4_:IEntityListDef = null;
         var _loc5_:int = 0;
         var _loc6_:IEntityDef = null;
         if(saga.caravan)
         {
            _loc1_ = saga.caravan._legend;
            _loc2_ = _loc1_.party;
            _loc3_ = Boolean(def.param) && def.param.indexOf("roster") >= 0;
            _loc4_ = _loc1_.roster;
            _loc5_ = 0;
            while(_loc5_ < _loc2_.numMembers)
            {
               _loc6_ = _loc2_.getMember(_loc5_);
               if(_loc6_.partyRequired)
               {
                  logger.info("Action_PartyClear skipping required unit " + _loc6_.id);
               }
               else
               {
                  logger.info("Action_PartyClear removing " + _loc6_.id);
                  if(_loc3_)
                  {
                     _loc4_.removeEntityDef(_loc6_);
                  }
               }
               _loc5_++;
            }
            _loc2_.clear();
         }
         end();
      }
   }
}
