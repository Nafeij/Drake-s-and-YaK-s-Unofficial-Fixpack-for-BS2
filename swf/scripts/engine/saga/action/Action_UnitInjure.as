package engine.saga.action
{
   import engine.entity.def.IEntityDef;
   import engine.saga.Saga;
   
   public class Action_UnitInjure extends Action
   {
       
      
      public function Action_UnitInjure(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:IEntityDef = null;
         if(def.id != "*")
         {
            _loc1_ = saga.getCastMember(def.id);
            if(!_loc1_)
            {
               throw new ArgumentError("invalid entity not in cast: " + def.id);
            }
            saga.injure(_loc1_,true);
         }
         else
         {
            saga.injureAll();
         }
         end();
      }
   }
}
