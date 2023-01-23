package engine.saga.action
{
   import engine.entity.def.IEntityDef;
   import engine.entity.def.Item;
   import engine.saga.Saga;
   
   public class Action_UnitTransferItem extends Action
   {
       
      
      public function Action_UnitTransferItem(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc3_:IEntityDef = null;
         var _loc1_:IEntityDef = saga.getCastMember(def.id);
         if(!_loc1_)
         {
            throw new ArgumentError("invalid entity not in cast: id=" + def.id);
         }
         var _loc2_:Item = _loc1_.defItem;
         if(_loc2_)
         {
            _loc3_ = saga.getCastMember(def.speaker);
            _loc1_.defItem = null;
            _loc2_.owner = _loc3_;
            if(!_loc3_)
            {
               if(saga.caravan)
               {
                  saga.caravan._legend._items.addItem(_loc2_);
               }
            }
            else
            {
               _loc3_.defItem = _loc2_;
            }
         }
         end();
      }
   }
}
