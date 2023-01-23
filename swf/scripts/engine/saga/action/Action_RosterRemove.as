package engine.saga.action
{
   import engine.entity.def.IEntityDef;
   import engine.saga.Caravan;
   import engine.saga.Saga;
   import flash.errors.IllegalOperationError;
   
   public class Action_RosterRemove extends Action
   {
       
      
      public function Action_RosterRemove(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:Caravan = saga.caravan;
         if(!_loc1_)
         {
            throw new IllegalOperationError("No caravan set" + this);
         }
         var _loc2_:IEntityDef = _loc1_._legend.roster.getEntityDefById(def.id);
         if(_loc2_)
         {
            saga.caravan._legend.dismissEntity(_loc2_);
         }
         end();
      }
   }
}
