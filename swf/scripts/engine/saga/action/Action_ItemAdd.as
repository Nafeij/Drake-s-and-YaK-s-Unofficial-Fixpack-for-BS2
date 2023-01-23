package engine.saga.action
{
   import engine.entity.def.IEntityDef;
   import engine.entity.def.Item;
   import engine.entity.def.ItemDef;
   import engine.saga.Saga;
   
   public class Action_ItemAdd extends Action
   {
       
      
      public function Action_ItemAdd(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc3_:uint = 0;
         var _loc4_:String = null;
         var _loc5_:IEntityDef = null;
         var _loc1_:ItemDef = saga.def.itemDefs.getItemDef(def.id);
         if(!_loc1_)
         {
            saga.logger.error("Invalid item def id [" + def.id + "] for " + this);
            end();
            return;
         }
         var _loc2_:Item = saga.gainItemDef(_loc1_);
         if(_loc2_)
         {
            if(!def.suppress_flytext)
            {
               _loc3_ = 16777215;
               _loc4_ = saga.locale.translateGui("gained_item");
               saga.showFlyText(_loc4_ + " " + _loc1_.colorizedName,_loc3_,"ui_stats_total",2);
            }
         }
         if(def.speaker)
         {
            _loc5_ = saga.caravan._legend.roster.getEntityDefById(def.speaker);
            if(!_loc5_)
            {
               saga.logger.error("Invalid unit id [" + def.speaker + "] for " + this);
               end();
               return;
            }
            if(_loc5_.defItem)
            {
               _loc5_.defItem.owner = null;
               saga.caravan._legend._items.addItem(_loc5_.defItem);
            }
            _loc5_.defItem = _loc2_;
            _loc2_.owner = _loc5_;
            saga.caravan._legend._items.removeItemById(_loc2_.id);
         }
         end();
      }
   }
}
