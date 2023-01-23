package engine.entity.def
{
   import flash.events.IEventDispatcher;
   
   public interface ILegend extends IEventDispatcher
   {
       
      
      function get renown() : int;
      
      function set renown(param1:int) : void;
      
      function get roster() : IEntityListDef;
      
      function get party() : IPartyDef;
      
      function get items() : ItemList;
      
      function get itemDefs() : ItemListDef;
      
      function dismissEntity(param1:IEntityDef) : void;
      
      function getAllSortedItems(param1:Item) : Vector.<Item>;
      
      function purchaseVariation(param1:IEntityDef, param2:int) : void;
      
      function putItemOnEntity(param1:IEntityDef, param2:Item) : void;
      
      function rename(param1:String, param2:String) : void;
      
      function promote(param1:String, param2:String, param3:String, param4:Function) : void;
      
      function unlockRosterRow(param1:Function) : Boolean;
      
      function get rosterRowCount() : int;
      
      function get rosterSlotAvailable() : Boolean;
      
      function get rosterSlotsPerRow() : int;
      
      function hireRosterUnit(param1:IPurchasableUnit, param2:Boolean, param3:Function) : void;
   }
}
