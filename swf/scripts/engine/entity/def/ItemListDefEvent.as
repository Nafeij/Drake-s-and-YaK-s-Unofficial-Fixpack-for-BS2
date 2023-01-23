package engine.entity.def
{
   import flash.events.Event;
   
   public class ItemListDefEvent extends Event
   {
      
      public static var EVENT_ADDED:String = "ItemListDefEvent.EVENT_ADDED";
      
      public static var EVENT_REMOVED:String = "ItemListDefEvent.EVENT_REMOVED";
      
      public static var EVENT_PROMOTED:String = "ItemListDefEvent.EVENT_PROMOTED";
      
      public static var EVENT_DEMOTED:String = "ItemListDefEvent.EVENT_DEMOTED";
      
      public static var EVENT_REID:String = "ItemListDefEvent.EVENT_REID";
       
      
      public var itemDef:ItemDef;
      
      public var index:int;
      
      public function ItemListDefEvent(param1:String, param2:ItemDef, param3:int)
      {
         super(param1);
         this.itemDef = param2;
         this.index = param3;
      }
   }
}
