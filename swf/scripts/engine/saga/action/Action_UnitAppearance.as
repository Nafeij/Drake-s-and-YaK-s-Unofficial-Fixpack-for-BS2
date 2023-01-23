package engine.saga.action
{
   import engine.entity.def.IEntityDef;
   import engine.saga.Saga;
   
   public class Action_UnitAppearance extends Action
   {
       
      
      public function Action_UnitAppearance(param1:ActionDef, param2:Saga)
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
         _loc1_.appearanceIndex = def.varvalue;
         end();
      }
   }
}
