package engine.saga.action
{
   import engine.entity.def.ItemDef;
   import engine.saga.Saga;
   
   public class Action_ItemAll extends Action
   {
       
      
      public function Action_ItemAll(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:ItemDef = null;
         for each(_loc1_ in saga.def.itemDefs.items)
         {
            saga.gainItemDef(_loc1_);
         }
         end();
      }
   }
}
