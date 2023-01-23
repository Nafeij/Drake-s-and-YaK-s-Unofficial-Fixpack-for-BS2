package engine.saga.action
{
   import engine.saga.Caravan;
   import engine.saga.Saga;
   
   public class Action_RosterClear extends Action
   {
       
      
      public function Action_RosterClear(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:Caravan = saga.caravan;
         if(def.id)
         {
            _loc1_ = saga.getCaravan(def.id) as Caravan;
            if(!_loc1_)
            {
               throw new ArgumentError("No such caravan [" + def.id + "]");
            }
         }
         _loc1_._legend.party.clear();
         _loc1_._legend.roster.clear();
         _loc1_._legend.computeRosterRowCount();
         end();
      }
   }
}
