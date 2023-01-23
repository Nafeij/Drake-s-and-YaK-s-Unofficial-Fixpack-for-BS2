package engine.saga.action
{
   import engine.entity.def.IEntityDef;
   import engine.saga.Saga;
   
   public class Action_UnitUninjure extends Action
   {
       
      
      public function Action_UnitUninjure(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:IEntityDef = null;
         var _loc2_:int = 0;
         if(def.id != "*" && def.id != "*roster")
         {
            _loc1_ = saga.getCastMember(def.id);
            if(!_loc1_)
            {
               throw new ArgumentError("invalid entity not in cast: " + def.id);
            }
            saga.uninjure(_loc1_);
         }
         else if(def.id == "*roster")
         {
            _loc2_ = 0;
            while(_loc2_ < saga.roster.numEntityDefs)
            {
               saga.uninjure(saga.roster.getEntityDef(_loc2_));
               _loc2_++;
            }
         }
         else
         {
            saga.uninjureAll();
         }
         end();
      }
   }
}
