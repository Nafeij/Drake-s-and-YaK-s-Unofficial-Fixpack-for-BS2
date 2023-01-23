package engine.saga.action
{
   import engine.entity.def.IEntityDef;
   import engine.entity.def.Item;
   import engine.entity.def.ItemDef;
   import engine.saga.Saga;
   
   public final class Action_ItemRemove extends Action
   {
       
      
      public function Action_ItemRemove(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc3_:Item = null;
         var _loc4_:Item = null;
         var _loc5_:int = 0;
         var _loc6_:IEntityDef = null;
         var _loc1_:ItemDef = null;
         var _loc2_:IEntityDef = null;
         if(def.param)
         {
            _loc1_ = saga.def.itemDefs.getItemDef(def.param);
            if(!_loc1_)
            {
               saga.logger.error("Invalid item def id [" + def.param + "] for " + this);
               end();
               return;
            }
         }
         if(def.id)
         {
            _loc2_ = saga.caravan._legend.roster.getEntityDefById(def.id);
            if(!_loc2_)
            {
               saga.logger.error("Invalid unit id [" + def.id + "] for " + this);
               end();
               return;
            }
         }
         if(!_loc1_ && !_loc2_)
         {
            saga.logger.error("No unit or item specified for " + this);
            end();
            return;
         }
         if(Boolean(_loc1_) && Boolean(_loc2_))
         {
            if(Boolean(_loc2_.defItem) && _loc2_.defItem.def.id == _loc1_.id)
            {
               _loc3_ = _loc2_.defItem;
               _loc3_.owner = null;
               _loc2_.defItem = null;
               saga.caravan._legend._items.removeItemById(_loc3_.id);
            }
         }
         else if(_loc1_)
         {
            for each(_loc4_ in saga.caravan._legend._items.items)
            {
               if(_loc4_.def.id == _loc1_.id)
               {
                  _loc3_ = _loc4_;
                  if(_loc3_.owner)
                  {
                     _loc3_.owner.defItem = null;
                     _loc3_.owner = null;
                  }
                  saga.caravan._legend._items.removeItemById(_loc3_.id);
                  break;
               }
            }
            if(!_loc3_)
            {
               _loc5_ = 0;
               while(_loc5_ < saga.caravan._legend.roster.numEntityDefs)
               {
                  _loc6_ = saga.caravan._legend.roster.getEntityDef(_loc5_);
                  if(Boolean(_loc6_.defItem) && _loc6_.defItem.def.id == _loc1_.id)
                  {
                     _loc3_ = _loc6_.defItem;
                     _loc6_.defItem = null;
                     _loc3_.owner = null;
                     break;
                  }
                  _loc5_++;
               }
            }
         }
         else if(_loc2_.defItem)
         {
            _loc3_ = _loc2_.defItem;
            _loc3_.owner = null;
            _loc2_.defItem = null;
         }
         end();
      }
   }
}
