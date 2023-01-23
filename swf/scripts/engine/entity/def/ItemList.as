package engine.entity.def
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class ItemList extends EventDispatcher
   {
      
      public static var EVENT_CHANGED:String = "Item.EVENT_CHANGED";
       
      
      public var items:Vector.<Item>;
      
      public var itemsById:Dictionary;
      
      public function ItemList()
      {
         this.items = new Vector.<Item>();
         this.itemsById = new Dictionary();
         super();
      }
      
      public function clearItems() : void
      {
         this.items.splice(0,this.items.length);
         this.itemsById = new Dictionary();
      }
      
      public function addItem(param1:Item) : Item
      {
         if(this.getItem(param1.id))
         {
            throw new ArgumentError("ItemList.addItem already have " + param1.id);
         }
         this.items.push(param1);
         this.itemsById[param1.id] = param1;
         dispatchEvent(new Event(EVENT_CHANGED));
         return param1;
      }
      
      public function getItem(param1:String) : Item
      {
         return this.itemsById[param1];
      }
      
      public function removeItemById(param1:String) : Item
      {
         var _loc3_:int = 0;
         var _loc2_:Item = this.getItem(param1);
         if(_loc2_)
         {
            _loc3_ = this.items.indexOf(_loc2_);
            if(_loc3_ >= 0)
            {
               this.items.splice(_loc3_,1);
            }
            delete this.itemsById[param1];
            dispatchEvent(new Event(EVENT_CHANGED));
         }
         return _loc2_;
      }
   }
}
